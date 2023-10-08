---
title: 'PyPI Package Registry'
license: 'Apache-2.0'
origin_url: 'https://github.com/go-gitea/gitea/blob/abe8fe352711601fbcd24bf4505f7e0b81a93c5d/docs/content/usage/packages/pypi.en-us.md'
---

Publish [PyPI](https://pypi.org/) packages for your user or organization.

## Requirements

To work with the PyPI package registry, you need to use the tools [pip](https://pypi.org/project/pip/) to consume and [twine](https://pypi.org/project/twine/) to publish packages.

## Configuring the package registry

To register the package registry you need to edit your local `~/.pypirc` file. Add

```ini
[distutils]
index-servers = forgejo

[forgejo]
repository = https://forgejo.example.com/api/packages/{owner}/pypi
username = {username}
password = {password}
```

| Placeholder | Description                                                                                                                                  |
| ----------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `owner`     | The owner of the package.                                                                                                                    |
| `username`  | Your Forgejo username.                                                                                                                       |
| `password`  | Your Forgejo password. If you are using 2FA or OAuth use a [personal access token](../../api-usage/#authentication) instead of the password. |

## Publish a package

Publish a package by running the following command:

```shell
python3 -m twine upload --repository forgejo /path/to/files/*
```

The package files have the extensions `.tar.gz` and `.whl`.

You cannot publish a package if a package of the same name and version already exists. You must delete the existing package first.

## Install a package

To install a PyPI package from the package registry, execute the following command:

```shell
pip install --index-url https://{username}:{password}@forgejo.example.com/api/packages/{owner}/pypi/simple --no-deps {package_name}
```

| Parameter      | Description                                       |
| -------------- | ------------------------------------------------- |
| `username`     | Your Forgejo username.                            |
| `password`     | Your Forgejo password or a personal access token. |
| `owner`        | The owner of the package.                         |
| `package_name` | The package name.                                 |

For example:

```shell
pip install --index-url https://testuser:password123@forgejo.example.com/api/packages/testuser/pypi/simple --no-deps test_package
```

You can use `--extra-index-url` instead of `--index-url` but that makes you vulnerable to dependency confusion attacks because `pip` checks the official PyPi repository for the package before it checks the specified custom repository. Read the `pip` docs for more information.

## Supported commands

```
pip install
twine upload
```
