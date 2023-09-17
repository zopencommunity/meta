## NAME
zopen-build
 
## SYNOPSIS
`zopen build [options]*` 

## DESCRIPTION
builds the software package of the repository you are in

zopen-build is a general purpose build script to be used with the ZOSOpenTools ports.
The specifics of how the tool works can be controlled through environment variables.
The only environment variables you _must_ specify are to tell zopen-build where the
  source is, and in what format type the source is stored.
By default, the environment variables are defined in a file named `buildenv` in the
  root directory of the `<package>port` github repository
[sample port](https://github.com/ZOSOpenTools/zotsampleport) is a fully functioning 
z/OSOpenTools sample port.

## OPTIONS

 **\-\-build dev|stable**
 : The type of build to perform. If not specified, use `${ZOPEN_BUILD_LINE}`.

 **\-\-comp `<compiler>`**
 : The compiler used for building.  The default is `comp_xlclang`.

 **\-\-forcepatchapply**
 : force apply patches. Rejected patches are written to `<patch-name>.rej`. 

 **-e `<env file>`**
 : source `<env file>` instead of buildenv to establish build environment.

 **-c|\-\-clean**
 : Deletes all of the build output and forces reconfigure with next build.

 **-f|\-\-force-rebuild**
 : forces a rebuild, including running bootstrap and configure again.

 **-g|\-\-get-source**
 : get the source and apply patch without building.

 **-gp|\-\-generate-pax**
 : generate a pax.Z file based on the install contents.

 **-h**
 : print help.

 **-nosym|\-\-nosymlink**
 : do not generate a symlink from the project name to `${ZOPEN_INSTALL_DIR}`.

 **-s**
 : exec a shell before running configure.  Useful when manually building ports.

 **-u|\-\-upgradedeps**
 : upgrade all dependencies by running zopen install.

 **-v**
 : run in verbose mode.

 **-vv**
 : run in very verbose mode.

## EXIT STATUS

## ENVIRONMENT

  **ZOPEN_CC** 
  : C compiler (default set by dependency)

  **ZOPEN_CXX** 
  : C++ compiler (default set by dependency)

  **ZOPEN_CPPFLAGS** 
  : C/C++ pre-processor flags (default set by dependency)

  **ZOPEN_CFLAGS** 
  : C compiler flags (default set by dependency)

  **ZOPEN_CXXFLAGS** 
  : C++ compiler flags (default set by dependency)

  **ZOPEN_LDFLAGS** 
  : C/C++ linker flags (default set by dependency)

  **ZOPEN_LIBS** 
  : C/C++ libraries (default set by dependency)

  **ZOPEN_BUILD_LINE** 
  : Specify the default build line, either 'DEV' or 'STABLE'

  **ZOPEN_DEV_URL** 
  : Specify the dev build url (either a git url or tarball url)

  **ZOPEN_STABLE_URL** 
  : Specify the stable build url (either a git url or tarball url)

  **ZOPEN_DEV_DEPS** 
  : Specify the dev build dependencies

  **ZOPEN_STABLE_DEPS** 
  : Specify the stable build dependencies

  **ZOPEN_DEV_BRANCH** 
  : The branch that the git repo should checkout (optional, takes precedence over ZOPEN_DEV_TAG)

  **ZOPEN_DEV_TAG** 
  : The tag that the git repo should checkout as a branch (optional)

  **ZOPEN_DEV_TYPE** 
  : The type of package to download. Valid types are TARBALL, BARE and GIT (optional)

  **ZOPEN_STABLE_BRANCH** 
  : The branch that the stable repo should checkout (optional, takes precedence over ZOPEN_STABLE_TAG)

  **ZOPEN_STABLE_TAG** 
  : The tag that the git repo should checkout as a branch (optional)

  **ZOPEN_STABLE_TYPE** 
  : The type of package to download. Valid types are TARBALL, BARE and GIT (optional)

  **ZOPEN_GIT_SETUP** 
  : Specify whether git files should be added to a local repo or if this will be done manually (defaults to Y)

  **ZOPEN_SRC_DIR** 
  : Specify a relative source directory to cd to for bootstrap, configure, build, check, install (defaults to '.')

  **ZOPEN_EXTRA_CPPFLAGS** 
  : C/C++ pre-processor flags to append to CPPFLAGS (defaults to '')

  **ZOPEN_EXTRA_CFLAGS** 
  : C compiler flags to append to CFLAGS (defaults to '')

  **ZOPEN_EXTRA_CXXFLAGS** 
  : C++ compiler flags to append to CXXFLAGS (defaults to '')

  **ZOPEN_EXTRA_LDFLAGS** 
  : C/C++ linker flags to append to LDFLAGS (defaults to '')

  **ZOPEN_EXTRA_LIBS** 
  : C/C++ libraries to append to LIBS (defaults to '')

  **ZOPEN_NUM_JOBS** 
  : Number of jobs that can be run in parallel (defaults to 1/2 the CPUs on the system)

  **ZOPEN_BOOTSTRAP** 
  : Bootstrap program to run. If skip is specified, no bootstrap step is performed (defaults to './bootstrap')

  **ZOPEN_BOOTSTRAP_OPTS** 
  : Options to pass to bootstrap program (defaults to '')

  **ZOPEN_CONFIGURE** 
  : Configuration program to run. If skip is specified, no configuration step is performed (defaults to './configure')

  **ZOPEN_CONFIGURE_MINIMAL** 
  : Configuration program will not be passed CFLAGS, LDFLAGS, CPPFLAGS options but will just get them from env vars

  **ZOPEN_CONFIGURE_OPTS** 
  : Options to pass to configuration program (defaults to '--prefix=${ZOPEN_INSTALL_DIR}')

  **ZOPEN_EXTRA_CONFIGURE_OPTS** 
  : Extra configure options to pass to configuration program (defaults to '')

  **ZOPEN_INSTALL_DIR** 
  : Installation directory to pass to configuration (defaults to '${PKGINSTALL}/zopen/prod/<pkg>/<pkg>')

  **ZOPEN_MAKE** 
  : Build program to run. If skip is specified, no build step is performed (defaults to 'make')

  **ZOPEN_MAKE_MINIMAL** 
  : Build program will not be passed CFLAGS, LDFLAGS, CPPFLAGS options but will just get them from env vars

  **ZOPEN_MAKE_OPTS** 
  : Options to pass to build program (defaults to '-j${ZOPEN_NUM_JOBS}')

  **ZOPEN_CHECK** 
  : Check program to run. If skip is specified, no check step is performed (defaults to 'make')

  **ZOPEN_CHECK_MINIMAL** 
  : Check program will not be passed CFLAGS, LDFLAGS, CPPFLAGS options but will just get them from env vars

  **ZOPEN_CHECK_OPTS** 
  : Options to pass to check program (defaults to 'check')

  **ZOPEN_CHECK_TIMEOUT** 
  : Timeout limit in seconds for the check program (defaults to '12600')

  **ZOPEN_IMAGE_REGISTRY** 
  : Docker image registry to an OCI image to (use with --oci option)

  **ZOPEN_IMAGE_DOCKERFILE_NAME** 
  : Dockerfile name (default: Dockerfile)

  **ZOPEN_IMAGE_DOCKER_NAME** 
  : Docker/podman tool name (default: podman)

  **ZOPEN_IMAGE_REGISTRY_ID** 
  : The ID to authenticate to the Docker image registry (use with --oci option)

  **ZOPEN_IMAGE_REGISTRY_KEY_FILE** 
  : The file containing the key to authenticate to the Docker image registry (use with --oci option)

  **ZOPEN_LOG_DIR** 
  : The directory to store build logs (defaults to '/log')

  **ZOPEN_INSTALL** 
  : Installation program to run. If skip is specified, no installation step is performed (defaults to 'make')

  **ZOPEN_INSTALL_OPTS** 
  : Options to pass to installation program (defaults to 'install')

  **ZOPEN_CLEAN** 
  : Clean up program to run (defaults to 'make')

  **ZOPEN_CLEAN_OPTS** 
  : Options to pass to clean up  program (defaults to 'clean')

  **ZOPEN_SHELL** 
  : Specify an alternate shell to use if -s option specified (defaults to /bin/sh)

## FILES

## SEE ALSO
zopen-init(1) zopen-install(1) zopen-list(1)  

zopen-build(1) zopen-alt(1) zopen-generate(1) zopen-remove(1) zopen-clean(1)

Part of the zopen(1) suite

## BUGS
[Current Issues](https://github.com/ZOSOpenTools/meta/issues) are managed in the `meta` repository of [z/OS Open Tools](https://zosopentools.github.io/meta/#/)

## EXAMPLES

## AUTHORS
[Contributors](https://github.com/ZOSOpenTools/meta/graphs/contributors) are tracked in the `meta` repository of [z/OS Open Tools](https://zosopentools.github.io/meta/#/)

## REPORTING BUGS
[Create a new Issue](https://github.com/ZOSOpenTools/meta/issues/new) in the `meta` repository of [z/OS Open Tools](https://zosopentools.github.io/meta/#/)

## LICENSE
[License](https://github.com/ZOSOpenTools/meta/blob/main/LICENSE) in the `meta` repository of [z/OS Open Tools](https://zosopentools.github.io/meta/#/) 
