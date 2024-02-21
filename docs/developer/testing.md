---
title: 'Testing'
license: 'CC-BY-SA-4.0'
---

A [reasonable effort should be made to test changes](https://codeberg.org/forgejo/governance/src/branch/main/PullRequestsAgreement.md)
proposed to Forgejo.

## Running the tests from sources

To run automated frontend and backend tests:

```bash
make test
```

## Frontend tests

The [e2e](https://codeberg.org/forgejo/forgejo/src/branch/forgejo/tests/e2e/README.md) frontend tests are run with:

```sh
make 'test-e2e-sqlite'
# or, for individual tests
make 'test-e2e-sqlite#example.test'
```

They are based on [playwright](https://playwright.dev/) and will:

- Launch a Forgejo instance
- Populate it with data found in the `models/fixtures` directory
- Launch a browser (e.g. Firefox)
- Run JavaScript tests (e.g. tests/e2e/example.test.e2e.js)

> **NOTE:** make sure to [use a version of Node >= 20.11.1](https://github.com/microsoft/playwright/issues/29253)

### With VSCodium or VSCode

To debug a test, you can use "Playwright Test" for
[VScodium](https://open-vsx.org/extension/ms-playwright/playwright)
or [VSCode](https://marketplace.visualstudio.com/items?itemName=ms-playwright.playwright).
Before doing that you will need to manually start a Forgejo instance and populate it
with data from `models/fixtures` by running:

```sh
make TAGS='sqlite sqlite_unlock_notify' 'test-e2e-debugserver'
```

### CLI

Tests can also be individually run on an existing server as follows:

```sh
GITEA_URL=http://0.0.0.0:3000 npx playwright test tests/e2e/release.test.e2e.js
```

In this case the Forgejo instance must be manually prepared with a minimal
subset of the data found in the `models/fixtures` directory.

## Interactive testing

To run and continuously rebuild when the source files change:

```bash
TAGS='sqlite sqlite_unlock_notify' make watch
```

> **NOTE:** do not set the `bindata` tag such as in `TAGS="bindata" make watch` or the browser may fail to load pages with an error like `Failed to load asset`

## Manual run of the binary

After following the [steps to compile from source](../from-source/), a `forgejo` binary will be available
in the working directory.
It can be tested from this directory or moved to a directory with test data. When Forgejo is
launched manually from command line, it can be killed by pressing `Ctrl + C`.

```bash
./forgejo web
```

## Automated tests

### In the Forgejo repository

When a [pull request](https://codeberg.org/forgejo/forgejo/pulls) is opened,
it will run workflows found in the [.forgejo/workflows](https://codeberg.org/forgejo/forgejo/src/branch/forgejo/.forgejo/workflows)
directory.

### In the end-to-end repository

Some tests are best served by running Forgejo from a compiled binary,
for instance to verify the result of a workflow run by the [Forgejo runner](https://code.forgejo.org/forgejo/runner). They can be
run by adding the `run-end-to-end-test` label to the pull request. It will:

- compile a binary from the pull request
- open a pull request against the [end-to-end](https://code.forgejo.org/forgejo/end-to-end) repository
- use the compiled binary to run the tests
- report back failure or success

### Debugging locally

A workflow can be run locally by [installing the Forgejo runner](../../admin/actions/#installation) and using the command line:

```sh
forgejo-runner exec --workflows .forgejo/workflows/testing.yml
```

## Manual testing

When the change to be tested lacks the proper framework, the manual
test procedure must be documented and referenced in the
[manual testing repository](https://codeberg.org/forgejo/forgejo-manual-testing).
The tests it contains should be run on a regular basis to verify they keep working.

Changes that are associated with a manual test procedure should be
labeled ["manual test"](https://codeberg.org/forgejo/forgejo/pulls?labels=181437).

## No test

When a change is not tested, it should be labeled
["untested"](https://codeberg.org/forgejo/forgejo/pulls?labels=167348). The
rationale for the absence of test should be explained.
