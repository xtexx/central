---
title: 'AGit Workflow Usage'
license: 'Apache-2.0'
origin_url: 'https://github.com/go-gitea/gitea/blob/e865de1e9d65dc09797d165a51c8e705d2a86030/docs/content/usage/agit-support.en-us.md'
---

Forgejo ships with limited support for [AGit-Flow](https://git-repo.info/en/2020/03/agit-flow-and-git-repo/). It was originally introduced in Gitea `1.13`.

Similarly to [Gerrit's workflow](https://www.gerritcodereview.com), this workflow provides a way of submitting changes to repositories hosted on Forgejo instances using the `git push` command alone, without having to create forks or feature branches and then using the web UI to create a Pull Request.

Using Push Options (`-o`) and a [Refspec](https://git-scm.com/book/en/v2/Git-Internals-The-Refspec) (a location identifier known to Git), it is possible to supply the information required to open a Pull Request, such as the target branch or the Pull Request's title.

## Creating Pull Requests

For clarity reasons, this document will lead with some examples first.

A full list of the parameters, as well as information on avoiding duplicate Pull Requests when rebasing or amending a commit, will follow.

### Usage Examples

Suppose that you cloned a repository and created a new commit on top of the `main` branch. A Pull Request targeting the `main` branch using your **currently checked out branch** can be created like this:

```shell
git push origin HEAD:refs/for/main -o topic="agit-typo-fixes"
```

The topic will be visible in the Pull Request and it will be used to associate further commits to the same Pull Request. Under the hood, it is essentially just a branch.

It can also be supplied directly using the `<session>` parameter in the **Refspec**, which will set the topic as `topic-branch` **and** push the **local branch** `topic-branch` instead:

```shell
# topic-branch is the session parameter and the topic
git push origin HEAD:refs/for/main/topic-branch
```

A detailed explanation illustrating the difference between using `-o topic` and `<session>` will follow shortly.

It is also possible to use some additional parameters, such as `title` and `description`. Here's another example targeting the `master` branch:

```shell
git push origin HEAD:refs/for/master -o topic="topic-branch" \
  -o title="Title of the PR" \
  -o description="# The PR Description
This can be **any** markdown content.\n
- [x] Ok"
```

To be able to easily push new commits to your pull request, you first need to switch the [default push method](https://git-scm.com/docs/git-config#Documentation/git-config.txt-pushdefault) to "upstream":

```shell
# To only set this option for this specific repository
git config push.default upstream
# Or run this instead if you want to set this option globally
git config --global push.default upstream
```

Then, run the following command:

```shell
git config branch.local-branch.merge refs/for/main/topic-branch
```

After doing so, you can now simply run `git push` to push commits to your pull request, without having to specify the refspec.
This also will allow you to pull, fetch, rebase, etc. from the AGit pull request by default.

#### A More Complex Example

Suppose that the currently checked out branch in your local repository is `main`, yet you would like to submit a Pull Request meant for a remote branch called `remote-branch`.

However, the changes that you want to submit reside in a local branch called `local-branch`. In order to submit the changes residing in the `local-branch` branch **without** checking it out, you can supply the name of the local branch (`local-branch`) using the `<session>` parameter:

```shell
git push origin HEAD:refs/for/remote-branch/local-branch \
  -o title="My First Pull Request!"
```

This syntax may be a bit disorienting for users that are accustomed to commands such as `git push origin remote-branch` or `git push origin local-branch:remote-branch`.

Just like when using `git push origin remote-branch`, supplying the local branch name is optional, as long as you checkout `local-branch` using `git checkout local-branch` beforehand and **use the `topic` push option**:

```shell
git checkout local-branch
git push origin HEAD:refs/for/remote-branch \
  -o topic="my-first-agit-pr" \
  -o title="My First Pull Request!"
```

**If you do not use the `topic` push option,** `<session>` will be used as the topic instead.

### Parameters

The following parameters are available:

- `HEAD`: The target branch **(required)**
- `refs/<for|draft|for-review>/<branch>/<session>`: Refspec **(required)**
  - `for`/`draft`/`for-review`: This parameter describes the Pull Request type. **for** opens a normal Pull Request. **draft** and **for-review** are currently silently ignored.
  - `<branch>`: The target branch that a Pull Request should be merged against **(required)**
  - `<session>`: The local branch that should be submitted remotely. **If left empty,** the currently checked out branch will be submitted by default, however, you **must** use `topic`.
- `-o <topic|title|description|force-push>`: Push options
  - `topic`: Essentially an identifier. **If left empty,** the value of `<session>`, if present, will also be used for the topic. Otherwise, Forgejo will return an error. If you want to push additional commits to a Pull Request that was created using AGit, you **must** use the same topic.
  - `title`: Title of the Pull Request. **If left empty,** the first line of the first new Git commit will be used instead.
  - `description`: Description of the Pull Request.
  - `force-push`: Necessary when rebasing, amending or [retroactively modifying](https://git-scm.com/book/en/v2/Git-Tools-Rewriting-History) your previous commits. Otherwise, a new Pull Request will be opened, **even if you use the same topic**. If used, the value of this parameter should be set to `true`.

Forgejo relies on the `topic` parameter and a linear commit history in order to associate new commits with an existing Pull Request.

**For Gerrit users:** Forgejo does not support [Gerrit's Change-Ids](https://gerrit-review.googlesource.com/Documentation/user-changeid.html).
