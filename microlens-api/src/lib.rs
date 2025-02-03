use std::{
	convert::Infallible,
	ops::{Deref, DerefMut},
	sync::{Arc, Mutex, MutexGuard},
};

use axum::{
	Router,
	extract::{FromRef, FromRequestParts},
	http::request::Parts,
	routing::get,
};
use microlens_core::Microlens;
use ouroboros::self_referencing;

/// Re-exports of core.
pub use microlens_core as core;

mod aw;

pub fn create_router(microlens: Microlens) -> Router {
	Router::new()
		.route("/", get(handle_root))
		.nest("/aw/{token}", aw::create_router())
		.with_state(Arc::new(Mutex::new(microlens)))
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
