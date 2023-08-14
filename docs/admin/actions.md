---
title: 'Forgejo Actions administrator guide'
license: 'CC-BY-SA-4.0'
---

`Forgejo Actions` provides continuous integration driven from the files in the `.forgejo/workflows` directory of a repository. It is still in beta and disabled by default. It can be activated by adding the following to `app.ini`:

```yaml
[actions]
ENABLED = true
```

`Forgejo` itself does not run the jobs, it relies on the [Forgejo runner](https://code.forgejo.org/forgejo/runner) to do so.

## Default Actions URL

When `uses:` does not specify an absolution URL for the `Action`, the
value of `DEFAULT_ACTIONS_URL` is prepended to it.

```yaml
[actions]
ENABLED = true
DEFAULT_ACTIONS_URL = https://code.forgejo.org
```

The actions found at https://code.forgejo.org are:

- known to work with Forgejo Actions
- published under a Free Software license

They can be found in the following organizations:

- [General purpose actions](https://code.forgejo.org/actions)
- [Docker actions](https://code.forgejo.org/docker)

When setting `DEFAULT_ACTIONS_URL` to a Forgejo instance with an open
registration, **care must be taken to avoid name conflicts**. For
instance if an action has `uses: foo/bar@main` it will clone and try
to run the action found at `DEFAULT_ACTIONS_URL/foo/bar` if it exists,
even if it provides something different than what is expected.

## Forgejo runner

### Installation

Download the latest [binary release](https://code.forgejo.org/forgejo/runner/releases) and verify their signature:

```shell
$ wget -O forgejo-runner https://code.forgejo.org/forgejo/runner/releases/download/v2.3.0/forgejo-runner-amd64
$ chmod +x forgejo-runner
$ wget -O forgejo-runner.asc https://code.forgejo.org/forgejo/runner/releases/download/v2.3.0/forgejo-runner-amd64.asc
$ gpg --keyserver keys.openpgp.org --recv EB114F5E6C0DC2BCDD183550A4B61A2DC5923710
$ gpg --verify forgejo-runner.asc forgejo-runner
Good signature from "Forgejo <contact@forgejo.org>"
                aka "Forgejo Releases <release@forgejo.org>"
```

#### Docker

For jobs to run in containers, the `Forgejo runner` needs access to [Docker](https://docs.docker.com/engine/install/).

#### Podman

While Podman is generally compatible to Docker,
it does not run socket for managing containers by default
(because it doesn't usually need one).

If the Forgejo runner complains about "daemon Docker Engine socket not found", or "cannot ping the docker daemon",
you can use podman to provide a Docker compatible socket from an unprivileged user
and pass that socket on to the runner,
e.g. by executing:

```shell
$ podman system service -t 0 &
$ DOCKER_HOST=unix://${XDG_RUNTIME_DIR}/podman/podman.sock ./forgejo-runner daemon
```

#### LXC

For jobs to run in LXC containers, the `Forgejo runner` needs passwordless sudo access for all `lxc-*` commands on a Debian GNU/Linux `bookworm` system where [LXC](https://linuxcontainers.org/lxc/) is installed. The [LXC helpers](https://code.forgejo.org/forgejo/lxc-helpers/) can be used as follows to create a suitable container:

```shell
$ git clone https://code.forgejo.org/forgejo/lxc-helpers
$ sudo cp -a lxc-helpers/lxc-helpers{,-lib}.sh /usr/local/bin
$ lxc-helpers.sh lxc_container_create myrunner
$ lxc-helpers.sh lxc_container_start myrunner
$ lxc-helpers.sh lxc_container_user_install forgejo-runners 1000 debian
```

> **NOTE:** Multiarch [Go](https://go.dev/) builds and [binfmt](https://github.com/tonistiigi/binfmt) need `bookworm` to produce and test binaries on a single machine for people who do not have access to dedicated hardware. If this is not needed, installing the `Forgejo runner` on `bullseye` will also work.

The `Forgejo runner` can then be installed and run within the `myrunner` container.

```shell
$ lxc-helpers.sh lxc_container_run forgejo-runners -- sudo --user debian bash
$ sudo apt-get install docker.io wget gnupg2
$ wget -O forgejo-runner https://code.forgejo.org/forgejo/runner/releases/download/v2.3.0/forgejo-runner-amd64
...
```

> **Warning:** LXC containers do not provide a level of security that makes them safe for potentially malicious users to run jobs. They provide an excellent isolation for jobs that may accidentally damage the system they run on.

### Registration

The `Forgejo runner` needs to connect to a `Forgejo` instance and must be registered before doing so. It will give it permission to read the repositories and send back information to `Forgejo` such as the logs or its status.

#### Online registration

A special kind of token is needed and can be obtained from the `Create new runner` button:

- in `/admin/runners` to gain access to all repositories.
- in `/org/{org}/settings/actions/runners` to gain access to all repositories within the organization.
- in `/user/settings/actions/runners` to gain access to all repositories of the logged in user
- in `/{owner}/{repository}/settings/actions/runners` to gain access to a single repository.

![add a runner](../../../../images/v1.20/user/actions/runners-add.png)

For instance, using a token obtained for a test repository from `next.forgejo.org`:

```shell
forgejo-runner register --no-interactive --token {TOKEN} --name runner --instance https://next.forgejo.org --labels docker:docker://node:16-bullseye,self-hosted
INFO Registering runner, arch=amd64, os=linux, version=2.3.0.
INFO Runner registered successfully.
```

It will create a `.runner` file that looks like:

```json
{
  "WARNING": "This file is automatically generated. Do not edit.",
  "id": 6,
  "uuid": "fcd0095a-291c-420c-9de7-965e2ebaa3e8",
  "name": "runner",
  "token": "{TOKEN}",
  "address": "https://next.forgejo.org",
  "labels": ["docker:docker://node:16-bullseye", "self-hosted"]
}
```

#### Offline registration

When Infrastructure as Code (Ansible, kubernetes, etc.) is used to
deploy and configure both Forgejo and the Forgejo runner, it may be
more convenient for it to generate a secret and share it with both.

The `forgejo forgejo-cli actions register --secret <secret>` subcommand can be
used to register the runner with the Forgejo instance and the
`forgejo-runner create-runner-file --secret <secret>` subcommand can
be used to configure the Forgejo runner with the credentials that will
allow it to start picking up tasks from the Forgejo instances as soon
as it comes online.

For instance, on the machine running Forgejo:

```sh
$ forgejo forgejo-cli actions register --name runner-name --scope myorganization \
          --labels docker \
          --secret 7c31591e8b67225a116d4a4519ea8e507e08f71f
```

and on the machine on which the Forgejo runner is installed:

```sh
$ forgejo-runner create-runner-file --instance https://example.conf \
                 --secret 7c31591e8b67225a116d4a4519ea8e507e08f71f
```

> **NOTE:** the labels known to the runner are defined in the `config.yml` and **MUST** match the labels provided to the `forgejo-cli actions register` command above. In this example, `labels: ['docker:docker://node:16-bullseye']` will tell the Forgejo runner that when a **job** specifies `runs-on: docker`, it will run in a container created from the `node:16-bullseye` image by default.

### Configuration

The default configuration for the runner can be
displayed with `forgejo-runner generate-config`, stored in a
`config.yml` file, modified and used instead of the default with the
`--config` flag.

```yaml
$ forgejo-runner generate-config > config.yml
# Example configuration file, it's safe to copy this as the default config file without any modification.

log:
  # The level of logging, can be trace, debug, info, warn, error, fatal
  level: info

runner:
  # Where to store the registration result.
  file: .runner
  # Execute how many tasks concurrently at the same time.
  capacity: 1
  # Extra environment variables to run jobs.
  envs:
    A_TEST_ENV_NAME_1: a_test_env_value_1
    A_TEST_ENV_NAME_2: a_test_env_value_2
  # Extra environment variables to run jobs from a file.
  # It will be ignored if it's empty or the file doesn't exist.
  env_file: .env
  # The timeout for a job to be finished.
  # Please note that the Forgejo instance also has a timeout (3h by default) for the job.
  # So the job could be stopped by the Forgejo instance if it's timeout is shorter than this.
  timeout: 3h
  # Whether skip verifying the TLS certificate of the Forgejo instance.
  insecure: false
  # The timeout for fetching the job from the Forgejo instance.
  fetch_timeout: 5s
  # The interval for fetching the job from the Forgejo instance.
  fetch_interval: 2s
  # The labels of a runner are used to determine which jobs the runner can run, and how to run them.
  # Like: ["macos-arm64:host", "ubuntu-latest:docker://node:16-bullseye", "ubuntu-22.04:docker://node:16-bullseye"]
  # If it's empty when registering, it will ask for inputting labels.
  # If it's empty when execute `deamon`, will use labels in `.runner` file.
  labels: []

cache:
  # Enable cache server to use actions/cache.
  enabled: true
  # The directory to store the cache data.
  # If it's empty, the cache data will be stored in $HOME/.cache/actcache.
  dir: ""
  # The host of the cache server.
  # It's not for the address to listen, but the address to connect from job containers.
  # So 0.0.0.0 is a bad choice, leave it empty to detect automatically.
  host: ""
  # The port of the cache server.
  # 0 means to use a random available port.
  port: 0

container:
  # Specifies the network to which the container will connect.
  # Could be host, bridge or the name of a custom network.
  # If it's empty, create a network automatically.
  network: ""
  # Whether to use privileged mode or not when launching task containers (privileged mode is required for Docker-in-Docker).
  privileged: false
  # And other options to be used when the container is started (eg, --add-host=my.forgejo.url:host-gateway).
  options:
  # The parent directory of a job's working directory.
  # If it's empty, /workspace will be used.
  workdir_parent:
  # Volumes (including bind mounts) can be mounted to containers. Glob syntax is supported, see https://github.com/gobwas/glob
  # You can specify multiple volumes. If the sequence is empty, no volumes can be mounted.
  # For example, if you only allow containers to mount the `data` volume and all the json files in `/src`, you should change the config to:
  # valid_volumes:
  #   - data
  #   - /src/*.json
  # If you want to allow any volume, please use the following configuration:
  # valid_volumes:
  #   - '**'
  valid_volumes: []
  # overrides the docker client host with the specified one.
  # If it's empty, act_runner will find an available docker host automatically.
  # If it's "-", act_runner will find an available docker host automatically, but the docker host won't be mounted to the job containers and service containers.
  # If it's not empty or "-", the specified docker host will be used. An error will be returned if it doesn't work.
  docker_host: ""

host:
  # The parent directory of a job's working directory.
  # If it's empty, $HOME/.cache/act/ will be used.
  workdir_parent:
```

### Cache configuration

Some actions such as https://code.forgejo.org/actions/cache or
https://code.forgejo.org/actions/setup-go can communicate with the
`Forgejo runner` to save and restore commonly used files such as
compilation dependencies. They are stored as compressed tar archives,
fetched when a job starts and saved when it completes.

If the machine has a fast disk, uploading the cache when the job
starts may significantly reduce the bandwidth required to download
and rebuild dependencies.

If the machine on which the `Forgejo runner` is running has a slow
disk and plenty of CPU and bandwidth, it may be better to not activate
the cache as it can slow down the execution time.

### Running the daemon

Once the `Forgejo runner` is successfully registered, it can be run from the directory in which the `.runner` file is found with:

```shell
$ forgejo-runner daemon
INFO[0000] Starting runner daemon
```

To verify it is actually available for the targeted repository, go to `/{owner}/{repository}/settings/actions/runners`. It will show the runners:

- dedicated to the repository with the **repo** type
- available to all repositories within an organization or a user
- available to all repositories, with the **Global** type

![list the runners](../../../../images/v1.20/user/actions/list-of-runners.png)

Adding the `.forgejo/workflows/demo.yaml` file to the test repository:

```yaml
on: [push]
jobs:
  test:
    runs-on: docker
    steps:
      - run: echo All Good
```

Will send a job request to the `Forgejo runner` that will display logs such as:

```shell
...
INFO[2023-05-28T18:54:53+02:00] task 29 repo is earl-warren/test https://code.forgejo.org https://next.forgejo.org
...
[/test] [DEBUG] Working directory '/workspace/earl-warren/test'
| All Good
[/test]   ✅  Success - Main echo All Good
```

It will also show a similar output in the `Actions` tab of the repository.

If no `Forgejo runner` is available, `Forgejo` will wait for one to connect and submit the job as soon as it is available.

### Labels and `runs-on`

The workflows / tasks defined in the files found in `.forgejo/workflows` must specify the environment they need to run with `runs-on`. Each `Forgejo runner` declares with **labels** which one they support so `Forgejo` knows sends them tasks accordingly. For instance if a job within a workflow has:

```yaml
runs-on: docker
```

it will be submitted to a runner that registered with a `docker` label (for instance with `--labels docker:docker://node:16-bullseye`).

#### Docker

If `runs-on` is matched to a label that contains `docker://`, the rest of it is interpreted as the default container image to use if no other is specified. The runner will execute all the steps, as root, within a container created from that image.

#### LXC

If `runs-on` is `self-hosted`, the runner will execute all the steps, as root, within a Debian GNU/Linux `bullseye` LXC container.

### Host environment

Certain hosts may require specific configurations for runners to work smoothly. Anything specific to these host environments can be found below.

#### NixOS

The `gitea-actions-runner` recipe was released in NixOS 23.05. It can be configured via `services.gitea-actions-runner`.

Please note that the `services.gitea-actions-runner.instances.<name>.labels` key may be set to `[]` (an empty list) to use the packaged Forgejo instance list. One of `virtualisation.docker.enable` or `virtualisation.podman.enable` will need to be set. The default Forgejo image list is populated with docker images.

##### IPv6 on docker

IPv6 support is not enabled by default in docker. The following snippet enables this.

```nix
virtualisation.docker = {
  daemon.settings = {
    fixed-cidr-v6 = "fd00::/80";
    ipv6 = true;
  };
};
```
