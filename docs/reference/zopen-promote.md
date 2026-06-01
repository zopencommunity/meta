<div v-pre class="man-page-content">

<div class="header-with-back"><div class="link" style="float: left;"><a href="./zopen-pax2rpm">← Previous</a></div><div class='link' style='float: right;'><a href='./zopen-publish'>Next →</a></div><div style="clear: both;"></div></div>


<h1 align="center">ZOPEN-VERSION</h1>




<h2>NAME</h2>


<p style="margin-left:6%; margin-top: 1em">zopen-version -
manual page for zopen-version 0.8.5</p>

<h2>SYNOPSIS</h2>


<p style="margin-left:6%; margin-top: 1em">zopen
promote [OPTION] [DESTINATION]...</p>

<h2>DESCRIPTION</h2>


<p style="margin-left:6%; margin-top: 1em">zopen-promote is
a utility for zopen community to generate a clone of an
existing zopen environment. For example, a user can install
to a test area, validate the behavior, and promote to a
production area.</p>

<h2>OPTIONS</h2>


<p style="margin-left:6%; margin-top: 1em">-cp,
--configperms [PERMISSIONS]</p>

<p style="margin-left:15%;">Update the permissions for the
configuration file &lt;promotedroot&gt;/etc/zopen-config
with the given [PERMISSIONS] string, specified in symbolic
mode.</p>

<p style="margin-left:6%;">-f, --from</p>

<p style="margin-left:15%;">[DIRECTORY] The zopen
environment to copy from; if not present, the default is
taken from ZOPEN_ROOTFS (the current zopen environment).</p>

<p style="margin-left:6%;">-g, --group
[GROUP]</p>

<p style="margin-left:15%;">Change group of promoted
environment files from default.</p>

<p style="margin-left:6%;">-h, -?, --help</p>

<p style="margin-left:15%;">Display this help and exit.</p>

<p style="margin-left:6%;">--keepzopentooling</p>

<p style="margin-left:15%;">Install the zopen admin tools
into the promoted environment for zopen system
administration.</p>

<p style="margin-left:6%;">-o, --owner
[OWNER]</p>

<p style="margin-left:15%;">Change owner of promoted
environment files from current user.</p>

<p style="margin-left:6%;">-v, --verbose</p>

<p style="margin-left:15%;">Run in verbose mode.</p>

<p style="margin-left:6%;">--version</p>

<p style="margin-left:15%;">Display version
information.</p>

<p style="margin-left:6%;">-y, --yes</p>

<p style="margin-left:15%;">Automatically answer
'yes' to prompts; existing target filesystems
will be purged before promote occurs.</p>

<p style="margin-left:6%;">-zp, --zopenperms
[PERMISSIONS]</p>

<p style="margin-left:15%;">Update the permissions for all
files within the promoted zopen environment with the given
[PERMISSIONS] string, specified in symbolic mode.</p>

<h2>EXAMPLES</h2>


<p style="margin-left:6%; margin-top: 1em">zopen
promote</p>

<p style="margin-left:15%;">Interactively promote current
zopen environment.</p>

<p style="margin-left:6%;">zopen promote /prod</p>

<p style="margin-left:15%;">Promote current zopen
environment to '/prod', setting file ownership
to current user and group to default.</p>

<p style="margin-left:6%;">zopen promote /prod --owner
FOO</p>

<p style="margin-left:15%;">Promote current zopen
environment to '/prod', setting file ownership
to 'FOO' and group to default.</p>

<p style="margin-left:6%;">zopen promote /prod --group
BAR</p>

<p style="margin-left:15%;">Promote current zopen
environment to '/prod', setting file ownership
to current user and group to 'BAR'.</p>

<p style="margin-left:6%;">zopen promote /mytest -cp
g-wx,o-rwx -zp g-rwx,o-rwx --owner FOO</p>

<p style="margin-left:15%;">Promote current zopen
environment to '/mytest', allowing only the
current user to source the zopen-config environment file and
only permit access to zopen environment files to the user
'FOO'.</p>

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
