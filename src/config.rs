use std::{collections::HashMap, path::PathBuf};

use kstring::KString;
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct Config {
    #[serde(rename = "client")]
    pub clients: HashMap<KString, ClientConfig>,
    #[serde(rename = "room")]
    pub rooms: HashMap<KString, RoomConfig>,
}

#[derive(Debug, Serialize, Deserialize)]
#[serde(tag = "type", rename_all = "kebab-case")]
pub enum ClientConfig {
    Irc(IRCClientConfig),
    Matrix(MatrixClientConfig),
}

#[derive(Debug, Serialize, Deserialize)]
pub struct IRCClientConfig {
    pub client: irc::client::data::Config,
    #[serde(default, rename = "room")]
    pub rooms: HashMap<KString, IRCRoomConfig>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct IRCRoomConfig {
    pub room: KString,
    #[serde(default)]
    pub key: Option<String>,
    #[serde(default)]
    pub prefix: Option<KString>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MatrixClientConfig {
    pub client: MatrixBotConfig,
    #[serde(default, rename = "room")]
    pub rooms: HashMap<KString, MatrixRoomConfig>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MatrixBotConfig {
    pub user: KString,
    pub password: String,

    pub session_path: PathBuf,
    pub store_path: PathBuf,
    #[serde(default)]
    pub store_passphrase: Option<String>,
    pub cache_path: PathBuf,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MatrixRoomConfig {
    pub room: KString,
    #[serde(default)]
    pub prefix: Option<KString>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct RoomConfig {}
