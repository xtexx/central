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
- wait 15 minutes
- click `Lock`
- reload the page
  - check the number of commits
  - verify there are 0 pending changes
- go to the pull request and wait until it is rebased and has the same number of commits
- squash-merge the pending `[I18N]` pull request ([similar to this example](https://codeberg.org/forgejo/forgejo/pulls/2317))
- click `Reset`
- click `Unlock`

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
