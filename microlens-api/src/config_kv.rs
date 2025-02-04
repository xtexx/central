use std::collections::HashMap;

use axum::{
	Json,
	extract::Path,
	http::StatusCode,
	response::{IntoResponse, Response},
};
use kstring::KString;
use microlens_core::config_store::ConfigStore;
use uuid::Uuid;

use crate::{ApiAuth, ApiResult, Service};

pub async fn get_all(
	ApiAuth(_): ApiAuth,
	Service(mut service): Service,
) -> ApiResult<Json<HashMap<KString, serde_json::Value>>> {
	Ok(Json(service.kv_dump(None)?))
}

pub async fn get_kv(
	ApiAuth(_): ApiAuth,
	Service(mut service): Service,
	Path((_, _, key)): Path<(Uuid, KString, KString)>,
) -> ApiResult<Response> {
	if let Some(val) = service.kv_get::<serde_json::Value>(&key)? {
		Ok(Json(val).into_response())
	} else {
		Ok((StatusCode::NOT_FOUND, "key not found").into_response())
	}
}

pub async fn put_kv(
	ApiAuth(_): ApiAuth,
	Service(mut service): Service,
	Path((_, _, key)): Path<(Uuid, KString, KString)>,
	Json(value): Json<serde_json::Value>,
) -> ApiResult<StatusCode> {
	service.kv_put(&key, value)?;
	Ok(StatusCode::CREATED)
}

pub async fn delete_kv(
	ApiAuth(_): ApiAuth,
	Service(mut service): Service,
	Path((_, _, key)): Path<(Uuid, KString, KString)>,
) -> ApiResult<StatusCode> {
	service.kv_delete(&key)?;
	Ok(StatusCode::ACCEPTED)
}
