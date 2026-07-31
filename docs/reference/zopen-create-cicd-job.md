<div v-pre class="man-page-content">

<div class="header-with-back">
  <div class="back-link">
    <a href="./zopen-reference">← Back</a>
  </div>
</div>

<h1 align="center">ZOPEN-CREATE-CICD-JOB</h1>

<h2>NAME</h2>

<p style="margin-left:11%; margin-top: 1em">zopen-create-cicd-job
&minus; manual page for zopen-create-cicd-job 0.8.4</p>

<h2>SYNOPSIS</h2>

<p style="margin-left:11%; margin-top: 1em">zopen-create-cicd-job
[OPTION] -n PORT_NAME</p>

<h2>DESCRIPTION</h2>

<p style="margin-left:11%; margin-top: 1em">zopen&minus;create&minus;cicd&minus;job
&minus; Create a Jenkins CI/CD job for a port.</p>

<p style="margin-left:11%; margin-top: 1em">NOTE: This
script is intended for use by core contributors only.</p>

<h2>OPTIONS</h2>















<table border="1" cellpadding="10" cellspacing="0" style="width:100%; border-collapse:collapse;">
<tr style="background-color:#f0f0f0;">
<th style="text-align:left; border: 1px solid #ccc;">Option</th>
<th style="text-align:left; border: 1px solid #ccc;">Description</th>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;h, &minus;&minus;help</code></td>
<td style="border: 1px solid #ccc;">print this help</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;v, &minus;&minus;verbose</code></td>
<td style="border: 1px solid #ccc;">run in verbose mode.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;n, &minus;&minus;name PORT_NAME</code></td>
<td style="border: 1px solid #ccc;">Name of the port (required) e.g., curl, openssl (without &rsquo;port&rsquo; suffix)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;b, &minus;&minus;build&minus;type TYPE</code></td>
<td style="border: 1px solid #ccc;">Build type: stable or dev (default: stable)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;s, &minus;&minus;script SCRIPT</code></td>
<td style="border: 1px solid #ccc;">Groovy script path in repo (default: cicd&minus;stable.groovy)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;r, &minus;&minus;run&minus;after RUN</code></td>
<td style="border: 1px solid #ccc;">Trigger job after creation: yes or no (default: yes)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;&minus;version</code></td>
<td style="border: 1px solid #ccc;">print version</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>Example:</code></td>
<td style="border: 1px solid #ccc;">zopen&minus;create&minus;cicd&minus;job &minus;n curl zopen&minus;create&minus;cicd&minus;job &minus;v &minus;n pv &minus;b dev &minus;r no zopen&minus;create&minus;cicd&minus;job &minus;n openssl &minus;b stable &minus;s cicd&minus;stable.groovy</td>
</tr>
</table>


<p style="margin-left:11%; margin-top: 1em">This is free
software: you are free to change and redistribute it under
the terms of the Apache License, Version 2.0.
<a href="https://www.apache.org/licenses/LICENSE-2.0.html" target="_blank">https://www.apache.org/licenses/LICENSE-2.0.html</a>
There is NO WARRANTY, to the extent permitted by law.</p>

<h2>AUTHOR</h2>

<p style="margin-left:11%; margin-top: 1em">Written by
contributors to the zopen community.
<a href="https://github.com/zopencommunity/meta/graphs/contributors" target="_blank">https://github.com/zopencommunity/meta/graphs/contributors</a></p>

</div>
