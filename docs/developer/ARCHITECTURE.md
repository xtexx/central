---
title: Architecture
license: 'CC-BY-SA-4.0'
---

This document serves two purposes: it seeks to offer the reader a high-level grasp of how Forgejo operates, and it shows the reader where to find whatever sort of code. This is not a full explanation of how the code works; rather, it is intended to be concise.

It's encouraged to read this carefully, take a moment to let it sink in, find related code through your preferred symbol finder, and [reach out](https://matrix.to/#/#forgejo-development:matrix.org) when necessary.

## Bird's-eye view

Forgejo serves as a Git server and frontend; users can pull and push to git repositories and view commits and their diff, Forgejo handles the authentication and executes actions based on the context of the request, such as sending a notification if the pushed commit was part of a pull request or getting a diff (and syntax-highlighting it) between two commits if the compare page is requested. Forgejo doesn’t touch the git repository itself; it leaves that to the `git` binary.

Forgejo also provides a software development environment that does not rely on or interact with Git for the most part, which means that Forgejo handles the logic and stores information in databases. The environment includes features such as user profiles, issue reporting, and packages.

## Code map

### `models/`

All code related to databases resides in this directory.

Files in this directory include type definitions for tables and helper functions that execute SQL queries to retrieve and update data from the database.

### `modules/`

All code related to advanced logic that doesn't require database and/or git code resides in this directory; it isn't specific to Forgejo's context and could've been outsourced to a library.

Examples of modules that reside in this directory are markdown rendering, caching, and logging.

### `services/`

This directory contains advanced functions that require database and/or git code and implement a lot of non-database logic; it is a combination of the 'models' and 'modules' functions.

This category contains operations such as user deletion, Git repository mirroring, and mail.

### `web_src/`

The sources used to generate static assets used by the web UI (such as JavaScript, CSS, and SVGs) resides in this directory.

### `routers/`

All code related to handling network endpoints (Forgejo REST API, web routes, Forgejo Actions internal API etc.) resides in this directory.

Web and API routes are in separate files and don't share handlers with each other, but they do have common middleware. Handlers either retrieve data and prepare it for rendering or perform an action and report on its success.

### `templates/`

This directory contains the HTML templates for the frontend.

These templates are server-side rendered and use the [Go template](https://pkg.go.dev/html/template) syntax.

### `tests/`

This directory contains integration testing code.

The files prefixed with `api_` contain integration tests for API routes, while those without are mostly integration tests for web routes.

Integration tests ensure that the behavior of the entire program is correct, which usually means that they indirectly test the behavior of multiple functions and their logic together as one behavior.

### Unit tests

Unit tests are implemented in `<filename>_test.go_` for the corresponding `<filename>.go` code. Not all files will have unit tests.

They test the expected result and behavior of the function.
