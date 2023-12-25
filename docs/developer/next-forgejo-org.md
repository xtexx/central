---
title: next.forgejo.org
license: 'CC-BY-SA-4.0'
---

_This is the developer documentation for Forgejo Next, covering technical
details for Forgejo contributors.
[Go to end-user documentation for service overview.](../../user/forgejo-next/)_

https://next.forgejo.org, also known as Forgejo Next, is Forgejo's
official testing and demonstration instance. The specific version of
Forgejo running on this instance varies depending on the status of the
latest release branch.

Typically, the instance will be running a recent build straight from the
`forgejo` branch, meaning it contains experimental code that will be
included in the next major version of Forgejo. When a release branch is
created and release candidates are posted, Forgejo Next will be switched
to the latest release candidate. Release candidates are to be deployed
until a stable release is available. next.forgejo.org will then be upgraded
back to the `forgejo` branch.

For details on the hardward from which it is running, [checkout the section in the
infrastructe documentation](../infrastructure/#containers).
