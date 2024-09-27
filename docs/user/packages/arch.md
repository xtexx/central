---
title: 'Arch Package Registry'
license: 'Apache-2.0'
---

Forgejo has a Arch Linux package registry, which can act as a fully working [Arch linux mirror](https://wiki.archlinux.org/title/mirrors) and connected directly in `/etc/pacman.conf`. Forgejo automatically creates pacman database for packages in user/organization space when a new Arch package is uploaded.

## Upload packages

When uploading the package to Forgejo, you have to prepare package file with the `.pkg.tar.zst` extension. You can use [curl](https://curl.se/) or any other HTTP client, Forgejo supports multiple [authentication schemes](https://docs.Forgejo.com/usage/authentication). The upload command will create 3 files: package, signature and desc file for the pacman database (which will be created automatically on request).

The following command will upload arch package and related signature to Forgejo with basic authentification:

```sh
curl -X PUT \
  https://{domain}/api/packages/{owner}/arch/{group} \
  --user your_username:your_token_or_password \
  --header "Content-Type: application/octet-stream" \
  --data-binary '@/path/to/package/file/package-1-1-x86_64.pkg.tar.zst'
```

| Placeholder | Description                                                                                 |
| ----------- | ------------------------------------------------------------------------------------------- |
| `owner`     | The owner of the package                                                                    |
| `group`     | [Repository](https://wiki.archlinux.org/title/Official_repositories), e.g. `os`, `extras` . |

## Install packages

First, you need to update your pacman configuration, adding following lines :

```conf
[{owner}.{group}.{domain}]
SigLevel = Required
Server = https://{domain}/api/packages/{owner}/arch/{group}/{architecture}
```

You can also copy content from the Forgejo package page.

| Placeholder    | Description                                                                               |
| -------------- | ----------------------------------------------------------------------------------------- |
| `owner`        | The owner of the package                                                                  |
| `group`        | [Repository](https://wiki.archlinux.org/title/Official_repositories), e.g. `os`, `extras` |
| `architecture` | System architecture, such as `x86_64`, `aarch64`                                          |

Then, Import the server's public key.

```bash
# Download the public key from the remote server.
wget -O sign.gpg https://{domain}/api/packages/{owner}/arch/repository.key

# Import the public key for pacman.
pacman-key --add sign.gpg

# Trust the certificate with the specified email
pacman-key --lsign-key '{owner}@noreply.{domain}'
```

| Placeholder | Description                                      |
| ----------- | ------------------------------------------------ |
| `domain`    | Your Forgejo domain, such as `code.forgejo.org`. |
| `owner`     | The owner of the package                         |

Finally, you can run pacman sync command (with -y flag to load connected database file), to install your package:

```sh
pacman -Sy {package}
```

## Delete packages

The `DELETE` method will remove specific package version, and all package files related to that version:

```sh
curl -X DELETE \
  https://{domain}/api/packages/{owner}/arch/{group}/{package}/{version}/{arch} \
  --user your_username:your_token_or_password
```

| Placeholder | Description                                                                               |
| ----------- | ----------------------------------------------------------------------------------------- |
| `owner`     | The owner of the package                                                                  |
| `group`     | [Repository](https://wiki.archlinux.org/title/Official_repositories), e.g. `os`, `extras` |
| `package`   | Package name                                                                              |
| `version`   | Package version                                                                           |
| `arch`      | Package arch                                                                              |

## Clients

Any `pacman` compatible package manager or AUR-helper can be used to install packages from Forgejo ([yay](https://github.com/Jguer/yay), [paru](https://github.com/Morganamilo/paru), [pikaur](https://github.com/actionless/pikaur), [aura](https://github.com/fosskers/aura)). Also, any HTTP client can be used to execute get/push/remove operations ([curl](https://curl.se/), [postman](https://www.postman.com/), [thunder-client](https://www.thunderclient.com/)).
