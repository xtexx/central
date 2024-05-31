---
title: 'Moderation tools'
license: 'CC-BY-SA-4.0'
---

Moderation tools are meant to help the Forgejo users and admins cope
with spam bots and undesirable interactions.

`[admin].SEND_NOTIFICATION_EMAIL_ON_NEW_USER` can be set to `true` on
small Forgejo instances with an open registration. Such instances are
subject to occasional spam bots registrations and saves the admin the
trouble to check on a regular basis. Read more in the [config cheat
sheet](../config-cheat-sheet/#security-security).

On large instances the moderation team may be too busy with fighting
spam to handle problematic relationships between users. Self
moderation tools may help in this case and allow users to block any
unwanted interaction from another user. Read more in the [user
blocking guide](../../user/blocking-user/).

To delete a user, including all the repositories or issues they
created the Forgejo admin can either:

- Use the administration panel of the web interface
- Use the `forgejo admin user delete --purge` command line. Read more in the [command line documentation](../command-line/#delete).
