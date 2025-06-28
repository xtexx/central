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
    pub text: String,
}
