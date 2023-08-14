---
title: 'Push Options'
license: 'Apache-2.0'
origin_url: 'https://github.com/go-gitea/gitea/blob/699f20234b9f7cdbbeeee3be004470c598fa1147/docs/content/doc/usage/push-options.en-us.md'
---

There is support for some [push options](https://git-scm.com/docs/git-push#Documentation/git-push.txt--oltoptiongt).

- `repo.private` (true|false) - Change the repository's visibility.

  This is particularly useful when combined with push-to-create.

- `repo.template` (true|false) - Change whether the repository is a template.

Example of changing a repository's visibility to public:

```shell
git push -o repo.private=false -u origin main
```
