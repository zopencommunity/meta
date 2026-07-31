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





























<table border="1" cellpadding="10" cellspacing="0" style="width:100%; border-collapse:collapse;">
<tr style="background-color:#f0f0f0;">
<th style="text-align:left; border: 1px solid #ccc;">Option</th>
<th style="text-align:left; border: 1px solid #ccc;">Description</th>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;h, &minus;&minus;help</code></td>
<td style="border: 1px solid #ccc;">print this help</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;v, &minus;&minus;verbose</code></td>
<td style="border: 1px solid #ccc;">run in verbose mode.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;f, &minus;&minus;force</code></td>
<td style="border: 1px solid #ccc;">Force overwrite release if tag exists.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;p, &minus;&minus;pax&minus;file PAX_FILE</code></td>
<td style="border: 1px solid #ccc;">Path to the pax.Z file (required)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;m, &minus;&minus;metadata&minus;file METADATA_FILE</code></td>
<td style="border: 1px solid #ccc;">Path to the metadata.json file (required)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;g, &minus;&minus;tag TAG</code></td>
<td style="border: 1px solid #ccc;">Tag name for the release (required) e.g., DEV_mypackage_12345</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;r, &minus;&minus;repo REPO_URL</code></td>
<td style="border: 1px solid #ccc;">GitHub repository URL (optional, overrides metadata.json) e.g., <a href="https://github.com/zopencommunity/xzport.git" target="_blank">https://github.com/zopencommunity/xzport.git</a></td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;d, &minus;&minus;description TEXT</code></td>
<td style="border: 1px solid #ccc;">Description for the GitHub release (optional, from metadata.json &rsquo;summary&rsquo; if omitted)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;b, &minus;&minus;build&minus;line LINE</code></td>
<td style="border: 1px solid #ccc;">Build line (DEV or STABLE) (optional, from metadata.json &rsquo;buildline&rsquo; if omitted)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;t, &minus;&minus;github&minus;token TOKEN</code></td>
<td style="border: 1px solid #ccc;">GitHub Personal Access Token (required, or set GITHUB_TOKEN env var)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;o, &minus;&minus;github&minus;org ORG</code></td>
<td style="border: 1px solid #ccc;">GitHub Organization (default: zopencommunity)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;l, &minus;&minus;latest</code></td>
<td style="border: 1px solid #ccc;">Mark release as &rsquo;Latest&rsquo; (not pre&minus;release).</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;&minus;version</code></td>
<td style="border: 1px solid #ccc;">print version</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>Environment GITHUB_TOKEN</code></td>
<td style="border: 1px solid #ccc;">GitHub Personal Access Token (alternative to &minus;&minus;github&minus;token)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>Example:</code></td>
<td style="border: 1px solid #ccc;">zopen&minus;publish &minus;f &minus;p install/mypackage.zos.pax.Z &minus;m metadata.json &minus;g DEV_mypackage_12345 &minus;t &lt;your_github_token&gt; zopen&minus;publish &minus;v &minus;f &minus;p install/mypackage.zos.pax.Z &minus;m metadata.json &minus;r <a href="https://github.com/zopencommunity/override" target="_blank">https://github.com/zopencommunity/override</a>&minus;repo.git &minus;d &quot;My custom release description&quot; &minus;b DEV &minus;g REL&minus;1.0.1 &minus;t &lt;your_github_token&gt; &minus;l</td>
</tr>
</table>


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
