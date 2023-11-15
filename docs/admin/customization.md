---
title: 'Interface customization'
license: 'CC-BY-SA-4.0'
---

Forgejo currently has limited capabilities for customizing the user interface.

Some settings are provided to customize the look and feel of the Forgejo user interface, such as the default theme or the description that shows on the home page. See a complete list of those settings in the config cheat sheet:

- In the [UI section](../config-cheat-sheet/#ui-ui) and below.
- The `APP_NAME` setting in the [Overall section](../config-cheat-sheet/#overall-default)

They are documented and supported to be backward compatible between versions.

It is also possible to customize Forgejo by recompiling from the sources and changing the files. Or by extracting and modifying the relevant files with the `forgejo embedded extract` CLI. In both cases an intimate knowledge of the underlying codebase is necessary to figure out what files should be modified to achieve the desired result. They are considered an internal detail: non backward compatible changes will be introduced without warning in the release notes and they will not be documented.

See also the [developer section on interface customization](../../developer/customization/) for more information.
