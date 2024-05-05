---
title: 'Package Registry'
license: 'Apache-2.0'
origin_url: 'https://github.com/go-gitea/gitea/blob/e865de1e9d65dc09797d165a51c8e705d2a86030/docs/content/usage/packages/storage.en-us.md'
---

## Supported package managers

The following package managers are currently supported:

| Name                      | Language   | Package client             |
| ------------------------- | ---------- | -------------------------- |
| [Alpine](./alpine/)       | -          | `apk`                      |
| [Cargo](./cargo/)         | Rust       | `cargo`                    |
| [Chef](./chef/)           | -          | `knife`                    |
| [Composer](./composer/)   | PHP        | `composer`                 |
| [Conan](./conan/)         | C++        | `conan`                    |
| [Conda](./conda/)         | -          | `conda`                    |
| [Container](./container/) | -          | any OCI compliant client   |
| [CRAN](./cran/)           | R          |                            |
| [Debian](./debian/)       | -          | `apt`                      |
| [Generic](./generic/)     | -          | any HTTP client            |
| [Go](./go/)               | Go         | `go`                       |
| [Helm](./helm/)           | -          | any HTTP client, `cm-push` |
| [Maven](./maven/)         | Java       | `mvn`, `gradle`            |
| [npm](./npm/)             | JavaScript | `npm`, `yarn`, `pnpm`      |
| [NuGet](./nuget/)         | .NET       | `nuget`                    |
| [Pub](./pub/)             | Dart       | `dart`, `flutter`          |
| [PyPI](./pypi/)           | Python     | `pip`, `twine`             |
| [RPM](./rpm/)             | -          | `yum`, `dnf`               |
| [RubyGems](./rubygems/)   | Ruby       | `gem`, `Bundler`           |
| [Swift](./swift/)         | Swift      | `swift`                    |
| [Vagrant](./vagrant/)     | -          | `vagrant`                  |

**The following paragraphs only apply if Packages are not globally disabled!**

## Repository-Packages

A package always belongs to an owner (a user or organisation), not a repository.
To link an (already uploaded) package to a repository, open the settings page
on that package and choose a repository to link this package to.
The entire package will be linked, not just a single version.

Linking a package results in showing that package in the repository's package list,
and shows a link to the repository on the package site (as well as a link to the repository issues).

## Access Restrictions

| Package owner type | User                                                        | Organization                                             |
| ------------------ | ----------------------------------------------------------- | -------------------------------------------------------- |
| **read** access    | public, if user is public too; otherwise for this user only | public, if org is public, otherwise for org members only |
| **write** access   | owner only                                                  | org members with admin or write access to the org        |

N.B.: These access restrictions are subject to change, where more finegrained control will be added via a dedicated organization team permission.

## Create or upload a package

Depending on the type of package, use the respective package-manager for that. Check out the sub-page of a specific package manager for instructions.

## View packages

You can view the packages of a repository on the repository page.

1. Go to the repository.
1. Go to **Packages** in the navigation bar.

To view more details about a package, select the name of the package.

## Download a package

To download a package from your repository:

1. Go to **Packages** in the navigation bar.
1. Select the name of the package to view the details.
1. In the **Assets** section, select the name of the package file you want to download.

## Delete a package

You cannot edit a package after you have published it in the Package Registry. Instead, you
must delete and recreate it.

To delete a package from your repository:

1. Go to **Packages** in the navigation bar.
1. Select the name of the package to view the details.
1. Click **Delete package** to permanently delete the package.

## Disable the Package Registry

The Package Registry is automatically enabled. To disable it for a single repository:

1. Go to **Settings** in the navigation bar.
1. Disable **Enable Repository Packages Registry**.

Previously published packages are not deleted by disabling the Package Registry.

## Deduplication

The package registry has a built-in deduplication of uploaded blobs.
If two identical files are uploaded only one blob is saved on the filesystem.
This ensures no space is wasted for duplicated files.

If two packages are uploaded with identical files, both packages will display the same size but on the filesystem they require only half of the size.
Whenever a package gets deleted only the references to the underlying blobs are removed.
The blobs get not removed at this moment, so they still require space on the filesystem.
When a new package gets uploaded the existing blobs may get referenced again.

These unreferenced blobs get deleted by a [clean up job](../../admin/config-cheat-sheet/#cron---cleanup-expired-packages-croncleanup_packages).
The config setting `OLDER_THAN` configures how long unreferenced blobs are kept before they get deleted.

## Cleanup Rules

Package registries can become large over time without cleanup.
It's recommended to delete unnecessary packages and set up cleanup rules to automatically manage the package registry usage.
Every package owner (user or organization) manages the cleanup rules which are applied to their packages.

| Setting                            | Description                                                                                                                                                                                                     |
| ---------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Enabled                            | Turn the cleanup rule on or off.                                                                                                                                                                                |
| Type                               | Every rule manages a specific package type.                                                                                                                                                                     |
| Apply pattern to full package name | If enabled, the patterns below are applied to the full package name (`package/version`). Otherwise only the version (`version`) is used.                                                                        |
| Keep the most recent               | How many versions to _always_ keep for each package.                                                                                                                                                            |
| Keep versions matching             | The regex pattern that determines which versions to keep. An empty pattern keeps no version while `.+` keeps all versions. The container registry will always keep the `latest` version even if not configured. |
| Remove versions older than         | Remove only versions older than the selected days.                                                                                                                                                              |
| Remove versions matching           | The regex pattern that determines which versions to remove. An empty pattern or `.+` leads to the removal of every package if no other setting tells otherwise.                                                 |

Every cleanup rule can show a preview of the affected packages.
This can be used to check if the cleanup rules is proper configured.

### Regex examples

Regex patterns are automatically surrounded with `\A` and `\z` anchors.
Do not include any `\A`, `\z`, `^` or `$` token in the regex patterns as they are not necessary.
The patterns are case-insensitive which matches the behaviour of the package registry in Forgejo.

| Pattern                      | Description                                                                                                                                                                       |
| ---------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `.*`                         | Match every possible version.                                                                                                                                                     |
| `v.+`                        | Match versions that start with `v`.                                                                                                                                               |
| `release`                    | Match only the version `release`.                                                                                                                                                 |
| `release.*`                  | Match versions that are either named or start with `release`.                                                                                                                     |
| `.+-temp-.+`                 | Match versions that contain `-temp-`.                                                                                                                                             |
| `v.+\|release`               | Match versions that either start with `v` or are named `release`.                                                                                                                 |
| `package/v.+\|other/release` | Match versions of the package `package` that start with `v` or the version `release` of the package `other`. This needs the setting _Apply pattern to full package name_ enabled. |

### How the cleanup rules work

The cleanup rules are part of the [clean up job](../../admin/config-cheat-sheet/#cron---cleanup-expired-packages-croncleanup_packages) and run periodically.

The cleanup rule:

1. Collects all packages of the package type for the owners registry.
1. For every package it collects all versions.
1. Excludes from the list the # versions based on the _Keep the most recent_ value.
1. Excludes from the list any versions matching the _Keep versions matching_ value.
1. Excludes from the list the versions more recent than the _Remove versions older than_ value.
1. Excludes from the list any versions not matching the _Remove versions matching_ value.
1. Deletes the remaining versions.
