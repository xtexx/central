---
title: 'Reverse proxy'
license: 'Apache-2.0'
origin_url: 'https://github.com/go-gitea/gitea/blob/abe8fe352711601fbcd24bf4505f7e0b81a93c5d/docs/content/usage/authentication.en-us.md'
---

Forgejo supports Reverse Proxy Header authentication, it will read headers as a trusted login user name or user email address. This hasn't been enabled by default, you can enable it with

```ini
[service]
ENABLE_REVERSE_PROXY_AUTHENTICATION = true
```

The default login user name is in the `X-WEBAUTH-USER` header, you can change it via changing `REVERSE_PROXY_AUTHENTICATION_USER` in app.ini. If the user doesn't exist, you can enable automatic registration with `ENABLE_REVERSE_PROXY_AUTO_REGISTRATION=true`.

The default login user email is `X-WEBAUTH-EMAIL`, you can change it via changing `REVERSE_PROXY_AUTHENTICATION_EMAIL` in app.ini, this could also be disabled with `ENABLE_REVERSE_PROXY_EMAIL`

If set `ENABLE_REVERSE_PROXY_FULL_NAME=true`, a user full name expected in `X-WEBAUTH-FULLNAME` will be assigned to the user when auto creating the user. You can also change the header name with `REVERSE_PROXY_AUTHENTICATION_FULL_NAME`.

You can also limit the reverse proxy's IP address range with `REVERSE_PROXY_TRUSTED_PROXIES` which default value is `127.0.0.0/8,::1/128`. By `REVERSE_PROXY_LIMIT`, you can limit trusted proxies level.

Notice: Reverse Proxy Auth doesn't support the API. You still need an access token or basic auth to make API requests.
