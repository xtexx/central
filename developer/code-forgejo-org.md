---
layout: '~/layouts/Markdown.astro'
title: code.forgejo.org
license: 'CC-BY-SA-4.0'
---

https://code.forgejo.org is a Forgejo instance running the latest stable
version. It is dedicated to hosting the following repositories:

- Default Forgejo Runner actions https://code.forgejo.org/actions
- Forgejo Runner https://code.forgejo.org/forgejo/runner
- [ACT](https://github.com/nektos/act) soft fork https://code.forgejo.org/forgejo/act
- [Infrastructure as code](https://enough-community.readthedocs.io) used to deploy code.forgejo.org https://code.forgejo.org/forgejo/infrastructure
- [Infrastructure as code](https://enough-community.readthedocs.io) secrets in a private repository

To make these repositories easier to find, the following push mirrors are in place:

- https://code.forgejo.org/forgejo/runner => https://codeberg.org/forgejo/runner
- https://code.forgejo.org/forgejo/act => https://codeberg.org/forgejo/act

## Infrastructure

https://code.forgejo.org runs on an OVH virtual machine using the same
OVH account used for the forgejo.org domain name and mails.

It is deployed and upgraded using the following [Enough command line](https://enough-community.readthedocs.io):

```shell
$ mkdir -p ~/.enough
$ git clone https://code.forgejo.org/forgejo/<secret repository> ~/.enough/code.forgejo.org
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
