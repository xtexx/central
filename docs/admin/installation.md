---
title: 'Installation'
license: 'CC-BY-SA-4.0'
origin_url: 'https://github.com/DanielGibson/DanielGibson.github.io/blob/58362695f743a545d2530508ce42d5fe1eea84a9/content/post/setup-vps-with-wireguard-and-forgejo.md'
---

## Installation with Docker

Forgejo provides [container images](https://codeberg.org/forgejo/-/packages/container/forgejo/versions) for use with Docker or other containerization tools.

```shell
docker pull codeberg.org/forgejo/forgejo:1.20.5-0
```

The **1.20** tag is set to be the latest patch release, starting with [1.20.5-0](https://codeberg.org/forgejo/-/packages/container/forgejo/1.20.5-0). **1.20** will then be equal to **1.20.2-0** when it is released and so on.

Upgrading from **1.X** to **1.X+1** (for instance from **1.19** to **1.20**) requires a [manual operation and human verification](../upgrade/). However it is possible to use the **X.Y** tag (for instance **1.20**) to get the latest point release automatically.

Here is a sample [docker-compose](https://docs.docker.com/compose/install/) file:

```yaml
version: '3'

networks:
  forgejo:
    external: false

services:
  server:
    image: codeberg.org/forgejo/forgejo:1.20
    container_name: forgejo
    environment:
      - USER_UID=1000
      - USER_GID=1000
    restart: always
    networks:
      - forgejo
    volumes:
      - ./forgejo:/var/lib/gitea
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
    ports:
      - '3000:3000'
      - '222:22'
```

Note that the volume should be owned by the user/group with the UID/GID specified in the config file.
If you don't give the volume correct permissions, the container may not start.

### Databases

In the following each database is shown as part of a `docker-compose` example file, with a `diff like` presentation that highlights additions to the example above.

#### MySQL database

```yaml
version: "3"

networks:
  forgejo:
    external: false

services:
  server:
    image: codeberg.org/forgejo/forgejo:1.20
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
      - ./forgejo:/var/lib/gitea
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

#### PostgreSQL database

```yaml
version: "3"

networks:
  forgejo:
    external: false

services:
  server:
    image: codeberg.org/forgejo/forgejo:1.20
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
      - ./forgejo:/var/lib/gitea
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

### Hosting repository data on remote storage systems

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

We assume that a server with the hostname `server` is accessible which has a folder `/respositories`
shared via NFS. Append an entry to your `/etc/exports` like

```shell
[...]
/repositories	*(rw,sync,all_squash,ec=sys,anonuid=1024,anongid=100)
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
setting (abreviated "`0777` permissions"). We can also "fake-own" data, since all `chown` calls are now mapped to the anonymous user. This is an
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

To consider in the client setup is the `hard` setting, blocking all file operations if the share is not available.
This prevents state changes in the repository which could potentially corrupt the repository data and is an NFS-specific setting.

To circumvent this, you can use the
We will use the `rootless` image, which hosts the `ssh` server for Forgejo embedded. A possible entry for a `docker-compose` file
would look like this (shown as a `diff like` view to the example shown [in our initial example](#installation-with-docker)):

```yaml
version: "3"

networks:
  forgejo:
    external: false

services:
  server:
-    image: codeberg.org/forgejo/forgejo:1.20
+    image: codeberg.org/forgejo/forgejo:1.20-rootless
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
-      - ./forgejo:/var/lib/gitea
+      - /mnt/repositories/data:/var/lib/gitea
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

Note that this is a comparatively simple setup which does not necessarily reflect the reality of your network.
User mapping and ownership could theoretically be streamlined better with Kerberos, which is however out of scope
for this guide.

## Installation from binary

### Install Forgejo and git, create git user

> **NOTE:** this guide assumes that you'll host on the server with the domain git.example.com.

First, download the Forgejo binary for your CPU architecture and maybe verify the GPG signature,
as described on [the Forgejo download page](/download/).

Next, copy the downloaded Forgejo binary to `/usr/local/bin/` (renaming it to just "forgejo")
and make it executable:

> **NOTE:** when a line starts with #, it means the command 'foo --bar' must be run as root (or with sudo).

`# cp forgejo-1.20.5-0-linux-amd64 /usr/local/bin/forgejo`
`# chmod 755 /usr/local/bin/forgejo`

Make sure `git` and `git-lfs` are installed:
`# apt install git git-lfs`

Create a user `git` on the system. Forgejo will run as that user, and when accessing git through ssh
(which is the default), this user is part of the URL _(for example in
`git clone git@git.example.com:YourOrg/YourRepo.git` the `git` before the `@` is the user you'll create now)._
On **Debian, Ubuntu** and their derivates that's done with:

```
# adduser --system --shell /bin/bash --gecos 'Git Version Control' \
  --group --disabled-password --home /home/git  git
```

On **Linux distributions not based on Debian/Ubuntu** (this should at least work with Red Hat derivates
like Fedora, CentOS etc.), run this instead:

```
# groupadd --system git

# adduser --system --shell /bin/bash --comment 'Git Version Control' \
   --gid git --home-dir /home/git --create-home git
```

### Create directories Forgejo will use

Now create the directories Forgejo will use and set access rights appropriately:

`# mkdir /var/lib/forgejo`
`# chown git:git /var/lib/forgejo && chmod 750 /var/lib/forgejo`
_This is the directory Forgejo will store its data in, including your git repos._

`# mkdir /etc/forgejo`
`# chown root:git /etc/forgejo && chmod 770 /etc/forgejo`
_This is the directory Forgejo's config, called `app.ini`, is stored in. Initially it needs to
be writable by Forgejo, but after the installation you can make it read-only for Forgejo because
then it shouldn't modify it anymore._

### Optional: Set up database

When using sqlite as Forgejos database, nothing needs to be done here.

If you need a more powerful database, you can use MySQL/MariaDB or PostgreSQL (apparently sqlite
is good enough for at least 10 users, but might even suffice for more).

See [Forgejos Database Preparation guide](../database-preparation/) for
setup instructions.

### Install systemd service for Forgejo

Forgejo provides a
[systemd service script](https://codeberg.org/forgejo/forgejo/src/branch/forgejo/contrib/systemd/forgejo.service).
Download it to the correct location:
`# wget -O /etc/systemd/system/forgejo.service https://codeberg.org/forgejo/forgejo/raw/branch/forgejo/contrib/systemd/forgejo.service`

If you're _not_ using sqlite, but MySQL or MariaDB or PostgreSQL, you'll have to edit that file
(`/etc/systemd/system/forgejo.service`) and uncomment the corresponding `Wants=` and `After=` lines.
Otherwise it _should_ work as it is.

Now enable and start the Forgejo service, so you can go on with the installation:
`# systemctl enable forgejo.service`
`# systemctl start forgejo.service`

### Forgejos web-based configuration

You should now be able to access Forgejo in your local web browser, so open http://git.example.com:3000/.

If it doesn't work:

- Make sure the forgejo service started successfully by checking the output of
  `# systemctl status forgejo.service`
  If that indicates an error but the log lines underneath are too incomplete to tell what caused it,
  `# journalctl -n 100 --unit forgejo.service`
  will print the last 100 lines logged by Forgejo.

You should be greeted by Forgejo's "Initial Configuration" screen.
The settings should be mostly self-explanatory, some hints:

- Select the correct database (SQLite3, or if you configured something else in the
  "Set up database" step above, select that and set the corresponding options)
- **Server Domain** should be `git.example.com` (or whatever you're actually using),
  **Forgejo Base URL** should be `http://git.example.com:3000` (assuming you won't change HTTP_PORT a different value than 3000)
- Check the **Server and Third-Party Service Settings** settings for settings that look relevant
  for you.
- It may make sense to create the administrator account right now (**Administrator Account Settings**),
  even more so if you disabled self-registration.
- Most settings can be changed in `/etc/forgejo/app.ini` later, so don't worry about them too much.

Once you're done configuring, click `Install Forgejo` and a few seconds later you should be
on the dashboard (if you created an administrator account) or at the login/register screen, where you
can create an account to then get to the dashboard.

So far, so good, but we're not quite done yet - some manual configuration in the app.ini is needed.

### Further configuration in Forgejo's app.ini

Stop the forgejo service:
`# systemctl stop forgejo.service`

While at it, make `/etc/forgejo/` and the `app.ini` read-only for the git user (Forgejo doesn't
write to it after the initial configuration):
`# chmod 750 /etc/forgejo && chmod 640 /etc/forgejo/app.ini`

Now (as root) edit `/etc/forgejo/app.ini`

> **NOTE:** You'll probably find the
> [Configuration Cheat Sheet](../config-cheat-sheet/) and the
> [Example app.ini](https://codeberg.org/forgejo/forgejo/src/branch/forgejo/custom/conf/app.example.ini)
> that contains all options incl. descriptions helpful.

The following changes are recommended if dealing with many large files:

- Forgejo allows uploading files to git repos through the web interface.
  By default the **file size for uploads**
  is limited to 3MB per file, and 5 files at once. To increase it, under the `[repository]` section,
  add a `[repository.upload]` section with a line like `FILE_MAX_SIZE = 4095`
  (that would be 4095MB, about 4GB) and `MAX FILES = 20`
  It'll look somehow like this:

  ```ini
  ...
  [repository]
  ROOT = /var/lib/forgejo/data/forgejo-repositories

  [repository.upload]
  ;; max size for files to the repo via web interface, in MB,
  ;; defaults to 3 (this sets a limit of about 4GB)
  FILE_MAX_SIZE = 4095
  ;; by default 5 files can be uploaded at once, increase to 20
  MAX_FILES = 20

  [server]
  ...
  ```

  Similar restrictions restrictions exist for attachments to issues/pull requests, configured
  in the [`[attachment]` sections](../config-cheat-sheet/#issue-and-pull-request-attachments-attachment)
  `MAX_SIZE` (default 4MB) and `MAX_FILES` (default 5) settings.

- By default **LFS data uploads expire** after 20 minutes - this can be too short for big files,
  slow connections or slow LFS storage (git-lfs seems to automatically restart the upload then -
  which means that it can take forever and use lots of traffic)..
  If you're going to use LFS with big uploads, increase thus limit, by adding a line
  `LFS_HTTP_AUTH_EXPIRY = 180m` (for 180 minutes) to the `[server]` section.
- Similarly there are timeouts for all kinds of git operations, that can be too short.
  Increasing all those git timeouts by adding a `[git.timeout]` section
  below the `[server]` section:
  ```ini
  ;; Git Operation timeout in seconds
  ;; increase the timeouts, so importing big repos (and presumably
  ;; pushing large files?) hopefully won't fail anymore
  [git.timeout]
  DEFAULT = 3600 ; Git operations default timeout seconds
  MIGRATE = 6000 ; Migrate external repositories timeout seconds
  MIRROR  = 3000 ; Mirror external repositories timeout seconds
  CLONE   = 3000 ; Git clone from internal repositories timeout seconds
  PULL    = 3000 ; Git pull from internal repositories timeout seconds
  GC      = 600  ; Git repository GC timeout seconds
  ```
  They are increased by a factor 10 (by adding a 0 at the end); probably not all these timeouts
  need to be increased (and if, then maybe not this much)... use your own judgement.
- By default LFS files are stored in the filesystem, in `/var/lib/forgejo/data/lfs`.
  In the `[lfs]` section you can change the `PATH = ...` line to store elsewhere, but you can also
  configure Forgejo to store the files in an S3-like Object-Storage.
- If you want to use the systemwide sendmail, enable sending E-Mails by changing the `[mailer]` section like this:
  ```ini
  [mailer]
  ;; send mail with systemwide "sendmail"
  ENABLED = true
  PROTOCOL = sendmail
  FROM = "Forgejo Git" <noreply@yourdomain.com>
  ```
- By default Forgejo will listen to the port 3000 but that can be [changed to 80 with HTTP_PORT](../config-cheat-sheet/) like this:
  ```ini
  [server]
  HTTP_PORT = 80
  ```

When you're done editing the app.ini, save it and start the forgejo service again:
`# systemctl start forgejo.service`

You can test sending a mail by clicking the user button on the upper right of the Forgejo page
("Profile and Settings"), then `Site Administration`, then `Configuration` and under
`Mailer Configuration` type in your mail address and click `Send Testing Email`.

### General hints for using Forgejo

Sometimes you may want/need to use the Forgejo
[command line interface](../command-line/).
Keep in mind that:

- You need to **run it as `git` user**, for example with `$ sudo -u git forgejo command --argument`
- You need to specify the **Forgejo work path**, either with the `--work-path /var/lib/forgejo`
  (or `-w /var/lib/forgejo`) commandline option or by setting the `FORGEJO_WORK_DIR` environment variable
  (`$ export FORGEJO_WORK_DIR=/var/lib/forgejo`) before calling `forgejo`
- You need to specify the path to the config (app.ini) with `--config /etc/forgejo/app.ini`
  (or `-c /etc/forgejo/app.ini`).

So all in all your command might look like:
`$ sudo -u git forgejo -w /var/lib/forgejo -c /etc/forgejo/app.ini admin user list`

> **_For convenience_**, you could create a `/usr/local/bin/forgejo.sh` with the following contents:
>
> ```sh
> #!/bin/sh
> sudo -u git forgejo -w /var/lib/forgejo -c /etc/forgejo/app.ini "$@"
> ```
>
> and make it executable:
> `# chmod 755  /usr/local/bin/forgejo.sh`
>
> Now if you want to call `forgejo` on the commandline (for the default system-wide installation
> in `/var/lib/forgejo`), just use e.g. `$ forgejo.sh admin user list` instead of the long
> line shown above.

You can always call forgejo and its subcommands with `-h` or `--help` to make it output usage
information like available options and (sub)commands, for example
`$ forgejo admin user -h`
to show available subcommands to administrate users on the commandline.

## Installation from package

Forgejo is also available for installation using package managers on many platforms. At this
time, Forgejo has been successfully adapted for use on various platforms, including Alpine Linux, Arch
Linux, Debian, Fedora, Gentoo, Manjaro, and the Nix ecosystem. It's important to acknowledge that these
platform-specific packages are under the care of distribution packagers, and specific packages are
currently undergoing testing. For a carefully curated inventory, please refer to
[the "Delightful Forgejo" list](https://codeberg.org/forgejo-contrib/delightful-forgejo#packaging).
