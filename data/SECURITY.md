# Security Policy

CRA stewardship: This project is supported under the Linux Foundation CRA
stewardship framework, as described at https://www.linuxfoundation.org/security.
Security vulnerabilities should be reported through the mechanisms described
below, which we will coordinate with our CRA steward. For actively exploited
vulnerabilities and severe incidents that may require CRA escalation, please use
the project’s emergency security reporting mechanisms as appropriate.

## Reporting a Vulnerability

Please do **not** report security vulnerabilities through public GitHub issues,
pull requests, or discussions.

Report vulnerabilities privately using either of the following:

1. **GitHub private vulnerability reporting (preferred):**
   https://github.com/{{REPOSITORY}}/security/advisories/new
2. **Email:** zosopentools@gmail.com

Please include, where possible:

- A description of the issue and its potential impact
- The affected package, version, and z/OS release
- Steps to reproduce, or a proof of concept
- Whether the vulnerability is being actively exploited

## Actively Exploited Vulnerabilities and Severe Incidents

If you believe a vulnerability is being actively exploited, or that an incident
may require CRA escalation, say so at the start of your report (for example,
put "ACTIVELY EXPLOITED" in the subject or title) so that it can be prioritized
and escalated to the CRA steward.

## Scope

This repository contains the z/OS port of an upstream open source project.
Vulnerabilities in the upstream project itself should also be reported to the
upstream maintainers following their security policy. We will coordinate with
upstream where a fix is required there. Issues specific to the z/OS port
(patches, build scripts, packaging, or artifacts published by the zopen
community) are handled in this repository.

## Supported Versions

Security fixes are provided for the latest release of each package published by
the zopen community. Use `zopen audit` to check installed packages for known
vulnerabilities and `zopen upgrade` to move to the latest release.
