INSERT INTO `bucket` (`bid`, `hostname`, `id`, `kind`, `client`) VALUES (1, 'localhost', 'test1', 'test1', 'fixures');

INSERT INTO `event` (`id`, `bucket`, `started_at`, `ended_at`) VALUES (x'90f5528f5fe34d85b90aaa0a2713dd15', 1, datetime('2025-02-03 02:37:54'), datetime('2025-02-03 02:38:54'));
INSERT INTO `event` (`id`, `bucket`, `started_at`, `ended_at`) VALUES (x'0965324bfb9c45faaa3d051999530903', 1, datetime('2025-02-03 02:39:54'), datetime('2025-02-03 02:40:54'));
UPDATE `bucket` SET `last_event` = x'0965324bfb9c45faaa3d051999530903' WHERE `bid` == 1;
