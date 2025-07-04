use anyhow::{Result, bail};
use futures::{FutureExt, StreamExt, select};
use irc::{client::prelude::*, proto::Message as IrcMessage};
use kstring::KString;
use log::{debug, info};

use crate::{
    State,
    config::{ClientConfig, IRCClientConfig},
    data::{Message, MessageBody},
};

pub async fn run_bridge(mut state: State, client_id: KString) -> Result<()> {
    let config = match state.config.clients.get(&client_id).unwrap() {
        ClientConfig::Irc(config) => config,
        _ => unreachable!(),
    };

    let mut irc_config = config.client.clone();
    if irc_config.version.is_none() {
        irc_config.version =
            Some(concat!(env!("CARGO_PKG_NAME"), ":", env!("CARGO_PKG_VERSION")).to_string());
    }
    if irc_config.source.is_none() {
        irc_config.source = Some(env!("CARGO_PKG_REPOSITORY").to_string());
    }

    let mut client = Client::from_config(irc_config).await?;
    client.identify()?;
    info!("{}: logged-in as {}", &client_id, client.current_nickname());

    let mut stream = client.stream()?;
    while let Some(message) = stream.next().await.transpose()? {
        debug!("{}: received pre-ready message: {}", &client_id, message);
        if let Command::Response(Response::RPL_ISUPPORT, _) = message.command {
            break;
        }
    }
    info!("{}: got RPL_ISUPPORT", &client_id);

    for (channel, room_config) in &config.rooms {
        info!("{}: joining channel {}", &client_id, channel);
        if let Some(key) = &room_config.key {
            client.send_join_with_keys(channel, key)?;
        } else {
            client.send_join(channel)?;
        }
    }

    info!("{}: ready", &client_id);

    loop {
        select! {
            message = stream.next() => {
                let message = match message{
                    Some(message) => message?,
                    None => bail!("IRC client exited"),
                };
                handle_incoming_message(&state, &client_id, config, &mut client, message).await?;
            },
            message = state.output_rx.recv().fuse() => {
                let message = message?;
                handle_outgoing_message(&client_id, config, &mut client, message)?;
            },
            complete => unreachable!(),
        };
    }
}

async fn handle_incoming_message(
    state: &State,
    client_id: &KString,
    config: &IRCClientConfig,
    client: &mut Client,
    message: IrcMessage,
) -> Result<()> {
    debug!("{}: received message: {}", &client_id, message);

    let (is_notice, target, text) = match message.command {
        Command::PRIVMSG(target, text) => (false, target, text),
        Command::NOTICE(target, text) => (true, target, text),
        Command::PING(..) => return Ok(()),
        Command::PONG(..) => return Ok(()),
        _ => {
            info!("{}: message: {}", client_id, message.to_string().trim());
            return Ok(());
        }
    };

    let prefix = if let Some(prefix) = message.prefix {
        prefix
    } else {
        return Ok(());
    };
    let sender = match prefix {
        Prefix::ServerName(_) => return Ok(()),
        Prefix::Nickname(nick, _, _) => nick,
    };

    if sender == client.current_nickname() {
        return Ok(());
    }

    if is_notice {
        info!("{}: notice: {} -> {}: {}", client_id, sender, target, text);
    } else if target.starts_with("#") {
        // channel message
        if let Some(room) = config.rooms.get(&KString::from_ref(&target)) {
            let msg = Message {
                origin: client_id.clone(),
                room: room.room.clone(),
                prefix: room.prefix.clone(),
                sender: KString::from_string(sender),
                body: MessageBody::Text(text),
            };
            state.input_tx.send(msg).await?;
        } else {
            info!(
                "{}: message from unknown channel: {}: {}",
                client_id, target, text
            );
        }
    } else {
        // private message
        info!("{}: private message: {}", client_id, text);
        // TODO
        client.send_privmsg(
            sender,
            concat!(
                "Hi! Please see ",
                env!("CARGO_PKG_REPOSITORY"),
                " for more info."
            ),
        )?;
    }

    Ok(())
}

fn handle_outgoing_message(
    client_id: &KString,
    config: &IRCClientConfig,
    client: &mut Client,
    message: Message,
) -> Result<()> {
    if &message.origin == client_id {
        return Ok(());
    }

    let room = config
        .rooms
        .iter()
        .find(|(_, room)| room.room == message.room);
    let (chan, _) = match room {
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
        MessageBody::Text(txt) => text.push_str(&txt),
    }

    for line in text.lines() {
        if line.is_empty() {
            continue;
        }
        debug!("{}: send: {}: {}", client_id, chan, line);
        client.send_privmsg(chan, line)?;
    }

    Ok(())
}
