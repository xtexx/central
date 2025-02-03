use diesel::{
	Connection, SqliteConnection,
	connection::{SimpleConnection, TransactionManager},
};
use diesel_migrations::{
	EmbeddedMigrations, MigrationHarness, embed_migrations,
};
use serde::{Deserialize, Serialize};
use thiserror::Error;

pub mod bucket;
mod db;
pub mod event;

pub struct Microlens {
	db: SqliteConnection,
}

#[derive(Debug, PartialEq, Eq, Clone, Hash, Serialize, Deserialize)]
pub struct MicrolensConfig {
	database: String,
}

impl Microlens {
	pub fn from_config(config: MicrolensConfig) -> Result<Self> {
		let mut db = SqliteConnection::establish(&config.database)?;
		db.batch_execute(DATABASE_PRAGMA).unwrap();

		{
			const MIGRATIONS: EmbeddedMigrations =
				embed_migrations!("migrations");
			db.run_pending_migrations(MIGRATIONS)
				.map_err(Error::MigrationError)?;
		}

		Ok(Self { db })
	}

	pub fn db_transaction<R, E, F>(
		&mut self,
		callback: F,
	) -> std::result::Result<R, E>
	where
		F: FnOnce(&mut Self) -> std::result::Result<R, E>,
		E: From<diesel::result::Error>,
	{
		SqliteTransactionManager::begin_transaction(&mut self.db)?;

		match callback(self) {
			Ok(value) => {
				SqliteTransactionManager::commit_transaction(&mut self.db)?;
				Ok(value)
			}
			Err(user_error) => {
				let result = SqliteTransactionManager::rollback_transaction(
					&mut self.db,
				);
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
		SqliteTransactionManager::begin_transaction_sql(
			&mut self.db,
			"BEGIN EXCLUSIVE",
		)?;

		match callback(self) {
			Ok(value) => {
				SqliteTransactionManager::commit_transaction(&mut self.db)?;
				Ok(value)
			}
			Err(user_error) => {
				let result = SqliteTransactionManager::rollback_transaction(
					&mut self.db,
				);
				match result {
					Ok(())
					| Err(diesel::result::Error::BrokenTransactionManager) => Err(user_error),
					Err(rollback_error) => Err(rollback_error.into()),
				}
			}
		}
	}
}

const DATABASE_PRAGMA: &str = "PRAGMA foreign_keys = ON;";

type SqliteTransactionManager =
	<SqliteConnection as Connection>::TransactionManager;

#[derive(Debug, Error)]
pub enum Error {
	#[error("database error: {0}")]
	DatabaseError(#[from] diesel::result::Error),
	#[error("database migration failed: {0}")]
	MigrationError(Box<dyn std::error::Error + Send + Sync>),
	#[error("database connection error: {0}")]
	DatabaseConnectionError(#[from] diesel::result::ConnectionError),
}

pub type Result<T> = std::result::Result<T, Error>;

#[cfg(test)]
pub(crate) mod test {
	use diesel::{Connection, SqliteConnection, connection::SimpleConnection};
	use diesel_migrations::{
		EmbeddedMigrations, MigrationHarness, embed_migrations,
	};

	use crate::{DATABASE_PRAGMA, Microlens, MicrolensConfig};

	#[must_use]
	pub fn test_env() -> Microlens {
		let mut service = Microlens::from_config(MicrolensConfig {
			database: ":memory:".to_string(),
		})
		.unwrap();
		service
			.db
			.batch_execute(include_str!("../test/fixures.sql"))
			.unwrap();
		service
	}

	#[test]
	fn test_db_migration() {
		const MIGRATIONS: EmbeddedMigrations = embed_migrations!("migrations");

		let mut db = SqliteConnection::establish(":memory:").unwrap();
		db.batch_execute(DATABASE_PRAGMA).unwrap();
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
