---
title: 'Push Options'
license: 'Apache-2.0'
origin_url: 'https://github.com/go-gitea/gitea/blob/faa28b5a44912f1c63afddab9396bae9e6fe061c/docs/content/doc/usage/push.en-us.md'
---

## Push To Create

Push to create is a feature that allows you to push to a repository that does not exist yet in Forgejo. This is useful for automation and for allowing users to create repositories without having to go through the web interface. This feature is disabled by default.

### Enabling Push To Create

In the `app.ini` file, set `ENABLE_PUSH_CREATE_USER` to `true` and `ENABLE_PUSH_CREATE_ORG` to `true` if you want to allow users to create repositories in their own user account and in organizations they are a member of respectively. Restart Forgejo for the changes to take effect. You can read more about these two options in the Configuration Cheat Sheet.

### Using Push To Create

Assuming you have a git repository in the current directory, you can push to a repository that does not exist yet in Forgejo by running the following command:

```shell
# Add the remote you want to push to
git remote add origin git@{domain}:{username}/{repo name that does not exist yet}.git

# push to the remote
git push -u origin main
```

This assumes you are using an SSH remote, but you can also use HTTPS remotes as well.

### Push options

Push-to-create will default to the visibility defined by `DEFAULT_PUSH_CREATE_PRIVATE` in `app.ini`. To explicitly set the visibility there is support for some [push options](https://git-scm.com/docs/git-push#Documentation/git-push.txt--oltoptiongt).

- `repo.private` (true|false) - Change the repository's visibility.

  This is particularly useful when combined with push-to-create.

- `repo.template` (true|false) - Change whether the repository is a template.

Example of changing a repository's visibility to public:

```shell
git push -o repo.private=false -u origin main
```
