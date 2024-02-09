---
title: Development workflow
license: 'CC-BY-SA-4.0'
---

All Forgejo commits are merged into the `forgejo` branch from which binary releases and packages are created and distributed. The development workflow is a set of conventions Forgejo developers are expected to follow to work together.

## Naming conventions

- development: `forgejo`
- stable releases: `vX.Y/forgejo`

## Cherry-picking

Gitea branches are regularly scrubbed, and changes useful to Forgejo are cherry picked.

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
