---
title: Forgejo CLI
license: 'CC-BY-SA-4.0'
---

<!--
This page should not be edited manually.
To update this page, run the following command from the root of the docs repo:
```
forgejo docs | perl ./scripts/cli-docs.pl > ./docs/admin/command-line.md
```
-->

_**Note**: this documentation is generated from the output of the Forgejo CLI command `forgejo docs`._

## NAME

Forgejo - Beyond coding. We forge.

## SYNOPSIS

Forgejo

```
[--config|-c]=[value]
[--custom-path|-C]=[value]
[--help|-h]
[--version|-v]
[--work-path|-w]=[value]
```

## DESCRIPTION

By default, forgejo will start serving using the web-server with no argument, which can alternatively be run by running the subcommand "web".

**Usage**:

```
Forgejo [GLOBAL OPTIONS] command [COMMAND OPTIONS] [ARGUMENTS...]
```

## GLOBAL OPTIONS

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--version, -v`: print the version

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

## COMMANDS

### web

Start Forgejo web server

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--install-port`: Temporary port number to run the install page on to prevent conflict _(default: `3000`)_

`--pid, -P`: Custom pid file path _(default: `/run/gitea.pid`)_

`--port, -p`: Temporary port number to prevent conflict _(default: `3000`)_

`--quiet, -q`: Only display Fatal logging errors until logging is set-up

`--verbose`: Set initial logging to TRACE level until logging is properly set-up

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

#### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

### serv

This command should only be called by SSH shell

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--debug`:

`--enable-pprof`:

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

#### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

### hook

Delegate commands to corresponding Git hooks

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

#### pre-receive

Delegate pre-receive Git hook

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--debug`:

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

#### update

Delegate update Git hook

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--debug`:

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

#### post-receive

Delegate post-receive Git hook

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--debug`:

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

#### proc-receive

Delegate proc-receive Git hook

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--debug`:

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

#### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

### dump

Dump Forgejo files and database

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--database, -d`: Specify the database SQL syntax

`--file, -f`: Name of the dump file which will be created. Supply '-' for stdout. See type for available types. _(default: `forgejo-dump-1693311145.zip`)_

`--help, -h`: show help

`--quiet, -q`: Only display warnings and errors

`--skip-attachment-data`: Skip attachment data

`--skip-custom-dir`: Skip custom directory

`--skip-index`: Skip bleve index data

`--skip-lfs-data`: Skip LFS data

`--skip-log, -L`: Skip the log dumping

`--skip-package-data`: Skip package data

`--skip-repository, -R`: Skip the repository dumping

`--tempdir, -t`: Temporary dir path _(default: `/var/folders/xj/1byxn7qs2tbgspdl9m2839tm0000gn/T/`)_

`--type`: Dump output format: zip, tar, tar.sz, tar.gz, tar.xz, tar.bz2, tar.br, tar.lz4, tar.zst _(default: `zip`)_

`--verbose, -V`: Show process details

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

#### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

### admin

Command line interface to perform common administrative operations

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

#### user

Modify users

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### create

Create a new user in database

`--access-token`: Generate access token for the user

`--admin`: User is an admin

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--email`: User email address

`--help, -h`: show help

`--must-change-password`: Set this option to false to prevent forcing the user to change their password after initial login, (Default: true)

`--name`: Username. DEPRECATED: use username instead

`--password`: User password

`--random-password`: Generate a random password for the user

`--random-password-length`: Length of the random password to be generated _(default: `0`)_

`--restricted`: Make a restricted user account

`--username`: Username

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

###### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### list

List users

`--admin`: List only admin users

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

###### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### change-password

Change a user's password

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--password, -p`: New password to set for user

`--username, -u`: The user to change password for

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

###### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### delete

Delete specific user by id, name or email

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--email, -e`: Email of the user to delete

`--help, -h`: show help

`--id`: ID of user of the user to delete _(default: `0`)_

`--purge`: Purge user, all their repositories, organizations and comments

`--username, -u`: Username of the user to delete

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

###### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### generate-access-token

Generate an access token for a specific user

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--raw`: Display only the token value

`--scopes`: Comma separated list of scopes to apply to access token

`--token-name, -t`: Token name _(default: `gitea-admin`)_

`--username, -u`: Username

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

###### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### must-change-password

Set the must change password flag for the provided users or all users

`--all, -A`: All users must change password, except those explicitly excluded with --exclude

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--exclude, -e`: Do not change the must-change-password flag for these users

`--help, -h`: show help

`--unset`: Instead of setting the must-change-password flag, unset it

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

###### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

#### repo-sync-releases

Synchronize repository releases with tags

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

#### regenerate

Regenerate specific files

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### hooks

Regenerate git-hooks

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

###### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### keys

Regenerate authorized_keys file

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

###### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

#### auth

Modify external auth providers

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### add-oauth

Add new Oauth authentication source

`--admin-group`: Group Claim value for administrator users

`--auto-discover-url`: OpenID Connect Auto Discovery URL (only required when using OpenID Connect as provider)

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-auth-url`: Use a custom Authorization URL (option for GitLab/GitHub)

`--custom-email-url`: Use a custom Email URL (option for GitHub)

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--custom-profile-url`: Use a custom Profile URL (option for GitLab/GitHub)

`--custom-tenant-id`: Use custom Tenant ID for OAuth endpoints

`--custom-token-url`: Use a custom Token URL (option for GitLab/GitHub)

`--group-claim-name`: Claim name providing group names for this source

`--group-team-map`: JSON mapping between groups and org teams

`--group-team-map-removal`: Activate automatic team membership removal depending on groups

`--help, -h`: show help

`--icon-url`: Custom icon URL for OAuth2 login source

`--key`: Client ID (Key)

`--name`: Application Name

`--provider`: OAuth2 Provider

`--required-claim-name`: Claim name that has to be set to allow users to login with this source

`--required-claim-value`: Claim value that has to be set to allow users to login with this source

`--restricted-group`: Group Claim value for restricted users

`--scopes`: Scopes to request when to authenticate against this OAuth2 source

`--secret`: Client Secret

`--skip-local-2fa`: Set to true to skip local 2fa for users authenticated by this source

`--use-custom-urls`: Use custom URLs for GitLab/GitHub OAuth endpoints _(default: `false`)_

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

###### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### update-oauth

Update existing Oauth authentication source

`--admin-group`: Group Claim value for administrator users

`--auto-discover-url`: OpenID Connect Auto Discovery URL (only required when using OpenID Connect as provider)

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-auth-url`: Use a custom Authorization URL (option for GitLab/GitHub)

`--custom-email-url`: Use a custom Email URL (option for GitHub)

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--custom-profile-url`: Use a custom Profile URL (option for GitLab/GitHub)

`--custom-tenant-id`: Use custom Tenant ID for OAuth endpoints

`--custom-token-url`: Use a custom Token URL (option for GitLab/GitHub)

`--group-claim-name`: Claim name providing group names for this source

`--group-team-map`: JSON mapping between groups and org teams

`--group-team-map-removal`: Activate automatic team membership removal depending on groups

`--help, -h`: show help

`--icon-url`: Custom icon URL for OAuth2 login source

`--id`: ID of authentication source _(default: `0`)_

`--key`: Client ID (Key)

`--name`: Application Name

`--provider`: OAuth2 Provider

`--required-claim-name`: Claim name that has to be set to allow users to login with this source

`--required-claim-value`: Claim value that has to be set to allow users to login with this source

`--restricted-group`: Group Claim value for restricted users

`--scopes`: Scopes to request when to authenticate against this OAuth2 source

`--secret`: Client Secret

`--skip-local-2fa`: Set to true to skip local 2fa for users authenticated by this source

`--use-custom-urls`: Use custom URLs for GitLab/GitHub OAuth endpoints _(default: `false`)_

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

###### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### add-ldap

Add new LDAP (via Bind DN) authentication source

`--active`: Activate the authentication source.

`--admin-filter`: An LDAP filter specifying if a user should be given administrator privileges.

`--allow-deactivate-all`: Allow empty search results to deactivate all users.

`--attributes-in-bind`: Fetch attributes in bind DN context.

`--avatar-attribute`: The attribute of the user’s LDAP record containing the user’s avatar.

`--bind-dn`: The DN to bind to the LDAP server with when searching for the user.

`--bind-password`: The password for the Bind DN, if any.

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--disable-synchronize-users`: Disable user synchronization.

`--email-attribute`: The attribute of the user’s LDAP record containing the user’s email address.

`--firstname-attribute`: The attribute of the user’s LDAP record containing the user’s first name.

`--help, -h`: show help

`--host`: The address where the LDAP server can be reached.

`--name`: Authentication name.

`--not-active`: Deactivate the authentication source.

`--page-size`: Search page size. _(default: `0`)_

`--port`: The port to use when connecting to the LDAP server. _(default: `0`)_

`--public-ssh-key-attribute`: The attribute of the user’s LDAP record containing the user’s public ssh key.

`--restricted-filter`: An LDAP filter specifying if a user should be given restricted status.

`--security-protocol`: Security protocol name.

`--skip-local-2fa`: Set to true to skip local 2fa for users authenticated by this source

`--skip-tls-verify`: Disable TLS verification.

`--surname-attribute`: The attribute of the user’s LDAP record containing the user’s surname.

`--synchronize-users`: Enable user synchronization.

`--user-filter`: An LDAP filter declaring how to find the user record that is attempting to authenticate.

`--user-search-base`: The LDAP base at which user accounts will be searched for.

`--username-attribute`: The attribute of the user’s LDAP record containing the user name.

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

###### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### update-ldap

Update existing LDAP (via Bind DN) authentication source

`--active`: Activate the authentication source.

`--admin-filter`: An LDAP filter specifying if a user should be given administrator privileges.

`--allow-deactivate-all`: Allow empty search results to deactivate all users.

`--attributes-in-bind`: Fetch attributes in bind DN context.

`--avatar-attribute`: The attribute of the user’s LDAP record containing the user’s avatar.

`--bind-dn`: The DN to bind to the LDAP server with when searching for the user.

`--bind-password`: The password for the Bind DN, if any.

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--disable-synchronize-users`: Disable user synchronization.

`--email-attribute`: The attribute of the user’s LDAP record containing the user’s email address.

`--firstname-attribute`: The attribute of the user’s LDAP record containing the user’s first name.

`--help, -h`: show help

`--host`: The address where the LDAP server can be reached.

`--id`: ID of authentication source _(default: `0`)_

`--name`: Authentication name.

`--not-active`: Deactivate the authentication source.

`--page-size`: Search page size. _(default: `0`)_

`--port`: The port to use when connecting to the LDAP server. _(default: `0`)_

`--public-ssh-key-attribute`: The attribute of the user’s LDAP record containing the user’s public ssh key.

`--restricted-filter`: An LDAP filter specifying if a user should be given restricted status.

`--security-protocol`: Security protocol name.

`--skip-local-2fa`: Set to true to skip local 2fa for users authenticated by this source

`--skip-tls-verify`: Disable TLS verification.

`--surname-attribute`: The attribute of the user’s LDAP record containing the user’s surname.

`--synchronize-users`: Enable user synchronization.

`--user-filter`: An LDAP filter declaring how to find the user record that is attempting to authenticate.

`--user-search-base`: The LDAP base at which user accounts will be searched for.

`--username-attribute`: The attribute of the user’s LDAP record containing the user name.

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

###### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### add-ldap-simple

Add new LDAP (simple auth) authentication source

`--active`: Activate the authentication source.

`--admin-filter`: An LDAP filter specifying if a user should be given administrator privileges.

`--allow-deactivate-all`: Allow empty search results to deactivate all users.

`--avatar-attribute`: The attribute of the user’s LDAP record containing the user’s avatar.

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--email-attribute`: The attribute of the user’s LDAP record containing the user’s email address.

`--firstname-attribute`: The attribute of the user’s LDAP record containing the user’s first name.

`--help, -h`: show help

`--host`: The address where the LDAP server can be reached.

`--name`: Authentication name.

`--not-active`: Deactivate the authentication source.

`--port`: The port to use when connecting to the LDAP server. _(default: `0`)_

`--public-ssh-key-attribute`: The attribute of the user’s LDAP record containing the user’s public ssh key.

`--restricted-filter`: An LDAP filter specifying if a user should be given restricted status.

`--security-protocol`: Security protocol name.

`--skip-local-2fa`: Set to true to skip local 2fa for users authenticated by this source

`--skip-tls-verify`: Disable TLS verification.

`--surname-attribute`: The attribute of the user’s LDAP record containing the user’s surname.

`--user-dn`: The user’s DN.

`--user-filter`: An LDAP filter declaring how to find the user record that is attempting to authenticate.

`--user-search-base`: The LDAP base at which user accounts will be searched for.

`--username-attribute`: The attribute of the user’s LDAP record containing the user name.

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

###### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### update-ldap-simple

Update existing LDAP (simple auth) authentication source

`--active`: Activate the authentication source.

`--admin-filter`: An LDAP filter specifying if a user should be given administrator privileges.

`--allow-deactivate-all`: Allow empty search results to deactivate all users.

`--avatar-attribute`: The attribute of the user’s LDAP record containing the user’s avatar.

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--email-attribute`: The attribute of the user’s LDAP record containing the user’s email address.

`--firstname-attribute`: The attribute of the user’s LDAP record containing the user’s first name.

`--help, -h`: show help

`--host`: The address where the LDAP server can be reached.

`--id`: ID of authentication source _(default: `0`)_

`--name`: Authentication name.

`--not-active`: Deactivate the authentication source.

`--port`: The port to use when connecting to the LDAP server. _(default: `0`)_

`--public-ssh-key-attribute`: The attribute of the user’s LDAP record containing the user’s public ssh key.

`--restricted-filter`: An LDAP filter specifying if a user should be given restricted status.

`--security-protocol`: Security protocol name.

`--skip-local-2fa`: Set to true to skip local 2fa for users authenticated by this source

`--skip-tls-verify`: Disable TLS verification.

`--surname-attribute`: The attribute of the user’s LDAP record containing the user’s surname.

`--user-dn`: The user’s DN.

`--user-filter`: An LDAP filter declaring how to find the user record that is attempting to authenticate.

`--user-search-base`: The LDAP base at which user accounts will be searched for.

`--username-attribute`: The attribute of the user’s LDAP record containing the user name.

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

###### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### add-smtp

Add new SMTP authentication source

`--active`: This Authentication Source is Activated.

`--allowed-domains`: Leave empty to allow all domains. Separate multiple domains with a comma (',')

`--auth-type`: SMTP Authentication Type (PLAIN/LOGIN/CRAM-MD5) default PLAIN _(default: `PLAIN`)_

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--disable-helo`: Disable SMTP helo.

`--force-smtps`: SMTPS is always used on port 465. Set this to force SMTPS on other ports.

`--helo-hostname`: Hostname sent with HELO. Leave blank to send current hostname

`--help, -h`: show help

`--host`: SMTP Host

`--name`: Application Name

`--port`: SMTP Port _(default: `0`)_

`--skip-local-2fa`: Skip 2FA to log on.

`--skip-verify`: Skip TLS verify.

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

###### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### update-smtp

Update existing SMTP authentication source

`--active`: This Authentication Source is Activated.

`--allowed-domains`: Leave empty to allow all domains. Separate multiple domains with a comma (',')

`--auth-type`: SMTP Authentication Type (PLAIN/LOGIN/CRAM-MD5) default PLAIN _(default: `PLAIN`)_

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--disable-helo`: Disable SMTP helo.

`--force-smtps`: SMTPS is always used on port 465. Set this to force SMTPS on other ports.

`--helo-hostname`: Hostname sent with HELO. Leave blank to send current hostname

`--help, -h`: show help

`--host`: SMTP Host

`--id`: ID of authentication source _(default: `0`)_

`--name`: Application Name

`--port`: SMTP Port _(default: `0`)_

`--skip-local-2fa`: Skip 2FA to log on.

`--skip-verify`: Skip TLS verify.

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

###### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### list

List auth sources

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--min-width`: Minimal cell width including any padding for the formatted table _(default: `0`)_

`--pad-char`: ASCII char used for padding if padchar == '\\t', the Writer will assume that the width of a '\\t' in the formatted output is tabwidth, and cells are left-aligned independent of align*left (for correct-looking results, tabwidth must correspond to the tab width in the viewer displaying the result) *(default: `	`)\_

`--padding`: padding added to a cell before computing its width _(default: `0`)_

`--tab-width`: width of tab characters in formatted table (equivalent number of spaces) _(default: `0`)_

`--vertical-bars`: Set to true to print vertical bars between columns

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

###### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### delete

Delete specific auth source

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--id`: ID of authentication source _(default: `0`)_

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

###### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

#### sendmail

Send a message to all users

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--content`: a content of a message

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--force, -f`: A flag to bypass a confirmation step

`--help, -h`: show help

`--title`: a title of a message

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

#### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

### migrate

Migrate the database

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

#### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

### keys

This command queries the Forgejo database to get the authorized command for a given ssh key fingerprint

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--content, -k`: Base64 encoded content of the SSH key provided to the SSH Server (requires type to be provided too)

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--expected, -e`: Expected user for whom provide key commands _(default: `git`)_

`--help, -h`: show help

`--type, -t`: Type of the SSH key provided to the SSH Server (requires content to be provided too)

`--username, -u`: Username trying to log in by SSH

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

#### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

### doctor

Diagnose and optionally fix problems

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

#### check

Diagnose and optionally fix problems

`--all`: Run all the available checks

`--color, -H`: Use color for outputted information

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--default`: Run the default checks (if neither --run or --all is set, this is the default behaviour)

`--fix`: Automatically fix what we can

`--help, -h`: show help

`--list`: List the available checks

`--log-file`: Name of the log file (no verbose log output by default). Set to "-" to output to stdout

`--run`: Run the provided checks - (if --default is set, the default checks will also run)

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

#### recreate-table

Recreate tables from XORM definitions and copy the data.

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--debug`: Print SQL commands sent

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

#### convert

Convert the database

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

#### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

### manager

Manage the running gitea process

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

#### shutdown

Gracefully shutdown the running process

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--debug`:

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

#### restart

Gracefully restart the running process - (not implemented for windows servers)

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--debug`:

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

#### reload-templates

Reload template files in the running process

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--debug`:

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

#### flush-queues

Flush queues in the running process

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--debug`:

`--help, -h`: show help

`--non-blocking`: Set to true to not wait for flush to complete before returning

`--timeout`: Timeout for the flushing process _(default: `0s`)_

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

#### logging

Adjust logging commands

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### pause

Pause logging (Forgejo will buffer logs up to a certain point and will drop them after that point)

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--debug`:

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

###### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### resume

Resume logging

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--debug`:

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

###### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### release-and-reopen

Cause Forgejo to release and re-open files used for logging

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--debug`:

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

###### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### remove

Remove a logger

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--debug`:

`--help, -h`: show help

`--logger`: Logger name - will default to "default"

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

###### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### add

Add a logger

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

###### file

Add a file logger

`--color`: Use color in the logs

`--compress, -z`: Compress rotated logs

`--compression-level, -Z`: Compression level to use _(default: `0`)_

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--daily, -d`: Rotate logs daily

`--debug`:

`--expression, -e`: Matching expression for the logger

`--filename, -f`: Filename for the logger - this must be set.

`--flags, -F`: Flags for the logger

`--help, -h`: show help

`--level`: Logging level for the new logger

`--logger`: Logger name - will default to "default"

`--max-days, -D`: Maximum number of daily logs to keep _(default: `0`)_

`--max-size, -s`: Maximum size in bytes before rotation _(default: `0`)_

`--prefix, -p`: Prefix for the logger

`--rotate, -r`: Rotate logs

`--stacktrace-level, -L`: Stacktrace logging level

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

`--writer`: Name of the log writer - will default to mode

####### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

###### conn

Add a net conn logger

`--address, -a`: Host address and port to connect to _(default: `:7020`)_

`--color`: Use color in the logs

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--debug`:

`--expression, -e`: Matching expression for the logger

`--flags, -F`: Flags for the logger

`--help, -h`: show help

`--level`: Logging level for the new logger

`--logger`: Logger name - will default to "default"

`--prefix, -p`: Prefix for the logger

`--protocol, -P`: Set protocol to use: tcp, unix, or udp _(default: `tcp`)_

`--reconnect, -r`: Reconnect to host when connection is dropped

`--reconnect-on-message, -R`: Reconnect to host for every message

`--stacktrace-level, -L`: Stacktrace logging level

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

`--writer`: Name of the log writer - will default to mode

####### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

###### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### log-sql

Set LogSQL

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--debug`:

`--help, -h`: show help

`--off`: Switch off SQL logging

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

###### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

#### processes

Display running processes within the current process

`--cancel`: Process PID to cancel. (Only available for non-system processes.)

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--debug`:

`--flat`: Show processes as flat table rather than as tree

`--help, -h`: show help

`--json`: Output as json

`--no-system`: Do not show system processes

`--stacktraces`: Show stacktraces

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

#### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

### embedded

Extract embedded resources

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

#### list

List files matching the given pattern

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--include-vendored, --vendor`: Include files under public/vendor as well

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

#### view

View a file matching the given pattern

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--include-vendored, --vendor`: Include files under public/vendor as well

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

#### extract

Extract resources

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom`: Extract to the 'custom' directory as per app.ini

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--destination, --dest-dir`: Extract to the specified directory

`--help, -h`: show help

`--include-vendored, --vendor`: Include files under public/vendor as well

`--overwrite`: Overwrite files if they already exist

`--rename`: Rename files as {name}.bak if they already exist (overwrites previous .bak)

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

#### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

### migrate-storage

Migrate the storage

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--minio-access-key-id`: Minio storage accessKeyID

`--minio-base-path`: Minio storage base path on the bucket

`--minio-bucket`: Minio storage bucket

`--minio-checksum-algorithm`: Minio checksum algorithm (default/md5)

`--minio-endpoint`: Minio storage endpoint

`--minio-insecure-skip-verify`: Skip SSL verification

`--minio-location`: Minio storage location to create bucket

`--minio-secret-access-key`: Minio storage secretAccessKey

`--minio-use-ssl`: Enable SSL for minio

`--path, -p`: New storage placement if store is local (leave blank for default)

`--storage, -s`: New storage type: local (default) or minio

`--type, -t`: Type of stored files to copy. Allowed types: 'attachments', 'lfs', 'avatars', 'repo-avatars', 'repo-archivers', 'packages', 'actions-log'

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

#### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

### dump-repo

Dump the repository from git/github/gitea/gitlab

`--auth_password`: The password to visit the clone_addr

`--auth_token`: The personal token to visit the clone_addr

`--auth_username`: The username to visit the clone_addr

`--clone_addr`: The URL will be clone, currently could be a git/github/gitea/gitlab http/https URL

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--git_service`: Git service, git, github, gitea, gitlab. If clone_addr could be recognized, this could be ignored.

`--help, -h`: show help

`--owner_name`: The data will be stored on a directory with owner name if not empty

`--repo_dir, -r`: Repository dir path to store the data _(default: `./data`)_

`--repo_name`: The data will be stored on a directory with repository name if not empty

`--units`: Which items will be migrated, one or more units should be separated as comma.
wiki, issues, labels, releases, release_assets, milestones, pull_requests, comments are allowed. Empty means all units.

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

#### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

### restore-repo

Restore the repository from disk

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--owner_name`: Restore destination owner name

`--repo_dir, -r`: Repository dir path to restore from _(default: `./data`)_

`--repo_name`: Restore destination repository name

`--units`: Which items will be restored, one or more units should be separated as comma.
wiki, issues, labels, releases, release_assets, milestones, pull_requests, comments are allowed. Empty means all units.

`--validation`: Sanity check the content of the files before trying to load them

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

#### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

### actions

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

#### generate-runner-token, grt

Generate a new token for a runner to use to register with the server

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--scope, -s`: {owner}[/{repo}] - leave empty for a global runner

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

##### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

#### help, h

Shows a list of commands or help for one command

`--config, -c`: Set custom config file _(default: `{WorkPath}/custom/conf/app.ini`)_

`--custom-path, -C`: Set custom path _(default: `{WorkPath}/custom`)_

`--help, -h`: show help

`--work-path, -w`: Set Forgejo's working path (defaults to the Forgejo's binary directory)

### cert

Generate self-signed certificate

`--ca`: whether this cert should be its own Certificate Authority

`--duration`: Duration that certificate is valid for _(default: `0s`)_

`--ecdsa-curve`: ECDSA curve to use to generate a key. Valid values are P224, P256, P384, P521

`--host`: Comma-separated hostnames and IPs to generate a certificate for

`--rsa-bits`: Size of RSA key to generate. Ignored if --ecdsa-curve is set _(default: `0`)_

`--start-date`: Creation date formatted as Jan 1 15:04:05 2011

### generate

Command line interface for running generators

#### secret

Generate a secret token

##### INTERNAL_TOKEN

Generate a new INTERNAL_TOKEN

##### JWT_SECRET, LFS_JWT_SECRET

Generate a new JWT_SECRET

##### SECRET_KEY

Generate a new SECRET_KEY

### docs

Output CLI documentation

`--help, -h`: show help

`--man`: Output man pages instead

`--output, -o`: Path to output to instead of stdout (will overwrite if exists)

#### help, h

Shows a list of commands or help for one command

### forgejo-cli

Forgejo CLI

#### actions

Commands for managing Forgejo Actions

##### generate-runner-token

Generate a new token for a runner to use to register with the server

`--scope, -s`: {owner}[/{repo}] - leave empty for a global runner

##### generate-secret

Generate a secret suitable for input to the register subcommand

##### register

Idempotent registration of a runner using a shared secret

`--labels`: comma separated list of labels supported by the runner (e.g. docker,ubuntu-latest,self-hosted) (not required since v1.21)

`--name`: name of the runner (default runner) _(default: `runner`)_

`--scope, -s`: {owner}[/{repo}] - leave empty for a global runner

`--secret`: the secret the runner will use to connect as a 40 character hexadecimal string

`--secret-file`: path to the file containing the secret the runner will use to connect as a 40 character hexadecimal string

`--secret-stdin`: the secret the runner will use to connect as a 40 character hexadecimal string, read from stdin

`--version`: version of the runner (not required since v1.21)

#### f3

F3

##### mirror

Mirror

`--from`: `URL` or directory of the from forge

`--from-password`: `PASSWORD` of the user

`--from-token`: `TOKEN` of the user

`--from-type`: `TYPE` of the from forge (default: F3, allowed values are F3,GitLab,forgejo)

`--from-user`: `USER` to access the forge API

`--from-validation`: validate the JSON files against F3 JSON schemas

`--repository`: The name of the repository

`--to`: `URL` or directory of the to forge

`--to-password`: `PASSWORD` of the user

`--to-token`: `TOKEN` of the user

`--to-type`: `TYPE` of the to forge (default: F3, allowed values are F3,GitLab,forgejo)

`--to-user`: `USER` to access the forge API

`--to-validation`: validate the JSON files against F3 JSON schemas

`--user`: The name of the user who owns the repository
