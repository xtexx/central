---
title: 'Email setup'
license: 'Apache-2.0'
origin_url: 'https://github.com/go-gitea/gitea/blob/e865de1e9d65dc09797d165a51c8e705d2a86030/docs/content/administration/email-setup.en-us.md'
---

Forgejo can be set to send emails such as a registration confirmation, either with [Sendmail](https://man7.org/linux/man-pages/man8/sendmail.8.html) (or compatible MTAs like Postfix and msmtp) or by connecting to an SMTP server.

## Using SMTP

Directly use SMTP server as relay. This option is useful if you don't want to set up MTA on your instance but you have an account at an email provider.

```ini
[mailer]
ENABLED        = true
FROM           = forgejo@example.com
PROTOCOL       = smtps
SMTP_ADDR      = mail.example.com
SMTP_PORT      = 587
USER           = forgejo@example.com
PASSWD         = mysecurepassword
```

Restart Forgejo for the configuration changes to take effect.

To send a test email to validate the settings, go to Forgejo > Site Administration > Configuration > SMTP Mailer Configuration.

For the full list of options check the [Config Cheat Sheet](../config-cheat-sheet/#mailer-mailer).

> **NOTE:** authentication is only supported when the SMTP server communication is encrypted with TLS or `HOST=localhost`. This is due to protections imposed by the Go internal libraries against STRIPTLS attacks. TLS encryption can be through:

- STARTTLS (also known as Opportunistic TLS) via port 587. Initial connection is done over cleartext, but then be upgraded over TLS if the server supports it.
- SMTPS connection (SMTP over TLS) via the default port 465. Connection to the server use TLS from the beginning.
- Forced SMTPS connection with `PROTOCOL=smtps`. (These are both known as Implicit TLS.)

Both `SMTPS` and `STARTTLS` combined with `IS_TLS_ENABLED=true` are known as Implicit TLS and is recommended by [RFC8314](https://tools.ietf.org/html/rfc8314#section-3) since 2018.

## Using Sendmail

Use `sendmail` command as mailer.

> **NOTE:** For Internet-facing sites consult the documentation of your MTA for instructions to send emails over TLS. Also set up SPF, DMARC, and DKIM DNS records to make emails sent be accepted as legitimate by various email providers.

```ini
[mailer]
ENABLED       = true
FROM          = forgejo@example.com
PROTOCOL      = sendmail
SENDMAIL_PATH = /usr/sbin/sendmail
SENDMAIL_ARGS = "--" ; most "sendmail" programs take options, "--" will prevent an email address being interpreted as an option.
```
