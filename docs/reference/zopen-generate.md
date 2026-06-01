<div v-pre class="man-page-content">

<div class="header-with-back"><div class="link"><a href="./zopen-diagnostics">← Previous</a></div><div class='link'><a href='./zopen-help2man'>Next →</a></div></div>

<h1 align="center">ZOPEN-GENERATE</h1>









<h2>NAME</h2>


<table><tr><td style="width: 25%; vertical-align: top;"><b>zopen-generate
- manual page for zopen-generate 0.8.5

<h2>DESCRIPTION</h2>



zopen-generate
will generate a zopen compatible project Syntax:
zopen-generate [options]

<h2>OPTIONS</h2>


<table>
<tr><td style="width: 25%; vertical-align: top;"><b>--help</b></td><td style="vertical-align: top;">Display this help message</td></tr>
<tr><td style="width: 25%; vertical-align: top;"><b>--version</b></td><td style="vertical-align: top;">Display version information</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--list-licenses</b></td><td style="vertical-align: top;">List available licenses</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--list-categories</b></td><td style="vertical-align: top;">List available categories</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--list-build-systems</b></td><td style="vertical-align: top;">List supported build
systems</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--name</b>
NAME</td><td style="vertical-align: top;">Project name</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--description</b>
DESC</td><td style="vertical-align: top;">Project description</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--categories</b>
CATS</td><td style="vertical-align: top;">Project categories
(space-delimited)</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--license</b>
LICENSE</td><td style="vertical-align: top;">License name</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--type</b>
TYPE</td><td style="vertical-align: top;">Port type: 'BUILD'
(from source) or 'BARE' (binary download)</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--build-system</b>
SYSTEM</td><td style="vertical-align: top;">Build system if type is BUILD
(GNU Make, CMake, Gradle, Maven, etc.)</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--c-extensions</b></td><td style="vertical-align: top;">Python project contains C
extensions (requires C compiler)</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--stable-url</b>
URL</td><td style="vertical-align: top;">Stable release source URL (Git
HTTPS clone URL ending in .git, or a direct archive URL
ending in .tar.gz, .tar.xz, .tar.bz2, .zip, etc.)</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--stable-deps</b>
DEPS</td><td style="vertical-align: top;">Stable build dependencies
(space-delimited)</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--dev-url</b>
URL</td><td style="vertical-align: top;">Dev-line source URL (same
formats as <b>--stable-url</b>; typically
the main-branch Git clone URL)</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--dev-deps</b>
DEPS</td><td style="vertical-align: top;">Dev build dependencies
(space-delimited)</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--build-line</b>
LINE</td><td style="vertical-align: top;">Default build line (stable or
dev)</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--runtime-deps</b>
DEPS</td><td style="vertical-align: top;">Runtime dependencies
(space-delimited)</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--force</b></td><td style="vertical-align: top;">Force update if project
directory exists</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--non-interactive</b></td><td style="vertical-align: top;">Run in non-interactive
mode (requires all necessary options)</td></tr>
<tr><td style="width: 25%; vertical-align: top;"><b>--json</b></td><td style="vertical-align: top;">Display list output in JSON format</td></tr>
</table>

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
