---
title: 'Labels'
license: 'Apache-2.0'
origin_url: 'https://github.com/go-gitea/gitea/blob/faa28b5a44912f1c63afddab9396bae9e6fe061c/docs/content/doc/usage/labels.en-us.md'
---

You can use labels to classify issues and pull requests and to improve your overview over them.

## Creating Labels

For repositories, labels can be created by going to `Issues` and clicking on `Labels`.

![create a label](../../../../images/v1.20/user/labels/label-new.png)

For organizations, you can define organization-wide labels that are shared with all organization repositories, including both already-existing repositories as well as newly created ones. Organization-wide labels can be created in the organization `Settings`.

Labels have a mandatory name, a mandatory color, an optional description, and must either be exclusive or not (see `Scoped labels` below).

When you create a repository, you can ensure certain labels exist by using the `Issue Labels` option. This option lists a number of available label sets that are configured globally on your instance. Its contained labels will all be created as well while creating the repository.

![list of labels](../../../../images/v1.20/user/labels/label-apply.png)

When you create a repository, you can ensure certain labels exist by using the `Issue Labels` option. This option lists a number of available label sets that are configured globally on your instance. Its contained labels will all be created as well while creating the repository.

## Scoped Labels

Scoped labels are used to ensure at most a single label with the same scope is assigned to an issue or pull request. For example, if labels `kind/bug` and `kind/enhancement` have the Exclusive option set, an issue can only be classified as a bug or an enhancement.

![list of labels](../../../../images/v1.20/user/labels/label-list.png)

A scoped label must contain `/` in its name (not at either end of the name). The scope of a label is determined based on the **last** `/`, so for example the scope of label `scope/subscope/item` is `scope/subscope`.

A scoped label must contain `/` in its name (not at either end of the name). The scope of a label is determined based on the **last** `/`, so for example the scope of label `scope/subscope/item` is `scope/subscope`.

## Filtering by Label

Issue and pull request lists can be filtered by label. Selecting multiple labels shows issues and pull requests that have all selected labels assigned.

By holding alt to click the label, issues and pull requests with the chosen label are excluded from the list.
