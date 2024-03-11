---
title: Base localization
license: 'CC-BY-SA-4.0'
---

Forgejo base localization is English. This means that all translations are derived from it.

## Managing strings

English localization strings are stored in the file `options/locale/locale_en-US.ini`. Strings are [translated](../localization) on Weblate and string management is partially done by it.

When a new string needs to be added to Forgejo, it must be added to the base language to be picked up by Weblate. Optionally, if the author knows other languages, string translations for other languages can be added so they don't need to be translated for those languages after the PR is merged. This is not necessary and translation can be delegated to the translators at Weblate.

When a string key needs to be changed, it must be mass-changed for all languages into which the string has already been translated, so that existing translations aren't lost.

When a string needs to be deleted, it should only be deleted for the base language. Weblate will delete strings for other languages after the PR is merged.

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
