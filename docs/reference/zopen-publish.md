# zopen-publish

# ZOPEN-PUBLISH

[NAME](#NAME)

[SYNOPSIS](#SYNOPSIS)

[DESCRIPTION](#DESCRIPTION)

[OPTIONS](#OPTIONS)

[AUTHOR](#AUTHOR)


---



NAME




zopen-publish
- manual page for zopen-publish 0.8.4

SYNOPSIS





**zopen-publish**
[*OPTION*] -p PAX_FILE -m METADATA_FILE -g
TAG

DESCRIPTION





zopen-publish
- Publish zopen package release to GitHub.

OPTIONS





**-h**,
**--help**

print this help

**-v**,
**--verbose**

run in verbose mode.

**-f**,
**--force**

Force overwrite release if tag
exists.

**-p**,
**--pax-file** PAX_FILE

Path to the pax.Z file
(required)

**-m**,
**--metadata-file** METADATA_FILE

Path to the metadata.json file
(required)

**-g**,
**--tag** TAG

Tag name for the release
(required) e.g., DEV_mypackage_12345

**-r**,
**--repo** REPO_URL

GitHub repository URL
(optional, overrides metadata.json) e.g.,
https://github.com/zopencommunity/xzport.git

**-d**,
**--description** TEXT

Description for the GitHub
release (optional, from metadata.json &rsquo;summary&rsquo;
if omitted)

**-b**,
**--build-line** LINE

Build line (DEV or STABLE)
(optional, from metadata.json &rsquo;buildline&rsquo; if
omitted)

**-t**,
**--github-token** TOKEN

GitHub Personal Access Token
(required, or set GITHUB_TOKEN env var)

**-o**,
**--github-org** ORG

GitHub Organization (default:
zopencommunity)

**-l**,
**--latest**

Mark release as
&rsquo;Latest&rsquo; (not pre-release).


**--version**

print version

Environment
Variables: 

GITHUB_TOKEN

GitHub Personal Access Token
(alternative to **--github-token**)


**Example:**

zopen-publish -f
-p install/mypackage.zos.pax.Z **-m**
metadata.json **-g** DEV_mypackage_12345
**-t** &lt;your_github_token&gt;
zopen-publish **-v -f -p**
install/mypackage.zos.pax.Z **-m** metadata.json
**-r**
https://github.com/zopencommunity/override-repo.git
**-d** &quot;My custom release description&quot;
**-b** DEV **-g** REL-1.0.1
**-t** &lt;your_github_token&gt;
**-l**

This is free
software: you are free to change and redistribute it under
the terms of the Apache License, Version 2.0.
&lt;https://www.apache.org/licenses/LICENSE-2.0.html&gt;
There is NO WARRANTY, to the extent permitted by law.

AUTHOR




Written by
contributors to the zopen community.
&lt;https://github.com/zopencommunity/meta/graphs/contributors&gt;
---
