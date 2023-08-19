---
title: 'Swift Packages Repository'
license: 'Apache-2.0'
origin_url: 'https://github.com/go-gitea/gitea/blob/faa28b5a44912f1c63afddab9396bae9e6fe061c/docs/content/doc/usage/packages/swift.en-us.md'
---

## Swift Packages Repository

Publish [Swift](hhttps://www.swift.org/) packages for your user or organization.

### Requirements

To work with the Swift package registry, you need to use [swift](https://www.swift.org/getting-started/) to consume and a HTTP client (like `curl`) to publish packages.

### Configuring the package registry

To register the package registry and provide credentials, execute:

```shell
swift package-registry set https://forgejo.example.com/api/packages/{owner}/swift -login {username} -password {password}
```

| Placeholder | Description                                                                                                                                  |
| ----------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `owner`     | The owner of the package.                                                                                                                    |
| `username`  | Your Forgejo username.                                                                                                                       |
| `password`  | Your Forgejo password. If you are using 2FA or OAuth use a [personal access token](../../api-usage/#authentication) instead of the password. |

The login is optional and only needed if the package registry is private.

### Publish a package

First you have to pack the contents of your package:

```shell
swift package archive-source
```

To publish the package perform a HTTP PUT request with the package content in the request body.

```shell --user your_username:your_password_or_token \
curl -X PUT --user {username}:{password} \
	 -H "Accept: application/vnd.swift.registry.v1+json" \
	 -F source-archive=@/path/to/package.zip \
	 -F metadata={metadata} \
	 https://forgejo.example.com/api/packages/{owner}/swift/{scope}/{name}/{version}
```

| Placeholder | Description                                                                                                                                  |
| ----------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `username`  | Your Forgejo username.                                                                                                                       |
| `password`  | Your Forgejo password. If you are using 2FA or OAuth use a [personal access token](../../api-usage/#authentication) instead of the password. |
| `owner`     | The owner of the package.                                                                                                                    |
| `scope`     | The package scope.                                                                                                                           |
| `name`      | The package name.                                                                                                                            |
| `version`   | The package version.                                                                                                                         |
| `metadata`  | (Optional) The metadata of the package. JSON encoded subset of https://schema.org/SoftwareSourceCode                                         |

You cannot publish a package if a package of the same name and version already exists. You must delete the existing package first.

### Install a package

To install a Swift package from the package registry, add it in the `Package.swift` file dependencies list:

```
dependencies: [
	.package(id: "{scope}.{name}", from:"{version}")
]
```

| Parameter | Description          |
| --------- | -------------------- |
| `scope`   | The package scope.   |
| `name`    | The package name.    |
| `version` | The package version. |

Afterwards execute the following command to install it:

```shell
swift package resolve
```
