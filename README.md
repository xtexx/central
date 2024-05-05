# Forgejo Documentation

This is the documentation for [Forgejo](https://codeberg.org/forgejo/forgejo)
and is published [on the Forgejo website](https://forgejo.org/docs/next).

The main development branch of this repo is the
[`next`](https://codeberg.org/forgejo/docs/src/branch/next) branch,
which documents the version that is currently being developed.

Each time a new major version of Forgejo is released,
a new branch will be created in this repo to document the stable release.

Current release branches are as follows:

- [`next`](https://codeberg.org/forgejo/docs/src/branch/next)
- [`v7.0`](https://codeberg.org/forgejo/docs/src/branch/v7.0)
- [`v1.21`](https://codeberg.org/forgejo/docs/src/branch/v1.21)
- [`v1.20`](https://codeberg.org/forgejo/docs/src/branch/v1.20)
- [`v1.19`](https://codeberg.org/forgejo/docs/src/branch/v1.19)

Documentation content lives in the `docs` directory, and images in the `docs/_images` subdirectory.

## Contributing

### Tooling

It is possible to simply edit the documentation with a text editor and [send PRs](#pull-requests) without using any other tooling.
[Lints](#linting-and-formatting) will be run when PRs are sent to ensure that content and code comply with our stylistic rules.

However, several tools are available to run locally to help ensure that content is [formatted](#linting-and-formatting) appropriately before committing,
as well as to [preview](#previewing-changes) your changes on a local copy of the Forgejo website.

#### Getting set up

To run the tools used in this repo you will need [NodeJS](https://nodejs.org/en/download) on your machine.
The required version will change over time, but in general it is recommended to use at least the latest LTR release.

You'll also need [PNPM](https://pnpm.io/installation). The easiest way to install it on most systems is to use the
command `corepack enable`, which is part of NodeJS. However depending on your system you may prefer to use a package manager.

Once you have Node and PNPM installed, just run `pnpm install` from the root of this repo to fetch the dependencies
and set up the Git [pre-commit hook](#pre-commit-hook).

```shell
# Install/enable PNPM
corepack enable

# Clone this repo (or your fork of it)
git clone git@codeberg.org:forgejo/docs
cd docs

# Install the dependencies
pnpm install
```

Every time you `pull` the repo or `checkout` a different branch, you should run `pnpm install` again to update the dependencies.

#### Previewing changes

```shell
pnpm run preview
```

This command will clone the [website repo](https://codeberg.org/forgejo/forgejo)
and launch a local development server. The current docs branch will be opened in the browser.

The URL to the documentation preview looks like
`http://localhost:4321/docs/{branch}/` where `{branch}` is the
name of the current branch from which the preview is run.

Modifications can be made to the docs while the dev server is running, and the preview will live-reload.

#### Linting and formatting

We use two linters to check that all content is formatted in a consistent way.
Most of the rules are checked using [remark-lint](https://github.com/remarkjs/remark-lint),
whilst some stylistic consistency is enforced using [Prettier](https://prettier.io/).

To run both linters and display any warnings in the terminal, use the following command:

```shell
pnpm run lint
```

Prettier is also able to automatically format the code according to its rules.
To do so, use the following command.
Be aware that it can occasionally break things, so be sure to check what it changes.

```shell
pnpm run format:prettier
```

There is currently no way to automatically format the code to according to the rules configured for `remark-lint`,
however the pre-commit hook should prevent badly-formatted content from being committed.

#### Pre-commit hook

Both of the above linting and formatting commands are run automatically on commit
using a Git `pre-commit` hook which is set up when running `pnpm install`.
This attempts to prevent badly-formatted content from being committed.

In the event that the pre-commit hook is skipped or fails to run, badly-formatted
content will also be caught by the CI, preventing the PR from being merged.

### Pull Requests

PRs should usually be sent against the [`next`](https://codeberg.org/forgejo/docs/src/branch/next) branch.
Sometimes it will be appropriate to send a PR against a specific release branch if the changes only affect that release.

Most changes should either be sent as a _single commit per PR_, or should be squashed before merging.
_Fast-forwarding is the preferred merge strategy._
Changes can then be [backported](#backports) (or if appropriate frontported) by cherry-picking.

Rarely, it will make sense to create a feature branch containing a series of commits that will
be merged instead of squashing and fast-forwarding.
Such a feature branch can then be merged into multiple versions of the docs if appropriate.
In this case, the feature branch should usually be taken from the last common ancestor of all of the
version branches into which it will potentially be merged.

#### Backports

If a PR is meant to be backported to a stable branch, it must be
labelled with `backport/v7.0`, `backport/v1.21`, etc.

### Content guidelines

#### Links

All internal links within the documentation content should be relative to each page's path
at the `https://forgejo.org/docs/{{version}}/` URL.
File extensions (`.md`) should not be included, and every URL should end with a trailing slash.
Look at existing links for examples.

#### Images

Images should be stored in the `docs/_images/` directory, and should be referenced by their path relative to the markdown files where they are used.

Use 1280 x 800 as dimensions for screenshots that show the whole page.

Consistency is improved by having a standard window size for
screenshots to ensure things are shown at roughly the same scale and
layout. 1280 x 800 is close to the largest size where there is no
extraneous padding at the sides.

When taking a screenshot one can use "responsive design mode" in Firefox
(Cmd+Alt+M on macOS, Ctrl+Shift+M on GNU/Linux) which allows you to enter
the viewport size in the toolbar at the top. It also has a handy
screenshot button.

## Code of Conduct

All contributors are required to abide by the [Forgejo Code of Conduct](https://codeberg.org/forgejo/code-of-conduct).

Feel free to reach out to the [moderation team](https://codeberg.org/forgejo/governance/src/branch/main/TEAMS.md#moderation)
in case of any conflicts.

## License

The documentation content originates from several different sources and each page has a different license.
Please check the `license` frontmatter key near the top of each file to see the relevant license.

Where not otherwise stated, content is licensed under the
[Creative Commons Attribution-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-sa/4.0/).
