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

All hardware is running Debian GNU/linux bookworm.

### hetzner01

https://hetzner01.forgejo.org runs on an [EX101](https://www.hetzner.com/dedicated-rootserver/ex101) Hetzner hardware.

There is no backup, no redundancy and is dedicated to Forgejo runner instances.
If the hardware reboots, the runners do not restart automatically, they have to be restarted manually.

It hosts LXC containers setup with [lxc-helpers](https://code.forgejo.org/forgejo/lxc-helpers/):

- `forgejo-runners`

  Dedicated to Forgejo runners for the https://codeberg.org/forgejo organization.

  ```sh
  lxc-helpers.sh lxc_container_run forgejo-runners -- sudo --user debian bash
  cd codeberg.org/forgejo/
  forgejo-runner-3.2.0 --config config.yml daemon >& runner.log &
  ```

- `runner01-lxc`

  Dedicated to Forgejo runners for the https://code.forgejo.org
  organization with two labels: **docker** and **self-hosted**.

  - https://code.forgejo.org/forgejo
  - https://code.forgejo.org/actions
  - https://code.forgejo.org/forgejo-integration
  - https://code.forgejo.org/forgejo-contrib

  ```sh
  lxc-helpers.sh lxc_container_run runner01-lxc -- sudo --user debian bash
  cd code.forgejo.org
  for runner in forgejo-contrib forgejo forgejo-integration actions ; do ( cd $runner ; HOME=/srv/$runner forgejo-runner-3.2.0 --config config.yml daemon >&runner.log & ) ; done
  ```

The runners are installed with something like:

```sh
sudo wget -O /usr/local/bin/forgejo-runner-3.2.0 https://code.forgejo.org/forgejo/runner/releases/download/v3.2.0/forgejo-runner-3.2.0-linux-amd64
sudo chmod +x /usr/local/bin/forgejo-runner-3.2.0
```

### hetzner{02,03}

https://hetzner02.forgejo.org & https://hetzner03.forgejo.org run on [EX44](https://www.hetzner.com/dedicated-rootserver/ex44) Hetzner hardware.

A vSwitch is assigned via the Robot console on both servers
and [configured](https://docs.hetzner.com/robot/dedicated-server/network/vswitch#example-debian-configuration)
in /etc/network/interfaces for each of them with something like:

```
auto enp5s0.4000
iface enp5s0.4000 inet static
  address 10.53.100.2
  netmask 255.255.255.0
  vlan-raw-device enp5s0
  mtu 1400
```

#### Root filesystem backups

- `hetzner03:/etc/cron.daily/backup-hetzner02`
  `rsync -aHS --delete-excluded --delete --numeric-ids --exclude /proc --exclude /dev --exclude /sys --exclude /srv --exclude /var/lib/lxc 10.53.100.2:/ /srv/backups/hetzner02/`
- `hetzner02:/etc/cron.daily/backup-hetzner03`
  `rsync -aHS --delete-excluded --delete --numeric-ids --exclude /proc --exclude /dev --exclude /sys --exclude /srv --exclude /var/lib/lxc 10.53.100.3:/ /srv/backups/hetzner03/`

#### DRBD

DRBD is configured with hetzner02 as the primary and hetzner03 as the secondary:

```
resource r0 {
    net {
        # A : write completion is determined when data is written to the local disk and the local TCP transmission buffer
        # B : write completion is determined when data is written to the local disk and remote buffer cache
        # C : write completion is determined when data is written to both the local disk and the remote disk
        protocol C;
        cram-hmac-alg sha1;
        # any secret key for authentication among nodes
        shared-secret "***";
    }
    disk {
        resync-rate 1000M;
    }
    on hetzner02 {
        address 10.53.100.2:7788;
        volume 0 {
            # device name
            device /dev/drbd0;
            # specify disk to be used for devide above
            disk /dev/nvme0n1p5;
            # where to create metadata
            # specify the block device name when using a different disk
            meta-disk internal;
        }
    }
    on hetzner03 {
        address 10.53.100.3:7788;
        volume 0 {
            device /dev/drbd0;
            disk /dev/nvme1n1p5;
            meta-disk internal;
        }
    }
}
```

The DRBD device is mounted on `/var/lib/lxc`.

In `/etc/fstab` there is a noauto line:

```
/dev/drbd0 /var/lib/lxc ext4 noauto,defaults 0 0
```

To prevent split brain situations a manual step is required at boot
time, on the machine that is going to be the primary, which is
hetzner02 in a normal situation.

```sh
sudo drbdsetup status
sudo drbdadm primary r0
sudo mount /var/lib/lxc
sudo lxc-autostart start
sudo lxc-ls -f
sudo drbdsetup status
```

#### Fast storage on /srv

The second disk on each node is mounted on /srv and can be used when
fast storage is needed and there is no need for backups, such as Forgejo runners.

#### LXC

LXC is setup with [lxc-helpers](https://code.forgejo.org/forgejo/lxc-helpers/).

The `/etc/default/lxc-net` file is the same on both machines:

```
USE_LXC_BRIDGE="true"
LXC_ADDR="10.6.83.1"
LXC_NETMASK="255.255.255.0"
LXC_NETWORK="10.6.83.0/24"
LXC_DHCP_RANGE="10.6.83.2,10.6.83.254"
LXC_DHCP_MAX="253"
LXC_IPV6_ADDR="fc16::216:3eff:fe00:1"
LXC_IPV6_MASK="64"
LXC_IPV6_NETWORK="fc16::/64"
LXC_IPV6_NAT="true"
```

#### Public IP addresses

The public IP addresses attached to the hosts are not failover IPs that can be moved from one host to the next.
The DNS entry needs to be updated if the primary hosts changes.

When additional IP addresses are attached to the server, they are added to `/etc/network/interfaces` like
65.21.67.71 and 2a01:4f9:3081:51ec::102 below.

```
auto enp5s0
iface enp5s0 inet static
  address 65.21.67.73
  netmask 255.255.255.192
  gateway 65.21.67.65
  # route 65.21.67.64/26 via 65.21.67.65
  up route add -net 65.21.67.64 netmask 255.255.255.192 gw 65.21.67.65 dev enp5s0
  # BEGIN code.forgejo.org
  up ip addr add 65.21.67.71/32 dev enp5s0
  up nft -f /home/debian/code.nftables
  down ip addr del 65.21.67.71/32 dev enp5s0
  # END code.forgejo.org

iface enp5s0 inet6 static
  address 2a01:4f9:3081:51ec::2
  netmask 64
  gateway fe80::1
  # BEGIN code.forgejo.org
  up ip -6 addr add 2a01:4f9:3081:51ec::102/64 dev enp5s0
  down ip -6 addr del 2a01:4f9:3081:51ec::102/64 dev enp5s0
  # END code.forgejo.org
```

#### Port forwarding

Forwarding a port to an LXC container can be done with `/home/debian/code.nftables` for
the public IP of code.forgejo.org (65.21.67.71) to the private IP of the `code` LXC container:

```
add table ip code;
flush table ip code;
add chain ip code prerouting {
  type nat hook prerouting priority 0;
  policy accept;
  ip daddr 65.21.67.71 tcp dport { ssh } dnat to 10.6.83.195;
};
```

with `nft -f /root/code.nftables`.

#### Reverse proxy

The reverse proxy forwards to the designated LXC container with
something like the following in
`/etc/nginx/sites-enabled/code.forgejo.org`, where 10.6.83.195 is the
IP allocated to the LXC container running the web service:

```
server {

    server_name code.forgejo.org;

    location / {
        proxy_pass http://10.6.83.195:8080;
        client_max_body_size 2G;
	#
	# http://nginx.org/en/docs/http/websocket.html
	#
        proxy_set_header Connection $http_connection;
        proxy_set_header Upgrade $http_upgrade;
        include proxy_params;
    }
}
```

The LE certificate is obtained once and automatically renewed with:

```
sudo certbot -n --agree-tos --email contact@forgejo.org -d code.forgejo.org --nginx
```

#### Containers

It hosts LXC containers setup with [lxc-helpers](https://code.forgejo.org/forgejo/lxc-helpers/).

- `fogejo-code` on hetzner02

  Dedicated to https://code.forgejo.org

  - LXC creation
    ```sh
    lxc-helpers.sh lxc_container_create --config "docker" forgejo-next
    lxc-helpers.sh --verbose lxc_container_start forgejo-next
    lxc-helpers.sh --verbose lxc_install_docker forgejo-next
    lxc-helpers.sh lxc_container_user_install forgejo-next $(id -u) $USER
    ```
  - upgrades checklist:
    ```sh
    emacs /home/debian/run-forgejo.sh # change the `image=`
    docker stop forgejo
    sudo rsync -av --numeric-ids --delete --progress /srv/forgejo/ /root/forgejo-backup/
    docker rm forgejo
    bash -x /home/debian/run-forgejo.sh
    docker logs -n 200 -f forgejo
    ```

- `forgejo-next` on hetzner02

  Dedicated to https://next.forgejo.org

  - LXC creation same as code.forgejo.org
  - upgrades checklist:
    ```sh
    docker stop forgejo
    docker rm forgejo
    docker rmi codeberg.org/forgejo-experimental/forgejo:1.22.0-test
    docker pull codeberg.org/forgejo-experimental/forgejo:1.22.0-test
    bash -x /home/debian/run-forgejo.sh
    docker logs -n 200 -f forgejo
    ```
  - reset everything
    ```sh
    docker stop forgejo
    docker rm forgejo
    sudo rm -fr /srv/forgejo.old
    sudo mv /srv/forgejo /srv/forgejo.old
    bash -x /home/debian/run-forgejo.sh
    ```
    and create a user with the CLI using the example from `/home/debian/run-forgejo.sh`
  - `/home/debian/next.nftables`
    ```
    add table ip next;
    flush table ip next;
    add chain ip next prerouting {
      type nat hook prerouting priority 0;
      policy accept;
      ip daddr 65.21.67.65 tcp dport { 2020 } dnat to 10.6.83.213;
    };
    ```
  - `/etc/nginx/sites-available/next.forgejo.org` same as `/etc/nginx/sites-available/code.forgejo.org`

  Rotating 30 days backups happen daily /etc/cron.daily/forgejo-code-backup.sh

- `runner-forgejo-helm` on hetzner03

  Dedicated to https://codeberg.org/forgejo-contrib/forgejo-helm and running from an ephemral disk

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
