use std::{cmp::min, collections::HashMap};

use axum::{
	Json, Router,
	extract::{Path, Query},
	routing::{any, get, post},
};
use kstring::KString;
use microlens_core::{
	bucket::{BucketAccess, BucketError, BucketSelector},
	config_store::ConfigStore,
	event::{Event, EventAccess, EventFilter},
	token::{Token, TokenStore},
};
use serde::{Deserialize, Serialize};
use time::{Duration, OffsetDateTime};
use uuid::Uuid;

use crate::{ApiError, ApiResult, Service, ServiceRef, ServiceState};

pub fn router() -> Router<ServiceState> {
	Router::new()
		.route("/query", get(query))
		.route("/get/status_list", get(get_status_list))
		.route("/status_list", get(get_status_list))
		.route("/status_list/{token}", post(set_status_list))
		.route("/set/{token}/{status}", any(set_status))
		.route("/set", any(set_status_single))
		.route("/device/set", get(device_set_get).post(device_set_post))
}

#[derive(Debug, Serialize, Clone)]
struct UploadSuccess {
	success: bool,
	code: KString,
	#[serde(default)]
	set_to: Option<u32>,
}

impl Default for UploadSuccess {
	fn default() -> Self {
		Self {
			success: true,
			code: "OK".into(),
			set_to: None,
		}
	}
}

const STATUS_KEY: &str = "sleepy:status";
const STATUS_LIST_KEY: &str = "sleepy:status-list";
const STATUS_SLICE_KEY: &str = "sleepy:status-slice";
const REFRESH_KEY: &str = "sleepy:status-refresh";

const DEFAULT_STATUS_SLICE: usize = 50;
const DEFAULT_REFRESH: usize = 5000;

const SLEEP_BUCKET_KIND: &str = "sleepy";

#[derive(Debug, Serialize, Deserialize, Clone)]
struct SleepyStatus {
	id: u32,
	name: KString,
	desc: String,
	color: KString,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
struct QueryResult {
	time: String,
	last_updated: String,
	success: bool,
	status: u32,
	info: SleepyStatus,
	device: HashMap<KString, DeviceResult>,
	device_status_slice: usize,
	refresh: usize,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
struct DeviceResult {
	show_name: KString,
	using: bool,
	app_name: String,
}

async fn query(Service(mut service): Service) -> ApiResult<Json<QueryResult>> {
	let time = OffsetDateTime::now_utc();
	let time_str = format!(
		"{:04}-{:02}-{:02} {:02}:{:02}:{:02}",
		time.year(),
		time.month(),
		time.day(),
		time.hour(),
		time.minute(),
		time.second()
	);
	let status = service.kv_get(STATUS_KEY)?.unwrap_or(0);
	let info = service
		.kv_get::<Vec<SleepyStatus>>(STATUS_LIST_KEY)?
		.unwrap_or_default()
		.into_iter()
		.find(|s| s.id == status)
		.unwrap_or_else(|| SleepyStatus {
			id: status,
			name: "???".into(),
			desc: "? ? ?".into(),
			color: "sleeping".into(),
		});
	let device_status_slice = service
		.kv_get::<usize>(STATUS_SLICE_KEY)?
		.unwrap_or(DEFAULT_STATUS_SLICE);
	let refresh = service
		.kv_get::<usize>(REFRESH_KEY)?
		.unwrap_or(DEFAULT_REFRESH);

	let mut device = HashMap::new();
	for bucket in service.get_buckets_of_kind(SLEEP_BUCKET_KIND)? {
		if let Some(event) = bucket.last_event_id {
			let filter = EventFilter {
				id: Some(event),
				..Default::default()
			};
			let event = service.get_event(&filter)?;
			if event.ended_at < time {
				continue;
			}
			let event_data = serde_json::from_value::<SleepyEvent>(event.data)
				.map_err(ApiError::JsonError)?;

			let show_name = service
				.kv_get(&format!("sleepy:device-name:{}", bucket.name.0))?
				.unwrap_or_default();
			let app_name = event_data.content
				[0..min(device_status_slice, event_data.content.len())]
				.to_string();
			let info = DeviceResult {
				show_name,
				using: event_data.using,
				app_name,
			};
			device.insert(bucket.name.0, info);
		}
	}

	let result = QueryResult {
		last_updated: time_str.clone(),
		time: time_str,
		success: true,
		status,
		info,
		device,
		device_status_slice,
		refresh,
	};
	Ok(Json(result))
}

async fn get_status_list(
	Service(mut service): Service,
) -> ApiResult<Json<Vec<SleepyStatus>>> {
	Ok(Json(service.kv_get(STATUS_LIST_KEY)?.unwrap_or(Vec::new())))
}

async fn set_status_list(
	Service(mut service): Service,
	Path(token): Path<Token>,
	Json(list): Json<Vec<SleepyStatus>>,
) -> ApiResult<Json<UploadSuccess>> {
	service.touch_token(token)?;
	service.kv_put(STATUS_LIST_KEY, list)?;

	Ok(Json(UploadSuccess {
		..Default::default()
	}))
}

async fn set_status(
	Service(mut service): Service,
	Path((token, status)): Path<(Token, u32)>,
) -> ApiResult<Json<UploadSuccess>> {
	service.touch_token(token)?;
	service.kv_put(STATUS_KEY, status)?;

	Ok(Json(UploadSuccess {
		set_to: Some(status),
		..Default::default()
	}))
}

#[derive(Debug, Serialize, Deserialize, Clone)]
struct SetStatusRequest {
	secret: Token,
	status: u32,
}

async fn set_status_single(
	Service(mut service): Service,
	Query(req): Query<SetStatusRequest>,
) -> ApiResult<Json<UploadSuccess>> {
	service.touch_token(req.secret)?;
	service.kv_put(STATUS_KEY, req.status)?;

	Ok(Json(UploadSuccess {
		set_to: Some(req.status),
		..Default::default()
	}))
}

#[derive(Debug, Serialize, Deserialize, Clone)]
struct UploadRequest {
	secret: Token,
	id: KString,
	show_name: KString,
	using: bool,
	app_name: String,
}

async fn device_set_get(
	Service(service): Service,
	Query(req): Query<UploadRequest>,
) -> ApiResult<Json<UploadSuccess>> {
	handle_upload(service, req).await?;
	Ok(Json(UploadSuccess::default()))
}

async fn device_set_post(
	Service(service): Service,
	Json(req): Json<UploadRequest>,
) -> ApiResult<Json<UploadSuccess>> {
	handle_upload(service, req).await?;
	Ok(Json(UploadSuccess::default()))
}

#[derive(Debug, Serialize, Deserialize, Clone)]
struct SleepyEvent {
	using: bool,
	content: String,
}

async fn handle_upload(
	mut service: ServiceRef,
	req: UploadRequest,
) -> ApiResult<()> {
	service.touch_token(req.secret)?;

	let bucket_id = (req.id.clone(), "sleepy".into());
	let bucket =
		service.resolve_bucket(BucketSelector::Name(bucket_id.clone()));

	let bucket = match bucket {
		Ok(bucket) => bucket,
		Err(error) => {
			if matches!(error, BucketError::BucketNotFound(_)) {
				service.create_bucket(
					bucket_id,
					SLEEP_BUCKET_KIND,
					"sleepy-compat",
				)?
			} else {
				return Err(error.into());
			}
		}
	};

	service.kv_put(&format!("sleepy:device-name:{}", req.id), req.show_name)?;

	let data = SleepyEvent {
		using: req.using,
		content: req.app_name.clone(),
	};
	let time = OffsetDateTime::now_utc();
	let event = Event {
		id: Uuid::now_v7(),
		bucket,
		started_at: time,
		ended_at: time + Duration::minutes(10),
		data: serde_json::to_value(data).map_err(ApiError::JsonError)?,
	};

	service.record(event, Duration::minutes(5))?;

	Ok(())
}
