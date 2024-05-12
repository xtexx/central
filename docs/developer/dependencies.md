---
title: Dependency management
license: 'CC-BY-SA-4.0'
---

Forgejo relies on hundreds of Free Software components and they all need to be updated on a regular basis, with appropriate tooling and methods.

# Releases

Software referenced by a release (even if such a release is the hash of a commit). They are listed in the [dependency dashboard](https://codeberg.org/forgejo/forgejo/issues/2779) which is updated by [renovate](https://github.com/renovatebot/renovate) from [the renovate.json configuration file](https://codeberg.org/forgejo/forgejo/src/branch/forgejo/renovate.json).

Pull [requests are opened](https://codeberg.org/forgejo/forgejo/pulls?poster=165503) when an upgrade is available and the decision to merge (positive review) or not (request for change review) depends on what the upgrade offers.

- The PR contains information about the release. If it does not, it has detailed references that can be used to browse the commits in the dependency source repository and figure out what the changes are.
- The comment of the review:
  - explains the decision (needed, not needed)
  - explains why the change has an impact on Forgejo
- If the upgrade is needed, user visible changes must be included in the draft release notes for the upcoming release. See [this upgrade for an example](https://codeberg.org/forgejo/forgejo/pulls/3724/files).
- Security fix and important bug fixes are backported to the stable releases.
- Set the dependency label.

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
