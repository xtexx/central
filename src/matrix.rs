use std::{borrow::Cow, fs, sync::Arc};

use anyhow::Result;
use futures::{FutureExt, StreamExt, executor::block_on, select};
use kstring::KString;
use log::{debug, error, info};
use matrix_sdk::{
    Client, LoopCtrl, Room, SqliteStoreConfig,
    authentication::matrix::MatrixSession,
    config::SyncSettings,
    crypto::{SasState, format_emojis},
    deserialized_responses::{TimelineEvent, TimelineEventKind},
    encryption::verification::{
        SasVerification, Verification, VerificationRequest, VerificationRequestState,
    },
    media::{MediaFormat, MediaRequestParameters},
    ruma::{
        OwnedRoomId, OwnedUserId, RoomId, TransactionId, UserId,
        api::client::filter::FilterDefinition,
        events::{
            AnyMessageLikeEvent, AnySyncTimelineEvent, MessageLikeEventType,
            key::verification::{VerificationMethod, request::ToDeviceKeyVerificationRequestEvent},
            room::{
                MediaSource,
                member::StrippedRoomMemberEvent,
                message::{
                    MessageType, OriginalSyncRoomMessageEvent, Relation, RoomMessageEventContent,
                    SyncRoomMessageEvent,
                },
            },
        },
    },
    store::RoomLoadSettings,
};
use serde::{Deserialize, Serialize};
use tokio::sync::mpsc;

use crate::{
    State, USER_AGENT,
    config::{ClientConfig, MatrixClientConfig},
    data::{Message, MessageBody},
    processor::upload_to_pastebin,
};

pub async fn run_bridge(mut state: State, client_id: KString) -> Result<()> {
    let config = match state.config.clients.get(&client_id).unwrap() {
        ClientConfig::Matrix(config) => config,
        _ => unreachable!(),
    };
    let config = Arc::new(config.clone());

    let user = UserId::parse(&config.client.user)?;

    let client = Client::builder()
        .server_name(user.server_name())
        .handle_refresh_tokens()
        .respect_login_well_known(true)
        .sqlite_store_with_config_and_cache_path(
            SqliteStoreConfig::new(&config.client.store_path)
                .optimize(true)
                .passphrase(config.client.store_passphrase.as_ref().map(String::as_str)),
            Some(&config.client.cache_path),
        )
        .user_agent(USER_AGENT)
        .build()
        .await?;

    let mut session = if config.client.session_path.exists() {
        info!("{}: loading session file ...", &client_id);
        let session = SessionData::load(&config)?;

        info!("{}: restoring user session ...", &client_id);
        client
            .matrix_auth()
            .restore_session(session.user_session.clone(), RoomLoadSettings::default())
            .await?;

        session
    } else {
        info!("{}: initializing new login ...", &client_id);

        client
            .matrix_auth()
            .login_username(&user, &config.client.password)
            .initial_device_display_name(env!("CARGO_PKG_NAME"))
            .send()
            .await?;

        info!("{}: login completed", &client_id);

        SessionData {
            user_session: client
                .matrix_auth()
                .session()
                .expect("user session must be present after login"),
            sync_token: None,
        }
    };

    info!("{}: starting initial sync ...", &client_id);

    // skip messages during the offline time
    {
        let mut sync_settings =
            SyncSettings::new().filter(FilterDefinition::with_lazy_loading().into());
        if let Some(sync_token) = &session.sync_token {
            sync_settings = sync_settings.token(sync_token);
        }
        let config = config.clone();
        loop {
            match client.sync_once(sync_settings.clone()).await {
                Ok(response) => {
                    session.sync_token = Some(response.next_batch);
                    session.save(&config)?;
                    break;
                }
                Err(error) => {
                    error!(
                        "{}: error occurred during initial sync: {error}",
                        &client_id
                    );
                }
            }
        }
    }

    let sync_settings = SyncSettings::new().token(
        session
            .sync_token
            .as_ref()
            .expect("sync token must be present after initial sync"),
    );

    let (input_tx, mut input_rx) = mpsc::unbounded_channel();

    client.add_event_handler(async move |ev: SyncRoomMessageEvent, room: Room| {
        input_tx.send((room.room_id().to_owned(), ev))
    });

    {
        let client_id = client_id.clone();
        let config = config.clone();

        client.add_event_handler(
            |ev: StrippedRoomMemberEvent, client: Client, room: Room| async move {
                if ev.state_key == client.user_id().unwrap() {
                    let room_id = room.room_id();
                    let accept = config.rooms.contains_key(room_id.as_str());
                    info!("{client_id}: got invitation to room {room_id}");

                    if accept {
                        if let Err(error) = room.join().await {
                            error!("{client_id}: failed to join room {room_id}: {error}");
                        } else {
                            info!("{client_id}: joined room {room_id}");
                        }
                    } else {
                        if let Err(error) = room.leave().await {
                            error!("{client_id}: failed to reject invitation for room {room_id}: {error}");
                        } else {
                            info!("{client_id}: rejected invitation for room {room_id}");
                        }
                    }
                }
            },
        );
    }

    {
        let client_id = client_id.clone();
        let user = user.clone();

        client.add_event_handler(
            |ev: ToDeviceKeyVerificationRequestEvent, client: Client| async move {
                let request = client
                    .encryption()
                    .get_verification_request(&ev.sender, &ev.content.transaction_id)
                    .await
                    .expect("Request object wasn't created");

                tokio::spawn(handle_verification_req(client_id, user, request));
            },
        );
    }

    info!("{}: ready", &client_id);

    {
        let client = client.clone();
        let client_id = client_id.clone();
        let config = config.clone();
        tokio::spawn(async move {
            loop {
                select! {
                    ev = input_rx.recv().fuse() => {
                        let (room_id, ev) = ev.unwrap();
                        if let Err(error) = handle_incoming_message(
                            &state,
                            &client_id,
                            &config,
                            &client,
                            room_id,
                            ev,
                        )
                        .await
                        {
                            error!("{client_id}: failed to handle incoming message: {error}")
                        }
                    },
                    msg = state.output_rx.recv().fuse() => {
                        let msg = msg.unwrap();
                        if let Err(error) = handle_outgoing_message(&client_id, &config, &client, msg).await
                        {
                            error!("{client_id}: failed to handle incoming message: {error}")
                        }
                    },
                };
            }
        });
    }

    client
        .sync_with_result_callback(sync_settings, |sync_result| {
            match sync_result {
                Ok(response) => {
                    SessionData {
                        user_session: session.user_session.clone(),
                        sync_token: Some(response.next_batch),
                    }
                    .save(&config)
                    .map_err(|err| matrix_sdk::Error::UnknownError(err.into()))
                    .unwrap();
                }
                Err(error) => error!("{}: sync error: {error}", &client_id),
            }

            async { Ok(LoopCtrl::Continue) }
        })
        .await?;
    Ok(())
}

#[derive(Debug, Serialize, Deserialize)]
struct SessionData {
    user_session: MatrixSession,
    // Sync token. Null only when the initial sync is not completed yet.
    sync_token: Option<String>,
}

impl SessionData {
    fn load(config: &MatrixClientConfig) -> Result<Self> {
        Ok(serde_json::from_str(&fs::read_to_string(
            &config.client.session_path,
        )?)?)
    }

    fn save(&self, config: &MatrixClientConfig) -> Result<()> {
        fs::write(&config.client.session_path, serde_json::to_string(&self)?)?;
        Ok(())
    }
}

async fn handle_incoming_message(
    state: &State,
    client_id: &KString,
    config: &MatrixClientConfig,
    client: &Client,
    mx_room_id: OwnedRoomId,
    event: SyncRoomMessageEvent,
) -> Result<()> {
    debug!("{}: received message: {:?}", &client_id, event);

    let original = match event.as_original() {
        Some(orig) => orig,
        None => return Ok(()),
    };

    if event.event_type() != MessageLikeEventType::RoomMessage {
        info!("{}: received message: {:?}", &client_id, event.event_type());
        return Ok(());
    }

    let room = if let Some(room) = config.rooms.get(&KString::from_ref(mx_room_id.as_str())) {
        room
    } else {
        info!("{}: leaving unknown room {}", &client_id, mx_room_id);
        if let Some(room) = client.get_room(&mx_room_id) {
            room.leave().await?;
            info!("{}: left unknown room {}", &client_id, mx_room_id);
        }
        return Ok(());
    };
    let mx_room = match client.get_room(&mx_room_id) {
        Some(mx_room) => mx_room,
        None => return Ok(()),
    };

    let sender = event.sender();
    if sender == client.user_id().unwrap() {
        return Ok(());
    }
    let mx_sender = match mx_room.get_member(sender).await? {
        Some(mx_sender) => mx_sender,
        None => return Ok(()),
    };
    let sender = mx_sender.display_name().unwrap_or_else(|| mx_sender.name());
    let sender = if mx_sender.name_ambiguous() {
        KString::from_string(format!("{} ({})", sender, mx_sender.name()))
    } else {
        KString::from_ref(sender)
    };

    state
        .input_tx
        .send(Message {
            origin: client_id.clone(),
            room: room.room.clone(),
            prefix: room.prefix.clone(),
            sender,
            body: format_body(state, &config, &mx_room, original).await?,
        })
        .await?;

    Ok(())
}

async fn handle_outgoing_message(
    client_id: &KString,
    config: &MatrixClientConfig,
    client: &Client,
    message: Message,
) -> Result<()> {
    if &message.origin == client_id {
        return Ok(());
    }

    let room = config
        .rooms
        .iter()
        .find(|(_, room)| room.room == message.room);
    let (mx_room_id, _) = match room {
        Some(room) => room,
        None => return Ok(()),
    };
    let mx_room = match client.get_room(<&RoomId>::try_from(mx_room_id.as_str())?) {
        Some(room) => room,
        None => return Ok(()),
    };

    let mut text = String::new();
    text.push('[');
    if let Some(prefix) = &message.prefix {
        text.push_str(&prefix);
        text.push_str(" - ");
    }
    text.push_str(&message.sender);
    text.push_str("] ");

    match message.body {
        MessageBody::Text(txt) => {
            text.push_str(&txt);
            let resp = mx_room
                .send(RoomMessageEventContent::text_markdown(text))
                .with_transaction_id(TransactionId::new())
                .await?
                .event_id;
            debug!("{client_id}: relayed message as event {resp}");
        }
    }

    Ok(())
}

async fn handle_verification_req(
    client_id: KString,
    user: OwnedUserId,
    request: VerificationRequest,
) {
    if request.other_user_id() != user {
        info!(
            "{client_id}: ignoring verification request from {}",
            request.other_user_id()
        );
        return;
    }

    info!("{client_id}: starting cross-signing bootstrap ...",);
    if let Err(error) = request
        .accept_with_methods(vec![VerificationMethod::SasV1])
        .await
    {
        error!("{client_id}: failed to accept verification request: {error}");
    };

    let mut stream = request.changes();
    while let Some(state) = stream.next().await {
        match state {
            VerificationRequestState::Created { .. }
            | VerificationRequestState::Requested { .. }
            | VerificationRequestState::Ready { .. } => (),
            VerificationRequestState::Transitioned { verification } => {
                if let Verification::SasV1(sas) = verification {
                    tokio::spawn(handle_sas_verification(client_id, sas));
                    break;
                }
            }
            VerificationRequestState::Done | VerificationRequestState::Cancelled(_) => break,
        }
    }
}

async fn handle_sas_verification(client_id: KString, sas: SasVerification) {
    info!(
        "{client_id}: starting SASv1 verification with {} {}",
        &sas.other_device().user_id(),
        &sas.other_device().device_id()
    );
    if let Err(error) = sas.accept().await {
        error!("{client_id}: failed to accept SASv1 verification: {error}");
    };

    let mut stream = sas.changes();
    while let Some(state) = stream.next().await {
        match state {
            SasState::KeysExchanged { emojis, decimals } => {
                if let Some(emojis) = emojis {
                    info!(
                        "{client_id}: SASv1 emojis: {}",
                        format_emojis(emojis.emojis)
                    );
                }
                info!(
                    "{client_id}: SASv1 decimals: {} {} {}",
                    decimals.0, decimals.1, decimals.2
                );
                if let Err(error) = sas.confirm().await {
                    error!("{client_id}: failed to confirm keys for SASv1: {error}");
                };
            }
            SasState::Done { .. } => {
                let device = sas.other_device();

                info!(
                    "{client_id}: verified device with SASv1: {} {} {:?}",
                    device.user_id(),
                    device.device_id(),
                    device.local_trust_state()
                );

                break;
            }
            SasState::Cancelled(cancel_info) => {
                error!(
                    "{client_id}: SASv1 verification is cancelled: {}",
                    cancel_info.reason()
                );
                break;
            }
            SasState::Created { .. }
            | SasState::Started { .. }
            | SasState::Accepted { .. }
            | SasState::Confirmed => (),
        }
    }
}

async fn format_body(
    state: &State,
    config: &MatrixClientConfig,
    room: &Room,
    message: &OriginalSyncRoomMessageEvent,
) -> Result<MessageBody> {
    let mut reply_to = None;
    let mut edit_to = None;
    let mut content = &message.content.msgtype;

    if let Some(relation) = &message.content.relates_to {
        match relation {
            Relation::Reply { in_reply_to } => reply_to = Some(in_reply_to.event_id.clone()),
            Relation::Replacement(replacement) => {
                edit_to = Some(replacement.event_id.clone());
                content = &replacement.new_content.msgtype;
            }
            _ => {}
        }
    };

    let reply_to = match reply_to {
        Some(reply_to) => Some(room.event(&reply_to, None).await?),
        None => None,
    };
    let edit_to = match edit_to {
        Some(edit_to) => Some(room.event(&edit_to, None).await?),
        None => None,
    };

    format_content(state, config, room, content, reply_to, edit_to, false).await
}

/// Formats a body.
/// No async/await is allowed in short mode.
async fn format_content(
    state: &State,
    config: &MatrixClientConfig,
    room: &Room,
    body: &MessageType,
    reply_to: Option<TimelineEvent>,
    edit_to: Option<TimelineEvent>,
    short: bool,
) -> Result<MessageBody> {
    debug_assert!(!short || reply_to.is_none());
    debug_assert!(!short || edit_to.is_none());
    match body {
        MessageType::Text(content) => Ok(MessageBody::Text(format_text_content(
            state,
            config,
            room,
            maybe_strip_body(&content.body, short),
            reply_to,
            edit_to,
        )?)),
        MessageType::Notice(content) => Ok(MessageBody::Text(format!(
            "({})",
            format_text_content(
                state,
                config,
                room,
                maybe_strip_body(&content.body, short),
                reply_to,
                edit_to
            )?
        ))),
        MessageType::Emote(content) => Ok(MessageBody::Text(format!(
            "// {}",
            format_text_content(
                state,
                config,
                room,
                maybe_strip_body(&content.body, short),
                reply_to,
                edit_to
            )?
        ))),

        MessageType::Audio(content) => Ok(format_media(
            &state,
            &config,
            room,
            "audio",
            maybe_strip_body(&content.body, short),
            &content.source,
            &content.filename,
            content
                .info
                .as_ref()
                .and_then(|info| info.mimetype.as_ref().map(|s| s.as_ref())),
            reply_to,
            edit_to,
            short,
        )
        .await?),
        MessageType::File(content) => Ok(format_media(
            &state,
            &config,
            room,
            "file",
            maybe_strip_body(&content.body, short),
            &content.source,
            &content.filename,
            content
                .info
                .as_ref()
                .and_then(|info| info.mimetype.as_ref().map(|s| s.as_ref())),
            reply_to,
            edit_to,
            short,
        )
        .await?),
        MessageType::Image(content) => Ok(format_media(
            &state,
            &config,
            room,
            "image",
            maybe_strip_body(&content.body, short),
            &content.source,
            &content.filename,
            content
                .info
                .as_ref()
                .and_then(|info| info.mimetype.as_ref().map(|s| s.as_ref())),
            reply_to,
            edit_to,
            short,
        )
        .await?),
        MessageType::Video(content) => Ok(format_media(
            &state,
            &config,
            room,
            "video",
            maybe_strip_body(&content.body, short),
            &content.source,
            &content.filename,
            content
                .info
                .as_ref()
                .and_then(|info| info.mimetype.as_ref().map(|s| s.as_ref())),
            reply_to,
            edit_to,
            short,
        )
        .await?),
        _ => Ok(MessageBody::Text("(cannot display)".to_string())),
    }
}

async fn format_media(
    state: &State,
    config: &MatrixClientConfig,
    room: &Room,
    kind: &'static str,
    body: &str,
    source: &MediaSource,
    filename: &Option<String>,
    mimetype: Option<&str>,
    reply_to: Option<TimelineEvent>,
    edit_to: Option<TimelineEvent>,
    short: bool,
) -> Result<MessageBody> {
    let text = 'text: {
        if short {
            format!("{kind}: {body}")
        } else if !config.client.reupload_media {
            match source {
                MediaSource::Plain(uri) => match filename {
                    Some(filename) => format!(
                        "{kind}: {}_matrix/client/v1/media/download/{}/{}/{} ({body})",
                        room.client().homeserver(),
                        uri.server_name()?,
                        uri.media_id()?,
                        filename
                    ),
                    None => format!(
                        "{kind}: {}_matrix/client/v1/media/download/{}/{} ({body})",
                        room.client().homeserver(),
                        uri.server_name()?,
                        uri.media_id()?
                    ),
                },
                MediaSource::Encrypted(_) => format!("{kind}: {body}"),
            }
        } else {
            let result = room
                .client()
                .media()
                .get_media_content(
                    &MediaRequestParameters {
                        source: source.clone(),
                        format: MediaFormat::File,
                    },
                    false,
                )
                .await;
            let data = match result {
                Ok(data) => data,
                Err(error) => {
                    error!("failed to download Matrix media: {source:?}: {error}");
                    break 'text format!("{kind}: {body} (failed to download)");
                }
            };
            let result = upload_to_pastebin(
                &state,
                reqwest::multipart::Part::bytes(data)
                    .mime_str(mimetype.unwrap_or("application/octet-stream"))?
                    .file_name(
                        filename
                            .clone()
                            .map(Cow::Owned)
                            .unwrap_or(Cow::Borrowed(kind)),
                    ),
            )
            .await;
            match result {
                Ok(data) => data,
                Err(_) => {
                    format!("{kind}: {body} (failed to reupload)")
                }
            }
        }
    };
    Ok(MessageBody::Text(format_text_content(
        state, config, room, &text, reply_to, edit_to,
    )?))
}

fn format_text_content(
    state: &State,
    config: &MatrixClientConfig,
    room: &Room,
    body: &str,
    reply_to: Option<TimelineEvent>,
    edit_to: Option<TimelineEvent>,
) -> Result<String> {
    let mut text = String::new();

    if let Some(reply_to) = &reply_to {
        text.push_str(&format!(
            "Re: {}: {text}",
            format_tl_event(state, config, room, reply_to)?
        ));
    }
    if let Some(edit_to) = &edit_to {
        text.push_str(&format!(
            "(edit: {}) {text}",
            format_tl_event(state, config, room, edit_to)?
        ));
    }

    if reply_to.is_some() {
        text.push_str(strip_rich_reply_fallback(&body));
    } else {
        text.push_str(&body);
    }

    Ok(text)
}

fn strip_rich_reply_fallback(mut text: &str) -> &str {
    while text.starts_with("> ") {
        match text.split_once('\n') {
            Some((_, next)) => text = next,
            None => break,
        }
    }
    text.trim_ascii()
}

fn maybe_strip_body(text: &str, strip: bool) -> &str {
    if strip {
        strip_rich_reply_fallback(text)
    } else {
        text
    }
}

fn format_tl_event(
    state: &State,
    config: &MatrixClientConfig,
    room: &Room,
    event: &TimelineEvent,
) -> Result<String> {
    let content = match &event.kind {
        TimelineEventKind::Decrypted(event) => Some(event.event.deserialize()?),
        TimelineEventKind::PlainText { event } => match event.deserialize()? {
            AnySyncTimelineEvent::MessageLike(event) => {
                Some(event.into_full_event(room.room_id().into()))
            }
            AnySyncTimelineEvent::State(_) => None,
        },
        _ => None,
    };
    if let Some(content) = content
        && !content.is_redacted()
    {
        match content {
            AnyMessageLikeEvent::RoomMessage(event) => {
                if let Some(orig) = event.as_original() {
                    return Ok(block_on(format_content(
                        state,
                        config,
                        room,
                        &orig.content.msgtype,
                        None,
                        None,
                        true,
                    ))?
                    .to_string());
                }
            }
            _ => {}
        }
    }
    Ok("(cannot display)".to_string())
}
