---
title: 'Branch and tag protection'
license: 'Apache-2.0'
origin_url: 'https://github.com/go-gitea/gitea/blob/faa28b5a44912f1c63afddab9396bae9e6fe061c/docs/content/doc/usage/protected-tags.en-us.md'
---

## Protected branches

Protected branches enforce restrictions such as force pushing or
merging unless a given number of approval are obtained on a pull
request.

To protect a branch, you need to go to the repository’s **Settings** >
**Branch** page and add a new rule.

![Add a new rule](../../../../images/v1.20/user/protection/branch-protect.png)

The name of the branch can be a glob where / is the separator and **
spans accross separators. For instance `main`, `release/**`or`precious\*`.

If two rules apply to the same branch, the one that has no glob takes
precedence.

## Protected tags

Protected tags allow control over who has permission to create or update Git tags. Each rule allows you to match either an individual tag name, or use an appropriate pattern to control multiple tags at once.

### Setting up protected tags

To protect a tag, you need to follow these steps:

1. Go to the repository’s **Settings** > **Tags** page.
1. Type a pattern to match a name. You can use a single name, a [glob pattern](https://pkg.go.dev/github.com/gobwas/glob#Compile) or a regular expression.
1. Choose the allowed users and/or teams. If you leave these fields empty no one is allowed to create or modify this tag.
1. Select **Save** to save the configuration.

### Pattern protected tags

The pattern uses [glob](https://pkg.go.dev/github.com/gobwas/glob#Compile) or regular expressions to match a tag name. For regular expressions you need to enclose the pattern in slashes.

Examples:

| Type  | Pattern Protected Tag    | Possible Matching Tags                  |
| ----- | ------------------------ | --------------------------------------- |
| Glob  | `v*`                     | `v`, `v-1`, `version2`                  |
| Glob  | `v[0-9]`                 | `v0`, `v1` up to `v9`                   |
| Glob  | `*-release`              | `2.1-release`, `final-release`          |
| Glob  | `forgejo`                | only `forgejo`                          |
| Glob  | `*forgejo*`              | `forgejo`, `2.1-forgejo`, `1_forgejo-r` |
| Glob  | `{v,rel}-*`              | `v-`, `v-1`, `v-final`, `rel-`, `rel-x` |
| Glob  | `*`                      | matches all possible tag names          |
| Regex | `/\Av/`                  | `v`, `v-1`, `version2`                  |
| Regex | `/\Av[0-9]\z/`           | `v0`, `v1` up to `v9`                   |
| Regex | `/\Av\d+\.\d+\.\d+\z/`   | `v1.0.17`, `v2.1.0`                     |
| Regex | `/\Av\d+(\.\d+){0,2}\z/` | `v1`, `v2.1`, `v1.2.34`                 |
| Regex | `/-release\z/`           | `2.1-release`, `final-release`          |
| Regex | `/forgejo/`              | `forgejo`, `2.1-forgejo`, `1_forgejo-r` |
| Regex | `/\Aforgejo\z/`          | only `forgejo`                          |
| Regex | `/^forgejo$/`            | only `forgejo`                          |
| Regex | `/\A(v\|rel)-/`          | `v-`, `v-1`, `v-final`, `rel-`, `rel-x` |
| Regex | `/.+/`                   | matches all possible tag names          |
