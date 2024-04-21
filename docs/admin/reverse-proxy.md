---
title: 'Reverse proxy'
license: 'Apache-2.0'
origin_url: 'https://github.com/go-gitea/gitea/blob/e865de1e9d65dc09797d165a51c8e705d2a86030/docs/content/usage/authentication.en-us.md'
---

Forgejo supports Reverse Proxy Header authentication, it will read headers as a trusted login user name or user email address. This hasn't been enabled by default, you can enable it with

```ini
[service]
ENABLE_REVERSE_PROXY_AUTHENTICATION = true
```

The default login user name is in the `X-WEBAUTH-USER` header, you can change it via changing `[security].REVERSE_PROXY_AUTHENTICATION_USER` in app.ini. If the user doesn't exist, you can enable automatic registration with `ENABLE_REVERSE_PROXY_AUTO_REGISTRATION=true`.

The default login user email is `X-WEBAUTH-EMAIL`, you can change it via changing `[security].REVERSE_PROXY_AUTHENTICATION_EMAIL` in app.ini, this could also be disabled with `ENABLE_REVERSE_PROXY_EMAIL`

If set `ENABLE_REVERSE_PROXY_FULL_NAME=true`, a user full name expected in `X-WEBAUTH-FULLNAME` will be assigned to the user when auto creating the user. You can also change the header name with `[security].REVERSE_PROXY_AUTHENTICATION_FULL_NAME`.

You can also limit the reverse proxy's IP address range with `[security].REVERSE_PROXY_TRUSTED_PROXIES` which default value is `127.0.0.0/8,::1/128`. By `[security].REVERSE_PROXY_LIMIT`, you can limit trusted proxies level.

Notice: Reverse Proxy Auth doesn't support the API. You still need an access token or basic auth to make API requests.

## Docker / Container Registry

The container registry uses a fixed sub-path `/v2` which can't be changed.
Even if you deploy Gitea with a different sub-path, `/v2` will be used by the `docker` client.
Therefore you may need to add an additional route to your reverse proxy configuration.
