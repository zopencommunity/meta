---
prev:
  text: 'zopen-build'
  link: '/reference/zopen-build'
next:
  text: 'zopen-compare-versions'
  link: '/reference/zopen-compare-versions'
---
<div v-pre class="man-page-content">
<div class="header-with-back">
  <div class="home-link">
    <a href="./zopen-reference">🏠 Home</a>
  </div>
  <div class="nav-buttons">
    <a href="./zopen-build" class="nav-link">← Prev</a>
    <a href="./zopen-compare-versions" class="nav-link">Next →</a>
  </div>
</div>

<h1 align="center">ZOPEN-CLEAN</h1>

<h2>NAME</h2>

<p style="margin-left:11%; margin-top: 1em">zopen-clean
&minus; manual page for zopen-clean 0.8.4</p>

<h2>SYNOPSIS</h2>

<p style="margin-left:11%; margin-top: 1em">zopen-clean
[OPTION] [PACKAGE]</p>

<h2>DESCRIPTION</h2>

<p style="margin-left:11%; margin-top: 1em">zopen&minus;clean
is a utility for zopen community to remove unneeded
resources from the system to save space and prevent clutter.</p>

<h2>OPTIONS</h2>

<table border="1" cellpadding="10" cellspacing="0" style="width:100%; border-collapse:collapse;">
<tr style="background-color:#f0f0f0;">
<th style="text-align:left; border: 1px solid #ccc;">Option</th>
<th style="text-align:left; border: 1px solid #ccc;">Description</th>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;&minus;deep</code></td>
<td style="border: 1px solid #ccc;">deep clean &minus; run all cleanup operations.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;&minus;all</code></td>
<td style="border: 1px solid #ccc;">apply cleanup command to all applicable packages.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;c, &minus;&minus;cache [PACKAGE ...]</code></td>
<td style="border: 1px solid #ccc;">cleans the downloaded package cache; packages will be re&minus;downloaded if needed.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;d, &minus;&minus;dangling</code></td>
<td style="border: 1px solid #ccc;">removes dangling symlinks from the zopen file system in case of issues during package maintenance.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;h, &minus;&minus;help, &minus;?</code></td>
<td style="border: 1px solid #ccc;">display this help and exit.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;m, &minus;&minus;metadata</code></td>
<td style="border: 1px solid #ccc;">cleans and refreshes the metadata for zopen.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;u, &minus;&minus;unused [PACKAGE ...]</code></td>
<td style="border: 1px solid #ccc;">remove versions of PACKAGEs that are available as alternatives, leaving only the currently active version.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;&minus;nostats</code></td>
<td style="border: 1px solid #ccc;">do not output statistics from the clean operation(s).</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;v, &minus;&minus;verbose</code></td>
<td style="border: 1px solid #ccc;">run in verbose mode.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;&minus;version</code></td>
<td style="border: 1px solid #ccc;">print version.</td>
</tr>
</table>

<h2>EXAMPLES</h2>

<table border="1" cellpadding="10" cellspacing="0" style="width:100%; border-collapse:collapse;">
<tr style="background-color:#f0f0f0;">
<th style="text-align:left; border: 1px solid #ccc;">Command</th>
<th style="text-align:left; border: 1px solid #ccc;">Description</th>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>zopen clean &minus;c</code></td>
<td style="border: 1px solid #ccc;">clear the package download cache</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>zopen clean &minus;d</code></td>
<td style="border: 1px solid #ccc;">analyse the zopen file system and remove dangling symlinks</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>zopen clean &minus;u [PACKAGE]</code></td>
<td style="border: 1px solid #ccc;">remove unused versions for PACKAGE</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>zopen clean &minus;u &minus;&minus;all</code></td>
<td style="border: 1px solid #ccc;">remove all unused packages within the zopen environment</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>zopen clean &minus;&minus;deep</code></td>
<td style="border: 1px solid #ccc;">run all cleanup operations</td>
</tr>
</table>

<h2>AUTHOR</h2>

<p style="margin-left:11%; margin-top: 1em">Written by
contributors to the zopen community.
<a href="https://github.com/zopencommunity/meta/graphs/contributors" target="_blank">https://github.com/zopencommunity/meta/graphs/contributors</a></p>

<h2>REPORTING BUGS</h2>

<p style="margin-left:11%; margin-top: 1em">Report bugs at
<a href="https://github.com/zopencommunity/meta/issues." target="_blank">https://github.com/zopencommunity/meta/issues.</a></p>

<p style="margin-left:11%; margin-top: 1em">This is free
software: you are free to change and redistribute it under
the terms of the Apache License, Version 2.0.
<a href="https://www.apache.org/licenses/LICENSE-2.0.html" target="_blank">https://www.apache.org/licenses/LICENSE-2.0.html</a>
There is NO WARRANTY, to the extent permitted by law.</p>

</div>
