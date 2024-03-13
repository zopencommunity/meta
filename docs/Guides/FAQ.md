# z/OS Open Tools FAQ

## What is z/OS Open Tools?
The z/OS Open Tools initiative was started to help modernize z/OS and encourage open source development on z/OS. Currently, we have over 190+ projects that we, along with the community, are porting to z/OS. This list includes Git, Bash, Make, Ninja, CMake, Vim, and many others. All z/OS Open Tools projects are hosted under the z/OS Open Tools organization.

## How do I contribute?
If you have access to a z/OS system, you can get started with porting [here](https://zosopentools.github.io/meta/#/Guides/Porting). Not sure what to work on? Start with the [help wanted issues](https://github.com/ZOSOpenTools/meta/labels/help%20wanted). If you do not have access to a z/OS system, speak to [@Mike Fulton](https://github.com/MikeFultonDev) or [@Igor Todorovski](https://github.com/IgorTodorovskiIBM).

## How do I consume the z/OS Open Tools?

To install and consume z/OS Open Tools, we recommend that you use the [zopen package manager](https://zosopentools.github.io/meta/#/Guides/ThePackageManager?id=using-the-package-manager). Get started [here](https://zosopentools.github.io/meta/#/Guides/QuickStart). 
Alternatively, you can install the tools directly from the zOS Open Tools repo's github releases. For example, the releases for git are available [here]( https://github.com/ZOSOpenTools/gitport/releases). All z/OS Open Tools releases are consolidated into a [table here](https://zosopentools.github.io/meta/#/Latest).

## What does zopen use for downloading the packages?
Zopen utilizes curl for downloading. If you are behind a corporate firewall it might be possible to create a `.curlrc` file in your home directory to allow zopen to go through the proxy. This example is for a ntlm based proxy, where a passphrase `This is my passphase!` is used for the user `myuser`, the proxy is called `http://yourinternalproxy`, listening on port `8080`. In this example we also set a user agent to mimic a browser as some proxies might block other user agents. Of course, it is your responsibility to comply with your companies policy if this is allowed.
```
--proxy http://yourinternalproxy:8080
--proxy-ntlm
--proxy-user myuser:This%20is%20my%20passphrase%21
--insecure

#user agent string
-A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36"
```

## Are the tools and commands provided by the z/OS Open Tools project formally supported?
The tools and commands offered by z/OS Open Tools operate within a volunteer-driven and community-supported framework. It's important to understand that these tools and commands are primarily maintained and supported by volunteers within the community. As such, the level of support may vary, and users are encouraged to engage with the community for assistance, report issues, and contribute to the project's development.

## How do I raise issues?
If the issue pertains to a given project, open the issue in the project's Github repository. If you have a general issue or discussion item, [create a discussion](https://github.com/ZOSOpenTools/meta/discussions) or ask us directly on the [System Z Enthusiasts discord channel](https://discord.gg/system-z-enthusiasts-880322471608344597).

## What is the current porting status?
Overall status for the z/OS Open Tools initiative is available [here](https://zosopentools.github.io/meta/#/Progress).

## What are the z/OS Open Source Guild Meetings?
The z/OS Open Source Guild meetings are monthly meetings where we cover highlights in z/OS Open Source. To view past recordings and slides, visit [https://github.com/ZOSOpenTools/meta/discussions/categories/guild](https://github.com/ZOSOpenTools/meta/discussions/categories/guild).

## How do I get credit for my contributions?
We are working on a Badge reward system. Stay tuned.
