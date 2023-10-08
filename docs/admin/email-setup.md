---
title: 'Email setup'
license: 'Apache-2.0'
origin_url: 'https://github.com/go-gitea/gitea/blob/abe8fe352711601fbcd24bf4505f7e0b81a93c5d/docs/content/administration/email-setup.en-us.md'
---

Forgejo has mailer functionality for sending transactional emails (such as registration confirmation). It can be configured to either use Sendmail (or compatible MTAs like Postfix and msmtp) or directly use SMTP server.

## Using SMTP

Directly use SMTP server as relay. This option is useful if you don't want to set up MTA on your instance but you have an account at email provider.

```ini
[mailer]
ENABLED        = true
FROM           = forgejo@example.com
PROTOCOL       = smtps
SMTP_ADDR      = mail.example.com
SMTP_PORT      = 587
USER           = forgejo@example.com
PASSWD         = `password`
```

Restart Forgejo for the configuration changes to take effect.

To send a test email to validate the settings, go to Forgejo > Site Administration > Configuration > SMTP Mailer Configuration.

For the full list of options check the Config Cheat Sheet.

Please note: authentication is only supported when the SMTP server communication is encrypted with TLS or `HOST=localhost`. TLS encryption can be through:

- STARTTLS (also known as Opportunistic TLS) via port 587. Initial connection is done over cleartext, but then be upgraded over TLS if the server supports it.
- SMTPS connection (SMTP over TLS) via the default port 465. Connection to the server use TLS from the beginning.
- Forced SMTPS connection with `IS_TLS_ENABLED=true`. (These are both known as Implicit TLS.)
  This is due to protections imposed by the Go internal libraries against STRIPTLS attacks.

Note that Implicit TLS is recommended by [RFC8314](https://tools.ietf.org/html/rfc8314#section-3) since 2018.

## Using Sendmail

Use `sendmail` command as mailer.

Note: For Internet-facing sites consult documentation of your MTA for instructions to send emails over TLS. Also set up SPF, DMARC, and DKIM DNS records to make emails sent be accepted as legitimate by various email providers.

```ini
[mailer]
ENABLED       = true
FROM          = forgejo@example.com
PROTOCOL      = sendmail
SENDMAIL_PATH = /usr/sbin/sendmail
SENDMAIL_ARGS = "--" ; most "sendmail" programs take options, "--" will prevent an email address being interpreted as an option.
```
