use diesel::{
	BoolExpressionMethods, BoxableExpression, ExpressionMethods,
	OptionalExtension, QueryDsl, Queryable, RunQueryDsl, Selectable,
	SelectableHelper, delete, insert_into, sql_types::Bool, update,
};
use kstring::KString;
use serde::{Deserialize, Serialize};
use time::{OffsetDateTime, PrimitiveDateTime};

use crate::{
	Error, Microlens, SqlBackend,
	db::{
		schema::{self, bucket::dsl},
		utils::{XJsonVal, XUuidVal, convert_time_to_utc},
	},
	event::EventRef,
};

pub type BucketRef = i32;
pub type LocalBucketName = KString;
pub type HostRef = KString;
pub type GlobalBucketName = (HostRef, LocalBucketName);

pub trait BucketAccess {
	fn create_bucket(
		&mut self,
		id: GlobalBucketName,
		kind: &str,
		client: &str,
	) -> Result<BucketRef>;
	fn delete_bucket(&mut self, bucket: BucketSelector) -> Result<()>;
	fn resolve_bucket(&mut self, bucket: BucketSelector) -> Result<BucketRef>;
	fn get_bucket(&mut self, bucket: BucketSelector) -> Result<Bucket>;
	fn get_buckets(&mut self) -> Result<Vec<Bucket>>;
	fn get_buckets_of_kind(&mut self, kind: &str) -> Result<Vec<Bucket>>;

	fn set_bucket_last_event(
		&mut self,
		bucket: BucketSelector,
		event: EventRef,
	) -> Result<()>;
	fn get_bucket_last_event(
		&mut self,
		bucket: BucketSelector,
	) -> Result<Option<EventRef>>;
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Bucket {
	pub id: BucketRef,
	pub name: GlobalBucketName,
	pub kind: KString,
	pub client: KString,
	pub data: serde_json::Value,
	pub created_at: OffsetDateTime,
	pub updated_at: OffsetDateTime,
	pub last_event_id: Option<EventRef>,
}

/// Selector of a **single** bucket.
#[derive(Debug, PartialEq, Eq, Clone, Hash)]
pub enum BucketSelector {
	Id(BucketRef),
	Name(GlobalBucketName),
}

impl From<BucketRef> for BucketSelector {
	fn from(value: BucketRef) -> Self {
		Self::Id(value)
	}
}

impl From<GlobalBucketName> for BucketSelector {
	fn from(value: GlobalBucketName) -> Self {
		Self::Name(value)
	}
}

#[derive(Debug, Error)]
pub enum BucketError {
	#[error("database error: {0}")]
	DatabaseError(#[from] diesel::result::Error),

	#[error("bucket not found: {0:?}")]
	BucketNotFound(BucketSelector),
}

pub type Result<T> = std::result::Result<T, BucketError>;

impl BucketAccess for Microlens {
	fn create_bucket(
		&mut self,
		id: GlobalBucketName,
		kind: &str,
		client: &str,
	) -> Result<BucketRef> {
		let (hostname, bucket_name) = id;

		let id = insert_into(dsl::bucket)
			.values((
				dsl::id.eq(bucket_name.as_str()),
				dsl::hostname.eq(hostname.as_str()),
				dsl::kind.eq(kind),
				dsl::client.eq(client),
			))
			.returning(dsl::bid)
			.get_result::<i32>(&mut self.db)?;
		Ok(id)
	}

	fn delete_bucket(&mut self, bucket: BucketSelector) -> Result<()> {
		let result = delete(dsl::bucket)
			.filter(bucket.make_filter())
			.execute(&mut self.db)?;
		if result == 0 {
			return Err(BucketError::BucketNotFound(bucket));
		}
		Ok(())
	}

	fn resolve_bucket(&mut self, bucket: BucketSelector) -> Result<BucketRef> {
		let data: BucketRef = dsl::bucket
			.filter(bucket.make_filter())
			.limit(1)
			.select(dsl::bid)
			.get_result(&mut self.db)
			.optional()?
			.ok_or_else(|| BucketError::BucketNotFound(bucket))?;
		Ok(data.into())
	}

	fn get_bucket(&mut self, bucket: BucketSelector) -> Result<Bucket> {
		let data: SqlBucket = dsl::bucket
			.filter(bucket.make_filter())
			.limit(1)
			.select(SqlBucket::as_select())
			.get_result(&mut self.db)
			.optional()?
			.ok_or_else(|| BucketError::BucketNotFound(bucket))?;
		Ok(data.into())
	}

	fn get_buckets(&mut self) -> Result<Vec<Bucket>> {
		let data: Vec<Bucket> = dsl::bucket
			.select(SqlBucket::as_select())
			.get_results(&mut self.db)?
			.into_iter()
			.map(Bucket::from)
			.collect();
		Ok(data)
	}

	fn get_buckets_of_kind(&mut self, kind: &str) -> Result<Vec<Bucket>> {
		let data: Vec<Bucket> = dsl::bucket
			.filter(dsl::kind.eq(kind))
			.select(SqlBucket::as_select())
			.get_results(&mut self.db)?
			.into_iter()
			.map(Bucket::from)
			.collect();
		Ok(data)
	}

	fn set_bucket_last_event(
		&mut self,
		bucket: BucketSelector,
		event: EventRef,
	) -> Result<()> {
		let time = convert_time_to_utc(OffsetDateTime::now_utc());
		let result = update(dsl::bucket)
			.filter(bucket.make_filter())
			.set((
				dsl::updated_at.eq(time),
				dsl::last_event.eq(Some(XUuidVal(event))),
			))
			.execute(&mut self.db)?;
		if result == 0 {
			return Err(BucketError::BucketNotFound(bucket));
		}
		Ok(())
	}

	fn get_bucket_last_event(
		&mut self,
		bucket: BucketSelector,
	) -> Result<Option<EventRef>> {
		Ok(dsl::bucket
			.filter(bucket.make_filter())
			.limit(1)
			.select(dsl::last_event)
			.get_result::<Option<XUuidVal>>(&mut self.db)
			.optional()?
			.ok_or_else(|| BucketError::BucketNotFound(bucket))?
			.map(|val| val.0))
	}
}

#[derive(Debug, Queryable, Selectable)]
#[diesel(table_name = schema::bucket)]
#[diesel(check_for_backend(SqlBackend))]
struct SqlBucket {
	bid: i32,
	hostname: String,
	id: String,
	kind: String,
	client: String,
	data: XJsonVal,
	created_at: PrimitiveDateTime,
	updated_at: PrimitiveDateTime,
	last_event: Option<XUuidVal>,
}

impl From<SqlBucket> for Bucket {
	fn from(value: SqlBucket) -> Self {
		Bucket {
			id: value.bid,
			name: (
				KString::from_string(value.hostname),
				KString::from_string(value.id),
			),
			kind: KString::from_string(value.kind),
			client: KString::from_string(value.client),
			data: value.data.0,
			created_at: value.created_at.assume_utc(),
			updated_at: value.updated_at.assume_utc(),
			last_event_id: value.last_event.map(|id| id.0),
		}
	}
}

impl BucketSelector {
	pub fn make_filter(
		&self,
	) -> Box<dyn BoxableExpression<dsl::bucket, SqlBackend, SqlType = Bool> + '_>
	{
		match self {
			BucketSelector::Id(id) => Box::new(dsl::bid.eq(*id)),
			BucketSelector::Name((hostname, name)) => Box::new(
				dsl::hostname
					.eq(hostname.as_str())
					.and(dsl::id.eq(name.as_str())),
			),
		}
	}
}

#[cfg(test)]
mod test {
	use uuid::uuid;

	use crate::test::test_env;

	use super::BucketAccess;

	#[test]
	fn test_create_bucket() {
		let mut env = test_env();
		let id = env
			.create_bucket(
				("testhost".into(), "test".into()),
				"testkind".into(),
				"testclient".into(),
			)
			.unwrap();
		let bucket = env.get_bucket(id.into()).unwrap();
		assert_eq!(bucket.id, 2);
		assert_eq!(bucket.name.0, "testhost");
		assert_eq!(bucket.name.1, "test");
		assert_eq!(bucket.kind, "testkind");
		assert_eq!(bucket.client, "testclient");
	}

	#[test]
	fn test_delete_bucket() {
		let mut env = test_env();
		assert!(env.get_bucket(1.into()).is_ok());
		env.delete_bucket(1.into()).unwrap();
		assert!(env.get_bucket(1.into()).is_err());
	}

	#[test]
	fn test_resolve_bucket() {
		let mut env = test_env();
		assert_eq!(env.resolve_bucket(1.into()).unwrap(), 1);
	}

	#[test]
	fn test_get_bucket() {
		let mut env = test_env();
		let bucket = env.get_bucket(1.into()).unwrap();
		assert_eq!(bucket.id, 1);
		assert_eq!(bucket.name.0, "localhost");
		assert_eq!(bucket.name.1, "test1");
		assert_eq!(bucket.kind, "test1");
		assert_eq!(bucket.client, "fixures");
		assert_eq!(
			bucket.last_event_id,
			Some(uuid!("0965324bfb9c45faaa3d051999530903"))
		);
	}

	#[test]
	fn test_get_buckets() {
		let mut env = test_env();
		let bucket = env.get_buckets().unwrap();
		assert_eq!(bucket.len(), 1);
		assert_eq!(bucket[0].id, 1);
	}
}
