<div v-pre class="man-page-content">

<div class="header-with-back"><div class="link" style="float: left;"><a href="./zopen-promote">← Previous</a></div><div class='link' style='float: right;'><a href='./zopen-query'>Next →</a></div><div style="clear: both;"></div></div>


<h1 align="center">ZOPEN-PUBLISH</h1>




<h2>NAME</h2>


<p style="margin-left:6%; margin-top: 1em">zopen-publish -
manual page for zopen-publish 0.8.5</p>

<h2>SYNOPSIS</h2>



<p style="margin-left:6%; margin-top: 1em">zopen-publish
[OPTION] -p PAX_FILE -m METADATA_FILE -g
TAG</p>

<h2>DESCRIPTION</h2>


<p style="margin-left:6%; margin-top: 1em">zopen-publish -
Publish zopen package release to GitHub and/or Pulp.</p>

<p style="margin-left:15%; margin-top: 1em">zopen-publish
[OPTION] --whl WHL_FILE --pulp-url URL</p>

<h2>OPTIONS</h2>


<p style="margin-left:6%; margin-top: 1em">-h,
--help</p>

<p style="margin-left:15%;">print this help</p>

<p style="margin-left:6%;">-v, --verbose</p>

<p style="margin-left:15%;">run in verbose mode.</p>

<p style="margin-left:6%;">-f, --force</p>

<p style="margin-left:15%;">Force overwrite release if tag
exists.</p>

<p style="margin-left:6%;">-p, --pax-file
PAX_FILE</p>

<p style="margin-left:15%;">Path to the pax.Z file required
for GitHub publish</p>

<p style="margin-left:6%;">-m,
--metadata-file FILE</p>

<p style="margin-left:15%;">Path to the metadata.json file
required for GitHub publish</p>

<p style="margin-left:6%;">-g, --tag TAG</p>

<p style="margin-left:15%;">Tag name for the release, e.g.
DEV_mypackage_12345</p>

<p style="margin-left:6%;">-r, --repo
REPO_URL</p>

<p style="margin-left:15%;">GitHub repository URL,
optional, overrides metadata.json</p>

<p style="margin-left:6%;">-d, --description
TEXT</p>

<p style="margin-left:15%;">Description for the GitHub
release</p>

<p style="margin-left:6%;">-b, --build-line
LINE</p>

<p style="margin-left:15%;">Build line: DEV or STABLE</p>

<p style="margin-left:6%;">-t, --github-token
TOKEN</p>

<p style="margin-left:15%;">GitHub token, or set
GITHUB_TOKEN</p>

<p style="margin-left:6%;">-o, --github-org
ORG</p>

<p style="margin-left:15%;">GitHub Organization, default:
zopencommunity</p>

<p style="margin-left:6%;">-l, --latest</p>

<p style="margin-left:15%;">Mark release as Latest /
non-prerelease</p>

<p style="margin-left:6%;">--pulp</p>

<p style="margin-left:15%;">Push RPM artifacts to Pulp
repository</p>

<p style="margin-left:6%;">--pulp-repo REPO</p>

<p style="margin-left:15%;">Pulp repository name, default:
zopen-stable or zopen-dev</p>

<p style="margin-left:6%;">-w, --whl
WHL_FILE</p>

<p style="margin-left:15%;">Path to a Python wheel file to
publish to Pulp PyPI</p>

<p style="margin-left:6%;">--pulp-url URL</p>

<p style="margin-left:15%;">Pulp PyPI repository URL</p>

<p style="margin-left:6%;">--pulp-user USER</p>

<p style="margin-left:15%;">Pulp username, or set
PULP_USER</p>

<p style="margin-left:6%;">--pulp-password PASS</p>

<p style="margin-left:15%;">Pulp password, or set
PULP_PASSWORD</p>

<p style="margin-left:6%;">--version</p>

<p style="margin-left:15%;">print version</p>

<h3>Environment Variables:</h3>



<p style="margin-left:6%; margin-top: 1em">GITHUB_TOKEN</p>

<p style="margin-left:15%;">GitHub Personal Access
Token</p>

<p style="margin-left:6%;">PULP_URL</p>

<p style="margin-left:15%;">Pulp PyPI repository URL</p>

<p style="margin-left:6%;">PULP_USER</p>

<p style="margin-left:15%;">Pulp username</p>

<p style="margin-left:6%;">PULP_PASSWORD</p>

<p style="margin-left:15%;">Pulp password</p>

<h2>EXAMPLES</h2>


<p style="margin-left:15%; margin-top: 1em">zopen-publish
-f -p install/mypackage.zos.pax.Z -m metadata.json -g
DEV_mypackage_12345 -t &lt;token&gt; zopen-publish --whl
dist/mypackage-1.0-py3-none-any.whl --pulp-url
http://host:8080/pypi/zopen/ zopen-publish -f -p
install/mypackage.zos.pax.Z -m metadata.json -g TAG -t
&lt;token&gt; --pulp</p>

<p style="margin-left:6%; margin-top: 1em">This is free
software: you are free to change and redistribute it under
the terms of the Apache License, Version 2.0.
<a href="https://www.apache.org/licenses/LICENSE-2.0.html" target="_blank">https://www.apache.org/licenses/LICENSE-2.0.html</a>
There is NO WARRANTY, to the extent permitted by law.</p>

<h2>AUTHOR</h2>


<p style="margin-left:6%; margin-top: 1em">Written by
contributors to the zopen community.
<a href="https://github.com/zopencommunity/meta/graphs/contributors" target="_blank">https://github.com/zopencommunity/meta/graphs/contributors</a></p>

</div>
