## NAME
zopen-list
 
## SYNOPSIS
`zopen list [options]` 

## DESCRIPTION
lists information about z/OS Open Tools packages

## OPTIONS

  **-d | \-\-details**
  : include full details for listings.

  **\-\-filter <color>**
  : apply filter based on quality (green - all tests passing, blue - most tests passing, yellow - some tests passing, red - no tests passing, or skipped (no filter by default))

  **-i|\-\-installed**
  : list install z/OS Open Tools.

  **\-\-list**
  : list all available z/OS Open Tools.

  **\-\-no-header**
  : suppress the header for the output.

  **\-\-no-version**
  :  suppress version information, return package names.

  **\-\-remote-search**
  : regex match package against available z/OS Open Tools

  **\-\-upgradeable**
  : list packages where an upgrade is available.

  **-v**
  : run in verbose mode.

  **-wp|\-\-whatprovides**
  : which installed package provided a file.

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
