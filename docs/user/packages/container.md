---
title: 'Container Registry'
license: 'Apache-2.0'
origin_url: 'https://github.com/go-gitea/gitea/blob/e865de1e9d65dc09797d165a51c8e705d2a86030/docs/content/usage/packages/container.en-us.md'
---

Publish [Open Container Initiative](https://opencontainers.org/) compliant images for your user or organization.
The container registry follows the OCI specs and supports all compatible images like [Docker](https://www.docker.com/) and [Helm Charts](https://helm.sh/).

## Requirements

To work with the Container registry, you can use the tools for your specific image type.
The following examples use the `docker` client.

## Login to the container registry

To push an image or if the image is in a private registry, you have to authenticate:

```shell
docker login forgejo.example.com
```

If you are using 2FA or OAuth use a [personal access token](../../api-usage/#authentication) instead of the password.

## Image naming convention

Images must follow this naming convention:

`{registry}/{owner}/{image}`

When building your docker image, using the naming convention above, this looks like:

```shell
# build an image with tag
docker build -t {registry}/{owner}/{image}:{tag} .
# name an existing image with tag
docker tag {some-existing-image}:{tag} {registry}/{owner}/{image}:{tag}
```

where your registry is the domain of your gitea instance (e.g. gitea.example.com).
For example, these are all valid image names for the owner `testuser`:

`forgejo.example.com/testuser/myimage`

`forgejo.example.com/testuser/my-image`

`forgejo.example.com/testuser/my/image`

**NOTE:** The registry only supports case-insensitive tag names. So `image:tag` and `image:Tag` get treated as the same image and tag.

## Push an image

Push an image by executing the following command:

```shell
docker push forgejo.example.com/{owner}/{image}:{tag}
```

| Parameter | Description             |
| --------- | ----------------------- |
| `owner`   | The owner of the image. |
| `image`   | The name of the image.  |
| `tag`     | The tag of the image.   |

For example:

```shell
docker push forgejo.example.com/testuser/myimage:latest
```

For more information please check the [docker push](https://docs.docker.com/engine/reference/commandline/push/) documentation page.

## Pull an image

Pull an image by executing the following command:

```shell
docker pull forgejo.example.com/{owner}/{image}:{tag}
```

| Parameter | Description             |
| --------- | ----------------------- |
| `owner`   | The owner of the image. |
| `image`   | The name of the image.  |
| `tag`     | The tag of the image.   |

For example:

```shell
docker pull forgejo.example.com/testuser/myimage:latest
```
