---
title: 'Cargo Package Registry'
license: 'Apache-2.0'
origin_url: 'https://github.com/go-gitea/gitea/blob/faa28b5a44912f1c63afddab9396bae9e6fe061c/docs/content/doc/usage/packages/cargo.en-us.md'
---

Publish [Cargo](https://doc.rust-lang.org/stable/cargo/) packages for your user or organization.

## Requirements

To work with the Cargo package registry, you need [Rust and Cargo](https://www.rust-lang.org/tools/install).

Cargo stores information about the available packages in a package index stored in a git repository.
This repository is needed to work with the registry.
The following section describes how to create it.

## Index Repository

Cargo stores informations about the available packages in a package index stored in a git repository.
In Forgejo this repository has the special name `_cargo-index`.
After a package was uploaded, its metadata is automatically written to the index.
The content of this repository should not be manually modified.

The user or organization package settings page allows to create the index repository along with the configuration file.
If needed this action will rewrite the configuration file.
This can be useful if for example the Forgejo instance domain was changed.

If the case arises where the packages stored in Forgejo and the information in the index repository are out of sync, the settings page allows to rebuild the index repository.
This action iterates all packages in the registry and writes their information to the index.
If there are lot of packages this process may take some time.

## Configuring the package registry

To register the package registry the Cargo configuration must be updated.
Add the following text to the configuration file located in the current users home directory (for example `~/.cargo/config.toml`):

```
[registry]
default = "forgejo"

[registries.forgejo]
index = "https://forgejo.example.com/{owner}/_cargo-index.git"

[net]
git-fetch-with-cli = true
```

| Parameter | Description               |
| --------- | ------------------------- |
| `owner`   | The owner of the package. |

If the registry is private or you want to publish new packages, you have to configure your credentials.
Add the credentials section to the credentials file located in the current users home directory (for example `~/.cargo/credentials.toml`):

```
[registries.forgejo]
token = "Bearer {token}"
```

| Parameter | Description                                                                                     |
| --------- | ----------------------------------------------------------------------------------------------- |
| `token`   | Your [personal access token]({{< relref "doc/developers/api-usage.en-us.md#authentication" >}}) |

## Publish a package

Publish a package by running the following command in your project:

```shell
cargo publish
```

You cannot publish a package if a package of the same name and version already exists. You must delete the existing package first.

## Install a package

To install a package from the package registry, execute the following command:

```shell
cargo add {package_name}
```

| Parameter      | Description       |
| -------------- | ----------------- |
| `package_name` | The package name. |

## Supported commands

```
cargo publish
cargo add
cargo install
cargo yank
cargo unyank
cargo search
```
