<div v-pre class="man-page-content">

<div class="header-with-back">
  <div class="back-link">
    <a href="./zopen-reference">← Back</a>
  </div>
</div>

<h1 align="center">ZOPEN-CREATE-REPO</h1>

<h2>NAME</h2>
<a name="NAME"></a>

<p style="margin-left:11%; margin-top: 1em">zopen-create-repo
&minus; manual page for zopen-create-repo 0.8.4</p>

<h2>SYNOPSIS</h2>
<a name="SYNOPSIS"></a>

<p style="margin-left:11%; margin-top: 1em"><b>zopen-create-repo</b>
[OPTION] -n PORT_NAME</p>

<h2>DESCRIPTION</h2>
<a name="DESCRIPTION"></a>

<p style="margin-left:11%; margin-top: 1em">zopen&minus;create&minus;repo
&minus; Create a new port repository in zopencommunity.</p>

<p style="margin-left:11%; margin-top: 1em">NOTE: This
script is intended for use by core contributors only.</p>

<p style="margin-left:22%; margin-top: 1em">You must have
admin permissions in the zopencommunity organization.</p>

<h2>OPTIONS</h2>
<a name="OPTIONS"></a>

<p style="margin-left:11%; margin-top: 1em"><b>&minus;h</b>,
<b>&minus;&minus;help</b></p>

<p style="margin-left:22%;">print this help</p>

<p style="margin-left:11%;"><b>&minus;v</b>,
<b>&minus;&minus;verbose</b></p>

<p style="margin-left:22%;">run in verbose mode.</p>

<p style="margin-left:11%;"><b>&minus;n</b>,
<b>&minus;&minus;name</b> PORT_NAME</p>

<p style="margin-left:22%;">Name of the port (required)
e.g., curl, openssl</p>

<p style="margin-left:11%;"><b>&minus;d</b>,
<b>&minus;&minus;description</b> TEXT</p>

<p style="margin-left:22%;">Repository description
(optional) Default: &rsquo;zopen port of
PORT_NAME&rsquo;</p>

<p style="margin-left:11%;"><b>&minus;u</b>,
<b>&minus;&minus;user</b> USERNAME</p>

<p style="margin-left:22%;">GitHub username to assign as
admin (optional)</p>

<p style="margin-left:11%;"><b>&minus;o</b>,
<b>&minus;&minus;github&minus;org</b> ORG</p>

<p style="margin-left:22%;">GitHub Organization (default:
zopencommunity)</p>

<p style="margin-left:11%;"><b>&minus;t</b>,
<b>&minus;&minus;github&minus;token</b> TOKEN</p>

<p style="margin-left:22%;">GitHub Personal Access Token
(required, or set GITHUB_TOKEN env var)</p>

<p style="margin-left:11%;"><b>&minus;&minus;version</b></p>

<p style="margin-left:22%;">print version</p>

<p style="margin-left:11%; margin-top: 1em"><b>Environment
GITHUB_TOKEN</b></p>

<p style="margin-left:22%;">GitHub Personal Access Token
(alternative to <b>&minus;&minus;github&minus;token</b>)</p>

<p style="margin-left:11%; margin-top: 1em"><b>Example:</b></p>

<p style="margin-left:22%;">zopen&minus;create&minus;repo
<b>&minus;n</b> curl zopen&minus;create&minus;repo
<b>&minus;v &minus;n</b> pv <b>&minus;d</b> &rsquo;Pipe
Viewer &minus; monitor data through a pipeline&rsquo;
zopen&minus;create&minus;repo <b>&minus;v &minus;n</b>
openssl <b>&minus;u</b> johndoe <b>&minus;t</b>
&lt;your_github_token&gt;</p>

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
