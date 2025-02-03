use diesel::{
	ExpressionMethods, OptionalExtension, QueryDsl, RunQueryDsl, insert_into,
};
use thiserror::Error;
use time::OffsetDateTime;

use crate::{
	Microlens,
	db::{schema::config_kv::dsl as kv_dsl, utils::convert_time_to_utc},
};

pub trait ConfigStore {
	fn kv_put(&mut self, key: &str, value: &str) -> Result<()>;
	fn kv_get(&mut self, key: &str) -> Result<Option<String>>;
}

impl ConfigStore for Microlens {
	fn kv_put(&mut self, key: &str, value: &str) -> Result<()> {
		let time = OffsetDateTime::now_utc();
		insert_into(kv_dsl::config_kv)
			.values((kv_dsl::key.eq(key), kv_dsl::value.eq(value)))
			.on_conflict(kv_dsl::key)
			.do_update()
			.set((
				kv_dsl::value.eq(value),
				kv_dsl::updated_at.eq(convert_time_to_utc(time)),
			))
			.execute(&mut self.db)?;
		Ok(())
	}

	fn kv_get(&mut self, key: &str) -> Result<Option<String>> {
		let value = kv_dsl::config_kv
			.filter(kv_dsl::key.eq(key))
			.limit(1)
			.select(kv_dsl::value)
			.get_result::<String>(&mut self.db)
			.optional()?;
		Ok(value)
	}
}

#[derive(Debug, Error)]
pub enum ConfigStoreError {
	#[error("database error: {0}")]
	DatabaseError(#[from] diesel::result::Error),
}

pub type Result<T> = std::result::Result<T, ConfigStoreError>;

#[cfg(test)]
mod test {
	use crate::test::test_env;

	use super::*;

	#[test]
	fn test_kv_put() {
		let mut env = test_env();
		assert_eq!(env.kv_get("aa").unwrap(), None);
		env.kv_put("aa", "test").unwrap();
		assert_eq!(env.kv_get("aa").unwrap(), Some("test".to_string()));
	}

	#[test]
	fn test_kv_get() {
		let mut env = test_env();
		assert_eq!(env.kv_get("testing").unwrap(), Some("yes".to_string()));
	}
}
