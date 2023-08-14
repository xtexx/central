---
title: 'Conan Package Registry'
license: 'Apache-2.0'
origin_url: 'https://github.com/go-gitea/gitea/blob/faa28b5a44912f1c63afddab9396bae9e6fe061c/docs/content/doc/usage/packages/conan.en-us.md'
---

Publish [Conan](https://conan.io/) packages for your user or organization.

## Requirements

To work with the Conan package registry, you need to use the [conan](https://conan.io/downloads.html) command line tool to consume and publish packages.

## Configuring the package registry

To register the package registry you need to configure a new Conan remote:

```shell
conan remote add {remote} https://forgejo.example.com/api/packages/{owner}/conan
conan user --remote {remote} --password {password} {username}
```

| Parameter  | Description                                                                                                                                                                    |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `remote`   | The remote name.                                                                                                                                                               |
| `username` | Your Forgejo username.                                                                                                                                                         |
| `password` | Your Forgejo password. If you are using 2FA or OAuth use a [personal access token]({{< relref "doc/developers/api-usage.en-us.md#authentication" >}}) instead of the password. |
| `owner`    | The owner of the package.                                                                                                                                                      |

For example:

```shell
conan remote add forgejo https://forgejo.example.com/api/packages/testuser/conan
conan user --remote forgejo --password password123 testuser
```

## Publish a package

Publish a Conan package by running the following command:

```shell
conan upload --remote={remote} {recipe}
```

| Parameter | Description           |
| --------- | --------------------- |
| `remote`  | The remote name.      |
| `recipe`  | The recipe to upload. |

For example:

```shell
conan upload --remote=forgejo ConanPackage/1.2@forgejo/final
```

The Forgejo Conan package registry has full [revision](https://docs.conan.io/en/latest/versioning/revisions.html) support.

## Install a package

To install a Conan package from the package registry, execute the following command:

```shell
conan install --remote={remote} {recipe}
```

| Parameter | Description             |
| --------- | ----------------------- |
| `remote`  | The remote name.        |
| `recipe`  | The recipe to download. |

For example:

```shell
conan install --remote=forgejo ConanPackage/1.2@forgejo/final
```

## Supported commands

```
conan install
conan get
conan info
conan search
conan upload
conan user
conan download
conan remove
```
