<div v-pre class="man-page-content">

<div class="header-with-back"><div class="link"><a href="./zopen-build">← Previous</a></div><div class='link'><a href='./zopen-compare-versions'>Next →</a></div></div>

<h1 align="center">ZOPEN-CLEAN</h1>












<h2>NAME</h2>


<table><tr><td style="width: 25%; vertical-align: top;"><b>zopen-clean
- manual page for zopen-clean 0.8.5

<h2>SYNOPSIS</h2>



<b>zopen-clean</b>
[<i>OPTION</i>] [<i>PACKAGE</i>]

<h2>DESCRIPTION</h2>



zopen-clean
is a utility for zopen community to remove uneeded resources
from the system to save space and prevent clutter.

<h2>OPTIONS</h2>


<table>
<tr><td style="width: 25%; vertical-align: top;"><b>--deep</b></td><td style="vertical-align: top;">deep clean - run all
cleanup operations</td></tr>
<tr><td style="width: 25%; vertical-align: top;"><b>--all</b></td><td style="vertical-align: top;">apply cleanup command to all applicable packages.</td></tr>
</table>

<b>-c</b>,
<b>--cache</b></td><td style="vertical-align: top;">[PACKAGE ...] cleans the
downloaded package cache; packages will be
re-downloaded if needed.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-d</b>,
<b>--dangling</b></td><td style="vertical-align: top;">removes dangling symlinks from
the zopen file system in case of issues during package
maintenance.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-h</b>,
<b>--help</b>, -?</td><td style="vertical-align: top;">display this help and exit.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-m</b>,
<b>--metadata</b></td><td style="vertical-align: top;">cleans and refreshes the
metadata for zopen.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-u</b>,
<b>--unused</b> [PACKAGE ...]</td><td style="vertical-align: top;">remove versions of PACKAGEs
that are available as alternatives, leaving only the
currently active version.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--nostats</b></td><td style="vertical-align: top;">do not output statistics from
the clean operation(s)</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-v</b>,
<b>--verbose</b></td><td style="vertical-align: top;">run in verbose mode.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--version</b></td><td style="vertical-align: top;">print version.</td></tr></table>

<h2>EXAMPLES</h2>


<table><tr><td style="width: 25%; vertical-align: top;"><b>zopen clean
-c</b></td><td style="vertical-align: top;">clear the package download
cache</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>zopen clean -d</b></td><td style="vertical-align: top;">analyse the zopen file system
and remove dangling symlinks</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>zopen clean -u
[PACKAGE]</b></td><td style="vertical-align: top;">remove unused versions for
PACKAGE</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>zopen clean -u
--all</b></td><td style="vertical-align: top;">remove all unused packages
within the zopen environment</td></tr></table>

<p style="margin-left:18%; margin-top: 1em">zopen clean
--deep</p>

<h2>AUTHOR</h2>


<p style="margin-left:9%; margin-top: 1em">Written by
contributors to the zopen community.
<a href="https://github.com/zopencommunity/meta/graphs/contributors" target="_blank">https://github.com/zopencommunity/meta/graphs/contributors</a></p>

<h2>REPORTING BUGS</h2>


<p style="margin-left:9%; margin-top: 1em">Report bugs at
https://github.com/zopencommunity/meta/issues.</p>

<p style="margin-left:9%; margin-top: 1em">This is free
software: you are free to change and redistribute it under
the terms of the Apache License, Version 2.0.
<a href="https://www.apache.org/licenses/LICENSE-2.0.html" target="_blank">https://www.apache.org/licenses/LICENSE-2.0.html</a>
<br>
There is NO WARRANTY, to the extent permitted by law.</p>

</div>
