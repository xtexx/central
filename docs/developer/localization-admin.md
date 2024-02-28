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

- announce 15 minutes before in the chatroom `@room the translations will be locked for maintenance in 15 minutes, make sure you don't try to save a translation when that happens as it will be lost.`
- go to the [weblate repository admin page](https://translate.codeberg.org/projects/forgejo/forgejo/#repository)
- click lock
- reload the page
  - check the number of commits
  - verify there are 0 pending changes
- go to the pull request and wait until it is rebased and has the same number of commits
- squash merge the pending pull request ([similar to this example](https://codeberg.org/forgejo/forgejo/pulls/2317))
- click reset
- click unlock
