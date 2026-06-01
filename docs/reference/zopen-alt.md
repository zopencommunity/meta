<div v-pre class="man-page-content">

<div class="header-with-back"><div class="link" style="float: left;"><a href="./zopen-reference">← Previous</a></div><div class='link' style='float: right;'><a href='./zopen-audit'>Next →</a></div><div style="clear: both;"></div></div>


<h1 align="center">ZOPEN-ALT</h1>




<h2>NAME</h2>


<p style="margin-left:6%; margin-top: 1em">zopen-alt -
manual page for zopen-alt 0.8.5</p>

<h2>SYNOPSIS</h2>



<p style="margin-left:6%; margin-top: 1em">zopen-alt
[OPTION] [PACKAGE] [PARAMETERS]...</p>

<h2>DESCRIPTION</h2>


<p style="margin-left:6%; margin-top: 1em">zopen-alt is a
utility for zopen community to switch package versions for
currently installed packages.</p>

<h2>OPTIONS</h2>


<p style="margin-left:6%; margin-top: 1em">-h,
--help, -?</p>

<p style="margin-left:15%;">display this help and exit.</p>

<p style="margin-left:6%;">--select [PACKAGE]</p>

<p style="margin-left:15%;">select the active version for
PACKAGE from a list.</p>

<p style="margin-left:6%;">-s, --set
[PACKAGE] [VERSION]</p>

<p style="margin-left:15%;">set the active version for
PACKAGE to VERSION.</p>

<p style="margin-left:6%;">-v, --verbose</p>

<p style="margin-left:15%;">run in verbose mode.</p>

<p style="margin-left:6%;">--version</p>

<p style="margin-left:15%;">print version</p>

<h2>EXAMPLES</h2>


<p style="margin-left:6%; margin-top: 1em">zopen alt
foo</p>

<p style="margin-left:15%;">list the available alternatives
for package 'foo'</p>

<p style="margin-left:6%;">zopen alt --select foo</p>

<p style="margin-left:15%;">list the available alternatives
for package 'foo' and allow the user to select
an alternative version</p>

<p style="margin-left:6%;">zopen alt --set foo
foo-1.2.3.19700101_012345.zos</p>

<p style="margin-left:15%;">set the active version of
package 'foo' to version
foo-1.2.3.19700101_012345.zos if available</p>

<h2>AUTHOR</h2>


<p style="margin-left:6%; margin-top: 1em">Written by
contributors to the zopen community.
<a href="https://github.com/zopencommunity/meta/graphs/contributors" target="_blank">https://github.com/zopencommunity/meta/graphs/contributors</a></p>

<h2>REPORTING BUGS</h2>


<p style="margin-left:6%; margin-top: 1em">Report bugs at
https://github.com/zopencommunity/meta/issues</p>

<p style="margin-left:6%; margin-top: 1em">This is free
software: you are free to change and redistribute it under
the terms of the Apache License, Version 2.0.
<a href="https://www.apache.org/licenses/LICENSE-2.0.html" target="_blank">https://www.apache.org/licenses/LICENSE-2.0.html</a>
There is NO WARRANTY, to the extent permitted by law.</p>

</div>
