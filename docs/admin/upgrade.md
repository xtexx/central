---
title: 'Upgrade guide'
license: 'CC-BY-SA-4.0'
origin_url: 'https://forgejo.gna.org/Hostea/admin-guide/src/branch/master/README.md'
---

This guide helps Forgejo admins perform upgrades safely and provides guidance to troubleshoot problems. It also covers upgrades from Gitea back to version 1.2.0.

## Release life cycle

There are about two major versions published every year. Each version undergoes the following states:

- **Experimental** (current development version): receives new features, should not be used in production
- **Stable** (latest major version): receives full support, bugfixes and security fixes
- **Old Stable** (previous major version): receives only critical security support

To be notified in advance of security releases, watch or subscribe to the RSS feed of the [security-announcements repository](https://codeberg.org/forgejo/security-announcements/issues). The details of the vulnerability will not be revealed, only the expected release date, for administrators to plan ahead and better secure their instance.

## Backup

To be safe, make sure to perform a full backup before upgrading. It is a requirement when upgrading to a new stable release (going from v1.20 to v1.21 for instance) but is also a good precaution when installing a patch release (going from v1.20.4-0 to v1.20.5-1 for instance).

The reliable way to perform a backup is with a synchronized point-in-time snapshot of all the storage used by Forgejo.

For instance, if everything (SQLite database + repositories etc.) is on a single QCOW2 disk attached to a virtual machine, a [qemu snapshot](https://wiki.qemu.org/Features/Snapshots) guarantees the backup is consistent and can be done while the Forgejo server is running.

However, if Forgejo uses a S3 storage for attachments with a PostgresQL database, stores Git repositories on a remote file system and queues in a Redis server, the only way to ensure a consistent state is to shutdown Forgejo during the backup.

In the simplest case where everything is on a single file system and if the instance is not busy (no mirrors, no users), the backup can be done with:

- `forgejo dump` to collect everything into one zip file
- `psql/mysql/mssql dump`. Although the zip file created by `forgejo dump` contains a copy of the database it has serious long standing open bugs that may introduce problems when re-injecting the SQL dump in a new database. Note that there is no need to dump SQLite because the database itself is included in the zip file already.

## Verify Forgejo works

It is **critical** to verify that Forgejo works very carefully. Restoring the backup done before the upgrade is easy and does not lose any information. But if a problem is discovered days or weeks after the upgrade, it will not be an option and fixing it on a live Forgejo instance will be much more challenging.

- Run `forgejo doctor check --all --log-file /tmp/doctor.log` and make sure it does not report any problem.
- Manually verify via the web interface. Making a checklist of a typical use case is a good way to not miss anything.
- If there is a problem of any kind, increase the log level and take a look at the logs. If you cannot figure out what the problem is, ask for help [in the Forgejo chatroom](https://matrix.to/#/#forgejo-chat:matrix.org) before trying to fix it.

## Preparing the Forgejo upgrade

- Manually analyze (reading the patches to the sources of the template directory) and update the customized CSS / content.
- Do not use `forgejo help` to figure out the location of `CustomPath`, look at the configuration tab of the `Site administration` panel when logged in as an admin.
- `forgejo manager flush-queues`. If it timesout, run it again with a more generous `--timeout` argument. It is important because the queues contain serialized data that is not guaranteed to be backward compatible between versions.
- Go to the `Site administration` panel and pause all queues

Note: Forgejo requires [docker >= 20.10.6](https://wiki.alpinelinux.org/wiki/Release_Notes_for_Alpine_3.14.0) otherwise mysterious problems will happen (mysterious in the sense that the problem will about something unrelated to the Docker version").

## Performing the upgrade

- If the upgrade is from a Gitea version [lower than 1.6](https://github.com/go-gitea/gitea/blob/faa28b5a44912f1c63afddab9396bae9e6fe061c/models/migrations/migrations.go#L63) and greater or equal to 1.2.0, proceed as follows:
  - Upgrade to 1.2.3 and manually verify it runs
  - Upgrade to 1.4.3 and manually verify it runs
  - Upgrade to 1.5.3 and manually verify it runs
  - Upgrade to 1.6.4 and manually verify it runs
- If the upgrade is from a Gitea version greater or equal to 1.6.4 that is not mentioned to be problematic [below](#when-upgrading-from-a-specific-version), upgrade directly to the latest stable Forgejo version; there is no need to upgrade to intermediate versions.
- Verify Forgejo works

## Troubleshooting

- Increase the log level. By default, the logs are outputted to console. If you need to collect logs from files, you could copy the following config into your `app.ini` file (remove all other [log] sections), then you can find the \*.log files in Forgejo's log directory.
  ```ini
   ; To show all SQL logs, you can also set LOG_SQL=true in the [database] section
   [log]
   LEVEL=debug
   MODE=console,file
   ROUTER=console,file
   XORM=console,file
   ENABLE_XORM_LOG=true
   FILE_NAME=forgejo.log
   [log.file.router]
   FILE_NAME=router.log
   [log.file.xorm]
   FILE_NAME=xorm.log
  ```
- If the upgrade from version x.y to version x.y+2 fails and there is a need to narrow down the problem, try upgrading to the latest minor version of each major version and verify it works. It will show which major version causes the issue and help debug the problem. For instance, if upgrading from Forgejo 1.19.3-0 to Forgejo 1.20.5-1 does not work:
  - Upgrade from Forgejo 1.19.3-0 to Forgejo 1.19.4-0 (the last minor version of the 1.19 major version) and verify Forgejo works.
  - Upgrade to Forgejo 1.20.5-1 (the last minor version of the 1.20 major version) and verify Forgejo works.

### Unexpected database version

The database version is stored in the database and used to prevent an accidental downgrade. For instance, if a running `Forgejo v1.20` instance is downgraded to `Forgejo v1.19`, it will refuse to start because it would damage the content of the database.

### When upgrading from a specific version...

- Any version before Forgejo v1.20.3-0
  - verify the `app.ini` file does not problematic `[storage*]` sections [as explained in the v1.20.3-0 blog post](https://forgejo.org/2023-08-release-v1-20-3-0/)
- Any version before [Gitea 1.17](https://github.com/go-gitea/gitea/releases/tag/v1.17.4)
  - preserve a custom gitconfig: [episode 1](https://gna.org/blog/1-17-breaking-episode-1/), [episode 2](https://gna.org/blog/1-17-breaking-episode-2/)
- [Gitea 1.13.0](https://blog.gitea.io/2020/12/gitea-1.13.0-is-released/)
  - The Webhook shared secret inside the webhook payload has been deprecated and will be removed in 1.14.0: https://github.com/go-gitea/gitea/issues/11755 please use the secret header that uses an hmac signature to validate the webhook payload.
  - Git hooks now default to `off`! ([#13058](https://github.com/go-gitea/gitea/pull/13058))
    In your config, you can check the security section for `DISABLE_GIT_HOOKS`. To enable them again, you must set the setting to `false`.

### Only when upgrading to a specific version

- From [v1.19] to a version greater or equal to than [1.20](https://forgejo.org/2023-07-release-v1/)

  - The [tokens](https://forgejo.org/docs/v1.20/user/oauth2-provider/#scoped-tokens) were refactored in a way that does not guarantee their scope will be preserved. They may be larger or narrower and the only way to be sure that the intended scope is preserved is to re-create the token.

- [1.15.2](https://blog.gitea.io/2021/09/gitea-1.15.2-is-released/)

  - Unfortunately following the release of 1.15.1 it has become apparent that there is an issue with upgrading from 1.15.0 to 1.15.1 due to problem with a table constraint that was unexpectedly automatically dropped. Users who upgraded straight from 1.14.x to 1.15.1 are not affected and users who upgraded from 1.15.0 to 1.15.1 can fix the problem using `gitea doctor recreate-table issue_index` or upgrade to 1.15.2.

- Between [1.13.0](https://blog.gitea.io/2020/12/gitea-1.13.0-is-released/) [1.13.3](https://blog.gitea.io/2021/03/gitea-1.13.3-is-released/)
  - Password hashing algorithm default has changed back to pbkdf2 from argon2. ([#14673](https://github.com/go-gitea/gitea/pull/14673))

### Unexplained upgrade failures & workarounds

- All versions
  - Symptom: [blank / 500 page after login when running SQLite](https://github.com/go-gitea/gitea/issues/18650)
  - Workaround: upgrade to [Forgejo 1.19.3-0 or greater](https://codeberg.org/forgejo/forgejo/commit/443675d18072d2a345bc4644d3f52dee42f58b44) and run `gitea doctor check --all --fix`

### Versions with known issues

- Gogs from before September 2015 migrated to Forgejo v1.18 may have a [dangling `pull_repo` table](https://forum.gna.org/t/73) and the corresponding pull requests will be removed by `gitea doctor check --fix --all`.

[From the 1.11.3 release notes](https://blog.gitea.io/2020/03/gitea-1.11.3-and-1.10.6-released/):

- v1.10.0, v1.10.1, v1.10.2, v1.10.3, v1.10.4, v1.11.0, and v1.11.1 **do not use** any of these versions, as a bug in the upgrade process will delete attachments from the releases on your repositories.
- v1.11.2 (now replaced by 1.11.3) was mistakenly compiled with Go 1.14, which Gitea is not currently fully tested with and it’s known to cause [a few issues](https://github.com/go-gitea/gitea/issues/10661).
- v1.10.5 (replaced by 1.10.6 if you need to keep using the 1.10 branch) was incorrectly tagged, and was in fact a snapshot of our development branch (1.12-dev). It was also compiled with Go 1.14.
