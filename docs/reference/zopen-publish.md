<div v-pre class="man-page-content">

<div class="header-with-back"><div class="link"><a href="./zopen-promote">← Previous</a></div><div class='link'><a href='./zopen-query'>Next →</a></div></div>

<h1 align="center">ZOPEN-PUBLISH</h1>












<h2>NAME</h2>


<table><tr><td style="width: 25%; vertical-align: top;"><b>zopen-publish
- manual page for zopen-publish 0.8.5

<h2>SYNOPSIS</h2>



<b>zopen-publish</b>
[<i>OPTION</i>] <i>-p PAX_FILE -m METADATA_FILE -g
TAG</i>

<h2>DESCRIPTION</h2>



zopen-publish
- Publish zopen package release to GitHub and/or
Pulp.</b></td><td style="vertical-align: top;">zopen-publish
[OPTION] <b>--whl</b> WHL_FILE
<b>--pulp-url</b> URL</td></tr></table>

<h2>OPTIONS</h2>



<table><tr><td style="width: 25%; vertical-align: top;"><b>-h</b>,
<b>--help</b></td><td style="vertical-align: top;">print this help</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-v</b>,
<b>--verbose</b></td><td style="vertical-align: top;">run in verbose mode.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-f</b>,
<b>--force</b></td><td style="vertical-align: top;">Force overwrite release if tag
exists.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-p</b>,
<b>--pax-file</b> PAX_FILE</td><td style="vertical-align: top;">Path to the pax.Z file required
for GitHub publish</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-m</b>,
<b>--metadata-file</b> FILE</td><td style="vertical-align: top;">Path to the metadata.json file
required for GitHub publish</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-g</b>,
<b>--tag</b> TAG</td><td style="vertical-align: top;">Tag name for the release, e.g.
DEV_mypackage_12345</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-r</b>,
<b>--repo</b> REPO_URL</td><td style="vertical-align: top;">GitHub repository URL,
optional, overrides metadata.json</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-d</b>,
<b>--description</b> TEXT</td><td style="vertical-align: top;">Description for the GitHub
release</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-b</b>,
<b>--build-line</b> LINE</td><td style="vertical-align: top;">Build line: DEV or STABLE</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-t</b>,
<b>--github-token</b> TOKEN</td><td style="vertical-align: top;">GitHub token, or set
GITHUB_TOKEN</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-o</b>,
<b>--github-org</b> ORG</td><td style="vertical-align: top;">GitHub Organization, default:
zopencommunity</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-l</b>,
<b>--latest</b></td><td style="vertical-align: top;">Mark release as Latest /
non-prerelease</td></tr>
<tr><td style="width: 25%; vertical-align: top;"><b>--pulp</b></td><td style="vertical-align: top;">Push RPM artifacts to Pulp repository</td></tr>
<tr><td style="width: 25%; vertical-align: top;"><b>--pulp-repo</b>
REPO</td><td style="vertical-align: top;">Pulp repository name, default:
zopen-stable or zopen-dev</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-w</b>,
<b>--whl</b> WHL_FILE</td><td style="vertical-align: top;">Path to a Python wheel file to
publish to Pulp PyPI</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--pulp-url</b>
URL</td><td style="vertical-align: top;">Pulp PyPI repository URL</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--pulp-user</b>
USER</td><td style="vertical-align: top;">Pulp username, or set
PULP_USER</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--pulp-password</b>
PASS</td><td style="vertical-align: top;">Pulp password, or set
PULP_PASSWORD</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--version</b></td><td style="vertical-align: top;">print version</td></tr></table>

<h3>Environment Variables:</h3>



<table><tr><td style="width: 25%; vertical-align: top;"><b>GITHUB_TOKEN</b></td><td style="vertical-align: top;">GitHub Personal Access
Token</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>PULP_URL</b></td><td style="vertical-align: top;">Pulp PyPI repository URL</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>PULP_USER</b></td><td style="vertical-align: top;">Pulp username</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>PULP_PASSWORD</b></td><td style="vertical-align: top;">Pulp password</td></tr></table>

<h2>EXAMPLES</h2>



<p style="margin-left:18%; margin-top: 1em">zopen-publish
-f -p install/mypackage.zos.pax.Z -m
metadata.json -g DEV_mypackage_12345 -t
<code>&lt;token&gt;</code> zopen-publish --whl
dist/mypackage-1.0-py3-none-any.whl
--pulp-url http://host:8080/pypi/zopen/
zopen-publish -f -p
install/mypackage.zos.pax.Z -m metadata.json -g
TAG -t <code>&lt;token&gt;</code> --pulp</p>

<p style="margin-left:9%; margin-top: 1em">This is free
software: you are free to change and redistribute it under
the terms of the Apache License, Version 2.0.
<a href="https://www.apache.org/licenses/LICENSE-2.0.html" target="_blank">https://www.apache.org/licenses/LICENSE-2.0.html</a>
There is NO WARRANTY, to the extent permitted by law.</p>

<h2>AUTHOR</h2>


<p style="margin-left:9%; margin-top: 1em">Written by
contributors to the zopen community.
<a href="https://github.com/zopencommunity/meta/graphs/contributors" target="_blank">https://github.com/zopencommunity/meta/graphs/contributors</a></p>

</div>
