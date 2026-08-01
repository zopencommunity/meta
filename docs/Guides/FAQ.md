# zopen community FAQ

[[toc]]

## General

### What is the zopen community?

The zopen community initiative, **now part of the Open Mainframe Project (OMP)**, was started to help modernize z/OS and encourage open source development on z/OS. Currently, we have over 200+ projects that we, along with the community, are porting to z/OS. This [list of projects is available here](https://zopencommunity.github.io/meta/#/Latest) and includes popular tools like Git, Bash, Make, Ninja, CMake, and Vim. To make these tools easily consumable, the zopen community provides the `zopen` package manager. All zopen community projects are hosted under the [Zopen Community organization on GitHub](https://github.com/zopencommunity) and are part of the OMP.

### What is the Open Mainframe Project's (OMP) relationship with zopen community?

The zopen community is now a project hosted under the [Open Mainframe Project](https://openmainframeproject.org/projects/zopen-community/) (OMP), which is part of the Linux Foundation. Being part of the OMP provides zopen community with a neutral governance structure, broader community reach, and access to resources within the OMP ecosystem. This partnership strengthens the project's sustainability and its mission to advance open source on z/OS.

### Who maintains the zopen community project?

The zopen community project continues to be volunteer-driven and community-supported, now under the umbrella of the Open Mainframe Project. It is maintained and supported by volunteers from the community, including individuals and organizations passionate about open source on z/OS.

### Are the tools and commands provided by the zopen community project formally supported?

The tools and commands offered by zopen community operate within a volunteer-driven and community-supported framework. While being part of the OMP enhances the project's visibility and community, the support model remains community-based. These tools and commands are primarily maintained and supported by volunteers. As such, the level of support may vary, and users are encouraged to engage with the community for assistance, report issues, and contribute to the project's development. The OMP affiliation does not imply formal commercial support, but it does signify a stronger community backing and potential for broader collaboration.

### Is the zopen community project affiliated with IBM?

While some contributors are associated with IBM, and IBM has been a significant supporter, the zopen community project, as part of the Open Mainframe Project, is an independent, community-led initiative focused on open source on z/OS. The project benefits from contributions from various individuals and organizations, fostering a vendor-neutral ecosystem.

### Does zopen community have IBM approval for installation on IBM-owned systems?

zopen Community is a community-led open source initiative. While many contributors are IBM employees, the project itself is not an IBM product and is not formally vetted or certified by IBM. As such, we are not aware of a formal IBM-wide approval process for installing zopen Community on IBM-owned systems. Organizations should follow their own internal software governance and approval processes before adopting it.

Regarding scenarios where systems are IBM-owned but hosted in a partner's data center, that would be governed by your organization's internal policies, so we are unfortunately not in a position to advise on that.

### Does zopen community provide IBM-certified builds?

zopen Community does not currently provide IBM-certified builds or a separate IBM-managed repository.

The [IBM Open Enterprise Foundation for z/OS](https://www.ibm.com/products/open-enterprise-foundation-zos) is a separate IBM offering with a curated set of packages and a different support model. The zopen Community repository has a broader catalog of community-maintained packages, which is why you may find packages there that are not currently included in OEF.

### Does zopen community offer a stable or long-term support (LTS) release channel?

We understand the value of a stable or long-term support (LTS) release channel for enterprise environments. While we don't have a formal LTS offering to announce today, we appreciate the suggestion and will certainly take it into consideration as we continue to evolve the project.

### What platforms and z/OS versions are supported?

zopen community tools are designed to run on z/OS. Compatibility is generally focused on actively supported z/OS versions. While efforts are made to support a range of z/OS releases, it's recommended to consult individual project documentation or release notes for specific z/OS version compatibility. Modern z/OS UNIX systems are the primary target.

### What is the current porting status?

Overall status for the zopen community initiative is available [here](/Progress). This page provides up-to-date information on the progress of porting various open source projects.

### What are the z/OS Open Source Guild Meetings?

The z/OS Open Source Guild meetings are monthly meetings where we cover highlights in z/OS Open Source and often feature updates from the zopen community. To view past recordings and slides, visit [https://github.com/zopencommunity/meta/discussions/categories/guild](https://github.com/zopencommunity/meta/discussions/categories/guild). These meetings are a great way to stay informed about the latest developments.

### How do I raise issues?

For project-specific issues, please open an issue in the project's GitHub repository. For general issues or discussions, create a discussion in the [meta repository](https://github.com/zopencommunity/meta/discussions) or ask on the [System Z Enthusiasts Discord channel](https://discord.com/invite/sze). For general community questions, the Discord channel is often a good place to get quick answers.

### What is the license for zopen community tools?

zopen community projects generally follow open source licenses, with many using licenses like the Apache License 2.0. Refer to the specific project's repository for the exact license details, usually found in a `LICENSE` file in the root of the repository.

### How does zopen community handle compliance and licensing of distributed packages?

Packages distributed through zopen Community retain the licenses provided by their upstream open source projects. At present, we do not perform a separate legal or compliance certification of those licenses. Organizations adopting zopen Community should review the upstream licenses and ensure they align with their internal open source policies.

### Where can I find a list of all ported tools?

A comprehensive list of ported tools and their status can be found on the zopen community website, often linked from the main `meta` repository. The [Progress page](/Progress) and the [Latest Releases](/Latest) table are good starting points to explore available tools.

---

## Consuming

### How do I consume zopen community tools?

There are two main ways to consume zopen community tools: using the recommended [zopen package manager](/Guides/QuickStart), or by directly downloading tools. For most users, the package manager is the easier and more robust method as it handles dependency management for you.

### What is the zopen package manager and why should I use it?

The zopen package manager is the recommended way to install and manage zopen community tools. It simplifies installation, automatically handles dependencies, and makes updates easier. You can find more information and get started [here](/Guides/ThePackageManager). It's designed specifically for z/OS and the tools provided by the zopen community.

### Where can I download the zopen package manager?

Instructions to download and install the zopen package manager can be found in the [Quick Start guide](/Guides/QuickStart). The quick start guide provides the most direct and up-to-date installation instructions.

### How do I install and manage zopen tools using the zopen package manager?

Please refer to the [Using the Package Manager guide](/Guides/ThePackageManager) for detailed instructions on installing tools. This guide covers basic installation, listing available packages, and more advanced usage.

### How do I check for vulnerabilities in packages installed with the zopen package manager?

You can use the `zopen audit` command to check for known vulnerabilities in the packages you have installed using the zopen package manager.

### Where do I open issues against the zopen package manager?

If you encounter issues with the zopen package manager itself, please open an issue in the [meta repository](https://github.com/zopencommunity/meta/issues).

### Does the zopen package manager require internet access?

Yes, the zopen package manager requires internet access to download packages and metadata. Ensure your z/OS system has outbound internet connectivity, or configure a proxy if necessary.

### Can I use the zopen package manager behind a proxy?

Yes, zopen uses `curl` for downloading and supports proxies, which is common in enterprise z/OS environments. You can configure proxy settings using environment variables or a `.curlrc` file as described in the section below.

### What technology does zopen use for downloading the packages?

zopen utilizes `curl` for downloading, a widely used and robust command-line tool for transferring data with URLs. There is a `ZOPEN_CURL_PARAMS` environment variable that can be set to pass additional parameters to curl, providing flexibility for advanced configurations.

Alternatively, you can create a `.curlrc` file in your home directory to pass persistent additional parameters to curl. This example shows a `.curlrc` file that can be used to go through an NTLM-based proxy, often encountered in corporate networks:

```
--proxy http://yourinternalproxy:8080
--proxy-ntlm
--proxy-user myuser:This%20is%20my%20passphrase%21
--insecure

# User agent string (optional, but can help with some proxies)
-A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36"
```

> **Note:** Using `--insecure` disables TLS certificate verification. For a more secure configuration, consider adding your trusted CA certificates instead.

### Can I install specific versions of packages using the zopen package manager?

Yes, the zopen package manager supports installing specific versions of packages. Refer to the [package manager documentation](/Guides/ThePackageManager) for syntax and examples on how to specify version numbers during installation.

### What should I do if I get "Permission denied" errors when installing zopen using pax?

Some z/OS environments have enhanced security settings that may require additional permissions to extract the zopen pax archive. If you encounter "Permission denied" errors during `pax -rf meta-main.xxxx.zos.pax.Z`, it's likely related to security permissions or your `umask` setting.

- **Check your `umask` setting:** A restrictive `umask` (e.g., `umask 500`) can prevent `pax` from creating directories and files with the necessary permissions. Ensure your `umask` setting is reasonable (e.g., `0022` is a common default). Use the `umask` command to check and adjust your setting if needed.

- **BPX.CAHFS.\* Permissions (TSS environments):** In environments using **TSS (Top Secret Security)**, "Permission denied" errors during pax extraction — especially error code `EDC5111I Permission denied. (errno2=0x5BC80004)` — are often caused by missing permissions for certain `BPX.CAHFS.*` facility classes.

  Users in highly secured TSS environments might need to be permitted to the following TSS SAF facility classes:

  | Facility class |
  |---|
  | `BPX.CAHFS.CHANGE.FILE.ATTRIBUTES` |
  | `BPX.CAHFS.CHANGE.FILE.FORMAT` |
  | `BPX.CAHFS.CHANGE.FILE.MODE` |
  | `BPX.CAHFS.CHANGE.FILE.TIME` |
  | `BPX.CAHFS.CREATE.SYMBOLIC.LINK` |

  Contact your z/OS security team and ask them to grant you access to these `BPX.CAHFS.*` facilities.

- **Other security products (ACF2, RACF):** Request your security team to grant equivalent permissions for file attribute changes, file format changes, file mode changes, file time changes, and symbolic link creation for your user ID.

---

## Security

### What security practices does zopen community follow for its software supply chain?

Security is an important area for the project, and we continue to strengthen our software supply chain practices.

**Current practices:**

| Practice | Details |
|---|---|
| Pull request requirement | All changes require a pull request — no direct pushes to the main branch |
| Code review | At least two reviewers must approve before changes are merged |
| CI gating | CI must pass before any merge |
| Release controls | Only authorized maintainers can approve and publish releases |
| Isolated builds | Packages are built through an automated, isolated CI pipeline rather than on developer workstations |
| Artifact signing | Release artifacts are signed using a GPG key, allowing users to verify authenticity and integrity |

**In progress:**

- Enabling automated static security scanning as part of our CI pipeline.
- Continuing to evaluate additional improvements to our software supply chain security.

### How can I check for known vulnerabilities in installed packages?

The zopen package manager provides a [`zopen audit`](/reference/zopen-audit) command to help identify known vulnerabilities in installed packages. We also publish vulnerability information on the [zopen Community Vulnerabilities page](/Vulnerabilities).

Additionally, organizations can use industry-standard vulnerability scanners such as [Grype](https://github.com/anchore/grype) or [Trivy](https://github.com/aquasecurity/trivy) as part of their own security and compliance workflows.

---

## Contributing

### How do I contribute to the zopen community?

If you are passionate about open source on z/OS, there are many ways to contribute! If you have access to a z/OS system, you can contribute by porting open source tools to z/OS. Get started with the [porting guide](/Guides/Porting). If you are unsure where to begin, check out the [help wanted issues](https://github.com/zopencommunity/meta/labels/help%20wanted). If you do not have z/OS access, you can request access via the [z/OS Public Facing Program](https://community.ibm.com/zsystems/form/zos-program/). Joining the System Z Enthusiasts Discord channel is also a great way to connect with the community.

### What kind of contributions are needed?

The zopen community welcomes various types of contributions:

| Contribution type | Description |
|---|---|
| Porting open source tools | Bringing new open source tools to the z/OS platform |
| Testing ported tools | Ensuring tools function correctly in the z/OS environment |
| Improving documentation | Clear and comprehensive documentation is essential for user adoption |
| Feedback and issue reporting | User feedback helps identify bugs and areas for improvement |
| Community support | Assisting other users in the community is a valuable contribution |
| Package manager development | Contributions to the package manager enhance the user experience |
| Examples and tutorials | Helping new users get started is important for community growth |

### Where can I find the source code for zopen community projects?

All zopen community project source code is hosted on GitHub under the [zopen community organization](https://github.com/zopencommunity). Each ported tool and the zopen package manager have their own repositories within this organization.
