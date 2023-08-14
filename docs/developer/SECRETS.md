---
title: Secrets
license: 'CC-BY-SA-4.0'
---

All Forgejo credentials are shared among the [secret keepers](https://codeberg.org/forgejo/meta/src/branch/readme/TEAMS.md#secrets-keeper) teams in a private repository with encrypted content.

## Get started

1. Make sure you have a GPG Key, or [create one](https://github.com/NicoHood/gpgit#12-key-generation)
2. Send someone else your public key and ask this person to add yourself as a recipient

```
# Commands for the other person
$ gpg --import public_key.asc
# The following command will open a prompt, with the available public keys.
# Choose the one you just added and all secrets will be re-encrypted with this new key.
$ gopass recipients add
```

3. [Install gopass](https://www.gopass.pw/#install)
   > :warning: When installing on Ubuntu or Debian you can either download the deb package, install manually or build from source or use our APT repository ([github comment](https://github.com/gopasspw/gopass/issues/1849#issuecomment-802789285) with more information).
4. Clone this repo using `gopass` (the name and email are for `git config`)

```
$ gopass clone git@codeberg.org:forgejo/gopass.git
```

5. Check the consistency of the gopass storage

```
$ gopass fsck
```

## Get a secret

Show the whole secret file:

```
$ gopass show ovh.com/manager
```

Copy the password in the clipboard:

```
$ gopass show -c ovh.com/manager
```

Copy the `user` part of the secret in the clipboard:

```
$ gopass show -c ovh.com/manager user
```

## Insert or edit a secret

```
$ gopass edit ovh.com/manager
```

In the editor, insert the password on the first line.
You may then add lines with a `key: value` syntax (`user: username` for instance).

## Debugging and manual git operations

The following command will show the location and status of the git repo (all git commands are available).

```
$ gopass git status
```
