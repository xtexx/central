use std::{fs, sync::Arc};

use anyhow::{Result, bail};
use log::info;
use tokio::{
    sync::{broadcast, mpsc},
    task::JoinSet,
};

use crate::{
    config::{ClientConfig, Config},
    data::Message,
};

mod config;
mod data;
mod irc;
mod processor;

struct State {
    config: Arc<Config>,
    output_rx: broadcast::Receiver<Message>,
    output_tx: broadcast::Sender<Message>,
    input_tx: mpsc::Sender<Message>,
}

impl Clone for State {
    fn clone(&self) -> Self {
        Self {
            config: self.config.clone(),
            output_rx: self.output_tx.subscribe(),
            output_tx: self.output_tx.clone(),
            input_tx: self.input_tx.clone(),
        }
    }
}

#[tokio::main]
async fn main() -> Result<()> {
    env_logger::builder()
        .filter_level(log::LevelFilter::Info)
        .parse_env("LITTLEBRIDGE_LOG")
        .try_init()?;

    let config_path =
        std::env::var("LITTLEBRIDGE_CONFIG").unwrap_or_else(|_| "config.toml".to_string());
    let config: Config = toml::from_str(&fs::read_to_string(config_path)?)?;
    let config = Arc::new(config);

    let (output_tx, output_rx) = broadcast::channel::<Message>(1024);
    let (input_tx, input_rx) = mpsc::channel(512);
    let mut jobs = JoinSet::<Result<()>>::new();

    let state = State {
        config: config.clone(),
        output_rx: output_rx,
        output_tx: output_tx,
        input_tx: input_tx,
    };

    jobs.spawn(processor::run_processor(state.clone(), input_rx));
    info!("Started message processor");

    for (client_id, config) in config.clients.iter() {
        match config {
            ClientConfig::Irc(_) => {
                jobs.spawn(irc::run_bridge(state.clone(), client_id.to_owned()))
            }
        };
        info!("Started client {client_id}");
    }
    drop(state);

    info!("Ready");
    match jobs.join_next().await {
        Some(result) => match result? {
            Ok(_) => bail!("A client exited without error code"),
            Err(err) => return Err(err),
        },
        None => unreachable!(),
    }
}

// fn start_backend::<B>()
