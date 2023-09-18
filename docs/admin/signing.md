---
title: 'GPG Commit Signatures'
license: 'Apache-2.0'
origin_url: 'https://github.com/go-gitea/gitea/blob/323135b97b219d7fb10557fb9d9156c6bef3ae62/docs/content/administration/signing.en-us.md'
---

Forgejo will verify GPG commit signatures in the provided tree by
checking if the commits are signed by a key within the Forgejo database,
or if the commit matches the default key for Git.

Keys are not checked to determine if they have expired or revoked.
Keys are also not checked with keyservers.

A commit will be marked with an unlocked icon if no key can be
found to verify it.

## Automatic Signing

There are a number of places where Forgejo will generate commits itself:

- Repository Initialisation
- Wiki Changes
- CRUD actions using the editor or the API
- Merges from Pull Requests

## Installing and generating a GPG key for Forgejo

Forgejo generates all its commits using the server `git`
command - and the `gpg` command will be used for
signing.

## General Configuration

Forgejo's configuration for signing can be found with the
`[repository.signing]` section of `app.ini`:

```ini
...
[repository.signing]
SIGNING_KEY = default
SIGNING_NAME =
SIGNING_EMAIL =
INITIAL_COMMIT = always
CRUD_ACTIONS = pubkey, twofa, parentsigned
WIKI = never
MERGES = pubkey, twofa, basesigned, commitssigned

...
```

### `SIGNING_KEY`

There are three main options:

- `none` - this prevents Forgejo from signing any commits
- `default` - Forgejo will default to the key configured within `git config`
- `KEYID` - Forgejo will sign commits with the gpg key with the ID
  `KEYID`. In this case you should provide a `SIGNING_NAME` and
  `SIGNING_EMAIL` to be displayed for this key.

The `default` option will interrogate `git config` for
`commit.gpgsign` option - if this is set, then it will use the results
of the `user.signingkey`, `user.name` and `user.email`.

By default, Forgejo will look for the signing key in `[git].HOME_PATH/.gnupg`.

However, this path differs from where GnuPG stores keys by default (`$HOME/.gnupg`).

There are 2 possible solutions here:

1. Move the `.gnupg` folder after importing/generating keys;
2. Set the `GNUPGHOME` environment variable to help Forgejo find the correct keychain.

### `INITIAL_COMMIT`

This option determines whether Forgejo should sign the initial commit
when creating a repository. The possible values are:

- `never`: Never sign
- `pubkey`: Only sign if the user has a public key
- `twofa`: Only sign if the user logs in with two factor authentication
- `always`: Always sign

Options other than `never` and `always` can be combined as a comma
separated list. The commit will be signed if all selected options are true.

### `WIKI`

This options determines if Forgejo should sign commits to the Wiki.
The possible values are:

- `never`: Never sign
- `pubkey`: Only sign if the user has a public key
- `twofa`: Only sign if the user logs in with two-factor authentication
- `parentsigned`: Only sign if the parent commit is signed.
- `always`: Always sign

Options other than `never` and `always` can be combined as a comma
separated list. The commit will be signed if all selected options are true.

### `CRUD_ACTIONS`

This option determines if Forgejo should sign commits from the web
editor or API CRUD actions. The possible values are:

- `never`: Never sign
- `pubkey`: Only sign if the user has a public key
- `twofa`: Only sign if the user logs in with two-factor authentication
- `parentsigned`: Only sign if the parent commit is signed.
- `always`: Always sign

Options other than `never` and `always` can be combined as a comma
separated list. The change will be signed if all selected options are true.

### `MERGES`

This option determines if Forgejo should sign merge commits from PRs.
The possible options are:

- `never`: Never sign
- `pubkey`: Only sign if the user has a public key
- `twofa`: Only sign if the user logs in with two-factor authentication
- `basesigned`: Only sign if the parent commit in the base repo is signed.
- `headsigned`: Only sign if the head commit in the head branch is signed.
- `commitssigned`: Only sign if all the commits in the head branch to the merge point are signed.
- `approved`: Only sign approved merges to a protected branch.
- `always`: Always sign

Options other than `never` and `always` can be combined as a comma
separated list. The merge will be signed if all selected options are true.

## Obtaining the Public Key of the Signing Key

The public key used to sign Forgejo's commits can be obtained from the API at:

```sh
/api/v1/signing-key.gpg
```

In cases where there is a repository specific key this can be obtained from:

```sh
/api/v1/repos/:username/:reponame/signing-key.gpg
```
