---
title: Base localization
license: 'CC-BY-SA-4.0'
---

Forgejo base localization is English. This means that all translations are derived from it.

## Managing strings

English localization strings are stored in the file `options/locale/locale_en-US.ini`. Strings are [translated](../localization) on Weblate and string management is partially done by it.

When a new string needs to be added to Forgejo, it must be added to the base language to be picked up by Weblate.

When a string key needs to be changed, it must be mass-changed for all languages into which the string has already been translated, so that existing translations aren't lost.

When an unused string needs to be deleted, it should be only deleted for the base language to avoid merge conflicts. The string will disappear from all translations automatically after the PR is merged.

## Localization style

All strings should have regular capitalization. Headers, labels, buttons and such should start with a capital letter. Only names, product names and such should be capitalized after that. Forgejo-specific measurement units should not be capitalized.

| Context | ❌ Bad                                 | ✅ Good                                |
| ------- | -------------------------------------- | -------------------------------------- |
| Button  | star                                   | Star                                   |
| Header  | Manage Organizations                   | Manage organizations                   |
| Option  | Use Custom Avatar                      | Use custom avatar                      |
| Button  | Add Cleanup Rule                       | Add cleanup rule                       |
| Label   | Integrate matrix into your repository. | Integrate Matrix into your repository. |
| Label   | %s Commits                             | %s commits                             |

## Contributing

This section is to help you contribute to the English localization of Forgejo.

### Suggesting improvements

You send bugs, suggestions and feedback via Forgejo [issue tracker](https://codeberg.org/forgejo/forgejo/issues) or Forgejo Localization [Matrix chatroom](https://matrix.to/#/#forgejo-localization:matrix.org). Comments on Weblate also might work but are not recommended because they're checked rarely and might not be noticed.

### Proposing changes

Similarly to other projects you can propose changes via a pull request. Read the informative sections for string managing and style guidelines above. You can perform small changes via Forgejo web UI. Otherwise you can make a fork or use AGit workflow, clone, checkout a new branch, make your changes, commit, push and open a pull request. Put some useful explanation of the change in the PR description. Screenshots are also highly welcome.

If it's a small change to the string, you don't need to test it locally. However, if you want to make larger text refactor, consider verifying that everything looks good together in live by building and running Forgejo locally. See [For contributors](https://forgejo.org/docs/latest/developer) for more information how to do this.

If your refactor affects key names, make sure to perform a mass-rename of the affected keys in all code, templates and translations. Sometimes keys are generated in code with conditions. Please check for that as well. With such refactor you might be asked to resolve merge conflicts before your PR can be merged. If you have low availability, it is best to avoid renaming transltation keys.
