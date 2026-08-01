---
prev:
  text: 'zopen'
  link: '/reference/zopen'
next:
  text: 'zopen-audit'
  link: '/reference/zopen-audit'
---
<div v-pre class="man-page-content">
<div class="header-with-back">
  <div class="home-link">
    <a href="./zopen-reference">🏠 Home</a>
  </div>
  <div class="nav-buttons">
    <a href="./zopen" class="nav-link">← Prev</a>
    <a href="./zopen-audit" class="nav-link">Next →</a>
  </div>
</div>

<h1 align="center">ZOPEN-ALT</h1>

<h2>NAME</h2>

<p style="margin-left:11%; margin-top: 1em">zopen-alt
&minus; manual page for zopen-alt 0.8.4</p>

<h2>SYNOPSIS</h2>

<p style="margin-left:11%; margin-top: 1em">zopen-alt
[OPTION] [PACKAGE] [PARAMETERS]...</p>

<h2>DESCRIPTION</h2>

<p style="margin-left:11%; margin-top: 1em">zopen&minus;alt
is a utility for zopen community to switch package versions
for currently installed packages.</p>

<h2>OPTIONS</h2>

<table border="1" cellpadding="10" cellspacing="0" style="width:100%; border-collapse:collapse;">
<tr style="background-color:#f0f0f0;">
<th style="text-align:left; border: 1px solid #ccc;">Option</th>
<th style="text-align:left; border: 1px solid #ccc;">Description</th>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;h, &minus;&minus;help, &minus;?</code></td>
<td style="border: 1px solid #ccc;">display this help and exit.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;&minus;select [PACKAGE]</code></td>
<td style="border: 1px solid #ccc;">select the active version for PACKAGE from a list.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;s, &minus;&minus;set [PACKAGE] [VERSION]</code></td>
<td style="border: 1px solid #ccc;">set the active version for PACKAGE to VERSION.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;v, &minus;&minus;verbose</code></td>
<td style="border: 1px solid #ccc;">run in verbose mode.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;&minus;version</code></td>
<td style="border: 1px solid #ccc;">print version</td>
</tr>
</table>

<h2>EXAMPLES</h2>

<table border="1" cellpadding="10" cellspacing="0" style="width:100%; border-collapse:collapse;">
<tr style="background-color:#f0f0f0;">
<th style="text-align:left; border: 1px solid #ccc;">Option</th>
<th style="text-align:left; border: 1px solid #ccc;">Description</th>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>zopen alt foo</code></td>
<td style="border: 1px solid #ccc;">list the available alternatives for package &rsquo;foo&rsquo;</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>zopen alt &minus;&minus;select foo</code></td>
<td style="border: 1px solid #ccc;">list the available alternatives for package &rsquo;foo&rsquo; and allow the user to select an alternative version</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>zopen alt &minus;&minus;set foo foo&minus;1.2.3.19700101_012345.zos</code></td>
<td style="border: 1px solid #ccc;">set the active version of package &rsquo;foo&rsquo; to version foo&minus;1.2.3.19700101_012345.zos if available</td>
</tr>
</table>

<h2>AUTHOR</h2>

<p style="margin-left:11%; margin-top: 1em">Written by
contributors to the zopen community.
<a href="https://github.com/zopencommunity/meta/graphs/contributors" target="_blank">https://github.com/zopencommunity/meta/graphs/contributors</a></p>

<h2>REPORTING BUGS</h2>

<p style="margin-left:11%; margin-top: 1em">Report bugs at
<a href="https://github.com/zopencommunity/meta/issues" target="_blank">https://github.com/zopencommunity/meta/issues</a></p>

<p style="margin-left:11%; margin-top: 1em">This is free
software: you are free to change and redistribute it under
the terms of the Apache License, Version 2.0.
<a href="https://www.apache.org/licenses/LICENSE-2.0.html" target="_blank">https://www.apache.org/licenses/LICENSE-2.0.html</a>
There is NO WARRANTY, to the extent permitted by law.</p>

</div>
