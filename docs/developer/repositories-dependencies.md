---
title: Managing dependencies between repositories
license: 'CC-BY-SA-4.0'
---

Some Forgejo repositories that depend on each other have workflows
that will trigger workflows on other repositories using the
[cascading-pr](https://code.forgejo.org/actions/cascading-pr/) action.

# Use cases and examples

## Files copied from other repositories

[setup-forgejo](https://code.forgejo.org/actions/setup-forgejo) contains a [copy](https://code.forgejo.org/actions/setup-forgejo/src/branch/main/forgejo-curl.sh) of the [forgejo-curl](https://code.forgejo.org/forgejo/forgejo-curl) script. This script does not have numbered releases and the latest version is the one in the main branch.

forgejo-curl has a [workflow](https://code.forgejo.org/forgejo/forgejo-curl/src/branch/main/.forgejo/workflows/cascade-setup-forgejo.yml) that will open a pull request to setup-forgejo to [update the forgejo-curl.sh script it contains](https://code.forgejo.org/forgejo/forgejo-curl/src/branch/main/.forgejo/cascading-pr-setup-forgejo). The forgejo-curl workflow will wait on the setup-forgejo workflow and fail if it does not pass, thus providing additional confirmation that the change under test won't break setup-forgejo once merged.

When the PR is merged in forgejo-curl, the corresponding PR in setup-forgejo is left open and ready to be merged with the latest version of the forgejo-curl.sh script.

## Verifying an upgrade would work

[setup-forgejo](https://code.forgejo.org/actions/setup-forgejo) installs a [runner](https://code.forgejo.org/forgejo/runner/) by default, as [specified in the action.yml](https://code.forgejo.org/actions/setup-forgejo/src/commit/a580cb63b6ce411c3394aff77c7073d4d3e9428c/action.yml#L49) file.

The runner has a [workflow](https://code.forgejo.org/forgejo/runner/src/branch/main/.forgejo/workflows/cascade-setup-forgejo.yml) that will open a pull request to setup-forgejo to [update the default version](https://code.forgejo.org/forgejo/runner/src/branch/main/.forgejo/cascading-pr-setup-forgejo) in the action.yml file. The runner workflow will wait on the setup-forgejo workflow and fail if it does not pass, thus providing additional confirmation that the change under test won't break setup-forgejo when it upgrades to using a release that contains the change.

When the PR is merged in forgejo-curl, the corresponding PR in setup-forgejo is closed. It is not meant to upgrade setup-forgejo because there is not yet a tag release published with this change.

# Permissions

The cascading-pr action needs a token with write permissions on issues
and pull requests for the destination repository and read permission
on issues and pull requests for the origin repository.

The [cascading-pr user](https://code.forgejo.org/cascading-pr) is
dedicated to providing such tokens and is added as a collaborator with
write permissions to the repositories that are destinations for the
cascading-pr action.

For instance, a personal token named
`https://code.forgejo.org/forgejo/forgejo-curl/` was created by the
cascading-pr user. This token was added as two secrets named
`CASCADING_PR_ORIGIN` and `CASCADING_PR_DESTINATION` in the
https://code.forgejo.org/forgejo/forgejo-curl/ repository. The
cascading-pr user was added as a collaborator with write permission to
https://code.forgejo.org/actions/setup-forgejo. The cascading-user is
not added as a collaborator to the forgejo-curl repository and only
has read permission on issues which allows it to comment on the pull
request and fetch the repository content.

# Access to secrets

The workflow that contains the cascading-pr action needs access to the
secrets of the repository and must run `on.pull_request_target`. For
instance:

```yaml
on:
  pull_request_target:
    types:
      - opened
      - synchronize
      - closed
```

# Updating the workflow

When the cascading-pr workflow is added or updated in a repository, it
must be done in a PR from a branch of the repository and not than from
a forked repository. It runs `on.pull_request_target` and if run from a fork it will use the
content of the default branch instead of the proposed change.
