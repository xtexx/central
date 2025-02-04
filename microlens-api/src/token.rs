use std::borrow::Cow;

use axum::{Json, extract::Path, http::StatusCode};
use microlens_core::token::{TokenInfo, TokenStore};
use uuid::Uuid;

use crate::{ApiResult, Service, SuApiAuth};

pub async fn list_tokens(
	SuApiAuth: SuApiAuth,
	Service(mut service): Service,
) -> ApiResult<Json<Vec<TokenInfo>>> {
	Ok(Json(service.get_all_token_info()?))
}

pub async fn create_token(
	SuApiAuth: SuApiAuth,
	Service(mut service): Service,
) -> ApiResult<(StatusCode, String)> {
	let token = service.create_token()?;
	Ok((StatusCode::CREATED, token.to_string()))
}

pub async fn get_token(
	SuApiAuth: SuApiAuth,
	Service(mut service): Service,
	Path(token): Path<Uuid>,
) -> ApiResult<Json<TokenInfo>> {
	let token = service.get_token_info(token)?;
	Ok(Json(token))
}

pub async fn delete_token(
	SuApiAuth: SuApiAuth,
	Service(mut service): Service,
	Path(token): Path<Uuid>,
) -> ApiResult<(StatusCode, Cow<'static, str>)> {
	if token == service.config.su_token {
		return Ok((
			StatusCode::NOT_ACCEPTABLE,
			"You cannot revoke the sudoer token".into(),
		));
	}

	service.revoke_token(token)?;
	Ok((
		StatusCode::ACCEPTED,
		format!("token {} has been revoked", token).into(),
	))
}
