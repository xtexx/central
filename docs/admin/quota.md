---
title: 'Soft-Quota'
license: 'CC-BY-SA-4.0'
---

Forgejo has early support for a soft-quota that can protect your server from high disk usage
due to abuse or errors.
The feature is still in development.
If you make use of it, consider sending us feedback via [a discussion](https://codeberg.org/forgejo/discussions/issues/),
or the Matrix channels.

## Understanding soft-quota and its limitations

Forgejo has chosen to use a "soft" quota implementation.
It means that Forgejo checks the quota usage only before an action is executed,
but it will allow a started action to complete.

In some cases (like pushing to Git repositories),
it is hard to estimate the exact new size,
because it depends on how much data is available and how much we can benefit from compression.
As a result, it is possible to exceed the quota if the operation was started before the quota was used up,
but after the quota is exceeded,
new operations that would increase the quota won't be possible.

Further, there is currently little support for early prevention of operations in the UI:
The handling for e.g. web operations that are denied later is not yet optimal.

You can read more about the technical background in the
[initial PR setting the foundations](https://codeberg.org/forgejo/forgejo/pulls/4212).

## Getting started

The quota feature is currently not yet enabled by default.
Set this in your app.ini:

```ini
[quota]
ENABLED = true
```

You can now choose between managing quota via the config file
(simple option, but limited functionality)
or via the API (more advanced).

### Simple case

To make use of a simple quota for your instance,
you can set a global quota for all data:

```ini
[quota.default]
TOTAL = 2G
```

`quota.default.TOTAL` is `-1` (unlimited) by default and can take sizes suffixed with units such as 500M or 10G.

## Advanced usage: via API

If you have more complex needs,
you can use the API to configure quota rules.

1. With an admin account, create a new application token.
2. Make yourself familiar with the API endpoints by visiting the swagger documentation (e.g. by visiting `/api/swagger` ([online example](https://v9.next.forgejo.org/api/swagger#/admin)).
3. Make yourself familiar with the available quota subjects from the [respective section in the config cheat sheet](../config-cheat-sheet/#quota-subjects-list).
4. Optionally, set up a local helper for interacting with the API:

```sh
  export FORGEJO_API_TOKEN="your-admin-api-token" #  delete after setting it up or ensure it is not preserved in the shell history
api_helper() {
  endpoint="$1"; shift
  curl -s -H "content-type: application/json" \
          -H "accept: application/json" \
          -H "authorization: token ${FORGEJO_API_TOKEN}" \
      "https://url-to-your-forgejo/api/v1${endpoint}" "$@" | jq .
}
```

### Example: Set up a quota group

This example sets a quota group that is restricted tightly on Git repo space,
has more generous limits for LFS files
and can store unlimited packages and attachments,
but Actions artifacts are restricted:

```json
{
  "name": "newgroup",
  "rules": [
    {
      "name": "git",
      "limit": 200000000,
      "subjects": ["size:repos:all"]
    },
    {
      "name": "git-lfs",
      "limit": 500000000,
      "subjects": ["size:git:lfs"]
    },
    {
      "name": "all-assets",
      "limit": -1,
      "subjects": ["size:assets:all"]
    },
    {
      "name": "size:assets:artifacts",
      "limit": 350000000,
      "subjects": ["size:assets:all"]
    }
  ]
}
```

After tuning the above JSON to your needs,
you can create a new quota group by calling the API:

```sh
api_helper /admin/quota/groups -XPOST -d '{"your": "json"}'
```

Check the API documentation for more details on how you can add, modify and delete quota groups and their rules.

### Example: Managing users

If you do not modify the `default` quota group,
or have your new groups listed in the `[quota].DEFAULT_GROUPS` list,
they won't apply to users.

However, you can create quota groups and assign users to them:

```sh
api_helper "/admin/quota/groups/<GROUPNAME>/users/<USERNAME>" -XPUT
```

Or remove them:

```sh
api_helper "/admin/quota/groups/<GROUPNAME>/users/<USERNAME>" -XDELETE
```
