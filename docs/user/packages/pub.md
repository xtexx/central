---
title: 'Pub Package Registry'
license: 'Apache-2.0'
origin_url: 'https://github.com/go-gitea/gitea/blob/faa28b5a44912f1c63afddab9396bae9e6fe061c/docs/content/doc/usage/packages/pub.en-us.md'
---

Publish [Pub](https://dart.dev/guides/packages) packages for your user or organization.

## Requirements

To work with the Pub package registry, you need to use the tools [dart](https://dart.dev/tools/dart-tool) and/or [flutter](https://docs.flutter.dev/reference/flutter-cli).

The following examples use dart.

## Configuring the package registry

To register the package registry and provide credentials, execute:

```shell
dart pub token add https://forgejo.example.com/api/packages/{owner}/pub
```

| Placeholder | Description               |
| ----------- | ------------------------- |
| `owner`     | The owner of the package. |

You need to provide your [personal access token](../../api-usage/#authentication).

## Publish a package

To publish a package, edit the `pubspec.yaml` and add the following line:

```yaml
publish_to: https://forgejo.example.com/api/packages/{owner}/pub
```

| Placeholder | Description               |
| ----------- | ------------------------- |
| `owner`     | The owner of the package. |

Now you can publish the package by running the following command:

```shell
dart pub publish
```

You cannot publish a package if a package of the same name and version already exists. You must delete the existing package first.

## Install a package

To install a Pub package from the package registry, execute the following command:

```shell
dart pub add {package_name} --hosted-url=https://forgejo.example.com/api/packages/{owner}/pub/
```

| Parameter      | Description               |
| -------------- | ------------------------- |
| `owner`        | The owner of the package. |
| `package_name` | The package name.         |

For example:

```shell
# use latest version
dart pub add mypackage --hosted-url=https://forgejo.example.com/api/packages/testuser/pub/
# specify version
dart pub add mypackage:1.0.8 --hosted-url=https://forgejo.example.com/api/packages/testuser/pub/
```
