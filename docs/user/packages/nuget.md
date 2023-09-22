---
title: 'NuGet Package Registry'
license: 'Apache-2.0'
origin_url: 'https://github.com/go-gitea/gitea/blob/8d9e2d07f3f84a86265fdbe0ab7fcf63cc34ddbd/docs/content/usage/packages/nuget.en-us.md'
---

Publish [NuGet](https://www.nuget.org/) packages for your user or organization. The package registry supports the V2 and V3 API protocol and you can work with [NuGet Symbol Packages](https://docs.microsoft.com/en-us/nuget/create-packages/symbol-packages-snupkg) too.

## Requirements

To work with the NuGet package registry, you can use command-line interface tools as well as NuGet features in various IDEs like Visual Studio.
More information about NuGet clients can be found in [the official documentation](https://docs.microsoft.com/en-us/nuget/install-nuget-client-tools).
The following examples use the `dotnet nuget` tool.

## Configuring the package registry

To register the package registry you need to configure a new NuGet feed source:

```shell
dotnet nuget add source --name {source_name} --username {username} --password {password} https://forgejo.example.com/api/packages/{owner}/nuget/index.json
```

| Parameter     | Description                                                                                                                                  |
| ------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `source_name` | The desired source name.                                                                                                                     |
| `username`    | Your Forgejo username.                                                                                                                       |
| `password`    | Your Forgejo password. If you are using 2FA or OAuth use a [personal access token](../../api-usage/#authentication) instead of the password. |
| `owner`       | The owner of the package.                                                                                                                    |

For example:

```shell
dotnet nuget add source --name forgejo --username testuser --password password123 https://forgejo.example.com/api/packages/testuser/nuget/index.json
```

You can add the source without credentials and use the [`--api-key`](https://docs.microsoft.com/en-us/dotnet/core/tools/dotnet-nuget-push) parameter when publishing packages. In this case you need to provide a [personal access token](../../api-usage/#authentication).

## Publish a package

Publish a package by running the following command:

```shell
dotnet nuget push --source {source_name} {package_file}
```

| Parameter      | Description                        |
| -------------- | ---------------------------------- |
| `source_name`  | The desired source name.           |
| `package_file` | Path to the package `.nupkg` file. |

For example:

```shell
dotnet nuget push --source forgejo test_package.1.0.0.nupkg
```

You cannot publish a package if a package of the same name and version already exists. You must delete the existing package first.

### Symbol Packages

The NuGet package registry has build support for a symbol server. The PDB files embedded in a symbol package (`.snupkg`) can get requested by clients.
To do so, register the NuGet package registry as symbol source:

```
https://forgejo.example.com/api/packages/{owner}/nuget/symbols
```

| Parameter | Description                        |
| --------- | ---------------------------------- |
| `owner`   | The owner of the package registry. |

For example:

```
https://forgejo.example.com/api/packages/testuser/nuget/symbols
```

## Install a package

To install a NuGet package from the package registry, execute the following command:

```shell
dotnet add package --source {source_name} --version {package_version} {package_name}
```

| Parameter         | Description              |
| ----------------- | ------------------------ |
| `source_name`     | The desired source name. |
| `package_name`    | The package name.        |
| `package_version` | The package version.     |

For example:

```shell
dotnet add package --source forgejo --version 1.0.0 test_package
```

## Supported commands

```
dotnet add
dotnet nuget push
dotnet nuget delete
```
