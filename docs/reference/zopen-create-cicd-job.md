<div v-pre class="man-page-content">

<div class="header-with-back"><div class="link" style="float: left;"><a href="./zopen-config-helper">← Previous</a></div><div class='link' style='float: right;'><a href='./zopen-create-repo'>Next →</a></div><div style="clear: both;"></div></div>


<h1 align="center">ZOPEN-CREATE-CICD-JOB</h1>




<h2>NAME</h2>



<p style="margin-left:6%; margin-top: 1em">zopen-create-cicd-job
- manual page for zopen-create-cicd-job 0.8.5</p>

<h2>SYNOPSIS</h2>



<p style="margin-left:6%; margin-top: 1em">zopen-create-cicd-job
[OPTION] -n PORT_NAME</p>

<h2>DESCRIPTION</h2>



<p style="margin-left:6%; margin-top: 1em">zopen-create-cicd-job
- Create a Jenkins CI/CD job for a port.</p>

<p style="margin-left:6%; margin-top: 1em">NOTE: This
script is intended for use by core contributors only.</p>

<h2>OPTIONS</h2>


<p style="margin-left:6%; margin-top: 1em">-h,
--help</p>

<p style="margin-left:15%;">print this help</p>

<p style="margin-left:6%;">-v, --verbose</p>

<p style="margin-left:15%;">run in verbose mode.</p>

<p style="margin-left:6%;">-n, --name
PORT_NAME</p>

<p style="margin-left:15%;">Name of the port (required)
e.g., curl, openssl (without 'port' suffix)</p>

<p style="margin-left:6%;">-b, --build-type
TYPE</p>

<p style="margin-left:15%;">Build type: stable or dev
(default: stable)</p>

<p style="margin-left:6%;">-s, --script
SCRIPT</p>

<p style="margin-left:15%;">Groovy script path in repo
(default: cicd-stable.groovy)</p>

<p style="margin-left:6%;">-r, --run-after
RUN</p>

<p style="margin-left:15%;">Trigger job after creation: yes
or no (default: yes)</p>

<p style="margin-left:6%;">--version</p>

<p style="margin-left:15%;">print version</p>

<h3>Example:</h3>



<p style="margin-left:15%; margin-top: 1em">zopen-create-cicd-job
-n curl zopen-create-cicd-job -v -n pv
-b dev -r no zopen-create-cicd-job -n
openssl -b stable -s cicd-stable.groovy</p>

<p style="margin-left:6%; margin-top: 1em">This is free
software: you are free to change and redistribute it under
the terms of the Apache License, Version 2.0.
<a href="https://www.apache.org/licenses/LICENSE-2.0.html" target="_blank">https://www.apache.org/licenses/LICENSE-2.0.html</a>
There is NO WARRANTY, to the extent permitted by law.</p>

<h2>AUTHOR</h2>


<p style="margin-left:6%; margin-top: 1em">Written by
contributors to the zopen community.
<a href="https://github.com/zopencommunity/meta/graphs/contributors" target="_blank">https://github.com/zopencommunity/meta/graphs/contributors</a></p>

</div>
