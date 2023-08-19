---
title: 'Helm Chart Registry'
license: 'Apache-2.0'
origin_url: 'https://github.com/go-gitea/gitea/blob/faa28b5a44912f1c63afddab9396bae9e6fe061c/docs/content/doc/usage/packages/helm.en-us.md'
---

Publish [Helm](https://helm.sh/) charts for your user or organization.

## Requirements

To work with the Helm Chart registry use a simple HTTP client like `curl` or the [`helm cm-push`](https://github.com/chartmuseum/helm-push/) plugin.

## Publish a package

Publish a package by running the following command:

```shell
curl --user {username}:{password} -X POST --upload-file ./{chart_file}.tgz https://forgejo.example.com/api/packages/{owner}/helm/api/charts
```

or with the `helm cm-push` plugin:

```shell
helm repo add  --username {username} --password {password} {repo} https://forgejo.example.com/api/packages/{owner}/helm
helm cm-push ./{chart_file}.tgz {repo}
```

| Parameter    | Description                                                                                                                                  |
| ------------ | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `username`   | Your Forgejo username.                                                                                                                       |
| `password`   | Your Forgejo password. If you are using 2FA or OAuth use a [personal access token](../../api-usage/#authentication) instead of the password. |
| `repo`       | The name for the repository.                                                                                                                 |
| `chart_file` | The Helm Chart archive.                                                                                                                      |
| `owner`      | The owner of the package.                                                                                                                    |

## Install a package

To install a Helm char from the registry, execute the following command:

```shell
helm repo add  --username {username} --password {password} {repo} https://forgejo.example.com/api/packages/{owner}/helm
helm repo update
helm install {name} {repo}/{chart}
```

| Parameter  | Description                                       |
| ---------- | ------------------------------------------------- |
| `username` | Your Forgejo username.                            |
| `password` | Your Forgejo password or a personal access token. |
| `repo`     | The name for the repository.                      |
| `owner`    | The owner of the package.                         |
| `name`     | The local name.                                   |
| `chart`    | The name Helm Chart.                              |
