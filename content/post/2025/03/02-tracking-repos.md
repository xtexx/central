---
title: "Managing a troop of repositories"
date: 2025-03-02T10:17:16+08:00
aliases: ["/2025/03/02-tracking-repos"]
params: { locale: en-us }
---

When I am getting deeper and deeper in the open-source community, I find software bugs or need new features more and more frequently. Generally, I will make a issue, submit a PR, or maintain a fork if I think those code are not suitable for being upstreamed.

What if we also want to fork some extensions? It can happen in the real world. In my MediaWiki setup, I have to patch extensions frequently to address deprecation warnings and compatibility bugs.

Another scene is when we want to track versions of softwares running on our servers.

I have some experience forking these multi-repository softwares and want to write my thought down and re-consider them. Projects I currently work on include: [the MediaWiki deployment of Xensor V Network](https://codeberg.org/xens/mediawiki/), the wiki family of WMGMC, [Chi_Tang UI](https://github.com/chitangUI) (a AOSP fork), the [Phorge instance of WMGMC](https://git.cnuser.wiki/wmgmc/phorge/), and more.

## Ways of forking

### One by one

The simplest way is to fork all repositories one by one. Examples include almost all (as far as I know, absolutely all) AOSP forks and [WeirdGloop's fork of MediaWiki](https://github.com/weirdgloop/).

The pros are that we can clone only some repositories to local and that we can submit patches to upstream easily.

However, on forge services that do not support nested groups (GitLab does, GitHub and Forgejo don't), we have to create many fork repositories in our organization. It is okay if your project is only the fork, but not okay for Xensor V Network. MediaWiki is only a small part of the network and I don't want to make the list of our repositories full of MediaWiki.

The advantage of cloning partially can also be seen as disadvantage: what if I want to clone all repositories? For AOSP projects (and others using `git-repo`), it is easy because there is a manifest repository containing a list of all repositories forked and not forked. `git-repo` will handle it.

One may ask "then I can use `git-repo` for all projects?". The answer is no. `git-repo` is coupled with Gerrit.

### git-submodule

Some use `git-submodule(1)` for managing their forks. It is a bit weird. I would not recommend this way. And you won't be able to patch unless you fork repositories one-by-one.

### git-subtree

`git-subtree(1)` is a relatively little-used feature. It is in the official repository of Git, but in `contrib/`. It can create a merge committing pulling a repo into your super-repo, while keeping all commit histories. An example is [how I manage the WMGMC fork of Phorge](https://git.cnuser.wiki/wmgmc/phorge/commit/c61314105933dfe5293aeca0e51cc84488444ce5) and the Xensor V fork of MediaWiki.

Pros are that history is kept and we can merge future changes easily (by `git subtree merge` or `git merge -Xsubtree=`). We can also overview changes across all sub-repos when running `git log`.

Obviously, this won't suit super-large projects like AOSP fork. Nobody wants to work with a repo larger than 50 GiB (this is even the size of a shallow checkout). Small projects may also grow larger and larger.

On the other side, submitting patches to upstream become harder. `git cherry-pick` will not work. If you really like `git-cherry-pick`, you will have to `git subtree split` which will walk the history and cherry-pick all changes to the subtree out to construct a split history of that subtree.

Although most time I implement changes in dedicated repo first and then merge that repo into the subtree so I can submit to upstream directly from the dedicated repo, it is also possible to `git format-patch`, edit the patch to fix file paths manually and `git am` in the dedicated repo.

### patches

Linux distribution packagers often keep patch files (or even diff files) only. AOSC has [a GitHub organization](https://github.com/AOSC-Tracking/) for placing forks but still converts commits to patch files when packaging.

[Miraheze's fork of MediaWiki](https://github.com/miraheze/mediawiki-repos) also uses this way.

The best point is that the tracking repository is small, including only patch files.

But if we want to add a new patch? Before we can commit new changes, we will need to clone the upstream repository, `git am` (or `git apply` then `git commit`) all already existing patches for this sub-repo. After that, we need to `git format-patch` all changes out. Some may also require you to write some other texts. For example, openSUSE requires packagers to mention all patch removals in change logs, Debian/ArchLinux/Alpine Linux requires to update `PKGBUILD` or `series` file to include the new patch, and Miraheze needs new JSON files for patches.

It may also work if you simply download a patch file and append it to the patch list if there are no patch conflicts. However, I would recommend the above process because `git format-patch` index patches automatically and correctly for you.

## Merging updates

It is undoubted that success software needs continuous maintenance. If we are not forking dead projects, we need to merge changes form upstream regularly.

For one-by-one forks, merge requests can be created for each repositories and reviewed separately. For GitHub users, I would suggest using [the wei/pull bot](https://github.com/wei/pull).

For submodule users, `git submodule update --remote --recursive` do everything.

For subtree users, it will be nice to write a manifest file listing all upstreams and a script for running `git fetch` and `git subtree merge` to make updating easier. I have [done](https://codeberg.org/xens/mediawiki/src/branch/main/repositories.yaml) this for Xensor V's fork of MediaWiki.

For patches, you need to apply patches and run `git rebase`. If you keep tracking repositories like what AOSC has done, the applying step can be skipped (but their way is almost identical to one-by-one forking).

## How to choose?

Basically I just want to choose between one-by-one and `git-subtree` solutions.

The key is the size. If it is too large, then one-by-one. If there are numerous small repos, then subtree.

By the way, having a look at `git-worktree` may be helpful?

EOF
