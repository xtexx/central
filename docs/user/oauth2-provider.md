---
title: 'OAuth2 provider'
license: 'Apache-2.0'
origin_url: 'https://github.com/go-gitea/gitea/blob/e865de1e9d65dc09797d165a51c8e705d2a86030/docs/content/development/oauth2-provider.en-us.md'
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

To use the Authorization Code Grant as a third party application it is required to register a new application via the "Settings" (`/user/settings/applications`) section of the settings. To test or debug you can use the web-tool https://oauthdebugger.com/.

## Scoped Tokens

See the [Access Token scope](../token-scope/) section for more information.

## Client types

Forgejo supports both confidential and public client types, [as defined by RFC 6749](https://datatracker.ietf.org/doc/html/rfc6749#section-2.1).

For public clients, a redirect URI of a loopback IP address such as `http://127.0.0.1/` allows any port. Avoid using `localhost`, [as recommended by RFC 8252](https://datatracker.ietf.org/doc/html/rfc8252#section-8.3).

## Git authentication

OAuth2 can be used as an alternative to a public SSH key or basic authentication (user/password) to obtain the required
read or write access permissions. It relies on a Git [credential helpers](https://git-scm.com/docs/gitcredentials#_custom_helpers)
such as:

- [Git Credential Manager](https://github.com/git-ecosystem/git-credential-manager)
- [git-credential-oauth](https://github.com/hickford/git-credential-oauth)

They are both [pre-configured server
side](../../admin/oauth2-provider/) but need to be installed and
configured client side.
The following example uses [git-credential-oauth](https://github.com/hickford/git-credential-oauth) on a Debian GNU/Linux machine
to authenticate on https://code.forgejo.org:

- [download the binary tarball](https://github.com/hickford/git-credential-oauth/releases/download/v0.11.0/git-credential-oauth_0.11.0_linux_amd64.tar.gz)
- extract the binary in `/usr/local/bin/git-credential-oauth`
- verify it is found with `git credential-oauth`
- add the following to `~/gitconfig` (note that `a4792ccc-144e-407e-86c9-5e7d8d9c3269` is a hardcoded value that is identical for all Forgejo instances)
  ```ini
  [credential]
    helper = cache --timeout 7200
    helper = oauth
  [credential "https://code.forgejo.org"]
    oauthClientId = a4792ccc-144e-407e-86c9-5e7d8d9c3269
    oauthAuthURL = /login/oauth/authorize
    oauthTokenURL = /login/oauth/access_token
  ```
- `git clone https://code.forgejo.org/earl-warren/test`
- `git push` will open new page on the default browser, looking like this:
  ![git-credential-oauth OAuth2 grant page](../_images/user/oauth2-provider/oauth-git-credential-client.png)
- subsequent `git push` will reuse the token obtained from OAuth2 as long as it remains in the [git credential-cache](https://git-scm.com/docs/git-credential-cache) (i.e. 2h / 7200s)

> **NOTE:** Scopes are not implemented for OAuth2 tokens and they can be used to execute any actions on behalf the user, not just git related actions. Scoped applications tokens or SSH keys limited to interactions with the repository should be preferred in environments where security is a concern.

It is possible for any user to manually register a new OAuth2 application in the `/user/settings/applications` page for the purpose of using a Git [credential helpers](https://git-scm.com/docs/gitcredentials#_custom_helpers) different from the pre-registered ones. In that case the `~/gitconfig` setting (`oauthClientId` etc.) needs to be adapted accordingly

## Examples

### Confidential client

**Note:** This example does not use PKCE.

1. Redirect the user to the authorization endpoint in order to get their consent for accessing the resources:

   ```curl
   https://[YOUR-FORGEJO-URL]/login/oauth/authorize?client_id=CLIENT_ID&redirect_uri=REDIRECT_URI&response_type=code&state=STATE
   ```

   The `CLIENT_ID` can be obtained by registering an application in the settings. The `STATE` is a random string that will be sent back to your application after the user authorizes. The `state` parameter is optional but should be used to prevent CSRF attacks.

   The user will now be asked to authorize your application. If they authorize it, the user will be redirected to the `REDIRECT_URL`, for example:

   ```curl
   https://[REDIRECT_URI]?code=RETURNED_CODE&state=STATE
   ```

2. Using the provided `code` from the redirect, you can request a new application and refresh token. The access token endpoint accepts POST requests with `application/json` and `application/x-www-form-urlencoded` body, for example:

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

   The `CLIENT_SECRET` is the unique secret code generated for this application. Please note that the secret will only be visible after you created/registered the application with Forgejo and cannot be recovered. If you lose the secret, you must regenerate the secret via the application's settings.

   The `REDIRECT_URI` in the `access_token` request must match the `REDIRECT_URI` in the `authorize` request.

3. Use the `access_token` to make API requests to access the user's resources.

### Public client (PKCE)

PKCE (Proof Key for Code Exchange) is an extension to the OAuth flow which allows for a secure credential exchange without the requirement to provide a client secret.

**Note**: Please ensure you have registered your OAuth application as a public client.

To achieve this, you have to provide a `code_verifier` for every authorization request. A `code_verifier` has to be a random string with a minimum length of 43 characters and a maximum length of 128 characters. It can contain alphanumeric characters as well as the characters `-`, `.`, `_` and `~`.

Using this `code_verifier` string, a new one called `code_challenge` is created by using one of two methods:

- If you have the required functionality on your client, set `code_challenge` to be a URL-safe base64-encoded string of the SHA256 hash of `code_verifier`. In that case, your `code_challenge_method` becomes `S256`.
- If you are unable to do so, you can provide your `code_verifier` as a plain string to `code_challenge`. Then you have to set your `code_challenge_method` as `plain`.

After you have generated this values, you can continue with your request.

1. Redirect the user to the authorization endpoint in order to get their consent for accessing the resources:

   ```curl
   https://[YOUR-FORGEJO-URL]/login/oauth/authorize?client_id=CLIENT_ID&redirect_uri=REDIRECT_URI&response_type=code&code_challenge_method=CODE_CHALLENGE_METHOD&code_challenge=CODE_CHALLENGE&state=STATE
   ```

   The `CLIENT_ID` can be obtained by registering an application in the settings. The `STATE` is a random string that will be sent back to your application after the user authorizes. The `state` parameter is optional, but should be used to prevent CSRF attacks.

   ![Authorization Page](/authorize.png)

   The user will now be asked to authorize your application. If they authorize it, the user will be redirected to the `REDIRECT_URL`, for example:

   ```curl
   https://[REDIRECT_URI]?code=RETURNED_CODE&state=STATE
   ```

2. Using the provided `code` from the redirect, you can request a new application and refresh token. The access token endpoint accepts POST requests with `application/json` and `application/x-www-form-urlencoded` body, for example:

   ```curl
   POST https://[YOUR-FORGEJO-URL]/login/oauth/access_token
   ```

   ```json
   {
     "client_id": "YOUR_CLIENT_ID",
     "code": "RETURNED_CODE",
     "grant_type": "authorization_code",
     "redirect_uri": "REDIRECT_URI",
     "code_verifier": "CODE_VERIFIER"
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
