---
title: 'Access Token scope'
license: 'Apache-2.0'
origin_url: 'https://github.com/go-gitea/gitea/blob/e865de1e9d65dc09797d165a51c8e705d2a86030/docs/content/development/oauth2-provider.en-us.md'
---

Forgejo supports scoped access tokens, which allow users to restrict tokens to operate only on selected url routes. Scopes are grouped by high-level API routes, and further refined to the following:

- `read`: `GET` routes
- `write`: `POST`, `PUT`, `PATCH`, and `DELETE` routes (in addition to `GET`)

Forgejo token scopes are as follows:

| Name                                      | Description                                                                                                                                          |
| ----------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| **(no scope)**                            | Not supported. A scope is required even for public repositories.                                                                                     |
| **activitypub**                           | `activitypub` API routes: ActivityPub related operations.                                                                                            |
| &nbsp;&nbsp;&nbsp; **read:activitypub**   | Grants read access for ActivityPub operations.                                                                                                       |
| &nbsp;&nbsp;&nbsp; **write:activitypub**  | Grants read/write/delete access for ActivityPub operations.                                                                                          |
| **admin**                                 | `/admin/*` API routes: Site-wide administrative operations (hidden for non-admin accounts).                                                          |
| &nbsp;&nbsp;&nbsp; **read:admin**         | Grants read access for admin operations, such as getting cron jobs or registered user emails.                                                        |
| &nbsp;&nbsp;&nbsp; **write:admin**        | Grants read/write/delete access for admin operations, such as running cron jobs or updating user accounts.                                           |
| **issue**                                 | `issues/*`, `labels/*`, `milestones/*` API routes: Issue-related operations.                                                                         |
| &nbsp;&nbsp;&nbsp; **read:issue**         | Grants read access for issues operations, such as getting issue comments, issue attachments, and milestones.                                         |
| &nbsp;&nbsp;&nbsp; **write:issue**        | Grants read/write/delete access for issues operations, such as posting or editing an issue comment or attachment, and updating milestones.           |
| **misc**                                  | miscellaneous and settings top-level API routes.                                                                                                     |
| &nbsp;&nbsp;&nbsp; **read:misc**          | Grants read access to miscellaneous operations, such as getting label and gitignore templates.                                                       |
| &nbsp;&nbsp;&nbsp; **write:misc**         | Grants read/write/delete access to miscellaneous operations, such as markup utility operations.                                                      |
| **notification**                          | `notification/*` API routes: user notification operations.                                                                                           |
| &nbsp;&nbsp;&nbsp; **read:notification**  | Grants read access to user notifications, such as which notifications users are subscribed to and read new notifications.                            |
| &nbsp;&nbsp;&nbsp; **write:notification** | Grants read/write/delete access to user notifications, such as marking notifications as read.                                                        |
| **organization**                          | `orgs/*` and `teams/*` API routes: Organization and team management operations.                                                                      |
| &nbsp;&nbsp;&nbsp; **read:organization**  | Grants read access to org and team status, such as listing all orgs a user has visibility to, teams, and team members.                               |
| &nbsp;&nbsp;&nbsp; **write:organization** | Grants read/write/delete access to org and team status, such as creating and updating teams and updating org settings.                               |
| **package**                               | `/packages/*` API routes: Packages operations                                                                                                        |
| &nbsp;&nbsp;&nbsp; **read:package**       | Grants read access to package operations, such as reading and downloading available packages.                                                        |
| &nbsp;&nbsp;&nbsp; **write:package**      | Grants read/write/delete access to package operations. Currently the same as `read:package`.                                                         |
| **repository**                            | `/repos/*` API routes except `/repos/issues/*`: Repository file, pull-request, and release operations.                                               |
| &nbsp;&nbsp;&nbsp; **read:repository**    | Grants read access to repository operations, such as getting repository files, releases, collaborators.                                              |
| &nbsp;&nbsp;&nbsp; **write:repository**   | Grants read/write/delete access to repository operations, such as getting updating repository files, creating pull requests, updating collaborators. |
| **user**                                  | `/user/*` and `/users/*` API routes: User-related operations.                                                                                        |
| &nbsp;&nbsp;&nbsp; **read:user**          | Grants read access to user operations, such as getting user repo subscriptions and user settings.                                                    |
| &nbsp;&nbsp;&nbsp; **write:user**         | Grants read/write/delete access to user operations, such as updating user repo subscriptions, followed users, and user settings.                     |
