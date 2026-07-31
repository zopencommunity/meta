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


<tr>
<td style="border: 1px solid #ccc;"><code>&minus;h, &minus;&minus;help, &minus;?</code></td>
<td style="border: 1px solid #ccc;">display this help and exit.</td>
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
<th style="text-align:left; border: 1px solid #ccc;">Variable</th>
<th style="text-align:left; border: 1px solid #ccc;">Description</th>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>zopen usage</code></td>
<td style="border: 1px solid #ccc;">list the file system usage for the environment</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>zopen usage &minus;&minus;pie /mnt/zopen</code></td>
<td style="border: 1px solid #ccc;">list the file system usage for the zopen environment at the mount point /mnt/zopen</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>Notes:</code></td>
<td style="border: 1px solid #ccc;">Values might not add to 100% due to rounding during calculations; use the reported values as guidance, rounding up for capacity planning for example.</td>
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
