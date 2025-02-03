diesel::table! {
	use diesel::sql_types::*;
	use crate::db::utils::*;

	bucket (bid) {
		bid -> Integer,
		hostname -> VarChar,
		id -> VarChar,
		kind -> VarChar,
		client -> VarChar,
		data -> XJson,
		created_at -> Timestamp,
		updated_at -> Timestamp,
		last_event -> Nullable<XUuid>,
	}
}

diesel::table! {
	use diesel::sql_types::*;
	use crate::db::utils::*;

	event (id) {
		id -> XUuid,
		bucket -> Integer,
		started_at -> Timestamp,
		ended_at -> Timestamp,
		data -> XJson,
	}
}

diesel::joinable!(bucket -> event (last_event));

diesel::allow_tables_to_appear_in_same_query!(bucket, event,);

diesel::table! {
	use diesel::sql_types::*;
	use crate::db::utils::*;

	config_kv (key) {
		key -> VarChar,
		value -> Text,
		updated_at -> Timestamp,
	}
}

diesel::table! {
	use diesel::sql_types::*;
	use crate::db::utils::*;

	tokens (id) {
		id -> XUuid,
		created_at -> Timestamp,
		used_at -> Timestamp,
	}
}
