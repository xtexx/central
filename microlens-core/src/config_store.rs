use std::collections::HashMap;

use diesel::{
	ExpressionMethods, OptionalExtension, QueryDsl, RunQueryDsl, delete,
	insert_into,
};
use kstring::KString;
use serde::{Serialize, de::DeserializeOwned};
use thiserror::Error;
use time::OffsetDateTime;

use crate::{
	Microlens,
	db::{
		schema::config_kv::dsl as kv_dsl,
		utils::{XJsonVal, convert_time_to_utc},
	},
};

pub trait ConfigStore {
	fn kv_put<V: Serialize>(&mut self, key: &str, value: V) -> Result<()>;
	fn kv_get<V: DeserializeOwned>(&mut self, key: &str) -> Result<Option<V>>;
	fn kv_dump(
		&mut self,
		prefix: Option<&str>,
	) -> Result<HashMap<KString, serde_json::Value>>;
	fn kv_delete(&mut self, key: &str) -> Result<()>;
}

impl ConfigStore for Microlens {
	fn kv_put<V: Serialize>(&mut self, key: &str, value: V) -> Result<()> {
		let time = OffsetDateTime::now_utc();
		let value = serde_json::to_value(value)?;
		insert_into(kv_dsl::config_kv)
			.values((
				kv_dsl::key.eq(key),
				kv_dsl::value.eq(XJsonVal(value.clone())),
			))
			.on_conflict(kv_dsl::key)
			.do_update()
			.set((
				kv_dsl::value.eq(XJsonVal(value)),
				kv_dsl::updated_at.eq(convert_time_to_utc(time)),
			))
			.execute(&mut self.db)?;
		Ok(())
	}

	fn kv_get<V: DeserializeOwned>(&mut self, key: &str) -> Result<Option<V>> {
		let value = kv_dsl::config_kv
			.filter(kv_dsl::key.eq(key))
			.limit(1)
			.select(kv_dsl::value)
			.get_result::<XJsonVal>(&mut self.db)
			.optional()?;
		match value {
			None => Ok(None),
			Some(XJsonVal(value)) => {
				let value = serde_json::from_value(value)?;
				Ok(Some(value))
			}
		}
	}

	fn kv_dump(
		&mut self,
		prefix: Option<&str>,
	) -> Result<HashMap<KString, serde_json::Value>> {
		let value = kv_dsl::config_kv
			.select((kv_dsl::key, kv_dsl::value))
			.get_results::<(String, XJsonVal)>(&mut self.db)?;
		let mut result = HashMap::new();
		for (key, val) in value {
			if let Some(prefix) = prefix {
				if let Some(key) = key.strip_prefix(prefix) {
					result.insert(KString::from_ref(key), val.0);
				}
			} else {
				result.insert(KString::from_string(key), val.0);
			}
		}
		Ok(result)
	}

	fn kv_delete(&mut self, key: &str) -> Result<()> {
		let result = delete(kv_dsl::config_kv)
			.filter(kv_dsl::key.eq(key))
			.execute(&mut self.db)?;
		if result == 0 {
			return Err(ConfigStoreError::KeyNotFound(key.to_string()));
		}
		Ok(())
	}
}

#[derive(Debug, Error)]
pub enum ConfigStoreError {
	#[error("database error: {0}")]
	DatabaseError(#[from] diesel::result::Error),
	#[error("JSON error: {0}")]
	JsonError(#[from] serde_json::Error),
	#[error("key not found: {0}")]
	KeyNotFound(String),
}

pub type Result<T> = std::result::Result<T, ConfigStoreError>;

#[cfg(test)]
mod test {
	use serde_json::json;

	use crate::test::test_env;

	use super::*;

	#[test]
	fn test_kv_put() {
		let mut env = test_env();
		assert_eq!(env.kv_get::<String>("aa").unwrap(), None);
		env.kv_put("aa", "test").unwrap();
		assert_eq!(env.kv_get("aa").unwrap(), Some("test".to_string()));
	}

	#[test]
	fn test_kv_get() {
		let mut env = test_env();
		assert_eq!(env.kv_get("testing").unwrap(), Some("yes".to_string()));
	}

	#[test]
	fn test_kv_dump() {
		let mut env = test_env();
		assert_eq!(
			env.kv_dump(None).unwrap(),
			HashMap::from([("testing".into(), json!("yes"))])
		);
		assert_eq!(
			env.kv_dump(Some("")).unwrap(),
			HashMap::from([("testing".into(), json!("yes"))])
		);
		assert_eq!(env.kv_dump(Some("teeee")).unwrap(), HashMap::from([]));
		assert_eq!(
			env.kv_dump(Some("t")).unwrap(),
			HashMap::from([("esting".into(), json!("yes"))])
		);
	}

	#[test]
	fn test_kv_delete() {
		let mut env = test_env();
		env.kv_delete("testing").unwrap();
		assert_eq!(env.kv_get::<()>("testing").unwrap(), None);
		env.kv_delete("testing").unwrap_err();
	}
}
