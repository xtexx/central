# Forgejo Security Policy

As accepted by the community in https://codeberg.org/forgejo/governance/issues/159.
Last modified: 2024-08-21

Forgejo takes security serious, and in addition, privacy is [one of the four core values](https://codeberg.org/forgejo/governance/src/branch/main/MISSION.md#values) of the project. These policies clarify communication and collaboration of the Forgejo security team with external parties such as libraries, security researchers and users.

## Reporting to Forgejo

- If you discover a security vulnerability in Forgejo, you **MUST** send an encrypted email to security@forgejo.org, combined with all available details. The same applies when a security issue was not properly addressed in Forgejo.
- This email **SHOULD** be encrypted, or you should contact us first so we can provide a secure channel for the transmission of the details. You **SHOULD NOT** share details about the issue via insecure channels. Please pay special attention when quoting email conversations.
- You **MAY** disclose the details of the security issue to other affected projects, such as operating systems or library vendors. You **SHOULD NOT** include details about the vulnerability that are not relevant to third-parties. (For example, informing a packager about an upcoming issue is probably enough, there is often no need to provide them with all details to reproduce and potentially abuse an issue)
- You **MUST NOT** disclose the vulnerability (both details and existence) to anyone not directly involved in either fixing the issue or distributing fixed software before an established embargo deadline. See the section for embargo timelines below. You **MAY** propose an embargo deadline of 90 days if Forgejo does not respond with an embargo deadline within 7 days of the report.
- We appreciate if you let us know which third parties are involved so we can continue the communication and avoid duplicated effort.
- Forgejo will only keep you updated via secure channels, and we reserve the right to not disclose details about the internal process.
- When reporting issues with an established embargo deadline, this deadline **MUST** be communicated to Forgejo. Forgejo **will respect** embargoes established by a reporting party.


## Coordination with third parties

- We appreciate your effort in working on the security fix together. Thank you.
- When Forgejo determined an embargo date for a vulnerability and you would like to extend it, you **SHOULD** give us advance notice as soon as possible and at least one week before the embargo expires.
- You **MUST NOT** communicate about the vulnerability in public before the embargo deadline passes. You **MUST** respect the rules about responsible disclosure timelines as specified below.
- You **MAY** apply these rules yourself and give advance notice of upcoming security releases for your affected product, or collaborate with others to fix the issue.
- You **MUST NOT** publish fixes for the security issue in public before the embargo deadline passes. This explicitly includes refactors or workarounds that solve the issue via security by obscurity to not draw attention to the affected parts of the codebase.
- You **MAY** publish all details about the security issue, including guides for reproduction, after patched software releases are available. We urge you to apply common sense for the timing and recommend waiting until most users had enough time to upgrade their instances to prevent massive exploitation of the issue.
- Failure to comply with these rules will be criticized publicly, and we reserve the right to no longer coordinate with you or your project in the future. In this case, you **SHOULD** reach out to us to settle the matter.
- The Forgejo security team reserves the right to collaborate with trusted third-parties on resolving specific security issues, on a case-by-case basis. This includes (but is not limited to) working with a reporter or security researcher on a solution. Such collaboration requires consensus within the Forgejo security team.


## Responsible disclosure timelines

- When Forgejo learns about a security report and no existing embargo dates have been agreed upon, Forgejo will categorize the security issue and apply schedules accordingly.
- The timeline is in this order:
    - A security issue is reported to Forgejo and investigated by our team
    - Affected upstream third-parties (e.g. libraries or related projects) are informed immediately after confirmation by Forgejo
    - Affected downstream third-parties which work upon the source code (e.g.  distributions packagers) can receive notice ahead of time
    - Affected system administrators can receive advance notice of an upcoming security release via https://codeberg.org/forgejo/security-announcements/issues
- The common procedures are listed below (total embargo time / disclosure to downstreams before deadline / announcement of upcoming release before deadline):
    - Security issues that are either simple to fix or the severity calls for an urgent fix: 30 days / 14 days / 7 days
    - Complex security issues: 90 days / 30 days / 14 days
- We acknowledge that it might sometimes become necessary to adjust deadlines to accommodate for new discoveries or unexpected complications, and we are open to discuss deadline adjustments. We ask you to respect that it is difficult to reschedule release dates and therefore ask you to give us a notice as soon as possible.
