---
title: Comment on issues and pull requests via email
license: 'CC-BY-SA-4.0'
---

> **NOTE:** this feature is not enabled by default, the [`[email.incoming].ENABLED`](../../admin/config-cheat-sheet/) setting must be set.

When receiving a notification it is possible to reply to the email instead of using the web interface. The content of the reply will be stripped of the quoted text (lines starting with greater than `>`) and used as the content of the comment. The attachments from the reply will be added as attachments to the comment.

It will be taken into account when receiving a notification email about:

- A newly created issue
- A newly created pull request
- A comment added to a specific line of code in a pull request review
- A comment to an existing issue
- A comment to an existing pull request

> **NOTE:** the reply address contains a unique token to match the response with the issue or pull request and looks like this: `forgejo+ABCDE@example.com`. In some mail clients, such as Thunderbird, using this reply address may require using the `Reply List` button rather than the `Reply` button.
