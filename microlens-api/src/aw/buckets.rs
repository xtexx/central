use std::collections::HashMap;

use axum::{
	extract::{Path, Query}, http::StatusCode, Json
};
use kstring::KString;
use microlens_core::{
	bucket::{Bucket, BucketAccess, BucketSelector},
	event::{Event, EventAccess, EventFilter},
};
use serde::{Deserialize, Serialize};
use time::{OffsetDateTime, ext::NumericalDuration};
use uuid::Uuid;

use crate::{ApiError, ApiResult, Service};

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct AwBucket {
	#[serde(default)]
	pub id: KString,
	#[serde(rename = "type")]
	pub kind: KString,
	pub client: KString,
	#[serde(skip_deserializing)]
	pub hostname: KString,
	#[serde(
		default,
		skip_deserializing,
		with = "time::serde::rfc3339::option"
	)]
	pub created: Option<OffsetDateTime>,
	#[serde(default)]
	pub data: serde_json::Value,
	#[serde(default, skip_deserializing)]
	pub metadata: AwBucketMetadata,
	#[serde(
		default,
		skip_deserializing,
		with = "time::serde::rfc3339::option"
	)]
	pub last_updated: Option<OffsetDateTime>,
	// event is only for import/export
	#[serde(default)]
	pub events: Option<Vec<AwEvent>>,
}

#[derive(Debug, Serialize, Deserialize, Clone, Default)]
pub struct AwBucketMetadata {
	#[serde(default, with = "time::serde::rfc3339::option")]
	pub start: Option<OffsetDateTime>,
	#[serde(default, with = "time::serde::rfc3339::option")]
	pub end: Option<OffsetDateTime>,
}

impl From<Bucket> for AwBucket {
	fn from(value: Bucket) -> Self {
		AwBucket {
			id: value.name.1,
			kind: value.kind,
			client: value.client,
			hostname: value.name.0.clone(),
			created: Some(value.created_at),
			data: value.data,
			metadata: AwBucketMetadata {
				start: None,
				end: None,
			},
			last_updated: Some(value.updated_at),
			events: None,
		}
	}
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct AwEvent {
	#[serde(default)]
	pub id: Option<i64>,
	#[serde(with = "time::serde::rfc3339")]
	pub timestamp: OffsetDateTime,
	/// Duration of the event as a floating point number in seconds.
	/// Maximum precision is nanoseconds.
	pub duration: f64,
	pub data: serde_json::Value,
}

impl From<Event> for AwEvent {
	fn from(value: Event) -> Self {
		Self {
			id: Some(value.id.as_u64_pair().1 as i64),
			timestamp: value.started_at,
			duration: (value.ended_at - value.started_at).as_seconds_f64(),
			data: value.data,
		}
	}
}

pub async fn list_buckets(
	Service(mut service): Service,
) -> ApiResult<Json<HashMap<KString, AwBucket>>> {
	let mut result = HashMap::new();

	for bucket in service.get_buckets()? {
		let id = bucket.name.1.clone();
		let bucket = AwBucket::from(bucket);
		result.insert(id, bucket);
	}

	Ok(Json(result))
}

pub async fn get_bucket(
	Service(mut service): Service,
	Path((_, hostname, id)): Path<(Uuid, KString, KString)>,
) -> ApiResult<Json<AwBucket>> {
	let bucket = service.get_bucket(BucketSelector::Name((hostname, id)))?;
	Ok(Json(AwBucket::from(bucket)))
}

pub async fn create_bucket(
	Service(mut service): Service,
	Path((_, hostname, id)): Path<(Uuid, KString, KString)>,
	Json(bucket): Json<AwBucket>,
) -> ApiResult<StatusCode> {
	service.create_bucket((hostname, id), bucket.kind, bucket.client)?;
	Ok(StatusCode::CREATED)
}

pub async fn delete_bucket(
	Service(mut service): Service,
	Path((_, hostname, id)): Path<(Uuid, KString, KString)>,
) -> ApiResult<()> {
	service.delete_bucket(BucketSelector::Name((hostname, id)))?;
	Ok(())
}

#[derive(Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct GetEventsFilter {
	#[serde(default, with = "time::serde::rfc3339::option")]
	start: Option<OffsetDateTime>,
	#[serde(default, with = "time::serde::rfc3339::option")]
	end: Option<OffsetDateTime>,
	#[serde(default)]
	limit: Option<u64>,
}

pub async fn get_events(
	Service(mut service): Service,
	Path((_, hostname, id)): Path<(Uuid, KString, KString)>,
	Query(query): Query<GetEventsFilter>,
) -> ApiResult<Json<Vec<AwEvent>>> {
	let bucket = service.resolve_bucket((hostname, id).into())?;
	let filter = EventFilter {
		bucket: Some(bucket),
		started_after: query.start,
		ended_before: query.end,
		..Default::default()
	};
	let events = service.get_events(&filter)?;
	let mut results = Vec::new();

	for event in events {
		let event = event?;
		results.push(AwEvent::from(event));
	}

	Ok(Json(results))
}

pub async fn create_events(
	Service(mut service): Service,
	Path((_, hostname, id)): Path<(Uuid, KString, KString)>,
	Query(events): Query<Vec<AwEvent>>,
) -> ApiResult<Json<Vec<AwEvent>>> {
	let bucket = service.resolve_bucket((hostname, id).into())?;

	let mut results = Vec::new();

	service.db_transaction(|service| {
		for event in events {
			let id = Uuid::now_v7();
			let event = Event {
				id,
				bucket,
				started_at: event.timestamp,
				ended_at: event.timestamp + event.duration.seconds(),
				data: event.data,
			};
			service.add_event(event)?;
			let filter = EventFilter {
				id: Some(id),
				..Default::default()
			};
			results.push(AwEvent::from(service.get_event(&filter)?));
		}
		Ok::<_, ApiError>(())
	})?;

	Ok(Json(results))
}

#[derive(Debug, PartialEq, Serialize, Deserialize)]
pub struct HeartbeatParams {
	#[serde(default)]
	pulsetime: Option<f64>,
}

pub async fn heartbeat(
	Service(mut service): Service,
	Path((_, hostname, id)): Path<(Uuid, KString, KString)>,
	Query(query): Query<HeartbeatParams>,
	Query(event): Query<AwEvent>,
) -> ApiResult<Json<AwEvent>> {
	let bucket = service.resolve_bucket((hostname, id).into())?;

	let id = Uuid::now_v7();
	let event = Event {
		id,
		bucket,
		started_at: event.timestamp,
		ended_at: event.timestamp + event.duration.seconds(),
		data: event.data,
	};
	service.record(event, query.pulsetime.unwrap_or(120.0).seconds())?;

	let filter = EventFilter {
		id: Some(id),
		..Default::default()
	};
	Ok(Json(AwEvent::from(service.get_event(&filter)?)))
}
