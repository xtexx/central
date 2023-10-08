---
title: 'Profile customization'
license: 'Apache-2.0'
origin_url: 'https://github.com/go-gitea/gitea/blob/abe8fe352711601fbcd24bf4505f7e0b81a93c5d/docs/content/usage/profile-readme.en-us.md'
---

By default the profile page of a user is the list of repositories they
own. It is possible to customize it with a short description that
shows to the left, under their avatar. It can now be fully
personalized with a markdown file that is displayed instead of the
list of repositories.

![Profile page](../_images/user/profile/profile-step1.png)

It uses the `README.md` file from the `.profile` repository of the
user, if it exists.

![Profile README.md](../_images/user/profile/profile-step2.png)

Making the `.profile` repository private will hide the Profile README.
