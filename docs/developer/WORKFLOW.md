---
title: Development workflow
license: 'CC-BY-SA-4.0'
---

Forgejo is a set of commits applied to the Gitea development branch and the stable branches. On a regular basis those commits are cherry-picked and modified if necessary to keep working. All Forgejo commits are merged into a branch from which binary releases and packages are created and distributed. The development workflow is a set of conventions Forgejo developers are expected to follow to work together.

## Naming conventions

### Development

- Gitea: `main`
- Forgejo: `forgejo`
- Feature branches: `forgejo-feature-name`

### Stable

- Gitea: `release/vX.Y`
- Forgejo: `vX.Y/forgejo`
- Feature branches: `vX.Y/forgejo-feature-name`

### Branches history

Before cherry-picking on top of Gitea, all branches are copied to `soft-fork/YYYY-MM-DD/<branch>` for safekeeping. Older `soft-fork/*/<branch>` branches are converted into references under the same name. Similar to how pull requests store their head, they do not clutter the list of branches but can be retrieved if needed with `git fetch +refs/soft-fork/*:refs/soft-fork/*`. Tooling to automate this archival process [is available](https://codeberg.org/forgejo-contrib/soft-fork-tools/src/branch/master/README.md#archive-branches).

## Cherry-picking

### _Feature branches_

On a weekly basis all of _Forgejo_ commits are cherry-picked on top of
the latest Gitea development branch. It starts like this:

- the `forgejo-ci` branch is `reset --hard` with _Gitea_ main
- all the commits it contained are `cherry-pick -x` and conflicts resolved
- the `forgejo-ci` branch is force pushed after the CI confirms it is sane

The same is done for the `forgejo-development` branch which is based on
`forgejo-ci` and the commits it contains are similarly `cherry-pick
-x`.

And finally the same is done for each _Feature branch_ until they all pass
the CI.

### Development branch

Once all _Feature branches_ are ready, the `forgejo` branch is `reset --hard`
with _Gitea_ main, all _Feature branches_ are merged into it
and it is force pushed.

### Stable branches

The stable branches are not force pushed because they would no
longer contain the tags from which releases were made. Instead, the following is done:

- The _Gitea_ commits are cherry-picked
- If there is a conflict
  - revert the _Forgejo_ commit that caused the conflict
  - cherry-pick the _Gitea_ commit
  - cherry-pick the _Forgejo_ commit back and resolve the conflict

This ensures the conflict resolution is documented in the relevant
_Forgejo_ commit. The conflict must not be resolved in the _Gitea_
commit because there would be no convenient way to know why and how it
happened when browsing the commit history.

To improve the readability of the git history, pull requests to stable
branches are rebased on top of the branch instead of being merged. It
saves one merge commit and creates a linear history.

## Feature branches

All _Feature branches_ are based on the forgejo-development branch which provides development tools and documentation. The `forgejo-development` branch is based on the forgejo-ci branch which provides the CI configuration.

The purpose of each _Feature branch_ is documented below:

### General purpose

- [forgejo-ci](https://codeberg.org/forgejo/forgejo/src/branch/forgejo-ci), based on [main](https://codeberg.org/forgejo/forgejo/src/branch/main)

  CI configuration, including the release process.

- [forgejo-development](https://codeberg.org/forgejo/forgejo/src/branch/forgejo-development) based on [forgejo-ci](https://codeberg.org/forgejo/forgejo/src/branch/forgejo-ci)

  Forgejo development tools, tests etc. that do not fit in a feature branch or that are used by multiple feature branches. The commits titles should be prefixed with
  a string that reflects their purpose such as `[DOCS]`, `[DB]`, `[TESTS]` etc.

  The database migrations of all feature branches must be in the `forgejo-development` branch. This is a requirement to ensure they do not conflict with each other
  and happen in sequence.

### Dependency

- [forgejo-dependency](https://codeberg.org/forgejo/forgejo/src/branch/forgejo-dependency) based on [forgejo-development](https://codeberg.org/forgejo/forgejo/src/branch/forgejo-development)

  Each commit is prefixed with the name of dependency in uppercase, for instance **[GOTH]** or **[GITEA]**. They are standalone and implement either a bug fix or a feature that is in the process of being contributed to the dependency. It is better to contribute directly to the dependency instead of adding a commit to this branch but it is sometimes not possible, for instance when someone does not have a GitHub account. The author of the commit is responsible for rebasing and resolve conflicts. The ultimate goal of this branch is to be empty and it is expected that a continuous effort is made to reduce its content so that the technical debt it represents does not burden Forgejo long term.

### [Privacy](https://codeberg.org/forgejo/forgejo/issues?labels=83271)

- [forgejo-privacy](https://codeberg.org/forgejo/forgejo/src/branch/forgejo-privacy) based on [forgejo-development](https://codeberg.org/forgejo/forgejo/src/branch/forgejo-development)

  Customize Forgejo to have more privacy.

### Moderation

- [forgejo-moderation](https://codeberg.org/forgejo/forgejo/src/branch/forgejo-moderation) based on [forgejo-development](https://codeberg.org/forgejo/forgejo/src/branch/forgejo-development)

  Add moderation tooling for users and admins.

### Branding

- [forgejo-branding](https://codeberg.org/forgejo/forgejo/src/branch/forgejo-branding) based on [forgejo-development](https://codeberg.org/forgejo/forgejo/src/branch/forgejo-development)

  Replace hardcoded dependencies branding with a Forgejo equivalent.

### [Internationalization](https://codeberg.org/forgejo/forgejo/issues?labels=82637)

- [forgejo-i18n](https://codeberg.org/forgejo/forgejo/src/branch/forgejo-i18n) based on [forgejo-development](https://codeberg.org/forgejo/forgejo/src/branch/forgejo-development)

  Internationalization and localization support.

### [Accessibility](https://codeberg.org/forgejo/forgejo/issues?labels=81214)

- [forgejo-a11y](https://codeberg.org/forgejo/forgejo/src/branch/forgejo-a11y) based on [forgejo-development](https://codeberg.org/forgejo/forgejo/src/branch/forgejo-development)

  Accessibility improvements.

### [Federation](https://codeberg.org/forgejo/forgejo/issues?labels=79349)

- [forgejo-federation](https://codeberg.org/forgejo/forgejo/src/branch/forgejo-federation) based on [forgejo-development](https://codeberg.org/forgejo/forgejo/src/branch/forgejo-development)

  Federation support.

- [forgejo-f3](https://codeberg.org/forgejo/forgejo/src/branch/forgejo-f3) based on [forgejo-development](https://codeberg.org/forgejo/forgejo/src/branch/forgejo-development)

  [F3](https://f3.forgefriends.org) support.

## Pull requests and feature branches

Most people who are used to contributing will be familiar with the workflow of sending a pull request against the default branch. When that happens the reviewer may ask to change the base branch to the appropriate _Feature branch_ instead. If the pull request does not fit in any _Feature branch_, the reviewer needs to make decision to either:

- Decline the pull request because it is best contributed to the relevant dependency
- Create a new _Feature branch_

## Granularity

_Feature branches_ can contain a number of commits grouped together, for instance for branding the documentation, the landing page and the footer. It makes it convenient for people working on that topic to get the big picture without browsing multiple branches. Creating a new _Feature branch_ for each individual commit, while possible, is likely to be difficult to work with.

Observing the granularity of the existing _Feature branches_ is the best way to figure out what works and what does not. It requires adjustments from time to time depending on the number of contributors and the complexity of the Forgejo codebase.

## Testing

Software is always tested with different methods which are more or less costly. Forgejo has a lot of technical debt and large portions of the codebase are very difficult to test. A [reasonable effort should be made](https://codeberg.org/forgejo/governance/src/branch/main/PullRequestsAgreement.md) to improve the situation whenever a change is proposed.

### Automated tests

They do not require manual intervention and can be run as often as necessary from the CI.

Ideally all aspects of a code can be verified with unit tests (e.g. `make unit-test-coverage`). Integration tests may involve third party components such as a database (e.g. `make test-sqlite`).

Tests that require launching a Forgejo instance are found in the [end-to-end repository](https://code.forgejo.org/forgejo/end-to-end).

It is possible to run them on a pull request by setting the `run-end-to-end-tests` label. It will [trigger a workflow](https://codeberg.org/forgejo/forgejo/src/branch/forgejo/.forgejo/workflows/cascade-setup-end-to-end.yml) that:

- builds a Forgejo binary including the pull request and uploads it as [an artifact](https://forgejo.org/docs/next/user/actions/#artifacts) of the PR
- creates a pull request in the [end-to-end repository](https://code.forgejo.org/forgejo/end-to-end) against the [forgejo-pr branch](https://code.forgejo.org/forgejo/end-to-end/src/branch/forgejo-pr)
- run [a workflow](https://code.forgejo.org/forgejo/end-to-end/src/branch/forgejo-pr/.forgejo/workflows/pr.yml) using the Forgejo binary found in the PR artifact

### Manual tests

When the test infrastructure is lacking or the test to verify a change (such as a oneliner) is out of proportion with the effort to create and automated test (as a few days of work may be needed if this is in the web UI), the instructions to manually verify the change is good must be documented in the [forgejo-manual-testing](https://codeberg.org/forgejo/forgejo-manual-testing) repository.

The person who wrote the instructions is expected to run them on a regular basis to ensure there are no regressions. **If this is not done, the regression will always happen over time and will be discovered by end users which by far the [most costly and frustrating method of testing](https://codeberg.org/forgejo/discussions/issues/103).**
