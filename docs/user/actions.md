---
title: 'Forgejo Actions user guide'
license: 'CC-BY-SA-4.0'
similar: 'https://github.com/go-gitea/gitea/blob/main/docs/content/doc/usage/actions/faq.en-us.md https://docs.github.com/en/actions'
---

`Forgejo Actions` provides Continuous Integration driven from the files in the `.forgejo/workflows` directory of a repository, with a web interface to show the results. The syntax and semantic of the `workflow` files will be familiar to people used to [GitHub Actions](https://docs.github.com/en/actions) but **they are not and will never be identical**.

The following guide explains key **concepts** to help understand how `workflows` are interpreted, with a set of **examples** that can be copy/pasted and modified to fit particular use cases.

## Quick start

- Verify that `Enable Repository Actions` is checked in the `Repository` tab of the `/{owner}/{repository}/settings` page. If the checkbox does not show it means the administrator of the Forgejo instance did not activate the feature.
  ![enable actions](../../../../images/v1.20/user/actions/enable-repository.png)
- Add the following to the `.forgejo/workflows/demo.yaml` file in the repository.
  ```yaml
  on: [push]
  jobs:
    test:
      runs-on: docker
      steps:
        - run: echo All Good
  ```
  ![demo.yaml file](../../../../images/v1.20/user/actions/demo-yaml.png)
- Go to the `Actions` tab of the `/{owner}/{repository}/actions` page of the repository to see the result of the run.
  ![actions results](../../../../images/v1.20/user/actions/actions-demo.png)
- Click on the workflow link to see the details and the job execution logs.
  ![actions results](../../../../images/v1.20/user/actions/workflow-demo.png)

## Concepts

### Forgejo runner

`Forgejo` itself does not run the `jobs`, it relies on the [Forgejo runner](https://code.forgejo.org/forgejo/runner) to do so. See the [Forgejo Actions administrator guide](../../admin/actions/) for more information.

### Actions

An `Action` is a repository that contains the equivalent of a function in any programming language. It comes in two flavors, depending on the file found at the root of the repository:

- **action.yml:** describes the inputs and outputs of the action and the implementation. See [this example](https://code.forgejo.org/actions/setup-forgejo/src/branch/main/action.yml).
- **Dockerfile:** if no `action.yml` file is found, it is used to create an image with `docker build` and run a container from it to carry out the action. See [this example](https://code.forgejo.org/forgejo/test-setup-forgejo-docker) and [the workflow that uses it](https://code.forgejo.org/actions/setup-forgejo/src/branch/main/testdata/example-docker-action). Note that files written outside of the **workspace** will be lost when the **step** using such an action terminates.

One of the most commonly used action is [checkout](https://code.forgejo.org/actions/checkout#usage) which clones the repository that triggered a `workflow`. Another one is [setup-go](https://code.forgejo.org/actions/setup-go#usage) that will install Go.

Just as any other program of function, an `Action` has pre-requisites to successfully be installed and run. When looking at re-using an existing `Action`, this is an important consideration. For instance [setup-go](https://code.forgejo.org/actions/setup-go) depends on NodeJS during installation.

### Expressions

In a `workflow` file strings that look like `${{ ... }}` are evaluated by the `Forgejo runner` and are called expressions. As a shortcut, `if: ${{ ... }}` is equivalent to `if: ...`, i.e the `${{ }}` surrounding the expression is implicit and can be stripped. [Checkout the example](https://code.forgejo.org/actions/setup-forgejo/src/branch/main/testdata/example-expression/.forgejo/workflows/test.yml) that illustrates expressions.

#### Literals

- boolean: true or false
- null: null
- number: any number format supported by JSON
- string: enclosed in single quotes. Two single quotes

#### Logical operators

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

#### Functions

- `contains( search, item )`. Returns `true` if `search` contains `item`. If `search` is an array, this function returns `true` if the `item` is an element in the array. If `search` is a string, this function returns `true` if the `item` is a substring of `search`. This function is not case sensitive. Casts values to a string.
- `startsWith( searchString, searchValue )`. Returns `true` when `searchString` starts with `searchValue`. This function is not case sensitive. Casts values to a string.
- `endsWith( searchString, searchValue )`. Returns `true` if `searchString` ends with `searchValue`. This function is not case sensitive. Casts values to a string.
- `format( string, replaceValue0, replaceValue1, ..., replaceValueN)`. Replaces values in the `string`, with the variable `replaceValueN`. Variables in the `string` are specified using the `{N}` syntax, where `N` is an integer. You must specify at least one `replaceValue` and `string`. Escape curly braces using double braces.
- `join( array, optionalSeparator )`. The value for `array` can be an array or a string. All values in `array` are concatenated into a string. If you provide `optionalSeparator`, it is inserted between the concatenated values. Otherwise, the default separator `,` is used. Casts values to a string.
- `toJSON(value)`. Returns a pretty-print JSON representation of `value`.
- `fromJSON(value)`. Returns a JSON object or JSON data type for `value`. You can use this function to provide a JSON object as an evaluated expression or to convert environment variables from a string.

### Caching commonly used files

When a `job` starts, it can communicate with the `Forgejo runner` to
fetch commonly used files that were saved by previous runs. For
instance the https://code.forgejo.org/actions/setup-go action will do
that by default to save downloading and compiling packages found in
`go.mod`.

It is also possible to explicitly control what is cached and when
using the https://code.forgejo.org/actions/cache action.

### Services

PostgreSQL, redis and other services can be run from container images with something similar to the following. See also the [set of examples](https://code.forgejo.org/actions/setup-forgejo/src/branch/main/testdata/example-service/.forgejo/workflows/).

```yaml
services:
  pgsql:
    image: postgres:15
    env:
      POSTGRES_DB: test
      POSTGRES_PASSWORD: postgres
```

A container with the specified `image:` is run before the `job` starts and is terminated when it completes. The job can address the service using its name, in this case `pgsql`.

The IP address of `pgsql` is on the same [docker network](https://docs.docker.com/engine/reference/commandline/network/) as the container running the **steps** and there is no need for port binding (see the [docker run --publish](https://docs.docker.com/engine/reference/commandline/run/) option for more information). The `postgres:15` image exposes the PostgreSQL port 5432 and a client will be able to connect as [shown in this example](https://code.forgejo.org/actions/setup-forgejo/src/branch/main/testdata/example-service/.forgejo/workflows/postgresql.yml)

#### image

The location of the container image to run.

#### env

Key/value pairs injected in the environment when running the container, equivalent to [--env](https://docs.docker.com/engine/reference/commandline/run/).

#### cmd

A list of command and arguments, equivalent to [[COMMAND] [ARG...]](https://docs.docker.com/engine/reference/commandline/run/).

#### options

A string of additional options, as documented [docker run](https://docs.docker.com/engine/reference/commandline/run/). For instance: "--workdir /myworkdir --ulimit nofile=1024:1024".

> **NOTE:** the `--volume` option is restricted to a whitelist of volumes configured in the runner executing the task. See the [Forgejo Actions administrator guide](../../admin/actions/) for more information.

#### username

The username to authenticate with the registry where the image is located.

#### password

The password to authenticate with the registry where the image is located.

## The list of runners and their tasks

A `Forgejo runner` listens on a `Forgejo` instance, waiting for jobs. To figure out if a runner is available for a given repository, go to `/{owner}/{repository}/settings/actions/runners`. If there are none, you can run one for yourself on your laptop.

![list of runners](../../../../images/v1.20/user/actions/list-of-runners.png)

Some runners are **Global** and are available for every repository, others are only available for the repositories within a given user or organization. And there can even be runners dedicated to a single repository. The `Forgejo` administrator is the only one able to launch a **Global** runner. But the user who owns an organization can launch a runner without requiring any special permission. All they need to do is to get a runner registration token and install the runner on their own laptop or on a server of their choosing (see the [Forgejo Actions administrator guide](../../admin/actions/) for more information).

Clicking on the pencil icon next to a runner shows the list of tasks it executed, with the status and a link to display the details of the execution.

![show the runners tasks](../../../../images/v1.20/user/actions/runner-tasks.png)

## The list of tasks in a repository

From the `Actions` tab in a repository, the list of ongoing and past tasks triggered by this repository is displayed with their status.

![the list of actions in a repository](../../../../images/v1.20/user/actions/actions-list.png)

Following the link on a task displays the logs and the `Re-run all jobs` button. It is also possible to re-run a specific job by hovering on it and clicking on the arrows.

![the details of an action](../../../../images/v1.20/user/actions/actions-detail.png)

## Pull request actions are moderated

The first time a user proposes a pull request, the task is blocked to reduce the security risks.

![blocked action](../../../../images/v1.20/user/actions/action-blocked.png)

It can be approved by a maintainer of the project and there will be no need to unblock future pull requests.

![button to approve an action](../../../../images/v1.20/user/actions/action-approve.png)

## Secrets

A repository, a user or an organization can hold secrets, a set of key/value pairs that are stored encrypted in the `Forgejo` database and revealed to the `workflows` as `${{ secrets.KEY }}`. They can be defined from the web interface:

- in `/org/{org}/settings/actions/secrets` to be available in all the repositories that belong to the organization
- in `/user/settings/actions/secrets` to be available in all the repositories that belong to the logged in user
- in `/{owner}/{repo}/settings/actions/secrets` to be available to the `workflows` of a single repository

![add a secret](../../../../images/v1.20/user/actions/secret-add.png)

Once the secret is added, its value cannot be changed or displayed.

![secrets list](../../../../images/v1.20/user/actions/secret-list.png)

## Workflow reference guide

The syntax and semantic of the YAML file describing a `workflow` are partially explained here. When an entry is missing the [GitHub Actions](https://docs.github.com/en/actions) documentation can help because there are similarities. But there also are significant differences that deserve testing.

### on

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

| trigger event               | activity types                                                                                                           |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| create                      | not applicable                                                                                                           |
| delete                      | not applicable                                                                                                           |
| fork                        | not applicable                                                                                                           |
| gollum                      | not applicable                                                                                                           |
| push                        | not applicable                                                                                                           |
| issues                      | `opened`, `edited`, `closed`, `reopened`, `assigned`, `unassigned`, `milestoned`, `demilestoned`, `labeled`, `unlabeled` |
| issue_comment               | `created`, `edited`, `deleted`                                                                                           |
| pull_request                | `opened`, `edited`, `closed`, `reopened`, `assigned`, `unassigned`, `synchronize`, `labeled`, `unlabeled`                |
| pull_request_review         | `submitted`, `edited`                                                                                                    |
| pull_request_review_comment | `created`, `edited`                                                                                                      |
| release                     | `published`, `edited`                                                                                                    |
| registry_package            | `published`                                                                                                              |

Not everything from https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows is implemented yet. Please refer to the [forgejo/actions package source code](https://codeberg.org/forgejo/forgejo/src/branch/forgejo/modules/actions/workflows.go) and the [list of webhook event names](https://codeberg.org/forgejo/forgejo/src/branch/forgejo/modules/webhook/type.go) to find out about supported triggers.

### env

Set environment variables that are available in the workflow in the `env` `context` and as regular environment variables.

```yaml
env:
  KEY1: value1
  KEY2: value2
```

- The expression `${{ env.KEY1 }}` will be evaluated to `value1`
- The environment variable `KEY1` will be set to `value1`

[Checkout the example](https://code.forgejo.org/actions/setup-forgejo/src/branch/main/testdata/example-expression/.forgejo/workflows/test.yml).

### jobs

#### runs-on

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

![actions results](../../../../images/v1.20/user/actions/list-of-runners.png)

##### container

By default the `docker` label will create a container from a [Node.js 16 Debian GNU/Linux bullseye image](https://hub.docker.com/_/node/tags?name=16-bullseye) and will run each `step` as root. Since an application container is used, the jobs will inherit the limitations imposed by the engine (Docker for instance). In particular they will not be able to run or install software that depends on `systemd`.

If the default image is unsuitable, a job can specify an alternate container image with `container:`, [as shown in this example](https://code.forgejo.org/actions/setup-forgejo/src/branch/main/testdata/example-container/.forgejo/workflows/test.yml). For instance the following will ensure the job is run using [Alpine 3.18](https://hub.docker.com/_/alpine/tags?name=3.18).

```yaml
runs-on: docker
container:
  image: alpine:3.18
```

##### options

A string of additional options, as documented [docker run](https://docs.docker.com/engine/reference/commandline/run/). For instance: "--workdir /myworkdir --ulimit nofile=1024:1024".

> **NOTE:** the `--volume` option is restricted to a whitelist of volumes configured in the runner executing the task. See the [Forgejo Actions administrator guide](../../admin/actions/) for more information.

##### LXC

The `runs-on: self-hosted` label will run the jobs in a [LXC](https://linuxcontainers.org/lxc/) container where software that rely on `systemd` can be installed. Nested containers can also be created recursively (see [the setup-forgejo integration tests](https://code.forgejo.org/actions/setup-forgejo/src/branch/main/.forgejo/workflows/integration.yml) for an example).

`Services` are not supported for jobs that run on LXC.

#### steps

##### uses

Specifies the repository from which the `Action` will be cloned or a directory where it can be found.

###### Remote actions

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

###### Local actions

An action that begins with a `./` will be loaded from a directory
instead of being cloned from a repository. The structure of the
directory is otherwise the same as if it was located in a remote
repository.

> **NOTE:** the most common mistake when using an action included in the repository under test is to forget to checkout the repository with `uses: actions/checkout@v3`.

[Checkout the example](https://code.forgejo.org/actions/setup-forgejo/src/branch/main/testdata/example-local-action/).

###### with

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

[Checkout the example](https://code.forgejo.org/actions/setup-forgejo/src/branch/main/testdata/example-local-action/.forgejo/workflows/test.yml)

For remote actions that are implemented with a `Dockerfile` instead of `action.yml`, the `args` key is used as command line arguments when the container is run.

[Checkout the example](https://code.forgejo.org/actions/setup-forgejo/src/branch/main/testdata/example-docker-action/.forgejo/workflows/test.yml)

## Debugging workflows with forgejo-runner exec

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

## Examples

Each example is part of the [setup-forgejo](https://code.forgejo.org/actions/setup-forgejo/) action [test suite](https://code.forgejo.org/actions/setup-forgejo/src/branch/main/testdata). They can be run locally with something similar to:

```sh
$ git clone --depth 1 http://code.forgejo.org/actions/setup-forgejo
$ cd setup-forgejo
$ forgejo-runner exec --workflows testdata/example-expression/.forgejo/workflows/test.yml
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

- [Echo](https://code.forgejo.org/actions/setup-forgejo/src/branch/main/testdata/example-echo/.forgejo/workflows/test.yml) - a single step that prints one sentence
- [Expression](https://code.forgejo.org/actions/setup-forgejo/src/branch/main/testdata/example-expression/.forgejo/workflows/test.yml) - a collection of various forms of expression
- [Local actions](https://code.forgejo.org/actions/setup-forgejo/src/branch/main/testdata/example-local-action/.forgejo) - using an action found in a directory instead of a remote repository
- [PostgreSQL service](https://code.forgejo.org/actions/setup-forgejo/src/branch/main/testdata/example-service/.forgejo/workflows/postgres.yml) - a PostgreSQL service and a connection to display the (empty) list of tables of the default database
- [Using services](https://code.forgejo.org/actions/setup-forgejo/src/branch/main/testdata/example-service/.forgejo/workflows/) - illustrates how to configure and use services
- [Choosing the image with `container`](https://code.forgejo.org/actions/setup-forgejo/src/branch/main/testdata/example-container/.forgejo/workflows/test.yml) - replacing the `runs-on: docker` image with the `alpine:3.18` image using `container:`
- [Docker action](https://code.forgejo.org/actions/setup-forgejo/src/branch/main/testdata/example-docker-action/.forgejo/workflows/test.yml) - using a action implemented as a `Dockerfile`

## Glossary

- **action:** a repository that can be used in a way similar to a function in any programming language to run a single **step**.
- **expression:** a string enclosed in `${{ ... }}` and evaluated at runtime
- **job:** a sequential set of **steps**.
- **label** the kind of machine that is matched against the value of `runs-on` in a **workflow**.
- **runner:** the [Forgejo runner](https://code.forgejo.org/forgejo/runner) daemon tasked to execute the **workflows**.
- **step:** a command the **runner** is required to carry out.
- **workflow or task:** a file in the `.forgejo/workflows` directory that contains **jobs**.
- **workspace** is the directory where the files of the **job** are stored and shared between all **step**s
