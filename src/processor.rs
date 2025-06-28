use anyhow::Result;
use log::info;
use tokio::sync::mpsc;

use crate::{
    State,
    data::{Message, MessageBody},
};

pub async fn run_processor(state: State, mut input_rx: mpsc::Receiver<Message>) -> Result<()> {
    loop {
        let msg = input_rx.recv().await.unwrap();
        match &msg.body {
            MessageBody::Text(text) => {
                if text.contains("!NOFWD") {
                    continue;
                }
            }
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
