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
