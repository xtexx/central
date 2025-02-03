use std::{
	convert::Infallible,
	ops::{Deref, DerefMut},
	sync::{Arc, Mutex, MutexGuard},
};

use axum::{
	Router,
	extract::{FromRef, FromRequestParts},
	http::{StatusCode, request::Parts},
	response::{IntoResponse, Response},
	routing::get,
};
use microlens_core::{
	Error, Microlens, bucket::BucketError, config_store::ConfigStoreError,
	event::EventError, token::TokenStoreError,
};
use ouroboros::self_referencing;

/// Re-exports of core.
pub use microlens_core as core;
use thiserror::Error;

mod aw;

pub fn create_router(microlens: Microlens) -> Router {
	let state = Arc::new(Mutex::new(microlens));

	Router::new()
		.route("/", get(handle_root))
		.nest("/aw/{token}/{hostname}/api/0", aw::router(state.clone()))
		.with_state(state)
}

async fn handle_root(Service(service): Service) -> String {
	format!(
		"~ MicroLens ({}) {}",
		env!("CARGO_PKG_VERSION"),
		service.config.id
	)
}

pub(crate) type ServiceState = Arc<Mutex<Microlens>>;

#[repr(transparent)]
pub(crate) struct Service(pub ServiceRef);

#[repr(transparent)]
pub(crate) struct ServiceRef(ServiceInner);

/// Internal self-referencing implementation of Service.
///
/// SAFETY: mutex and guard should not be mutated after initialization
/// and it's borrowed mutably as the service field.
#[self_referencing]
pub(crate) struct ServiceInner {
	mutex: Arc<Mutex<Microlens>>,
	#[borrows(mutex)]
	#[covariant]
	guard: MutexGuard<'this, Microlens>,
	#[borrows(guard)]
	service: &'this mut Microlens,
}

// SAFETY: We panicks when locking failed
// which is enough to avoid any deadlocks
unsafe impl Send for ServiceInner {}

impl<S> FromRequestParts<S> for Service
where
	ServiceState: FromRef<S>,
	S: Send + Sync,
{
	type Rejection = Infallible;

	async fn from_request_parts(
		_parts: &mut Parts,
		state: &S,
	) -> Result<Self, Self::Rejection> {
		let mutex = ServiceState::from_ref(state);
		Ok(Self(ServiceRef(ServiceInner::new(
			mutex,
			|mutex| mutex.try_lock().expect("lock failed"),
			|guard| unsafe {
				(guard as *const MutexGuard<'_, Microlens>)
					.cast_mut()
					.as_mut()
					.expect("never null")
			},
		))))
	}
}

impl AsRef<Microlens> for ServiceRef {
	fn as_ref(&self) -> &Microlens {
		&self.0.borrow_service()
	}
}

impl AsMut<Microlens> for ServiceRef {
	fn as_mut(&mut self) -> &mut Microlens {
		unsafe {
			(self.0.borrow_service() as *const &mut Microlens)
				.cast_mut()
				.as_mut()
				.expect("never null")
		}
	}
}

impl Deref for ServiceRef {
	type Target = Microlens;

	fn deref(&self) -> &Self::Target {
		self.as_ref()
	}
}

impl DerefMut for ServiceRef {
	fn deref_mut(&mut self) -> &mut Self::Target {
		self.as_mut()
	}
}

#[derive(Debug, Error)]
pub enum ApiError {
	#[error(transparent)]
	ServiceError(Error),
	#[error("activity-watch API authorization failed")]
	AwInvalidToken,
}

impl IntoResponse for ApiError {
	fn into_response(self) -> Response {
		let mut status = StatusCode::INTERNAL_SERVER_ERROR;

		match &self {
			ApiError::ServiceError(error) => match &error {
				Error::BucketError(error) => match &error {
					BucketError::BucketNotFound(_) => {
						status = StatusCode::NOT_FOUND
					}
					_ => {}
				},
				Error::EventError(error) => match &error {
					EventError::EventNotFound(_) => {
						status = StatusCode::NOT_FOUND
					}
					_ => {}
				},
				Error::ConfigStoreError(error) => match &error {
					ConfigStoreError::JsonError(_) => {
						status = StatusCode::BAD_REQUEST
					}
					ConfigStoreError::KeyNotFound(_) => {
						status = StatusCode::NOT_FOUND
					}
					_ => {}
				},
				Error::TokenStoreError(error) => match &error {
					TokenStoreError::TokenNotFound(_) => {
						status = StatusCode::NOT_FOUND
					}
					_ => {}
				},
				_ => {}
			},
			ApiError::AwInvalidToken => status = StatusCode::UNAUTHORIZED,
		}

		(status, self.to_string()).into_response()
	}
}

impl<T: Into<Error>> From<T> for ApiError {
	fn from(value: T) -> Self {
		Self::ServiceError(value.into())
	}
}

pub(crate) type ApiResult<T> = Result<T, ApiError>;
