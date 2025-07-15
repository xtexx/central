use std::{env, fs};

use anyhow::{Result, bail};
use base64::{Engine, prelude::BASE64_STANDARD};
use log::info;
use reqwest::ClientBuilder;
use serde::Deserialize;

#[tokio::main]
async fn main() -> Result<()> {
    dotenvy::dotenv()?;
    env_logger::try_init()?;

    let ph_url = env::var("PH_URL").unwrap();
    let ph_token = env::var("PH_TOKEN").unwrap();
    let tg_url = env::var("TG_URL").unwrap();
    let tg_token = env::var("TG_TOKEN").unwrap();

    let tg_stickers = env::var("TG_STICKER_SET").unwrap();
    let ph_prefix = env::var("PH_PREFIX").unwrap();
    let ph_sub = env::var("PH_SUB").unwrap();

    let continue_from = env::var("CONTINUE")
        .map_err(anyhow::Error::from)
        .and_then(|s| Ok(s.parse::<usize>()?))
        .unwrap_or_default();

    let client = ClientBuilder::new().user_agent("xtex-bot").build()?;

    fs::create_dir_all("pack")?;

    info!("Getting sticker pack info ...");
    let sticker_set = client
        .get(format!(
            "{tg_url}/bot{tg_token}/getStickerSet?name={tg_stickers}"
        ))
        .send()
        .await?
        .error_for_status()?
        .json::<TgResponse<TgStickerSet>>()
        .await?;
    assert!(sticker_set.ok);
    let sticker_set = sticker_set.result;

    info!("Target pack: {} / {}", sticker_set.name, sticker_set.title);
    info!("Found {} stickers in total", sticker_set.stickers.len());

    for (i, sticker) in sticker_set
        .stickers
        .into_iter()
        .enumerate()
        .skip(continue_from - 1)
    {
        let i = i + 1;
        info!("Uploading {i}: {sticker:?}");

        info!("Resolving Telegram file ...");
        let tg_file = client
            .get(format!(
                "{tg_url}/bot{tg_token}/getFile?file_id={}",
                sticker.file_id
            ))
            .send()
            .await?
            .error_for_status()?
            .json::<TgResponse<TgFile>>()
            .await?;
        assert!(tg_file.ok);
        let file_suffix = tg_file.result.file_path.split('.').last().unwrap();
        info!("Determined file suffix: {file_suffix}");

        info!("Downloading Telegram file ...");
        let sticker_data = client
            .get(format!(
                "{tg_url}/file/bot{tg_token}/{}",
                tg_file.result.file_path
            ))
            .send()
            .await?
            .error_for_status()?
            .bytes()
            .await?;
        fs::write(format!("pack/{i}.{file_suffix}"), &sticker_data)?;

        let ph_name = format!("{ph_prefix}-{i}");
        let ph_file_name = format!("{ph_name}.{file_suffix}");

        info!("Uploading file to Phorge ...");
        let upload_resp = client
            .post(format!("{ph_url}/api/file.upload"))
            .form(&[
                ("api.token", ph_token.as_str()),
                ("data_base64", BASE64_STANDARD.encode(sticker_data).as_str()),
                ("name", &ph_file_name),
                ("viewPolicy", "public"),
            ])
            .send()
            .await?
            .error_for_status()?
            .json::<PhResponse>()
            .await?;
        if !upload_resp.error_code.is_null() {
            bail!("Upload failed: {upload_resp:?}");
        }
        let file_phid = upload_resp.result.as_str().unwrap();
        info!("File uploaded: {file_phid}");

        let comment = format!(
            "Imported from Telegram sticker set {} (`{}`): {}, {}px x {}px, {} bytes, Telegram file UID: `{}`",
            sticker_set.title,
            sticker.set_name,
            sticker.emoji,
            sticker.width,
            sticker.height,
            sticker.file_size,
            sticker.file_unique_id
        );
        info!("Comment: {comment}");

        info!("Creating macro ...");
        let resp = client
            .post(format!("{ph_url}/api/macro.edit"))
            .form(&[
                ("api.token", ph_token.as_str()),
                ("transactions[0][type]", "name"),
                ("transactions[0][value]", &ph_name),
                ("transactions[1][type]", "filePHID"),
                ("transactions[1][value]", file_phid),
                ("transactions[2][type]", "comment"),
                ("transactions[2][value]", &comment),
                ("transactions[3][type]", "subscribers.add"),
                ("transactions[3][value][0]", &ph_sub),
            ])
            .send()
            .await?
            .error_for_status()?
            .json::<PhResponse>()
            .await?;
        if !resp.error_code.is_null() {
            bail!("Macro creation failed: {resp:?}");
        }
        info!("Macro created: {}", resp.result);
    }

    info!("Finished!");
    Ok(())
}

#[derive(Debug, Deserialize)]
struct TgResponse<T> {
    ok: bool,
    result: T,
}

#[derive(Debug, Deserialize)]
struct TgStickerSet {
    name: String,
    title: String,
    stickers: Vec<TgSticker>,
}

#[derive(Debug, Deserialize)]
struct TgSticker {
    width: u32,
    height: u32,
    emoji: String,
    set_name: String,
    file_id: String,
    file_unique_id: String,
    file_size: u32,
}

#[derive(Debug, Deserialize)]
struct TgFile {
    file_path: String,
}

#[derive(Debug, Deserialize)]
struct PhResponse {
    result: serde_json::Value,
    #[serde(default)]
    error_code: serde_json::Value,
    #[serde(default)]
    #[allow(dead_code)]
    error_info: serde_json::Value,
}
