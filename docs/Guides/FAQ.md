# Zopen Community FAQ

## What is Zopen Community?
The Zopen Community initiative was started to help modernize z/OS and encourage open source development on z/OS. Currently, we have over 190+ projects that we, along with the community, are porting to z/OS. This list includes Git, Bash, Make, Ninja, CMake, Vim, and many others. All Zopen Community projects are hosted under the Zopen Community organization.

## How do I contribute?
If you have access to a z/OS system, you can get started with porting [here](https://zosopentools.github.io/meta/#/Guides/Porting). Not sure what to work on? Start with the [help wanted issues](https://github.com/zopen-community/meta/labels/help%20wanted). If you do not have access to a z/OS system, speak to [@Mike Fulton](https://github.com/MikeFultonDev) or [@Igor Todorovski](https://github.com/IgorTodorovskiIBM).

## How do I consume the Zopen Community?

To install and consume Zopen Community, we recommend that you use the [zopen package manager](https://zosopentools.github.io/meta/#/Guides/ThePackageManager?id=using-the-package-manager). Get started [here](https://zosopentools.github.io/meta/#/Guides/QuickStart). 
Alternatively, you can install the tools directly from the zOS Open Tools repo's github releases. For example, the releases for git are available [here]( https://github.com/zopen-community/gitport/releases). All Zopen Community releases are consolidated into a [table here](https://zosopentools.github.io/meta/#/Latest).

## What does zopen use for downloading the packages?
Zopen utilizes curl for downloading. There is a `ZOPEN_CURL_PARAMS` environment variable that can be set to pass additional parameters to curl.
Alternatively, you can create a `.curlrc` file in your home directory to pass additional parameters to curl.
This example shows a `.curlrc` file that can be used to go through a ntlm based proxy. In this example, a (url encoded) passphrase `This is my passphrase!` is used for the user `myuser`, the proxy is called `http://yourinternalproxy`, listening on port `8080`. In this example we also set a user agent to mimic a browser as some proxies might block other user agents. 
In this example we use the `--insecure` tag to ignore certificate errors. Even though this is convenient, a secure option is to include a `cacert /some/path/to/ca-all.pem` line that points to a pem file that has the necessary root certificates to allow for a trusted chain.
Of course, it is your responsibility to verify if your companies policy allows this!
```
--proxy http://yourinternalproxy:8080
--proxy-ntlm
--proxy-user myuser:This%20is%20my%20passphrase%21
--insecure

#user agent string
-A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36"
```

## Are the tools and commands provided by the Zopen Community project formally supported?
The tools and commands offered by Zopen Community operate within a volunteer-driven and community-supported framework. It's important to understand that these tools and commands are primarily maintained and supported by volunteers within the community. As such, the level of support may vary, and users are encouraged to engage with the community for assistance, report issues, and contribute to the project's development.

## How do I raise issues?
If the issue pertains to a given project, open the issue in the project's Github repository. If you have a general issue or discussion item, [create a discussion](https://github.com/zopen-community/meta/discussions) or ask us directly on the [System Z Enthusiasts discord channel](https://discord.gg/system-z-enthusiasts-880322471608344597).

## What is the current porting status?
Overall status for the Zopen Community initiative is available [here](https://zosopentools.github.io/meta/#/Progress).

## What are the z/OS Open Source Guild Meetings?
The z/OS Open Source Guild meetings are monthly meetings where we cover highlights in z/OS Open Source. To view past recordings and slides, visit [https://github.com/zopen-community/meta/discussions/categories/guild](https://github.com/zopen-community/meta/discussions/categories/guild).

## How do I get credit for my contributions?
We are working on a Badge reward system. Stay tuned.
