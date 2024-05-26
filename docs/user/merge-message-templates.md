---
title: 'Merge Message templates'
license: 'Apache-2.0'
origin_url: 'https://github.com/go-gitea/gitea/blob/e865de1e9d65dc09797d165a51c8e705d2a86030/docs/content/usage/merge-message-templates.en-us.md'
---

## File names

Possible file names for PR default merge message templates:

- `.gitea/default_merge_message/MERGE_TEMPLATE.md`
- `.gitea/default_merge_message/REBASE_TEMPLATE.md`
- `.gitea/default_merge_message/REBASE-MERGE_TEMPLATE.md`
- `.gitea/default_merge_message/SQUASH_TEMPLATE.md`
- `.gitea/default_merge_message/MANUALLY-MERGED_TEMPLATE.md`
- `.gitea/default_merge_message/REBASE-UPDATE-ONLY_TEMPLATE.md`

## Variables

You can use the following variables enclosed in `${}` inside these templates which follow [os.Expand](https://pkg.go.dev/os#Expand) syntax:

- BaseRepoOwnerName: Base repository owner name of this pull request
- BaseRepoName: Base repository name of this pull request
- BaseBranch: Base repository target branch name of this pull request
- HeadRepoOwnerName: Head repository owner name of this pull request
- HeadRepoName: Head repository name of this pull request
- HeadBranch: Head repository branch name of this pull request
- PullRequestTitle: Pull request's title
- PullRequestDescription: Pull request's description
- PullRequestPosterName: Pull request's poster name
- PullRequestIndex: Pull request's index number
- PullRequestReference: Pull request's reference char with index number. i.e. #1, !2
- ClosingIssues: return a string contains all issues which will be closed by this pull request i.e. `close #1, close #2`

## Rebase

When rebasing without a merge commit, `REBASE_TEMPLATE.md` modifies the message of the last commit. The following additional variables are available in this template:

- CommitTitle: Commit's title
- CommitBody: Commit's body text
