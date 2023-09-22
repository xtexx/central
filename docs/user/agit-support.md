---
title: 'Agit Setup'
license: 'Apache-2.0'
origin_url: 'https://github.com/go-gitea/gitea/blob/8d9e2d07f3f84a86265fdbe0ab7fcf63cc34ddbd/docs/content/usage/agit-support.en-us.md'
---

Limited support for [agit](https://git-repo.info/en/2020/03/agit-flow-and-git-repo/).

## Creating PRs

Agit allows to create PRs while pushing code to the remote repo. \
This can be done by pushing to the branch followed by a specific refspec (a location identifier known to git). \
The following example illustrates this:

```shell
git push origin HEAD:refs/for/master
```

The command has the following structure:

- `HEAD`: The target branch
- `refs/<for|draft|for-review>/<branch>`: The target PR type
  - `for`: Create a normal PR with `<branch>` as the target branch
  - `draft`/ `for-review`: Currently ignored silently
- `<branch>/<session>`: The target branch to open the PR
- `-o <topic|title|description>`: Options for the PR
  - `title`: The PR title
  - `topic`: The branch name the PR should be opened for
  - `description`: The PR description
  - `force-push`: confirm force update the target branch

Here's another advanced example for creating a new PR targeting `master` with `topic`, `title`, and `description`:

```shell
git push origin HEAD:refs/for/master -o topic="Topic of my PR" -o title="Title of the PR" -o description="# The PR Description\nThis can be **any** markdown content.\n- [x] Ok"
```
