<div v-pre class="man-page-content">

<div class="header-with-back">
  <div class="back-link">
    <a href="./zopen-reference">← Back</a>
  </div>
</div>


<h1 align="center">ZOPEN-COMPUTE-BUILDDEPS</h1>




<h2>NAME
<a name="NAME"></a>
</h2>



<p style="margin-left:11%; margin-top: 1em">zopen-compute-builddeps
&minus; manual page for zopen-compute-builddeps 0.8.4</p>

<h2>SYNOPSIS
<a name="SYNOPSIS"></a>
</h2>



<p style="margin-left:11%; margin-top: 1em"><b>zopen-compute-builddeps</b>
[OPTION] [tool]</p>

<h2>DESCRIPTION
<a name="DESCRIPTION"></a>
</h2>



<p style="margin-left:11%; margin-top: 1em">zopen&minus;compute&minus;builddeps
&minus; print out build dependencies (transitive closure)
for a given tool.</p>

<p style="margin-left:22%; margin-top: 1em">NOTE: This tool
will clone several repositories into a temporary directory
for this computation.</p>

<h2>OPTIONS
<a name="OPTIONS"></a>
</h2>


<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">
<tr valign="top" align="left">
<td width="11%"></td>
<td width="9%">


<p style="margin-top: 1em"><b>&minus;&minus;help</b></p></td>
<td width="2%"></td>
<td width="41%">


<p style="margin-top: 1em">display this help and exit.</p></td>
<td width="37%">
</td></tr>
</table>


<p style="margin-left:11%;"><b>&minus;&minus;version</b></p>

<p style="margin-left:22%;">print version.</p>

<h2>EXAMPLES
<a name="EXAMPLES"></a>
</h2>


<p style="margin-left:22%; margin-top: 1em">Print out the
tools required to build git.</p>


<p style="margin-left:22%; margin-top: 1em">zopen&minus;compute&minus;builddeps
git</p>

<p style="margin-left:11%; margin-top: 1em">This is free
software: you are free to change and redistribute it under
the terms of the Apache License, Version 2.0.
<a href="https://www.apache.org/licenses/LICENSE-2.0.html" target="_blank">https://www.apache.org/licenses/LICENSE-2.0.html</a>
There is NO WARRANTY, to the extent permitted by law.</p>

<h2>AUTHOR
<a name="AUTHOR"></a>
</h2>


<p style="margin-left:11%; margin-top: 1em">Written by
contributors to the zopen community.
<a href="https://github.com/zopencommunity/meta/graphs/contributors" target="_blank">https://github.com/zopencommunity/meta/graphs/contributors</a></p>

</div>
