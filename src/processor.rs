use anyhow::Result;
use log::info;
use tokio::sync::mpsc;

use crate::{State, data::Message};

pub async fn run_processor(state: State, mut input_rx: mpsc::Receiver<Message>) -> Result<()> {
    loop {
        let msg = input_rx.recv().await.unwrap();
        if msg.text.contains("!NOFWD") {
            continue;
        }

        info!(
            "{}: {}: [{}] {}: {}",
            &msg.origin,
            &msg.room,
            msg.prefix.clone().unwrap_or_default(),
            &msg.sender,
            &msg.text,
        );
        state.output_tx.send(msg)?;
    }
}
