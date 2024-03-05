---
title: Localization
license: 'CC-BY-SA-4.0'
---

Forgejo is translated via Weblate - libre web-based translation platform.

## Translating via Weblate

The Weblate project of Forgejo localization is publicly available at [Codeberg Translate](https://translate.codeberg.org/projects/forgejo/forgejo/) Weblate instance.

### Translation guidelines

1. Please only suggest changes that will benefit all potential users of the translation. Do not suggest changes that will only make the translation better in cases specific to you or your Forgejo instance. Instead you can customize your instance separately from Forgejo upstream.
2. Try to keep the translation beginner-friendly.
3. Remember that you're not obligated to do the translation. If you're unsure about translation, feel free to leave it for somebody else to translate later.

### Discovering the translation

Go to the [Project](https://translate.codeberg.org/projects/forgejo/forgejo/) page. You'll see the list of languages that are currently available for translation. Click on your language.

From the language page you can browse all translation strings, as well as untranslated, unfinished and failing ones.

### Suggesting changes

You can suggest changes and additions to the existing translation anonymously: find the string for which you want to suggest a change, type your change in, and click "Suggest". Your change will be checked before being accepted. Most contributors are volunteers, this can take a while.

### Making direct changes, accepting suggestions

Making direct changes requires a [Codeberg](https://codeberg.org/) account. Use it to log into [Codeberg Translate](https://translate.codeberg.org/).

If the string is not translated or approved, you can edit it and use the "Save" button to save the change. You can also apply existing suggestions by clicking the checkmark icon, or reject, optionally specifying the rejection reason.

If the string is translated and approved, it can only be changed by a Forgejo Localization team member, but everyone else is still able suggest changes.

To protect the existing translations from vandalism, all strings imported from Gitea were automatically marked as approved.

### Adding a new language

If your language is not available in the language list, you must add first it before translating.

To add a new language, go to the [page for starting new translation](https://translate.codeberg.org/new-lang/forgejo/forgejo/), select your language and click "Start new translation".

### E-mail privacy

By default, Weblate will use your primary e-mail address for your contributions. If you want to adjust this behavior, go to [Weblate settings - Account](https://translate.codeberg.org/accounts/profile/#account) and select a different e-mail under "Commit e-mail" section. You can select `@users.noreply.translate.codeberg.org` address to avoid using any real e-mail address.

## Joining the Localization team

If you want to be more involved in maintaining the translation - consider becoming a part of the Localization team.

In order to apply to the team you must open a new issue at [forgejo/governance](https://codeberg.org/forgejo/governance) repository. See [previous applications](https://codeberg.org/forgejo/governance/issues?q=application+to+the+localization+team&state=closed) for inspiration.

In your application message, please include:

- your motivation for becoming a member
- your experience at translating other projects and using Weblate. e.g. link(s) to your public translation profile(s) or contributions

Application process takes 2 weeks or more. However, it doesn't prevent you from working on the translation: you can add suggestions which you will be able accept later being a team member, translate new strings, add comments and discuss the translation.

It is a good idea to work on the translation first for a bit, before applying to the Localization team, to see how the workflow looks like.

Please apply to the team only if you want your actions as a team member to be beneficial to all translation users.

## Discussing the translation

Ask questions, clarify string meaning, report vandalism and suggest changes to source strings in [Matrix room](https://matrix.to/#/#forgejo-localization:matrix.org) or [issues](https://codeberg.org/forgejo/forgejo/issues). For this you don't need to be a member of the Localization team.

## Troubleshooting

If you have problems using Weblate, there are multiple support channels available:

- [Weblate documentation](https://docs.weblate.org)
- [Weblate issues](https://github.com/WeblateOrg/weblate/issues)
- [Codeberg Translate chat room](https://matrix.to/#/#codeberg-translate:bubu1.eu)
- [Codeberg community issues](https://codeberg.org/Codeberg/Community/issues)
