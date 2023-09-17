## NAME
zopen
 
## SYNOPSIS
`zopen [command] [options]` 

## DESCRIPTION
zopen is a package manager and build tool for z/OS Open Tools

## OPTIONS

Options are passed to the underlying commands.

## ZOPEN COMMANDS

We divide zopen into high level ("porcelain") commands and low level ("plumbing") commands.

### HIGH-LEVEL COMMANDS (PORCELAIN)

 **git-build(1)**
 : builds the software package of the repository you are in

 **git-init(1)**
 : initialize the zopen tooling so you can subsequently use the other `zopen` commands

 **git-generate(1)**       
 : generate the skeleton files for a z/OS Open Tools project

 **git-install(1)**        
 : installs one or more z/OS Open Tools packages into your z/OS system

 **git-list(1)**           
 : lists information about z/OS Open Tools packages

 **git-remove(1)**         
 : remove z/OS Open Tools packages installed on your z/OS system

 **git-alt(1)**
 : switch local versions of z/OS Open Tools packages

 **git-clean(1)**          
 : cleans various aspects of z/OS Open Tools packages

#### Ancillary Commands

 **git-download(1)**       
 : this is an alias for git-install 

 **git-query(1)**          
 : this is an alias for git-list

 **git-upgrade(1)**        
 : this is an alias for git-install

 **git-search(1)**         
 : this is an alias for git-list

### LOW-LEVEL COMMANDS (PLUMBING)

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
