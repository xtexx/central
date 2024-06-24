---
title: Blocking a user
license: 'CC-BY-SA-4.0'
---

Blocking another user is desirable if they are acting maliciously or are spamming your repository (for instance by adding unsolicited comments in issues). For such cases, Forgejo provides the functionality to block other users. When you block a user, Forgejo does not explicitly notify them, but they may learn through an interaction with you that is blocked.

## How to block someone

In order to block another user, go to their profile page and click on the "Block" button.

![Profile card where block button is shown](../_images/user/block/profile.png)

A popup will show; please read carefully what blocking another user implies, and if you accept the implications, click on Yes.

![Popup where implications of the block action is listed](../_images/user/block/popup.png)

### List of blocked users and unblocking

If you would like to see the list of users you've blocked, navigate to your user profile in the top-right corner and click on the settings item.

![Dropdown that shows up after clicking on the profile in the navigation bar](../_images/user/block/profile_dropdown.png)

Select the Blocked Users item in the menu. This navigates you to the page where the users you've blocked are listed.

![Blocked Users page being selected in the settings menu](../_images/user/block/user_settings.png)

To unblock someone, click on the unblock button next to their name.

![List of people that are currently blocked by the user](../_images/user/block/user_list_blocks.png)

## How to block someone as an organization

It is possible to block a user from an organization, this has the same implications as a normal user blocking another user. To block a user from an organization, you must be on that organization's Owners team.

Navigate to your organization's settings and select the Blocked Users page.

![Blocked Users page being selected in the settings menu](../_images/user/block/org_page.png)

Find the person you want to block in the search bar, select the user and click block.

![Search results being shown to the search query in the search bar](../_images/user/block/org_search.png)

You will now see the blocked users in the list, along with the date they were blocked.

![Blocked person being shown in the blocked users list](../_images/user/block/org_successful.png)

To unblock that person, you can click the unblock button next to their name.

![Blocked person being shown in the blocked users list](../_images/user/block/org_unblock.png)

## Implications of blocking a user

When you block a user:

- You stop following them.
- They stop following you.
- They are removed as collaborators on repositories you own as an individual.
- All pending repository transfers caused by the them are removed.

After you've blocked them:

- They cannot cause any notifications for you anymore by mentioning you.
- They cannot open issues or pull requests on repository you own.
- They cannot add reactions to your comments.
- They cannot post comments on issues and pull request you've opened.
- They cannot transfer repositories to you.
