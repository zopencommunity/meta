<div v-pre class="man-page-content">

<div class="header-with-back"><div class="link" style="float: left;"><a href="./zopen-update-cacert">← Previous</a></div><div class='link' style='float: right;'><a href='./zopen-version'>Next →</a></div><div style="clear: both;"></div></div>


<h1 align="center">ZOPEN-USAGE</h1>




<h2>NAME</h2>


<p style="margin-left:6%; margin-top: 1em">zopen-usage -
manual page for zopen-usage 0.8.5</p>

<h2>SYNOPSIS</h2>



<p style="margin-left:6%; margin-top: 1em">zopen-usage
[OPTION] [ZOPEN_ROOTFS]
[PARAMETERS]...</p>

<h2>DESCRIPTION</h2>


<p style="margin-left:6%; margin-top: 1em">zopen-usage is a
utility to display the file system usage by a zopen
environment</p>

<h2>OPTIONS</h2>



<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">

<tr valign="top" align="left">

<td width="6%"></td>


<td width="7%">


<p style="margin-top: 1em">--pie</p></td>


<td width="2%"></td>


<td width="49%">


<p style="margin-top: 1em">generate a pie chart showing
space hogs</p></td>


<td width="36%">
</td>
</tr>

</table>


<p style="margin-left:6%;">-h, --help, -?</p>

<p style="margin-left:15%;">display this help and exit.</p>

<p style="margin-left:6%;">-v, --verbose</p>

<p style="margin-left:15%;">run in verbose mode.</p>

<p style="margin-left:6%;">--version</p>

<p style="margin-left:15%;">print version</p>

<h2>EXAMPLES</h2>


<p style="margin-left:6%; margin-top: 1em">zopen usage</p>

<p style="margin-left:15%;">list the file system usage for
the environment</p>

<p style="margin-left:6%;">zopen usage --pie /mnt/zopen</p>

<p style="margin-left:15%;">list the file system usage for
the zopen environment at the mount point /mnt/zopen</p>

<h3>Notes:</h3>


<p style="margin-left:15%; margin-top: 1em">Values might
not add to 100% due to rounding during calculations; use the
reported values as guidance, rounding up for capacity
planning for example.</p>

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
