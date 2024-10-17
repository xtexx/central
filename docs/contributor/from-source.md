---
title: 'Compiling from source'
license: 'Apache-2.0'
origin_url: 'https://github.com/go-gitea/gitea/blob/e865de1e9d65dc09797d165a51c8e705d2a86030/docs/content/installation/from-source.en-us.md'
---

## Installation from source

You should [install go](https://golang.org/doc/install) and set up your go
environment correctly. In particular, it is recommended to set the `$GOPATH`
environment variable and to add the go bin directory or directories
`${GOPATH//://bin:}/bin` to the `$PATH`. See the Go wiki entry for
[GOPATH](https://github.com/golang/go/wiki/GOPATH).

Next, [install Node.js with npm](https://nodejs.org/en/download/current) which is
required to build the JavaScript and CSS files. The minimum supported Node.js
version is 20.

**Note**: When executing make tasks that require external tools, like
`make misspell-check`, Forgejo will automatically download and build these as
necessary. To be able to use these, you must have the `"$GOPATH/bin"` directory
on the executable path.

**Note 2**: Go version 1.23 or higher is required. However, it is recommended to
obtain the same version as the [continuous integration](https://codeberg.org/forgejo/forgejo/src/branch/forgejo/.forgejo/workflows/testing.yml).

**Note 3**: If you want to avoid installing build dependencies manually,
you can also [build the Docker image](#build-the-docker-image), which runs
the build process in a Docker image containing all the required dependencies.

### Download

First, we must retrieve the source code.

```bash
git clone https://codeberg.org/forgejo/forgejo
```

Decide which version of Forgejo to build and install. Currently, there are
multiple options to choose from. The `forgejo` branch represents the current
development version.

To work with tagged releases, the following commands can be used:

```bash
git branch -a
git checkout v7.0.3
```

To build Forgejo from source at a specific tagged release (like v7.0.3), list the
available tags and check out the specific tag.

List available tags with the following.

```bash
git tag -l
git checkout v7.0.3
```

### Build

To build from source, the following programs must be present on the system:

- `go` v1.23 or higher, see [here](https://golang.org/dl/)
- `node` 20 or higher with `npm`, see [here](https://nodejs.org/en/download/current)
- `make`

There are a number of useful `make` targets, only some of which are documented here.
They can all be displayed with:

```sh
$ make help
Make Routines:
 - ""                               equivalent to "build"
 - build                            build everything
 - frontend                         build frontend files
 - backend                          build backend files
 - watch                            watch everything and continuously rebuild
 - watch-frontend                   watch frontend files and continuously rebuild
 - watch-backend                    watch backend files and continuously rebuild
...
```

Depending on requirements, the following build tags can be included.

- `bindata`: Build a single monolithic binary, with all assets included. Required for production build.
- `sqlite sqlite_unlock_notify`: Enable support for a
  [SQLite3](https://sqlite.org/) database. Suggested only for small
  installations.
- `pam`: Enable support for PAM (Linux Pluggable Authentication Modules). Can
  be used to authenticate local users or extend authentication to methods
  available to PAM.

Using the `bindata` build tag is required for production
deployments. You could exclude `bindata` when you are
developing/testing Forgejo or able to separate the assets correctly.

To include all assets, use the `bindata` tag:

```bash
TAGS="bindata" make build
```

In the default release build of the continuous integration system, the build
tags are: `TAGS="bindata timetzdata sqlite sqlite_unlock_notify"`. The simplest
recommended way to build from source is therefore:

```bash
TAGS="bindata timetzdata sqlite sqlite_unlock_notify" make build
```

The `build` target is split into two sub-targets:

- `make backend` which requires [Go v1.22](https://golang.org/dl/) or greater.
- `make frontend` which requires [Node.js 20](https://nodejs.org/en/download/current) or greater.

If pre-built frontend files are present it is possible to only build the backend:

```bash
TAGS="bindata" make backend
```

Webpack source maps are by default enabled in development builds and disabled in production builds. They can be enabled by setting the `ENABLE_SOURCEMAP=true` environment variable.

### Build the Docker image

To build Forgejo's Docker image, you need to have Docker and the Docker Buildx plugin installed.
You can build the Docker image with:

```bash
docker buildx build --output type=docker --tag forgejo:mybuild .
```

This will run the entire build process in a Docker container with the required dependencies.
You can also supply a tag during the build process with the `-t` option, to make it easier to publish or run the image later.

### Testing

See [the section dedicated to testing](../testing/).
