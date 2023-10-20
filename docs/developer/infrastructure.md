---
title: Hardware infrastructure
license: 'CC-BY-SA-4.0'
---

## Codeberg

Codeberg provides a LXC container with 48GB RAM, 24 threads and SSD drive to be used for the CI. A Forgejo Runner is installed in `/opt/runner` and registered with a token obtained from https://codeberg.org/forgejo. It does not allow running privileged containers or LXC containers for security reasons. The runner is intended to be used for pull requests, for instance in https://codeberg.org/forgejo/forgejo.

## Octopuce

[Octopuce provides hardware](https://codeberg.org/forgejo/sustainability) managed by [the devops team](https://codeberg.org/forgejo/governance/src/branch/main/TEAMS.md#devops). It can be accessed via a VPN which provides a DNS for the `octopuce.forgejo.org` internal domain.

The VPN is deployed and upgraded using the following [Enough command line](https://enough-community.readthedocs.io):

```shell
$ mkdir -p ~/.enough
$ git clone https://forgejo.octopuce.forgejo.org/forgejo/enough-octopuce ~/.enough/octopuce.forgejo.org
$ enough --domain octopuce.forgejo.org service create openvpn
```

## Hetzner

https://hetzner01.forgejo.org runs on an [EX101](https://www.hetzner.com/dedicated-rootserver/ex101) Hetzner hardware.

## OVH

https://code.forgejo.org runs on an OVH virtual machine using the same
OVH account used for the forgejo.org domain name and mails.

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

## Uberspace

The website https://forgejo.org is hosted at
https://uberspace.de/. The https://codeberg.org/forgejo/website/ CI
has credentials to push HTML pages there.

## Installing Forgejo runners

### Preparing the LXC hypervisor

```shell
git clone https://code.forgejo.org/forgejo/lxc-helpers/

lxc-helpers.sh lxc_prepare_environment
sudo lxc-helpers.sh lxc_install_lxc_inside 10.120.13
```

### Creating an LXC container

```shell
lxc-helpers.sh lxc_container_create forgejo-runners
lxc-helpers.sh lxc_container_start forgejo-runners
lxc-helpers.sh lxc_container_user_install forgejo-runners $(id -u) $USER
lxc-helpers.sh lxc_container_run forgejo-runners -- sudo --user debian bash
sudo apt-get update
sudo apt-get install -y wget docker.io emacs-nox
sudo usermod -aG docker $USER # exit & enter again for the group to be active
lxc-helpers.sh lxc_prepare_environment
sudo wget -O /usr/local/bin/forgejo-runner https://code.forgejo.org/forgejo/runner/releases/download/v2.0.4/forgejo-runner-amd64
sudo chmod +x /usr/local/bin/forgejo-runner
echo 'export TERM=vt100' >> .bashrc
```

### Creating a runner

Multiple runners can co-exist on the same machine. To keep things
organized they are located in a directtory that is the same as the url
from which the token is obtained. For instance
DIR=codeberg.org/forgejo-integration means that the token was obtained from the
https://codeberg.org/forgejo-integration organization.

If a runner only provides unprivileged docker containers, the labels
should be
`LABELS=docker:docker://node:16-bullseye,ubuntu-latest:docker://node:16-bullseye`.

If a runner provides LXC containers and unprivileged docker
containers, the labels should be
`LABELS=docker:docker://node:16-bullseye,self-hosted`.

```shell
mkdir -p $DIR ; cd $DIR
forgejo-runner generate-config > config.yml
## edit config.yml
## Obtain a $TOKEN from https://$DIR
forgejo-runner register --no-interactive --token $TOKEN --name runner --instance https://codeberg.org --labels $LABELS
forgejo-runner --config config.yml daemon |& cat -v > runner.log &
```

#### codeberg.org config.yml

- `fetch_timeout: 30s` # because it can be slow at times
- `fetch_interval: 60s` # because there is throttling and 429 replies will mess up the runner
- cache `enabled: false` # because codeberg.org is still v1.19
