use std::{
	fmt::Display,
	ops::{Deref, DerefMut},
};

use diesel::{
	deserialize::{self, FromSql, FromSqlRow},
	expression::AsExpression,
	query_builder::QueryId,
	serialize::{self, Output, ToSql},
	sql_types::SqlType,
};
use time::{OffsetDateTime, PrimitiveDateTime, UtcOffset};
use uuid::Uuid;

#[cfg(feature = "sqlite")]
use diesel::sqlite::{Sqlite, SqliteValue};
#[cfg(feature = "pg")]
use diesel::{
	pg::{Pg, PgValue},
	sql_types::Jsonb,
};

#[derive(Debug, Clone, Copy, Default, QueryId, SqlType)]
#[diesel(postgres_type(oid = 2950, array_oid = 2951))]
#[diesel(sqlite_type(name = "Binary"))]
pub struct XUuid;

#[derive(Debug, AsExpression, FromSqlRow, Clone, Copy, PartialEq, Eq)]
#[diesel(sql_type = XUuid)]
pub struct XUuidVal(pub Uuid);

impl Deref for XUuidVal {
	type Target = Uuid;

	fn deref(&self) -> &Self::Target {
		&self.0
	}
}

impl DerefMut for XUuidVal {
	fn deref_mut(&mut self) -> &mut Self::Target {
		&mut self.0
	}
}

impl AsRef<Uuid> for XUuidVal {
	fn as_ref(&self) -> &Uuid {
		&self.0
	}
}

impl AsMut<Uuid> for XUuidVal {
	fn as_mut(&mut self) -> &mut Uuid {
		&mut self.0
	}
}

#[cfg(feature = "sqlite")]
impl FromSql<XUuid, Sqlite> for XUuidVal {
	fn from_sql(value: SqliteValue<'_, '_, '_>) -> deserialize::Result<Self> {
		use diesel::sql_types::Binary;
		let value = <Vec<u8> as FromSql<Binary, Sqlite>>::from_sql(value)?;
		Ok(XUuidVal(Uuid::from_slice(value.as_slice())?))
	}
}

#[cfg(feature = "sqlite")]
impl ToSql<XUuid, Sqlite> for XUuidVal {
	fn to_sql<'b>(
		&'b self,
		out: &mut Output<'b, '_, Sqlite>,
	) -> serialize::Result {
		use diesel::sql_types::Binary;
		<[u8; 16] as ToSql<Binary, Sqlite>>::to_sql(self.as_bytes(), out)
	}
}

#[cfg(feature = "pg")]
impl FromSql<XUuid, Pg> for XUuidVal {
	fn from_sql(value: PgValue<'_>) -> deserialize::Result<Self> {
		Ok(XUuidVal(Uuid::from_slice(value.as_bytes())?))
	}
}

#[cfg(feature = "pg")]
impl ToSql<XUuid, Pg> for XUuidVal {
	fn to_sql<'b>(&'b self, out: &mut Output<'b, '_, Pg>) -> serialize::Result {
		<Uuid as ToSql<diesel::sql_types::Uuid, Pg>>::to_sql(self, out)
	}
}

impl Display for XUuidVal {
	fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
		Display::fmt(&self.0, f)
	}
}

#[derive(Debug, Clone, Copy, Default, QueryId, SqlType)]
#[diesel(postgres_type(oid = 3802, array_oid = 3807))]
#[diesel(sqlite_type(name = "Text"))]
pub struct XJson;

#[derive(Debug, AsExpression, FromSqlRow, Clone, PartialEq, Eq)]
#[diesel(sql_type = XJson)]
pub struct XJsonVal(pub serde_json::Value);

impl Deref for XJsonVal {
	type Target = serde_json::Value;

	fn deref(&self) -> &Self::Target {
		&self.0
	}
}

impl DerefMut for XJsonVal {
	fn deref_mut(&mut self) -> &mut Self::Target {
		&mut self.0
	}
}

impl AsRef<serde_json::Value> for XJsonVal {
	fn as_ref(&self) -> &serde_json::Value {
		&self.0
	}
}

impl AsMut<serde_json::Value> for XJsonVal {
	fn as_mut(&mut self) -> &mut serde_json::Value {
		&mut self.0
	}
}

#[cfg(feature = "sqlite")]
impl FromSql<XJson, Sqlite> for XJsonVal {
	fn from_sql(value: SqliteValue<'_, '_, '_>) -> deserialize::Result<Self> {
		use diesel::sql_types::VarChar;
		let value = <String as FromSql<VarChar, Sqlite>>::from_sql(value)?;
		let value = serde_json::from_str(&value)?;
		Ok(XJsonVal(value))
	}
}

#[cfg(feature = "sqlite")]
impl ToSql<XJson, Sqlite> for XJsonVal {
	fn to_sql<'b>(
		&'b self,
		out: &mut Output<'b, '_, Sqlite>,
	) -> serialize::Result {
		use diesel::serialize::IsNull;
		out.set_value(serde_json::to_string(self.as_ref())?);
		Ok(IsNull::No)
	}
}

#[cfg(feature = "pg")]
impl FromSql<XJson, Pg> for XJsonVal {
	fn from_sql(value: PgValue<'_>) -> deserialize::Result<Self> {
		Ok(XJsonVal(
			<serde_json::Value as FromSql<Jsonb, Pg>>::from_sql(value)?,
		))
	}
}

#[cfg(feature = "pg")]
impl ToSql<XJson, Pg> for XJsonVal {
	fn to_sql<'b>(&'b self, out: &mut Output<'b, '_, Pg>) -> serialize::Result {
		<serde_json::Value as ToSql<Jsonb, Pg>>::to_sql(self, out)
	}
}

impl Display for XJsonVal {
	fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
		Display::fmt(&self.0, f)
	}
}

#[cfg(feature = "sqlite")]
diesel::define_sql_function! { fn unixepoch(x: diesel::sql_types::Timestamp) -> Integer; }

pub fn convert_time_to_utc(time: OffsetDateTime) -> PrimitiveDateTime {
	let time = time.to_offset(UtcOffset::UTC);
	let time = PrimitiveDateTime::new(time.date(), time.time());
	time
}
