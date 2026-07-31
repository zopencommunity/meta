<div v-pre class="man-page-content">

<div class="header-with-back">
  <div class="back-link">
    <a href="./zopen-reference">← Back</a>
  </div>
</div>

<h1 align="center">ZOPEN-CREATE-REPO</h1>

<h2>NAME</h2>

<p style="margin-left:11%; margin-top: 1em">zopen-create-repo
&minus; manual page for zopen-create-repo 0.8.4</p>

<h2>SYNOPSIS</h2>

<p style="margin-left:11%; margin-top: 1em">zopen-create-repo
[OPTION] -n PORT_NAME</p>

<h2>DESCRIPTION</h2>

<p style="margin-left:11%; margin-top: 1em">zopen&minus;create&minus;repo
&minus; Create a new port repository in zopencommunity.</p>

<p style="margin-left:11%; margin-top: 1em">NOTE: This
script is intended for use by core contributors only.</p>

<p style="margin-left:22%; margin-top: 1em">You must have
admin permissions in the zopencommunity organization.</p>

<h2>OPTIONS</h2>

<p style="margin-left:11%; margin-top: 1em">&minus;h,
&minus;&minus;help</p>

<p style="margin-left:22%;">print this help</p>

<p style="margin-left:11%;">&minus;v,
&minus;&minus;verbose</p>

<p style="margin-left:22%;">run in verbose mode.</p>

<p style="margin-left:11%;">&minus;n,
&minus;&minus;name PORT_NAME</p>

<p style="margin-left:22%;">Name of the port (required)
e.g., curl, openssl</p>

<p style="margin-left:11%;">&minus;d,
&minus;&minus;description TEXT</p>

<p style="margin-left:22%;">Repository description
(optional) Default: &rsquo;zopen port of
PORT_NAME&rsquo;</p>

<p style="margin-left:11%;">&minus;u,
&minus;&minus;user USERNAME</p>

<p style="margin-left:22%;">GitHub username to assign as
admin (optional)</p>

<p style="margin-left:11%;">&minus;o,
&minus;&minus;github&minus;org ORG</p>

<p style="margin-left:22%;">GitHub Organization (default:
zopencommunity)</p>

<p style="margin-left:11%;">&minus;t,
&minus;&minus;github&minus;token TOKEN</p>

<p style="margin-left:22%;">GitHub Personal Access Token
(required, or set GITHUB_TOKEN env var)</p>

<p style="margin-left:11%;">&minus;&minus;version</p>

<p style="margin-left:22%;">print version</p>

<p style="margin-left:11%; margin-top: 1em">Environment
GITHUB_TOKEN</p>

<p style="margin-left:22%;">GitHub Personal Access Token
(alternative to &minus;&minus;github&minus;token)</p>

<p style="margin-left:11%; margin-top: 1em">Example:</p>

<p style="margin-left:22%;">zopen&minus;create&minus;repo
&minus;n curl zopen&minus;create&minus;repo
&minus;v &minus;n pv &minus;d &rsquo;Pipe
Viewer &minus; monitor data through a pipeline&rsquo;
zopen&minus;create&minus;repo &minus;v &minus;n
openssl &minus;u johndoe &minus;t
&lt;your_github_token&gt;</p>

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
