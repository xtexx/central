---
title: Release management
license: 'CC-BY-SA-4.0'
---

## Release numbering

The Forgejo release numbers are composed of the Gitea release number followed by a dash and a serial number. For instance:

- Gitea **v1.20.0** will be Forgejo **v1.20.0-0**, **v1.20.0-1**, etc

The Gitea release candidates are suffixed with **-rcN** which is handled as a special case for packaging: although **X.Y.Z** is lexicographically lower than **X.Y.Z-rc1** is is considered greater. The Forgejo serial number must therefore be inserted before the **-rcN** suffix to preserve the expected version ordering.

- Gitea **v1.20.0-rc0** will be Forgejo **v1.20.0-0-rc0**, **v1.20.0-1-rc0**
- Gitea **v1.20.0-rc1** will be Forgejo **v1.20.0-2-rc1**, **v1.20.0-3-rc1**, **v1.20.0-4-rc1**
- Gitea **v1.20.0** will be Forgejo **v1.20.0-5**, **v1.20.0-6**, **v1.20.0-7**
- etc.

Because Forgejo depends on Gitea, it must retain the same release numbering scheme to be compatible with libraries and tools that depend on it. For instance, the tea CLI or the Gitea SDK will behave differently depending on the server version they connect to. If Forgejo had a different numbering scheme, it would no longer be compatible with the Gitea ecosystem.

From a [Semantic Versioning](https://semver.org/) standpoint, all Forgejo releases are [pre-releases](https://semver.org/#spec-item-9) because they are suffixed with a dash. They are syntactically correct but do not comply with the Semantic Versioning recommendations. Gitea is not compliant either and Forgejo inherits this problem.

## Release process

The TL;DR: to publish a vX.Y.Z-N release is to:

- Push the vX.Y.Z-N tag to https://codeberg.org/forgejo-integration/forgejo to trigger a workflow that will publish the release in https://codeberg.org/forgejo-experimental/forgejo
- Give it some time for people to try it out
- Push the vX.Y.Z-N tag to https://forgejo.octopuce.forgejo.org/forgejo-release/forgejo to trigger a workflow that will sign the release from https://codeberg.org/forgejo-experimental/forgejo and publish it in https://codeberg.org/forgejo-release/forgejo

### Semantic version

- Update the FORGEJO_VERSION variable in the Makefile

### Create a milestone and a check list

- Create a `Forgejo vX.X.Z-N` milestone set to the date of the release
- Create an issue named `[RELEASE] Forgejo vX.Y.Z-N` with a description that includes a list of what needs to be done for the release with links to follow the progress
- Set the milestone of this issue to `Forgejo vX.X.Z-N`
- Close the milestone when the release is complete

### Cherry pick the latest commits from Gitea

The vX.Y/forgejo branch is populated as part of the [rebase on top of Gitea](./workflow/). The release happens in between rebase and it is worth checking if the matching Gitea branch, release/vX.Y contains commits that should be included in the release.

- `cherry-pick -x` the commits
- push the vX.Y/forgejo branch including the commits
- verify that the tests pass

### Release Notes

- Add an entry in RELEASE-NOTES.md

### Forgejo release building and testing

When Forgejo is released, artefacts (packages, binaries, etc.) are first published by the CI/CD pipelines in the https://codeberg.org/forgejo-experimental organization, to be downloaded and verified to work.

- Locally set the vX.Y.Z-N tag to the tip of the https://codeberg.org/forgejo/forgejo/vX.Y/forgejo branch
- Push the vX.Y.Z-N tag to https://codeberg.org/forgejo-integration/forgejo

Binaries are built and uploaded to https://codeberg.org/forgejo-integration/forgejo/releases
Container images are built and uploaded to https://codeberg.org/forgejo-integration/-/packages/container/forgejo/versions

If the release is successfully built, it will be copied to https://codeberg.org/forgejo/forgejo-experimental. Otherwise the logs of the workflow that tried to build the release in https://codeberg.org/forgejo-integration/forgejo/actions contains the error that needs fixing.

Fork the Forgejo [infrastructure](https://code.forgejo.org/forgejo/infrastructure) repository, [modify it](https://code.forgejo.org/earl-warren/infrastructure/commit/269eae6c3a17005ad9d825d747745da041d69756) to use the experimental release and push the branch. It will trigger [a workflow](https://code.forgejo.org/earl-warren/infrastructure/src/branch/wip-forgejo/.forgejo/workflows/forgejo.yml) to deploy the release and run high level integration tests.

Reach out to packagers and users to manually verify the release works as expected.

### Forgejo release publication

- Push the vX.Y.Z-N tag to https://forgejo.octopuce.forgejo.org/forgejo-release/forgejo

It will trigger a workflow to:

- Push the vX.Y.Z-N tag to https://codeberg.org/forgejo/forgejo
- Downoad Binaries from https://codeberg.org/forgejo-experimental, sign them and copy them to https://codeberg.org/forgejo
- Copy container images from https://codeberg.org/forgejo-experimental to https://codeberg.org/forgejo

### Forgejo runner publication

- Push the vX.Y.Z-N tag to https://code.forgejo.org/forgejo/runner

The release is built on https://code.forgejo.org/forgejo-integration/runner, which is a mirror of https://code.forgejo.org/forgejo/runner.

The release is published on
https://forgejo.octopuce.forgejo.org/forgejo/runner, which is a mirror
of https://code.forgejo.org/forgejo-integration/runner. It is behind a
VPN and its role is to copy and sign release artifacts.

- Binaries are downloaded from https://code.forgejo.org/forgejo-integration/runner, signed and copied to https://code.forgejo.org/forgejo/runner.
- Container images are copied from https://code.forgejo.org/forgejo-integration to https://code.forgejo.org/forgejo

If the publishing the release needs debug, it can be done manually:

- https://forgejo.octopuce.forgejo.org/forgejo-release/runner-debug has the same secrets as https://forgejo.octopuce.forgejo.org/forgejo-release/runner
- Make the changes, commit them, tag the commit with vX.Y.Z-N and force push the tag to https://forgejo.octopuce.forgejo.org/forgejo-release/runner-debug. Note that it does not matter that the tag is not on a commit that matches the release because this action only cares about the tag: it does not build any content itself, it copies it from one organization to another. However it matters that it matches a SHA that is found in the destination repository of the release otherwise it won't be able to set the tag (setting a tag on a non-existing sha does not work).
- Watch the action run at https://forgejo.octopuce.forgejo.org/forgejo-release/runner-debug/actions
- To skip one of the publish phases (binaries or container images), delete it and commit in the repository before pushing the tag
- Reflect the changes in a PR at https://code.forgejo.org/forgejo/runner to make sure they are not lost

It can also be done from the CLI with `forgejo-runner exec` and
providing the secrets from the command line.

### Securing the release token and cryptographic keys

For both the Forgejo runner and Forgejo itself, copying and signing the release artifacts (container images and binaries) happen on a Forgejo isntance running [behind a VPN](./infrastructure#octopuce/) to safeguard the token that has write access to the Forgejo repository as well as the cryptographic key used to sign the releases.

### Website update

- Restart the last CI build at https://codeberg.org/forgejo/website/src/branch/main/
- Verify [https://forgejo.org/download/](/download/) points to the expected release
- Update the [documentation link to the latest version](https://codeberg.org/forgejo/website/src/commit/e63c6f8ab64876b10b86de1d18162b6ccb87bd99/.woodpecker.yml#L35)
- Manually try the instructions to work

### DNS update

- Update the `release.forgejo.org` TXT record that starts with `forgejo_versions=` to be `forgejo_versions=vX.Y.Z-N`

### Standard toot

The following toot can be re-used to announce a minor release at `https://floss.social/@forgejo`. For more significant releases it is best to consider a dedicated and non-standard toot.

```
#Forgejo vX.Y.Z-N was just released! This is a minor patch. Check out the release notes and download it at https://forgejo.org/releases/. If you experience any issues with this release, please report to https://codeberg.org/forgejo/forgejo/issues.
```

## Release signing keys management

A GPG master key with no expiration date is created and shared with members of the Owners team via encrypted email. A subkey with a one year expiration date is created and stored in the secrets repository, to be used by the CI pipeline. The public master key is stored in the secrets repository and published where relevant.

### Master key creation

- gpg --expert --full-generate-key
- key type: ECC and ECC option with Curve 25519 as curve
- no expiration
- id: Forgejo Releases <contact@forgejo.org>
- gpg --export-secret-keys --armor EB114F5E6C0DC2BCDD183550A4B61A2DC5923710 and send via encrypted email to Owners
- gpg --export --armor EB114F5E6C0DC2BCDD183550A4B61A2DC5923710 > release-team-gpg.pub
- commit to the secret repository

### Subkey creation and renewal

- gpg --expert --edit-key EB114F5E6C0DC2BCDD183550A4B61A2DC5923710
- addkey
- key type: ECC (signature only)
- key validity: one year
- create [an issue](https://codeberg.org/forgejo/forgejo/issues) to schedule the renewal

#### 2023

- gpg --export --armor F7CBF02094E7665E17ED6C44E381BF3E50D53707 > 2023-release-team-gpg.pub
- gpg --export-secret-keys --armor F7CBF02094E7665E17ED6C44E381BF3E50D53707 > 2023-release-team-gpg
- commit to the secrets repository
- renewal issue https://codeberg.org/forgejo/forgejo/issues/58

### CI configuration

In the Woodpecker CI configuration the following secrets must be set:

- `releaseteamgpg` is the secret GPG key used to sign the releases
- `releaseteamuser` is the user name to authenticate with the Forgejo API and publish the releases
- `releaseteamtoken` is the token to authenticate `releaseteamuser` with the Forgejo API and publish the releases
- `domain` is `codeberg.org`

## Users, organizations and repositories

### Shared user: release-team

The [release-team](https://codeberg.org/release-team) user publishes and signs all releases. The associated email is mailto:release@forgejo.org.

The public GPG key used to sign the releases is [EB114F5E6C0DC2BCDD183550A4B61A2DC5923710](https://codeberg.org/release-team.gpg) `Forgejo Releases <release@forgejo.org>`

### Shared user: forgejo-ci

The [forgejo-ci](https://codeberg.org/forgejo-ci) user is dedicated to https://forgejo-ci.codeberg.org/ and provides it with OAuth2 credentials it uses to run.

### Shared user: forgejo-experimental-ci

The [forgejo-experimental-ci](https://codeberg.org/forgejo-experimental-ci) user is dedicated to provide the application tokens used by Woodpecker CI repositories to build releases and publish them to https://codeberg.org/forgejo-experimental. It does not (and must not) have permission to publish releases at https://codeberg.org/forgejo.

### Integration and experimental organization

The https://codeberg.org/forgejo-integration organization is dedicated to integration testing. Its purpose is to ensure all artefacts can effectively be published and retrieved by the CI/CD pipelines.

The https://codeberg.org/forgejo-experimental organization is dedicated to publishing experimental Forgejo releases. They are copied from the https://codeberg.org/forgejo-integration organization.

The `forgejo-experimental-ci` user as well as all Forgejo contributors working on the CI/CD pipeline should be owners of both organizations.

The https://codeberg.org/forgejo-integration/forgejo repository is coupled with a Woodpecker CI repository configured with the credentials provided by the https://codeberg.org/forgejo-experimental-ci user. It runs the pipelines found in `releases/woodpecker-build/*.yml` which builds and publishes an unsigned release in https://codeberg.org/forgejo-integration.

### Experimental and release repositories

The https://codeberg.org/forgejo/experimental private repository is coupled with a Woodpecker CI repository configured with the credentials provided by the https://codeberg.org/forgejo-experimental-ci user. It runs the pipelines found in `releases/woodpecker-publish/*.yml` which signs and copies a release from https://codeberg.org/forgejo-integration into https://codeberg.org/forgejo-experimental.

The https://codeberg.org/forgejo/release private repository is coupled with a Woodpecker CI repository configured with the credentials provided by the https://codeberg.org/release-team user. It runs the pipelines found in `releases/woodpecker-publish/*.yml` which signs and copies a release from https://codeberg.org/forgejo-integration into https://codeberg.org/forgejo.
