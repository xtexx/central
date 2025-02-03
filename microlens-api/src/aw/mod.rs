use axum::{Json, Router, routing::get};
use serde::{Deserialize, Serialize};

use crate::{Service, ServiceState};

pub fn create_router() -> Router<ServiceState> {
	Router::new().route("/", get(handle_root))
}

async fn handle_root(Service(service): Service) -> Json<AwSiteInfo> {
	Json(AwSiteInfo {
		hostname: service.config.hostname.clone(),
		version: format!("MicroLens v{}", env!("CARGO_PKG_VERSION")),
		testing: false,
		device_id: service.config.id.to_string(),
	})
}

#[derive(Debug, PartialEq, Eq, Clone, Serialize, Deserialize)]
struct AwSiteInfo {
	pub hostname: String,
	pub version: String,
	pub testing: bool,
	pub device_id: String,
}
