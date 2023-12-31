---
title: Forgejo CLI
license: 'CC-BY-SA-4.0'
---

<!--
This page should not be edited manually.
To update this page, run the following command from the root of the docs repo:
```
./scripts/cli-docs.sh > ./docs/admin/command-line.md
```
-->

## forgejo `--help`

```
NAME:
   Forgejo - Beyond coding. We forge.

USAGE:
   Forgejo [global options] command [command options] [arguments...]

VERSION:
   1.21.3+0 built with GNU Make 4.4.1, go1.21.5 : bindata, timetzdata, sqlite, sqlite_unlock_notify

DESCRIPTION:
   By default, forgejo will start serving using the web-server with no argument, which can alternatively be run by running the subcommand "web".

COMMANDS:
   web              Start the Forgejo web server
   serv             This command should only be called by SSH shell
   hook             Delegate commands to corresponding Git hooks
   dump             Dump Forgejo files and database
   admin            Command line interface to perform common administrative operations
   migrate          Migrate the database
   keys             This command queries the Forgejo database to get the authorized command for a given ssh key fingerprint
   doctor           Diagnose and optionally fix problems
   manager          Manage the running forgejo process
   embedded         Extract embedded resources
   migrate-storage  Migrate the storage
   dump-repo        Dump the repository from git/github/gitea/gitlab
   restore-repo     Restore the repository from disk
   help, h          Shows a list of commands or help for one command
   cert             Generate self-signed certificate
   generate         Command line interface for running generators
   docs             Output CLI documentation
   forgejo-cli      Forgejo CLI

GLOBAL OPTIONS:
   --version, -v                  print the version
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
```

## forgejo-cli

```
NAME:
   Forgejo forgejo-cli - Forgejo CLI

USAGE:
   Forgejo forgejo-cli command [command options] [arguments...]

COMMANDS:
   actions  Commands for managing Forgejo Actions
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h  show help
```

### forgejo-cli actions

```
NAME:
   Forgejo forgejo-cli actions - Commands for managing Forgejo Actions

USAGE:
   Forgejo forgejo-cli actions command [command options] [arguments...]

COMMANDS:
   generate-runner-token  Generate a new token for a runner to use to register with the server
   generate-secret        Generate a secret suitable for input to the register subcommand
   register               Idempotent registration of a runner using a shared secret
   help, h                Shows a list of commands or help for one command

OPTIONS:
   --help, -h  show help
```

### forgejo-cli actions generate-runner-token

```
NAME:
   Forgejo forgejo-cli actions generate-runner-token - Generate a new token for a runner to use to register with the server

USAGE:
   Forgejo forgejo-cli actions generate-runner-token [command options] [arguments...]

OPTIONS:
   --scope value, -s value  {owner}[/{repo}] - leave empty for a global runner
   --help, -h               show help
```

### forgejo-cli actions generate-secret

```
NAME:
   Forgejo forgejo-cli actions generate-secret - Generate a secret suitable for input to the register subcommand

USAGE:
   Forgejo forgejo-cli actions generate-secret [command options] [arguments...]

OPTIONS:
   --help, -h  show help
```

### forgejo-cli actions register

```
NAME:
   Forgejo forgejo-cli actions register - Idempotent registration of a runner using a shared secret

USAGE:
   Forgejo forgejo-cli actions register [command options] [arguments...]

OPTIONS:
   --secret value           the secret the runner will use to connect as a 40 character hexadecimal string
   --secret-stdin value     the secret the runner will use to connect as a 40 character hexadecimal string, read from stdin
   --secret-file value      path to the file containing the secret the runner will use to connect as a 40 character hexadecimal string
   --scope value, -s value  {owner}[/{repo}] - leave empty for a global runner
   --labels value           comma separated list of labels supported by the runner (e.g. docker,ubuntu-latest,self-hosted)  (not required since v1.21)
   --name value             name of the runner (default runner) (default: "runner")
   --version value          version of the runner (not required since v1.21)
   --help, -h               show help
```

## web

```
NAME:
   Forgejo web - Start the Forgejo web server

USAGE:
   Forgejo web command [command options] [arguments...]

DESCRIPTION:
   The Forgejo web server is the only thing you need to run,
   and it takes care of all the other things for you

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --port value, -p value         Temporary port number to prevent conflict (default: "3000")
   --install-port value           Temporary port number to run the install page on to prevent conflict (default: "3000")
   --pid value, -P value          Custom pid file path (default: "/run/gitea.pid")
   --quiet, -q                    Only display Fatal logging errors until logging is set-up (default: false)
   --verbose                      Set initial logging to TRACE level until logging is properly set-up (default: false)
```

## dump

```
NAME:
   Forgejo dump - Dump Forgejo files and database

USAGE:
   Forgejo dump command [command options] [arguments...]

DESCRIPTION:
   Dump compresses all related files and database into zip file.
   It can be used for backup and capture Forgejo server image to send to maintainer

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --file value, -f value         Name of the dump file which will be created. Supply '-' for stdout. See type for available types. (default: "forgejo-dump-<timestamp>.zip")
   --verbose, -V                  Show process details (default: false)
   --quiet, -q                    Only display warnings and errors (default: false)
   --tempdir value, -t value      Temporary dir path (default: "/tmp")
   --database value, -d value     Specify the database SQL syntax: sqlite3, mysql, mssql, postgres
   --skip-repository, -R          Skip the repository dumping (default: false)
   --skip-log, -L                 Skip the log dumping (default: false)
   --skip-custom-dir              Skip custom directory (default: false)
   --skip-lfs-data                Skip LFS data (default: false)
   --skip-attachment-data         Skip attachment data (default: false)
   --skip-package-data            Skip package data (default: false)
   --skip-index                   Skip bleve index data (default: false)
   --type value                   Dump output format: zip, tar, tar.sz, tar.gz, tar.xz, tar.bz2, tar.br, tar.lz4, tar.zst (default: zip)
```

## admin

```
NAME:
   Forgejo admin - Command line interface to perform common administrative operations

USAGE:
   Forgejo admin command [command options] [arguments...]

COMMANDS:
   user                Modify users
   repo-sync-releases  Synchronize repository releases with tags
   regenerate          Regenerate specific files
   auth                Modify external auth providers
   sendmail            Send a message to all users
   help, h             Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
```

### admin user

```
NAME:
   Forgejo admin user - Modify users

USAGE:
   Forgejo admin user command [command options] [arguments...]

COMMANDS:
   create                 Create a new user in database
   list                   List users
   change-password        Change a user's password
   delete                 Delete specific user by id, name or email
   generate-access-token  Generate an access token for a specific user
   must-change-password   Set the must change password flag for the provided users or all users
   help, h                Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
```

### admin user create

```
NAME:
   Forgejo admin user create - Create a new user in database

USAGE:
   Forgejo admin user create command [command options] [arguments...]

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                      show help
   --custom-path value, -C value   Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value        Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value     Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --name value                    Username. DEPRECATED: use username instead
   --username value                Username
   --password value                User password
   --email value                   User email address
   --admin                         User is an admin (default: false)
   --random-password               Generate a random password for the user (default: false)
   --must-change-password          Set this option to false to prevent forcing the user to change their password after initial login, (Default: true) (default: false)
   --random-password-length value  Length of the random password to be generated (default: 12)
   --access-token                  Generate access token for the user (default: false)
   --restricted                    Make a restricted user account (default: false)
```

### admin user list

```
NAME:
   Forgejo admin user list - List users

USAGE:
   Forgejo admin user list command [command options] [arguments...]

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --admin                        List only admin users (default: false)
```

### admin user change-password

```
NAME:
   Forgejo admin user change-password - Change a user's password

USAGE:
   Forgejo admin user change-password command [command options] [arguments...]

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --username value, -u value     The user to change password for
   --password value, -p value     New password to set for user
```

### admin user delete

```
NAME:
   Forgejo admin user delete - Delete specific user by id, name or email

USAGE:
   Forgejo admin user delete command [command options] [arguments...]

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --id value                     ID of user of the user to delete (default: 0)
   --username value, -u value     Username of the user to delete
   --email value, -e value        Email of the user to delete
   --purge                        Purge user, all their repositories, organizations and comments (default: false)
```

### admin user generate-access-token

```
NAME:
   Forgejo admin user generate-access-token - Generate an access token for a specific user

USAGE:
   Forgejo admin user generate-access-token command [command options] [arguments...]

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --username value, -u value     Username
   --token-name value, -t value   Token name (default: "gitea-admin")
   --raw                          Display only the token value (default: false)
   --scopes value                 Comma separated list of scopes to apply to access token
```

### admin user must-change-password

```
NAME:
   Forgejo admin user must-change-password - Set the must change password flag for the provided users or all users

USAGE:
   Forgejo admin user must-change-password command [command options] [arguments...]

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                                               show help
   --custom-path value, -C value                            Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value                                 Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value                              Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --all, -A                                                All users must change password, except those explicitly excluded with --exclude (default: false)
   --exclude value, -e value [ --exclude value, -e value ]  Do not change the must-change-password flag for these users
   --unset                                                  Instead of setting the must-change-password flag, unset it (default: false)
```

### admin repo-sync-releases

```
NAME:
   Forgejo admin repo-sync-releases - Synchronize repository releases with tags

USAGE:
   Forgejo admin repo-sync-releases command [command options] [arguments...]

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
```

### admin regenerate

```
NAME:
   Forgejo admin regenerate - Regenerate specific files

USAGE:
   Forgejo admin regenerate command [command options] [arguments...]

COMMANDS:
   hooks    Regenerate git-hooks
   keys     Regenerate authorized_keys file
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
```

### admin auth

```
NAME:
   Forgejo admin auth - Modify external auth providers

USAGE:
   Forgejo admin auth command [command options] [arguments...]

COMMANDS:
   add-oauth           Add new Oauth authentication source
   update-oauth        Update existing Oauth authentication source
   add-ldap            Add new LDAP (via Bind DN) authentication source
   update-ldap         Update existing LDAP (via Bind DN) authentication source
   add-ldap-simple     Add new LDAP (simple auth) authentication source
   update-ldap-simple  Update existing LDAP (simple auth) authentication source
   add-smtp            Add new SMTP authentication source
   update-smtp         Update existing SMTP authentication source
   list                List auth sources
   delete              Delete specific auth source
   help, h             Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
```

### admin auth add-oauth

```
NAME:
   Forgejo admin auth add-oauth - Add new Oauth authentication source

USAGE:
   Forgejo admin auth add-oauth command [command options] [arguments...]

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                         show help
   --custom-path value, -C value      Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value           Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value        Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --name value                       Application Name
   --provider value                   OAuth2 Provider
   --key value                        Client ID (Key)
   --secret value                     Client Secret
   --auto-discover-url value          OpenID Connect Auto Discovery URL (only required when using OpenID Connect as provider)
   --use-custom-urls value            Use custom URLs for GitLab/GitHub OAuth endpoints (default: "false")
   --custom-tenant-id value           Use custom Tenant ID for OAuth endpoints
   --custom-auth-url value            Use a custom Authorization URL (option for GitLab/GitHub)
   --custom-token-url value           Use a custom Token URL (option for GitLab/GitHub)
   --custom-profile-url value         Use a custom Profile URL (option for GitLab/GitHub)
   --custom-email-url value           Use a custom Email URL (option for GitHub)
   --icon-url value                   Custom icon URL for OAuth2 login source
   --skip-local-2fa                   Set to true to skip local 2fa for users authenticated by this source (default: false)
   --scopes value [ --scopes value ]  Scopes to request when to authenticate against this OAuth2 source
   --required-claim-name value        Claim name that has to be set to allow users to login with this source
   --required-claim-value value       Claim value that has to be set to allow users to login with this source
   --group-claim-name value           Claim name providing group names for this source
   --admin-group value                Group Claim value for administrator users
   --restricted-group value           Group Claim value for restricted users
   --group-team-map value             JSON mapping between groups and org teams
   --group-team-map-removal           Activate automatic team membership removal depending on groups (default: false)
```

### admin auth update-oauth

```
NAME:
   Forgejo admin auth update-oauth - Update existing Oauth authentication source

USAGE:
   Forgejo admin auth update-oauth command [command options] [arguments...]

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                         show help
   --custom-path value, -C value      Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value           Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value        Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --name value                       Application Name
   --id value                         ID of authentication source (default: 0)
   --provider value                   OAuth2 Provider
   --key value                        Client ID (Key)
   --secret value                     Client Secret
   --auto-discover-url value          OpenID Connect Auto Discovery URL (only required when using OpenID Connect as provider)
   --use-custom-urls value            Use custom URLs for GitLab/GitHub OAuth endpoints (default: "false")
   --custom-tenant-id value           Use custom Tenant ID for OAuth endpoints
   --custom-auth-url value            Use a custom Authorization URL (option for GitLab/GitHub)
   --custom-token-url value           Use a custom Token URL (option for GitLab/GitHub)
   --custom-profile-url value         Use a custom Profile URL (option for GitLab/GitHub)
   --custom-email-url value           Use a custom Email URL (option for GitHub)
   --icon-url value                   Custom icon URL for OAuth2 login source
   --skip-local-2fa                   Set to true to skip local 2fa for users authenticated by this source (default: false)
   --scopes value [ --scopes value ]  Scopes to request when to authenticate against this OAuth2 source
   --required-claim-name value        Claim name that has to be set to allow users to login with this source
   --required-claim-value value       Claim value that has to be set to allow users to login with this source
   --group-claim-name value           Claim name providing group names for this source
   --admin-group value                Group Claim value for administrator users
   --restricted-group value           Group Claim value for restricted users
   --group-team-map value             JSON mapping between groups and org teams
   --group-team-map-removal           Activate automatic team membership removal depending on groups (default: false)
```

### admin auth add-ldap

```
NAME:
   Forgejo admin auth add-ldap - Add new LDAP (via Bind DN) authentication source

USAGE:
   Forgejo admin auth add-ldap command [command options] [arguments...]

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                        show help
   --custom-path value, -C value     Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value          Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value       Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --name value                      Authentication name.
   --not-active                      Deactivate the authentication source. (default: false)
   --active                          Activate the authentication source. (default: false)
   --security-protocol value         Security protocol name.
   --skip-tls-verify                 Disable TLS verification. (default: false)
   --host value                      The address where the LDAP server can be reached.
   --port value                      The port to use when connecting to the LDAP server. (default: 0)
   --user-search-base value          The LDAP base at which user accounts will be searched for.
   --user-filter value               An LDAP filter declaring how to find the user record that is attempting to authenticate.
   --admin-filter value              An LDAP filter specifying if a user should be given administrator privileges.
   --restricted-filter value         An LDAP filter specifying if a user should be given restricted status.
   --allow-deactivate-all            Allow empty search results to deactivate all users. (default: false)
   --username-attribute value        The attribute of the user’s LDAP record containing the user name.
   --firstname-attribute value       The attribute of the user’s LDAP record containing the user’s first name.
   --surname-attribute value         The attribute of the user’s LDAP record containing the user’s surname.
   --email-attribute value           The attribute of the user’s LDAP record containing the user’s email address.
   --public-ssh-key-attribute value  The attribute of the user’s LDAP record containing the user’s public ssh key.
   --skip-local-2fa                  Set to true to skip local 2fa for users authenticated by this source (default: false)
   --avatar-attribute value          The attribute of the user’s LDAP record containing the user’s avatar.
   --bind-dn value                   The DN to bind to the LDAP server with when searching for the user.
   --bind-password value             The password for the Bind DN, if any.
   --attributes-in-bind              Fetch attributes in bind DN context. (default: false)
   --synchronize-users               Enable user synchronization. (default: false)
   --disable-synchronize-users       Disable user synchronization. (default: false)
   --page-size value                 Search page size. (default: 0)
```

### admin auth update-ldap

```
NAME:
   Forgejo admin auth update-ldap - Update existing LDAP (via Bind DN) authentication source

USAGE:
   Forgejo admin auth update-ldap command [command options] [arguments...]

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                        show help
   --custom-path value, -C value     Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value          Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value       Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --id value                        ID of authentication source (default: 0)
   --name value                      Authentication name.
   --not-active                      Deactivate the authentication source. (default: false)
   --active                          Activate the authentication source. (default: false)
   --security-protocol value         Security protocol name.
   --skip-tls-verify                 Disable TLS verification. (default: false)
   --host value                      The address where the LDAP server can be reached.
   --port value                      The port to use when connecting to the LDAP server. (default: 0)
   --user-search-base value          The LDAP base at which user accounts will be searched for.
   --user-filter value               An LDAP filter declaring how to find the user record that is attempting to authenticate.
   --admin-filter value              An LDAP filter specifying if a user should be given administrator privileges.
   --restricted-filter value         An LDAP filter specifying if a user should be given restricted status.
   --allow-deactivate-all            Allow empty search results to deactivate all users. (default: false)
   --username-attribute value        The attribute of the user’s LDAP record containing the user name.
   --firstname-attribute value       The attribute of the user’s LDAP record containing the user’s first name.
   --surname-attribute value         The attribute of the user’s LDAP record containing the user’s surname.
   --email-attribute value           The attribute of the user’s LDAP record containing the user’s email address.
   --public-ssh-key-attribute value  The attribute of the user’s LDAP record containing the user’s public ssh key.
   --skip-local-2fa                  Set to true to skip local 2fa for users authenticated by this source (default: false)
   --avatar-attribute value          The attribute of the user’s LDAP record containing the user’s avatar.
   --bind-dn value                   The DN to bind to the LDAP server with when searching for the user.
   --bind-password value             The password for the Bind DN, if any.
   --attributes-in-bind              Fetch attributes in bind DN context. (default: false)
   --synchronize-users               Enable user synchronization. (default: false)
   --disable-synchronize-users       Disable user synchronization. (default: false)
   --page-size value                 Search page size. (default: 0)
```

### admin auth add-ldap-simple

```
NAME:
   Forgejo admin auth add-ldap-simple - Add new LDAP (simple auth) authentication source

USAGE:
   Forgejo admin auth add-ldap-simple command [command options] [arguments...]

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                        show help
   --custom-path value, -C value     Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value          Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value       Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --name value                      Authentication name.
   --not-active                      Deactivate the authentication source. (default: false)
   --active                          Activate the authentication source. (default: false)
   --security-protocol value         Security protocol name.
   --skip-tls-verify                 Disable TLS verification. (default: false)
   --host value                      The address where the LDAP server can be reached.
   --port value                      The port to use when connecting to the LDAP server. (default: 0)
   --user-search-base value          The LDAP base at which user accounts will be searched for.
   --user-filter value               An LDAP filter declaring how to find the user record that is attempting to authenticate.
   --admin-filter value              An LDAP filter specifying if a user should be given administrator privileges.
   --restricted-filter value         An LDAP filter specifying if a user should be given restricted status.
   --allow-deactivate-all            Allow empty search results to deactivate all users. (default: false)
   --username-attribute value        The attribute of the user’s LDAP record containing the user name.
   --firstname-attribute value       The attribute of the user’s LDAP record containing the user’s first name.
   --surname-attribute value         The attribute of the user’s LDAP record containing the user’s surname.
   --email-attribute value           The attribute of the user’s LDAP record containing the user’s email address.
   --public-ssh-key-attribute value  The attribute of the user’s LDAP record containing the user’s public ssh key.
   --skip-local-2fa                  Set to true to skip local 2fa for users authenticated by this source (default: false)
   --avatar-attribute value          The attribute of the user’s LDAP record containing the user’s avatar.
   --user-dn value                   The user’s DN.
```

### admin auth update-ldap-simple

```
NAME:
   Forgejo admin auth update-ldap-simple - Update existing LDAP (simple auth) authentication source

USAGE:
   Forgejo admin auth update-ldap-simple command [command options] [arguments...]

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                        show help
   --custom-path value, -C value     Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value          Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value       Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --id value                        ID of authentication source (default: 0)
   --name value                      Authentication name.
   --not-active                      Deactivate the authentication source. (default: false)
   --active                          Activate the authentication source. (default: false)
   --security-protocol value         Security protocol name.
   --skip-tls-verify                 Disable TLS verification. (default: false)
   --host value                      The address where the LDAP server can be reached.
   --port value                      The port to use when connecting to the LDAP server. (default: 0)
   --user-search-base value          The LDAP base at which user accounts will be searched for.
   --user-filter value               An LDAP filter declaring how to find the user record that is attempting to authenticate.
   --admin-filter value              An LDAP filter specifying if a user should be given administrator privileges.
   --restricted-filter value         An LDAP filter specifying if a user should be given restricted status.
   --allow-deactivate-all            Allow empty search results to deactivate all users. (default: false)
   --username-attribute value        The attribute of the user’s LDAP record containing the user name.
   --firstname-attribute value       The attribute of the user’s LDAP record containing the user’s first name.
   --surname-attribute value         The attribute of the user’s LDAP record containing the user’s surname.
   --email-attribute value           The attribute of the user’s LDAP record containing the user’s email address.
   --public-ssh-key-attribute value  The attribute of the user’s LDAP record containing the user’s public ssh key.
   --skip-local-2fa                  Set to true to skip local 2fa for users authenticated by this source (default: false)
   --avatar-attribute value          The attribute of the user’s LDAP record containing the user’s avatar.
   --user-dn value                   The user’s DN.
```

### admin auth add-smtp

```
NAME:
   Forgejo admin auth add-smtp - Add new SMTP authentication source

USAGE:
   Forgejo admin auth add-smtp command [command options] [arguments...]

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --name value                   Application Name
   --auth-type value              SMTP Authentication Type (PLAIN/LOGIN/CRAM-MD5) default PLAIN (default: "PLAIN")
   --host value                   SMTP Host
   --port value                   SMTP Port (default: 0)
   --force-smtps                  SMTPS is always used on port 465. Set this to force SMTPS on other ports. (default: true)
   --skip-verify                  Skip TLS verify. (default: true)
   --helo-hostname value          Hostname sent with HELO. Leave blank to send current hostname
   --disable-helo                 Disable SMTP helo. (default: true)
   --allowed-domains value        Leave empty to allow all domains. Separate multiple domains with a comma (',')
   --skip-local-2fa               Skip 2FA to log on. (default: true)
   --active                       This Authentication Source is Activated. (default: true)
```

### admin auth update-smtp

```
NAME:
   Forgejo admin auth update-smtp - Update existing SMTP authentication source

USAGE:
   Forgejo admin auth update-smtp command [command options] [arguments...]

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --name value                   Application Name
   --id value                     ID of authentication source (default: 0)
   --auth-type value              SMTP Authentication Type (PLAIN/LOGIN/CRAM-MD5) default PLAIN (default: "PLAIN")
   --host value                   SMTP Host
   --port value                   SMTP Port (default: 0)
   --force-smtps                  SMTPS is always used on port 465. Set this to force SMTPS on other ports. (default: true)
   --skip-verify                  Skip TLS verify. (default: true)
   --helo-hostname value          Hostname sent with HELO. Leave blank to send current hostname
   --disable-helo                 Disable SMTP helo. (default: true)
   --allowed-domains value        Leave empty to allow all domains. Separate multiple domains with a comma (',')
   --skip-local-2fa               Skip 2FA to log on. (default: true)
   --active                       This Authentication Source is Activated. (default: true)
```

### admin auth list

```
NAME:
   Forgejo admin auth list - List auth sources

USAGE:
   Forgejo admin auth list command [command options] [arguments...]

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --min-width value              Minimal cell width including any padding for the formatted table (default: 0)
   --tab-width value              width of tab characters in formatted table (equivalent number of spaces) (default: 8)
   --padding value                padding added to a cell before computing its width (default: 1)
   --pad-char value               ASCII char used for padding if padchar == '\\t', the Writer will assume that the width of a '\\t' in the formatted output is tabwidth, and cells are left-aligned independent of align_left (for correct-looking results, tabwidth must correspond to the tab width in the viewer displaying the result) (default: "\t")
   --vertical-bars                Set to true to print vertical bars between columns (default: false)
```

### admin auth delete

```
NAME:
   Forgejo admin auth delete - Delete specific auth source

USAGE:
   Forgejo admin auth delete command [command options] [arguments...]

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --id value                     ID of authentication source (default: 0)
```

### admin sendmail

```
NAME:
   Forgejo admin sendmail - Send a message to all users

USAGE:
   Forgejo admin sendmail command [command options] [arguments...]

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --title value                  a title of a message
   --content value                a content of a message
   --force, -f                    A flag to bypass a confirmation step (default: false)
```

## migrate

```
NAME:
   Forgejo migrate - Migrate the database

USAGE:
   Forgejo migrate command [command options] [arguments...]

DESCRIPTION:
   This is a command for migrating the database, so that you can run gitea admin create-user before starting the server.

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
```

## keys

```
NAME:
   Forgejo keys - This command queries the Forgejo database to get the authorized command for a given ssh key fingerprint

USAGE:
   Forgejo keys command [command options] [arguments...]

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --expected value, -e value     Expected user for whom provide key commands (default: "git")
   --username value, -u value     Username trying to log in by SSH
   --type value, -t value         Type of the SSH key provided to the SSH Server (requires content to be provided too)
   --content value, -k value      Base64 encoded content of the SSH key provided to the SSH Server (requires type to be provided too)
```

## doctor

```
NAME:
   Forgejo doctor - Diagnose and optionally fix problems

USAGE:
   Forgejo doctor command [command options] [arguments...]

DESCRIPTION:
   A command to diagnose problems with the current Forgejo instance according to the given configuration. Some problems can optionally be fixed by modifying the database or data storage.

COMMANDS:
   check           Diagnose and optionally fix problems
   recreate-table  Recreate tables from XORM definitions and copy the data.
   convert         Convert the database
   help, h         Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
```

### doctor check

```
NAME:
   Forgejo doctor check - Diagnose and optionally fix problems

USAGE:
   Forgejo doctor check command [command options] [arguments...]

DESCRIPTION:
   A command to diagnose problems with the current Forgejo instance according to the given configuration. Some problems can optionally be fixed by modifying the database or data storage.

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --list                         List the available checks (default: false)
   --default                      Run the default checks (if neither --run or --all is set, this is the default behaviour) (default: false)
   --run value [ --run value ]    Run the provided checks - (if --default is set, the default checks will also run)
   --all                          Run all the available checks (default: false)
   --fix                          Automatically fix what we can (default: false)
   --log-file value               Name of the log file (no verbose log output by default). Set to "-" to output to stdout
   --color, -H                    Use color for outputted information (default: false)
```

### doctor recreate-table

```
NAME:
   Forgejo doctor recreate-table - Recreate tables from XORM definitions and copy the data.

USAGE:
   Forgejo doctor recreate-table command [command options] [TABLE]... : (TABLEs to recreate - leave blank for all)

DESCRIPTION:
   The database definitions Forgejo uses change across versions, sometimes changing default values and leaving old unused columns.

   This command will cause Xorm to recreate tables, copying over the data and deleting the old table.

   You should back-up your database before doing this and ensure that your database is up-to-date first.

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --debug                        Print SQL commands sent (default: false)
```

### doctor convert

```
NAME:
   Forgejo doctor convert - Convert the database

USAGE:
   Forgejo doctor convert command [command options] [arguments...]

DESCRIPTION:
   A command to convert an existing MySQL database from utf8 to utf8mb4 or MSSQL database from varchar to nvarchar

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
```

## manager

```
NAME:
   Forgejo manager - Manage the running forgejo process

USAGE:
   Forgejo manager command [command options] [arguments...]

DESCRIPTION:
   This is a command for managing the running forgejo process

COMMANDS:
   shutdown          Gracefully shutdown the running process
   restart           Gracefully restart the running process - (not implemented for windows servers)
   reload-templates  Reload template files in the running process
   flush-queues      Flush queues in the running process
   logging           Adjust logging commands
   processes         Display running processes within the current process
   help, h           Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
```

### manager shutdown

```
NAME:
   Forgejo manager shutdown - Gracefully shutdown the running process

USAGE:
   Forgejo manager shutdown command [command options] [arguments...]

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --debug                        (default: false)
```

### manager restart

```
NAME:
   Forgejo manager restart - Gracefully restart the running process - (not implemented for windows servers)

USAGE:
   Forgejo manager restart command [command options] [arguments...]

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --debug                        (default: false)
```

### manager reload-templates

```
NAME:
   Forgejo manager reload-templates - Reload template files in the running process

USAGE:
   Forgejo manager reload-templates command [command options] [arguments...]

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --debug                        (default: false)
```

### manager flush-queues

```
NAME:
   Forgejo manager flush-queues - Flush queues in the running process

USAGE:
   Forgejo manager flush-queues command [command options] [arguments...]

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --timeout value                Timeout for the flushing process (default: 1m0s)
   --non-blocking                 Set to true to not wait for flush to complete before returning (default: false)
   --debug                        (default: false)
```

### manager logging

```
NAME:
   Forgejo manager logging - Adjust logging commands

USAGE:
   Forgejo manager logging command [command options] [arguments...]

COMMANDS:
   pause               Pause logging (Forgejo will buffer logs up to a certain point and will drop them after that point)
   resume              Resume logging
   release-and-reopen  Cause Forgejo to release and re-open files used for logging
   remove              Remove a logger
   add                 Add a logger
   log-sql             Set LogSQL
   help, h             Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
```

### manager logging pause

```
NAME:
   Forgejo manager logging pause - Pause logging (Forgejo will buffer logs up to a certain point and will drop them after that point)

USAGE:
   Forgejo manager logging pause command [command options] [arguments...]

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --debug                        (default: false)
```

### manager logging resume

```
NAME:
   Forgejo manager logging resume - Resume logging

USAGE:
   Forgejo manager logging resume command [command options] [arguments...]

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --debug                        (default: false)
```

### manager logging release-and-reopen

```
NAME:
   Forgejo manager logging release-and-reopen - Cause Forgejo to release and re-open files used for logging

USAGE:
   Forgejo manager logging release-and-reopen command [command options] [arguments...]

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --debug                        (default: false)
```

### manager logging remove

```
NAME:
   Forgejo manager logging remove - Remove a logger

USAGE:
   Forgejo manager logging remove command [command options] [name] Name of logger to remove

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --debug                        (default: false)
   --logger value                 Logger name - will default to "default"
```

### manager logging add

```
NAME:
   Forgejo manager logging add - Add a logger

USAGE:
   Forgejo manager logging add command [command options] [arguments...]

COMMANDS:
   file     Add a file logger
   conn     Add a net conn logger
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
```

### manager logging add file

```
NAME:
   Forgejo manager logging add file - Add a file logger

USAGE:
   Forgejo manager logging add file command [command options] [arguments...]

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                           show help
   --custom-path value, -C value        Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value             Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value          Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --logger value                       Logger name - will default to "default"
   --writer value                       Name of the log writer - will default to mode
   --level value                        Logging level for the new logger
   --stacktrace-level value, -L value   Stacktrace logging level
   --flags value, -F value              Flags for the logger
   --expression value, -e value         Matching expression for the logger
   --prefix value, -p value             Prefix for the logger
   --color                              Use color in the logs (default: false)
   --debug                              (default: false)
   --filename value, -f value           Filename for the logger - this must be set.
   --rotate, -r                         Rotate logs (default: true)
   --max-size value, -s value           Maximum size in bytes before rotation (default: 0)
   --daily, -d                          Rotate logs daily (default: true)
   --max-days value, -D value           Maximum number of daily logs to keep (default: 0)
   --compress, -z                       Compress rotated logs (default: true)
   --compression-level value, -Z value  Compression level to use (default: 0)
```

### manager logging add conn

```
NAME:
   Forgejo manager logging add conn - Add a net conn logger

USAGE:
   Forgejo manager logging add conn command [command options] [arguments...]

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                          show help
   --custom-path value, -C value       Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value            Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value         Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --logger value                      Logger name - will default to "default"
   --writer value                      Name of the log writer - will default to mode
   --level value                       Logging level for the new logger
   --stacktrace-level value, -L value  Stacktrace logging level
   --flags value, -F value             Flags for the logger
   --expression value, -e value        Matching expression for the logger
   --prefix value, -p value            Prefix for the logger
   --color                             Use color in the logs (default: false)
   --debug                             (default: false)
   --reconnect-on-message, -R          Reconnect to host for every message (default: false)
   --reconnect, -r                     Reconnect to host when connection is dropped (default: false)
   --protocol value, -P value          Set protocol to use: tcp, unix, or udp (defaults to tcp)
   --address value, -a value           Host address and port to connect to (defaults to :7020)
```

### manager logging log-sql

```
NAME:
   Forgejo manager logging log-sql - Set LogSQL

USAGE:
   Forgejo manager logging log-sql command [command options] [arguments...]

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --debug                        (default: false)
   --off                          Switch off SQL logging (default: false)
```

### manager processes

```
NAME:
   Forgejo manager processes - Display running processes within the current process

USAGE:
   Forgejo manager processes command [command options] [arguments...]

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --debug                        (default: false)
   --flat                         Show processes as flat table rather than as tree (default: false)
   --no-system                    Do not show system processes (default: false)
   --stacktraces                  Show stacktraces (default: false)
   --json                         Output as json (default: false)
   --cancel value                 Process PID to cancel. (Only available for non-system processes.)
```

## embedded

```
NAME:
   Forgejo embedded - Extract embedded resources

USAGE:
   Forgejo embedded command [command options] [arguments...]

DESCRIPTION:
   A command for extracting embedded resources, like templates and images

COMMANDS:
   list     List files matching the given pattern
   view     View a file matching the given pattern
   extract  Extract resources
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
```

### embedded list

```
NAME:
   Forgejo embedded list - List files matching the given pattern

USAGE:
   Forgejo embedded list command [command options] [arguments...]

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --include-vendored, --vendor   Include files under public/vendor as well (default: false)
```

### embedded view

```
NAME:
   Forgejo embedded view - View a file matching the given pattern

USAGE:
   Forgejo embedded view command [command options] [arguments...]

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --include-vendored, --vendor   Include files under public/vendor as well (default: false)
```

### embedded extract

```
NAME:
   Forgejo embedded extract - Extract resources

USAGE:
   Forgejo embedded extract command [command options] [arguments...]

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                             show help
   --custom-path value, -C value          Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value               Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value            Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --include-vendored, --vendor           Include files under public/vendor as well (default: false)
   --overwrite                            Overwrite files if they already exist (default: false)
   --rename                               Rename files as {name}.bak if they already exist (overwrites previous .bak) (default: false)
   --custom                               Extract to the 'custom' directory as per app.ini (default: false)
   --destination value, --dest-dir value  Extract to the specified directory
```

## migrate-storage

```
NAME:
   Forgejo migrate-storage - Migrate the storage

USAGE:
   Forgejo migrate-storage command [command options] [arguments...]

DESCRIPTION:
   Copies stored files from storage configured in app.ini to parameter-configured storage

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                        show help
   --custom-path value, -C value     Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value          Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value       Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --type value, -t value            Type of stored files to copy.  Allowed types: 'attachments', 'lfs', 'avatars', 'repo-avatars', 'repo-archivers', 'packages', 'actions-log'
   --storage value, -s value         New storage type: local (default) or minio
   --path value, -p value            New storage placement if store is local (leave blank for default)
   --minio-endpoint value            Minio storage endpoint
   --minio-access-key-id value       Minio storage accessKeyID
   --minio-secret-access-key value   Minio storage secretAccessKey
   --minio-bucket value              Minio storage bucket
   --minio-location value            Minio storage location to create bucket
   --minio-base-path value           Minio storage base path on the bucket
   --minio-use-ssl                   Enable SSL for minio (default: false)
   --minio-insecure-skip-verify      Skip SSL verification (default: false)
   --minio-checksum-algorithm value  Minio checksum algorithm (default/md5)
```

## dump-repo

```
NAME:
   Forgejo dump-repo - Dump the repository from git/github/gitea/gitlab

USAGE:
   Forgejo dump-repo command [command options] [arguments...]

DESCRIPTION:
   This is a command for dumping the repository data.

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --git_service value            Git service, git, github, gitea, gitlab. If clone_addr could be recognized, this could be ignored.
   --repo_dir value, -r value     Repository dir path to store the data (default: "./data")
   --clone_addr value             The URL will be clone, currently could be a git/github/gitea/gitlab http/https URL
   --auth_username value          The username to visit the clone_addr
   --auth_password value          The password to visit the clone_addr
   --auth_token value             The personal token to visit the clone_addr
   --owner_name value             The data will be stored on a directory with owner name if not empty
   --repo_name value              The data will be stored on a directory with repository name if not empty
   --units value                  Which items will be migrated, one or more units should be separated as comma.
      wiki, issues, labels, releases, release_assets, milestones, pull_requests, comments are allowed. Empty means all units.
```

## restore-repo

```
NAME:
   Forgejo restore-repo - Restore the repository from disk

USAGE:
   Forgejo restore-repo command [command options] [arguments...]

DESCRIPTION:
   This is a command for restoring the repository data.

COMMANDS:
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h                     show help
   --custom-path value, -C value  Set custom path (defaults to '{WorkPath}/custom')
   --config value, -c value       Set custom config file (defaults to '{WorkPath}/custom/conf/app.ini')
   --work-path value, -w value    Set Forgejo's working path (defaults to the directory of the Forgejo binary)
   --repo_dir value, -r value     Repository dir path to restore from (default: "./data")
   --owner_name value             Restore destination owner name
   --repo_name value              Restore destination repository name
   --units value                  Which items will be restored, one or more units should be separated as comma.
      wiki, issues, labels, releases, release_assets, milestones, pull_requests, comments are allowed. Empty means all units.
   --validation  Sanity check the content of the files before trying to load them (default: false)
```

## cert

```
NAME:
   Forgejo cert - Generate self-signed certificate

USAGE:
   Forgejo cert [command options] [arguments...]

DESCRIPTION:
   Generate a self-signed X.509 certificate for a TLS server.
   Outputs to 'cert.pem' and 'key.pem' and will overwrite existing files.

OPTIONS:
   --host value         Comma-separated hostnames and IPs to generate a certificate for
   --ecdsa-curve value  ECDSA curve to use to generate a key. Valid values are P224, P256, P384, P521
   --rsa-bits value     Size of RSA key to generate. Ignored if --ecdsa-curve is set (default: 3072)
   --start-date value   Creation date formatted as Jan 1 15:04:05 2011
   --duration value     Duration that certificate is valid for (default: 8760h0m0s)
   --ca                 whether this cert should be its own Certificate Authority (default: false)
   --help, -h           show help
```

## generate secret

```
NAME:
   Forgejo generate secret - Generate a secret token

USAGE:
   Forgejo generate secret command [command options] [arguments...]

COMMANDS:
   INTERNAL_TOKEN              Generate a new INTERNAL_TOKEN
   JWT_SECRET, LFS_JWT_SECRET  Generate a new JWT_SECRET
   SECRET_KEY                  Generate a new SECRET_KEY
   help, h                     Shows a list of commands or help for one command

OPTIONS:
   --help, -h  show help
```
