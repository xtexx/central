---
title: 'Forgejo Actions user guide'
license: 'CC-BY-SA-4.0'
similar: 'https://github.com/go-gitea/gitea/blob/main/docs/content/doc/usage/actions/faq.en-us.md https://docs.github.com/en/actions'
---

`Forgejo Actions` provides Continuous Integration driven from the files in the `.forgejo/workflows` directory of a repository, with a web interface to show the results. The syntax and semantics of the `workflow` files will be familiar to people used to [GitHub Actions](https://docs.github.com/en/actions) but **they are not and will never be identical**.

The following guide explains key **concepts** to help understand how `workflows` are interpreted, with a set of **examples** that can be copy/pasted and modified to fit particular use cases.

## Quick start

- Verify that `Enable Repository Actions` is checked in the `Repository` tab of the `/{owner}/{repository}/settings` page. If the checkbox does not show it means the administrator of the Forgejo instance did not activate the feature.
  ![enable actions](../_images/user/actions/enable-repository.png)
- Add the following to the `.forgejo/workflows/demo.yaml` file in the repository.
  ```yaml
  on: [push]
  jobs:
    test:
      runs-on: docker
      steps:
        - run: echo All Good
  ```
  ![demo.yaml file](../_images/user/actions/demo-yaml.png)
- Go to the `Actions` tab of the `/{owner}/{repository}/actions` page of the repository to see the result of the run.
  ![actions results](../_images/user/actions/actions-demo.png)
- Click on the workflow link to see the details and the job execution logs.
  ![actions results](../_images/user/actions/workflow-demo.png)

## Actions

An `Action` is a repository that contains the equivalent of a function in any programming language. It comes in two flavors, depending on the file found at the root of the repository:

- **action.yml:** describes the inputs and outputs of the action and the implementation. See [this example](https://code.forgejo.org/actions/setup-forgejo/src/branch/main/action.yml).
- **Dockerfile:** if no `action.yml` file is found, it is used to create an image with `docker build` and run a container from it to carry out the action. See [this example](https://code.forgejo.org/forgejo/test-setup-forgejo-docker) and [the workflow that uses it](https://code.forgejo.org/forgejo/end-to-end/src/branch/main/actions/example-docker-action). Note that files written outside of the **workspace** will be lost when the **step** using such an action terminates.

One of the most commonly used action is [checkout](https://code.forgejo.org/actions/checkout#usage) which clones the repository that triggered a `workflow`. Another one is [setup-go](https://code.forgejo.org/actions/setup-go#usage) that will install Go.

Just as any other program of function, an `Action` has pre-requisites to successfully be installed and run. When looking at re-using an existing `Action`, this is an important consideration. For instance [setup-go](https://code.forgejo.org/actions/setup-go) depends on NodeJS during installation.

## Automatic token

At the start of each `workflow`, a unique authentication token is
automatically created and destroyed when it completes. It can be used
to read the repositories associated with the workflow, even when they
are private. It is available:

- in the environment of each step as `GITHUB_TOKEN`
- as `github.token`
- as `env.GITHUB_TOKEN`
- as `secrets.GITHUB_TOKEN`

This token can only be used for interactions with the repository of
the project and any attempt to use it on other repositories, even
for creating an issue, will return a 404 error.

This token also has write permission to the repository and can be used
to push commits or use API endpoints such as creating a label or merge
a pull request.

In order to avoid infinite recursion, no `workflow` will be triggered
as a side effect of a change authored with this token. For instance,
if a branch is pushed to the repository and there exists a workflow that
is triggered on push events, it will not fire.

A `workflow` triggered by a `pull_request` event is an exception: in
that case the token does not have write permissions to the repository.
The pull request could contain an untested or malicious workflow.

## Expressions

In a `workflow` file strings that look like `${{ ... }}` are evaluated by the `Forgejo runner` and are called expressions. As a shortcut, `if: ${{ ... }}` is equivalent to `if: ...`, i.e the `${{ }}` surrounding the expression is implicit and can be stripped. [Check out the example](https://code.forgejo.org/forgejo/end-to-end/src/branch/main/actions/example-expression/.forgejo/workflows/test.yml) that illustrates expressions.

### Literals

- boolean: true or false
- null: null
- number: any number format supported by JSON
- string: enclosed in single quotes

### Logical operators

| Operator | Description           |
| -------- | --------------------- |
| `( )`    | Logical grouping      |
| `[ ]`    | Index                 |
| `.`      | Property de-reference |
| `!`      | Not                   |
| `<`      | Less than             |
| `<=`     | Less than or equal    |
| `>`      | Greater than          |
| `>=`     | Greater than or equal |
| `==`     | Equal                 |
| `!=`     | Not equal             |
| `&&`     | And                   |
| `\|\|`   | Or                    |

> **NOTE:** String comparisons are case insensitive.

### Functions

- `contains( search, item )`. Returns `true` if `search` contains `item`. If `search` is an array, this function returns `true` if the `item` is an element in the array. If `search` is a string, this function returns `true` if the `item` is a substring of `search`. This function is not case sensitive. Casts values to a string.
- `startsWith( searchString, searchValue )`. Returns `true` when `searchString` starts with `searchValue`. This function is not case sensitive. Casts values to a string.
- `endsWith( searchString, searchValue )`. Returns `true` if `searchString` ends with `searchValue`. This function is not case sensitive. Casts values to a string.
- `format( string, replaceValue0, replaceValue1, ..., replaceValueN)`. Replaces values in the `string`, with the variable `replaceValueN`. Variables in the `string` are specified using the `{N}` syntax, where `N` is an integer. You must specify at least one `replaceValue` and `string`. Escape curly braces using double braces.
- `join( array, optionalSeparator )`. The value for `array` can be an array or a string. All values in `array` are concatenated into a string. If you provide `optionalSeparator`, it is inserted between the concatenated values. Otherwise, the default separator `,` is used. Casts values to a string.
- `toJSON(value)`. Returns a pretty-print JSON representation of `value`.
- `fromJSON(value)`. Returns a JSON object or JSON data type for `value`. You can use this function to provide a JSON object as an evaluated expression or to convert environment variables from a string.

## Sharing files between jobs

Two `jobs`, even if they are part of the same `workflow`, may run on
different machines. The files created on the file system of the host
by one `job` cannot be re-used by the `job` that follows because it
may run on a different machine.

There are three ways for a `job` to upload and download files,
depending on the use case:

- Using the cache provided by the `Forgejo runner`, for instance to
  speed up compilation of the cache happens to contain the required file.
- Using the artifacts provided by the `Forgejo` server, for instance to
  share files between `jobs` within the same `workflow`.
- Using the [a generic package](../packages/generic) to publish assets
  such as screenshots.

### Artifacts

`Artifacts` allow you to persist data after a `job` has completed, and
share that data with another `job` in the same `workflow`. An `artifact` is
a file or collection of files produced during a `workflow` run. For
example, you can use `artifacts` to save your build and test output
after a workflow run has ended. All `actions` and `workflows` called
within a run have write access to that run's `artifacts`.

The artifacts created by a `workflow` can be downloaded from the web
interface that shows the the details of the jobs for a `workflow`.

![download artifacts](../_images/user/actions/actions-download-artifact.png)

The `artifacts` expire after a delay that defaults to 90 days, but this value
can be modified by the instance admin.

[Check out the example](https://code.forgejo.org/forgejo/end-to-end/src/branch/main/actions/example-artifacts/.forgejo/workflows)
based on the [upload-artifact](https://code.forgejo.org/actions/upload-artifact) action and
the [download-artifact](https://code.forgejo.org/actions/download-artifact) action.

### Cache

When a `job` starts, it can communicate with the `Forgejo runner` to
fetch commonly used files that were saved by previous runs. For
instance the https://code.forgejo.org/actions/setup-go action will do
that by default to save downloading and compiling packages found in
`go.mod`.

It is also possible to explicitly control what is cached (and when)
by using the https://code.forgejo.org/actions/cache action.

There is no guarantee that the cache is populated, even when two `jobs`
run in sequence. It is not a substitute for `artifacts`.

## Auto cancelation of workflows

When a new commit is pushed to a branch, the workflows that are were
triggered by parent commits are canceled.

## Services

PostgreSQL, redis and other services can be run from container images with something similar to the following. See also the [set of examples](https://code.forgejo.org/forgejo/end-to-end/src/branch/main/actions/example-service/.forgejo/workflows/).

```yaml
services:
  pgsql:
    image: postgres:15
    env:
      POSTGRES_DB: test
      POSTGRES_PASSWORD: postgres
```

A container with the specified `image:` is run before the `job` starts and is terminated when it completes. The job can address the service using its name, in this case `pgsql`.

The IP address of `pgsql` is on the same [docker network](https://docs.docker.com/engine/reference/commandline/network/) as the container running the **steps** and there is no need for port binding (see the [docker run --publish](https://docs.docker.com/engine/reference/commandline/run/) option for more information). The `postgres:15` image exposes the PostgreSQL port 5432 and a client will be able to connect as [shown in this example](https://code.forgejo.org/forgejo/end-to-end/src/branch/main/actions/example-service/.forgejo/workflows/postgresql.yml)

### image

The location of the container image to run.

### env

Key/value pairs injected in the environment when running the container, equivalent to [--env](https://docs.docker.com/engine/reference/commandline/run/).

### cmd

A list of command and arguments, equivalent to [[COMMAND] [ARG...]](https://docs.docker.com/engine/reference/commandline/run/).

### options

A string of additional options, as documented [docker run](https://docs.docker.com/engine/reference/commandline/run/). For instance: "--workdir /myworkdir --ulimit nofile=1024:1024".

> **NOTE:** the `--volume` option is restricted to a whitelist of volumes configured in the runner executing the task. See the [Forgejo Actions administrator guide](../../admin/actions/) for more information.

### username

The username to authenticate with the registry where the image is located.

### password

The password to authenticate with the registry where the image is located.

## Forgejo runner

`Forgejo` itself does not run the `jobs`, it relies on the [Forgejo runner](https://code.forgejo.org/forgejo/runner) to do so. See the [Forgejo Actions administrator guide](../../admin/actions/) for more information.

### List of runners and their tasks

A `Forgejo runner` listens on a `Forgejo` instance, waiting for jobs. To figure out if a runner is available for a given repository, go to `/{owner}/{repository}/settings/actions/runners`. If there are none, you can run one for yourself on your laptop.

![list of runners](../_images/user/actions/list-of-runners.png)

Some runners are **Global** and are available for every repository, others are only available for the repositories within a given user or organization. And there can even be runners dedicated to a single repository. The `Forgejo` administrator is the only one able to launch a **Global** runner. But the user who owns an organization can launch a runner without requiring any special permission. All they need to do is to get a runner registration token and install the runner on their own laptop or on a server of their choosing (see the [Forgejo Actions administrator guide](../../admin/actions/) for more information).

Clicking on the pencil icon next to a runner shows the list of tasks it executed, with the status and a link to display the details of the execution.

![show the runners tasks](../_images/user/actions/runner-tasks.png)

### List of tasks in a repository

From the `Actions` tab in a repository, the list of ongoing and past tasks triggered by this repository is displayed with their status.

![the list of actions in a repository](../_images/user/actions/actions-list.png)

Following the link on a task displays the logs and the `Re-run all jobs` button. It is also possible to re-run a specific job by hovering on it and clicking on the arrows.

![the details of a task](../_images/user/actions/actions-detail.png)

A `workflow` can be disabled (or enabled) by selecting it and using the three dot menu to the right.

![disabling a workflow](../_images/user/actions/actions-disable.png)

## Pull request workflows are moderated

The first time a user proposes a pull request, the `on.pull_request`
workflows are blocked.

![blocked action](../_images/user/actions/action-blocked.png)

They can be approved by a maintainer of the project and there will be
no need to unblock future pull requests.

![button to approve an action](../_images/user/actions/action-approve.png)

The `on.pull_request_target` workflows are not subject to the same
restriction and will always run.

## Secrets

A repository, a user or an organization can hold secrets, a set of key/value pairs that are stored encrypted in the `Forgejo` database and revealed to the `workflows` as `${{ secrets.KEY }}`. They can be defined from the web interface:

- in `/org/{org}/settings/actions/secrets` to be available in all the repositories that belong to the organization
- in `/user/settings/actions/secrets` to be available in all the repositories that belong to the logged in user
- in `/{owner}/{repo}/settings/actions/secrets` to be available to the `workflows` of a single repository

![add a secret](../_images/user/actions/secret-add.png)

Once the secret is added, its value cannot be changed or displayed.

![secrets list](../_images/user/actions/secret-list.png)

## Variables

A repository, a user or an organization can hold variables, a set of key/value pairs that are stored in the `Forgejo` database and available to the `workflows` as `${{ vars.KEY }}`. They can be defined from the web interface:

- in `/org/{org}/settings/actions/variables` to be available in all the repositories that belong to the organization
- in `/user/settings/actions/variables` to be available in all the repositories that belong to the logged in user
- in `/{owner}/{repo}/settings/actions/variables` to be available to the `workflows` of a single repository

![add a variable](../_images/user/actions/variable-add.png)

After a variable is added, its value can be modified.

![variables list](../_images/user/actions/variable-list.png)

### Name constraints

The following rules apply to variable names:

- Variable names can only contain alphanumeric characters (`[a-z]`, `[A-Z]`, `[0-9]`) or underscores (`_`). Spaces are not allowed.
- Variable names must not start with the `FORGEJO_`, `GITHUB_` or `GITEA_` prefix.
- Variable names must not start with a number.
- Variable names are case-insensitive.
- Variable names must be unique at the level they are created at.
- Variable names must not be `CI`.

### Precedence

A variable found in the settings of the owner of a repository (organization or user) has precedence
over the same variable found in a repository.

## Workflow reference guide

The syntax and semantics of the YAML file describing a `workflow` are _partially_ explained here. When an entry is missing the [GitHub Actions](https://docs.github.com/en/actions) documentation may be helpful because there are similarities. But there also are significant differences that require testing.

The name of each chapter is a pseudo YAML path where user defined
values are in `<>`. For instance `jobs.<job_id>.runs-on` documents the
following YAML equivalent where `job-id` is `myjob`:

```yaml
jobs:
  myjob:
    runs-on: docker
```

### `on`

Workflows will be triggered `on` certain events with the following:

```yaml
on:
  <event-name>:
    <event-parameter>:
    ...
```

e.g. to run a workflow when branch `main` is pushed

```yaml
on:
  push:
    branches:
      - main
```

### `on.pull_request`

Trigger the workflow when an event happens on a pull request, as
specified with the `types` event parameter. It defaults to `[opened,
synchronize, reopened]` if not specified.

- `opened` the pull request was created.
- `reopened` the closed pull request was reopened.
- `closed` the pull request was closed or merged.
- `labeled` a label was added.
- `unlabeled` a label was removed.
- `synchronize` the commits associated with the pull request were modified.
- `assigned` an assignee was added.
- `unassigned` an assignee was removed.
- `edited` the body, title or comments of the pull request were modified.

```yaml
on:
  pull_request:
    types: [opened, synchronize, reopened]
```

If the head of a pull request is from a forked repository, the secrets
are not available and the automatic token only has read permissions.

[Check out the example](https://code.forgejo.org/forgejo/end-to-end/src/branch/main/actions/example-pull-request/.forgejo/workflows/test.yml).

### `on.pull_request_target`

It is similar to the `on.pull_request` event, with the following exceptions:

- secrets stored in the base repository are available in the `secrets` context, (e.g. `${{ secrets.KEY }}`).
- the workflow runs in the context of the default branch of the base repository, meaning that:
  - changes to the workflow in the pull request will be ignored
  - the [actions/checkout](https://code.forgejo.org/actions/checkout) action will checkout the default branch instead
    of the content of the pull request

[Check out the example](https://code.forgejo.org/forgejo/end-to-end/src/branch/main/actions/example-pull-request/.forgejo/workflows/test.yml).

### `on.schedule`

The `schedule` event allows you to trigger a workflow at a scheduled
time. When a workflow with a `schedule` event is present in the
default branch, Forgejo will add a task to run it at the
designated time. The scheduled workflows on other branches or pull
requests are ignored.

The scheduled time is specified using
the [POSIX cron syntax](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/crontab.html#tag_20_25_07).
See also the [crontab(5)](https://linux.die.net/man/5/crontab) manual page for a more information and some examples.

```yaml
on:
  schedule:
    - cron: '30 5,17 * * *'
```

[Check out the example](https://code.forgejo.org/forgejo/end-to-end/src/branch/main/actions/example-cron/.forgejo/workflows/test.yml).

### `env`

Set environment variables that are available in the workflow in the `env` `context` and as regular environment variables.

```yaml
env:
  KEY1: value1
  KEY2: value2
```

- The expression `${{ env.KEY1 }}` will be evaluated to `value1`
- The environment variable `KEY1` will be set to `value1`

[Check out the example](https://code.forgejo.org/forgejo/end-to-end/src/branch/main/actions/example-expression/.forgejo/workflows/test.yml).

### `jobs.<job_id>`

Each `job` in a `workflow` must specify the kind of machine it needs to run its `steps` with `runs-on`. For instance `docker` in the following `workflow`:

```yaml
---
jobs:
  test:
    runs-on: docker
```

means that the `Forgejo runner` that claims to provide a kind of machine labelled `docker` will be selected by `Forgejo` and sent the job to be run.

The actual machine provided by the runner **entirely depends on how the `Forgejo runner` was registered** (see the [Forgejo Actions administrator guide](../../admin/actions/) for more information).

The list of available `labels` for a given repository can be seen in the `/{owner}/{repo}/settings/actions/runners` page.

![actions results](../_images/user/actions/list-of-runners.png)

### `jobs.<job_id>.runs-on`

By default the `docker` label will create a container from a [Node.js 16 Debian GNU/Linux bullseye image](https://hub.docker.com/_/node/tags?name=16-bullseye) and will run each `step` as root. Since an application container is used, the jobs will inherit the limitations imposed by the engine (Docker for instance). In particular they will not be able to run or install software that depends on `systemd`.

The `runs-on: lxc` label will run the jobs in a [LXC](https://linuxcontainers.org/lxc/) container where software that rely on `systemd` can be installed. Nested containers can also be created recursively (see [the `end-to-end` tests](https://code.forgejo.org/forgejo/end-to-end/src/branch/main/.forgejo/workflows/integration.yml) for an example). `Services` are not supported for jobs that run on LXC.

The `runs-on: self-hosted` label will run the jobs directly on the host, in a shell spawned from the runner. It provides no isolation at all.

### `jobs.<job_id>.container`

- **Docker or Podman:**
  If the default image is unsuitable, a job can specify an alternate container image with `container:`, [as shown in this example](https://code.forgejo.org/forgejo/end-to-end/src/branch/main/actions/example-container/.forgejo/workflows/test.yml). For instance the following will ensure the job is run using [Alpine 3.18](https://hub.docker.com/_/alpine/tags?name=3.18).

  ```yaml
  runs-on: docker
  container:
    image: alpine:3.18
    ## Optionally provide credentials if the registry requires authentication.
    #credentials:
    #  username: "root"
    #  password: "admin1234"
  ```

- **LXC:**
  If the default [template and release](https://images.linuxcontainers.org/) are unsuitable, a job can specify an alternate template and release as follows.

  ```yaml
  runs-on: lxc
  container:
    image: debian:bookworm
  ```

### `jobs.<job_id>.container.options`

A string of additional options, as documented in [docker run](https://docs.docker.com/engine/reference/commandline/run/). For instance: "--workdir /myworkdir --ulimit nofile=1024:1024".

> **NOTE:** the `--volume` option is restricted to a whitelist of volumes configured in the runner executing the task. See the [Forgejo Actions administrator guide](../../admin/actions/) for more information.

### `jobs.<job_id>.steps`

An array of steps executed sequentially on the host specified by `runs-on`.

### `jobs.<job_id>.steps.if`

The step is run if the **expression** evaluates to true. The following additional boolean functions are supported:

- `success()`. returns true when none of the previous steps have failed or been canceled.
- `always()`. causes the step to always execute, and returns true, even when canceled. If you want to run a job or step regardless of its success or failure, use the recommended alternative: **!cancelled()**.
- `failure()`. returns true when any previous step of a job fails.

Check out the workflows in [example-if](https://code.forgejo.org/forgejo/end-to-end/src/branch/main/actions/example-if/) and [example-if-fail](https://code.forgejo.org/forgejo/end-to-end/src/branch/main/actions/example-if-fail/).

### `jobs.<job_id>.steps.uses`

Specifies the repository from which the `Action` will be cloned or a directory where it can be found.

- Remote actions
  A relative `Action` such as `uses: actions/checkout@v3` will clone the repository at the URL composed by prepending the default actions URL which is https://code.forgejo.org/. It is the equivalent of providing the fully qualified URL `uses: https://code.forgejo.org/actions/checkout@v3`. In other words the following:

  ```yaml
  on: [push]
  jobs:
    test:
      runs-on: docker
      steps:
        - uses: actions/checkout@v3
  ```

  is the same as:

  ```yaml
  on: [push]
  jobs:
    test:
      runs-on: docker
      steps:
        - uses: https://code.forgejo.org/actions/checkout@v3
  ```

  When possible **it is strongly recommended to choose fully qualified
  URLs** to avoid ambiguities. During installation, the `Forgejo'
  instance may use another default URL and a workflow could fail because
  it gets an outdated version from https://tooold.org/actions/checkout
  instead. Or even a repository that does not contain the intended
  action.

- Local actions

  An action that begins with a `./` will be loaded from a directory
  instead of being cloned from a repository. The structure of the
  directory is otherwise the same as if it was located in a remote
  repository.

  > **NOTE:** the most common mistake when using an action included in the repository under test is to forget to checkout the repository with `uses: actions/checkout@v3`.

  [Check out the example](https://code.forgejo.org/forgejo/end-to-end/src/branch/main/actions/example-local-action/).

### `jobs.<job_id>.steps.with`

A dictionary mapping the inputs of the action to concrete values. The `action.yml` defines and documents the inputs.

```yaml
on: [push]
jobs:
  ls:
    runs-on: docker
    steps:
      - uses: actions/checkout@v3
      - id: local-action
        uses: ./.forgejo/local-action
        with:
          input-two-required: 'two'
```

[Check out the example](https://code.forgejo.org/forgejo/end-to-end/src/branch/main/actions/example-local-action/.forgejo/workflows/test.yml)

For remote actions that are implemented with a `Dockerfile` instead of `action.yml`, the `args` key is used as command line arguments when the container is run.

[Check out the example](https://code.forgejo.org/forgejo/end-to-end/src/branch/main/actions/example-docker-action/.forgejo/workflows/test.yml)

## Debugging workflows

### Errors in the YAML file

When the YAML file describing the workflow contains an error that can
be detected with static analysis, it is signaled by a warning sign in
the actions task list of the repository, next to the file name that
contains the workflow. Hovering on the file name will show a tooltip
with a detailed error message.

![actions results](../_images/user/actions/actions-syntax-error.png)

### With forgejo-runner exec

To get a quicker debug loop when working on a workflow, it may be more
convenient to run them on your laptop using `forgejo-runner exec`. For
instance:

```sh
$ git clone --depth 1 http://code.forgejo.org/forgejo/runner
$ cd runner
$ forgejo-runner exec --workflows .forgejo/workflows/test.yml --job lint
INFO[0000] Using default workflow event: push
INFO[0000] Planning job: lint
INFO[0000] cache handler listens on: http://192.168.1.20:44261
INFO[0000] Start server on http://192.168.1.20:34567
[checks/check and test] 🚀  Start image=node:16-bullseye
[checks/check and test]   🐳  docker pull image=node:16-bullseye platform= username= forcePull=false
[checks/check and test]   🐳  docker create image=node:16-bullseye platform= entrypoint=["/bin/sleep" "10800"] cmd=[]
[checks/check and test]   🐳  docker run image=node:16-bullseye platform= entrypoint=["/bin/sleep" "10800"] cmd=[]
[checks/check and test]   ☁  git clone 'https://code.forgejo.org/actions/setup-go' # ref=v3
[checks/check and test] ⭐ Run Main actions/setup-go@v3
[checks/check and test]   🐳  docker cp src=/home/loic/.cache/act/actions-setup-go@v3/ dst=/var/run/act/actions/actions-setup-go@v3/
...
|
| ==> Ok
|
[checks/check and test]   ✅  Success - Main test
[checks/check and test] ⭐ Run Post actions/setup-go@v3
[checks/check and test]   🐳  docker exec cmd=[node /var/run/act/actions/actions-setup-go@v3/dist/cache-save/index.js] user= workdir=
[checks/check and test]   ✅  Success - Post actions/setup-go@v3
[checks/check and test] Cleaning up services for job check and test
[checks/check and test] Cleaning up container for job check and test
[checks/check and test] Cleaning up network for job check and test, and network name is: FORGEJO-ACTIONS-TASK-push_WORKFLOW-checks_JOB-check-and-test-network
[checks/check and test] 🏁  Job succeeded
```

> **NOTE:** When Docker or Podman is used and IPv6 support is required, the `--enable-ipv6` flag must be provided, and IPv6 must be enabled in the `Forgejo runner`'s Docker daemon configuration. See the [Forgejo Actions administrator guide](../../admin/actions/) for more information.

## Examples

Each example is part of the [setup-forgejo](https://code.forgejo.org/forgejo/end-to-end/) action [test suite](https://code.forgejo.org/forgejo/end-to-end/src/branch/main/actions). They can be run locally with something similar to:

```sh
$ git clone --depth 1 http://code.forgejo.org/forgejo/end-to-end
$ cd end-to-end
$ forgejo-runner exec --workflows actions/example-expression/.forgejo/workflows/test.yml
INFO[0000] Using the only detected workflow event: push
INFO[0000] Planning jobs for event: push
INFO[0000] cache handler listens on: http://192.168.1.20:43773
INFO[0000] Start server on http://192.168.1.20:34567
[test.yml/test] 🚀  Start image=node:16-bullseye
[test.yml/test]   🐳  docker pull image=node:16-bullseye platform= username= forcePull=false
[test.yml/test]   🐳  docker create image=node:16-bullseye platform= entrypoint=["/bin/sleep" "10800"] cmd=[]
[test.yml/test]   🐳  docker run image=node:16-bullseye platform= entrypoint=["/bin/sleep" "10800"] cmd=[]
[test.yml/test] ⭐ Run Main set -x
test "KEY1=value1" = "KEY1=value1"
test "KEY2=$KEY2" = "KEY2=value2"
[test.yml/test]   🐳  docker exec cmd=[bash --noprofile --norc -e -o pipefail /var/run/act/workflow/0] user= workdir=
| + test KEY1=value1 = KEY1=value1
| + test KEY2=value2 = KEY2=value2
[test.yml/test]   ✅  Success - Main set -x
test "KEY1=value1" = "KEY1=value1"
test "KEY2=$KEY2" = "KEY2=value2"
[test.yml/test] Cleaning up services for job test
[test.yml/test] Cleaning up container for job test
[test.yml/test] Cleaning up network for job test, and network name is: FORGEJO-ACTIONS-TASK-push_WORKFLOW-test-yml_JOB-test-network
[test.yml/test] 🏁  Job succeeded
```

- [Echo](https://code.forgejo.org/forgejo/end-to-end/src/branch/main/actions/example-echo/.forgejo/workflows/test.yml) - a single step that prints one sentence.
- [Expression](https://code.forgejo.org/forgejo/end-to-end/src/branch/main/actions/example-expression/.forgejo/workflows/test.yml) - a collection of various forms of expression.
- [Local actions](https://code.forgejo.org/forgejo/end-to-end/src/branch/main/actions/example-local-action/.forgejo) - using an action found in a directory instead of a remote repository.
- [PostgreSQL service](https://code.forgejo.org/forgejo/end-to-end/src/branch/main/actions/example-service/.forgejo/workflows/test.yml) - a PostgreSQL service and a connection to display the (empty) list of tables of the default database.
- [Using services](https://code.forgejo.org/forgejo/end-to-end/src/branch/main/actions/example-service/.forgejo/workflows/test.yml) - illustrates how to configure and use services.
- [Choosing the image with `container`](https://code.forgejo.org/forgejo/end-to-end/src/branch/main/actions/example-container/.forgejo/workflows/test.yml) - replacing the `runs-on: docker` image with the `alpine:3.18` image using `container:`.
- [Docker action](https://code.forgejo.org/forgejo/end-to-end/src/branch/main/actions/example-docker-action/.forgejo/workflows/test.yml) - using a action implemented as a `Dockerfile`.
- [`on.pull_request` and `on.pull_request_target` events](https://code.forgejo.org/forgejo/end-to-end/src/branch/main/actions/example-pull-request/.forgejo/workflows/test.yml).
- [`on.schedule` event](https://code.forgejo.org/forgejo/end-to-end/src/branch/main/actions/example-cron/.forgejo/workflows/test.yml).
- [Artifacts upload and download](https://code.forgejo.org/forgejo/end-to-end/src/branch/main/actions/example-artifacts/.forgejo/workflows/test.yml) - sharing files between `jobs`.

## Glossary

- **action:** a repository that can be used in a way similar to a function in any programming language to run a single **step**.
- **expression:** a string enclosed in `${{ ... }}` and evaluated at runtime
- **job:** a sequential set of **steps**.
- **label** the kind of machine that is matched against the value of `runs-on` in a **workflow**.
- **runner:** the [Forgejo runner](https://code.forgejo.org/forgejo/runner) daemon tasked to execute the **workflows**.
- **step:** a command the **runner** is required to carry out.
- **workflow or task:** a file in the `.forgejo/workflows` directory that contains **jobs**.
- **workspace** is the directory where the files of the **job** are stored and shared between all **step**s
- **automatic token** is the token created at the begining of each **workflow**
- **artifact** is a file or collection of files produced during a **workflow** run.
