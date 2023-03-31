---
layout: '~/layouts/Markdown.astro'
title: 'OAuth2 provider'
license: 'Apache-2.0'
origin_url: 'https://github.com/go-gitea/gitea/blob/699f20234b9f7cdbbeeee3be004470c598fa1147/docs/content/doc/developers/oauth2-provider.en-us.md'
---

Forgejo supports acting as an OAuth2 provider to allow third party applications to access its resources with the user's consent.

## Endpoints

| Endpoint                 | URL                                 |
| ------------------------ | ----------------------------------- |
| OpenID Connect Discovery | `/.well-known/openid-configuration` |
| Authorization Endpoint   | `/login/oauth/authorize`            |
| Access Token Endpoint    | `/login/oauth/access_token`         |
| OpenID Connect UserInfo  | `/login/oauth/userinfo`             |
| JSON Web Key Set         | `/login/oauth/keys`                 |

## Supported OAuth2 Grants

At the moment Forgejo only supports the [**Authorization Code Grant**](https://tools.ietf.org/html/rfc6749#section-1.3.1) standard with additional support of the following extensions:

- [Proof Key for Code Exchange (PKCE)](https://tools.ietf.org/html/rfc7636)
- [OpenID Connect (OIDC)](https://openid.net/specs/openid-connect-core-1_0.html#CodeFlowAuth)

To use the Authorization Code Grant as a third party application it is required to register a new application via the "Settings" (`/user/settings/applications`) section of the settings.

## Scoped Tokens

Forgejo supports the following scopes for tokens:

| Name                                     | Description                                                                                  |
| ---------------------------------------- | -------------------------------------------------------------------------------------------- |
| **(no scope)**                           | Grants read-only access to public user profile and public repositories.                      |
| **repo**                                 | Full control over all repositories.                                                          |
| &nbsp;&nbsp;&nbsp; **repo:status**       | Grants read/write access to commit status in all repositories.                               |
| &nbsp;&nbsp;&nbsp; **public_repo**       | Grants read/write access to public repositories only.                                        |
| **admin:repo_hook**                      | Grants access to repository hooks of all repositories. This is included in the `repo` scope. |
| &nbsp;&nbsp;&nbsp; **write:repo_hook**   | Grants read/write access to repository hooks                                                 |
| &nbsp;&nbsp;&nbsp; **read:repo_hook**    | Grants read-only access to repository hooks                                                  |
| **admin:org**                            | Grants full access to organization settings                                                  |
| &nbsp;&nbsp;&nbsp; **write:org**         | Grants read/write access to organization settings                                            |
| &nbsp;&nbsp;&nbsp; **read:org**          | Grants read-only access to organization settings                                             |
| **admin:public_key**                     | Grants full access for managing public keys                                                  |
| &nbsp;&nbsp;&nbsp; **write:public_key**  | Grant read/write access to public keys                                                       |
| &nbsp;&nbsp;&nbsp; **read:public_key**   | Grant read-only access to public keys                                                        |
| **admin:org_hook**                       | Grants full access to organizational-level hooks                                             |
| **notification**                         | Grants full access to notifications                                                          |
| **user**                                 | Grants full access to user profile info                                                      |
| &nbsp;&nbsp;&nbsp; **read:user**         | Grants read access to user's profile                                                         |
| &nbsp;&nbsp;&nbsp; **user:email**        | Grants read access to user's email addresses                                                 |
| &nbsp;&nbsp;&nbsp; **user:follow**       | Grants access to follow/un-follow a user                                                     |
| **delete_repo**                          | Grants access to delete repositories as an admin                                             |
| **package**                              | Grants full access to hosted packages                                                        |
| &nbsp;&nbsp;&nbsp; **write:package**     | Grants read/write access to packages                                                         |
| &nbsp;&nbsp;&nbsp; **read:package**      | Grants read access to packages                                                               |
| &nbsp;&nbsp;&nbsp; **delete:package**    | Grants delete access to packages                                                             |
| **admin:gpg_key**                        | Grants full access for managing GPG keys                                                     |
| &nbsp;&nbsp;&nbsp; **write:gpg_key**     | Grants read/write access to GPG keys                                                         |
| &nbsp;&nbsp;&nbsp; **read:gpg_key**      | Grants read-only access to GPG keys                                                          |
| **admin:application**                    | Grants full access to manage applications                                                    |
| &nbsp;&nbsp;&nbsp; **write:application** | Grants read/write access for managing applications                                           |
| &nbsp;&nbsp;&nbsp; **read:application**  | Grants read access for managing applications                                                 |
| **sudo**                                 | Allows to perform actions as the site admin.                                                 |

## Client types

Forgejo supports both confidential and public client types, [as defined by RFC 6749](https://datatracker.ietf.org/doc/html/rfc6749#section-2.1).

For public clients, a redirect URI of a loopback IP address such as `http://127.0.0.1/` allows any port. Avoid using `localhost`, [as recommended by RFC 8252](https://datatracker.ietf.org/doc/html/rfc8252#section-8.3).

## Example

**Note:** This example does not use PKCE.

1. Redirect to user to the authorization endpoint in order to get their consent for accessing the resources:

   ```curl
   https://[YOUR-FORGEJO-URL]/login/oauth/authorize?client_id=CLIENT_ID&redirect_uri=REDIRECT_URI& response_type=code&state=STATE
   ```

   The `CLIENT_ID` can be obtained by registering an application in the settings. The `STATE` is a random string that will be send back to your application after the user authorizes. The `state` parameter is optional but should be used to prevent CSRF attacks.

   ![Authorization Page](/authorize.png)

   The user will now be asked to authorize your application. If they authorize it, the user will be redirected to the `REDIRECT_URL`, for example:

   ```curl
   https://[REDIRECT_URI]?code=RETURNED_CODE&state=STATE
   ```

2. Using the provided `code` from the redirect, you can request a new application and refresh token. The access token endpoints accepts POST requests with `application/json` and `application/x-www-form-urlencoded` body, for example:

   ```curl
   POST https://[YOUR-FORGEJO-URL]/login/oauth/access_token
   ```

   ```json
   {
     "client_id": "YOUR_CLIENT_ID",
     "client_secret": "YOUR_CLIENT_SECRET",
     "code": "RETURNED_CODE",
     "grant_type": "authorization_code",
     "redirect_uri": "REDIRECT_URI"
   }
   ```

   Response:

   ```json
   {
     "access_token": "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJnbnQiOjIsInR0IjowLCJleHAiOjE1NTUxNzk5MTIsImlhdCI6MTU1NTE3NjMxMn0.0-iFsAwBtxuckA0sNZ6QpBQmywVPz129u75vOM7wPJecw5wqGyBkmstfJHAjEOqrAf_V5Z-1QYeCh_Cz4RiKug",
     "token_type": "bearer",
     "expires_in": 3600,
     "refresh_token": "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJnbnQiOjIsInR0IjoxLCJjbnQiOjEsImV4cCI6MTU1NzgwNDMxMiwiaWF0IjoxNTU1MTc2MzEyfQ.S_HZQBy4q9r5SEzNGNIoFClT43HPNDbUdHH-GYNYYdkRfft6XptJBkUQscZsGxOW975Yk6RbgtGvq1nkEcklOw"
   }
   ```

   The `CLIENT_SECRET` is the unique secret code generated for this application. Please note that the secret will only be visible after you created/registered the application with Forgejo and cannot be recovered. If you lose the secret you must regenerate the secret via the application's settings.

   The `REDIRECT_URI` in the `access_token` request must match the `REDIRECT_URI` in the `authorize` request.

3. Use the `access_token` to make [API requests](../api-usage) to access the user's resources.
