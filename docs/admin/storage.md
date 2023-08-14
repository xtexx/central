---
title: 'Storage settings'
license: 'CC-BY-SA-4.0'
---

The storage for each subsystem is defined in `app.ini`. It can either be on disk
(`local`) or using a MinIO server (`minio`). The default is `local`
storage, using the following hierarchy under the `APP_DATA_PATH` directory:

| subsystem           | default base path  | app.ini sections      |
| ------------------- | ------------------ | --------------------- |
| Attachments         | attachments/       | [attachment]          |
| LFS                 | lfs/               | [lfs]                 |
| Avatars             | avatars/           | [avatar]              |
| Repository avatars  | repo-avatars/      | [repo-avatar]         |
| Repository archives | repo-archive/      | [repo-archive]        |
| Packages            | packages/          | [packages]            |
| Actions logs        | actions_log/       | [storage.actions_log] |
| Actions Artifacts   | actions_artifacts/ | [actions.artifacts]   |

For instance if `APP_DATA_PATH` was `/appdata`, the default directory to
store attachments will be `/appdata/attachments`.

## Overriding the defaults

These defaults can be modified for all subsystems in the `[storage]`
section. For instance setting:

```
[storage]
PATH = /mystorage
```

will change the default for storing attachments to
`/mystorage/attachments`. It is also possible to change these settings
for each subsystem in their dedicated section. For instance:

```
[storage]
PATH = /mystorage

[attachment]
PATH = /otherstorage/attachments
```

will store attachments in `/otherstorage/attachments` while `lfs`
files will be stored in `/mystorage/lfs`.

## Storage type

The value of `STORAGE_TYPE` can be `local` (the default) or `minio`. For instance:

```
[storage]
STORAGE_TYPE = minio
```

will use `minio` for all subsystems (Attachments, LFS, etc.)
instead of storing them on disk. Each storage type has its own
settings, as explained below.

## `local` storage

There is just one setting when the `STORAGE_TYPE` is set to `local`,
`PATH`. It must be an absolute path and is interpreted as follows.

In the `[storage]` section, `PATH` is the directory under which the default
base path of each subsystem will be created instead of
`APP_DATA_PATH`. For instance, if `APP_DATA_PATH` equals `/appdata`:

```
[storage]
STORAGE_TYPE = local
PATH = /mystorage
```

Will create attachments in `/mystorage/attachments` instead of
`/appdata/attachments`, LFS files in `/mystorage/lfs` instead of
`/appdata/lfs`, etc.

In the section dedicated to a subsystem (see the table above), `PATH`
is the base path under which all files will be stored. For instance:

```
[storage]
STORAGE_TYPE = local
PATH = /mystorage

[attachment]
STORAGE_TYPE = local
PATH = /otherstorage/attachments
```

will store attachments in `/otherstorage/attachments` while `lfs`
files will be stored in `/mystorage/lfs`.

## `minio` storage

When the `STORAGE_TYPE` is set to `minio`, the settings available in
all sections (`[storage]` and `[XXXX]`) are:

- `SERVE_DIRECT`: **false**: Allows the storage driver to redirect to authenticated URLs to serve files directly. Only supported via signed URLs.
- `MINIO_ENDPOINT`: **localhost:9000**: Minio endpoint to connect.
- `MINIO_ACCESS_KEY_ID`: Minio accessKeyID to connect.
- `MINIO_SECRET_ACCESS_KEY`: Minio secretAccessKey to connect.
- `MINIO_BUCKET`: **gitea**: Minio bucket to store the data.
- `MINIO_LOCATION`: **us-east-1**: Minio location to create bucket.
- `MINIO_USE_SSL`: **false**: Minio enabled ssl.
- `MINIO_INSECURE_SKIP_VERIFY`: **false**: Minio skip SSL verification.

One setting is only available in the `[XXXX]` sections:

- `MINIO_BASE_PATH`: defaults to the `default base path` of the `XXXX`
  subsystem (see the table above) and is a relative path within the
  MinIO bucket defined by `MINIO_BUCKET`.

## Sections precedence

The sections in which a setting is found have the following priority:

- [XXXX] has precedence
- [storage] is the default

For instance:

```
[storage]
PATH = /default

[attachment]
PATH = /first
```

Will set the value of `PATH` for attachments to `/first`.

## Undocumented features

It is **strongly** recommended to avoid using undocumented features -
such as `[storage.attachments]` as an alternative to `[attachment]`
for instance (the plural is not a typo, it is a unification problem) -
because their behavior is not thoroughly tested and may lead to
unexpected results.
