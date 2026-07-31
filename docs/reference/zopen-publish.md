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

<p style="margin-left:11%; margin-top: 1em">zopen-publish
[OPTION] -p PAX_FILE -m METADATA_FILE -g
TAG</p>

<h2>DESCRIPTION</h2>

<p style="margin-left:11%; margin-top: 1em">zopen&minus;publish
&minus; Publish zopen package release to GitHub.</p>

<h2>OPTIONS</h2>

<p style="margin-left:11%; margin-top: 1em">&minus;h,
&minus;&minus;help</p>

<p style="margin-left:22%;">print this help</p>

<p style="margin-left:11%;">&minus;v,
&minus;&minus;verbose</p>

<p style="margin-left:22%;">run in verbose mode.</p>

<p style="margin-left:11%;">&minus;f,
&minus;&minus;force</p>

<p style="margin-left:22%;">Force overwrite release if tag
exists.</p>

<p style="margin-left:11%;">&minus;p,
&minus;&minus;pax&minus;file PAX_FILE</p>

<p style="margin-left:22%;">Path to the pax.Z file
(required)</p>

<p style="margin-left:11%;">&minus;m,
&minus;&minus;metadata&minus;file METADATA_FILE</p>

<p style="margin-left:22%;">Path to the metadata.json file
(required)</p>

<p style="margin-left:11%;">&minus;g,
&minus;&minus;tag TAG</p>

<p style="margin-left:22%;">Tag name for the release
(required) e.g., DEV_mypackage_12345</p>

<p style="margin-left:11%;">&minus;r,
&minus;&minus;repo REPO_URL</p>

<p style="margin-left:22%;">GitHub repository URL
(optional, overrides metadata.json) e.g.,
<a href="https://github.com/zopencommunity/xzport.git" target="_blank">https://github.com/zopencommunity/xzport.git</a></p>

<p style="margin-left:11%;">&minus;d,
&minus;&minus;description TEXT</p>

<p style="margin-left:22%;">Description for the GitHub
release (optional, from metadata.json &rsquo;summary&rsquo;
if omitted)</p>

<p style="margin-left:11%;">&minus;b,
&minus;&minus;build&minus;line LINE</p>

<p style="margin-left:22%;">Build line (DEV or STABLE)
(optional, from metadata.json &rsquo;buildline&rsquo; if
omitted)</p>

<p style="margin-left:11%;">&minus;t,
&minus;&minus;github&minus;token TOKEN</p>

<p style="margin-left:22%;">GitHub Personal Access Token
(required, or set GITHUB_TOKEN env var)</p>

<p style="margin-left:11%;">&minus;o,
&minus;&minus;github&minus;org ORG</p>

<p style="margin-left:22%;">GitHub Organization (default:
zopencommunity)</p>

<p style="margin-left:11%;">&minus;l,
&minus;&minus;latest</p>

<p style="margin-left:22%;">Mark release as
&rsquo;Latest&rsquo; (not pre&minus;release).</p>

<p style="margin-left:11%;">&minus;&minus;version</p>

<p style="margin-left:22%;">print version</p>

<p style="margin-left:11%; margin-top: 1em">Environment
GITHUB_TOKEN</p>

<p style="margin-left:22%;">GitHub Personal Access Token
(alternative to &minus;&minus;github&minus;token)</p>

<p style="margin-left:11%; margin-top: 1em">Example:</p>

<p style="margin-left:22%;">zopen&minus;publish &minus;f
&minus;p install/mypackage.zos.pax.Z &minus;m
metadata.json &minus;g DEV_mypackage_12345
&minus;t &lt;your_github_token&gt;
zopen&minus;publish &minus;v &minus;f &minus;p
install/mypackage.zos.pax.Z &minus;m metadata.json
&minus;r
<a href="https://github.com/zopencommunity/override" target="_blank">https://github.com/zopencommunity/override</a>&minus;repo.git
&minus;d &quot;My custom release description&quot;
&minus;b DEV &minus;g REL&minus;1.0.1
&minus;t &lt;your_github_token&gt;
&minus;l</p>

<p style="margin-left:11%; margin-top: 1em">This is free
software: you are free to change and redistribute it under
the terms of the Apache License, Version 2.0.
<a href="https://www.apache.org/licenses/LICENSE-2.0.html" target="_blank">https://www.apache.org/licenses/LICENSE-2.0.html</a>
There is NO WARRANTY, to the extent permitted by law.</p>

<h2>AUTHOR</h2>

<p style="margin-left:11%; margin-top: 1em">Written by
contributors to the zopen community.
<a href="https://github.com/zopencommunity/meta/graphs/contributors" target="_blank">https://github.com/zopencommunity/meta/graphs/contributors</a></p>

</div>
