use std::fmt::Display;

use kstring::KString;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct Message {
    /// ID of the original client.
    pub origin: KString,
    /// ID of the room.
    pub room: KString,

    /// Platform prefix.
    pub prefix: Option<KString>,

    pub sender: KString,
    pub body: MessageBody,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum MessageBody {
    Text(String),
}

impl Display for MessageBody {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            MessageBody::Text(text) => f.write_str(text),
        }
    }
}
