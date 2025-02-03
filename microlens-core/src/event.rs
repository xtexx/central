use std::num::TryFromIntError;

use diesel::{
	BoolExpressionMethods, BoxableExpression, ExpressionMethods, Insertable,
	OptionalExtension, QueryDsl, Queryable, RunQueryDsl, Selectable,
	SelectableHelper, connection::DefaultLoadingMode, delete, insert_into,
	sql_types::Bool, update,
};
use serde::{Deserialize, Serialize};
use thiserror::Error;
use time::{Duration, OffsetDateTime, PrimitiveDateTime};
use uuid::Uuid;

use crate::{
	Microlens, SqlBackend,
	bucket::BucketRef,
	db::{
		schema::{self, bucket::dsl as bucket_dsl, event::dsl},
		utils::{XJsonVal, XUuidVal, convert_time_to_utc},
	},
};

pub type EventRef = Uuid;

pub trait EventAccess {
	fn add_event(&mut self, event: Event) -> Result<()>;
	fn record(&mut self, event: Event, pulse: Duration) -> Result<()>;
	fn get_event(&mut self, filter: &EventFilter) -> Result<Event>;
	fn get_events<'a>(
		&'a mut self,
		filter: &'a EventFilter,
	) -> Result<impl Iterator<Item = Result<Event>> + 'a>;
	fn delete_events(&mut self, filter: &EventFilter) -> Result<()>;
}

#[derive(Debug, PartialEq, Eq, Clone, Hash, Serialize, Deserialize)]
pub struct Event {
	/// Event UUID
	///
	/// Must be a valid UUID v7, whose timestamp is the event insertion time.
	pub id: EventRef,
	pub bucket: BucketRef,
	pub started_at: OffsetDateTime,
	pub ended_at: OffsetDateTime,
	pub data: serde_json::Value,
}

impl Event {
	pub(crate) fn merge(
		mut self,
		next: &Event,
		pulse: &Duration,
	) -> std::result::Result<Self, Self> {
		if self.bucket != next.bucket || self.data != next.data {
			return Err(self);
		}
		if self.started_at > self.ended_at
			|| next.started_at > next.ended_at
			|| self.ended_at > next.started_at
		{
			return Err(self);
		}
		if next.started_at - self.ended_at > *pulse {
			// return Err(self);
		}
		self.ended_at = next.ended_at;
		Ok(self)
	}
}

#[derive(
	Debug, PartialEq, Eq, Clone, Hash, Serialize, Deserialize, Default,
)]
pub struct EventFilter {
	pub id: Option<EventRef>,
	pub bucket: Option<BucketRef>,
	pub started_before: Option<OffsetDateTime>,
	pub started_after: Option<OffsetDateTime>,
	pub ended_before: Option<OffsetDateTime>,
	pub ended_after: Option<OffsetDateTime>,
}

impl From<EventRef> for EventFilter {
	fn from(value: EventRef) -> Self {
		Self {
			id: Some(value),
			..Default::default()
		}
	}
}

#[derive(Debug, Insertable, Queryable, Selectable)]
#[diesel(table_name = schema::event)]
#[diesel(check_for_backend(SqlBackend))]
struct SqlEvent {
	pub id: XUuidVal,
	pub bucket: BucketRef,
	pub started_at: PrimitiveDateTime,
	pub ended_at: PrimitiveDateTime,
	pub data: XJsonVal,
}

impl From<Event> for SqlEvent {
	fn from(value: Event) -> Self {
		Self {
			id: XUuidVal(value.id),
			bucket: value.bucket,
			started_at: convert_time_to_utc(value.started_at),
			ended_at: convert_time_to_utc(value.ended_at),
			data: XJsonVal(value.data),
		}
	}
}

impl From<SqlEvent> for Event {
	fn from(value: SqlEvent) -> Self {
		Self {
			id: value.id.0,
			bucket: value.bucket,
			started_at: value.started_at.assume_utc(),
			ended_at: value.ended_at.assume_utc(),
			data: value.data.0,
		}
	}
}

impl EventAccess for Microlens {
	fn add_event(&mut self, event: Event) -> Result<()> {
		insert_into(dsl::event)
			.values(SqlEvent::from(event))
			.execute(&mut self.db)?;
		Ok(())
	}

	fn record(&mut self, event: Event, pulse: Duration) -> Result<()> {
		self.db_transaction_exclusive(|service| {
			#[cfg(feature = "sqlite")]
			use crate::db::utils::unixepoch;
			#[cfg(feature = "sqlite")]
			let filter = (bucket_dsl::bid.eq(event.bucket))
				.and(dsl::bucket.eq(event.bucket))
				.and(
					(unixepoch(dsl::ended_at)
						+ TryInto::<i32>::try_into(pulse.whole_seconds())
							.map_err(EventError::PulseDurationOverflow)?)
					.ge(unixepoch(convert_time_to_utc(event.started_at))),
				);
			#[cfg(feature = "pg")]
			let filter = (bucket_dsl::bid.eq(event.bucket))
				.and(dsl::bucket.eq(event.bucket));
			let last_event: Option<SqlEvent> = bucket_dsl::bucket
				.inner_join(dsl::event)
				.filter(filter)
				.select(SqlEvent::as_select())
				.first(&mut service.db)
				.optional()?;

			if let Some(last_event) = last_event {
				// attempt to merge events
				let last_event = Event::from(last_event);
				if let Ok(event) = last_event.merge(&event, &pulse) {
					// merge succeeded
					let event = SqlEvent::from(event);
					let result = update(dsl::event)
						.filter(dsl::id.eq(event.id))
						.set((dsl::ended_at.eq(event.ended_at),))
						.execute(&mut service.db)?;
					if result == 1 {
						return Ok(());
					}
				}
			}

			service.add_event(event)
		})
	}

	fn get_event(&mut self, filter: &EventFilter) -> Result<Event> {
		Ok(dsl::event
			.filter(filter.make_filter())
			.select(SqlEvent::as_select())
			.first(&mut self.db)?
			.into())
	}

	/// If no events are selected, a empty iterator will be returned.
	///
	/// Results are ordered by insertion time descending.
	fn get_events<'a>(
		&'a mut self,
		filter: &'a EventFilter,
	) -> Result<impl Iterator<Item = Result<Event>> + 'a> {
		Ok(dsl::event
			.filter(filter.make_filter())
			.select(SqlEvent::as_select())
			.order(dsl::id.desc())
			.load_iter::<SqlEvent, DefaultLoadingMode>(&mut self.db)?
			.map(|event| {
				event.map(|event| event.into()).map_err(|err| err.into())
			}))
	}

	fn delete_events(&mut self, filter: &EventFilter) -> Result<()> {
		let result = delete(dsl::event)
			.filter(filter.make_filter())
			.execute(&mut self.db)?;
		if result == 0 {
			return Err(EventError::EventNotFound(filter.to_owned()));
		}
		Ok(())
	}
}

impl EventFilter {
	pub fn make_filter(
		&self,
	) -> Box<dyn BoxableExpression<dsl::event, SqlBackend, SqlType = Bool> + '_>
	{
		#[cfg(feature = "sqlite")]
		use crate::db::utils::unixepoch;

		// `bucket IS NOT NULL` never fails
		// We are using it as a alternative to `TRUE` as diesel does not support TRUE
		let mut expr = Box::new(dsl::bucket.is_not_null())
			as Box<
				dyn BoxableExpression<dsl::event, SqlBackend, SqlType = Bool>
					+ '_,
			>;

		if let Some(id) = self.id {
			expr = Box::new(expr.and(dsl::id.eq(XUuidVal(id))));
		}
		if let Some(bucket) = self.bucket {
			expr = Box::new(expr.and(dsl::bucket.eq(bucket)));
		}
		if let Some(time) = self.started_before {
			let time = convert_time_to_utc(time);
			#[cfg(feature = "sqlite")]
			{
				expr = Box::new(
					expr.and(unixepoch(dsl::started_at).le(unixepoch(time))),
				);
			}
			#[cfg(feature = "pg")]
			{
				expr = Box::new(expr.and(dsl::started_at.le(time)));
			}
		}
		if let Some(time) = self.started_after {
			let time = convert_time_to_utc(time);
			#[cfg(feature = "sqlite")]
			{
				expr = Box::new(
					expr.and(unixepoch(dsl::started_at).ge(unixepoch(time))),
				);
			}
			#[cfg(feature = "pg")]
			{
				expr = Box::new(expr.and(dsl::started_at.ge(time)));
			}
		}
		if let Some(time) = self.ended_before {
			let time = convert_time_to_utc(time);
			#[cfg(feature = "sqlite")]
			{
				expr = Box::new(
					expr.and(unixepoch(dsl::ended_at).le(unixepoch(time))),
				);
			}
			#[cfg(feature = "pg")]
			{
				expr = Box::new(expr.and(dsl::ended_at.le(time)));
			}
		}
		if let Some(time) = self.ended_after {
			let time = convert_time_to_utc(time);
			#[cfg(feature = "sqlite")]
			{
				expr = Box::new(
					expr.and(unixepoch(dsl::ended_at).ge(unixepoch(time))),
				);
			}
			#[cfg(feature = "pg")]
			{
				expr = Box::new(expr.and(dsl::ended_at.ge(time)));
			}
		}

		expr
	}
}

#[derive(Debug, Error)]
pub enum EventError {
	#[error("database error: {0}")]
	DatabaseError(#[from] diesel::result::Error),

	#[error("event not found: {0:?}")]
	EventNotFound(EventFilter),

	#[error("pulse duration overflow: {0:?}")]
	PulseDurationOverflow(TryFromIntError),
}

pub type Result<T> = std::result::Result<T, EventError>;

#[cfg(test)]
mod test {
	use serde_json::json;
	use time::{Date, Month, Time};
	use uuid::uuid;

	use crate::test::test_env;

	use super::*;

	#[test]
	fn test_add_event() {
		let mut env = test_env();
		let id = Uuid::now_v7();
		let t1 = OffsetDateTime::now_utc();
		env.add_event(Event {
			id,
			bucket: 1,
			started_at: t1,
			ended_at: t1 + Duration::minutes(10),
			data: json!({}),
		})
		.unwrap();
		_ = env.get_event(&id.into()).unwrap();
	}

	#[test]
	fn test_record_event() {
		let mut env = test_env();

		let count = env.get_events(&Default::default()).unwrap().count();
		assert_eq!(count, 2);

		// test not merged
		let id = Uuid::now_v7();
		let t1 = OffsetDateTime::now_utc();
		env.record(
			Event {
				id,
				bucket: 1,
				started_at: t1,
				ended_at: t1 + Duration::minutes(10),
				data: json!({}),
			},
			Duration::seconds(120),
		)
		.unwrap();
		_ = env.get_event(&id.into()).unwrap();

		// test merged
		let id = Uuid::now_v7();
		let t1 = OffsetDateTime::new_utc(
			Date::from_calendar_date(2025, Month::February, 3).unwrap(),
			Time::from_hms(02, 42, 52).unwrap(),
		);
		env.record(
			Event {
				id,
				bucket: 1,
				started_at: t1,
				ended_at: t1 + Duration::minutes(10),
				data: json!({}),
			},
			Duration::seconds(120),
		)
		.unwrap();
		_ = env.get_event(&id.into()).unwrap_err();

		// test not merged
		let id = Uuid::now_v7();
		let t1 = OffsetDateTime::new_utc(
			Date::from_calendar_date(2025, Month::February, 3).unwrap(),
			Time::from_hms(02, 42, 52).unwrap(),
		);
		env.record(
			Event {
				id,
				bucket: 1,
				started_at: t1,
				ended_at: t1 + Duration::minutes(10),
				data: json!({"a": 1}),
			},
			Duration::seconds(120),
		)
		.unwrap();
		_ = env.get_event(&id.into()).unwrap();

		let count = env.get_events(&Default::default()).unwrap().count();
		assert_eq!(count, 4);
	}

	#[test]
	fn test_get_event() {
		let mut env = test_env();
		let ev = env
			.get_event(&uuid!("90f5528f5fe34d85b90aaa0a2713dd15").into())
			.unwrap();
		assert_eq!(ev.id, uuid!("90f5528f5fe34d85b90aaa0a2713dd15"));
		assert_eq!(ev.bucket, 1);
		assert_eq!(
			ev.ended_at,
			OffsetDateTime::new_utc(
				Date::from_calendar_date(2025, Month::February, 3).unwrap(),
				Time::from_hms(02, 38, 54).unwrap(),
			)
		);
	}

	#[test]
	fn test_get_events() {
		let mut env = test_env();
		let ev = env
			.get_events(&EventFilter {
				bucket: Some(1),
				..Default::default()
			})
			.unwrap()
			.collect::<Vec<_>>();
		assert_eq!(ev.len(), 2);
		let ev = ev[0].as_ref().unwrap();
		assert_eq!(ev.id, uuid!("90f5528f5fe34d85b90aaa0a2713dd15"));
		assert_eq!(ev.bucket, 1);
	}

	#[test]
	fn test_delete_events() {
		let mut env = test_env();
		let count = env
			.get_events(&EventFilter {
				bucket: Some(1),
				..Default::default()
			})
			.unwrap()
			.count();
		assert_eq!(count, 2);

		env.delete_events(&EventFilter {
			bucket: Some(1),
			..Default::default()
		})
		.unwrap();

		let count = env
			.get_events(&EventFilter {
				bucket: Some(1),
				..Default::default()
			})
			.unwrap()
			.count();
		assert_eq!(count, 0);
	}
}
