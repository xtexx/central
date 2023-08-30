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
until a stable release is available, at which point the stable release
will be deployed. After the release has been sufficiently tested (often
after it's deployed to Codeberg), next.forgejo.org will then be upgraded
back to the `forgejo` branch.

next.forgejo.org is generously hosted by Codeberg to help the Forgejo
community test and demonstrate its product. The instance runs inside
its own LXC container on Codeberg's infrastructure. When SNI-enabled
traffic bound for next.forgejo.org reaches Codeberg's proxy on port 443,
the raw TCP traffic is forwarded to the container, allowing the instance
to terminate the SSL/TLS and obtain its own certificate using Forgejo's
inbuilt ACME client. The proxy also forwards port 2222 to the container
for SSH access. Additionally, Codeberg provides a database on their
existing MariaDB host for the instance to use.

Inside the container, the Forgejo binary is manually installed to
`/usr/local/bin/forgejo` with the service managed by systemd.
Configuration is loaded from `/etc/forgejo/app.ini`.
_TODO: Semi-automated deployment with Forgejo Actions._

Since the container is inside Codeberg's infrastructure, logging into
it for maintainence is subject to Codeberg's security policy. If you
need to access it, please
[seek approval from the Forgejo community](https://codeberg.org/forgejo/governance/issues),
then contact Codeberg staff for more information.

<!-- TODO: Add more information about the requirements and how to set it up after seeking Codeberg's approval -->

When working with the container, it's important to avoid breaking anything
in a way that will cause any user data to be lost. Users of next.forgejo.org
are expected to keep their own backups of any important data they upload,
but we also wish to encourage casual use of the instance for legitimate
projects, not just test repos, so the instance should _not_ be considered
disposable.
