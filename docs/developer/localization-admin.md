---
title: Localization admin duties
license: 'CC-BY-SA-4.0'
---

Localization team members with admin rights on both Forgejo and Weblate
are expected to make sure the translations land in the Forgejo
repository and resolve conflicts when they arise.

## Merging translations in Forgejo

Weblate is [configured to propose pull requests](https://translate.codeberg.org/settings/forgejo/forgejo/#vcs)
to the Forgejo repository with new translations. These pull requests should be **squash merged** into the Forgejo
development branch as follows:

- announce in the chatroom: `@room the translations will be locked for maintenance in about 15 minutes. Make sure you don't try to save a translation when that happens as it will be lost.`
- go to the [Weblate repository admin page](https://translate.codeberg.org/projects/forgejo/forgejo/#repository)
- click `Commit`. This is done optionally to make tests run before interrupting anyone, to reduce the total maintenance time
- post an [announcement in Weblate](https://translate.codeberg.org/projects/forgejo/#announcement): `The translations will be locked for maintenance soon. Make sure you don't try to save a translation when that happens as it will be lost.`
- wait 15 minutes
- click `Lock`
- reload the page
  - check the number of commits
  - verify there are 0 pending changes
- go to the pull request and wait until it is rebased and has the same number of commits
- squash-merge the pending `[I18N]` pull request ([similar to this example](https://codeberg.org/forgejo/forgejo/pulls/2317))
- click `Reset`
- click `Unlock`
- remove Weblate announcement

## Merging a pull request that changes translations

When a [Forgejo pull
request](https://codeberg.org/forgejo/forgejo/pulls) modifies files in
`options/locale` other than `locale_en-US.ini` for which it is
authoritative, it must be merged after all pending changes in Weblate
are merged as explained above. Only the end of the sequence changes:

- squash merge the pending `[I18N]` pull request ([similar to this example](https://codeberg.org/forgejo/forgejo/pulls/2317))
- merge the PR (after resolving conflicts due to the merge of the Weblate changes)
- click `Reset`
- click `Unlock`

## Resolving failures

### Weblate locked due to network error

Sometimes a connectivity error with Codeberg or it's unavailability can cause Weblate to lock. The lock error looks like this:

```
kex_exchange_identification: Connection closed by remote host
Connection closed by 217.197.91.145 port 22
fatal: Could not read from remote repository.

Please make sure you have the correct access rights
and the repository exists.
 (128)
```

Weblate will retry connection attempts but it takes hours before it does that. If Codeberg is currently [available](https://status.codeberg.eu/) and working, the project can simply be unlocked manually to allow the translators to keep working.

### Weblate was not reset before unlocking

If Weblate was not reset after a translation squash-merge was performed, and it already has new edits, the following steps must be taken to resolve failing rebase and save the new edits:

1. Lock Weblate if it didn't lock itself yet due to a rebase error
2. Make sure there are no [pending changes](https://translate.codeberg.org/projects/forgejo/forgejo/#repository). If there are, click `Commit`
3. Download current [translation files](https://translate.codeberg.org/download/forgejo/forgejo/?format=zip) just in case something goes wrong
4. Add internal Weblate git repository to your remotes and fetch it: `git remote add weblate https://translate.codeberg.org/git/forgejo/forgejo`, `git fetch -u weblate`
5. Checkout into it's branch to see which commits it contains: `git checkout weblate/forgejo`. Identify the new commits that were not squash-merged into the Forgejo repository yet
6. Checkout a new branch from `forgejo` branch: `git switch forgejo`, `git checkout -b i18n-weblate-recovery`
7. Cherry-pick the new commits into this new branch: `git cherry-pick <commit>`
8. Publish this branch and open a PR
9. Wait for the PR to be merged
10. Click `Reset`
11. Click `Update`
12. Click unlock

### Commit changing non-base locales was merged before Weblate

If a commit changing translation files other than `en_US.ini` was merged before all changes from Weblate were merged, it could have caused Weblate to lock itself due to failed rebase.
If the rebase did succeed, everything is ok and no steps need to be taken, just be more cautious with merges next time.
If Weblate failed to rebase, the following steps must be taken:

1. Make a PR that reverts the commit that caused the breakage
2. Merge this PR
3. Make Weblate commit and push all changes
4. Merge the Weblate PR
5. Rebase the commit(s) of the PR that caused the breakage on top of the new Weblate commit, open a new PR

Alternatively the same steps as in `Weblate was not reset before unlocking` can be taken, except that the conflicts must be resolved with Weblate commits instead of the breaking PR commits.
