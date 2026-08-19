# zopen Technical Steering Committee (TSC) Structure and Governance

The Technical Steering Committee (TSC) for the zopen community is a group of passionate individuals dedicated to guiding the technical direction and fostering a vibrant open-source community for z/OS.

## Our Mission

Our primary goal is to make z/OS a more open and accessible platform for everyone. We do this by:

*   Curating a rich ecosystem of popular open-source tools.
*   Supporting developers and contributors in the community.
*   Ensuring the long-term health and stability of the zopen community.
*   Making it easier for everyone to contribute to and use open source on the mainframe.

## Responsibilities

The TSC has the following responsibilities:

*   Setting and maintaining the technical direction of the zopen project.
*   Reviewing and approving new project proposals and contributions.
*   Establishing and maintaining project policies and procedures.
*   Managing the project's infrastructure and resources.
*   Resolving technical disputes and making decisions on technical matters.
*   Working to grow the zopen community.

## Open Participation

The zopen community is an open, collaborative endeavor. Participation is open to individuals and organizations, subject to the project's contribution, review, licensing, technical, and Code of Conduct requirements.

Contributors participate as members of the community regardless of their employer. An individual's participation does not make community packages a supported product of that individual's employer unless a separate support arrangement explicitly says otherwise.

Organizations may contribute engineering time, testing, infrastructure, documentation, or funding. Sponsorship or organization affiliation does not purchase priority or give an organization control over project decisions.

## Package Requests and Prioritization

Package requests and community votes are advisory signals that help the project understand demand. Submitting or voting for a request does not create a delivery deadline, support commitment, or obligation for any individual, organization, maintainer, or the TSC to port or maintain a package. Website votes are not formal TSC governance votes.

When evaluating and prioritizing requests, maintainers and the TSC may consider:

*   Community interest and benefit to the broader z/OS ecosystem.
*   Contributor and maintainer availability.
*   Technical feasibility, dependencies, and expected maintenance effort.
*   Licensing and security considerations.
*   Available infrastructure, testing, and sponsorship.

Vote count is one input and is not the sole deciding factor. Routine request triage may be performed by project maintainers. Requests involving broader technical direction, infrastructure, policy, or disagreement may be referred to the TSC. Decisions and important status changes should be explained publicly where practical.

An **Accepted** request is considered suitable for the community backlog; it does not mean that implementation has started. **In progress** indicates that a contributor has taken responsibility for moving the port forward. Automated repository synchronization may identify possible package matches, but a maintainer must review a match before a request is marked **Available**.

## Security and Artifact Integrity

The project uses CodeQL-based security scanning for its z/OS codebase. Grype and Trivy may also be used to identify known vulnerabilities in dependencies, packages, container images, and other supported artifacts. Findings are reviewed, triaged, and remediated according to their severity and risk.

Python wheels published to Pulp may be accompanied by cryptographically verifiable attestations that bind each artifact to its build or publishing identity. Artifact integrity can be verified before promotion or consumption.

## Package Stewardship and Responsibility

Responsibility follows stewardship rather than the act of requesting or voting for a package:

| Area | Primary responsibility |
| --- | --- |
| Upstream functionality | The original upstream project |
| z/OS patches and build | Port contributors and repository maintainers |
| Package publishing | Port maintainers and zopen infrastructure maintainers |
| Project-wide policy and technical disputes | The zopen TSC |
| Testing in a particular environment | Package users and participating organizations |

A requester is not automatically responsible for implementation, although testing and contribution are encouraged. Package availability also does not guarantee indefinite maintenance. Maintenance depends on active contributors and project health, and a package may need a new maintainer or be identified as stale, deprecated, or unavailable.

## Consuming and Contributing

The community welcomes both people who use packages and people who contribute
them. These are different forms of participation and carry different
expectations.

### Consuming packages

Consumers may install, evaluate, use, test, document, and report problems with
community packages without becoming responsible for their implementation or
maintenance. A download, package request, vote, bug report, or testing result is
not an agreement to contribute code or provide support.

Consumers and participating organizations are responsible for deciding whether
a package is appropriate for their own environment. This includes evaluating
compatibility, licensing, provenance, security findings, operational risk, and
the package's documented maintenance state. **Available** means that the
community has published or identified a usable installation path; it is not a
warranty, certification, service-level agreement, or guarantee of fitness for a
particular purpose.

Useful consumer participation includes reporting reproducible results,
documenting use cases, identifying regressions, and offering environment-specific
testing. Consumers should distinguish upstream defects from z/OS porting,
packaging, or infrastructure defects so that reports reach the appropriate
project.

### Contributing packages

Contributors who propose a new port are expected to provide enough technical
evidence for review, comply with project licensing and Developer Certificate of
Origin requirements, follow the contribution and Code of Conduct policies, and
submit changes through the public review and testing process. Contributors should
avoid creating a z/OS-specific port when the upstream package already works
through the documented installation path.

Once a contribution is accepted, stewardship normally includes maintaining the
z/OS build and patches, tracking relevant upstream changes and dependencies,
responding to reasonable technical reports as availability permits, and helping
keep package status and limitations accurate. This is a good-faith community
expectation, not a promise of continuous availability or a permanent personal
obligation.

A contributor may reduce or end their involvement. They should communicate the
change where practical, document known issues, and help identify or transfer
access to another maintainer. If no maintainer is available, the community may
mark a package stale, deprecated, unavailable, or in need of stewardship rather
than imply support that does not exist.

Contribution does not transfer responsibility for upstream functionality to the
zopen community, and an individual's contribution does not create a support
commitment from their employer.

## Members

The current members of the TSC are listed on the [team page](docs/team.md).

### Joining the TSC

The process for appointing any new permanent member of the TSC requires:

1.  A nomination by an existing TSC member.
2.  A two-thirds vote by the full TSC on such an appointment.

Nominations should be made in writing and should include a brief biography of the nominee and a statement of their qualifications.

## Voting

### In Meetings

Decisions in TSC meetings are made by consensus. If consensus cannot be reached, a vote is held. A simple majority is required for a motion to pass.

### Outside of Meetings

The quorum for voting outside of meetings is defined in the TSC charter. Voting will be held in the TSC's designated communication channel. A two-thirds majority is required for a motion to pass.

## TSC Meeting Minutes

You can find the minutes from our TSC development meetings [here](https://github.com/zopencommunity/meta/wiki/Development-Minutes).

## Code of Conduct

All members of the zopen community, including the TSC, are expected to abide by the [zopen Code of Conduct](CODE_OF_CONDUCT.md).
