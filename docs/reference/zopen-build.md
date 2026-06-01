<div v-pre class="man-page-content">

<div class="header-with-back"><div class="link"><a href="./zopen-audit">← Previous</a></div><div class='link'><a href='./zopen-clean'>Next →</a></div></div>

<h1 align="center">ZOPEN-BUILD</h1>
























<h2>NAME</h2>


<table><tr><td style="width: 25%; vertical-align: top;"><b>zopen-build
- manual page for zopen-build 0.8.5

<h2>SYNOPSIS</h2>



<b>zopen-build</b>
[<i>OPTION</i>]...

<h2>DESCRIPTION</h2>



zopen-build
is a general purpose build script to be used with the zopen
community ports.

<h3>Option:</h3>



<b>--build</b>
LINE</b></td><td style="vertical-align: top;">LINE may be dev or stable. This
is the build line to build off of.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--buildtype</b>
TYPE</td><td style="vertical-align: top;">TYPE may be release or debug.
The default is release.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-c</b>,
<b>--clean</b></td><td style="vertical-align: top;">Deletes all of the build output
and forces reconfigure with next build.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--ccache</b></td><td style="vertical-align: top;">Enable ccache for clang builds
to speed up recompilation.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--comp</b>
COMP</td><td style="vertical-align: top;">COMP may be xlclang, clang, go,
java python. The default is clang.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-e</b> ENV_FILE</td><td style="vertical-align: top;">source ENV_FILE instead of
buildenv to establish build environment.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-E</b>,
<b>--editable</b></td><td style="vertical-align: top;">enable editing of the
executable (adds <b>-Wl</b>,-bedit=yes to
LDFLAGS).</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--instrument</b></td><td style="vertical-align: top;">instruments the application
with option <b>-finstrument-functions</b> (clang
only)</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-f</b>,
<b>--force-rebuild</b></td><td style="vertical-align: top;">forces a rebuild, including
running bootstrap and configure again.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--forcepatchapply</b></td><td style="vertical-align: top;">force apply the patches, where
rejected patches are placed into a corresponding file of the
same name, with the .rej extension.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-g</b>,
<b>--get-source</b></td><td style="vertical-align: top;">get the source and apply patch
without building.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-gp</b>,
<b>--generate-pax</b></td><td style="vertical-align: top;">generate a pax.Z file based on
the install contents.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-gr</b>,
<b>--generate-rpm</b></td><td style="vertical-align: top;">generate an RPM package from
the pax archive.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-h</b>,
<b>--help</b>, -?</td><td style="vertical-align: top;">print this information.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--no-set-active</b></td><td style="vertical-align: top;">do not change the pinned
version.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--no-install-deps</b></td><td style="vertical-align: top;">do not install project's
runtime dependencies.</td></tr>
<tr><td style="width: 25%; vertical-align: top;"><b>--oci</b></td><td style="vertical-align: top;">build and publish an OCI image to
$ZOPEN_IMAGE_REGISTRY.</td></tr>
<tr valign="top" align="left">
<td width="9%"></td></tr>
<tr><td style="width: 25%; vertical-align: top;"><b>--sign-pax</b>,
<b>-sp</b></td><td style="vertical-align: top;">This option signs the pax file.
ZOPEN_GPG_SECRET_KEY_FILE,
ZOPEN_GPG_SECRET_KEY_PASSPHRASE_FILE and
ZOPEN_GPG_PUBLIC_KEY_FILE must be set for signing the
file.</td></tr>
<tr><td style="width: 25%; vertical-align: top;"><b>-v</b></td><td style="vertical-align: top;">run in verbose mode.</td></tr>
<tr valign="top" align="left">
<td width="9%"></td></tr>
<tr><td style="width: 25%; vertical-align: top;"><b>-u</b>,
<b>--upgradedeps</b></td><td style="vertical-align: top;">upgrade all dependencies by
running zopen install.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>The specifics of
how the tool works can be controlled through environment
variables. The only environment variables you _must_ specify
are to tell zopen-build where the source is, and in
what format type the source is stored. By default, the
environment variables are defined in a file named buildenv
in the root directory of the [PACKAGE]port github
repository.

To see a fully
functioning zopen community sample port see:
https://github.com/zopencommunity/zotsampleport


User-Provided
environment variables:

<h3>Required:</h3>



ZOPEN_BUILD_LINE</b></td><td style="vertical-align: top;">Specify the default build line,
either 'DEV' or 'STABLE'</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_CATEGORIES</b></td><td style="vertical-align: top;">Specify a space-delimited
list of applicable categories. Valid categories:
('security development language ai core utilities
editor source_control networking webframework database
devops graphics math testing documentation library
compression json monitoring shell build_system
ai')</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_DEV_DEPS</b></td><td style="vertical-align: top;">Required IF
ZOPEN_BUILD_LINE='DEV'. Specify the dev build
dependencies</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_DEV_URL</b></td><td style="vertical-align: top;">Required IF
ZOPEN_BUILD_LINE='DEV'. Specify the dev build
URL (either git or tarball).</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_STABLE_DEPS</b></td><td style="vertical-align: top;">Required IF
ZOPEN_BUILD_LINE='STABLE'. Specify the stable
build dependencies.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_STABLE_URL</b></td><td style="vertical-align: top;">Required IF
ZOPEN_BUILD_LINE='STABLE'. Specify the stable
build URL (either git or tarball).</td></tr></table>

<h3>Optional:</h3>



<table><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_SOURCE_URL</b></td><td style="vertical-align: top;">If set, use this as ZOPEN_URL
before checking ZOPEN_DEV_URL or ZOPEN_STABLE_URL.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_EXTRA_CFLAGS</b></td><td style="vertical-align: top;">C compiler flags to append to
CFLAGS (defaults to '').</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_EXTRA_CPPFLAGS</b></td><td style="vertical-align: top;">C,C++ pre-processor flags
to append to CPPFLAGS. (defaults to '')</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_EXTRA_CXXFLAGS</b></td><td style="vertical-align: top;">C++ compiler flags to append to
CXXFLAGS. (defaults to '')</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_EXTRA_LDFLAGS</b></td><td style="vertical-align: top;">C,C++ linker flags to append to
LDFLAGS. (defaults to '')</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_EXTRA_LIBS</b></td><td style="vertical-align: top;">C,C++ libraries to append to
LIBS. (defaults to '')</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_BOOTSTRAP</b></td><td style="vertical-align: top;">Bootstrap program to run. If
skip is specified, no bootstrap step is performed. (defaults
to './bootstrap')</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_BOOTSTRAP_OPTS</b></td><td style="vertical-align: top;">Options to pass to bootstrap
program. (defaults to '')</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_CHECK</b></td><td style="vertical-align: top;">Check program to run. If skip
is specified, no check step is performed. (defaults to
'make')</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_CHECK_MINIMAL</b></td><td style="vertical-align: top;">Check program will not be
passed CFLAGS, LDFLAGS, CPPFLAGS options but will get them
from env vars.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_CHECK_OPTS</b></td><td style="vertical-align: top;">Options to pass to check
program. (defaults to 'check')</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_CHECK_TIMEOUT</b></td><td style="vertical-align: top;">Timeout limit in seconds for
the check program. (defaults to '12600')</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_CLEAN</b></td><td style="vertical-align: top;">Clean up program to run.
(defaults to 'make')</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_CLEAN_OPTS</b></td><td style="vertical-align: top;">Options to pass to clean up
program. (defaults to 'clean')</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_CONFIGURE</b></td><td style="vertical-align: top;">Configuration program to run.
If skip is specified, no configuration step is performed.
(defaults to './configure')</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_CONFIGURE_MINIMAL</b></td><td style="vertical-align: top;">Configuration program will not
be passed CFLAGS, LDFLAGS, CPPFLAGS options but will get
them from env vars.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_CONFIGURE_OPTS</b></td><td style="vertical-align: top;">Options to pass to
configuration program. (defaults to
'--prefix=${ZOPEN_INSTALL_DIR}')</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_EXTRA_CONFIGURE_OPTS</b></td><td style="vertical-align: top;">Extra configure options to pass
to configuration program. (defaults to '')</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_INSTALL</b></td><td style="vertical-align: top;">Installation program to run. If
skip is specified, no installation step is performed.
(defaults to 'make')</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_INSTALL_OPTS</b></td><td style="vertical-align: top;">Options to pass to installation
program. (defaults to 'install')</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_MAKE</b></td><td style="vertical-align: top;">Build program to run. If skip
is specified, no build step is performed. (defaults to
'make')</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_MAKE_MINIMAL</b></td><td style="vertical-align: top;">Build program will not be
passed CFLAGS, LDFLAGS, CPPFLAGS options but will get them
from env vars.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_MAKE_OPTS</b></td><td style="vertical-align: top;">Options to pass to build
program. (defaults to
'-j${ZOPEN_NUM_JOBS}')</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_PATCH_DIR</b></td><td style="vertical-align: top;">Specify directory from which
patches should be applied.</td></tr></table>

<h3>Optional settings for installation:</h3>



<table><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_RUNTIME_DEPS</b></td><td style="vertical-align: top;">Runtime z/OS Open Tool
dependencies to be installed alongside the tool.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_SETUP_NO_REPLACE</b></td><td style="vertical-align: top;">If set, do not replace
hardcoded paths with placeholders.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_SYSTEM_PREREQ</b></td><td style="vertical-align: top;">System prerequisites, supply
the name of the prereq scripts under
/u/tejas/new_zopen/zostools_dev/doc/meta/bin/../include/prereq.sh</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>Restricted Usage
- only set in ports if necessary <br>
ZOPEN_DONT_ADD_ZOSLIB_DEP</b></td><td style="vertical-align: top;">Set to avoid adding zoslib as a
dependency.</td></tr></table>

<h3>Restricted Usage - only SET by metaport, otherwise READ ONLY:</h3>



<table><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_INSTALL_DIR</b></td><td style="vertical-align: top;">Installation directory to pass
to configuration. (defaults to
'${ZOPEN_PKGINSTALL}/<code>&lt;pkg&gt;</code>/<code>&lt;pkg&gt;</code>')</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_NUM_JOBS</b></td><td style="vertical-align: top;">Number of jobs that can be run
in parallel (defaults to half the CPUs on the system)</td></tr></table>

<h3>Restricted Usage (clang):</h3>



<table><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_CFLAGS</b></td><td style="vertical-align: top;">C compiler flags. (default set
by dependency)</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_CPPFLAGS</b></td><td style="vertical-align: top;">C/C++ pre-processor
flags. (default set by dependency)</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_CXXFLAGS</b></td><td style="vertical-align: top;">C++ compiler flags. (default
set by dependency)</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_LDFLAGS</b></td><td style="vertical-align: top;">C/C++ linker flags. (default
set by dependency)</td></tr></table>

<h3>Restricted Usage (phpport):</h3>



<table><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_GIT_SETUP</b></td><td style="vertical-align: top;">Specify whether git files
should be added to a local repo or if this will be done
manually. (defaults to Y)</td></tr></table>

<h3>Restricted Usage (tclport):</h3>



<table><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_SRC_DIR</b></td><td style="vertical-align: top;">Specify a relative source
directory to cd to for bootstrap, configure, build, check,
install. (defaults to '.')</td></tr></table>

<h3>Restricted Usage (meta):</h3>



<table><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_IMAGE_DOCKERFILE_NAME</b></td><td style="vertical-align: top;">Dockerfile name. (default:
Dockerfile)</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_IMAGE_DOCKER_NAME</b></td><td style="vertical-align: top;">Docker/podman tool name.
(default: podman)</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_IMAGE_REGISTRY</b></td><td style="vertical-align: top;">Docker image registry to an OCI
image to (use with <b>--oci</b> option)</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_IMAGE_REGISTRY_ID</b></td><td style="vertical-align: top;">The ID to authenticate to the
Docker image registry. (use with <b>--oci</b>
option)</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_IMAGE_REGISTRY_KEY_FILE</b></td><td style="vertical-align: top;">The file containing
authentication key to the Docker image registry. (use with
<b>--oci</b> option)</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_LOG_DIR</b></td><td style="vertical-align: top;">The directory to store build
logs. (defaults to '/log')</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_SHELL</b></td><td style="vertical-align: top;">Specify an alternate shell to
use if <b>-s</b> option specified. (defaults to
<i>/bin/sh</i>)</td></tr></table>

<h3>Git variables:</h3>



<table><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_DEV_BRANCH</b></td><td style="vertical-align: top;">The branch that the git repo
should checkout. (default is repo default)</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_DEV_TAG</b></td><td style="vertical-align: top;">The tag that the git repo
should checkout as a branch. (optional)</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_STABLE_BRANCH</b></td><td style="vertical-align: top;">The branch that the stable repo
should checkout. (default is repo default)</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_STABLE_TAG</b></td><td style="vertical-align: top;">The tag that the git repo
should checkout as a branch. (optional)</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_CLONE_SUBMODULES</b></td><td style="vertical-align: top;">Set to yes to recursively clone
submodules.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_CLONE_FULL</b></td><td style="vertical-align: top;">Set to yes to perform a full
clone as opposed to the default shallow clone (depth of
1).</td></tr></table>

<h3>Currently unused:</h3>



<table><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_DEV_TYPE</b></td><td style="vertical-align: top;">The type of package to
download. Valid types are TARBALL, BARE and GIT.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_STABLE_TYPE</b></td><td style="vertical-align: top;">The type of package to
download. Valid types are TARBALL, BARE and GIT.</td></tr></table>

<h3>Deprecated:</h3>


<table><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_CC</b></td><td style="vertical-align: top;">C compiler. (default set by
dependency)</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_CXX</b></td><td style="vertical-align: top;">C++ compiler. (default set by
dependency)</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_DEPS</b></td><td style="vertical-align: top;">Alternate environment variable
instead of ZOPEN_TARBALL_DEPS or ZOPEN_GIT_DEPS.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_GIT_BRANCH</b></td><td style="vertical-align: top;">The branch that the git repo
should checkout.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_GIT_DEPS</b></td><td style="vertical-align: top;">Space-delimited set of
source packages this tarball package depends on to build.
(required if ZOPEN_TYPE=GIT)</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_GIT_TAG</b></td><td style="vertical-align: top;">The tag that the git repo
should checkout as a branch.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_GIT_URL</b></td><td style="vertical-align: top;">The fully qualified URL that
the git repo should be cloned from. (required if
ZOPEN_TYPE=GIT)</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_LIBS</b></td><td style="vertical-align: top;">C/C++ libraries (default set by
dependency)</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_TARBALL_DEPS</b></td><td style="vertical-align: top;">Space-delimited set of
source packages this git package depends on to build.
(required if ZOPEN_TYPE=TARBALL)</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_TARBALL_URL</b></td><td style="vertical-align: top;">The fully qualified URL that
the tarball should be downloaded from. (required if
ZOPEN_TYPE=TARBALL)</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_TYPE</b></td><td style="vertical-align: top;">The type of package to
download. Valid types are TARBALL, BARE and GIT.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>ZOPEN_URL</b></td><td style="vertical-align: top;">Alternate environment variable
instead of ZOPEN_TARBALL_URL or ZOPEN_GIT_URL.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>User-Provided
functions:

<h3>Required:</h3>



zopen_check_results</b></td><td style="vertical-align: top;">This function runs after the
'check' step of the build and must print out
expected and actual failures.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>zopen_get_version</b></td><td style="vertical-align: top;">This function returns the
version of the tool in accordance with semantic
versioning.</td></tr></table>

<h3>Optional:</h3>



<table><tr><td style="width: 25%; vertical-align: top;"><b>zopen_append_to_env</b></td><td style="vertical-align: top;">This function runs as part of
generation of the .env file. The output of the function is
appended to .env.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>zopen_append_to_setup</b></td><td style="vertical-align: top;">This function runs as part of
generation of the setup.sh file. The output of the function
is appended to setup.sh.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>zopen_append_to_validate_install</b></td><td style="vertical-align: top;">This function runs as part of
generation of the install_test.sh file. The output of the
function is appended to install_test.sh script.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>zopen_install_caveats</b></td><td style="vertical-align: top;">This function is run post
install. All stdout messages are captured and added to the
metadata.json as installation caveats.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>zopen_append_to_zoslib_env</b></td><td style="vertical-align: top;">This function runs as part of
generation of the C function zoslib_env_hook, which can be
used to set environment variables before main is run.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>zopen_init</b></td><td style="vertical-align: top;">This function runs after code
is downloaded and patched but before the code is built.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>zopen_post_buildenv</b></td><td style="vertical-align: top;">This function runs after the
'buildenv' is processed.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>zopen_post_extract</b></td><td style="vertical-align: top;">This function runs when an
archive containing the source to build has been
uncompressed.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>zopen_post_install</b></td><td style="vertical-align: top;">This function runs after the
'install' step of the build is run.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>zopen_pre_build</b></td><td style="vertical-align: top;">This function runs before the
'make' step of the build is run.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>zopen_pre_check</b></td><td style="vertical-align: top;">This function runs before the
'check' step of the build is run.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>zopen_pre_configure</b></td><td style="vertical-align: top;">This function runs before the
'configure' step of the build is run.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>zopen_pre_install</b></td><td style="vertical-align: top;">This function runs before the
'install' step of the build is run.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>zopen_pre_patch</b></td><td style="vertical-align: top;">This function runs before the
'patch' step of the build is run.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>zopen_pre_terminate</b></td><td style="vertical-align: top;">This function runs before
'zopen build' terminates.</td></tr></table>

<h3>SEE ALSO:</h3>


<p style="margin-left:18%; margin-top: 1em">zopen(1)
zopen-alt(1) zopen-init(1)
zopen-install(1) zopen-list(1)
zopen-remove(1)</p>

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
