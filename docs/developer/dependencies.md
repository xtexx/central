---
title: Dependency management
license: 'CC-BY-SA-4.0'
---

Forgejo relies on hundreds of Free Software components and they all need to be updated on a regular basis, with appropriate tooling and methods.

# Releases

Software referenced by a release (even if such a release is the hash of a commit). They are listed in the [dependency dashboard](https://codeberg.org/forgejo/forgejo/issues/2779) which is updated by [renovate](https://github.com/renovatebot/renovate) from [the renovate.json configuration file](https://codeberg.org/forgejo/forgejo/src/branch/forgejo/renovate.json).

## Decision to upgrade

An upgrade is justified if:

- it is beneficial to Forgejo
- the risk of regression is low compared to the benefit

There is no need to upgrade if there is no indication that it is beneficial to Forgejo.

## Reviewing renovate pull requests

Pull [requests are opened](https://codeberg.org/forgejo/forgejo/pulls?poster=165503) when an upgrade is available and the decision to merge (positive review) or not (request for change review) depends on what the upgrade offers. The history of past upgrades can be browsed by looking for PR with the same title (e.g. [happy-dom upgrades](https://codeberg.org/forgejo/forgejo/pulls?q=Update+dependency+happy-dom)).

- The PR contains information about the release. If it does not, it has detailed references that can be used to browse the commits in the dependency source repository and figure out what the changes are.
- The comment of the review:
  - explains the decision (needed, not needed)
  - explains why the change has an impact on Forgejo
- If the upgrade is needed, user visible changes must be included in the draft release notes for the upcoming release. See [this upgrade for an example](https://codeberg.org/forgejo/forgejo/pulls/3724/files).
- Security fix and important bug fixes are backported to the stable releases.

Note that renovate will keep a few (see `prConcurrentLimit` in [renovate.json](https://codeberg.org/forgejo/forgejo/src/branch/forgejo/renovate.json)) pull request open at any given time. If no decision is made, newer upgrades will accumulate in the backlog visible in the [dashboard](https://codeberg.org/forgejo/forgejo/issues/2779).

The [release team](https://codeberg.org/forgejo/governance/src/branch/main/TEAMS.md#releases) looks after the pull requests, to the extent that they can be tested automatically. If manual testing is required (because there is no test coverage for the part of the code that would be impacted by an upgrade), a review will be requested from the people who have the required expertise to either improve the test coverage or come up with a manual test procedure to be repeated.

## Tuning a software upgrade

There is no uniformity in how software is released and they call for different strategies to deal with upgrades:

- **grouping related software**.

  When the decision to upgrade applies to a number of related software, it is less noisy to have them all upgraded in a single PR rather than a number of individual PRs. Such dependencies can be grouped together.

  - **using a renovate [group preset](https://docs.renovatebot.com/presets-group/):** e.g. `group:linters` include `eslint`, `eslint-plugin-array-func`, `eslint-plugin-github` etc. See also [an example PR](https://codeberg.org/forgejo/forgejo/pulls/3921).
  - **creating a new group:**

  ```json
  {
    "description": "Group golang packages",
    "matchDepNames": [
  	"go",
  	"golang",
  	"docker.io/golang",
  	"docker.io/library/golang"
    ],
    "groupName": "golang packages"
  },
  ```

- **release on every commit or so**.

  There are usually no release notes and there is no notion of release ([monaco-editor](https://github.com/microsoft/monaco-editor/tags)) which may lead to frequent proposals to upgrade. It is similar to software that it tagged with a commit hash instead of a version, either because it does not publish versions ([go-ap](https://github.com/go-ap/activitypub)) or because a particular bug fix is needed before the release is available ([go-rpmutils](github.com/sassoftware/go-rpmutils)).

  - control the upgrade frequency with `schedule` (e.g. `schedule:quarterly` for [pprof](https://github.com/google/pprof)).
  - impose a delay with `minimumReleaseAge` (e.g. `monaco-editor` upgrades are considered no more frequently than once a month).
  - require dashboard approval with `dependencyDashboardApproval` (e.g. `go-ap` upgrades will never be proposed unless manually required from the [dashboard](https://codeberg.org/forgejo/forgejo/issues/2779).

- **automerge CI dependencies**.

  The dependencies that are exclusively used in the CI and demonstrated to work as expected when it passes can be merged automatically. They are listed in [renovate.json](https://codeberg.org/forgejo/forgejo/src/branch/forgejo/renovate.json)) in the `Automerge some packages when CI succeeds` stanza as follows.

  - **extends:** if the software is included in a known renovate package preset (e.g. ["packages:linters"](https://docs.renovatebot.com/presets-packages/#packageslinters)). Figuring out if that is the case requires looking at the output of a renovate run and analyzing the debug logs.
  - **matchDepNames:** to explicitly list the dependency (e.g. `markdownlint-cli`).
  - **matchPackagePrefixes:** if a range of CI related dependency happen to share the same prefix (e.g. `@playwright/`)

- **automerge patch releases**.

  When a software is known to be good at publishing quality patch releases (in the [semver](https://semver.org/spec/v2.0.0.html) sense), the proposed upgrades can be merged automatically. This can be done in a way similar to `vue` in [renovate.json](https://codeberg.org/forgejo/forgejo/src/branch/forgejo/renovate.json)).

  ```json
  {
    "matchDepNames": [
  	"vue"
    ],
    "separateMinorPatch": true
  },
  {
    "matchDepNames": ["vue"],
    "matchUpdateTypes": ["patch"],
    "automerge": true
  },
  ```

# Soft forks

## Permanent

- https://code.forgejo.org/forgejo/act is a set of commits on top of https://github.com/nektos/act

## Temporary

- https://code.forgejo.org/forgejo/download-artifact
- https://code.forgejo.org/forgejo/upload-artifact

# Cherry-picking

## lxc-helpers

Injects itself via [a workflow](https://code.forgejo.org/forgejo/lxc-helpers/src/branch/main/.forgejo/workflows/cascade-act.yml) in its dependencies.

## Gitea

Cherry-picked in the Forgejo codebase [on a regular basis](https://codeberg.org/forgejo/forgejo/pulls?q=week&labels=116080) using a [dedicated CLI tool](https://codeberg.org/forgejo/tools/src/branch/main/scripts/weekly-cherry-pick.sh).
