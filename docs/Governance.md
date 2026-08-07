---
title: Governance
description: How the zopen community makes decisions, prioritizes work, and shares responsibility.
---

# Governance

The zopen community is an open, collaborative project hosted by the [Open Mainframe Project](https://openmainframeproject.org/projects/zopen-community/). Individuals and organizations are welcome to participate under the same open contribution, review, licensing, technical, and conduct requirements.

> [!IMPORTANT]
> The repository's [GOVERNANCE.md](https://github.com/zopencommunity/meta/blob/main/GOVERNANCE.md) is the authoritative governance policy. This page presents that policy for website visitors. If the two ever differ, `GOVERNANCE.md` controls.

## Mission

The Technical Steering Committee (TSC) guides the technical direction of zopen community and helps foster a sustainable open-source ecosystem for z/OS. Its mission includes:

- Curating a rich ecosystem of open-source tools.
- Supporting developers and contributors.
- Promoting the long-term health and stability of the community.
- Making open source on z/OS easier to contribute to and use.

## Roles and responsibilities

The TSC sets technical direction, reviews project proposals, maintains project policies, helps manage shared infrastructure and resources, resolves technical disputes, and works to grow the community.

Package-level work is shared among the people closest to it:

| Area | Primary responsibility |
| --- | --- |
| Upstream functionality | The original upstream project |
| z/OS patches and build | Port contributors and repository maintainers |
| Package publishing | Port maintainers and zopen infrastructure maintainers |
| Project-wide policy and technical disputes | The zopen TSC |
| Testing in a particular environment | Package users and participating organizations |

Responsibility follows stewardship, not the act of requesting or voting for a package. A requester is not automatically responsible for implementing it, although testing and contribution are encouraged.

## How decisions are made

The TSC seeks consensus during meetings. If consensus cannot be reached, a simple-majority vote decides a motion. Outside meetings, voting takes place in the TSC's designated communication channel under the quorum requirements in the TSC charter, and a two-thirds majority is required.

Routine package-request triage may be handled by project maintainers. Matters involving broader technical direction, shared infrastructure, policy, or disagreement may be referred to the TSC. Decisions and important status changes should be explained publicly where practical.

The [TSC development meeting minutes](https://github.com/zopencommunity/meta/wiki/Development-Minutes) provide a public record of project discussions.

## TSC membership

Current TSC members are listed on the [team page](/team). A new permanent member must be nominated in writing by an existing TSC member and appointed by a two-thirds vote of the full TSC. A nomination should include a brief biography and the nominee's qualifications.

## Package requests and prioritization

[Package requests](/PackageRequests) and community votes help the project understand demand. They are advisory signals, not delivery deadlines, support commitments, or formal TSC governance votes.

Maintainers and the TSC may consider:

- Community interest and benefit to the broader z/OS ecosystem.
- Contributor and maintainer availability.
- Technical feasibility, dependencies, and maintenance effort.
- Licensing and security considerations.
- Infrastructure, testing, and sponsorship that can help the work succeed.

Vote count is one input, not the sole deciding factor. **Accepted** means a request is suitable for the community backlog and may still be awaiting a contributor. **In progress** means someone has taken responsibility for moving the port forward.

Repository synchronization may identify a possible match for a requested package, but a maintainer reviews the package identity and artifact before marking the request **Available**.

## Maintenance and support

Submitting, voting for, or accepting a package request does not oblige an individual, organization, maintainer, or the TSC to deliver or support it. Maintenance depends on active contributors and project health. A package may eventually need a new maintainer or be identified as stale, deprecated, or unavailable.

Community packages do not become IBM-supported—or supported by another contributor's employer—merely because one of that organization's employees participates. A commercial support arrangement must state such support separately and explicitly.

## Organizations and sponsorship

Organizations may contribute engineering time, testing, infrastructure, documentation, or funding. Organization information on a request can help explain a use case and coordinate testing, but it does not purchase priority or provide control over community decisions. Contributions remain subject to the same governance and technical requirements as other community work.

## Disputes and conduct

Technical disputes should first be addressed openly by the relevant maintainers. Project-wide or unresolved matters may be escalated to the TSC. Everyone participating in zopen community, including TSC members, must follow the [Code of Conduct](https://github.com/zopencommunity/meta/blob/main/CODE_OF_CONDUCT.md).

## How to participate

You can help by [requesting or voting for a package](/PackageRequests), testing packages on z/OS, documenting use cases and results, contributing code or documentation, helping with dependencies, or becoming a port maintainer. See the [contribution guidelines](https://github.com/zopencommunity/meta/blob/main/CONTRIBUTING.md) for the formal contribution and review process.

For more detail about requests and responsibilities, see the [package-request FAQ](/Guides/FAQ#package-requests-governance-and-responsibility).
