<div v-pre class="man-page-content">

<div class="header-with-back">
  <div class="back-link">
    <a href="./zopen-reference">← Back</a>
  </div>
</div>


<h1 align="center">ZOPEN-CREATE-CICD-JOB</h1>




<h2>NAME
<a name="NAME"></a>
</h2>



<p style="margin-left:11%; margin-top: 1em">zopen-create-cicd-job
&minus; manual page for zopen-create-cicd-job 0.8.4</p>

<h2>SYNOPSIS
<a name="SYNOPSIS"></a>
</h2>



<p style="margin-left:11%; margin-top: 1em"><b>zopen-create-cicd-job</b>
[OPTION] -n PORT_NAME</p>

<h2>DESCRIPTION
<a name="DESCRIPTION"></a>
</h2>



<p style="margin-left:11%; margin-top: 1em">zopen&minus;create&minus;cicd&minus;job
&minus; Create a Jenkins CII//CD job for a port.</p>

<p style="margin-left:11%; margin-top: 1em">NOTE: This
script is intended for use by core contributors only.</p>

<h2>OPTIONS
<a name="OPTIONS"></a>
</h2>



<p style="margin-left:11%; margin-top: 1em"><b>&minus;h</b>,
<b>&minus;&minus;help</b></p>

<p style="margin-left:22%;">print this help</p>

<p style="margin-left:11%;"><b>&minus;v</b>,
<b>&minus;&minus;verbose</b></p>

<p style="margin-left:22%;">run in verbose mode.</p>

<p style="margin-left:11%;"><b>&minus;n</b>,
<b>&minus;&minus;name</b> PORT_NAME</p>

<p style="margin-left:22%;">Name of the port (required)
e.g., curl, openssl (without &rsquo;port&rsquo; suffix)</p>

<p style="margin-left:11%;"><b>&minus;b</b>,
<b>&minus;&minus;build&minus;type</b> TYPE</p>

<p style="margin-left:22%;">Build type: stable or dev
(default: stable)</p>

<p style="margin-left:11%;"><b>&minus;s</b>,
<b>&minus;&minus;script</b> SCRIPT</p>

<p style="margin-left:22%;">Groovy script path in repo
(default: cicd&minus;stable.groovy)</p>

<p style="margin-left:11%;"><b>&minus;r</b>,
<b>&minus;&minus;run&minus;after</b> RUN</p>

<p style="margin-left:22%;">Trigger job after creation: yes
or no (default: yes)</p>


<p style="margin-left:11%;"><b>&minus;&minus;version</b></p>

<p style="margin-left:22%;">print version</p>


<p style="margin-left:11%; margin-top: 1em"><b>Example:</b></p>


<p style="margin-left:22%;">zopen&minus;create&minus;cicd&minus;job
<b>&minus;n</b> curl zopen&minus;create&minus;cicd&minus;job
<b>&minus;v &minus;n</b> pv <b>&minus;b</b> dev
<b>&minus;r</b> no zopen&minus;create&minus;cicd&minus;job
<b>&minus;n</b> openssl <b>&minus;b</b> stable
<b>&minus;s</b> cicd&minus;stable.groovy</p>

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
