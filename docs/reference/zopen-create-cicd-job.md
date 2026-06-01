<div v-pre class="man-page-content">

<div class="header-with-back"><div class="link"><a href="./zopen-config-helper">← Previous</a></div><div class='link'><a href='./zopen-create-repo'>Next →</a></div></div>

<h1 align="center">ZOPEN-CREATE-CICD-JOB</h1>











<h2>NAME</h2>



<table><tr><td style="width: 25%; vertical-align: top;"><b>zopen-create-cicd-job
- manual page for zopen-create-cicd-job 0.8.5

<h2>SYNOPSIS</h2>



<b>zopen-create-cicd-job</b>
[<i>OPTION</i>] <i>-n PORT_NAME</i>

<h2>DESCRIPTION</h2>



zopen-create-cicd-job
- Create a Jenkins CI/CD job for a port.

NOTE: This
script is intended for use by core contributors only.

<h2>OPTIONS</h2>



<b>-h</b>,
<b>--help</b></td><td style="vertical-align: top;">print this help</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-v</b>,
<b>--verbose</b></td><td style="vertical-align: top;">run in verbose mode.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-n</b>,
<b>--name</b> PORT_NAME</td><td style="vertical-align: top;">Name of the port (required)
e.g., curl, openssl (without 'port' suffix)</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-b</b>,
<b>--build-type</b> TYPE</td><td style="vertical-align: top;">Build type: stable or dev
(default: stable)</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-s</b>,
<b>--script</b> SCRIPT</td><td style="vertical-align: top;">Groovy script path in repo
(default: cicd-stable.groovy)</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-r</b>,
<b>--run-after</b> RUN</td><td style="vertical-align: top;">Trigger job after creation: yes
or no (default: yes)</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--version</b></td><td style="vertical-align: top;">print version</td></tr></table>

<h3>Example:</h3>



<p style="margin-left:18%; margin-top: 1em">zopen-create-cicd-job
<b>-n</b> curl zopen-create-cicd-job
<b>-v -n</b> pv <b>-b</b> dev
<b>-r</b> no zopen-create-cicd-job
<b>-n</b> openssl <b>-b</b> stable
<b>-s</b> cicd-stable.groovy</p>

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
