use std::collections::HashMap;

use axum::{Json, extract::Path, http::StatusCode};
use kstring::KString;
use microlens_core::config_store::ConfigStore;
use serde_json::json;
use uuid::Uuid;

use crate::{ApiResult, Service};

const AW_KEY_PREFIX: &str = "aw:";

pub async fn get_all(
	Service(mut service): Service,
) -> ApiResult<Json<HashMap<KString, serde_json::Value>>> {
	Ok(axum::Json(service.kv_dump(Some(AW_KEY_PREFIX))?))
}

pub async fn get_kv(
	Service(mut service): Service,
	Path((_, _, key)): Path<(Uuid, KString, KString)>,
) -> ApiResult<Json<serde_json::Value>> {
	Ok(axum::Json(
		service
			.kv_get(&format!("{}{}", AW_KEY_PREFIX, key))?
			.unwrap_or_else(|| json!({})),
	))
}

pub async fn put_kv(
	Service(mut service): Service,
	Path((_, _, key)): Path<(Uuid, KString, KString)>,
	Json(value): Json<serde_json::Value>,
) -> ApiResult<StatusCode> {
	service.kv_put(&format!("{}{}", AW_KEY_PREFIX, key), value)?;
	Ok(StatusCode::CREATED)
}

pub async fn delete_kv(
	Service(mut service): Service,
	Path((_, _, key)): Path<(Uuid, KString, KString)>,
) -> ApiResult<StatusCode> {
	service.kv_delete(&format!("{}{}", AW_KEY_PREFIX, key))?;
	Ok(StatusCode::ACCEPTED)
}
