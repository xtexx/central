use axum::{
	Json, Router,
	extract::{FromRequestParts, RawPathParams, Request},
	middleware::{self, Next},
	response::{IntoResponse, Response},
	routing::get,
};
use microlens_core::token::{TokenStore, TokenStoreError};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::{ApiError, Service, ServiceState};

mod buckets;
mod settings;

pub fn router(state: ServiceState) -> Router<ServiceState> {
	Router::new()
		.layer(middleware::from_fn_with_state(state, aw_auth))
		.route("/info", get(handle_root))
		.nest(
			"/buckets",
			Router::new()
				.route("/", get(buckets::list_buckets))
				.route(
					"/{bucket}",
					get(buckets::get_bucket)
						.post(buckets::create_bucket)
						.delete(buckets::delete_bucket),
				)
				.route(
					"/{bucket}/events",
					get(buckets::get_events).post(buckets::create_events),
				)
				.route("/{bucket}/heartbeat", get(buckets::heartbeat)),
		)
		.nest(
			"/settings",
			Router::new().route("/", get(settings::get_all)).route(
				"/{key}",
				get(settings::get_kv)
					.post(settings::put_kv)
					.delete(settings::delete_kv),
			),
		)
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

async fn aw_auth(
	Service(mut service): Service,
	request: Request,
	next: Next,
) -> Response {
	let (mut parts, body) = request.into_parts();
	let params = RawPathParams::from_request_parts(&mut parts, &())
		.await
		.unwrap();

	let mut authed = false;
	for (k, v) in params.iter() {
		if k == "token" {
			let token = Uuid::try_parse(v);
			match token {
				Ok(token) => {
					let result = service.touch_token(token);
					if let Err(error) = result {
						match error {
							TokenStoreError::DatabaseError(error) => {
								return ApiError::ServiceError(error.into())
									.into_response();
							}
							TokenStoreError::TokenNotFound(_) => {
								return ApiError::AwInvalidToken
									.into_response();
							}
						}
					}
				}
				Err(_) => return ApiError::AwInvalidToken.into_response(),
			}
			authed = true;
			break;
		}
	}
	assert!(authed);

	drop(service);
	next.run(Request::from_parts(parts, body)).await
}
