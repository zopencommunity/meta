<div v-pre class="man-page-content">

<div class="header-with-back">
  <div class="back-link">
    <a href="./zopen-reference">← Back</a>
  </div>
</div>

<h1 align="center">ZOPEN-ALT</h1>

<h2>NAME
<a name="NAME"></a>
</h2>

<p style="margin-left:11%; margin-top: 1em">zopen-alt
&minus; manual page for zopen-alt 0.8.4</p>

<h2>SYNOPSIS
<a name="SYNOPSIS"></a>
</h2>

<p style="margin-left:11%; margin-top: 1em"><b>zopen-alt</b>
[OPTION] [PACKAGE] [PARAMETERS]...</p>

<h2>DESCRIPTION
<a name="DESCRIPTION"></a>
</h2>

<p style="margin-left:11%; margin-top: 1em">zopen&minus;alt
is a utility for zopen community to switch package versions
for currently installed packages.</p>

<h2>OPTIONS
<a name="OPTIONS"></a>
</h2>

<p style="margin-left:11%; margin-top: 1em"><b>&minus;h</b>,
<b>&minus;&minus;help</b>, &minus;?</p>

<p style="margin-left:22%;">display this help and exit.</p>

<p style="margin-left:11%;"><b>&minus;&minus;select</b>
[PACKAGE]</p>

<p style="margin-left:22%;">select the active version for
PACKAGE from a list.</p>

<p style="margin-left:11%;"><b>&minus;s</b>,
<b>&minus;&minus;set</b> [PACKAGE] [VERSION]</p>

<p style="margin-left:22%;">set the active version for
PACKAGE to VERSION.</p>

<p style="margin-left:11%;"><b>&minus;v</b>,
<b>&minus;&minus;verbose</b></p>

<p style="margin-left:22%;">run in verbose mode.</p>

<p style="margin-left:11%;"><b>&minus;&minus;version</b></p>

<p style="margin-left:22%;">print version</p>

<h2>EXAMPLES
<a name="EXAMPLES"></a>
</h2>

<p style="margin-left:11%; margin-top: 1em">zopen alt
foo</p>

<p style="margin-left:22%;">list the available alternatives
for package &rsquo;foo&rsquo;</p>

<p style="margin-left:11%;">zopen alt &minus;&minus;select
foo</p>

<p style="margin-left:22%;">list the available alternatives
for package &rsquo;foo&rsquo; and allow the user to select
an alternative version</p>

<p style="margin-left:11%;">zopen alt &minus;&minus;set foo
foo&minus;1.2.3.19700101_012345.zos</p>

<p style="margin-left:22%;">set the active version of
package &rsquo;foo&rsquo; to version
foo&minus;1.2.3.19700101_012345.zos if available</p>

<h2>AUTHOR
<a name="AUTHOR"></a>
</h2>

<p style="margin-left:11%; margin-top: 1em">Written by
contributors to the zopen community.
<a href="https://github.com/zopencommunity/meta/graphs/contributors" target="_blank">https://github.com/zopencommunity/meta/graphs/contributors</a></p>

<h2>REPORTING BUGS
<a name="REPORTING BUGS"></a>
</h2>

<p style="margin-left:11%; margin-top: 1em">Report bugs at
https://github.com/zopencommunity/meta/issues</p>

<p style="margin-left:11%; margin-top: 1em">This is free
software: you are free to change and redistribute it under
the terms of the Apache License, Version 2.0.
<a href="https://www.apache.org/licenses/LICENSE-2.0.html" target="_blank">https://www.apache.org/licenses/LICENSE-2.0.html</a>
There is NO WARRANTY, to the extent permitted by law.</p>

</div>
