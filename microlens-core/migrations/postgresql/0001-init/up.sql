-- Bucket
CREATE TABLE `bucket` (
	`bid` INTEGER PRIMARY KEY AUTOINCREMENT,
	`hostname` VARCHAR(64) NOT NULL,
	`id` VARCHAR(64) NOT NULL,
	`kind` VARCHAR(64) NOT NULL,
	`client` VARCHAR(64) NOT NULL,
	`data` JSONB NOT NULL DEFAULT '{}',
	`created_at` TIMESTAMP NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
	`updated_at` TIMESTAMP NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
	`last_event` UUID NULL DEFAULT NULL
);
CREATE UNIQUE INDEX `bucket_bid` ON `bucket` (`bid`);
CREATE UNIQUE INDEX `bucket_host_id` ON `bucket` (`hostname`, `id`);
-- Event
CREATE TABLE `event` (
	`id` UUID PRIMARY KEY,
	`bucket` INTEGER NOT NULL,
	`started_at` TIMESTAMP NOT NULL,
	`ended_at` TIMESTAMP NOT NULL,
	`data` JSONB NOT NULL DEFAULT '{}',
	FOREIGN KEY (`bucket`) REFERENCES `bucket`(`bid`) ON DELETE CASCADE
);
CREATE UNIQUE INDEX `event_id` ON `event` (`id`);
CREATE INDEX `event_bucket` ON `event` (`bucket`);
CREATE INDEX `event_bucket_started` ON `event` (`bucket`, `started_at`);
CREATE INDEX `event_started` ON `event` (`started_at`);
CREATE INDEX `event_ended` ON `event` (`ended_at`);
-- Configuration K-V Storage
CREATE TABLE `config_kv` (
	`key` VARCHAR(128) PRIMARY KEY,
	`value` TEXT NOT NULL,
	`updated_at` TIMESTAMP NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC')
);
CREATE UNIQUE INDEX `config_kv_key` ON `event` (`id`);
-- Tokens
CREATE TABLE `tokens` (
	`id` UUID PRIMARY KEY,
	`created_at` TIMESTAMP NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
	`used_at` TIMESTAMP NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC')
);
CREATE UNIQUE INDEX `tokens_id` ON `tokens` (`id`);
