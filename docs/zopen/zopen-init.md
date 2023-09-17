## NAME
zopen-init
 
## SYNOPSIS
`zopen init [options] [<root dir>]` 

## DESCRIPTION
initialize the zopen tooling so you can subsequently use the other `zopen` tools.
`<root dir>` specifies the root directory that zopen will install under. `<root dir>` defaults to `${HOME}/zopen`

## OPTIONS

  **\-\-append-to-profile**
  : appends sourcing of zopen configuration to `.profile`

  **\-\-clone**
  : clones the current installation to a different location

  **-f `<type>`**
  : virtual filesystem location for package management; packages will be installed to this location under the `<root-dir>`. Where `<type>` is one of:

  - usrlclz - /usr/local/zopen (default)
  - zopen - /usr/zopen
  - prod - zopen standard
  - ibm  - /usr/lpp
  - fhs  - File Hierarchical Standard (/opt)
  - usrlcl - /usr/local

  **\-\-re-init**
  : re-initialize a previous installation (if present).  Re-initializing over a previous installation will re-use existing package structures and configurations.

  **\-\-releaseline-dev**
  : whether to globally enable Development packages

  **-v**
  : run in verbose mode

  **-?|-h|\-\-help**
  : display help

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
