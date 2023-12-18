---
title: 'Installation'
license: 'CC-BY-SA-4.0'
---

This guide covers the installation of Forgejo [with
Docker](../installation-docker/) or [from
binary](../installation-binary/). Both of these methods are created
and extensively tested to work on every release. They consist of three
steps:

- Download and run the release
- Connect to the web interface and complete the configuration
- And finally register the first user which will be granted administrative permissions

Forgejo is also available for installation using package managers on many platforms. At this
time, Forgejo has been successfully adapted for use on various platforms, including Alpine Linux, Arch
Linux, Debian, Fedora, Gentoo, Manjaro, and the Nix ecosystem. These
platform-specific packages are under the care of distribution packagers, and specific packages are
currently undergoing testing. For a curated inventory, please refer to
[the "Delightful Forgejo" list](https://codeberg.org/forgejo-contrib/delightful-forgejo#packaging).

# Migration from Gitea

## Arch Linux

Arch Linux provides package for both Gitea and Forgejo,
but they install to different locations and run as different users.
Therefore, a small amount of work is needed to transition from one to the other.

First step is to install the Forgejo package, and stop the Gitea service.

    $ pacman -S forgejo
    $ systemctl stop gitea

### Configuration migration

Now, we can copy the Gitea configuration over the default Forgejo one.
We need to set the group owner and group write permission so Forgejo can write to it.

    $ cp /etc/gitea/app.ini /etc/forgejo/app.ini
    $ chown root:forgejo /etc/forgejo/app.ini
    $ chmod g+w /etc/forgejo/app.ini

### Data migration

If we want to leave a copy of the Gitea data untouched (recommend in case of mistakes)
the next step is to copy the existing data to the Forgejo user's home directory.
We need to change the ownership of the files to the `forgejo` user and group too.

    $ cp -r /var/lib/gitea/* /var/lib/forgejo
    $ chown -R forgejo: /var/lib/forgejo/*

Finally, we need to update the configuration, which currently points to `/var/lib/gitea`,
to point to the new location.
Edit `/etc/forgejo/app.ini` and replace all instances of `/var/lib/gitea` with `/var/lib/forgejo`.

### Data migration (no copy)

If you're not concerned about being able to roll back to your Gitea installation,
you can simply change the owner of the files in `/var/lib/gitea`.
There's then no need to change the configuration.

    $ chown -R forgejo: /var/lib/gitea/*

### Starting Forgejo

Whichever data migration you've chosen, it's now time to start the Forgejo service.

    $ sytemctl start forgejo

Check to see that the service has started with no issues.

    $ sytemctl status forgejo

...and set the service to start automatically.

    $ sytemctl enable forgejo

Finally, if you're happy with everything, you can uninstall Gitea.

    $ pacman -R gitea
