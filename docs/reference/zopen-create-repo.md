<div v-pre class="man-page-content">

<div class="header-with-back"><div class="link"><a href="./zopen-create-cicd-job">← Previous</a></div><div class='link'><a href='./zopen-diagnostics'>Next →</a></div></div>

<h1 align="center">ZOPEN-CREATE-REPO</h1>












<h2>NAME</h2>



<table><tr><td style="width: 25%; vertical-align: top;"><b>zopen-create-repo
- manual page for zopen-create-repo 0.8.5

<h2>SYNOPSIS</h2>



<b>zopen-create-repo</b>
[<i>OPTION</i>] <i>-n PORT_NAME</i>

<h2>DESCRIPTION</h2>



zopen-create-repo
- Create a new port repository in zopencommunity.

NOTE: This
script is intended for use by core contributors only.</b></td><td style="vertical-align: top;">You must have
admin permissions in the zopencommunity organization.</td></tr></table>

<h2>OPTIONS</h2>



<table><tr><td style="width: 25%; vertical-align: top;"><b>-h</b>,
<b>--help</b></td><td style="vertical-align: top;">print this help</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-v</b>,
<b>--verbose</b></td><td style="vertical-align: top;">run in verbose mode.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-n</b>,
<b>--name</b> PORT_NAME</td><td style="vertical-align: top;">Name of the port (required)
e.g., curl, openssl</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-d</b>,
<b>--description</b> TEXT</td><td style="vertical-align: top;">Repository description
(optional) Default: 'zopen port of
PORT_NAME'</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-u</b>,
<b>--user</b> USERNAME</td><td style="vertical-align: top;">GitHub username to assign as
admin (optional)</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-o</b>,
<b>--github-org</b> ORG</td><td style="vertical-align: top;">GitHub Organization (default:
zopencommunity)</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-t</b>,
<b>--github-token</b> TOKEN</td><td style="vertical-align: top;">GitHub Personal Access Token
(required, or set GITHUB_TOKEN env var)</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--version</b></td><td style="vertical-align: top;">print version</td></tr></table>

<h3>Environment Variables:</h3>



<table><tr><td style="width: 25%; vertical-align: top;"><b>GITHUB_TOKEN</b></td><td style="vertical-align: top;">GitHub Personal Access Token
(alternative to <b>--github-token</b>)</td></tr></table>

<h3>Example:</h3>



<p style="margin-left:18%; margin-top: 1em">zopen-create-repo
<b>-n</b> curl zopen-create-repo
<b>-v -n</b> pv <b>-d</b> 'Pipe
Viewer - monitor data through a pipeline'
zopen-create-repo <b>-v -n</b>
openssl <b>-u</b> johndoe <b>-t</b>
<code>&lt;your_github_token&gt;</code></p>

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
