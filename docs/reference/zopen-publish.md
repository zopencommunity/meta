<div v-pre class="man-page-content">

<div class="header-with-back">
  <div class="back-link">
    <a href="./zopen-reference">← Back</a>
  </div>
</div>

<h1 align="center">ZOPEN-PUBLISH</h1>

<h2>NAME</h2>

<p style="margin-left:11%; margin-top: 1em">zopen-publish
&minus; manual page for zopen-publish 0.8.4</p>

<h2>SYNOPSIS</h2>

<p style="margin-left:11%; margin-top: 1em"><b>zopen-publish</b>
[OPTION] -p PAX_FILE -m METADATA_FILE -g
TAG</p>

<h2>DESCRIPTION
<a name="DESCRIPTION"></a>
</h2>

<p style="margin-left:11%; margin-top: 1em">zopen&minus;publish
&minus; Publish zopen package release to GitHub.</p>

<h2>OPTIONS
<a name="OPTIONS"></a>
</h2>

<p style="margin-left:11%; margin-top: 1em"><b>&minus;h</b>,
<b>&minus;&minus;help</b></p>

<p style="margin-left:22%;">print this help</p>

<p style="margin-left:11%;"><b>&minus;v</b>,
<b>&minus;&minus;verbose</b></p>

<p style="margin-left:22%;">run in verbose mode.</p>

<p style="margin-left:11%;"><b>&minus;f</b>,
<b>&minus;&minus;force</b></p>

<p style="margin-left:22%;">Force overwrite release if tag
exists.</p>

<p style="margin-left:11%;"><b>&minus;p</b>,
<b>&minus;&minus;pax&minus;file</b> PAX_FILE</p>

<p style="margin-left:22%;">Path to the pax.Z file
(required)</p>

<p style="margin-left:11%;"><b>&minus;m</b>,
<b>&minus;&minus;metadata&minus;file</b> METADATA_FILE</p>

<p style="margin-left:22%;">Path to the metadata.json file
(required)</p>

<p style="margin-left:11%;"><b>&minus;g</b>,
<b>&minus;&minus;tag</b> TAG</p>

<p style="margin-left:22%;">Tag name for the release
(required) e.g., DEV_mypackage_12345</p>

<p style="margin-left:11%;"><b>&minus;r</b>,
<b>&minus;&minus;repo</b> REPO_URL</p>

<p style="margin-left:22%;">GitHub repository URL
(optional, overrides metadata.json) e.g.,
https://github.com/zopencommunity/xzport.git</p>

<p style="margin-left:11%;"><b>&minus;d</b>,
<b>&minus;&minus;description</b> TEXT</p>

<p style="margin-left:22%;">Description for the GitHub
release (optional, from metadata.json &rsquo;summary&rsquo;
if omitted)</p>

<p style="margin-left:11%;"><b>&minus;b</b>,
<b>&minus;&minus;build&minus;line</b> LINE</p>

<p style="margin-left:22%;">Build line (DEV or STABLE)
(optional, from metadata.json &rsquo;buildline&rsquo; if
omitted)</p>

<p style="margin-left:11%;"><b>&minus;t</b>,
<b>&minus;&minus;github&minus;token</b> TOKEN</p>

<p style="margin-left:22%;">GitHub Personal Access Token
(required, or set GITHUB_TOKEN env var)</p>

<p style="margin-left:11%;"><b>&minus;o</b>,
<b>&minus;&minus;github&minus;org</b> ORG</p>

<p style="margin-left:22%;">GitHub Organization (default:
zopencommunity)</p>

<p style="margin-left:11%;"><b>&minus;l</b>,
<b>&minus;&minus;latest</b></p>

<p style="margin-left:22%;">Mark release as
&rsquo;Latest&rsquo; (not pre&minus;release).</p>

<p style="margin-left:11%;"><b>&minus;&minus;version</b></p>

<p style="margin-left:22%;">print version</p>

<p style="margin-left:11%; margin-top: 1em"><b>Environment
GITHUB_TOKEN</b></p>

<p style="margin-left:22%;">GitHub Personal Access Token
(alternative to <b>&minus;&minus;github&minus;token</b>)</p>

<p style="margin-left:11%; margin-top: 1em"><b>Example:</b></p>

<p style="margin-left:22%;">zopen&minus;publish <b>&minus;f
&minus;p</b> install/mypackage.zos.pax.Z <b>&minus;m</b>
metadata.json <b>&minus;g</b> DEV_mypackage_12345
<b>&minus;t</b> &lt;your_github_token&gt;
zopen&minus;publish <b>&minus;v &minus;f &minus;p</b>
install/mypackage.zos.pax.Z <b>&minus;m</b> metadata.json
<b>&minus;r</b>
https::///github.comm//zopencommunityy//override&minus;repo.git
<b>&minus;d</b> &quot;My custom release description&quot;
<b>&minus;b</b> DEV <b>&minus;g</b> REL&minus;1.0.1
<b>&minus;t</b> &lt;your_github_token&gt;
<b>&minus;l</b></p>

<p style="margin-left:11%; margin-top: 1em">This is free
software: you are free to change and redistribute it under
the terms of the Apache License, Version 2.0.
<a href="https://www.apache.org/licenses/LICENSE-2.0.html" target="_blank">https://www.apache.org/licenses/LICENSE-2.0.html</a>
There is NO WARRANTY, to the extent permitted by law.</p>

<h2>AUTHOR
<a name="AUTHOR"></a>
</h2>

<p style="margin-left:11%; margin-top: 1em">Written by
contributors to the zopen community.
<a href="https://github.com/zopencommunity/meta/graphs/contributors" target="_blank">https://github.com/zopencommunity/meta/graphs/contributors</a></p>

</div>
