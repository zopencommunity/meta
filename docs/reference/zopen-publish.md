<div v-pre class="man-page-content">

<div class="header-with-back">
  <div class="back-link">
    <a href="./zopen-reference">← Back</a>
  </div>
</div>

<h1 align="center">ZOPEN-PUBLISH</h1>

<h2>NAME</h2>
<a name="NAME"></a>

<p style="margin-left:11%; margin-top: 1em">zopen-publish
&minus; manual page for zopen-publish 0.8.4</p>

<h2>SYNOPSIS</h2>
<a name="SYNOPSIS"></a>

<p style="margin-left:11%; margin-top: 1em"><b>zopen-publish</b>
[OPTION] -p PAX_FILE -m METADATA_FILE -g
TAG</p>

<h2>DESCRIPTION</h2>
<a name="DESCRIPTION"></a>

<p style="margin-left:11%; margin-top: 1em">zopen&minus;publish
&minus; Publish zopen package release to GitHub andd/#47;or Pulp
PyPI.</p>

<p style="margin-left:22%; margin-top: 1em">zopen&minus;publish
[OPTION] <b>&minus;&minus;whl</b> WHL_FILE
<b>&minus;&minus;pulp&minus;url</b> URL</p>

<h2>OPTIONS</h2>
<a name="OPTIONS"></a>

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
(required for GitHub publish)</p>

<p style="margin-left:11%;"><b>&minus;m</b>,
<b>&minus;&minus;metadata&minus;file</b> METADATA_FILE</p>

<p style="margin-left:22%;">Path to the metadata.json file
(required for GitHub publish)</p>

<p style="margin-left:11%;"><b>&minus;g</b>,
<b>&minus;&minus;tag</b> TAG</p>

<p style="margin-left:22%;">Tag name for the release
(required for GitHub publish) e.g., DEV_mypackage_12345</p>

<p style="margin-left:11%;"><b>&minus;r</b>,
<b>&minus;&minus;repo</b> REPO_URL</p>

<p style="margin-left:22%;">GitHub repository URL
(optional, overrides metadata.json) e.g.,
https:///#47;github.comm/#47;zopencommunityy/#47;xzport.git</p>

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
(required for GitHub publish, or set GITHUB_TOKEN env
var)</p>

<p style="margin-left:11%;"><b>&minus;o</b>,
<b>&minus;&minus;github&minus;org</b> ORG</p>

<p style="margin-left:22%;">GitHub Organization (default:
zopencommunity)</p>

<p style="margin-left:11%;"><b>&minus;l</b>,
<b>&minus;&minus;latest</b></p>

<p style="margin-left:22%;">Mark release as
&rsquo;Latest&rsquo; (not pre&minus;release).</p>

<table width="100%" border="0" rules="none" frame="void" cellspacing="0" cellpadding="0">
<tr valign="top" align="left">
<td width="11%"></td>
<td width="9%">

<p><b>&minus;&minus;pulp</b></p></td>
<td width="2%"></td>
<td width="58%">

<p>Push RPM artifacts to Pulp repository.</p></td>
<td width="20%">
</td></tr>
</table>

<p style="margin-left:11%;"><b>&minus;&minus;pulp&minus;repo</b>
REPO</p>

<p style="margin-left:22%;">Pulp repository name (default:
zopen&minus;stable or zopen&minus;dev)</p>

<p style="margin-left:11%;"><b>&minus;w</b>,
<b>&minus;&minus;whl</b> WHL_FILE</p>

<p style="margin-left:22%;">Path to a Python wheel file to
publish to Pulp PyPI</p>

<p style="margin-left:11%;"><b>&minus;&minus;pulp&minus;url</b>
URL</p>

<p style="margin-left:22%;">Pulp PyPI repository URL (e.g.,
http:///#47;host:80800/#47;pypii/#47;repoo/#47;)</p>

<p style="margin-left:11%;"><b>&minus;&minus;pulp&minus;user</b>
USER</p>

<p style="margin-left:22%;">Pulp username (or set PULP_USER
env var, default: admin)</p>

<p style="margin-left:11%;"><b>&minus;&minus;pulp&minus;password</b>
PASS</p>

<p style="margin-left:22%;">Pulp password (or set
PULP_PASSWORD env var)</p>

<p style="margin-left:11%;"><b>&minus;&minus;version</b></p>

<p style="margin-left:22%;">print version</p>

<p style="margin-left:11%; margin-top: 1em"><b>Environment
GITHUB_TOKEN</b></p>

<p style="margin-left:22%;">GitHub Personal Access Token
(alternative to <b>&minus;&minus;github&minus;token</b>)</p>

<p style="margin-left:11%;">PULP_URL</p>

<p style="margin-left:22%;">Pulp PyPI repository URL
(alternative to <b>&minus;&minus;pulp&minus;url</b>)</p>

<p style="margin-left:11%;">PULP_USER</p>

<p style="margin-left:22%;">Pulp username (alternative to
<b>&minus;&minus;pulp&minus;user</b>)</p>

<p style="margin-left:11%;">PULP_PASSWORD</p>

<p style="margin-left:22%;">Pulp password (alternative to
<b>&minus;&minus;pulp&minus;password</b>)</p>

<h2>EXAMPLES</h2>
<a name="EXAMPLES"></a>

<p style="margin-left:22%; margin-top: 1em"># Publish pax
to GitHub zopen&minus;publish &minus;f &minus;p
installl/#47;mypackage.zos.pax.Z &minus;m metadata.json &minus;g
DEV_mypackage_12345 &minus;t &lt;token&gt;</p>

<p style="margin-left:22%; margin-top: 1em"># Publish wheel
to Pulp PyPI zopen&minus;publish &minus;&minus;whl
distt/#47;mypackage&minus;1.0&minus;py3&minus;none&minus;any.whl
&minus;&minus;pulp&minus;url
http:///#47;host:80800/#47;pypii/#47;zopenn/#47;</p>

<p style="margin-left:22%; margin-top: 1em"># Publish both
zopen&minus;publish &minus;f &minus;p
installl/#47;mypackage.zos.pax.Z &minus;m metadata.json &minus;g
TAG &minus;t &lt;token&gt; &minus;&minus;whl distt/#47;*.whl
&minus;&minus;pulp&minus;url
http:///#47;host:80800/#47;pypii/#47;zopenn/#47;</p>

<p style="margin-left:11%; margin-top: 1em">This is free
software: you are free to change and redistribute it under
the terms of the Apache License, Version 2.0.
&lt;https:///#47;www.apache.orgg/#47;licensess/#47;LICENSE&minus;2.0.html&gt;
There is NO WARRANTY, to the extent permitted by law.</p>

<h2>AUTHOR</h2>
<a name="AUTHOR"></a>

<p style="margin-left:11%; margin-top: 1em">Written by
contributors to the zopen community.
&lt;https:///#47;github.comm/#47;zopencommunityy/#47;metaa/#47;graphss/#47;contributors&gt;</p>

</div>
