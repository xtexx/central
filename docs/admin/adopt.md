---
title: 'Adopt existing git directories'
license: 'CC-BY-SA-4.0'
---

If directories containing bare git repositories exist in the
`[repository].ROOT` hierarchy, they can be imported using the admin
panel.

- Make sure the directory names are lowercase.
- `[repository].ROOT/{user,org}/{repo}.git` will become a project owned by the user or the org.
- Go to `/admin/repos/unadopted`
- In trusted environments, users can also be given similar permissions via the [`ALLOW_ADOPTION_OF_UNADOPTED_REPOSITORIES`](../config-cheat-sheet/#repository-repository) setting.
