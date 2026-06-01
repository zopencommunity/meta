<div v-pre class="man-page-content">

<div class="header-with-back"><div class="link"><a href="./zopen-update-cacert">← Previous</a></div><div class='link'><a href='./zopen-version'>Next →</a></div></div>

<h1 align="center">ZOPEN-USAGE</h1>













<h2>NAME</h2>


<table><tr><td style="width: 25%; vertical-align: top;"><b>zopen-usage
- manual page for zopen-usage 0.8.5

<h2>SYNOPSIS</h2>



<b>zopen-usage</b>
[<i>OPTION</i>] [<i>ZOPEN_ROOTFS</i>]
[<i>PARAMETERS</i>]...

<h2>DESCRIPTION</h2>



zopen-usage
is a utility to display the file system usage by a zopen
environment

<h2>OPTIONS</h2>


<table>
<tr><td style="width: 25%; vertical-align: top;"><b>--pie</b></td><td style="vertical-align: top;">generate a pie chart showing
space hogs</td></tr>
</table>

<b>-h</b>,
<b>--help</b>, -?</b></td><td style="vertical-align: top;">display this help and exit.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-v</b>,
<b>--verbose</b></td><td style="vertical-align: top;">run in verbose mode.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--version</b></td><td style="vertical-align: top;">print version</td></tr></table>

<h2>EXAMPLES</h2>


<table><tr><td style="width: 25%; vertical-align: top;"><b>zopen usage</b></td><td style="vertical-align: top;">list the file system usage for
the environment</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>zopen usage --pie
/mnt/zopen</b></td><td style="vertical-align: top;">list the file system usage for
the zopen environment at the mount point /mnt/zopen</td></tr></table>

<h3>Notes:</h3>


<p style="margin-left:18%; margin-top: 1em">Values might
not add to 100% due to rounding during calculations; use the
reported values as guidance, rounding up for capacity
planning for example.</p>

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
