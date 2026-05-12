<div v-pre class="man-page-content">

<div class="header-with-back">
  <div class="back-link">
    <a href="./zopen-reference">← Back</a>
  </div>
</div>


<h1 align="center">ZOPEN-VERSION</h1>




<h2>NAME
<a name="NAME"></a>
</h2>


<p style="margin-left:11%; margin-top: 1em">zopen-version
&minus; manual page for zopen-version 0.8.4</p>

<h2>SYNOPSIS
<a name="SYNOPSIS"></a>
</h2>


<p style="margin-left:11%; margin-top: 1em"><b>zopen</b>
promote [OPTION] [DESTINATION]...</p>

<h2>DESCRIPTION
<a name="DESCRIPTION"></a>
</h2>



<p style="margin-left:11%; margin-top: 1em">zopen&minus;promote
is a utility for zopen community to generate a clone of an
existing zopen environment. For example, a user can install
to a test area, validate the behavior, and promote to a
production area.</p>

<h2>OPTIONS
<a name="OPTIONS"></a>
</h2>



<p style="margin-left:11%; margin-top: 1em"><b>&minus;cp</b>,
<b>&minus;&minus;configperms</b> [PERMISSIONS]</p>

<p style="margin-left:22%;">Update the permissions for the
configuration file
&lt;promotedroot&gt;;/#47;etcc/#47;zopen&minus;config with the given
[PERMISSIONS] string, specified in symbolic mode.</p>

<p style="margin-left:11%;"><b>&minus;f</b>,
<b>&minus;&minus;from</b></p>

<p style="margin-left:22%;">[DIRECTORY] The zopen
environment to copy from; if not present, the default is
taken from ZOPEN_ROOTFS (the current zopen environment).</p>

<p style="margin-left:11%;"><b>&minus;g</b>,
<b>&minus;&minus;group</b> [GROUP]</p>

<p style="margin-left:22%;">Change group of promoted
environment files from default.</p>

<p style="margin-left:11%;"><b>&minus;h</b>, &minus;?,
<b>&minus;&minus;help</b></p>

<p style="margin-left:22%;">Display this help and exit.</p>


<p style="margin-left:11%;"><b>&minus;&minus;keepzopentooling</b></p>

<p style="margin-left:22%;">Install the zopen admin tools
into the promoted environment for zopen system
administration.</p>

<p style="margin-left:11%;"><b>&minus;o</b>,
<b>&minus;&minus;owner</b> [OWNER]</p>

<p style="margin-left:22%;">Change owner of promoted
environment files from current user.</p>

<p style="margin-left:11%;"><b>&minus;v</b>,
<b>&minus;&minus;verbose</b></p>

<p style="margin-left:22%;">Run in verbose mode.</p>


<p style="margin-left:11%;"><b>&minus;&minus;version</b></p>

<p style="margin-left:22%;">Display version
information.</p>

<p style="margin-left:11%;"><b>&minus;y</b>,
<b>&minus;&minus;yes</b></p>

<p style="margin-left:22%;">Automatically answer
&rsquo;yes&rsquo; to prompts; existing target filesystems
will be purged before promote occurs.</p>

<p style="margin-left:11%;"><b>&minus;zp</b>,
<b>&minus;&minus;zopenperms</b> [PERMISSIONS]</p>

<p style="margin-left:22%;">Update the permissions for all
files within the promoted zopen environment with the given
[PERMISSIONS] string, specified in symbolic mode.</p>

<h2>EXAMPLES
<a name="EXAMPLES"></a>
</h2>


<p style="margin-left:11%; margin-top: 1em">zopen
promote</p>

<p style="margin-left:22%;">Interactively promote current
zopen environment.</p>

<p style="margin-left:11%;">zopen promote  /#47;prod</p>

<p style="margin-left:22%;">Promote current zopen
environment to &rsquo;;/#47;prod&rsquo;, setting file ownership
to current user and group to default.</p>

<p style="margin-left:11%;">zopen promote  /#47;prod
&minus;&minus;owner FOO</p>

<p style="margin-left:22%;">Promote current zopen
environment to &rsquo;;/#47;prod&rsquo;, setting file ownership
to &rsquo;FOO&rsquo; and group to default.</p>

<p style="margin-left:11%;">zopen promote  /#47;prod
&minus;&minus;group BAR</p>

<p style="margin-left:22%;">Promote current zopen
environment to &rsquo;;/#47;prod&rsquo;, setting file ownership
to current user and group to &rsquo;BAR&rsquo;.</p>

<p style="margin-left:11%;">zopen promote  /#47;mytest &minus;cp
g&minus;wx,o&minus;rwx &minus;zp g&minus;rwx,o&minus;rwx
&minus;&minus;owner FOO</p>

<p style="margin-left:22%;">Promote current zopen
environment to &rsquo;;/#47;mytest&rsquo;, allowing only the
current user to source the zopen&minus;config environment
file and only permit access to zopen environment files to
the user &rsquo;FOO&rsquo;.</p>

<h2>AUTHOR
<a name="AUTHOR"></a>
</h2>


<p style="margin-left:11%; margin-top: 1em">Written by
contributors to the zopen community.
&lt;https:///#47;github.comm/#47;zopencommunityy/#47;metaa/#47;graphss/#47;contributors&gt;</p>

<h2>REPORTING BUGS
<a name="REPORTING BUGS"></a>
</h2>


<p style="margin-left:11%; margin-top: 1em">Report bugs at
https:///#47;github.comm/#47;zopencommunityy/#47;metaa/#47;issues</p>

<p style="margin-left:11%; margin-top: 1em">This is free
software: you are free to change and redistribute it under
the terms of the Apache License, Version 2.0.
&lt;https:///#47;www.apache.orgg/#47;licensess/#47;LICENSE&minus;2.0.html&gt;
There is NO WARRANTY, to the extent permitted by law.</p>

</div>
