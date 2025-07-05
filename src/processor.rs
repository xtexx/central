use anyhow::Result;
use log::{error, info};
use reqwest::multipart::{Form, Part};
use tokio::sync::mpsc;

use crate::{
    State,
    data::{Message, MessageBody},
};

pub async fn run_processor(state: State, mut input_rx: mpsc::Receiver<Message>) -> Result<()> {
    loop {
        let mut msg = input_rx.recv().await.unwrap();
        let mut use_pastebin = false;
        match &msg.body {
            MessageBody::Text(text) => {
                if text.contains("!NOFWD") {
                    continue;
                }
                if text.contains("!PB") {
                    use_pastebin = true;
                }
                if text.len() > 256 {
                    use_pastebin = true;
                }
            }
        }

        if use_pastebin
            && let Ok(body) = upload_to_pastebin(
                &state,
                Part::bytes(msg.body.to_string().into_bytes())
                    .mime_str("text/plain")?
                    .file_name("message.txt"),
            )
            .await
        {
            msg.body = MessageBody::Text(body);
        }

        info!(
            "{}: {}: [{}] {}: {}",
            &msg.origin,
            &msg.room,
            msg.prefix.clone().unwrap_or_default(),
            &msg.sender,
            &msg.body,
        );
        state.output_tx.send(msg)?;
    }
}

pub async fn upload_to_pastebin(state: &State, part: Part) -> Result<String> {
    let http_client = state.http_client.clone();
    let result = (async move {
        let form = Form::new()
            .part("file", part)
            .text("secret", "")
            .text("expires", "120");
        let resp = http_client
            .post("https://envs.sh")
            .multipart(form)
            .send()
            .await?
            .error_for_status()?;
        let token = resp
            .headers()
            .get("x-token")
            .map(|header| header.to_str())
            .transpose()?
            .unwrap_or("(none)")
            .to_string();
        let url = resp.text().await?.trim().to_string();
        info!("Uploaded message to pastebin: {url} (token: {token})");
        Ok::<_, anyhow::Error>(url)
    })
    .await;
    match result {
        Ok(body) => Ok(body),
        Err(error) => {
            error!("Failed to upload message to pastebin: {error}");
            Err(error)
        }
    }
}
