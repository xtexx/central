use std::{num::TryFromIntError, ops::Add};

use diesel::{
	BoolExpressionMethods, BoxableExpression, ExpressionMethods, Insertable,
	OptionalExtension, QueryDsl, Queryable, RunQueryDsl, Selectable,
	SelectableHelper, delete, insert_into, sql_types::Bool, sqlite::Sqlite,
	update,
};
use serde::{Deserialize, Serialize};
use thiserror::Error;
use time::{Duration, OffsetDateTime, PrimitiveDateTime};
use uuid::Uuid;

use crate::{
	Microlens,
	bucket::BucketRef,
	db::{
		schema::{self, bucket::dsl as bucket_dsl, event::dsl},
		utils::{XJsonVal, XUuidVal, convert_time_to_utc, unixepoch},
	},
};

pub type EventRef = Uuid;

pub trait EventAccess {
	fn add_event(&mut self, event: Event) -> Result<()>;
	fn heartbeat(&mut self, event: Event, pulse: Duration) -> Result<()>;
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
#[diesel(check_for_backend(diesel::sqlite::Sqlite))]
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

	fn heartbeat(&mut self, event: Event, pulse: Duration) -> Result<()> {
		self.db_transaction_exclusive(|service| {
			let filter = (bucket_dsl::bid.eq(event.bucket))
				.and(dsl::bucket.eq(event.bucket))
				.and(
					unixepoch(dsl::ended_at)
						.add(
							TryInto::<i32>::try_into(pulse.whole_seconds())
								.map_err(EventError::PulseDurationOverflow)?,
						)
						.ge(unixepoch(dsl::started_at)),
				);
			let last_event: Option<SqlEvent> = bucket_dsl::bucket
				.inner_join(dsl::event)
				.filter(filter)
				.select(SqlEvent::as_select())
				.first(&mut service.db)
				.optional()?;

			if let Some(last_event) = last_event {
				// attempt to merge events
				let last_event = Event::from(last_event);
				if let Ok(event) = last_event.merge(&event) {
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
	fn get_events<'a>(
		&'a mut self,
		filter: &'a EventFilter,
	) -> Result<impl Iterator<Item = Result<Event>> + 'a> {
		Ok(dsl::event
			.filter(filter.make_filter())
			.select(SqlEvent::as_select())
			.load_iter(&mut self.db)?
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
	) -> Box<dyn BoxableExpression<dsl::event, Sqlite, SqlType = Bool> + '_> {
		// `bucket IS NOT NULL` never fails
		// We are using it as a alternative to `TRUE` as diesel does not support TRUE
		let mut expr = Box::new(dsl::bucket.is_not_null())
			as Box<
				dyn BoxableExpression<dsl::event, Sqlite, SqlType = Bool> + '_,
			>;

		if let Some(id) = self.id {
			expr = Box::new(expr.and(dsl::id.eq(XUuidVal(id))));
		}
		if let Some(bucket) = self.bucket {
			expr = Box::new(expr.and(dsl::bucket.eq(bucket)));
		}
		if let Some(time) = self.started_before {
			let time = convert_time_to_utc(time);
			expr = Box::new(
				expr.and(unixepoch(dsl::started_at).le(unixepoch(time))),
			);
		}
		if let Some(time) = self.started_after {
			let time = convert_time_to_utc(time);
			expr = Box::new(
				expr.and(unixepoch(dsl::started_at).ge(unixepoch(time))),
			);
		}
		if let Some(time) = self.ended_before {
			let time = convert_time_to_utc(time);
			expr = Box::new(
				expr.and(unixepoch(dsl::ended_at).le(unixepoch(time))),
			);
		}
		if let Some(time) = self.ended_after {
			let time = convert_time_to_utc(time);
			expr = Box::new(
				expr.and(unixepoch(dsl::ended_at).ge(unixepoch(time))),
			);
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
