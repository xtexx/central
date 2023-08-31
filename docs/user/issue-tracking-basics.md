---
title: 'The Basics of Issue Tracking'
license: 'CC-BY-SA-4.0'
origin_url: 'https://codeberg.org/Codeberg/Documentation/src/commit/5d457efc069b52d512632fea024917e0848346cd/content/getting-started/issue-tracking-basics.md'
---

Issues are an important mean of communication on Forgejo.
Besides their original purpose - reporting bugs to a project's maintainer -
they can be used to suggest enhancements, ask for new features, discuss a project's
direction, ask questions and much more.

### The Issue Tracker

![Issues list](../_images/user/issue-tracking-basics/issues-list.png)

You can access the issue tracker of a project by clicking its "Issues" tab **(1)**.

There, you'll see a browsable and filterable **(2)** list of all issues.
Many projects use labels to categorize issues. If you want to contribute to a project,
a good label to look for is the "help wanted" label.

You can switch between issues that are still open, and those that are already resolved **(3)**.

Some projects define milestones **(4)**, to which issues can be assigned. They are good for
visualizing the progress of a project's development.

You can create an issue by clicking on the green "New Issue" button **(5)** at the top left
of the issues list.

Issues in the issue tracker are public, and everyone is able to read and answer them.

An issue can have an assignee, meaning someone responsible for resolving or moderating
the issue. Their profile picture, with a link to their profile, can be seen in the issue
list.

### Life of an Issue

Once an issue in the Issue Tracker has been created, it will usually pass through a
process of review, discussion and closure, which can be more or less strictly defined,
based on the project you're contributing to.

The first thing that might happen is that your issue is categorized using labels.
Your issue may be reviewed by the project's maintainer(s) and evaluated whether it, i.e., is a bug report or feature request.

Then, depending on what type of issue it is, there might be additional questions
or a discussion and, if applicable, the implementation of a solution (or the rejection of
the issue).

Finally, the issue is closed and moved from the list of open issues to the closed one.
Issues might have dependencies on other issues or pull requests preventing them from being closed.

Occasionally, issues may become "stale". That's when there hasn't been any progress for
an extended period of time (usually months). You might consider reviving these, if there
is a strong interest in getting them resolved (and, preferably, if you can contribute
something to them).

> If you encounter an abandoned project and there's no way of contacting the maintainer(s),
> consider forking it, if you want to assume responsibility for it (or, rather, your fork).

### Things to consider

#### Security bugs

If the bug you have found has security implications, **do not create
an issue right away!** Instead try contacting the project's maintainers privately.
Many projects have a dedicated e-mail address for reporting security bugs. If the
project in question doesn't, consider writing an email directly to the project's
maintainer or ask for the address in the issue tracker.

> **⚠** What's important is that you **don't publicly expose security bugs before they are
> fixed _and_ the fixes are deployed**, because **otherwise, you might put the users of that
> project at severe risk**.

#### Existing issues

Before creating a new issue, please make sure that there isn't already an existing
issue about, i.e., the bug you want to report or the feature you want to request.

If there already is an existing issue, please consider commenting on that issue instead,
if there is something more that you can contribute to it.

You should also make sure that the issue has not already been solved by having a look
at the closed issues **(3)** as well.

#### Try to be precise and helpful

Project maintainers love precise information about why, i.e., a bug is happening.

Some projects may even have templates that specifically ask for information like
the operating system or database software used.

If you can provide that information, it will be easier for the project maintainer(s)
to quickly resolve your issue. And if you want it resolved even quicker,
consider writing a Pull Request solving the issue (if possible).

#### Be (reasonably) patient

Please remember that many project maintainers work on their free software projects
in their free time. Some maintainers may answer you within minutes, others within days.
Don't be discouraged if there isn't an immediate answer.
