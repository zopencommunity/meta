<div v-pre class="man-page-content">

<div class="header-with-back"><div class="link" style="float: left;"><a href="./zopen-create-cicd-job">← Previous</a></div><div class='link' style='float: right;'><a href='./zopen-diagnostics'>Next →</a></div><div style="clear: both;"></div></div>


<h1 align="center">ZOPEN-CREATE-REPO</h1>




<h2>NAME</h2>



<p style="margin-left:6%; margin-top: 1em">zopen-create-repo
- manual page for zopen-create-repo 0.8.5</p>

<h2>SYNOPSIS</h2>



<p style="margin-left:6%; margin-top: 1em">zopen-create-repo
[OPTION] -n PORT_NAME</p>

<h2>DESCRIPTION</h2>



<p style="margin-left:6%; margin-top: 1em">zopen-create-repo
- Create a new port repository in zopencommunity.</p>

<p style="margin-left:6%; margin-top: 1em">NOTE: This
script is intended for use by core contributors only.</p>

<p style="margin-left:15%; margin-top: 1em">You must have
admin permissions in the zopencommunity organization.</p>

<h2>OPTIONS</h2>


<p style="margin-left:6%; margin-top: 1em">-h,
--help</p>

<p style="margin-left:15%;">print this help</p>

<p style="margin-left:6%;">-v, --verbose</p>

<p style="margin-left:15%;">run in verbose mode.</p>

<p style="margin-left:6%;">-n, --name
PORT_NAME</p>

<p style="margin-left:15%;">Name of the port (required)
e.g., curl, openssl</p>

<p style="margin-left:6%;">-d, --description
TEXT</p>

<p style="margin-left:15%;">Repository description
(optional) Default: 'zopen port of
PORT_NAME'</p>

<p style="margin-left:6%;">-u, --user
USERNAME</p>

<p style="margin-left:15%;">GitHub username to assign as
admin (optional)</p>

<p style="margin-left:6%;">-o, --github-org
ORG</p>

<p style="margin-left:15%;">GitHub Organization (default:
zopencommunity)</p>

<p style="margin-left:6%;">-t, --github-token
TOKEN</p>

<p style="margin-left:15%;">GitHub Personal Access Token
(required, or set GITHUB_TOKEN env var)</p>

<p style="margin-left:6%;">--version</p>

<p style="margin-left:15%;">print version</p>

<h3>Environment Variables:</h3>



<p style="margin-left:6%; margin-top: 1em">GITHUB_TOKEN</p>

<p style="margin-left:15%;">GitHub Personal Access Token
(alternative to --github-token)</p>

<h3>Example:</h3>



<p style="margin-left:15%; margin-top: 1em">zopen-create-repo
-n curl zopen-create-repo -v -n pv -d
'Pipe Viewer - monitor data through a pipeline'
zopen-create-repo -v -n openssl -u johndoe
-t &lt;your_github_token&gt;</p>

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
