use bucket::BucketError;
use config_store::ConfigStoreError;
use diesel::{Connection, connection::TransactionManager};
use diesel_migrations::{
	EmbeddedMigrations, MigrationHarness, embed_migrations,
};
use event::EventError;
use serde::{Deserialize, Serialize};
use thiserror::Error;
use token::{Token, TokenStoreError};
use uuid::Uuid;

pub mod bucket;
pub mod config_store;
mod db;
pub mod event;
pub mod token;

#[cfg(all(feature = "sqlite", feature = "pg"))]
compile_error!("multiple database backend has been enabled at the same time");

#[cfg(feature = "sqlite")]
pub(crate) type SqlConnection = diesel::SqliteConnection;
#[cfg(feature = "pg")]
pub(crate) type SqlConnection = diesel::PgConnection;

pub(crate) type SqlBackend = <SqlConnection as Connection>::Backend;
pub(crate) type SqlTransactionManager =
	<SqlConnection as Connection>::TransactionManager;

pub struct Microlens {
	pub config: MicrolensConfig,
	db: SqlConnection,
}

#[derive(Debug, PartialEq, Eq, Clone, Hash, Serialize, Deserialize)]
pub struct MicrolensConfig {
	pub id: Uuid,
	pub hostname: String,
	pub database: String,
	pub su_token: Token,
}

impl Microlens {
	pub fn from_config(config: MicrolensConfig) -> Result<Self> {
		let mut db = SqlConnection::establish(&config.database)?;

		#[cfg(feature = "sqlite")]
		use diesel::connection::SimpleConnection;
		#[cfg(feature = "sqlite")]
		db.batch_execute(DATABASE_PRAGMA).unwrap();

		{
			#[cfg(feature = "sqlite")]
			const MIGRATIONS: EmbeddedMigrations =
				embed_migrations!("migrations/sqlite");
			#[cfg(feature = "pg")]
			const MIGRATIONS: EmbeddedMigrations =
				embed_migrations!("migrations/postgresql");
			db.run_pending_migrations(MIGRATIONS)
				.map_err(Error::MigrationError)?;
		}

		Ok(Self { config, db })
	}

	pub fn db_transaction<R, E, F>(
		&mut self,
		callback: F,
	) -> std::result::Result<R, E>
	where
		F: FnOnce(&mut Self) -> std::result::Result<R, E>,
		E: From<diesel::result::Error>,
	{
		SqlTransactionManager::begin_transaction(&mut self.db)?;

		match callback(self) {
			Ok(value) => {
				SqlTransactionManager::commit_transaction(&mut self.db)?;
				Ok(value)
			}
			Err(user_error) => {
				let result =
					SqlTransactionManager::rollback_transaction(&mut self.db);
				match result {
					Ok(())
					| Err(diesel::result::Error::BrokenTransactionManager) => Err(user_error),
					Err(rollback_error) => Err(rollback_error.into()),
				}
			}
		}
	}

	pub fn db_transaction_exclusive<R, E, F>(
		&mut self,
		callback: F,
	) -> std::result::Result<R, E>
	where
		F: FnOnce(&mut Self) -> std::result::Result<R, E>,
		E: From<diesel::result::Error>,
	{
		#[cfg(feature = "sqlite")]
		SqlTransactionManager::begin_transaction_sql(
			&mut self.db,
			"BEGIN EXCLUSIVE",
		)?;
		#[cfg(feature = "pg")]
		SqlTransactionManager::begin_transaction(&mut self.db)?;

		match callback(self) {
			Ok(value) => {
				SqlTransactionManager::commit_transaction(&mut self.db)?;
				Ok(value)
			}
			Err(user_error) => {
				let result =
					SqlTransactionManager::rollback_transaction(&mut self.db);
				match result {
					Ok(())
					| Err(diesel::result::Error::BrokenTransactionManager) => Err(user_error),
					Err(rollback_error) => Err(rollback_error.into()),
				}
			}
		}
	}
}

#[cfg(feature = "sqlite")]
const DATABASE_PRAGMA: &str = "PRAGMA foreign_keys = ON;";

#[derive(Debug, Error)]
pub enum Error {
	#[error("database error: {0}")]
	DatabaseError(#[from] diesel::result::Error),
	#[error("database migration failed: {0}")]
	MigrationError(Box<dyn std::error::Error + Send + Sync>),
	#[error("database connection error: {0}")]
	DatabaseConnectionError(#[from] diesel::result::ConnectionError),

	#[error(transparent)]
	BucketError(#[from] BucketError),
	#[error(transparent)]
	EventError(#[from] EventError),
	#[error(transparent)]
	ConfigStoreError(#[from] ConfigStoreError),
	#[error(transparent)]
	TokenStoreError(#[from] TokenStoreError),
}

pub type Result<T> = std::result::Result<T, Error>;

#[cfg(test)]
pub(crate) mod test {
	use diesel::connection::SimpleConnection;
	use uuid::uuid;

	use crate::{Microlens, MicrolensConfig};

	#[must_use]
	pub fn test_env() -> Microlens {
		assert!(
			cfg!(feature = "sqlite"),
			"running tests with PG are not supported"
		);
		let mut service = Microlens::from_config(MicrolensConfig {
			id: uuid!("12f9792f-aedf-41ab-a027-308e6d4a1727"),
			hostname: "Test".to_string(),
			database: ":memory:".to_string(),
			su_token: uuid!("b5858974-db59-4440-8b2f-28aa734f8104"),
		})
		.unwrap();
		service
			.db
			.batch_execute(include_str!("../test/fixures.sql"))
			.unwrap();
		service
	}

	#[test]
	#[cfg(feature = "sqlite")]
	fn test_db_migration() {
		use diesel::{Connection, SqliteConnection};
		use diesel_migrations::{
			EmbeddedMigrations, MigrationHarness, embed_migrations,
		};

		const MIGRATIONS: EmbeddedMigrations =
			embed_migrations!("migrations/sqlite");

		let mut db = SqliteConnection::establish(":memory:").unwrap();
		db.batch_execute(super::DATABASE_PRAGMA).unwrap();
		db.run_pending_migrations(MIGRATIONS).unwrap();
		db.batch_execute("PRAGMA integrity_check;").unwrap();
		db.batch_execute("PRAGMA foreign_key_check;").unwrap();
		db.batch_execute(include_str!("../test/fixures.sql"))
			.unwrap();
		db.revert_all_migrations(MIGRATIONS).unwrap();
	}

	#[test]
	fn test_init() {
		let _ = test_env();
	}
}
