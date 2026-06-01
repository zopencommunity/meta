<div v-pre class="man-page-content">

<div class="header-with-back"><div class="link"><a href="./zopen-whichproject">← Previous</a></div></div>

<h1 align="center">ZOPEN-VERSION</h1>














<h2>NAME</h2>


<table><tr><td style="width: 25%; vertical-align: top;"><b>zopen-version
- manual page for zopen-version 0.8.5

<h2>SYNOPSIS</h2>


<b>zopen</b>
[<i>COMMAND</i>] [<i>OPTION</i>] [<i>PARAMETERS</i>]...

<h2>DESCRIPTION</h2>


zopen is a
utility for managing a zopen community environment.

<h3>Command:</h3>


<table>
<tr><td style="width: 25%; vertical-align: top;"><b>alt</b></td><td style="vertical-align: top;">manage alternate versions of
zopen community packages</td></tr>
<tr><td style="width: 25%; vertical-align: top;"><b>audit</b></td><td style="vertical-align: top;">(beta) reports known vulnerabilities for the installed
packages</td></tr>
<tr><td style="width: 25%; vertical-align: top;"><b>build</b></td><td style="vertical-align: top;">builds the enclosing zopen community git-cloned
package</td></tr>
<tr><td style="width: 25%; vertical-align: top;"><b>clean</b></td><td style="vertical-align: top;">cleans up your zopen environment</td></tr>
<tr><td style="width: 25%; vertical-align: top;"><b>config</b></td><td style="vertical-align: top;">change zopen runtime environment settings</td></tr>
</table>

diagnostics</b></td><td style="vertical-align: top;">collects system info for zopen
troubleshooting</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>generate</b></td><td style="vertical-align: top;">generates a new zopen
project</td></tr>
<tr><td style="width: 25%; vertical-align: top;"><b>init</b></td><td style="vertical-align: top;">initializes a zopen environment at the specified
location</td></tr>
<tr><td style="width: 25%; vertical-align: top;"><b>refresh</b></td><td style="vertical-align: top;">refreshes your zopen
environment and zopen-config file</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>install</b></td><td style="vertical-align: top;">installs one or more zopen
community packages</td></tr>
<tr><td style="width: 25%; vertical-align: top;"><b>info</b></td><td style="vertical-align: top;">displays detailed information about a package</td></tr>
<tr><td style="width: 25%; vertical-align: top;"><b>list</b></td><td style="vertical-align: top;">lists information about zopen community packages</td></tr>
<tr><td style="width: 25%; vertical-align: top;"><b>publish</b></td><td style="vertical-align: top;">publish zopen package release
to github</td></tr>
<tr><td style="width: 25%; vertical-align: top;"><b>query</b></td><td style="vertical-align: top;">list local or remote info about zopen community
packages</td></tr>
<tr><td style="width: 25%; vertical-align: top;"><b>remove</b></td><td style="vertical-align: top;">removes installed zopen community packages</td></tr>
<tr><td style="width: 25%; vertical-align: top;"><b>update-cacert</b></td><td style="vertical-align: top;">update the cacert.pem file used
by zopen community</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>upgrade</b></td><td style="vertical-align: top;">upgrades existing zopen
community packages</td></tr>
<tr valign="top" align="left">
<td width="9%"></td>
<td width="6%">usage</td>
<td width="3%"></td>
<td width="82%">output details about the file system usage for your
zopen environment</td></tr>
<tr><td style="width: 25%; vertical-align: top;"><b>whichproject</b></td><td style="vertical-align: top;">determine the package a command
or library belongs to</td></tr></table>

<h2>OPTIONS</h2>



<table><tr><td style="width: 25%; vertical-align: top;"><b>-h</b>,
<b>--help</b>, -?</td><td style="vertical-align: top;">display this help and exit</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-v</b>,
<b>--verbose</b></td><td style="vertical-align: top;">run in verbose mode</td></tr></table>

<h2>EXAMPLES</h2>


<table><tr><td style="width: 25%; vertical-align: top;"><b>zopen
--help</b></td><td style="vertical-align: top;">displays zopen help</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>zopen --version</b></td><td style="vertical-align: top;">displays the installed zopen
version</td></tr></table>

<p style="margin-left:18%; margin-top: 1em">zopen install
git install the latest version of the 'git'
package zopen upgrade -y upgrade all installed
packages to the latest release,</p>

<p style="margin-left:18%; margin-top: 1em">without
prompting</p>

<table><tr><td style="width: 25%; vertical-align: top;"><b>zopen alt bash</b></td><td style="vertical-align: top;">list installed alternative bash
packages</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>zopen info vim</b></td><td style="vertical-align: top;">displays details information
about the installed vim package</td></tr></table>

<p style="margin-left:18%; margin-top: 1em">zopen usage
--pie displays an ASCII-art chart showing
biggest space hogs</p>

<h3>SEE ALSO:</h3>



<p style="margin-left:18%; margin-top: 1em">zopen-alt(1)
zopen-audit(1) zopen-build(1)
zopen-clean(1) zopen-config-helper(1)
zopen-generate(1) zopen-init(1)
zopen-install(1) zopen-info(1)
zopen-publish(1) zopen-query(1)
zopen-remove(1) zopen-update-cacert(1)
zopen-usage(1) zopen-whichproject(1)
zopen-version(1)</p>

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
