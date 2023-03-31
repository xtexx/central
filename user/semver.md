---
layout: '~/layouts/Markdown.astro'
title: Semantic version
license: 'CC-BY-SA-4.0'
---

[SemVer](https://semver.org/spec/v2.0.0.html) allows users to understand the scope of a software update at first glance, based on the following :

- Patch is increased for backwards-compatible bugfixes.
- Minor is increased for backwards-compatible new features.
- Major is increased for breaking changes.

_something_ could be :

- a command, an option or an argument, for a CLI ;
- a route path, a query parameter or a body property, for a REST API ;
- a text node, a button or a field, for a GUI.

Since Forgejo has all of the above, changes to all of those components should be taken into consideration when creating a new version number.

## Getting the Forgejo semantic version

As of Forgejo v1.19, there are two version numbering schemes:

- [Following the Gitea version](https://codeberg.org/forgejo/forgejo/src/branch/forgejo/CONTRIBUTING/RELEASE.md#release-numbering) which is not a semantic version
  - Used to name release files
  - Used for tagging releases
  - Displayed in the web interface
  - Returned by the `/api/v1/version` API endpoint
- Forgejo semantic version
  - Returned by the `/api/forgejo/v1/version` API endpoint

For instance, the semantic version for https://code.forgejo.org can be obtained with:

```shell
$ curl https://code.forgejo.org/api/forgejo/v1/version
{"version":"3.0.0+0-gitea-1.19.0"}
```

## Understanding the Forgejo semantic version

The structure of the version number is `<major>.<minor>.<patch>+<build>-gitea-<gitea version>` where:

- `<major>.<minor>.<patch>` is conformant to [Semantic Versioning 2.0.0](https://semver.org/#semantic-versioning-200)
- `<build>` is the release build number of an otherwise identical source
- `gitea-<gitea version>` is the Gitea version this Forgejo release depends on
