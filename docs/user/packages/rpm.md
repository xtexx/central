---
title: 'RPM Package Registry'
license: 'Apache-2.0'
origin_url: 'https://github.com/go-gitea/gitea/blob/e865de1e9d65dc09797d165a51c8e705d2a86030/docs/content/usage/packages/rpm.en-us.md'
---

Publish [RPM](https://rpm.org/) packages for your user or organization.

## Requirements

To work with the RPM registry, you need to use a package manager like `yum` or `dnf` to consume packages.

The following examples use `dnf`.

## Configuring the package registry

To register the RPM registry add the url to the list of known sources:

```shell
dnf config-manager --add-repo https://forgejo.example.com/api/packages/{owner}/{group}.repo
```

| Placeholder | Description                                                        |
| ----------- | ------------------------------------------------------------------ |
| `owner`     | The owner of the package.                                          |
| `group`     | Optional: Everything, e.g. empty, `el7`, `rocky/el9`, `test/fc38`. |

Example:

```shell
# without a group
dnf config-manager --add-repo https://forgejo.example.com/api/packages/testuser/rpm.repo

# with the group 'centos/el7'
dnf config-manager --add-repo https://forgejo.example.com/api/packages/testuser/rpm/centos/el7.repo
```

If the registry is private, provide credentials in the url. You can use a password or a personal access token:

```shell
dnf config-manager --add-repo https://{username}:{your_password_or_token}@forgejo.example.com/api/packages/{owner}/{group}.repo
```

You have to add the credentials to the urls in the created `.repo` file in `/etc/yum.repos.d` too.

## Publish a package

To publish a RPM package (`*.rpm`), perform a HTTP PUT operation with the package content in the request body.

```
PUT https://forgejo.example.com/api/packages/{owner}/rpm/{group}/upload
```

| Parameter | Description                                                        |
| --------- | ------------------------------------------------------------------ |
| `owner`   | The owner of the package.                                          |
| `group`   | Optional: Everything, e.g. empty, `el7`, `rocky/el9`, `test/fc38`. |

Example request using HTTP Basic authentication:

```shell
# without a group
curl --user your_username:your_password_or_token \
     --upload-file path/to/file.rpm \
     https://forgejo.example.com/api/packages/testuser/rpm/upload
# with the group 'centos/el7'
curl --user your_username:your_password_or_token \
     --upload-file path/to/file.rpm \
     https://forgejo.example.com/api/packages/testuser/rpm/centos/el7/upload
```

If you are using 2FA or OAuth use a personal access token instead of the password.
You cannot publish a file with the same name twice to a package. You must delete the existing package version first.

The server responds with the following HTTP Status codes.

| HTTP Status Code  | Meaning                                                                              |
| ----------------- | ------------------------------------------------------------------------------------ |
| `201 Created`     | The package has been published.                                                      |
| `400 Bad Request` | The package is invalid.                                                              |
| `409 Conflict`    | A package file with the same combination of parameters exist already in the package. |

## Delete a package

To delete a Debian package perform a HTTP DELETE operation. This will delete the package version too if there is no file left.

```
DELETE https://forgejo.example.com/api/packages/{owner}/rpm/{group}/package/{package_name}/{package_version}/{architecture}
```

| Parameter         | Description                  |
| ----------------- | ---------------------------- |
| `owner`           | The owner of the package.    |
| `group`           | Optional: The package group. |
| `package_name`    | The package name.            |
| `package_version` | The package version.         |
| `architecture`    | The package architecture.    |

Example request using HTTP Basic authentication:

```shell
# without a group
curl --user your_username:your_token_or_password -X DELETE \
     https://forgejo.example.com/api/packages/testuser/rpm/package/test-package/1.0.0/x86_64

# with the group 'centos/el7'
curl --user your_username:your_token_or_password -X DELETE \
     https://forgejo.example.com/api/packages/testuser/rpm/centos/el7/package/test-package/1.0.0/x86_64
```

The server responds with the following HTTP Status codes.

| HTTP Status Code | Meaning                            |
| ---------------- | ---------------------------------- |
| `204 No Content` | Success                            |
| `404 Not Found`  | The package or file was not found. |

## Install a package

To install a package from the RPM registry, execute the following commands:

```shell
# use latest version
dnf install {package_name}
# use specific version
dnf install {package_name}-{package_version}.{architecture}
```
