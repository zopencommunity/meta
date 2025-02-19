# zopen community FAQ

## General

### What is the zopen community?
The zopen community initiative, **now part of the Open Mainframe Project (OMP)**, was started to help modernize z/OS and encourage open source development on z/OS. Currently, we have over 200+ projects that we, along with the community, are porting to z/OS.  This [list of projects is available here](https://zopencommunity.github.io/meta/#/Latest) and includes popular tools like Git, Bash, Make, Ninja, CMake, and Vim.  To make these tools easily consumable, the zopen community provides the `zopen` package manager. All zopen community projects are hosted under the [Zopen Community organization on GitHub](https://github.com/zopencommunity) and are part of the OMP.

### What is the Open Mainframe Project's (OMP) relationship with zopen community?
The zopen community is now a project hosted under the [Open Mainframe Project](https://openmainframeproject.org/projects/zopen-community/) (OMP), which is part of the Linux Foundation. Being part of the OMP provides zopen community with a neutral governance structure, broader community reach, and access to resources within the OMP ecosystem. This partnership strengthens the project's sustainability and its mission to advance open source on z/OS.

### Who maintains the zopen community project?
The zopen community project continues to be volunteer-driven and community-supported, now under the umbrella of the Open Mainframe Project. It is maintained and supported by volunteers from the community, including individuals and organizations passionate about open source on z/OS.

### Are the tools and commands provided by the zopen community project formally supported?
The tools and commands offered by zopen community operate within a volunteer-driven and community-supported framework.  While being part of the OMP enhances the project's visibility and community, the support model remains community-based.  These tools and commands are primarily maintained and supported by volunteers. As such, the level of support may vary, and users are encouraged to engage with the community for assistance, report issues, and contribute to the project's development. The OMP affiliation does not imply formal commercial support, but it does signify a stronger community backing and potential for broader collaboration.

### Is the zopen community project affiliated with IBM?
While some contributors are associated with IBM, and IBM has been a significant supporter, the zopen community project, as part of the Open Mainframe Project, is an independent, community-led initiative focused on open source on z/OS.  The project benefits from contributions from various individuals and organizations, fostering a vendor-neutral ecosystem.

### What platforms and z/OS versions are supported?
zopen community tools are designed to run on z/OS.  Compatibility is generally focused on actively supported z/OS versions.  While efforts are made to support a range of z/OS releases, it's recommended to consult individual project documentation or release notes for specific z/OS version compatibility.  Modern z/OS UNIX systems are the primary target.

### What is the current porting status?
Overall status for the zopen community initiative is available [here](/Progress).  This page provides up-to-date information on the progress of porting various open source projects.

### What are the z/OS Open Source Guild Meetings?
The z/OS Open Source Guild meetings are monthly meetings where we cover highlights in z/OS Open Source and often feature updates from the zopen community. To view past recordings and slides, visit [https://github.com/zopencommunity/meta/discussions/categories/guild](https://github.com/zopencommunity/meta/discussions/categories/guild). These meetings are a great way to stay informed about the latest developments.

### How do I raise issues?
For project-specific issues, please open an issue in the project's GitHub repository. For general issues or discussions, create a discussion in the [meta repository](https://github.com/zopencommunity/meta/discussions) or ask on the [System Z Enthusiasts discord channel](https://discord.com/invite/sze).  For general community questions, the Discord channel is often a good place to get quick answers.

### What is the license for zopen community tools?
Zopen community projects generally follow open source licenses, with many using licenses like the Apache License 2.0.  Refer to the specific project's repository for the exact license details, usually found in a `LICENSE` file in the root of the repository.

### Where can I find a list of all ported tools?
A comprehensive list of ported tools and their status can be found on the zopen community website, often linked from the main `meta` repository. The [Progress page](/Progress) and the [Latest Releases](/Latest) table are good starting points to explore available tools.

## Consuming

### How do I consume zopen community tools?
There are two main ways to consume zopen community tools: using the recommended [zopen package manager](/Guides/QuickStart), or by directly downloading tools.  For most users, the package manager is the easier and more robust method as it handles dependency management for you.

### zopen package manager

### What is the zopen package manager and why should I use it?
The zopen package manager is the recommended way to install and manage zopen community tools. It simplifies installation, automatically handles dependencies, and makes updates easier. You can find more information and get started [here](/Guides/ThePackageManager). It's designed specifically for z/OS and the tools provided by the zopen community.

### Where can I download the zopen package manager?
Instructions to download and install the zopen package manager can be found in the [Quick Start guide](/Guides/QuickStart).  The quick start guide provides the most direct and up-to-date installation instructions.

### How do I install and manage zopen tools using the zopen package manager?
Please refer to the [Using the Package Manager guide](/Guildes/ThePackageManager) for detailed instructions on installing tools.  This guide covers basic installation, listing available packages, and more advanced usage.

### How do I check for vulnerabilities in packages installed with the zopen package manager?
You can use the `zopen audit` command to check for known vulnerabilities in the packages you have installed using the zopen package manager. 

### Where do I open issues against the zopen package manager?
If you encounter issues with the zopen package manager itself, please open an issue in the [meta repository](https://github.com/zopencommunity/meta/issues).

### Does the zopen package manager require internet access?
Yes, the zopen package manager requires internet access to download packages and metadata. Ensure your z/OS system has outbound internet connectivity, or configure a proxy if necessary.

### Can I use the zopen package manager behind a proxy?
Yes, zopen uses `curl` for downloading and supports proxies, which is common in enterprise z/OS environments. You can configure proxy settings using environment variables or a `.curlrc` file as described in the "What does zopen use for downloading the packages?" section below.

### What technology does zopen use for downloading the packages?
zopen utilizes curl for downloading, a widely used and robust command-line tool for transferring data with URLs. There is a `ZOPEN_CURL_PARAMS` environment variable that can be set to pass additional parameters to curl, providing flexibility for advanced configurations.
Alternatively, you can create a `.curlrc` file in your home directory to pass persistent additional parameters to curl.
This example shows a `.curlrc` file that can be used to go through a ntlm based proxy, often encountered in corporate networks.
```
--proxy http://yourinternalproxy:8080
--proxy-ntlm
--proxy-user myuser:This%20is%20my%20passphrase%21
--insecure

#user agent string (optional, but can help with some proxies)
-A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36"
```

Refer to the original FAQ for more details on proxy configuration and security considerations, including adding trusted CA certificates instead of using `--insecure`.

### Can I install specific versions of packages using the zopen package manager?
Yes, the zopen package manager supports installing specific versions of packages. Refer to the [package manager documentation](/Guides/ThePackageManager) for syntax and examples on how to specify version numbers during installation.

### What should I do if I get "Permission denied" errors when installing zopen using pax?
Some z/OS environments have enhanced security settings that may require additional permissions to extract the zopen pax archive. If you encounter "Permission denied" errors during `pax -rf meta-main.xxxx.zos.pax.Z`, it's likely related to security permissions or your `umask` setting.

* Check your `umask` setting: A restrictive `umask` (e.g., `umask 500`) can prevent `pax` from creating directories and files with the necessary permissions, leading to "Permission denied" errors.  Ensure your `umask` setting is reasonable (e.g., `0022` is a common default). Use the `umask` command to check and adjust your setting if needed.
* BPX.CAHFS.\* Permissions (TSS Environments): In environments using **TSS (Top Secret Security)**, "Permission denied" errors during pax extraction, especially error code `EDC5111I Permission denied. (errno2=0x5BC80004)`, are often caused by missing permissions for certain **BPX.CAHFS.** facility classes. These facilities control various file system operations.

Users in highly secured TSS environments might need to be permitted to the following TSS SAF facility classes to successfully extract the zopen pax archive and use zopen tools:

* **BPX.CAHFS.CHANGE.FILE.ATTRIBUTES**
* **BPX.CAHFS.CHANGE.FILE.FORMAT**
* **BPX.CAHFS.CHANGE.FILE.MODE**
* **BPX.CAHFS.CHANGE.FILE.TIME**
* **BPX.CAHFS.CREATE.SYMBOLIC.LINK** 

If you encounter these errors in a TSS environment, contact your z/OS security team and ask them to grant you access to these BPX.CAHFS.* facilities.  

If you are using a security product other than RACF (like ACF2 or TSS), request your security team to grant you equivalent permissions that allow file attribute changes, file format changes, file mode changes, file time changes, and symbolic link creation for your user ID.

## Contributing

### How do I contribute to the zopen community?
If you are passionate about open source on z/OS, there are many ways to contribute! If you have access to a z/OS system, you can contribute by porting open source tools to z/OS. Get started with the [porting guide](/Guides/Porting). If you are unsure where to begin, check out the [help wanted issues](https://github.com/zopencommunity/meta/labels/help%20wanted). If you do not have z/OS access, you can request access via the [z/OS Public Facing Program](https://community.ibm.com/zsystems/form/zos-program/). Joining the System Z Enthusiasts Discord channel is also a great way to connect with the community.

### What kind of contributions are needed?
The zopen community welcomes various types of contributions:
* **Porting open source tools to z/OS:**  Bringing new open source tools to the z/OS platform.
* **Testing ported tools on z/OS:** Ensuring tools function correctly in the z/OS environment.
* **Improving documentation:** Clear and comprehensive documentation is essential for user adoption.
* **Providing feedback and reporting issues:** User feedback helps identify bugs and areas for improvement.
* **Helping with community support:** Assisting other users in the community is a valuable contribution.
* **Developing the zopen package manager itself:** Contributions to the package manager enhance the user experience.
* **Creating examples and tutorials:**  Helping new users get started is important for community growth.

### Where can I find the source code for zopen community projects?
All zopen community project source code is hosted on GitHub under the [zopen community organization](https://github.com/zopencommunity).  Each ported tool and the zopen package manager have their own repositories within this organization.
