---
title: 'Compiling from source'
license: 'Apache-2.0'
origin_url: 'https://github.com/go-gitea/gitea/blob/8d9e2d07f3f84a86265fdbe0ab7fcf63cc34ddbd/docs/content/installation/from-source.en-us.md'
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
on the executable path. If you don't add the go bin directory to the
executable path, you will have to manage this yourself.

**Note 2**: Go version 1.20 or higher is required. However, it is recommended to
obtain the same version as the [continuous integration](https://codeberg.org/forgejo/forgejo/src/branch/forgejo/.forgejo/workflows/testing.yml).

### Download

First, we must retrieve the source code. Since, the advent of go modules, the
simplest way of doing this is to use Git directly as we no longer have to have
Forgejo built from within the GOPATH.

```bash
git clone https://codeberg.org/forgejo/forgejo
```

Decide which version of Forgejo to build and install. Currently, there are
multiple options to choose from. The `forgejo` branch represents the current
development version.

To work with tagged releases, the following commands can be used:

```bash
git branch -a
git checkout v1.21.2-0
```

To build Forgejo from source at a specific tagged release (like v1.21.2-0), list the
available tags and check out the specific tag.

List available tags with the following.

```bash
git tag -l
git checkout v1.21.2-0
```

### Build

To build from source, the following programs must be present on the system:

- `go` v1.20 or higher, see [here](https://golang.org/dl/)
- `node` 20 or higher with `npm`, see [here](https://nodejs.org/en/download/current)
- `make`

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
tags are: `TAGS="bindata sqlite sqlite_unlock_notify"`. The simplest
recommended way to build from source is therefore:

```bash
TAGS="bindata sqlite sqlite_unlock_notify" make build
```

The `build` target is split into two sub-targets:

- `make backend` which requires [Go v1.20](https://golang.org/dl/) or greater.
- `make frontend` which requires [Node.js 20](https://nodejs.org/en/download/current) or greater.

If pre-built frontend files are present it is possible to only build the backend:

```bash
TAGS="bindata" make backend
```

Webpack source maps are by default enabled in development builds and disabled in production builds. They can be enabled by setting the `ENABLE_SOURCEMAP=true` environment variable.

### Test

After following the steps above, a `forgejo` binary will be available in the working directory.
It can be tested from this directory or moved to a directory with test data. When Forgejo is
launched manually from command line, it can be killed by pressing `Ctrl + C`.

```bash
./forgejo web
```

To run and continuously rebuild when the source files change:

```bash
make watch
```

> **NOTE:** do not set the `bindata` tag such as in `TAGS="bindata" make watch` or the browser may fail to load pages with an error like `Failed to load asset`
