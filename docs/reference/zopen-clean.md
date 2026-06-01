<div v-pre class="man-page-content">

<div class="header-with-back"><div class="link" style="float: left;"><a href="./zopen-build">← Previous</a></div><div class='link' style='float: right;'><a href='./zopen-config-helper'>Next →</a></div><div style="clear: both;"></div></div>


<h1 align="center">ZOPEN-CLEAN</h1>




<h2>NAME</h2>


<p style="margin-left:6%; margin-top: 1em">zopen-clean -
manual page for zopen-clean 0.8.5</p>

<h2>SYNOPSIS</h2>



<p style="margin-left:6%; margin-top: 1em">zopen-clean
[OPTION] [PACKAGE]</p>

<h2>DESCRIPTION</h2>


<p style="margin-left:6%; margin-top: 1em">zopen-clean is a
utility for zopen community to remove uneeded resources from
the system to save space and prevent clutter.</p>

<h2>OPTIONS</h2>



<p style="margin-left:6%; margin-top: 1em">--deep</p>

<p style="margin-left:15%;">deep clean - run all cleanup
operations</p>


<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">

<tr valign="top" align="left">

<td width="6%"></td>


<td width="7%">


<p>--all</p></td>


<td width="2%"></td>


<td width="61%">


<p>apply cleanup command to all applicable packages.</p></td>


<td width="24%">
</td>
</tr>

</table>


<p style="margin-left:6%;">-c, --cache</p>

<p style="margin-left:15%;">[PACKAGE ...] cleans the
downloaded package cache; packages will be re-downloaded if
needed.</p>

<p style="margin-left:6%;">-d, --dangling</p>

<p style="margin-left:15%;">removes dangling symlinks from
the zopen file system in case of issues during package
maintenance.</p>

<p style="margin-left:6%;">-h, --help, -?</p>

<p style="margin-left:15%;">display this help and exit.</p>

<p style="margin-left:6%;">-m, --metadata</p>

<p style="margin-left:15%;">cleans and refreshes the
metadata for zopen.</p>

<p style="margin-left:6%;">-u, --unused
[PACKAGE ...]</p>

<p style="margin-left:15%;">remove versions of PACKAGEs
that are available as alternatives, leaving only the
currently active version.</p>

<p style="margin-left:6%;">--nostats</p>

<p style="margin-left:15%;">do not output statistics from
the clean operation(s)</p>

<p style="margin-left:6%;">-v, --verbose</p>

<p style="margin-left:15%;">run in verbose mode.</p>

<p style="margin-left:6%;">--version</p>

<p style="margin-left:15%;">print version.</p>

<h2>EXAMPLES</h2>


<p style="margin-left:6%; margin-top: 1em">zopen clean
-c</p>

<p style="margin-left:15%;">clear the package download
cache</p>

<p style="margin-left:6%;">zopen clean -d</p>

<p style="margin-left:15%;">analyse the zopen file system
and remove dangling symlinks</p>

<p style="margin-left:6%;">zopen clean -u [PACKAGE]</p>

<p style="margin-left:15%;">remove unused versions for
PACKAGE</p>

<p style="margin-left:6%;">zopen clean -u --all</p>

<p style="margin-left:15%;">remove all unused packages
within the zopen environment</p>

<p style="margin-left:15%; margin-top: 1em">zopen clean
--deep</p>

<h2>AUTHOR</h2>


<p style="margin-left:6%; margin-top: 1em">Written by
contributors to the zopen community.
<a href="https://github.com/zopencommunity/meta/graphs/contributors" target="_blank">https://github.com/zopencommunity/meta/graphs/contributors</a></p>

<h2>REPORTING BUGS</h2>


<p style="margin-left:6%; margin-top: 1em">Report bugs at
https://github.com/zopencommunity/meta/issues.</p>

<p style="margin-left:6%; margin-top: 1em">This is free
software: you are free to change and redistribute it under
the terms of the Apache License, Version 2.0.
<a href="https://www.apache.org/licenses/LICENSE-2.0.html" target="_blank">https://www.apache.org/licenses/LICENSE-2.0.html</a>
There is NO WARRANTY, to the extent permitted by law.</p>

</div>
