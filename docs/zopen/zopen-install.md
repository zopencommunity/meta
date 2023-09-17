## NAME
zopen-install
 
## SYNOPSIS
`zopen install [options]* [package]*` 

## DESCRIPTION
installs one or more z/OS Open Tools packages into your z/OS system

## OPTIONS

    --all:                       download/install all z/OS Open Tools packages.
    --cache-only:                do not install dependencies.
    --download-only:             download package to current directory
    --install-or-upgrade:        installs the package if not installed, or upgrades the package if installed.
    --local-install:             download and unpackage to current directory
    --no-deps:                   do not install dependencies.
    --no-set-active:             do not change the pinned version
    --nosymlink:                 do not integrate into filesystem through symlink redirection. 
    --reinstall:                 reinstall already installed z/OS Open Tools packages.
    --release-line <stable|dev>: the release line to build off of.
    --skip-upgrade:              do not upgrade.
    --select:                    select a version to install.
    -u|--update|--upgrade:       updates installed z/OS Open Tools packages.
    -v:                          run in verbose mode.
    -y|--yes:                    automatically answer yes to prompts.

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
