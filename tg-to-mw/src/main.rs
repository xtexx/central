use std::{env, fs, path::PathBuf};

use anyhow::Result;
use itertools::Itertools;
use mwbot::{Bot, SaveOptions};
use serde::{Deserialize, Serialize};
use time::{
    Duration,
    macros::{format_description, time},
};

// const PAGE_BASE: &str = "Board频道存档";
// const TEMPLATE_NAME: &str = "Board channel archive";
// const FILE_PREFIX: &str = "Board message";
// const USE_MONTHS: bool = false;

const PAGE_BASE: &str = "Park聊天记录存档";
const TEMPLATE_NAME: &str = "Park chat archive";
const FILE_PREFIX: &str = "Park message";
const USE_MONTHS: bool = true;

#[tokio::main]
async fn main() -> Result<()> {
    let bot = Bot::from_default_config().await?;
    let opts = SaveOptions::summary("Import archive from Telegram");

    let tg_export = serde_json::from_str::<ResultJson>(&fs::read_to_string(env::var("TG_JSON")?)?)?;

    if USE_MONTHS {
        let messages = tg_export
            .messages
            .iter()
            .chunk_by(|msg| msg.date[0..7].to_string());

        for (year_month, messages) in messages.into_iter() {
            println!("Processing {}", year_month);
            let title = format!("{}/{}", PAGE_BASE, year_month);

            let mut page = String::new();
            page.push_str(&format!(
                "{{{{{}|{}}}}}\n__NOTOC__\n",
                TEMPLATE_NAME, year_month
            ));

            let messages = messages.chunk_by(|msg| msg.date[8..10].to_string());
            for (day, messages) in messages.into_iter() {
                page.push_str(&format!("= {}日 =\n", day));
                for message in messages {
                    page.push_str("* ");
                    page.push_str(&build_message(&bot, &tg_export, message).await?);
                    page.push_str("\n");
                }
            }

            bot.page(&title)?.save(page, &opts).await?;
        }
    } else {
        let messages = tg_export
            .messages
            .iter()
            .chunk_by(|msg| msg.date[0..4].to_string());

        for (year, messages) in messages.into_iter() {
            println!("Processing {}", year);
            let year = year.parse::<usize>()?;
            let title = format!("{}/{}", PAGE_BASE, year);

            let mut page = String::new();
            page.push_str(&format!("{{{{{}|{}}}}}\n__NOTOC__\n", TEMPLATE_NAME, year));

            let messages = messages.chunk_by(|msg| msg.date[5..7].to_string());
            for (month, messages) in messages.into_iter() {
                let month = month.parse::<usize>()?;
                page.push_str(&format!("\n= {}月 =\n", month));

                let messages = messages.chunk_by(|msg| msg.date[8..10].to_string());
                for (day, messages) in messages.into_iter() {
                    page.push_str(&format!("== {}月{}日 ==\n", month, day));
                    for message in messages {
                        page.push_str("* ");
                        page.push_str(&build_message(&bot, &tg_export, message).await?);
                        page.push_str("\n");
                    }
                }
            }

            bot.page(&title)?.save(page, &opts).await?;
        }
    }

    Ok(())
}

async fn build_message(bot: &Bot, export: &ResultJson, msg: &MessageJson) -> Result<String> {
    let mut out = String::new();
    let mut suffix = String::new();
    out.push_str("{{Telegram message");
    out.push_str(&format!("|id={}", msg.id));
    out.push_str(&format!("|date={}", msg.date));
    if let Some(edited) = msg.edited_unixtime.as_ref() {
        let edited = edited.parse::<u64>()?;
        let date = msg.date_unixtime.parse::<u64>()?;
        if (edited - date) >= 5 * 60 {
            out.push_str(&format!("|edited={}", msg.edited.as_ref().unwrap()));
        }
    }
    if let Some(author) = msg.author.as_ref() {
        out.push_str(&format!("|author={}", sanitize(author)));
    } else if let Some(author) = msg.actor.as_ref() {
        out.push_str(&format!("|author={}", sanitize(author)));
    } else if let Some(author) = msg.from.as_ref() {
        out.push_str(&format!("|author={}", sanitize(author)));
    }
    if let Some(forwarded) = msg.forwarded_from.as_ref() {
        out.push_str(&format!("|forwarded={}", sanitize(forwarded)));
    }
    if let Some(target) = msg.reply_to_message_id {
        out.push_str(&format!(
            "|reply=[[{}|{}]]",
            make_link(export, msg, target),
            target
        ));
    }
    out.push('|');

    if let Some(file) = &msg.file {
        if !file.contains("File unavailable") && !file.contains("File not included") {
            let file_ext = file.split('.').last().unwrap();
            let filename = format!("{} {}.{}", FILE_PREFIX, msg.id, file_ext);
            let local_file = PathBuf::from(env::var("TG_EXPORT")?).join(file);
            let mut ok = false;
            if !bot.page(&format!("File:{}", filename))?.exists().await? {
                println!("Uploading {} to {}", file, filename);
                if let Err(err) = bot
                    .api()
                    .upload(
                        &filename,
                        local_file,
                        5_000_000,
                        true,
                        &[("text", format!("[[Category:{}]]", PAGE_BASE))],
                    )
                    .await
                {
                    println!("{:#?}", err);
                } else {
                    ok = true;
                }
            } else {
                ok = true;
            }
            if ok {
                out.push_str(&format!(
                    "''([[:File:{}|{}]])''",
                    filename,
                    file.strip_prefix("files/").unwrap()
                ));
                suffix.push_str(&format!("[[File:{}|thumb]]", filename));
            } else {
                out.push_str(&format!(
                    "''(file upload failure, {})''",
                    file.strip_prefix("files/").unwrap()
                ));
            }
        }
    }

    if let Some(action) = &msg.action {
        match action.as_str() {
            "create_channel" => {
                out.push_str("''created channel''");
            }
            "create_group" => {
                out.push_str("''created group''");
            }
            "migrate_to_supergroup" => {
                out.push_str("''migrated to super-group''");
            }
            "migrate_from_group" => {
                out.push_str("''migrated from normal-group''");
            }
            "edit_group_photo" => {
                out.push_str("''updated group avatar''");
            }
            "group_call" => {
                if let Some(duration) = msg.duration {
                    let duration = Duration::seconds(duration);
                    let duration = time!(00:00:00) + duration;
                    let duration =
                        duration.format(&format_description!("[hour]:[minute]:[second]"))?;
                    out.push_str(&format!("''voice call, lasting {}''", duration));
                } else {
                    out.push_str("''voice call''");
                }
            }
            "pin_message" => {
                let target = msg.message_id.unwrap();
                out.push_str(&format!(
                    "''pinned message [[{}|{}]]''",
                    make_link(export, msg, target),
                    target
                ));
            }
            "invite_members" => {
                out.push_str("''invited member(s)");
                let mut first = true;
                if let Some(members) = &msg.members {
                    for member in members {
                        if let Some(member) = member {
                            if !first {
                                out.push_str(", ");
                            }
                            out.push_str(member);
                            first = false;
                        }
                    }
                }
                out.push_str("''");
            }
            "remove_members" => {
                out.push_str("''removed member(s)");
                let mut first = true;
                if let Some(members) = &msg.members {
                    for member in members {
                        if let Some(member) = member {
                            if !first {
                                out.push_str(", ");
                            }
                            out.push_str(member);
                            first = false;
                        }
                    }
                }
                out.push_str("''");
            }
            "set_messages_ttl" => {
                out.push_str("''updated group message TTL''");
            }
            _ => todo!("{action}"),
        }
    } else {
        for entity in &msg.text_entities {
            match entity.ty.as_ref() {
                "plain" | "email" | "custom_emoji" => out.push_str(&sanitize(entity.text.as_str())),
                "link" => {
                    out.push_str(&format!(
                        "[{} {}]",
                        entity.text.as_str(),
                        sanitize(entity.text.as_str())
                    ));
                }
                "text_link" => {
                    out.push_str(&format!(
                        "[{} {}]",
                        entity.href.as_ref().unwrap(),
                        sanitize(entity.text.as_str())
                    ));
                }
                "italic" | "bot_command" | "hashtag" => {
                    out.push_str(&format!("''{}''", sanitize(entity.text.as_str())));
                }
                "underline" => {
                    out.push_str(&format!("<u>{}</u>", sanitize(entity.text.as_str())));
                }
                "strikethrough" => {
                    out.push_str(&format!("<s>{}</s>", sanitize(entity.text.as_str())));
                }
                "mention" => {
                    out.push_str(&format!("''{}''", sanitize(entity.text.as_str())));
                }
                "mention_name" => {
                    out.push_str(&format!(
                        "''@{} ({})''",
                        sanitize(entity.text.as_str()),
                        entity.user_id.unwrap()
                    ));
                }
                "pre" => {
                    if let Some(lang) = &entity.language {
                        out.push_str(&format!(
                            "<syntaxhighlight lang=\"{}\">\n{}\n</syntaxhighlight>",
                            lang,
                            sanitize(entity.text.as_str())
                        ));
                    } else {
                        out.push_str(&format!(
                            "<syntaxhighlight>\n{}\n</syntaxhighlight>",
                            sanitize(entity.text.as_str())
                        ));
                    }
                }
                "spoiler" => {
                    out.push_str("{{Spoiler|");
                    out.push_str(&sanitize(entity.text.as_str()));
                    out.push_str("}}");
                }
                "code" => {
                    out.push_str("<code>");
                    out.push_str(&sanitize(entity.text.as_str()));
                    out.push_str("</code>");
                }
                "bold" => {
                    out.push_str("'''");
                    out.push_str(&sanitize(entity.text.as_str()));
                    out.push_str("'''");
                }
                _ => todo!("{}", entity.ty),
            }
        }
        if let Some(emoji) = &msg.sticker_emoji {
            out.push_str(emoji);
        }
    }
    out.push_str("}}");
    out.push_str(&suffix);
    Ok(out)
}

fn make_link(export: &ResultJson, msg: &MessageJson, id: i64) -> String {
    let year = export
        .messages
        .iter()
        .find(|msg| msg.id == id)
        .unwrap_or(msg);
    let year = year.date[0..4].parse::<usize>().unwrap();
    format!("{}/{}#msg{}", PAGE_BASE, year, id)
}

fn sanitize<S: AsRef<str>>(text: S) -> String {
    text.as_ref()
        .replace('{', "<nowiki>{</nowiki>")
        .replace('}', "<nowiki>}</nowiki>")
        .replace('|', "{{!}}")
}

#[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct ResultJson {
    pub name: String,
    #[serde(rename = "type")]
    pub ty: String,
    pub id: i64,
    pub messages: Vec<MessageJson>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct MessageJson {
    pub id: i64,
    #[serde(rename = "type")]
    pub type_field: String,
    pub date: String,
    pub date_unixtime: String,
    pub actor: Option<String>,
    pub actor_id: Option<String>,
    pub action: Option<String>,
    pub title: Option<String>,
    pub full_text: String,
    pub text: serde_json::Value,
    pub text_entities: Vec<TextJson>,
    pub photo: Option<String>,
    pub width: Option<i64>,
    pub height: Option<i64>,
    pub media_group_id: Option<i64>,
    pub from: Option<String>,
    pub from_id: Option<String>,
    pub author: Option<String>,
    pub forwarded_from: Option<String>,
    pub duration: Option<i64>,
    pub edited: Option<String>,
    pub edited_unixtime: Option<String>,
    pub file: Option<String>,
    pub thumbnail: Option<String>,
    pub mime_type: Option<String>,
    pub reply_to_message_id: Option<i64>,
    pub message_id: Option<i64>,
    pub media_type: Option<String>,
    pub duration_seconds: Option<i64>,
    pub sticker_emoji: Option<String>,
    pub members: Option<Vec<Option<String>>>,
    pub peroid: Option<i64>,
}

#[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct TextJson {
    #[serde(rename = "type")]
    pub ty: String,
    pub text: String,
    pub href: Option<String>,
    pub user_id: Option<i64>,
    pub language: Option<String>,
}
