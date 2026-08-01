<div v-pre class="man-page-content">
<h1 align="center">ZOPEN-CREATE-REPO</h1>

<h2>NAME</h2>

<p style="margin-left:11%; margin-top: 1em">zopen-create-repo
&minus; manual page for zopen-create-repo 0.8.4</p>

<h2>SYNOPSIS</h2>

<p style="margin-left:11%; margin-top: 1em">zopen-create-repo
[OPTION] -n PORT_NAME</p>

<h2>DESCRIPTION</h2>

<p style="margin-left:11%; margin-top: 1em">zopen&minus;create&minus;repo &minus; Create a new port repository in zopencommunity.</p>

<p style="margin-left:11%; margin-top: 1em">NOTE: This script is intended for use by core contributors only. You must have admin permissions in the zopencommunity organization.</p>

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
<td style="border: 1px solid #ccc;"><code>&minus;n, &minus;&minus;name PORT_NAME</code></td>
<td style="border: 1px solid #ccc;">Name of the port (required) e.g., curl, openssl</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;d, &minus;&minus;description TEXT</code></td>
<td style="border: 1px solid #ccc;">Repository description (optional) Default: &rsquo;zopen port of PORT_NAME&rsquo;</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;u, &minus;&minus;user USERNAME</code></td>
<td style="border: 1px solid #ccc;">GitHub username to assign as admin (optional)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;o, &minus;&minus;github&minus;org ORG</code></td>
<td style="border: 1px solid #ccc;">GitHub Organization (default: zopencommunity)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;t, &minus;&minus;github&minus;token TOKEN</code></td>
<td style="border: 1px solid #ccc;">GitHub Personal Access Token (required, or set GITHUB_TOKEN env var)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;&minus;version</code></td>
<td style="border: 1px solid #ccc;">print version</td>
</tr>
</table>

<h2>ENVIRONMENT</h2>

<table border="1" cellpadding="10" cellspacing="0" style="width:100%; border-collapse:collapse;">
<tr style="background-color:#f0f0f0;">
<th style="text-align:left; border: 1px solid #ccc;">Variable</th>
<th style="text-align:left; border: 1px solid #ccc;">Description</th>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>GITHUB_TOKEN</code></td>
<td style="border: 1px solid #ccc;">GitHub Personal Access Token (alternative to &minus;&minus;github&minus;token)</td>
</tr>
</table>

<h2>EXAMPLES</h2>

<table border="1" cellpadding="10" cellspacing="0" style="width:100%; border-collapse:collapse;">
<tr style="background-color:#f0f0f0;">
<th style="text-align:left; border: 1px solid #ccc;">Command</th>
<th style="text-align:left; border: 1px solid #ccc;">Description</th>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>zopen&minus;create&minus;repo &minus;n curl</code></td>
<td style="border: 1px solid #ccc;">create a new port repository for curl</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>zopen&minus;create&minus;repo &minus;v &minus;n pv &minus;d &rsquo;Pipe Viewer &minus; monitor data through a pipeline&rsquo;</code></td>
<td style="border: 1px solid #ccc;">create a pv repository with a custom description</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>zopen&minus;create&minus;repo &minus;v &minus;n openssl &minus;u johndoe &minus;t &lt;your_github_token&gt;</code></td>
<td style="border: 1px solid #ccc;">create an openssl repository, assigning johndoe as admin</td>
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
