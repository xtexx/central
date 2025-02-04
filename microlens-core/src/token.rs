use diesel::{
	ExpressionMethods, Insertable, OptionalExtension, QueryDsl, Queryable,
	RunQueryDsl, Selectable, SelectableHelper, delete, insert_into, update,
};
use serde::{Deserialize, Serialize};
use thiserror::Error;
use time::{OffsetDateTime, PrimitiveDateTime};
use uuid::Uuid;

use crate::{
	Microlens, SqlBackend,
	db::{
		schema::{self, token::dsl},
		utils::{NowUtc, XUuidVal, convert_time_to_utc},
	},
};

pub type Token = Uuid;

pub trait TokenStore {
	fn touch_token(&mut self, token: Token) -> Result<()>;
	fn get_all_token_info(&mut self) -> Result<Vec<TokenInfo>>;
	fn get_token_info(&mut self, token: Token) -> Result<TokenInfo>;
	fn revoke_token(&mut self, token: Token) -> Result<()>;
	fn create_token(&mut self) -> Result<Token>;
}

#[derive(Debug, PartialEq, Eq, Clone, Hash, Serialize, Deserialize)]
pub struct TokenInfo {
	pub token: Token,
	pub name: String,
	pub created_at: OffsetDateTime,
	pub used_at: OffsetDateTime,
}

impl TokenStore for Microlens {
	fn touch_token(&mut self, token: Token) -> Result<()> {
		if token == self.config.su_token {
			return Ok(());
		}
		let result = update(dsl::token)
			.filter(dsl::id.eq(XUuidVal(token)))
			.set(dsl::used_at.eq(NowUtc))
			.execute(&mut self.db)?;
		if result == 0 {
			return Err(TokenStoreError::TokenNotFound(token));
		}
		Ok(())
	}

	fn get_all_token_info(&mut self) -> Result<Vec<TokenInfo>> {
		let result = dsl::token
			.select(SqlTokenInfo::as_select())
			.get_results(&mut self.db)?
			.into_iter()
			.map(TokenInfo::from)
			.collect();
		Ok(result)
	}

	fn get_token_info(&mut self, token: Token) -> Result<TokenInfo> {
		let result = dsl::token
			.filter(dsl::id.eq(XUuidVal(token)))
			.limit(1)
			.select(SqlTokenInfo::as_select())
			.get_result(&mut self.db)
			.optional()?
			.ok_or_else(|| TokenStoreError::TokenNotFound(token))?;
		Ok(result.into())
	}

	fn revoke_token(&mut self, token: Token) -> Result<()> {
		let result = delete(dsl::token)
			.filter(dsl::id.eq(XUuidVal(token)))
			.execute(&mut self.db)?;
		if result == 0 {
			return Err(TokenStoreError::TokenNotFound(token));
		}
		Ok(())
	}

	fn create_token(&mut self) -> Result<Token> {
		let token = Uuid::new_v4();
		insert_into(dsl::token)
			.values(dsl::id.eq(XUuidVal(token)))
			.execute(&mut self.db)?;
		Ok(token)
	}
}

#[derive(Debug, Insertable, Queryable, Selectable)]
#[diesel(table_name = schema::token)]
#[diesel(check_for_backend(SqlBackend))]
pub struct SqlTokenInfo {
	pub id: XUuidVal,
	pub name: String,
	pub created_at: PrimitiveDateTime,
	pub used_at: PrimitiveDateTime,
}

impl From<TokenInfo> for SqlTokenInfo {
	fn from(value: TokenInfo) -> Self {
		Self {
			id: XUuidVal(value.token),
			name: value.name,
			created_at: convert_time_to_utc(value.created_at),
			used_at: convert_time_to_utc(value.used_at),
		}
	}
}

impl From<SqlTokenInfo> for TokenInfo {
	fn from(value: SqlTokenInfo) -> Self {
		Self {
			token: value.id.0,
			name: value.name,
			created_at: value.created_at.assume_utc(),
			used_at: value.used_at.assume_utc(),
		}
	}
}

#[derive(Debug, Error)]
pub enum TokenStoreError {
	#[error("database error: {0}")]
	DatabaseError(#[from] diesel::result::Error),

	#[error("token not found: {0}")]
	TokenNotFound(Token),
}

pub type Result<T> = std::result::Result<T, TokenStoreError>;

#[cfg(test)]
mod test {
	use time::{Date, Month, Time};
	use uuid::uuid;

	use crate::test::test_env;

	use super::*;

	#[test]
	fn test_token_touch() {
		let mut env = test_env();
		let token = env
			.get_token_info(uuid!("0976cdf0b68641fa933b7909ff0131c6"))
			.unwrap();
		let t1 = OffsetDateTime::new_utc(
			Date::from_calendar_date(2025, Month::February, 3).unwrap(),
			Time::from_hms(02, 55, 54).unwrap(),
		);
		assert_eq!(token.used_at, t1);

		env.touch_token(uuid!("0976cdf0b68641fa933b7909ff0131c6"))
			.unwrap();

		let token = env
			.get_token_info(uuid!("0976cdf0b68641fa933b7909ff0131c6"))
			.unwrap();
		assert_ne!(token.used_at, t1);

		env.touch_token(uuid!("0976cdf0b68641fa933b7909ff0131c7"))
			.unwrap_err();
		env.touch_token(uuid!("b5858974-db59-4440-8b2f-28aa734f8104"))
			.unwrap();
	}

	#[test]
	fn test_token_get() {
		let mut env = test_env();
		let token = env
			.get_token_info(uuid!("0976cdf0b68641fa933b7909ff0131c6"))
			.unwrap();
		assert_eq!(token.token, uuid!("0976cdf0b68641fa933b7909ff0131c6"));
		assert_eq!(token.name, "fixures");
	}

	#[test]
	fn test_token_revoke() {
		let mut env = test_env();
		let token = uuid!("0976cdf0b68641fa933b7909ff0131c6");
		_ = env.get_token_info(token).unwrap();
		env.revoke_token(token).unwrap();
		_ = env.get_token_info(token).unwrap_err();
	}

	#[test]
	fn test_token_create() {
		let mut env = test_env();
		let token = env.create_token().unwrap();
		_ = env.get_token_info(token).unwrap();
	}
}
