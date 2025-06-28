use std::collections::HashMap;

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

#[derive(Debug, Serialize, Deserialize)]
pub struct RoomConfig {}
