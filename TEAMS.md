# Forgejo teams

A team is a group of people who work together on a specific area to further Forgejo.

Some of the teams are trusted with access to exclusive resources that require credentials. To participate in such a team someone can open a pull request to add their name and their membership will be decided by the Forgejo community (see the [decision making document](DECISION-MAKING.md) for more information).

- [Accessibility](#accessibility)
- [User Interface](#user-interface)
- [Helm](#helm)
- [Devops](#devops)
- [Contributors](#contributors)
- [Mergers](#mergers)
- [Localization](#localization)
- [User Research](#user-research)
- [Releases](#releases)
- [Security](#security)
- [Social account](#social-account)
- [Moderation](#moderation)
- [Liberapay team members](#liberapay-team-members)
- [Sustainability Team](#sustainability-team)
- [GitHub organisation owners](#github-organisation-owners)
- [GitLab.com organisation owners](#gitlab-com-organisation-owners)

## Accessibility

Purpose: Work on improving Forgejo accessibility.

Team members:

* @Ryuno-Ki - [April 2025 Agreement](https://codeberg.org/forgejo/governance/issues/252)
* @fnetX - [April 2025 Agreement](https://codeberg.org/forgejo/governance/issues/251)

## User Interface

Purpose: Improve Forgejo's UI. Responsible for decision-making of frontend technology. Includes reviewing proposed changes to the UI and tending to (critical) UI bugs. Works closely together with the Accessibility, Contributors and Localization teams. The team is also responsible for Forgejo's design in collaboration with the Accessibility and User Research teams.

Team members:

* @Mai-Lapyst - [June 2024 Agreement](https://codeberg.org/forgejo/governance/issues/131)
* @0ko - [June 2024 Agreement](https://codeberg.org/forgejo/governance/issues/132)
* @caesar - [June 2024 Agreement](https://codeberg.org/forgejo/governance/issues/134)

## Helm

Purpose: Improve Forgejo Helm chart. Members have full write access to the Helm chart repo. They are responsible for improving the chart and reviewing / merging community PRs.

The team has access to the following Forgejo repositories:

* On code.forgejo.org: all repositories in the <https://code.forgejo.org/forgejo-helm> organization.

Team members:

* @viceice - [June 2024 Agreement](https://codeberg.org/forgejo/governance/issues/145)
* @earl-warren - [June 2024 Agreement](https://codeberg.org/forgejo/governance/issues/146)

## Devops

Purpose: The team cares of all the technical resources that Forgejo depends on (hardware, CI, static web site hosting, social media etc.). It helps all other teams to use those resources by installing, upgrading or migrating them when needed. If a resource becomes unavailable, it will help restore it in a functional state.

Accountability:

* Answer calls from other team members when help is needed.
* Fix problems that prevent the resources that Forgejo depends on from running.
* Keep the [credentials to access the resources](https://forgejo.org/docs/next/contributor/secrets/) in a safe place and share them with the teams that need them.

Team members:

* @crystal - [January 2025 Agreement](https://codeberg.org/forgejo/governance/issues/213)
* @earl-warren - [July 2024 Agreement](https://codeberg.org/forgejo/governance/issues/140)
* @viceice - [December 2024 Agreement](https://codeberg.org/forgejo/governance/issues/199)

## Contributors

Purpose: Improve Forgejo. Anyone can become a member of the team, as long as they need the associated permissions to contribute to Forgejo. Anyone can ask that an existing member confirms their membership in accordance to the [decision making process](DECISION-MAKING.md).

Members of the [mergers team](#mergers) are responsible for managing the membership of the contributors team. They can add new members even when the contributor did not apply for it formally. If they remove members for any reason, they must do so after listing the contributors to be removed in a governance issue explaining the reasons. When contributors are removed after long periods of inactivity, the issue documenting their removal can be done simultaneously.

The team has access to most Forgejo repositories:

* On codeberg.org: ([discussions](https://codeberg.org/forgejo/discussions), [docs](https://codeberg.org/forgejo/docs), [forgejo](https://codeberg.org/forgejo/forgejo), [governance](https://codeberg.org/forgejo/governance), [sustainability](https://codeberg.org/forgejo/sustainability), [website](https://codeberg.org/forgejo/website), [user-research](https://codeberg.org/forgejo/user-research)).
* On code.forgejo.org: all repositories in the https://code.forgejo.org/forgejo and https://code.forgejo.org/actions organizations.

The permissions of the team are:

| Unit          | Permission |
|---------------|------------|
| Code          | Read       |
| Issues        | Write      |
| Pull requests | Write      |
| Releases      | Read       |
| Wiki          | Write      |
| Projects      | Write      |
| Packages      | Read       |
| Actions       | Write      |

The [list of team members](https://codeberg.org/org/forgejo/teams/contributors) is visible to other contributors.
Non-team members can view the members who have not hidden themselves in the [organization's member list](https://codeberg.org/org/forgejo/members).

## Mergers

Purpose: Review and merge pull requests in Forgejo repositories in accordance to the [pull request agreement](PullRequestsAgreement.md). Manage the membership of the [contributors team](#contributors). The team is responsible for the same repositories as the [contributors team](#contributors).

Team members:

* @0ko - [April 2024 Agreement](https://codeberg.org/forgejo/governance/issues/106)
* @viceice - [August 2024 Agreement](https://codeberg.org/forgejo/governance/issues/156)
* @Kwonunn - [April 2025 Agreement](https://codeberg.org/forgejo/governance/issues/244)
* @fnetx - [June 2025 Agreement](https://codeberg.org/forgejo/governance/issues/269)
* @jerger - [June 2025 Agreement](https://codeberg.org/forgejo/governance/issues/271)
* @Beowulf - [June 2025 Agreement](https://codeberg.org/forgejo/governance/issues/292)
* Members of the [Security](#security), [Devops](#devops) & [Releases](#releases) teams

## Localization

Purpose: Manage the [Weblate localization](https://translate.codeberg.org/projects/forgejo/) project.

Accountability:

* Develop the software and workflows required for the translations to be available and updated in the Forgejo codebase.
* Document the localization process.
* Actively look for new translators to improve the quality and completeness of the project.

Admins accountability:

* Avoid destructive actions (such as resetting the weblate repository)
* Ensure the the weblate repository is in sync with the Forgejo repository
* Manage team assignments of members
* Block users performing destructive actions (such as vandalism or harassment in comments) and report these actions

Team members:

* Brazilian Portuguese: @Xinayder - [March 2025 Agreement](https://codeberg.org/forgejo/governance/issues/243)
* Chinese (Simplified): @xtex - [September 2024 Agreement](https://codeberg.org/forgejo/governance/issues/176)
* Chinese (Traditional): @leana8959 - [May 2024 Agreement](https://codeberg.org/forgejo/governance/issues/117)
* Czech: @Fjuro - [April 2025 Agreement](https://codeberg.org/forgejo/governance/issues/247)
* Danish: @tacaly - [December 2024 Agreement](https://codeberg.org/forgejo/governance/issues/201)
* Dutch: @gusted - [February 2025 Agreement](https://codeberg.org/forgejo/governance/issues/230) (admin)
* Esperanto: @jadedctrl - [March 2025 Agreement](https://codeberg.org/forgejo/governance/issues/236)
* Filipino: @kita - [April 2025 Agreement](https://codeberg.org/forgejo/governance/issues/254)
* Finnish: @artnay - [April 2025 Agreement](https://codeberg.org/forgejo/governance/issues/256)
* French:
    * @earl-warren - [February 2025 Agreement](https://codeberg.org/forgejo/governance/issues/224) (admin)
    * @KaKi87 - [May 2024 Agreement](https://codeberg.org/forgejo/governance/issues/123)
* German:
    * @fnetX - [March 2025 Agreement](https://codeberg.org/forgejo/governance/issues/235) (admin)
    * @Wuzzy - [April 2025 Agreement](https://codeberg.org/forgejo/governance/issues/253)
* German (Low): @Nordfriese - [October 2024 Agreement](https://codeberg.org/forgejo/governance/issues/186)
* Greek: @n0toose - [February 2025 Agreement](https://codeberg.org/forgejo/governance/issues/231)
* Hebrew: @Laxystem - [February 2025 Agreement](https://codeberg.org/forgejo/governance/issues/220)
* Italian: @Zughy - [April 2025 Agreement](https://codeberg.org/forgejo/governance/issues/248)
* Japanese: @ledyba - [March 2025 Agreement](https://codeberg.org/forgejo/governance/issues/233)
* Korean: @kdh8219 - [May 2024 Agreement](https://codeberg.org/forgejo/governance/issues/121)
* Latvian: @Edgarsons - [November 2024 Agreement](https://codeberg.org/forgejo/governance/issues/190)
* Russian: @0ko - [February 2025 Agreement](https://codeberg.org/forgejo/governance/issues/221) (admin)
* Spanish:
    * @maletil - [March 2024 Agreement](https://codeberg.org/forgejo/governance/issues/88)
    * @Miguel_PL - [April 2025 Agreement](https://codeberg.org/forgejo/governance/issues/249)
* Ukrainian: @nykula - [March 2025 Agreement](https://codeberg.org/forgejo/governance/issues/238)

## User Research

Purpose: Conduct User Research in the context of Forgejo. Anyone can become a member of the team, as long as they need the associated permissions to contribute to work on the [User Research repository](https://codeberg.org/forgejo/user-research).

Team members:

* @fnetX - [April 2025 Agreement](https://codeberg.org/forgejo/governance/issues/250)

## Releases

Purpose: [See the documentation](https://forgejo.org/docs/next/developer/release/). The team is trusted with the primary GPG key used to sign Forgejo releases.

Accountability:

* Publish Forgejo releases.

Team members:

* @0ko - [November 2024 Agreement](https://codeberg.org/forgejo/governance/issues/192)
* @crystal - [January 2025 Agreement](https://codeberg.org/forgejo/governance/issues/212)
* @earl-warren - [July 2024 Agreement](https://codeberg.org/forgejo/governance/issues/141)

## Security

Purpose: [See the documentation](https://forgejo.org/docs/next/developer/discussions/#security).

Accountability:

* Handle security vulnerabilities.

Team members:

* @Gusted - [May 2025 Agreement](https://codeberg.org/forgejo/governance/issues/264)
* @earl-warren - [February 2025 Agreement](https://codeberg.org/forgejo/governance/issues/208)
* @viceice - [October 2024 Agreement](https://codeberg.org/forgejo/governance/issues/174) (limited to case by case assistance)
* @jerger - [June 2025 Agreement](https://codeberg.org/forgejo/governance/issues/270) (limited to case by case assistance)

## Social account

Purpose: Reply to questions and publish news on https://floss.social/@forgejo

Accountability:

* Sign the toots that are not discussed before being published. If a toot is published by a Forgejo contributor without consultation with anyone, it must be signed with `~ @name` that links to the social account of the contributor.
* If a toot is agreed upon, in a public space, by other Forgejo contributors it does not need to be signed.
* Attach an alt text to images for accessibility.

Team members:

* All members of the [releases team](#releases).
* All members of the [moderation team](#moderation).
* @fnetX - [September 2024 Agreement](https://codeberg.org/forgejo/governance/issues/173)
* @mahlzahn - [January 2025 Agreement](https://codeberg.org/forgejo/governance/issues/205)

## Moderation

Purpose: [See the documentation](https://forgejo.org/docs/next/developer/COC/).

Accountability:

* Take action when a behavior in a Forgejo space goes against the Code of Conduct or the law.
* [Follow the moderation process](MODERATION-PROCESS.md) and publish auditable reports based on facts and logic.

Team members:

* @Beowulf - [February 2025 Agreement](https://codeberg.org/forgejo/governance/issues/219)
* @mahlzahn - [June 2025 Agreement](https://codeberg.org/forgejo/governance/issues/277)
* @earl-warren - [June 2025 Agreement](https://codeberg.org/forgejo/governance/issues/275)

## Liberapay team members

Purpose: Receive a share of donations distributed via the [Forgejo Liberapay account](https://liberapay.com/forgejo).

Accountability:

* Manage the Forgejo Liberapay team account, which was created by the Codeberg account (@fnetx has access)
* Decide on a fair distribution of the incoming funds among the team members

Team members:

* Fallback: Codeberg e.V. receives part of the share to make use of leftover budget (@fnetx can manage the account)
* @algernon - [July 2024 Agreement](https://codeberg.org/forgejo/governance/issues/151)
* @crystal - [January 2025 Agreement](https://codeberg.org/forgejo/governance/issues/214)
* @viceice - [August 2024 Agreement](https://codeberg.org/forgejo/governance/issues/157)
* @meissa - [August 2024 Agreement](https://codeberg.org/forgejo/governance/issues/158)
    * @jerger
    * @patdyn


## Sustainability Team

Purpose: The team focuses on concerted efforts to make Forgejo a durable endeavour. This includes taking a lead on fundraising, work out propositions on strategic planning, and coordinating related activities within the community. The team also monitors the distribution of funding, and acts as a mediator in the event of a disagreement.

Accountability: The administrative aspects of grant applications from start to finish.

Team members:

- @avobs - [September 2024 Agreement](https://codeberg.org/forgejo/governance/issues/179)


## GitHub organisation owners
Up to date as of 2024-08-08.

[The Forgejo organisation on GitHub](https://github.com/forgejo) is only used to prevent squatting. Its information must be kept up to date (website, forge and social links).

- [caesar](https://github.com/caesar)
- [crystal](https://github.com/crystalcommunication)
- [gapodo](https://github.com/gapodo)
- [gusted](https://github.com/Gusted)
- [oliverpool](https://github.com/oliverpool)

## GitLab.com organisation owners
Up to date as of 2024-08-08.

[The Forgejo organisation on GitLab.com](https://gitlab.com/forgejo) is only used to prevent squatting.

- [crystal](https://gitlab.com/crystalcommunication)
- [oliverpool](https://gitlab.com/oliverpool)
