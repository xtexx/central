# Forgejo Documentation

This is the documentation for [Forgejo](https://codeberg.org/forgejo/forgejo)
and is published [on the Forgejo website](https://forgejo.org/docs/next).

The main development branch of this repo is the
[`next`](https://codeberg.org/forgejo/docs/src/branch/next) branch,
which documents the version of Forgejo that is currently being developed.

Each time a new major version of Forgejo is released,
a new branch will be created in this repo to document the stable release.

Current release branches are as follows:

- [`next`](https://codeberg.org/forgejo/docs/src/branch/next)
- [`v1.20`](https://codeberg.org/forgejo/docs/src/branch/v1.20)
- [`v1.19`](https://codeberg.org/forgejo/docs/src/branch/v1.19)

Documentation content lives in the `docs` subfolder, and images in the `images` subfolder.

## Contributing

### Pull Requests

PRs should usually be sent against the [`next`](https://codeberg.org/forgejo/docs/src/branch/next) branch.
Sometimes it will be appropriate to send a PR against a specific release branch if the changes only affect that release.

Most changes should either be sent as a _single commit per PR_, or should be squashed before merging.
_Fast-forwarding is the preferred merge strategy._
Changes can then be backported (or if appropriate frontported) by cherry-picking.

Rarely, it will make sense to create a feature branch containting a series of commits that will
be merged instead of squashing and fast-forwarding.
Such a feature branch can then be merged into multiple versions of the docs if appropriate.
In this case, the feature branch should usually be taken from the last common ancestor of all of the
version branches into which it will potentially be merged.

### Links

All internal links within the documentation content should be relative to each page's path
at the `https://forgejo.org/docs/{{version}}/` URL.
File extensions (`.md`) should not be included, and every URL should end with a trailing slash.
Look at existing links for examples.

### Images

Images should use relative URLs to the image files, which will be published at `https://forgejo.org/images/{{version}}/`.

## Code of Conduct

All contributors are required to abide by the [Forgejo Code of Conduct](https://codeberg.org/forgejo/code-of-conduct).

Feel free to reach out to the [moderation team](https://codeberg.org/forgejo/governance/src/branch/main/TEAMS.md#moderation)
in case of any conflicts.

## License

The documentation content originates from several different sources and each page has a different license.
Please check the `license` frontmatter key near the top of each file to see the relevant license.

Where not otherwise stated, content is licensed under the
[Creative Commons Attribution-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-sa/4.0/).
