---
title: 'Profile customization'
license: 'Apache-2.0'
origin_url: 'https://github.com/go-gitea/gitea/blob/e865de1e9d65dc09797d165a51c8e705d2a86030/docs/content/usage/profile-readme.en-us.md'
---

By default the profile page of a user (or an organization) is the list of repositories they
own. It is possible to customize it with a short description that
shows to the left, under their avatar. It can now be fully
personalized with a markdown file that is displayed instead of the
list of repositories.

![Profile page](../_images/user/profile/profile-step1.png)

It uses the `README.md` file from the `.profile` repository of the
user (or organization), if it exists.

![Profile README.md](../_images/user/profile/profile-step2.png)

Making the `.profile` repository private will hide the Profile README.

Rather than supporting multiple social links on the profile card, under the user
avatar, such links - including
[`rel=me`](https://developer.mozilla.org/en-US/docs/Web/HTML/Attributes/rel/me)
attributes - can be placed in the `.profile` README instead. This gives a user a
lot of flexibility on how they wish to display these links. To add a `rel=me`
attribute, the link should be written in HTML, rather than in Markdown format,
for example: `<a rel="me"
href="https://social.example.com/@username">Fediverse</a>`.
