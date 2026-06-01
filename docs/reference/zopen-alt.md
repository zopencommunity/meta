<div v-pre class="man-page-content">

<div class="header-with-back"><div class="link"><a href="./zopen-reference">← Previous</a></div><div class='link'><a href='./zopen-audit'>Next →</a></div></div>

<h1 align="center">ZOPEN-ALT</h1>












<h2>NAME</h2>


<table><tr><td style="width: 25%; vertical-align: top;"><b>zopen-alt
- manual page for zopen-alt 0.8.5

<h2>SYNOPSIS</h2>



<b>zopen-alt</b>
[<i>OPTION</i>] [<i>PACKAGE</i>] [<i>PARAMETERS</i>]...

<h2>DESCRIPTION</h2>


zopen-alt
is a utility for zopen community to switch package versions
for currently installed packages.

<h2>OPTIONS</h2>



<b>-h</b>,
<b>--help</b>, -?</b></td><td style="vertical-align: top;">display this help and exit.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--select</b>
[PACKAGE]</td><td style="vertical-align: top;">select the active version for
PACKAGE from a list.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-s</b>,
<b>--set</b> [PACKAGE] [VERSION]</td><td style="vertical-align: top;">set the active version for
PACKAGE to VERSION.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-v</b>,
<b>--verbose</b></td><td style="vertical-align: top;">run in verbose mode.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--version</b></td><td style="vertical-align: top;">print version</td></tr></table>

<h2>EXAMPLES</h2>


<table><tr><td style="width: 25%; vertical-align: top;"><b>zopen alt
foo</b></td><td style="vertical-align: top;">list the available alternatives
for package 'foo'</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>zopen alt --select
foo</b></td><td style="vertical-align: top;">list the available alternatives
for package 'foo' and allow the user to select
an alternative version</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>zopen alt --set foo
foo-1.2.3.19700101_012345.zos</b></td><td style="vertical-align: top;">set the active version of
package 'foo' to version
foo-1.2.3.19700101_012345.zos if available</td></tr></table>

<h2>AUTHOR</h2>


<p style="margin-left:9%; margin-top: 1em">Written by
contributors to the zopen community.
<a href="https://github.com/zopencommunity/meta/graphs/contributors" target="_blank">https://github.com/zopencommunity/meta/graphs/contributors</a></p>

<h2>REPORTING BUGS</h2>


<p style="margin-left:9%; margin-top: 1em">Report bugs at
https://github.com/zopencommunity/meta/issues</p>

<p style="margin-left:9%; margin-top: 1em">This is free
software: you are free to change and redistribute it under
the terms of the Apache License, Version 2.0.
<a href="https://www.apache.org/licenses/LICENSE-2.0.html" target="_blank">https://www.apache.org/licenses/LICENSE-2.0.html</a>
<br>
There is NO WARRANTY, to the extent permitted by law.</p>

</div>
