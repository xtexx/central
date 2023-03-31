---
layout: '~/layouts/Markdown.astro'
title: 'Email Settings'
license: 'CC-BY-SA-4.0'
origin_url: 'https://codeberg.org/Codeberg/Documentation/src/commit/ceec82002bbdc62cf27974e84df51369a4bfe0f9/content/getting-started/email-settings.md'
---

By default, Forgejo will send notifications to your registered email addresses.

## Configuring all notifications

To change your notification preferences, go to your [Account Settings](https://codeberg.org/user/settings/account) or manually navigate to the settings page.

You can access it by clicking on the menu button “Profile and Settings...” in the top-right corner of Forgejo. From this dropdown, click on Settings, then click on the Account tab.

In the section “Manage Email Addresses”, you can select one of the following options from the drop-down menu for each email address that you have registered with Forgejo:

| Option                      | Effect                                                                                                 |
| :-------------------------- | :----------------------------------------------------------------------------------------------------- |
| Enable Email Notifications  | Enables all notifications (default setting)                                                            |
| Only Email on Mention       | Forgejo will only send an email to this address if your username is mentioned in an issue or a comment |
| Disable Email Notifications | Forgejo will not send any emails to this address                                                       |

When you're finished, press the button “Set Email Preference” to confirm your selection.

> **Note:**
> Disabling email notifications doesn't mean that you'll stop receiving important messages from the Forgejo organisation.

## Issue notifications

As soon as you make a comment on an issue, you automatically subscribe to it. Unless you disabled email notifications for all your email addresses, you will get an email for every change and comment on that issue.

You can check and modify your issue subscription status under the “Notifications” section on the menu on the right side of the issue screen.

## Watching repositories

When you watch a repository (by clicking on the “Watch” button in a repository), you will receive emails for every change (creation of issues, pull requests, comments, etc.) done in this repository.

To stop watching a repository, simply click on “Unwatch” in a repository.
