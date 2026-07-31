<div v-pre class="man-page-content">

<div class="header-with-back">
  <div class="back-link">
    <a href="./zopen-reference">← Back</a>
  </div>
</div>


<h1 align="center">ZOPEN-CREATE-CICD-JOB</h1>




<h2>NAME
</h2>



<p style="margin-left:11%; margin-top: 1em">zopen-create-cicd-job
&minus; manual page for zopen-create-cicd-job 0.8.4</p>

<h2>SYNOPSIS
</h2>



<p style="margin-left:11%; margin-top: 1em">zopen-create-cicd-job
[OPTION] -n PORT_NAME</p>

<h2>DESCRIPTION
</h2>



<p style="margin-left:11%; margin-top: 1em">zopen&minus;create&minus;cicd&minus;job
&minus; Create a Jenkins CI/CD job for a port.</p>

<p style="margin-left:11%; margin-top: 1em">NOTE: This
script is intended for use by core contributors only.</p>

<h2>OPTIONS
</h2>



<p style="margin-left:11%; margin-top: 1em">&minus;h,
&minus;&minus;help</p>

<p style="margin-left:22%;">print this help</p>

<p style="margin-left:11%;">&minus;v,
&minus;&minus;verbose</p>

<p style="margin-left:22%;">run in verbose mode.</p>

<p style="margin-left:11%;">&minus;n,
&minus;&minus;name PORT_NAME</p>

<p style="margin-left:22%;">Name of the port (required)
e.g., curl, openssl (without &rsquo;port&rsquo; suffix)</p>

<p style="margin-left:11%;">&minus;b,
&minus;&minus;build&minus;type TYPE</p>

<p style="margin-left:22%;">Build type: stable or dev
(default: stable)</p>

<p style="margin-left:11%;">&minus;s,
&minus;&minus;script SCRIPT</p>

<p style="margin-left:22%;">Groovy script path in repo
(default: cicd&minus;stable.groovy)</p>

<p style="margin-left:11%;">&minus;r,
&minus;&minus;run&minus;after RUN</p>

<p style="margin-left:22%;">Trigger job after creation: yes
or no (default: yes)</p>


<p style="margin-left:11%;">&minus;&minus;version</p>

<p style="margin-left:22%;">print version</p>


<p style="margin-left:11%; margin-top: 1em">Example:</p>


<p style="margin-left:22%;">zopen&minus;create&minus;cicd&minus;job
&minus;n curl zopen&minus;create&minus;cicd&minus;job
&minus;v &minus;n pv &minus;b dev
&minus;r no zopen&minus;create&minus;cicd&minus;job
&minus;n openssl &minus;b stable
&minus;s cicd&minus;stable.groovy</p>

<p style="margin-left:11%; margin-top: 1em">This is free
software: you are free to change and redistribute it under
the terms of the Apache License, Version 2.0.
&lt;<a href="https://www.apache.org/licenses/LICENSE" target="_blank">https://www.apache.org/licenses/LICENSE</a>&minus;2.0.html&gt;
There is NO WARRANTY, to the extent permitted by law.</p>

<h2>AUTHOR
</h2>


<p style="margin-left:11%; margin-top: 1em">Written by
contributors to the zopen community.
<a href="https://github.com/zopencommunity/meta/graphs/contributors" target="_blank">https://github.com/zopencommunity/meta/graphs/contributors</a></p>

</div>
