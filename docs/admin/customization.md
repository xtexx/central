---
title: 'Interface customization'
license: 'CC-BY-SA-4.0'
---

Forgejo currently has limited capabilities for customizing the user interface.

## Configurations and UI settings

Some settings are provided to customize the look and feel of the Forgejo user interface.

This includes the default theme, the name of your Forgejo instance, as well as the description that appears in Forgejo's homepage. A complete list of those settings can be found in the config cheat sheet:

- In the [UI section](../config-cheat-sheet/#ui-ui) and below.
- The `APP_NAME` setting in the [Overall section](../config-cheat-sheet/#overall-default)

They are documented and supported to be backward compatible between versions.

## Serving custom resources, logos and pages

### A word of warning (Here be dragons!)

Setting a custom logo for your instance, serving custom public files or modifying pages shown by Forgejo (such as the homepage) is possible. However, they impose an additional maintenance burden on administrators and, most importantly, **are unsupported**.

**Unsupported** means that future updates **are likely to break** your changes **without any warning**.

#### Templates

The most dangerous types of modifications are the ones concerning **template files** (`.tmpl`) served by Forgejo, as Forgejo issues backward incompatible updates to its templates very regularly.

Before deploying your changes to production or upgrading a modified Forgejo instance, we urge that you test your custom modifications in a testing environment first.

### Instructions

For the reasons mentioned above, the instructions on performing such tasks can be found in the [developer section on interface customization](../../developer/customization/).

At this stage, it is also worth mentioning that it is possible to customize Forgejo by [modifying its source code and compiling the changes](../../developer/from-source), or by extracting and modifying the files of your choice using the command `forgejo embedded extract`. However, these methods are, for the same reasons as mentioned above, also **unsupported**.
