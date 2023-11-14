---
title: code.forgejo.org
license: 'CC-BY-SA-4.0'
---

https://code.forgejo.org is a Forgejo instance running the latest
stable version, starting with the release candidates. It is dedicated
to hosting repositories dedicated to Forgejo development, among which:

- setup-forgejo a Forgejo Action to spawn a Forgejo instance and a runner for testing purposes https://code.forgejo.org/actions/setup-forgejo
- Forgejo Runner https://code.forgejo.org/forgejo/runner
- [ACT](https://github.com/nektos/act) soft fork https://code.forgejo.org/forgejo/act

To make these repositories easier to find, the following push mirrors are in place:

- https://code.forgejo.org/forgejo/runner => https://codeberg.org/forgejo/runner
- https://code.forgejo.org/forgejo/act => https://codeberg.org/forgejo/act

## Hardware

https://code.forgejo.org runs on the `code` LXC container hosted on the [hetzner{02,03}.forgejo.org LXC hypervisor](../infrastructure).

It is deployed and upgraded using the following [Enough command line](https://enough-community.readthedocs.io):

```shell
$ mkdir -p ~/.enough
$ git clone https://forgejo.octopuce.forgejo.org/forgejo/enough-code ~/.enough/code.forgejo.org
$ enough --domain code.forgejo.org service create --host bind-host forgejo
```

Upgrading only Forgejo:

```shell
$ enough --domain code.forgejo.org playbook -- --limit bind-host,localhost --private-key ~/.enough/code.forgejo.org/infrastructure_key venv/share/enough/playbooks/forgejo/forgejo-playbook.yml
```

Login in the machine hosting the Forgejo instance for debugging purposes:

```shell
enough --domain code.forgejo.org ssh bind-host
```
