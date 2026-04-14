# zopen-build

# ZOPEN-BUILD

[NAME](#NAME)

[SYNOPSIS](#SYNOPSIS)

[DESCRIPTION](#DESCRIPTION)

[AUTHOR](#AUTHOR)


---



NAME




zopen-build
- manual page for zopen-build 0.8.4

SYNOPSIS





**zopen-build**
[*OPTION*]...

DESCRIPTION





zopen-build
is a general purpose build script to be used with the zopen
community ports.

Option: 

--build LINE

LINE may be dev or stable. This
is the build line to build off of.

**--buildtype**
TYPE

TYPE may be release or debug.
The default is release.

**-c**,
**--clean**

Deletes all of the build output
and forces reconfigure with next build.


**--ccache**

Enable ccache for clang builds
to speed up recompilation.

**--comp**
COMP

COMP may be xlclang, clang, go,
java python. The default is clang.

**-e** ENV_FILE

source ENV_FILE instead of
buildenv to establish build environment.


**--instrument**

instruments the application
with option **-finstrument-functions** (clang
only)

**-f**,
**--force-rebuild**

forces a rebuild, including
running bootstrap and configure again.


**--forcepatchapply**

force apply the patches, where
rejected patches are placed into a corresponding file of the
same name, with the .rej extension.

**-g**,
**--get-source**

get the source and apply patch
without building.

**-gp**,
**--generate-pax**

generate a pax.Z file based on
the install contents.

**-h**,
**--help**, -?

print this information.


**--no-set-active**

do not change the pinned
version.


**--no-install-deps**

do not install project&rsquo;s
runtime dependencies.

<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">





**--oci**




build and publish an OCI image to
$ZOPEN_IMAGE_REGISTRY. 





**-s**




exec a shell before running configure. Useful when
manually building ports.



**--sign-pax**,
**-sp**

This option signs the pax file.
ZOPEN_GPG_SECRET_KEY_FILE,
ZOPEN_GPG_SECRET_KEY_PASSPHRASE_FILE and
ZOPEN_GPG_PUBLIC_KEY_FILE must be set for signing the
file.

<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">





**-v**




run in verbose mode.





**-vv**




run in very verbose mode (sets environment variables V=1
and VERBOSE=1).


**-u**,
**--upgradedeps**

upgrade all dependencies by
running zopen install.

The specifics
of how the tool works can be controlled through environment
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


**Required:**


ZOPEN_BUILD_LINE

Specify the default build line,
either &rsquo;DEV&rsquo; or &rsquo;STABLE&rsquo;

ZOPEN_CATEGORIES

Specify a space-delimited
list of applicable categories. Valid categories:
(&rsquo;security development language ai core utilities
editor source_control networking webframework database
devops graphics math testing documentation library
compression json monitoring shell build_system
ai&rsquo;)

ZOPEN_DEV_DEPS

Required IF
ZOPEN_BUILD_LINE=&rsquo;DEV&rsquo;. Specify the dev build
dependencies

ZOPEN_DEV_URL

Required IF
ZOPEN_BUILD_LINE=&rsquo;DEV&rsquo;. Specify the dev build
URL (either git or tarball).

ZOPEN_STABLE_DEPS

Required IF
ZOPEN_BUILD_LINE=&rsquo;STABLE&rsquo;. Specify the stable
build dependencies.

ZOPEN_STABLE_URL

Required IF
ZOPEN_BUILD_LINE=&rsquo;STABLE&rsquo;. Specify the stable
build URL (either git or tarball).


**Optional:**


ZOPEN_EXTRA_CFLAGS

C compiler flags to append to
CFLAGS (defaults to &rsquo;&rsquo;).

ZOPEN_EXTRA_CPPFLAGS

C,C++ pre-processor flags
to append to CPPFLAGS. (defaults to &rsquo;&rsquo;)

ZOPEN_EXTRA_CXXFLAGS

C++ compiler flags to append to
CXXFLAGS. (defaults to &rsquo;&rsquo;)

ZOPEN_EXTRA_LDFLAGS

C,C++ linker flags to append to
LDFLAGS. (defaults to &rsquo;&rsquo;)

ZOPEN_EXTRA_LIBS

C,C++ libraries to append to
LIBS. (defaults to &rsquo;&rsquo;)

ZOPEN_BOOTSTRAP

Bootstrap program to run. If
skip is specified, no bootstrap step is performed. (defaults
to &rsquo;./bootstrap&rsquo;)

ZOPEN_BOOTSTRAP_OPTS

Options to pass to bootstrap
program. (defaults to &rsquo;&rsquo;)

ZOPEN_CHECK

Check program to run. If skip
is specified, no check step is performed. (defaults to
&rsquo;make&rsquo;)

ZOPEN_CHECK_MINIMAL

Check program will not be
passed CFLAGS, LDFLAGS, CPPFLAGS options but will get them
from env vars.

ZOPEN_CHECK_OPTS

Options to pass to check
program. (defaults to &rsquo;check&rsquo;)

ZOPEN_CHECK_TIMEOUT

Timeout limit in seconds for
the check program. (defaults to &rsquo;12600&rsquo;)

ZOPEN_CLEAN

Clean up program to run.
(defaults to &rsquo;make&rsquo;)

ZOPEN_CLEAN_OPTS

Options to pass to clean up
program. (defaults to &rsquo;clean&rsquo;)

ZOPEN_CONFIGURE

Configuration program to run.
If skip is specified, no configuration step is performed.
(defaults to &rsquo;./configure&rsquo;)

ZOPEN_CONFIGURE_MINIMAL

Configuration program will not
be passed CFLAGS, LDFLAGS, CPPFLAGS options but will get
them from env vars.

ZOPEN_CONFIGURE_OPTS

Options to pass to
configuration program. (defaults to
&rsquo;--prefix=${ZOPEN_INSTALL_DIR}&rsquo;)

ZOPEN_EXTRA_CONFIGURE_OPTS

Extra configure options to pass
to configuration program. (defaults to &rsquo;&rsquo;)

ZOPEN_INSTALL

Installation program to run. If
skip is specified, no installation step is performed.
(defaults to &rsquo;make&rsquo;)

ZOPEN_INSTALL_OPTS

Options to pass to installation
program. (defaults to &rsquo;install&rsquo;)

ZOPEN_MAKE

Build program to run. If skip
is specified, no build step is performed. (defaults to
&rsquo;make&rsquo;)

ZOPEN_MAKE_MINIMAL

Build program will not be
passed CFLAGS, LDFLAGS, CPPFLAGS options but will get them
from env vars.

ZOPEN_MAKE_OPTS

Options to pass to build
program. (defaults to
&rsquo;-j${ZOPEN_NUM_JOBS}&rsquo;)

ZOPEN_PATCH_DIR

Specify directory from which
patches should be applied.

Optional
settings for installation: 

ZOPEN_RUNTIME_DEPS

Runtime z/OS Open Tool
dependencies to be installed alongside the tool.

ZOPEN_SYSTEM_PREREQ

System prerequisites, supply
the name of the prereq scripts under
/var/lib/jenkins/workspace/Port-Update-Nightly/meta_update/bin/../include/prereq.sh

Restricted
Usage - only set in ports if necessary 

ZOPEN_DONT_ADD_ZOSLIB_DEP

Set to avoid adding zoslib as a
dependency.

Restricted
Usage - only SET by metaport, otherwise READ ONLY: 

ZOPEN_INSTALL_DIR

Installation directory to pass
to configuration. (defaults to
&rsquo;${ZOPEN_PKGINSTALL}/&lt;pkg&gt;/&lt;pkg&gt;&rsquo;)

ZOPEN_NUM_JOBS

Number of jobs that can be run
in parallel (defaults to half the CPUs on the system)

Restricted
Usage (clang): 

ZOPEN_CFLAGS

C compiler flags. (default set
by dependency)

ZOPEN_CPPFLAGS

C/C++ pre-processor
flags. (default set by dependency)

ZOPEN_CXXFLAGS

C++ compiler flags. (default
set by dependency)

ZOPEN_LDFLAGS

C/C++ linker flags. (default
set by dependency)

Restricted
Usage (phpport): 

ZOPEN_GIT_SETUP

Specify whether git files
should be added to a local repo or if this will be done
manually. (defaults to Y)

Restricted
Usage (tclport): 

ZOPEN_SRC_DIR

Specify a relative source
directory to cd to for bootstrap, configure, build, check,
install. (defaults to &rsquo;.&rsquo;)

Restricted
Usage (meta): 

ZOPEN_IMAGE_DOCKERFILE_NAME

Dockerfile name. (default:
Dockerfile)

ZOPEN_IMAGE_DOCKER_NAME

Docker/podman tool name.
(default: podman)

ZOPEN_IMAGE_REGISTRY

Docker image registry to an OCI
image to (use with **--oci** option)

ZOPEN_IMAGE_REGISTRY_ID

The ID to authenticate to the
Docker image registry. (use with **--oci**
option)


ZOPEN_IMAGE_REGISTRY_KEY_FILE

The file containing
authentication key to the Docker image registry. (use with
**--oci** option)

ZOPEN_LOG_DIR

The directory to store build
logs. (defaults to &rsquo;/log&rsquo;)

ZOPEN_SHELL

Specify an alternate shell to
use if **-s** option specified. (defaults to
*/bin/sh*)

Git
variables: 

ZOPEN_DEV_BRANCH

The branch that the git repo
should checkout. (default is repo default)

ZOPEN_DEV_TAG

The tag that the git repo
should checkout as a branch. (optional)

ZOPEN_STABLE_BRANCH

The branch that the stable repo
should checkout. (default is repo default)

ZOPEN_STABLE_TAG

The tag that the git repo
should checkout as a branch. (optional)

ZOPEN_CLONE_SUBMODULES

Set to yes to recursively clone
submodules.

ZOPEN_CLONE_FULL

Set to yes to perform a full
clone as opposed to the default shallow clone (depth of
1).

Currently
unused: 

ZOPEN_DEV_TYPE

The type of package to
download. Valid types are TARBALL, BARE and GIT.

ZOPEN_STABLE_TYPE

The type of package to
download. Valid types are TARBALL, BARE and GIT.


**Deprecated:**


ZOPEN_CC

C compiler. (default set by
dependency)

ZOPEN_CXX

C++ compiler. (default set by
dependency)

ZOPEN_DEPS

Alternate environment variable
instead of ZOPEN_TARBALL_DEPS or ZOPEN_GIT_DEPS.

ZOPEN_GIT_BRANCH

The branch that the git repo
should checkout.

ZOPEN_GIT_DEPS

Space-delimited set of
source packages this tarball package depends on to build.
(required if ZOPEN_TYPE=GIT)

ZOPEN_GIT_TAG

The tag that the git repo
should checkout as a branch.

ZOPEN_GIT_URL

The fully qualified URL that
the git repo should be cloned from. (required if
ZOPEN_TYPE=GIT)

ZOPEN_LIBS

C/C++ libraries (default set by
dependency)

ZOPEN_TARBALL_DEPS

Space-delimited set of
source packages this git package depends on to build.
(required if ZOPEN_TYPE=TARBALL)

ZOPEN_TARBALL_URL

The fully qualified URL that
the tarball should be downloaded from. (required if
ZOPEN_TYPE=TARBALL)

ZOPEN_TYPE

The type of package to
download. Valid types are TARBALL, BARE and GIT.

ZOPEN_URL

Alternate environment variable
instead of ZOPEN_TARBALL_URL or ZOPEN_GIT_URL.


User-Provided
functions:


**Required:**


zopen_check_results

This function runs after the
&rsquo;check&rsquo; step of the build and must print out
expected and actual failures.

zopen_get_version

This function returns the
version of the tool in accordance with semantic
versioning.


**Optional:**


zopen_append_to_env

This function runs as part of
generation of the .env file. The output of the function is
appended to .env.

zopen_append_to_setup

This function runs as part of
generation of the setup.sh file. The output of the function
is appended to setup.sh.


zopen_append_to_validate_install

This function runs as part of
generation of the install_test.sh file. The output of the
function is appended to install_test.sh script.

zopen_install_caveats

This function is run post
install. All stdout messages are captured and added to the
metadata.json as installation caveats.

zopen_append_to_zoslib_env

This function runs as part of
generation of the C function zoslib_env_hook, which can be
used to set environment variables before main is run.

zopen_init

This function runs after code
is downloaded and patched but before the code is built.

zopen_post_buildenv

This function runs after the
&rsquo;buildenv&rsquo; is processed.

zopen_post_extract

This function runs when an
archive containing the source to build has been
uncompressed.

zopen_post_install

This function runs after the
&rsquo;install&rsquo; step of the build is run.

zopen_pre_build

This function runs before the
&rsquo;make&rsquo; step of the build is run.

zopen_pre_check

This function runs before the
&rsquo;check&rsquo; step of the build is run.

zopen_pre_configure

This function runs before the
&rsquo;configure&rsquo; step of the build is run.

zopen_pre_install

This function runs before the
&rsquo;install&rsquo; step of the build is run.

zopen_pre_patch

This function runs before the
&rsquo;patch&rsquo; step of the build is run.

zopen_pre_terminate

This function runs before
&rsquo;zopen build&rsquo; terminates.

SEE
ALSO:

zopen(1) zopen-alt(1)
zopen-init(1) zopen-install(1)
zopen-list(1) zopen-remove(1)

This is free
software: you are free to change and redistribute it under
the terms of the Apache License, Version 2.0.
&lt;https://www.apache.org/licenses/LICENSE-2.0.html&gt;
There is NO WARRANTY, to the extent permitted by law.

AUTHOR




Written by
contributors to the zopen community.
&lt;https://github.com/zopencommunity/meta/graphs/contributors&gt;
---
