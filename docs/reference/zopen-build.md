<div v-pre class="man-page-content">

<div class="header-with-back"><div class="link" style="float: left;"><a href="./zopen-audit">← Previous</a></div><div class='link' style='float: right;'><a href='./zopen-clean'>Next →</a></div><div style="clear: both;"></div></div>


<h1 align="center">ZOPEN-BUILD</h1>




<h2>NAME</h2>


<p style="margin-left:6%; margin-top: 1em">zopen-build -
manual page for zopen-build 0.8.5</p>

<h2>SYNOPSIS</h2>



<p style="margin-left:6%; margin-top: 1em">zopen-build
[OPTION]...</p>

<h2>DESCRIPTION</h2>


<p style="margin-left:6%; margin-top: 1em">zopen-build is a
general purpose build script to be used with the zopen
community ports.</p>

<h3>Option:</h3>


<p style="margin-left:6%; margin-top: 1em">--build
LINE</p>

<p style="margin-left:15%;">LINE may be dev or stable. This
is the build line to build off of.</p>

<p style="margin-left:6%;">--buildtype TYPE</p>

<p style="margin-left:15%;">TYPE may be release or debug.
The default is release.</p>

<p style="margin-left:6%;">-c, --clean</p>

<p style="margin-left:15%;">Deletes all of the build output
and forces reconfigure with next build.</p>

<p style="margin-left:6%;">--ccache</p>

<p style="margin-left:15%;">Enable ccache for clang builds
to speed up recompilation.</p>

<p style="margin-left:6%;">--comp COMP</p>

<p style="margin-left:15%;">COMP may be xlclang, clang, go,
java python. The default is clang.</p>

<p style="margin-left:6%;">-e ENV_FILE</p>

<p style="margin-left:15%;">source ENV_FILE instead of
buildenv to establish build environment.</p>

<p style="margin-left:6%;">-E, --editable</p>

<p style="margin-left:15%;">enable editing of the
executable (adds -Wl,-bedit=yes to LDFLAGS).</p>

<p style="margin-left:6%;">--instrument</p>

<p style="margin-left:15%;">instruments the application
with option -finstrument-functions (clang only)</p>

<p style="margin-left:6%;">-f,
--force-rebuild</p>

<p style="margin-left:15%;">forces a rebuild, including
running bootstrap and configure again.</p>

<p style="margin-left:6%;">--forcepatchapply</p>

<p style="margin-left:15%;">force apply the patches, where
rejected patches are placed into a corresponding file of the
same name, with the .rej extension.</p>

<p style="margin-left:6%;">-g,
--get-source</p>

<p style="margin-left:15%;">get the source and apply patch
without building.</p>

<p style="margin-left:6%;">-gp,
--generate-pax</p>

<p style="margin-left:15%;">generate a pax.Z file based on
the install contents.</p>

<p style="margin-left:6%;">-gr,
--generate-rpm</p>

<p style="margin-left:15%;">generate an RPM package from
the pax archive.</p>

<p style="margin-left:6%;">-h, --help, -?</p>

<p style="margin-left:15%;">print this information.</p>

<p style="margin-left:6%;">--no-set-active</p>

<p style="margin-left:15%;">do not change the pinned
version.</p>

<p style="margin-left:6%;">--no-install-deps</p>

<p style="margin-left:15%;">do not install project's
runtime dependencies.</p>


<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">

<tr valign="top" align="left">

<td width="6%"></td>


<td width="7%">


<p>--oci</p></td>


<td width="2%"></td>


<td width="85%">


<p>build and publish an OCI image to
$ZOPEN_IMAGE_REGISTRY.</p></td>
</tr>


<tr valign="top" align="left">

<td width="6%"></td>


<td width="7%">


<p style="margin-top: 1em">-s</p></td>


<td width="2%"></td>


<td width="85%">


<p style="margin-top: 1em">exec a shell before running
configure. Useful when manually building ports.</p></td>
</tr>

</table>


<p style="margin-left:6%;">--sign-pax,
-sp</p>

<p style="margin-left:15%;">This option signs the pax file.
ZOPEN_GPG_SECRET_KEY_FILE,
ZOPEN_GPG_SECRET_KEY_PASSPHRASE_FILE and
ZOPEN_GPG_PUBLIC_KEY_FILE must be set for signing the
file.</p>


<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">

<tr valign="top" align="left">

<td width="6%"></td>


<td width="4%">


<p>-v</p></td>


<td width="5%"></td>


<td width="85%">


<p>run in verbose mode.</p></td>
</tr>


<tr valign="top" align="left">

<td width="6%"></td>


<td width="4%">


<p style="margin-top: 1em">-vv</p></td>


<td width="5%"></td>


<td width="85%">


<p style="margin-top: 1em">run in very verbose mode (sets
environment variables V=1 and VERBOSE=1).</p></td>
</tr>

</table>


<p style="margin-left:6%;">-u,
--upgradedeps</p>

<p style="margin-left:15%;">upgrade all dependencies by
running zopen install.</p>

<p style="margin-left:6%; margin-top: 1em">The specifics of
how the tool works can be controlled through environment
variables. The only environment variables you _must_ specify
are to tell zopen-build where the source is, and in what
format type the source is stored. By default, the
environment variables are defined in a file named buildenv
in the root directory of the [PACKAGE]port github
repository.</p>

<p style="margin-left:6%; margin-top: 1em">To see a fully
functioning zopen community sample port see:
https://github.com/zopencommunity/zotsampleport</p>

<p style="margin-left:6%; margin-top: 1em">User-Provided
environment variables:</p>

<h3>Required:</h3>



<p style="margin-left:6%; margin-top: 1em">ZOPEN_BUILD_LINE</p>

<p style="margin-left:15%;">Specify the default build line,
either 'DEV' or 'STABLE'</p>

<p style="margin-left:6%;">ZOPEN_CATEGORIES</p>

<p style="margin-left:15%;">Specify a space-delimited list
of applicable categories. Valid categories: ('security
development language ai core utilities editor source_control
networking webframework database devops graphics math
testing documentation library compression json monitoring
shell build_system ai')</p>

<p style="margin-left:6%;">ZOPEN_DEV_DEPS</p>

<p style="margin-left:15%;">Required IF
ZOPEN_BUILD_LINE='DEV'. Specify the dev build
dependencies</p>

<p style="margin-left:6%;">ZOPEN_DEV_URL</p>

<p style="margin-left:15%;">Required IF
ZOPEN_BUILD_LINE='DEV'. Specify the dev build
URL (either git or tarball).</p>

<p style="margin-left:6%;">ZOPEN_STABLE_DEPS</p>

<p style="margin-left:15%;">Required IF
ZOPEN_BUILD_LINE='STABLE'. Specify the stable
build dependencies.</p>

<p style="margin-left:6%;">ZOPEN_STABLE_URL</p>

<p style="margin-left:15%;">Required IF
ZOPEN_BUILD_LINE='STABLE'. Specify the stable
build URL (either git or tarball).</p>

<h3>Optional:</h3>



<p style="margin-left:6%; margin-top: 1em">ZOPEN_SOURCE_URL</p>

<p style="margin-left:15%;">If set, use this as ZOPEN_URL
before checking ZOPEN_DEV_URL or ZOPEN_STABLE_URL.</p>

<p style="margin-left:6%;">ZOPEN_EXTRA_CFLAGS</p>

<p style="margin-left:15%;">C compiler flags to append to
CFLAGS (defaults to '').</p>

<p style="margin-left:6%;">ZOPEN_EXTRA_CPPFLAGS</p>

<p style="margin-left:15%;">C,C++ pre-processor flags to
append to CPPFLAGS. (defaults to '')</p>

<p style="margin-left:6%;">ZOPEN_EXTRA_CXXFLAGS</p>

<p style="margin-left:15%;">C++ compiler flags to append to
CXXFLAGS. (defaults to '')</p>

<p style="margin-left:6%;">ZOPEN_EXTRA_LDFLAGS</p>

<p style="margin-left:15%;">C,C++ linker flags to append to
LDFLAGS. (defaults to '')</p>

<p style="margin-left:6%;">ZOPEN_EXTRA_LIBS</p>

<p style="margin-left:15%;">C,C++ libraries to append to
LIBS. (defaults to '')</p>

<p style="margin-left:6%;">ZOPEN_BOOTSTRAP</p>

<p style="margin-left:15%;">Bootstrap program to run. If
skip is specified, no bootstrap step is performed. (defaults
to './bootstrap')</p>

<p style="margin-left:6%;">ZOPEN_BOOTSTRAP_OPTS</p>

<p style="margin-left:15%;">Options to pass to bootstrap
program. (defaults to '')</p>

<p style="margin-left:6%;">ZOPEN_CHECK</p>

<p style="margin-left:15%;">Check program to run. If skip
is specified, no check step is performed. (defaults to
'make')</p>

<p style="margin-left:6%;">ZOPEN_CHECK_MINIMAL</p>

<p style="margin-left:15%;">Check program will not be
passed CFLAGS, LDFLAGS, CPPFLAGS options but will get them
from env vars.</p>

<p style="margin-left:6%;">ZOPEN_CHECK_OPTS</p>

<p style="margin-left:15%;">Options to pass to check
program. (defaults to 'check')</p>

<p style="margin-left:6%;">ZOPEN_CHECK_TIMEOUT</p>

<p style="margin-left:15%;">Timeout limit in seconds for
the check program. (defaults to '12600')</p>

<p style="margin-left:6%;">ZOPEN_CLEAN</p>

<p style="margin-left:15%;">Clean up program to run.
(defaults to 'make')</p>

<p style="margin-left:6%;">ZOPEN_CLEAN_OPTS</p>

<p style="margin-left:15%;">Options to pass to clean up
program. (defaults to 'clean')</p>

<p style="margin-left:6%;">ZOPEN_CONFIGURE</p>

<p style="margin-left:15%;">Configuration program to run.
If skip is specified, no configuration step is performed.
(defaults to './configure')</p>

<p style="margin-left:6%;">ZOPEN_CONFIGURE_MINIMAL</p>

<p style="margin-left:15%;">Configuration program will not
be passed CFLAGS, LDFLAGS, CPPFLAGS options but will get
them from env vars.</p>

<p style="margin-left:6%;">ZOPEN_CONFIGURE_OPTS</p>

<p style="margin-left:15%;">Options to pass to
configuration program. (defaults to
'--prefix=${ZOPEN_INSTALL_DIR}')</p>

<p style="margin-left:6%;">ZOPEN_EXTRA_CONFIGURE_OPTS</p>

<p style="margin-left:15%;">Extra configure options to pass
to configuration program. (defaults to '')</p>

<p style="margin-left:6%;">ZOPEN_INSTALL</p>

<p style="margin-left:15%;">Installation program to run. If
skip is specified, no installation step is performed.
(defaults to 'make')</p>

<p style="margin-left:6%;">ZOPEN_INSTALL_OPTS</p>

<p style="margin-left:15%;">Options to pass to installation
program. (defaults to 'install')</p>

<p style="margin-left:6%;">ZOPEN_MAKE</p>

<p style="margin-left:15%;">Build program to run. If skip
is specified, no build step is performed. (defaults to
'make')</p>

<p style="margin-left:6%;">ZOPEN_MAKE_MINIMAL</p>

<p style="margin-left:15%;">Build program will not be
passed CFLAGS, LDFLAGS, CPPFLAGS options but will get them
from env vars.</p>

<p style="margin-left:6%;">ZOPEN_MAKE_OPTS</p>

<p style="margin-left:15%;">Options to pass to build
program. (defaults to '-j${ZOPEN_NUM_JOBS}')</p>

<p style="margin-left:6%;">ZOPEN_PATCH_DIR</p>

<p style="margin-left:15%;">Specify directory from which
patches should be applied.</p>

<h3>Optional settings for installation:</h3>



<p style="margin-left:6%; margin-top: 1em">ZOPEN_RUNTIME_DEPS</p>

<p style="margin-left:15%;">Runtime z/OS Open Tool
dependencies to be installed alongside the tool.</p>

<p style="margin-left:6%;">ZOPEN_SETUP_NO_REPLACE</p>

<p style="margin-left:15%;">If set, do not replace
hardcoded paths with placeholders.</p>

<p style="margin-left:6%;">ZOPEN_SYSTEM_PREREQ</p>

<p style="margin-left:15%;">System prerequisites, supply
the name of the prereq scripts under
/Users/tejaswini/Documents/tejaswini/zopen/meta_fork/meta/bin/../include/prereq.sh</p>

<p style="margin-left:6%; margin-top: 1em">Restricted Usage
ZOPEN_DONT_ADD_ZOSLIB_DEP</p>

<p style="margin-left:15%;">Set to avoid adding zoslib as a
dependency.</p>

<h3>Restricted Usage - only SET by metaport, otherwise READ ONLY:</h3>



<p style="margin-left:6%; margin-top: 1em">ZOPEN_INSTALL_DIR</p>

<p style="margin-left:15%;">Installation directory to pass
to configuration. (defaults to
'${ZOPEN_PKGINSTALL}/&lt;pkg&gt;/&lt;pkg&gt;')</p>

<p style="margin-left:6%;">ZOPEN_NUM_JOBS</p>

<p style="margin-left:15%;">Number of jobs that can be run
in parallel (defaults to half the CPUs on the system)</p>

<h3>Restricted Usage (clang):</h3>



<p style="margin-left:6%; margin-top: 1em">ZOPEN_CFLAGS</p>

<p style="margin-left:15%;">C compiler flags. (default set
by dependency)</p>

<p style="margin-left:6%;">ZOPEN_CPPFLAGS</p>

<p style="margin-left:15%;">C/C++ pre-processor flags.
(default set by dependency)</p>

<p style="margin-left:6%;">ZOPEN_CXXFLAGS</p>

<p style="margin-left:15%;">C++ compiler flags. (default
set by dependency)</p>

<p style="margin-left:6%;">ZOPEN_LDFLAGS</p>

<p style="margin-left:15%;">C/C++ linker flags. (default
set by dependency)</p>

<h3>Restricted Usage (phpport):</h3>



<p style="margin-left:6%; margin-top: 1em">ZOPEN_GIT_SETUP</p>

<p style="margin-left:15%;">Specify whether git files
should be added to a local repo or if this will be done
manually. (defaults to Y)</p>

<h3>Restricted Usage (tclport):</h3>



<p style="margin-left:6%; margin-top: 1em">ZOPEN_SRC_DIR</p>

<p style="margin-left:15%;">Specify a relative source
directory to cd to for bootstrap, configure, build, check,
install. (defaults to '.')</p>

<h3>Restricted Usage (meta):</h3>



<p style="margin-left:6%; margin-top: 1em">ZOPEN_IMAGE_DOCKERFILE_NAME</p>

<p style="margin-left:15%;">Dockerfile name. (default:
Dockerfile)</p>

<p style="margin-left:6%;">ZOPEN_IMAGE_DOCKER_NAME</p>

<p style="margin-left:15%;">Docker/podman tool name.
(default: podman)</p>

<p style="margin-left:6%;">ZOPEN_IMAGE_REGISTRY</p>

<p style="margin-left:15%;">Docker image registry to an OCI
image to (use with --oci option)</p>

<p style="margin-left:6%;">ZOPEN_IMAGE_REGISTRY_ID</p>

<p style="margin-left:15%;">The ID to authenticate to the
Docker image registry. (use with --oci option)</p>


<p style="margin-left:6%;">ZOPEN_IMAGE_REGISTRY_KEY_FILE</p>

<p style="margin-left:15%;">The file containing
authentication key to the Docker image registry. (use with
--oci option)</p>

<p style="margin-left:6%;">ZOPEN_LOG_DIR</p>

<p style="margin-left:15%;">The directory to store build
logs. (defaults to '/log')</p>

<p style="margin-left:6%;">ZOPEN_SHELL</p>

<p style="margin-left:15%;">Specify an alternate shell to
use if -s option specified. (defaults to
/bin/sh)</p>

<h3>Git variables:</h3>



<p style="margin-left:6%; margin-top: 1em">ZOPEN_DEV_BRANCH</p>

<p style="margin-left:15%;">The branch that the git repo
should checkout. (default is repo default)</p>

<p style="margin-left:6%;">ZOPEN_DEV_TAG</p>

<p style="margin-left:15%;">The tag that the git repo
should checkout as a branch. (optional)</p>

<p style="margin-left:6%;">ZOPEN_STABLE_BRANCH</p>

<p style="margin-left:15%;">The branch that the stable repo
should checkout. (default is repo default)</p>

<p style="margin-left:6%;">ZOPEN_STABLE_TAG</p>

<p style="margin-left:15%;">The tag that the git repo
should checkout as a branch. (optional)</p>

<p style="margin-left:6%;">ZOPEN_CLONE_SUBMODULES</p>

<p style="margin-left:15%;">Set to yes to recursively clone
submodules.</p>

<p style="margin-left:6%;">ZOPEN_CLONE_FULL</p>

<p style="margin-left:15%;">Set to yes to perform a full
clone as opposed to the default shallow clone (depth of
1).</p>

<h3>Currently unused:</h3>



<p style="margin-left:6%; margin-top: 1em">ZOPEN_DEV_TYPE</p>

<p style="margin-left:15%;">The type of package to
download. Valid types are TARBALL, BARE and GIT.</p>

<p style="margin-left:6%;">ZOPEN_STABLE_TYPE</p>

<p style="margin-left:15%;">The type of package to
download. Valid types are TARBALL, BARE and GIT.</p>

<h3>Deprecated:</h3>


<p style="margin-left:6%; margin-top: 1em">ZOPEN_CC</p>

<p style="margin-left:15%;">C compiler. (default set by
dependency)</p>

<p style="margin-left:6%;">ZOPEN_CXX</p>

<p style="margin-left:15%;">C++ compiler. (default set by
dependency)</p>

<p style="margin-left:6%;">ZOPEN_DEPS</p>

<p style="margin-left:15%;">Alternate environment variable
instead of ZOPEN_TARBALL_DEPS or ZOPEN_GIT_DEPS.</p>

<p style="margin-left:6%;">ZOPEN_GIT_BRANCH</p>

<p style="margin-left:15%;">The branch that the git repo
should checkout.</p>

<p style="margin-left:6%;">ZOPEN_GIT_DEPS</p>

<p style="margin-left:15%;">Space-delimited set of source
packages this tarball package depends on to build. (required
if ZOPEN_TYPE=GIT)</p>

<p style="margin-left:6%;">ZOPEN_GIT_TAG</p>

<p style="margin-left:15%;">The tag that the git repo
should checkout as a branch.</p>

<p style="margin-left:6%;">ZOPEN_GIT_URL</p>

<p style="margin-left:15%;">The fully qualified URL that
the git repo should be cloned from. (required if
ZOPEN_TYPE=GIT)</p>

<p style="margin-left:6%;">ZOPEN_LIBS</p>

<p style="margin-left:15%;">C/C++ libraries (default set by
dependency)</p>

<p style="margin-left:6%;">ZOPEN_TARBALL_DEPS</p>

<p style="margin-left:15%;">Space-delimited set of source
packages this git package depends on to build. (required if
ZOPEN_TYPE=TARBALL)</p>

<p style="margin-left:6%;">ZOPEN_TARBALL_URL</p>

<p style="margin-left:15%;">The fully qualified URL that
the tarball should be downloaded from. (required if
ZOPEN_TYPE=TARBALL)</p>

<p style="margin-left:6%;">ZOPEN_TYPE</p>

<p style="margin-left:15%;">The type of package to
download. Valid types are TARBALL, BARE and GIT.</p>

<p style="margin-left:6%;">ZOPEN_URL</p>

<p style="margin-left:15%;">Alternate environment variable
instead of ZOPEN_TARBALL_URL or ZOPEN_GIT_URL.</p>

<p style="margin-left:6%; margin-top: 1em">User-Provided
functions:</p>

<h3>Required:</h3>



<p style="margin-left:6%; margin-top: 1em">zopen_check_results</p>

<p style="margin-left:15%;">This function runs after the
'check' step of the build and must print out
expected and actual failures.</p>

<p style="margin-left:6%;">zopen_get_version</p>

<p style="margin-left:15%;">This function returns the
version of the tool in accordance with semantic
versioning.</p>

<h3>Optional:</h3>



<p style="margin-left:6%; margin-top: 1em">zopen_append_to_env</p>

<p style="margin-left:15%;">This function runs as part of
generation of the .env file. The output of the function is
appended to .env.</p>

<p style="margin-left:6%;">zopen_append_to_setup</p>

<p style="margin-left:15%;">This function runs as part of
generation of the setup.sh file. The output of the function
is appended to setup.sh.</p>


<p style="margin-left:6%;">zopen_append_to_validate_install</p>

<p style="margin-left:15%;">This function runs as part of
generation of the install_test.sh file. The output of the
function is appended to install_test.sh script.</p>

<p style="margin-left:6%;">zopen_install_caveats</p>

<p style="margin-left:15%;">This function is run post
install. All stdout messages are captured and added to the
metadata.json as installation caveats.</p>

<p style="margin-left:6%;">zopen_append_to_zoslib_env</p>

<p style="margin-left:15%;">This function runs as part of
generation of the C function zoslib_env_hook, which can be
used to set environment variables before main is run.</p>

<p style="margin-left:6%;">zopen_init</p>

<p style="margin-left:15%;">This function runs after code
is downloaded and patched but before the code is built.</p>

<p style="margin-left:6%;">zopen_post_buildenv</p>

<p style="margin-left:15%;">This function runs after the
'buildenv' is processed.</p>

<p style="margin-left:6%;">zopen_post_extract</p>

<p style="margin-left:15%;">This function runs when an
archive containing the source to build has been
uncompressed.</p>

<p style="margin-left:6%;">zopen_post_install</p>

<p style="margin-left:15%;">This function runs after the
'install' step of the build is run.</p>

<p style="margin-left:6%;">zopen_pre_build</p>

<p style="margin-left:15%;">This function runs before the
'make' step of the build is run.</p>

<p style="margin-left:6%;">zopen_pre_check</p>

<p style="margin-left:15%;">This function runs before the
'check' step of the build is run.</p>

<p style="margin-left:6%;">zopen_pre_configure</p>

<p style="margin-left:15%;">This function runs before the
'configure' step of the build is run.</p>

<p style="margin-left:6%;">zopen_pre_install</p>

<p style="margin-left:15%;">This function runs before the
'install' step of the build is run.</p>

<p style="margin-left:6%;">zopen_pre_patch</p>

<p style="margin-left:15%;">This function runs before the
'patch' step of the build is run.</p>

<p style="margin-left:6%;">zopen_pre_terminate</p>

<p style="margin-left:15%;">This function runs before
'zopen build' terminates.</p>

<h3>SEE ALSO:</h3>


<p style="margin-left:15%; margin-top: 1em">zopen(1)
zopen-alt(1) zopen-init(1) zopen-install(1) zopen-list(1)
zopen-remove(1)</p>

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
