<div v-pre class="man-page-content">

<div class="header-with-back"><div class="link"><a href="./zopen-info">← Previous</a></div><div class='link'><a href='./zopen-install'>Next →</a></div></div>

<h1 align="center">ZOPEN-INIT</h1>












<h2>NAME</h2>


<table><tr><td style="width: 25%; vertical-align: top;"><b>zopen-init
- manual page for zopen-init 0.8.5

<h2>SYNOPSIS</h2>


<b>zopen</b>
<i>init</i> [<i>OPTION</i>] [<i>PARAMETERS</i>]...

<h2>DESCRIPTION</h2>


zopen init is a
utility for zopen community to generate a zopen environment,
bootstrapping initial tools and creating a configuration
file

<h2>OPTIONS</h2>


<table>
<tr><td style="width: 25%; vertical-align: top;"><b>--append-to-profile</b></td><td style="vertical-align: top;"><b>--[no]enable-stats</b></td></tr>
</table>

Toggle enabling
collection of usage statistics

<table>
<tr><td style="width: 25%; vertical-align: top;"><b>--[no]override-zos-tools</b></td><td style="vertical-align: top;"><b>--bypass-prereq-checks</b></td></tr>
</table>

Bypasses
pre-requisite checks

<table>
<tr><td style="width: 25%; vertical-align: top;"><b>-f</b>,
<b>--fs-layout</b> <code>&lt;LAYOUT&gt;</code></td><td style="vertical-align: top;"><b>-h</b>, -?,
<b>--help</b></td></tr>
</table>

display this
help and exit

<table>
<tr><td style="width: 25%; vertical-align: top;"><b>--re-init</b></td><td style="vertical-align: top;"><b>--refresh</b></td></tr>
</table>

Refreshes the
zopen-config file

<table>
<tr><td style="width: 25%; vertical-align: top;"><b>--releaseline-dev</b></td><td style="vertical-align: top;"><b>-v</b>,
<b>--verbose</b></td></tr>
</table>

run in verbose
mode

<table>
<tr valign="top" align="left">
<td width="9%"></td>
<td width="12%"><b>-y</b>,
<b>--yes</b></td>
<td width="79%">
</td></tr>
</table>

automatically
answer 'yes' to prompts

<h2>EXAMPLES</h2>


zopen init</b></td><td style="vertical-align: top;">interactively
bootstrap a zopen environment</td></tr></table>

<p style="margin-left:18%; margin-top: 1em">zopen init
--releaseline-dev</p>

<p style="margin-left:18%; margin-top: 1em">interactively
bootstrap a zopen environment that will use Development
Releaseline packages</p>

<p style="margin-left:18%; margin-top: 1em">zopen init
--yes
--append-to-profile
--fs-layout fhs /zopen</p>


<p style="margin-left:18%; margin-top: 1em">non-interactively
create a zopen environment at location '/zopen'
on disk, with packages installed to
'/zopen/opt'. The user's .profile will be
updated to source the configuration file at
'/zopen/etc/zopen-config' when new
terminal sessions start</p>

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
