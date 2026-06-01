<div v-pre class="man-page-content">

<div class="header-with-back"><div class="link"><a href="./zopen-compare-versions">← Previous</a></div><div class='link'><a href='./zopen-config-helper'>Next →</a></div></div>

<h1 align="center">ZOPEN-COMPUTE-BUILDDEPS</h1>











<h2>NAME</h2>



<table><tr><td style="width: 25%; vertical-align: top;"><b>zopen-compute-builddeps
- manual page for zopen-compute-builddeps 0.8.5

<h2>SYNOPSIS</h2>



<b>zopen-compute-builddeps</b>
[<i>OPTION</i>] [<i>tool</i>]

<h2>DESCRIPTION</h2>



zopen-compute-builddeps
- print out build dependencies (transitive closure)
for a given tool.</b></td><td style="vertical-align: top;">NOTE: This tool
will clone several repositories into a temporary directory
for this computation.</td></tr></table>

<h2>OPTIONS</h2>


<table>
<tr><td style="width: 25%; vertical-align: top;"><b>--help</b></td><td style="vertical-align: top;">display this help and exit.</td></tr>
<tr><td style="width: 25%; vertical-align: top;"><b>--version</b></td><td style="vertical-align: top;">print version.</td></tr></table>

<h2>EXAMPLES</h2>


<p style="margin-left:18%; margin-top: 1em">Print out the
tools required to build git.</p>


<p style="margin-left:18%; margin-top: 1em">zopen-compute-builddeps
git</p>

<p style="margin-left:9%; margin-top: 1em">This is free
software: you are free to change and redistribute it under
the terms of the Apache License, Version 2.0.
<a href="https://www.apache.org/licenses/LICENSE-2.0.html" target="_blank">https://www.apache.org/licenses/LICENSE-2.0.html</a>
There is NO WARRANTY, to the extent permitted by law.</p>

<h2>AUTHOR</h2>


<p style="margin-left:9%; margin-top: 1em">Written by
contributors to the zopen community.
<a href="https://github.com/zopencommunity/meta/graphs/contributors" target="_blank">https://github.com/zopencommunity/meta/graphs/contributors</a></p>

</div>
