---
title: 'Installation with Docker'
license: 'CC-BY-SA-4.0'
---

Forgejo provides [container images](https://codeberg.org/forgejo/-/packages/container/forgejo/versions) for use with Docker or other containerization tools.

```shell
docker pull codeberg.org/forgejo/forgejo:7.0.0
```

If `codeberg.org` can not be accessed you can replace every mention of `codeberg.org` with `code.forgejo.org` to use our mirror.

The **7** tag is set to be the latest minor release, starting with **7.0.0**. The **7** tag will then be equal to **7.0.0** when it is released and so on.

Upgrading from **X** to **X+1** (for instance from **7** to **8**) requires a [manual operation and human verification](../upgrade/). However it is possible to use the **X** tag (for instance **7**) to get the latest minor release automatically.

Here is a sample [docker-compose](https://docs.docker.com/compose/install/) file:

```yaml
version: '3'

networks:
  forgejo:
    external: false

services:
  server:
    image: codeberg.org/forgejo/forgejo:7
    container_name: forgejo
    environment:
      - USER_UID=1000
      - USER_GID=1000
    restart: always
    networks:
      - forgejo
    volumes:
      - ./forgejo:/data
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
    ports:
      - '3000:3000'
      - '222:22'
```

Note that the volume should be owned by the user/group with the UID/GID specified in the config file.
If you don't give the volume correct permissions, the container may not start.

## Configuration

The Forgejo configuration is stored in the `app.ini` file as described
in the [Configuration Cheat Sheet](../config-cheat-sheet). When using
the Forgejo container image, this file is automatically created if it
does not exist already. In addition it is possible to add settings
using configuration variables. For instance:

```
FORGEJO__repository__ENABLE_PUSH_CREATE_USER=true
```

is the equivalent of adding the following to `app.ini`:

```
[repository]
ENABLE_PUSH_CREATE_USER = true
```

> **NOTE:** it is not possible to use environment variables to remove an existing value, it must be done by editing the `app.ini` file.

> **NOTE:** in case you are in a selinux environment check the audit logs if you are having issues with containers.

## Databases

In the following each database is shown as part of a `docker-compose` example file, with a `diff like` presentation that highlights additions to the example above.

If no database is configured, it will default to using SQLite.

### MySQL database

```yaml
version: "3"

networks:
  forgejo:
    external: false

services:
  server:
    image: codeberg.org/forgejo/forgejo:7
    container_name: forgejo
    environment:
      - USER_UID=1000
      - USER_GID=1000
+      - FORGEJO__database__DB_TYPE=mysql
+      - FORGEJO__database__HOST=db:3306
+      - FORGEJO__database__NAME=forgejo
+      - FORGEJO__database__USER=forgejo
+      - FORGEJO__database__PASSWD=forgejo
    restart: always
    networks:
      - forgejo
    volumes:
      - ./forgejo:/data
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
    ports:
      - "3000:3000"
      - "222:22"
+    depends_on:
+      - db
+
+  db:
+    image: mysql:8
+    restart: always
+    environment:
+      - MYSQL_ROOT_PASSWORD=forgejo
+      - MYSQL_USER=forgejo
+      - MYSQL_PASSWORD=forgejo
+      - MYSQL_DATABASE=forgejo
+    networks:
+      - forgejo
+    volumes:
+      - ./mysql:/var/lib/mysql
```

### PostgreSQL database

```yaml
version: "3"

networks:
  forgejo:
    external: false

services:
  server:
    image: codeberg.org/forgejo/forgejo:7
    container_name: forgejo
    environment:
      - USER_UID=1000
      - USER_GID=1000
+      - FORGEJO__database__DB_TYPE=postgres
+      - FORGEJO__database__HOST=db:5432
+      - FORGEJO__database__NAME=forgejo
+      - FORGEJO__database__USER=forgejo
+      - FORGEJO__database__PASSWD=forgejo
    restart: always
    networks:
      - forgejo
    volumes:
      - ./forgejo:/data
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
    ports:
      - "3000:3000"
      - "222:22"
+    depends_on:
+      - db
+
+  db:
+    image: postgres:14
+    restart: always
+    environment:
+      - POSTGRES_USER=forgejo
+      - POSTGRES_PASSWORD=forgejo
+      - POSTGRES_DB=forgejo
+    networks:
+      - forgejo
+    volumes:
+      - ./postgres:/var/lib/postgresql/data
```

## Hosting repository data on remote storage systems

You might also mount the data and repository folders on a remote drive such as a
network-attached storage system. While there are a multitude of possible solutions,
we will focus on a somewhat minimal setup with NFS here and explain what
measures have to be taken in general so that the administrators can adapt this to
their individual setup.

We begin to describe a possible setup and will try to highlight all important aspects which
the administrator will have to consider if a different hosting environment is present.
An important assumption for the Forgejo image to make is to own the folders it writes into
and reads from. This is naturally an issue since file-system permissions are a machine-local
concept and don't translate over the network easily.

We assume that a server with the hostname `server` is accessible which has a folder `/repositories`
shared via NFS. Append an entry to your `/etc/exports` like

```shell
[...]
/repositories	*(rw,sync,all_squash,sec=sys,anonuid=1024,anongid=100)
```

Four aspects to consider:

- The folder is mounted as `rw`, meaning clients can both read and write in the folder.
- The folder is mounted as `sync`. This is NFS-specific but means that transactions block until they are finished. This is
  not essential but increases the robustness against file corruption
- The `all_squash` setting maps all file accesses to an anonymous user, meaning that both the files of a user with the UID of `1050`
  and `1051` are mapped to a single `UID` on the server.
- We set these anonymous (G/U)ID to explicit values on the server with `anonuid=1024,anongid=100`. Hence all files will be owned by
  a user with the UID `1024`, belonging to a group `100`. Make sure the UID is available and a group with that ID is present.

Effectively we are now able to write and create files and folders on the remote share. With the `all_squash` setting, we map
all users to one user, hence all data writable by one user is writable by all users, implying all files have a `drwxrwxrwx`
setting (abbreviated "`0777` permissions"). We can also "fake-own" data, since all `chown` calls are now mapped to the anonymous user. This is an
important behaviour.
We now mount this folder on the `client` which will host Forgejo to a folder `/mnt/repositories`...

```shell
# mount -o hard,timeo=10,retry=10,vers=4.1 server:/repositories /mnt/repositories/
```

... and create two folders

```shell
$ mkdir conf
$ mkdir data
```

To consider in the NFS client setup is the `hard` setting, blocking all file operations if the share is not available.
This prevents state changes in the repository which could potentially corrupt the repository data and is an NFS-specific setting.

We will use the `rootless` image, which hosts the `ssh` server for Forgejo embedded. A possible entry for a `docker-compose` file
would look like this (shown as a `diff like` view to the example shown [in our initial example](#installation-with-docker)):

```yaml
version: "3"

networks:
  forgejo:
    external: false

services:
  server:
-    image: codeberg.org/forgejo/forgejo:7
+    image: codeberg.org/forgejo/forgejo:7-rootless
    container_name: forgejo
    environment:
+      - USER_UID=1024
+      - USER_GID=100
-      - USER_UID=1000
-      - USER_GID=1000

    restart: always
    networks:
      - forgejo
    volumes:
-      - ./forgejo:/data
+      - /mnt/repositories/data:/data
+      - /mnt/repositories/conf:/etc/gitea
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
    ports:
      - "3000:3000"
      - "222:22"
```

This will write the configuration into our created `conf` folder and all other data into the `data` folder.
Make sure that `USER_UID` and `USER_GID` match the `anonuid` and `anongid` setting
in the NFS server setting here such that the Forgejo user sees files and folders with the same UID and GID
in the respective folders and thus identifies itself as the sole owner of the folder structure.

Using the `rootless` image here solves another problem resulting from the file-system ownership issue.
If we create ssh keys on the `client` image and save them on the `server`, they too will have `0777` permissions, which is prohibited by `openssh`.
It is important for all involved tools that these files not be writable by just anybody with a login, so you would get you an error if you try to use them.
Changing permissions will also not succeed through the chosen `all_squash` setup, which was necessary to allow a correct ownership
mechanic on the server. To resolve this, we consider the `rootless` image, which embeds the `ssh` server, circumventing the problem entirely.

Note this setup is simple and does not necessarily reflect the reality of your network. User mapping and ownership could be streamlined better with Kerberos, but that is out of the scope of this guide.
