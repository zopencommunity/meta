<div v-pre class="man-page-content">

<div class="header-with-back">
  <div class="back-link">
    <a href="./zopen-reference">← Back</a>
  </div>
</div>

<h1 align="center">ZOPEN-BUILD</h1>

<h2>NAME</h2>

<p style="margin-left:11%; margin-top: 1em">zopen-build
&minus; manual page for zopen-build 0.8.4</p>

<h2>SYNOPSIS</h2>

<p style="margin-left:11%; margin-top: 1em">zopen-build
[OPTION]...</p>

<h2>DESCRIPTION</h2>

<p style="margin-left:11%; margin-top: 1em">zopen&minus;build
is a general purpose build script to be used with the zopen
community ports.</p>

<h3>Options</h3>

<table border="1" cellpadding="10" cellspacing="0" style="width:100%; border-collapse:collapse;">
<tr style="background-color:#f0f0f0;">
<th style="text-align:left; border: 1px solid #ccc;">Option</th>
<th style="text-align:left; border: 1px solid #ccc;">Description</th>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;&minus;build LINE</code></td>
<td style="border: 1px solid #ccc;">LINE may be dev or stable. This is the build line to build off of.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;&minus;buildtype TYPE</code></td>
<td style="border: 1px solid #ccc;">TYPE may be release or debug. The default is release.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;c, &minus;&minus;clean</code></td>
<td style="border: 1px solid #ccc;">Deletes all of the build output and forces reconfigure with next build.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;&minus;ccache</code></td>
<td style="border: 1px solid #ccc;">Enable ccache for clang builds to speed up recompilation.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;&minus;comp COMP</code></td>
<td style="border: 1px solid #ccc;">COMP may be xlclang, clang, go, java python. The default is clang.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;e ENV_FILE</code></td>
<td style="border: 1px solid #ccc;">source ENV_FILE instead of buildenv to establish build environment.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;E, &minus;&minus;editable</code></td>
<td style="border: 1px solid #ccc;">enable editing of the executable (adds &minus;Wl,&minus;bedit=yes to LDFLAGS).</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;&minus;instrument</code></td>
<td style="border: 1px solid #ccc;">instruments the application with option &minus;finstrument&minus;functions (clang only)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;f, &minus;&minus;force&minus;rebuild</code></td>
<td style="border: 1px solid #ccc;">forces a rebuild, including running bootstrap and configure again.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;&minus;forcepatchapply</code></td>
<td style="border: 1px solid #ccc;">force apply the patches, where rejected patches are placed into a corresponding file of the same name, with the .rej extension.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;g, &minus;&minus;get&minus;source</code></td>
<td style="border: 1px solid #ccc;">get the source and apply patch without building.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;gp, &minus;&minus;generate&minus;pax</code></td>
<td style="border: 1px solid #ccc;">generate a pax.Z file based on the install contents.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;h, &minus;&minus;help, &minus;?</code></td>
<td style="border: 1px solid #ccc;">print this information.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;&minus;no&minus;set&minus;active</code></td>
<td style="border: 1px solid #ccc;">do not change the pinned version.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;&minus;no&minus;install&minus;deps</code></td>
<td style="border: 1px solid #ccc;">do not install project&rsquo;s runtime dependencies.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;&minus;oci</code></td>
<td style="border: 1px solid #ccc;">build and publish an OCI image to $ZOPEN_IMAGE_REGISTRY.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;s</code></td>
<td style="border: 1px solid #ccc;">exec a shell before running configure. Useful when manually building ports.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;&minus;sign&minus;pax, &minus;sp</code></td>
<td style="border: 1px solid #ccc;">This option signs the pax file. ZOPEN_GPG_SECRET_KEY_FILE, ZOPEN_GPG_SECRET_KEY_PASSPHRASE_FILE and ZOPEN_GPG_PUBLIC_KEY_FILE must be set for signing the file.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;v</code></td>
<td style="border: 1px solid #ccc;">run in verbose mode.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;vv</code></td>
<td style="border: 1px solid #ccc;">run in very verbose mode (sets environment variables V=1 and VERBOSE=1).</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;u, &minus;&minus;upgradedeps</code></td>
<td style="border: 1px solid #ccc;">upgrade all dependencies by running zopen install.</td>
</tr>
</table>

<p style="margin-left:11%; margin-top: 1em">The specifics
of how the tool works can be controlled through environment
variables. The only environment variables you _must_ specify
are to tell zopen&minus;build where the source is, and in
what format type the source is stored. By default, the
environment variables are defined in a file named buildenv
in the root directory of the [PACKAGE]port github
repository.</p>

<p style="margin-left:11%; margin-top: 1em">To see a fully
functioning zopen community sample port see:
<a href="https://github.com/zopencommunity/zotsampleport" target="_blank">https://github.com/zopencommunity/zotsampleport</a></p>

<h3>Environment Variables</h3>

<h4>Required</h4>

<table border="1" cellpadding="10" cellspacing="0" style="width:100%; border-collapse:collapse;">
<tr style="background-color:#f0f0f0;">
<th style="text-align:left; border: 1px solid #ccc;">Variable</th>
<th style="text-align:left; border: 1px solid #ccc;">Description</th>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_BUILD_LINE</code></td>
<td style="border: 1px solid #ccc;">Specify the default build line, either &rsquo;DEV&rsquo; or &rsquo;STABLE&rsquo;</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_CATEGORIES</code></td>
<td style="border: 1px solid #ccc;">Specify a space&minus;delimited list of applicable categories. Valid categories: (&rsquo;security development language ai core utilities editor source_control networking webframework database devops graphics math testing documentation library compression json monitoring shell build_system ai&rsquo;)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_DEV_DEPS</code></td>
<td style="border: 1px solid #ccc;">Required IF ZOPEN_BUILD_LINE=&rsquo;DEV&rsquo;. Specify the dev build dependencies</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_DEV_URL</code></td>
<td style="border: 1px solid #ccc;">Required IF ZOPEN_BUILD_LINE=&rsquo;DEV&rsquo;. Specify the dev build URL (either git or tarball).</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_STABLE_DEPS</code></td>
<td style="border: 1px solid #ccc;">Required IF ZOPEN_BUILD_LINE=&rsquo;STABLE&rsquo;. Specify the stable build dependencies.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_STABLE_URL</code></td>
<td style="border: 1px solid #ccc;">Required IF ZOPEN_BUILD_LINE=&rsquo;STABLE&rsquo;. Specify the stable build URL (either git or tarball).</td>
</tr>
</table>

<h4>Optional - Compiler Flags</h4>

<table border="1" cellpadding="10" cellspacing="0" style="width:100%; border-collapse:collapse;">
<tr style="background-color:#f0f0f0;">
<th style="text-align:left; border: 1px solid #ccc;">Variable</th>
<th style="text-align:left; border: 1px solid #ccc;">Description</th>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_EXTRA_CFLAGS</code></td>
<td style="border: 1px solid #ccc;">C compiler flags to append to CFLAGS (defaults to &rsquo;&rsquo;).</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_EXTRA_CPPFLAGS</code></td>
<td style="border: 1px solid #ccc;">C,C++ pre&minus;processor flags to append to CPPFLAGS. (defaults to &rsquo;&rsquo;)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_EXTRA_CXXFLAGS</code></td>
<td style="border: 1px solid #ccc;">C++ compiler flags to append to CXXFLAGS. (defaults to &rsquo;&rsquo;)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_EXTRA_LDFLAGS</code></td>
<td style="border: 1px solid #ccc;">C,C++ linker flags to append to LDFLAGS. (defaults to &rsquo;&rsquo;)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_EXTRA_LIBS</code></td>
<td style="border: 1px solid #ccc;">C,C++ libraries to append to LIBS. (defaults to &rsquo;&rsquo;)</td>
</tr>
</table>

<h4>Optional - Build Programs</h4>

<table border="1" cellpadding="10" cellspacing="0" style="width:100%; border-collapse:collapse;">
<tr style="background-color:#f0f0f0;">
<th style="text-align:left; border: 1px solid #ccc;">Variable</th>
<th style="text-align:left; border: 1px solid #ccc;">Description</th>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_BOOTSTRAP</code></td>
<td style="border: 1px solid #ccc;">Bootstrap program to run. If skip is specified, no bootstrap step is performed. (defaults to &rsquo;./bootstrap&rsquo;)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_BOOTSTRAP_OPTS</code></td>
<td style="border: 1px solid #ccc;">Options to pass to bootstrap program. (defaults to &rsquo;&rsquo;)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_CHECK</code></td>
<td style="border: 1px solid #ccc;">Check program to run. If skip is specified, no check step is performed. (defaults to &rsquo;make&rsquo;)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_CHECK_MINIMAL</code></td>
<td style="border: 1px solid #ccc;">Check program will not be passed CFLAGS, LDFLAGS, CPPFLAGS options but will get them from env vars.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_CHECK_OPTS</code></td>
<td style="border: 1px solid #ccc;">Options to pass to check program. (defaults to &rsquo;check&rsquo;)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_CHECK_TIMEOUT</code></td>
<td style="border: 1px solid #ccc;">Timeout limit in seconds for the check program. (defaults to &rsquo;12600&rsquo;)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_CLEAN</code></td>
<td style="border: 1px solid #ccc;">Clean up program to run. (defaults to &rsquo;make&rsquo;)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_CLEAN_OPTS</code></td>
<td style="border: 1px solid #ccc;">Options to pass to clean up program. (defaults to &rsquo;clean&rsquo;)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_CONFIGURE</code></td>
<td style="border: 1px solid #ccc;">Configuration program to run. If skip is specified, no configuration step is performed. (defaults to &rsquo;./configure&rsquo;)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_CONFIGURE_MINIMAL</code></td>
<td style="border: 1px solid #ccc;">Configuration program will not be passed CFLAGS, LDFLAGS, CPPFLAGS options but will get them from env vars.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_CONFIGURE_OPTS</code></td>
<td style="border: 1px solid #ccc;">Options to pass to configuration program. (defaults to &rsquo;&minus;&minus;prefix=${ZOPEN_INSTALL_DIR}&rsquo;)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_EXTRA_CONFIGURE_OPTS</code></td>
<td style="border: 1px solid #ccc;">Extra configure options to pass to configuration program. (defaults to &rsquo;&rsquo;)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_INSTALL</code></td>
<td style="border: 1px solid #ccc;">Installation program to run. If skip is specified, no installation step is performed. (defaults to &rsquo;make&rsquo;)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_INSTALL_OPTS</code></td>
<td style="border: 1px solid #ccc;">Options to pass to installation program. (defaults to &rsquo;install&rsquo;)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_MAKE</code></td>
<td style="border: 1px solid #ccc;">Build program to run. If skip is specified, no build step is performed. (defaults to &rsquo;make&rsquo;)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_MAKE_MINIMAL</code></td>
<td style="border: 1px solid #ccc;">Build program will not be passed CFLAGS, LDFLAGS, CPPFLAGS options but will get them from env vars.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_MAKE_OPTS</code></td>
<td style="border: 1px solid #ccc;">Options to pass to build program. (defaults to &rsquo;&minus;j${ZOPEN_NUM_JOBS}&rsquo;)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_PATCH_DIR</code></td>
<td style="border: 1px solid #ccc;">Specify directory from which patches should be applied.</td>
</tr>
</table>

<h4>Optional - Runtime & System</h4>

<table border="1" cellpadding="10" cellspacing="0" style="width:100%; border-collapse:collapse;">
<tr style="background-color:#f0f0f0;">
<th style="text-align:left; border: 1px solid #ccc;">Variable</th>
<th style="text-align:left; border: 1px solid #ccc;">Description</th>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_RUNTIME_DEPS</code></td>
<td style="border: 1px solid #ccc;">Runtime z/OS Open Tool dependencies to be installed alongside the tool.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_SYSTEM_PREREQ</code></td>
<td style="border: 1px solid #ccc;">System prerequisites, supply the name of the prereq scripts under /var/lib/jenkins/workspace/Port&minus;Update&minus;Nightly/meta_update/bin/../include/prereq.sh</td>
</tr>
</table>

<h4>Restricted</h4>

<table border="1" cellpadding="10" cellspacing="0" style="width:100%; border-collapse:collapse;">
<tr style="background-color:#f0f0f0;">
<th style="text-align:left; border: 1px solid #ccc;">Variable</th>
<th style="text-align:left; border: 1px solid #ccc;">Description</th>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_DONT_ADD_ZOSLIB_DEP</code></td>
<td style="border: 1px solid #ccc;">Set to avoid adding zoslib as a dependency.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_INSTALL_DIR</code></td>
<td style="border: 1px solid #ccc;">Installation directory to pass to configuration. (defaults to &rsquo;${ZOPEN_PKGINSTALL}/&lt;pkg&gt;/&lt;pkg&gt;&rsquo;)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_NUM_JOBS</code></td>
<td style="border: 1px solid #ccc;">Number of jobs that can be run in parallel (defaults to half the CPUs on the system)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_CFLAGS</code></td>
<td style="border: 1px solid #ccc;">C compiler flags. (default set by dependency)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_CPPFLAGS</code></td>
<td style="border: 1px solid #ccc;">C/C++ pre&minus;processor flags. (default set by dependency)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_CXXFLAGS</code></td>
<td style="border: 1px solid #ccc;">C++ compiler flags. (default set by dependency)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_LDFLAGS</code></td>
<td style="border: 1px solid #ccc;">C/C++ linker flags. (default set by dependency)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_GIT_SETUP</code></td>
<td style="border: 1px solid #ccc;">Specify whether git files should be added to a local repo or if this will be done manually. (defaults to Y)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_SRC_DIR</code></td>
<td style="border: 1px solid #ccc;">Specify a relative source directory to cd to for bootstrap, configure, build, check, install. (defaults to &rsquo;.&rsquo;)</td>
</tr>
</table>

<h4>Image Configuration</h4>

<table border="1" cellpadding="10" cellspacing="0" style="width:100%; border-collapse:collapse;">
<tr style="background-color:#f0f0f0;">
<th style="text-align:left; border: 1px solid #ccc;">Variable</th>
<th style="text-align:left; border: 1px solid #ccc;">Description</th>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_IMAGE_DOCKERFILE_NAME</code></td>
<td style="border: 1px solid #ccc;">Dockerfile name. (default: Dockerfile)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_IMAGE_DOCKER_NAME</code></td>
<td style="border: 1px solid #ccc;">Docker/podman tool name. (default: podman)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_IMAGE_REGISTRY</code></td>
<td style="border: 1px solid #ccc;">Docker image registry to an OCI image to (use with &minus;&minus;oci option)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_IMAGE_REGISTRY_ID</code></td>
<td style="border: 1px solid #ccc;">The ID to authenticate to the Docker image registry. (use with &minus;&minus;oci option)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_IMAGE_REGISTRY_KEY_FILE</code></td>
<td style="border: 1px solid #ccc;">The file containing authentication key to the Docker image registry. (use with &minus;&minus;oci option)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_LOG_DIR</code></td>
<td style="border: 1px solid #ccc;">The directory to store build logs. (defaults to &rsquo;/log&rsquo;)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_SHELL</code></td>
<td style="border: 1px solid #ccc;">Specify an alternate shell to use if &minus;s option specified. (defaults to /bin/sh)</td>
</tr>
</table>

<h4>Git Configuration</h4>

<table border="1" cellpadding="10" cellspacing="0" style="width:100%; border-collapse:collapse;">
<tr style="background-color:#f0f0f0;">
<th style="text-align:left; border: 1px solid #ccc;">Variable</th>
<th style="text-align:left; border: 1px solid #ccc;">Description</th>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_DEV_BRANCH</code></td>
<td style="border: 1px solid #ccc;">The branch that the git repo should checkout. (default is repo default)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_DEV_TAG</code></td>
<td style="border: 1px solid #ccc;">The tag that the git repo should checkout as a branch. (optional)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_STABLE_BRANCH</code></td>
<td style="border: 1px solid #ccc;">The branch that the stable repo should checkout. (default is repo default)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_STABLE_TAG</code></td>
<td style="border: 1px solid #ccc;">The tag that the git repo should checkout as a branch. (optional)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_CLONE_SUBMODULES</code></td>
<td style="border: 1px solid #ccc;">Set to yes to recursively clone submodules.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_CLONE_FULL</code></td>
<td style="border: 1px solid #ccc;">Set to yes to perform a full clone as opposed to the default shallow clone (depth of 1).</td>
</tr>
</table>

<h4>Package Type Configuration</h4>

<table border="1" cellpadding="10" cellspacing="0" style="width:100%; border-collapse:collapse;">
<tr style="background-color:#f0f0f0;">
<th style="text-align:left; border: 1px solid #ccc;">Variable</th>
<th style="text-align:left; border: 1px solid #ccc;">Description</th>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_DEV_TYPE</code></td>
<td style="border: 1px solid #ccc;">The type of package to download. Valid types are TARBALL, BARE and GIT.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_STABLE_TYPE</code></td>
<td style="border: 1px solid #ccc;">The type of package to download. Valid types are TARBALL, BARE and GIT.</td>
</tr>
</table>

<h4>Deprecated</h4>

<table border="1" cellpadding="10" cellspacing="0" style="width:100%; border-collapse:collapse;">
<tr style="background-color:#f0f0f0;">
<th style="text-align:left; border: 1px solid #ccc;">Variable</th>
<th style="text-align:left; border: 1px solid #ccc;">Description</th>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_CC</code></td>
<td style="border: 1px solid #ccc;">C compiler. (default set by dependency)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_CXX</code></td>
<td style="border: 1px solid #ccc;">C++ compiler. (default set by dependency)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_DEPS</code></td>
<td style="border: 1px solid #ccc;">Alternate environment variable instead of ZOPEN_TARBALL_DEPS or ZOPEN_GIT_DEPS.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_GIT_BRANCH</code></td>
<td style="border: 1px solid #ccc;">The branch that the git repo should checkout.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_GIT_DEPS</code></td>
<td style="border: 1px solid #ccc;">Space&minus;delimited set of source packages this tarball package depends on to build. (required if ZOPEN_TYPE=GIT)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_GIT_TAG</code></td>
<td style="border: 1px solid #ccc;">The tag that the git repo should checkout as a branch.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_GIT_URL</code></td>
<td style="border: 1px solid #ccc;">The fully qualified URL that the git repo should be cloned from. (required if ZOPEN_TYPE=GIT)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_LIBS</code></td>
<td style="border: 1px solid #ccc;">C/C++ libraries (default set by dependency)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_TARBALL_DEPS</code></td>
<td style="border: 1px solid #ccc;">Space&minus;delimited set of source packages this git package depends on to build. (required if ZOPEN_TYPE=TARBALL)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_TARBALL_URL</code></td>
<td style="border: 1px solid #ccc;">The fully qualified URL that the tarball should be downloaded from. (required if ZOPEN_TYPE=TARBALL)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_TYPE</code></td>
<td style="border: 1px solid #ccc;">The type of package to download. Valid types are TARBALL, BARE and GIT.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>ZOPEN_URL</code></td>
<td style="border: 1px solid #ccc;">Alternate environment variable instead of ZOPEN_TARBALL_URL or ZOPEN_GIT_URL.</td>
</tr>
</table>

<h3>User-Provided Functions</h3>

<h4>Required</h4>

<table border="1" cellpadding="10" cellspacing="0" style="width:100%; border-collapse:collapse;">
<tr style="background-color:#f0f0f0;">
<th style="text-align:left; border: 1px solid #ccc;">Function</th>
<th style="text-align:left; border: 1px solid #ccc;">Description</th>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>zopen_check_results</code></td>
<td style="border: 1px solid #ccc;">This function runs after the &rsquo;check&rsquo; step of the build and must print out expected and actual failures.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>zopen_get_version</code></td>
<td style="border: 1px solid #ccc;">This function returns the version of the tool in accordance with semantic versioning.</td>
</tr>
</table>

<h4>Optional</h4>

<table border="1" cellpadding="10" cellspacing="0" style="width:100%; border-collapse:collapse;">
<tr style="background-color:#f0f0f0;">
<th style="text-align:left; border: 1px solid #ccc;">Function</th>
<th style="text-align:left; border: 1px solid #ccc;">Description</th>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>zopen_append_to_env</code></td>
<td style="border: 1px solid #ccc;">This function runs as part of generation of the .env file. The output of the function is appended to .env.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>zopen_append_to_setup</code></td>
<td style="border: 1px solid #ccc;">This function runs as part of generation of the setup.sh file. The output of the function is appended to setup.sh.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>zopen_append_to_validate_install</code></td>
<td style="border: 1px solid #ccc;">This function runs as part of generation of the install_test.sh file. The output of the function is appended to install_test.sh script.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>zopen_install_caveats</code></td>
<td style="border: 1px solid #ccc;">This function is run post install. All stdout messages are captured and added to the metadata.json as installation caveats.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>zopen_append_to_zoslib_env</code></td>
<td style="border: 1px solid #ccc;">This function runs as part of generation of the C function zoslib_env_hook, which can be used to set environment variables before main is run.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>zopen_init</code></td>
<td style="border: 1px solid #ccc;">This function runs after code is downloaded and patched but before the code is built.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>zopen_post_buildenv</code></td>
<td style="border: 1px solid #ccc;">This function runs after the &rsquo;buildenv&rsquo; is processed.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>zopen_post_extract</code></td>
<td style="border: 1px solid #ccc;">This function runs when an archive containing the source to build has been uncompressed.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>zopen_post_install</code></td>
<td style="border: 1px solid #ccc;">This function runs after the &rsquo;install&rsquo; step of the build is run.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>zopen_pre_build</code></td>
<td style="border: 1px solid #ccc;">This function runs before the &rsquo;make&rsquo; step of the build is run.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>zopen_pre_check</code></td>
<td style="border: 1px solid #ccc;">This function runs before the &rsquo;check&rsquo; step of the build is run.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>zopen_pre_configure</code></td>
<td style="border: 1px solid #ccc;">This function runs before the &rsquo;configure&rsquo; step of the build is run.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>zopen_pre_install</code></td>
<td style="border: 1px solid #ccc;">This function runs before the &rsquo;install&rsquo; step of the build is run.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>zopen_pre_patch</code></td>
<td style="border: 1px solid #ccc;">This function runs before the &rsquo;patch&rsquo; step of the build is run.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>zopen_pre_terminate</code></td>
<td style="border: 1px solid #ccc;">This function runs before &rsquo;zopen build&rsquo; terminates.</td>
</tr>
</table>

<h2>SEE ALSO</h2>

<p style="margin-left:11%; margin-top: 1em">zopen(1) zopen&minus;alt(1)
zopen&minus;init(1) zopen&minus;install(1)
zopen&minus;list(1) zopen&minus;remove(1)</p>

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
