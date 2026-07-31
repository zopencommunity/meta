<div v-pre class="man-page-content">

<div class="header-with-back">
  <div class="back-link">
    <a href="./zopen-reference">← Back</a>
  </div>
</div>

<h1 align="center">ZOPEN-USAGE</h1>

<h2>NAME</h2>

<p style="margin-left:11%; margin-top: 1em">zopen-usage
&minus; manual page for zopen-usage 0.8.4</p>

<h2>SYNOPSIS</h2>

<p style="margin-left:11%; margin-top: 1em">zopen-usage
[OPTION] [ZOPEN_ROOTFS]
[PARAMETERS]...</p>

<h2>DESCRIPTION</h2>

<p style="margin-left:11%; margin-top: 1em">zopen&minus;usage
is a utility to display the file system usage by a zopen
environment</p>

<h2>OPTIONS</h2>

<table width="100%" border="0" rules="none" frame="void" cellspacing="0" cellpadding="0">

<tr valign="top" align="left">

<td width="11%"></td>

<td width="7%">

<p style="margin-top: 1em">&minus;&minus;pie</p></td>

<td width="4%"></td>

<td width="60%">

<p style="margin-top: 1em">generate a pie chart showing
space hogs</p></td>

<td width="18%">
</td>
</tr>

</table>

<p style="margin-left:11%;">&minus;h,
&minus;&minus;help, &minus;?</p>

<p style="margin-left:22%;">display this help and exit.</p>

<p style="margin-left:11%;">&minus;v,
&minus;&minus;verbose</p>

<p style="margin-left:22%;">run in verbose mode.</p>

<p style="margin-left:11%;">&minus;&minus;version</p>

<p style="margin-left:22%;">print version</p>

<h2>EXAMPLES</h2>

<p style="margin-left:11%; margin-top: 1em">zopen usage</p>

<p style="margin-left:22%;">list the file system usage for
the environment</p>

<p style="margin-left:11%;">zopen usage &minus;&minus;pie
/mnt/zopen</p>

<p style="margin-left:22%;">list the file system usage for
the zopen environment at the mount point /mnt/zopen</p>

<p style="margin-left:11%; margin-top: 1em">Notes:</p>

<p style="margin-left:22%;">Values might not add to 100%
due to rounding during calculations; use the reported values
as guidance, rounding up for capacity planning for
example.</p>

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
&lt;<a href="https://www.apache.org/licenses/LICENSE" target="_blank">https://www.apache.org/licenses/LICENSE</a>&minus;2.0.html&gt;
There is NO WARRANTY, to the extent permitted by law.</p>

</div>
