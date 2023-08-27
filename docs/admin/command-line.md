---
title: 'Command Line'
license: 'Apache-2.0'
origin_url: https://github.com/go-gitea/gitea/blob/307ee2c044abe62c7e61787a6283e670fb3031ab/docs/content/administration/command-line.en-us.md
---

## Usage

```shell
forgejo [global options] command [command or global options] [arguments...]
```

## Global options

All global options can be used at the command level.

- `--help`, `-h`: Show help text and exit.
- `--version`, `-v`: Show version and exit. \
  (example: `Forgejo version 1.20.3+0 built with GNU Make 4.4.1, go1.20.7 : bindata, timetzdata, sqlite, sqlite_unlock_notify`)
- `--work-path path`, `-w path`: Forgejo's work path. \
  _(default: the binary's path or `$GITEA_WORK_DIR`)_
- `--custom-path path`, `-C path`: Forgejo's custom folder path. \
  _(default: `WorkPath`/custom or `$GITEA_CUSTOM`)_
- `--config path`, `-c path`: Forgejo configuration file path. \
  _(default: `CustomPath`/conf/app.ini)_

**Note:** The default values for `custom-path`, `config` and `work-path` can also be changed at build time.

## Commands

### `web`

Starts the server.

- **Options**
  - `--port number`, `-p number`: Port number _(default: `3000`)_. Overrides configuration file.
  - `--install-port number`: Port number to run the install page on _(default: `3000`)_. Overrides configuration file.
  - `--pid path`, `-P path`: Pidfile path.
  - `--quiet`, `-q`: Only emit Fatal logs on the console for logs emitted before logging set up.
  - `--verbose`: Emit tracing logs on the console for logs emitted before logging is set up.
- **Examples**
  - `forgejo web`
  - `forgejo web --port 80`
  - `forgejo web --config /etc/forgejo.ini --pid /some/custom/forgejo.pid`
- **Notes**
  - **Forgejo should not be run as root.** To bind to a port below `1024`, you can use `setcap` on Linux:
    `sudo setcap 'cap_net_bind_service=+ep' /path/to/forgejo`.
    This will need to be redone every time you update Forgejo.

### `admin`

Admin operations.

- **Commands**

  - `user`

    - `list`: Lists all users that exist.

      - **Options**
        - `--admin`: List only admin users.
      - **Examples**
        - `forgejo admin user list`

    - `delete`

      - **Options**
        - `--email`: Email of the user to be deleted.
        - `--username`: Username of user to be deleted.
        - `--id`: ID of user to be deleted.
        - _One of `--id`, `--username` or `--email` is required. If more than one is provided then all have to match._
      - **Examples**
        - `forgejo admin user delete --id 1`

    - `create`

      - **Options**
        - `--username value`: Username. _(required)_
        - `--password value`: Password. _(required)_
        - `--email value`: Email. _(required)_
        - `--admin`: If provided, this makes the user an admin.
        - `--access-token`: If provided, an access token will be created for the use. _(default: `false`)_
        - `--must-change-password`: If provided, the created user will be required to choose a newer password after the initial logi. _(default: `true`)_
        - `--random-password`: If provided, a randomly generated password will be used as the password of the created user. The value of `--password` will be discarded.
        - `--random-password-length`: If provided, it will be used to configure the length of the randomly generated passwor. _(default: `12`)_
      - **Examples**
        - `forgejo admin user create --username myname --password asecurepassword --email me@example.com`

    - `change-password`

      - **Options**
        - `--username value`, `-u value`: Username. _(required)_
        - `--password value`, `-p value`: New password. _(required)_
      - **Examples**
        - `forgejo admin user change-password --username myname --password asecurepassword`

    - `must-change-password`

      - **Args**
        - `[username...]`: Users that must change their passwords.
      - **Options**
        - `--all`, `-A`: Force a password change for all users.
        - `--exclude username`, `-e username`: Exclude the given user. Can be set multiple times.
        - `--unset`: Revoke forced password change for the given users.

    - `generate-access-token`
      - **Options**
        - `--username value`, `-u value`: Username. _(required)_
        - `--token-name value`, `-t value`: Token name. _(required)_
        - `--scopes value`: Comma-separated list of scopes. \
          Scopes follow the format `[read|write]:<block>` or `all`, where `<block>` is one of the available visual groups you can see when opening the API page showing the available routes (for example `repo`).
      - **Examples**
        - `forgejo admin user generate-access-token --username myname --token-name mytoken`
        - `forgejo admin user generate-access-token --help`

  - `regenerate`

    - **Options**
      - `hooks`: Regenerate Git Hooks for all repositories.
      - `keys`: Regenerate `authorized_keys` file.
    - **Examples**
      - `forgejo admin regenerate hooks`
      - `forgejo admin regenerate keys`

  - `auth`

    - `list`: Lists all external authentication sources that exist.

      - **Examples**
        - `forgejo admin auth list`

    - `delete`

      - **Options**
        - `--id`: ID of source to be deleted. _(required)_
      - **Examples**
        - `forgejo admin auth delete --id 1`

    - `add-oauth`

      - **Options**
        - `--name`: Application Name. _(required)_
        - `--provider`: OAuth2 Provider. _(required)_
        - `--key`: Client ID (Key). _(required)_
        - `--secret`: Client Secret. _(required)_
        - `--auto-discover-url`: OpenID Connect Auto Discovery URL _(only required when using OpenID Connect as provider)_.
        - `--use-custom-urls`: Use custom URLs for GitLab/GitHub OAuth endpoints.
        - `--custom-tenant-id`: Use custom Tenant ID for OAuth endpoints.
        - `--custom-auth-url`: Use a custom Authorization URL _(option for GitLab/GitHub)_.
        - `--custom-token-url`: Use a custom Token URL _(option for GitLab/GitHub)_.
        - `--custom-profile-url`: Use a custom Profile URL _(option for GitLab/GitHub)_.
        - `--custom-email-url`: Use a custom Email URL _(option for GitHub)_.
        - `--icon-url`: Custom icon URL for OAuth2 login source.
        - `--skip-local-2fa`: Allow source to override local 2FA. _(optional)_
        - `--scopes`: Additional scopes to request for this OAuth2 source. _(optional)_
        - `--required-claim-name`: Claim name that has to be set to allow users to login with this source. _(optional)_
        - `--required-claim-value`: Claim value that has to be set to allow users to login with this source. _(optional)_
        - `--group-claim-name`: Claim name providing group names for this source. _(optional)_
        - `--admin-group`: Group Claim value for administrator users. _(optional)_
        - `--restricted-group`: Group Claim value for restricted users. _(optional)_
        - `--group-team-map`: JSON mapping between groups and org teams. _(optional)_
        - `--group-team-map-removal`: Activate automatic team membership removal depending on groups. _(optional)_
      - **Examples**
        - `forgejo admin auth add-oauth --name external-github --provider github --key OBTAIN_FROM_SOURCE --secret OBTAIN_FROM_SOURCE`

    - `update-oauth`

      - **Options**
        - `--id`: ID of source to be updated. _(required)_
        - `--name`: Application Name.
        - `--provider`: OAuth2 Provider.
        - `--key`: Client ID (Key).
        - `--secret`: Client Secret.
        - `--auto-discover-url`: OpenID Connect Auto Discovery URL _(only required when using OpenID Connect as provider)_.
        - `--use-custom-urls`: Use custom URLs for GitLab/GitHub OAuth endpoints.
        - `--custom-tenant-id`: Use custom Tenant ID for OAuth endpoints.
        - `--custom-auth-url`: Use a custom Authorization URL _(option for GitLab/GitHub)_.
        - `--custom-token-url`: Use a custom Token URL _(option for GitLab/GitHub)_.
        - `--custom-profile-url`: Use a custom Profile URL _(option for GitLab/GitHub)_.
        - `--custom-email-url`: Use a custom Email URL _(option for GitHub)_.
        - `--icon-url`: Custom icon URL for OAuth2 login source.
        - `--skip-local-2fa`: Allow source to override local 2FA. _(optional)_
        - `--scopes`: Additional scopes to request for this OAuth2 source.
        - `--required-claim-name`: Claim name that has to be set to allow users to login with this source. _(optional)_
        - `--required-claim-value`: Claim value that has to be set to allow users to login with this source. _(optional)_
        - `--group-claim-name`: Claim name providing group names for this source. _(optional)_
        - `--admin-group`: Group Claim value for administrator users. _(optional)_
        - `--restricted-group`: Group Claim value for restricted users. _(optional)_
      - **Examples**
        - `forgejo admin auth update-oauth --id 1 --name external-github-updated`

    - `add-smtp`

      - **Options**
        - `--name`: Application Name. _(required)_
        - `--auth-type`: SMTP Authentication Type (`PLAIN`/`LOGIN`/`CRAM-MD5`). Default to `PLAIN`.
        - `--host`: SMTP host. _(required)_
        - `--port`: SMTP port. _(required)_
        - `--force-smtps`: SMTPS is always used on port `465`. Set this to force SMTPS on other ports.
        - `--skip-verify`: Skip TLS verify.
        - `--helo-hostname`: Hostname sent with `HELO`. Leave blank to send current hostname.
        - `--disable-helo`: Disable SMTP `HELO`.
        - `--allowed-domains`: Leave empty to allow all domains. Separate multiple domains with a comma (`,`).
        - `--skip-local-2fa`: Skip 2FA to log on.
        - `--active`: This Authentication Source is Activated.
      - **Remarks** \
        `--force-smtps`, `--skip-verify`, `--disable-helo`, `--skip-loca-2fs` and `--active` options can be used in form:
        - `--option`, `--option=true` to enable
        - `--option=false` to disable
          If those options are not specified, the value is not changed in `update-smtp` or uses the default `false` value in `add-smtp`.
      - **Examples**
        - `forgejo admin auth add-smtp --name ldap --host smtp.mydomain.org --port 587 --skip-verify --active`

    - `update-smtp`

      - **Options**
        - `--id`: ID of source to be updated. _(required)_
        - other options are shared with `add-smtp`
      - **Examples**
        - `forgejo admin auth update-smtp --id 1 --host smtp.mydomain.org --port 587 --skip-verify=false`
        - `forgejo admin auth update-smtp --id 1 --active=false`

    - `add-ldap`: Add new LDAP (via Bind DN) authentication source.

      - **Options**
        - `--name value`: Authentication name. _(required)_
        - `--not-active`: Deactivate the authentication source.
        - `--security-protocol value`: Security protocol name. _(required)_
        - `--skip-tls-verify`: Disable TLS verification.
        - `--host value`: The address where the LDAP server can be reached. _(required)_
        - `--port value`: The port to use when connecting to the LDAP server. _(required)_
        - `--user-search-base value`: The LDAP base at which user accounts will be searched for. _(required)_
        - `--user-filter value`: An LDAP filter declaring how to find the user record that is attempting to authenticate. _(required)_
        - `--admin-filter value`: An LDAP filter specifying if a user should be given administrator privileges.
        - `--restricted-filter value`: An LDAP filter specifying if a user should be given restricted status.
        - `--username-attribute value`: The attribute of the user’s LDAP record containing the user name.
        - `--firstname-attribute value`: The attribute of the user’s LDAP record containing the user’s first name.
        - `--surname-attribute value`: The attribute of the user’s LDAP record containing the user’s surname.
        - `--email-attribute value`: The attribute of the user’s LDAP record containing the user’s email address. _(required)_
        - `--public-ssh-key-attribute value`: The attribute of the user’s LDAP record containing the user’s public ssh key.
        - `--avatar-attribute value`: The attribute of the user’s LDAP record containing the user’s avatar.
        - `--bind-dn value`: The DN to bind to the LDAP server with when searching for the user.
        - `--bind-password value`: The password for the Bind DN, if any.
        - `--attributes-in-bind`: Fetch attributes in bind DN context.
        - `--synchronize-users`: Enable user synchronization.
        - `--page-size value`: Search page size.
      - **Examples**
        - `forgejo admin auth add-ldap --name ldap --security-protocol unencrypted --host mydomain.org --port 389 --user-search-base "ou=Users,dc=mydomain,dc=org" --user-filter "(&(objectClass=posixAccount)(|(uid=%[1]s)(mail=%[1]s)))" --email-attribute mail`

    - `update-ldap`: Update existing LDAP (via Bind DN) authentication source.

      - **Options**
        - `--id value`: ID of authentication source. _(required)_
        - `--name value`: Authentication name.
        - `--not-active`: Deactivate the authentication source.
        - `--security-protocol value`: Security protocol name.
        - `--skip-tls-verify`: Disable TLS verification.
        - `--host value`: The address where the LDAP server can be reached.
        - `--port value`: The port to use when connecting to the LDAP server.
        - `--user-search-base value`: The LDAP base at which user accounts will be searched for.
        - `--user-filter value`: An LDAP filter declaring how to find the user record that is attempting to authenticate.
        - `--admin-filter value`: An LDAP filter specifying if a user should be given administrator privileges.
        - `--restricted-filter value`: An LDAP filter specifying if a user should be given restricted status.
        - `--username-attribute value`: The attribute of the user’s LDAP record containing the user name.
        - `--firstname-attribute value`: The attribute of the user’s LDAP record containing the user’s first name.
        - `--surname-attribute value`: The attribute of the user’s LDAP record containing the user’s surname.
        - `--email-attribute value`: The attribute of the user’s LDAP record containing the user’s email address.
        - `--public-ssh-key-attribute value`: The attribute of the user’s LDAP record containing the user’s public ssh key.
        - `--avatar-attribute value`: The attribute of the user’s LDAP record containing the user’s avatar.
        - `--bind-dn value`: The DN to bind to the LDAP server with when searching for the user.
        - `--bind-password value`: The password for the Bind DN, if any.
        - `--attributes-in-bind`: Fetch attributes in bind DN context.
        - `--synchronize-users`: Enable user synchronization.
        - `--page-size value`: Search page size.
      - **Examples**
        - `forgejo admin auth update-ldap --id 1 --name "my ldap auth source"`
        - `forgejo admin auth update-ldap --id 1 --username-attribute uid --firstname-attribute givenName --surname-attribute sn`

    - `add-ldap-simple`: Add new LDAP (simple auth) authentication source.

      - **Options**
        - `--name value`: Authentication name. _(required)_
        - `--not-active`: Deactivate the authentication source.
        - `--security-protocol value`: Security protocol name. _(required)_
        - `--skip-tls-verify`: Disable TLS verification.
        - `--host value`: The address where the LDAP server can be reached. _(required)_
        - `--port value`: The port to use when connecting to the LDAP server. _(required)_
        - `--user-search-base value`: The LDAP base at which user accounts will be searched for.
        - `--user-filter value`: An LDAP filter declaring how to find the user record that is attempting to authenticate. _(required)_
        - `--admin-filter value`: An LDAP filter specifying if a user should be given administrator privileges.
        - `--restricted-filter value`: An LDAP filter specifying if a user should be given restricted status.
        - `--username-attribute value`: The attribute of the user’s LDAP record containing the user name.
        - `--firstname-attribute value`: The attribute of the user’s LDAP record containing the user’s first name.
        - `--surname-attribute value`: The attribute of the user’s LDAP record containing the user’s surname.
        - `--email-attribute value`: The attribute of the user’s LDAP record containing the user’s email address. _(required)_
        - `--public-ssh-key-attribute value`: The attribute of the user’s LDAP record containing the user’s public ssh key.
        - `--avatar-attribute value`: The attribute of the user’s LDAP record containing the user’s avatar.
        - `--user-dn value`: The user’s DN. _(required)_
      - **Examples**
        - `forgejo admin auth add-ldap-simple --name ldap --security-protocol unencrypted --host mydomain.org --port 389 --user-dn "cn=%s,ou=Users,dc=mydomain,dc=org" --user-filter "(&(objectClass=posixAccount)(cn=%s))" --email-attribute mail`

    - `update-ldap-simple`: Update existing LDAP (simple auth) authentication source.
      - **Options**
        - `--id value`: ID of authentication source. _(required)_
        - `--name value`: Authentication name.
        - `--not-active`: Deactivate the authentication source.
        - `--security-protocol value`: Security protocol name.
        - `--skip-tls-verify`: Disable TLS verification.
        - `--host value`: The address where the LDAP server can be reached.
        - `--port value`: The port to use when connecting to the LDAP server.
        - `--user-search-base value`: The LDAP base at which user accounts will be searched for.
        - `--user-filter value`: An LDAP filter declaring how to find the user record that is attempting to authenticate.
        - `--admin-filter value`: An LDAP filter specifying if a user should be given administrator privileges.
        - `--restricted-filter value`: An LDAP filter specifying if a user should be given restricted status.
        - `--username-attribute value`: The attribute of the user’s LDAP record containing the user name.
        - `--firstname-attribute value`: The attribute of the user’s LDAP record containing the user’s first name.
        - `--surname-attribute value`: The attribute of the user’s LDAP record containing the user’s surname.
        - `--email-attribute value`: The attribute of the user’s LDAP record containing the user’s email address.
        - `--public-ssh-key-attribute value`: The attribute of the user’s LDAP record containing the user’s public ssh key.
        - `--avatar-attribute value`: The attribute of the user’s LDAP record containing the user’s avatar.
        - `--user-dn value`: The user’s DN.
      - **Examples**
        - `forgejo admin auth update-ldap-simple --id 1 --name "my ldap auth source"`
        - `forgejo admin auth update-ldap-simple --id 1 --username-attribute uid --firstname-attribute givenName --surname-attribute sn`

### `cert`

Generates a self-signed SSL certificate. Outputs to `cert.pem` and `key.pem` in the current
directory and will overwrite any existing files.

- **Options**
  - `--host value`: Comma separated hostnames and ips which this certificate is valid for.
    Wildcards are supported. _(required)_
  - `--ecdsa-curve value`: ECDSA curve to use to generate a key. Valid options
    are P224, P256, P384, P521.
  - `--rsa-bits value`: Size of RSA key to generate. Ignored if --ecdsa-curve is
    set. _(default: `2048`)_
  - `--start-date value`: Creation date. _(format: `Jan 1 15:04:05 2011`)_
  - `--duration value`: Duration which the certificate is valid for. _(default: `8760h0m0s`)_
  - `--ca`: If provided, this cert generates it's own certificate authority.
- **Examples**
  - `forgejo cert --host git.example.com,example.com,www.example.com --ca`

### `dump`

Dumps all files and databases into a zip file. Outputs into a file like `forgejo-dump-1482906742.zip`
in the current directory.

- **Options**
  - `--file name`, `-f name`: Name of the dump file with will be created. _(default: `forgejo-dump-[timestamp].zip`)_
  - `--tempdir path`, `-t path`: Path to the temporary directory used. _(default: `/tmp`)_
  - `--skip-repository`, `-R`: Skip the repository dumping.
  - `--skip-custom-dir`: Skip dumping of the custom dir.
  - `--skip-lfs-data`: Skip dumping of LFS data.
  - `--skip-attachment-data`: Skip dumping of attachment data.
  - `--skip-package-data`: Skip dumping of package data.
  - `--skip-log`: Skip dumping of log data.
  - `--database`, `-d`: Specify the database SQL syntax.
  - `--verbose`, `-V`: If provided, shows additional details.
  - `--type`: Set the dump output format. _(default: `zip`)_
- **Examples**
  - `forgejo dump`
  - `forgejo dump --verbose`

### `generate`

Generates random values and tokens for usage in configuration file. Useful for generating values
for automatic deployments.

- **Commands**
  - `secret`
    - **Options**
      - `INTERNAL_TOKEN`: Token used for an internal API call authentication.
      - `JWT_SECRET`: LFS & OAUTH2 JWT authentication secret (LFS_JWT_SECRET is aliased to this option for backwards compatibility).
      - `SECRET_KEY`: Global secret key.
    - **Examples**
      - `forgejo generate secret INTERNAL_TOKEN`
      - `forgejo generate secret JWT_SECRET`
      - `forgejo generate secret SECRET_KEY`

### `keys`

Provides an SSHD AuthorizedKeysCommand. Needs to be configured in the sshd config file.

```ini
...
# The value of -e and the AuthorizedKeysCommandUser should match the
# username running Forgejo
AuthorizedKeysCommandUser git
AuthorizedKeysCommand /path/to/forgejo keys -e git -u %u -t %t -k %k
```

The command will return the appropriate `authorized_keys` line for the
provided key. You should also set the value
`SSH_CREATE_AUTHORIZED_KEYS_FILE=false` in the `[server]` section of
`app.ini`.

NB: opensshd requires the Forgejo program to be owned by root and not
writable by group or others. The program must be specified by an absolute
path.
NB: Forgejo must be running for this command to succeed.

### `migrate`

Migrates the database. This command can be used to run other commands before starting the server for the first time.
This command is idempotent.

### `convert`

Converts an existing MySQL database from utf8 to utf8mb4.

### `doctor`

Diagnose the problems of current Forgejo instance according the given configuration.

Currently performs the following checks:

- **Check if OpenSSH `authorized_keys` file is correct.** \
  If your Forgejo instance supports OpenSSH, your Forgejo instance binary path will be written to `authorized_keys` when any public key is added or changed on your Forgejo instance. \
  Sometimes if you have moved or renamed your Forgejo binary when upgrading and you haven't run the "`Update the '.ssh/authorized_keys' file with Forgejo SSH keys`" command on your Admin Panel, all pull/push operations via SSH will fail.
  This check will help you to verify that the configuration is correct.

For contributors, if you want to add more checks, you can write a new function like `func(ctx *cli.Context) ([]string, error)` and
append it to `doctor.go`.

```go
var checklist = []check{
	{
		title: "Check if OpenSSH authorized_keys file id correct",
		f:     runDoctorLocationMoved,
    },
    // more checks please append here
}
```

This function will receive a command line context and return a list of details about the problems or error.

#### `doctor recreate-table`

Sometimes when there are migrations the old columns and default values may be left
unchanged in the database schema. This may lead to warnings such as:

```log
2020/08/02 11:32:29 ...rm/session_schema.go:360:Sync2() [W] Table user Column keep_activity_private db default is , struct default is 0
```

You can cause Forgejo to recreate these tables and copy the old data into the new table
with the defaults set appropriately by using:

```shell
forgejo doctor recreate-table user
```

You can ask Forgejo to recreate multiple tables using:

```shell
forgejo doctor recreate-table table1 table2 ...
```

And if you would like Forgejo to recreate all tables simply call:

```shell
forgejo doctor recreate-table
```

It is highly recommended to back-up your database before running these commands.

### `manager`

Manage running server operations.

- **Commands**

  - `shutdown`: Gracefully shutdown the running process.
  - `restart`: Gracefully restart the running process (not implemented for windows servers).
  - `flush-queues`: Flush queues in the running process.

    - **Options**
      - `--timeout value`: Timeout for the flushing proces. _(default: `1m0s`)_
      - `--non-blocking`: Set to true to not wait for flush to complete before returning.

  - `logging`: Adjust logging commands.

    - **Commands**

      - `pause`: Pause logging.
        - **Notes**
          - The logging level will be raised to INFO temporarily if it is below this level.
          - Forgejo will buffer logs up to a certain point and will drop them after that point.
      - `resume`: Resume logging.
      - `release-and-reopen`: Cause Forgejo to release and re-open files and connections used for logging (Equivalent to sending SIGUSR1 to Forgejo.)
      - `remove name`: Remove the named logger.

        - **Options**
          - `--group group`, `-g group`: Set the group to remove the sublogger from. _(default: `default`)_

      - `add`: Add a logger.

        - **Commands**

          - `console`: Add a console logger.

            - **Options**
              - `--group value`, `-g value`: Group to add logger to. _(default: `default`)_
              - `--name value`, `-n value`: Name of the new logger. _(default: `mode`)_
              - `--level value`, `-l value`: Logging level for the new logger.
              - `--stacktrace-level value`, `-L value`: Stacktrace logging level.
              - `--flags value`, `-F value`: Flags for the logger.
              - `--expression value`, `-e value`: Matching expression for the logger.
              - `--prefix value`, `-p value`: Prefix for the logger.
              - `--color`: Use color in the logs.
              - `--stderr`: Output console logs to stderr - only relevant for console.

          - `file`: Add a file logger.

            - **Options**
              - `--group value`, `-g value`: Group to add logger to. _(default: `default`)_
              - `--name value`, `-n value`: Name of the new logger. _(default: `mode`)_
              - `--level value`, `-l value`: Logging level for the new logger.
              - `--stacktrace-level value`, `-L value`: Stacktrace logging level.
              - `--flags value`, `-F value`: Flags for the logger.
              - `--expression value`, `-e value`: Matching expression for the logger.
              - `--prefix value`, `-p value`: Prefix for the logger.
              - `--color`: Use color in the logs.
              - `--filename value`, `-f value`: Filename for the logger.
              - `--rotate`, `-r`: Rotate logs.
              - `--max-size value`, `-s value`: Maximum size in bytes before rotation.
              - `--daily`, `-d`: Rotate logs daily.
              - `--max-days value`, `-D value`: Maximum number of daily logs to keep.
              - `--compress`, `-z`: Compress rotated logs.
              - `--compression-level value`, `-Z value`: Compression level to use.

          - `conn`: Add a network connection logger.

            - **Options**
              - `--group value`, `-g value`: Group to add logger to. _(default: `default`)_
              - `--name value`, `-n value`: Name of the new logger. _(default: `mode`)_
              - `--level value`, `-l value`: Logging level for the new logger.
              - `--stacktrace-level value`, `-L value`: Stacktrace logging level.
              - `--flags value`, `-F value`: Flags for the logger.
              - `--expression value`, `-e value`: Matching expression for the logger.
              - `--prefix value`, `-p value`: Prefix for the logger.
              - `--color`: Use color in the logs.
              - `--reconnect-on-message`, `-R`: Reconnect to host for every message.
              - `--reconnect`, `-r`: Reconnect to host when connection is dropped.
              - `--protocol value`, `-P value`: Set protocol to use: tcp, unix, or udp _(defaults: `tcp`)_
              - `--address value`, `-a value`: Host address and port to connect to _(default: `7020`)_

          - `smtp`: Add an SMTP logger.
            - **Options**
              - `--group value`, `-g value`: Group to add logger to. _(default: `default`)_
              - `--name value`, `-n value`: Name of the new logger. _(default: `mode`)_
              - `--level value`, `-l value`: Logging level for the new logger.
              - `--stacktrace-level value`, `-L value`: Stacktrace logging level.
              - `--flags value`, `-F value`: Flags for the logger.
              - `--expression value`, `-e value`: Matching expression for the logger.
              - `--prefix value`, `-p value`: Prefix for the logger.
              - `--color`: Use color in the logs.
              - `--username value`, `-u value`: Mail server username.
              - `--password value`, `-P value`: Mail server password.
              - `--host value`, `-H value`: Mail server host _(default: `127.0.0.1:25`)_
              - `--send-to value`, `-s value`: Email address(es) to send to.
              - `--subject value`, `-S value`: Subject header of sent emails.

  - `processes`: Display Forgejo processes and goroutine information.
    - **Options**
      - `--flat`: Show processes as flat table rather than as tree.
      - `--no-system`: Do not show system processes.
      - `--stacktraces`: Show stacktraces for goroutines associated with processes.
      - `--json`: Output as JSON.
      - `--cancel PID`: Send cancel to process with PID. (Only for non-system processes.)

### `dump-repo`

Dumps repository data from a Git/Forgejo/Gitea/GitHub/GitLab repo.

- **Options**
  - `--git_service <service>` : Git service (`git`/`github`/`gitea`/`gitlab`). If `clone_addr` is recognized, this is ignored.
  - `--repo_dir <dir>`, `-r <dir>`: Repository dir path to store the data.
  - `--clone_addr <addr>`: Repo URL to be cloned. Can currently be a git/forgejo/gitea/github/gitlab HTTP/HTTPS URL.
  - `--auth_username <name>`: The username to use for authentication with the `clone_addr`.
  - `--auth_password <password>`: The password to use for authentication with the `clone_addr`.
  - `--auth_token <token>`: The personal token to use for authentication with the `clone_addr`.
  - `--owner_name <name>`: The data will be stored in a directory with owner name if not empty.
  - `--repo_name <name>`: The data will be stored in a directory with repository name if not empty.
  - `--units <units>`: Which items will be migrated, one or more units separated by commas. `wiki`, `issues`, `labels`, `releases`, `release_assets`, `milestones`, `pull_requests`, `comments` are allowed. Empty means all units.

### `restore-repo`

Restore-repo restore repository data from disk dir.

- **Options**
  - `--repo_dir <dir>`, `-r <dir>`: Repository dir path to restore from.
  - `--owner_name <name>`: Restore destination owner name.
  - `--repo_name <name>`: Restore destination repository name.
  - `--units <units>`: Which items will be restored, one or more units separated by commas. `wiki`, `issues`, `labels`, `releases`, `release_assets`, `milestones`, `pull_requests`, `comments` are allowed. Empty means all units.

### `actions generate-runner-token`

Generate a new token for a runner to use to register with the server.

- **Options**
  - `--scope {owner}[/{repo}]`, `-s {owner}[/{repo}]`: Limits the scope of the runner. No scope means the runner can be used for all repos, but you can also limit it to a specific repo or owner.

To register a global runner:

```shell
forgejo actions generate-runner-token
```

To register a runner for a specific organization, in this case `org`

```shell
forgejo actions generate-runner-token -s org
```

To register a runner for a specific repo, in this case `username/test-repo`

```shell
forgejo actions generate-runner-token -s username/test-repo
```
