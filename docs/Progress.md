
## Overall Status
* <span style="color:green">Green</a>: All tests passing
* <span style="color:blue">Blue</a>: Most tests passing
* <span style="color:#fee12b">Yellow</a>: Some tests passing
* <span style="color:red">Red</a>: No tests passing
* <span style="color:grey">Grey</a>: Skipped or Tests are not enabled

![image info](./images/progress.png)

## Breakdown of Status
![image info](./images/quality.png)

## Projects with skipped or no tests (grey)
	
* [bisonport](https://github.com/ZOSOpenTools/bisonport)
* [gperfport](https://github.com/ZOSOpenTools/gperfport)
* [ncduport](https://github.com/ZOSOpenTools/ncduport)
* [screenport](https://github.com/ZOSOpenTools/screenport)
* [sqliteport](https://github.com/ZOSOpenTools/sqliteport)
* [tclport](https://github.com/ZOSOpenTools/tclport)
* [texinfoport](https://github.com/ZOSOpenTools/texinfoport)
* [zigiport](https://github.com/ZOSOpenTools/zigiport)
## Projects that do not have builds

* [gnulibport](https://github.com/ZOSOpenTools/gnulibport)
* [htopport](https://github.com/ZOSOpenTools/htopport)
* [libxsltport](https://github.com/ZOSOpenTools/libxsltport)
* [man-dbport](https://github.com/ZOSOpenTools/man-dbport)
* [phpport](https://github.com/ZOSOpenTools/phpport)
* [pkg-configport](https://github.com/ZOSOpenTools/pkg-configport)
* [re2cport](https://github.com/ZOSOpenTools/re2cport)
* [shufport](https://github.com/ZOSOpenTools/shufport)
* [sshpassport](https://github.com/ZOSOpenTools/sshpassport)
* [topport](https://github.com/ZOSOpenTools/topport)

## Projects with the most dependencies

| Package | # of Dependent Projects | Test Success Rate | Dependent projects
|---|---|---|--|
| [makeport](https://github.com/ZOSOpenTools/makeport) | 68 | 100% |autoconf, automake, bash, bison, bzip2, cmake, coreutils, cscope, ctags, curl, diffutils, expat, findutils, flex, gawk, gdbm, getopt, gettext, git, gnulib, gperf, grep, groff, gzip, hello, help2man, htop, jq, less, libpcre, libpipeline, libtool, libxml2, libxslt, lua, lz4, m4, makeinfo, make, man-db, nano, ncdu, ncurses, ninja, openssl, patch, perl, php, re2c, rsync, screen, sed, sqlite, tar, tcl, texinfo, top, unzip, vim, wget, xmlto, xxhash, xz, zip, zlib, zoslib, zotsample, zstd
| [zoslibport](https://github.com/ZOSOpenTools/zoslibport) | 49 | 100% |bash, bison, bzip2, coreutils, cscope, ctags, curl, diffutils, findutils, flex, gawk, gdbm, getopt, git, grep, groff, gzip, hello, htop, jq, less, libpcre, libpipeline, libxml2, libxslt, lua, makeinfo, make, man-db, nano, ncdu, ninja, openssl, php, re2c, screen, sed, sqlite, tar, tcl, texinfo, unzip, vim, wget, xmlto, xz, zip, zlib, zstd
| [curlport](https://github.com/ZOSOpenTools/curlport) | 48 | 99% |autoconf, automake, bash, bison, bzip2, coreutils, cscope, curl, diffutils, expat, findutils, gawk, gettext, git, gnulib, gperf, grep, groff, gzip, hello, help2man, htop, jq, less, libpipeline, libtool, lz4, m4, makeinfo, make, man-db, ncdu, ncurses, openssl, patch, php, rsync, screen, sed, tar, tcl, texinfo, top, wget, xxhash, xz, zotsample, zstd
| [gitport](https://github.com/ZOSOpenTools/gitport) | 43 | 96% |autoconf, automake, bash, bison, cmake, ctags, curl, expat, gdbm, gettext, git, gnulib, gzip, hello, help2man, htop, libpipeline, libtool, m4, makeinfo, make, man-db, meta, ncdu, ncurses, ninja, openssl, patch, perl, php, re2c, rsync, sqlite, tar, unzip, vim, wget, xz, zigi, zip, zlib, zoslib, zotsample
| [gzipport](https://github.com/ZOSOpenTools/gzipport) | 43 | 72% |autoconf, automake, bash, bison, bzip2, coreutils, cscope, ctags, curl, findutils, flex, gawk, gettext, git, gperf, hello, htop, jq, less, libtool, lz4, m4, makeinfo, make, man-db, ncdu, ncurses, openssl, patch, php, rsync, screen, sed, sqlite, tar, tcl, texinfo, top, wget, xxhash, xz, zotsample, zstd
| [m4port](https://github.com/ZOSOpenTools/m4port) | 28 | 98% |autoconf, automake, bison, ctags, curl, expat, flex, gettext, git, gnulib, groff, gzip, hello, help2man, libtool, m4, makeinfo, make, man-db, openssl, php, re2c, rsync, screen, sed, tar, top, wget
| [perlport](https://github.com/ZOSOpenTools/perlport) | 27 | 100% |autoconf, automake, bison, coreutils, curl, expat, gettext, git, gnulib, groff, gzip, hello, help2man, libtool, m4, makeinfo, make, man-db, openssl, php, re2c, rsync, screen, sed, tar, texinfo, wget
| [autoconfport](https://github.com/ZOSOpenTools/autoconfport) | 26 | 98% |autoconf, automake, bison, ctags, curl, expat, gettext, git, gzip, hello, help2man, htop, libtool, m4, makeinfo, make, man-db, nano, openssl, php, re2c, rsync, screen, sed, tar, wget
| [automakeport](https://github.com/ZOSOpenTools/automakeport) | 26 | 71% |autoconf, automake, bison, ctags, curl, expat, gettext, git, gzip, hello, help2man, htop, libtool, m4, makeinfo, make, man-db, nano, openssl, php, re2c, rsync, screen, sed, tar, wget
| [coreutilsport](https://github.com/ZOSOpenTools/coreutilsport) | 26 | 84% |automake, bash, expat, gdbm, getopt, gettext, git, gnulib, grep, groff, gzip, hello, jq, libpcre, libtool, libxml2, lua, lz4, man-db, ncurses, patch, re2c, sed, texinfo, xxhash, zstd
| [tarport](https://github.com/ZOSOpenTools/tarport) | 26 | 89% |automake, bash, bzip2, coreutils, cscope, ctags, curl, findutils, flex, gettext, git, grep, hello, htop, jq, less, m4, makeinfo, make, ncdu, ncurses, openssl, re2c, screen, sqlite, zotsample
| [xzport](https://github.com/ZOSOpenTools/xzport) | 17 | 88% |autoconf, automake, bison, curl, diffutils, expat, findutils, gettext, git, gzip, help2man, libtool, m4, makeinfo, make, man-db, openssl
| [makeinfoport](https://github.com/ZOSOpenTools/makeinfoport) | 16 | 35% |autoconf, automake, bison, curl, expat, gettext, git, groff, gzip, hello, libtool, m4, make, openssl, sed, tar
| [diffutilsport](https://github.com/ZOSOpenTools/diffutilsport) | 14 | 92% |bash, coreutils, gawk, getopt, git, gnulib, grep, groff, libpcre, libxml2, libxslt, re2c, texinfo, xmlto
| [help2manport](https://github.com/ZOSOpenTools/help2manport) | 12 | 100% |autoconf, automake, bison, curl, expat, gettext, git, hello, libtool, m4, make, openssl
| [ncursesport](https://github.com/ZOSOpenTools/ncursesport) | 11 | 100% |bash, cscope, gettext, git, htop, less, man-db, nano, ncdu, screen, vim
| [gettextport](https://github.com/ZOSOpenTools/gettextport) | 9 | 81% |ctags, expat, getopt, git, hello, libiconv, m4, man-db, nano
| [libtoolport](https://github.com/ZOSOpenTools/libtoolport) | 7 | 80% |expat, gdbm, hello, makeinfo, man-db, php, re2c
| [sedport](https://github.com/ZOSOpenTools/sedport) | 7 | 84% |bash, git, groff, libxml2, libxslt, ncurses, re2c
| [gawkport](https://github.com/ZOSOpenTools/gawkport) | 6 | 93% |automake, curl, expat, gzip, ncurses, rsync
| [bashport](https://github.com/ZOSOpenTools/bashport) | 5 | 83% |flex, git, libxml2, re2c, xmlto
| [opensslport](https://github.com/ZOSOpenTools/opensslport) | 5 | 90% |curl, expat, git, rsync, wget
| [zlibport](https://github.com/ZOSOpenTools/zlibport) | 5 | 100% |autoconf, curl, expat, git, wget
| [cmakeport](https://github.com/ZOSOpenTools/cmakeport) | 4 | 74% |ninja, unzip, zip, zoslib
| [findutilsport](https://github.com/ZOSOpenTools/findutilsport) | 4 | 50% |grep, libxml2, re2c, texinfo
| [grepport](https://github.com/ZOSOpenTools/grepport) | 3 | 94% |libpcre, libxslt, xmlto
| [wgetport](https://github.com/ZOSOpenTools/wgetport) | 3 | 18% |hello, man-db, sed
| [lessport](https://github.com/ZOSOpenTools/lessport) | 2 | 100% |git, man-db
| [libiconvport](https://github.com/ZOSOpenTools/libiconvport) | 2 | 100% |libxml2, man-db
| [libxml2port](https://github.com/ZOSOpenTools/libxml2port) | 2 | 99% |libxslt, php
| [rsyncport](https://github.com/ZOSOpenTools/rsyncport) | 2 | 88% |m4, sed
| [bisonport](https://github.com/ZOSOpenTools/bisonport) | 1 | Skipped |php
| [expatport](https://github.com/ZOSOpenTools/expatport) | 1 | 100% |git
| [flexport](https://github.com/ZOSOpenTools/flexport) | 1 | 100% |cscope
| [gdbmport](https://github.com/ZOSOpenTools/gdbmport) | 1 | 100% |man-db
| [getoptport](https://github.com/ZOSOpenTools/getoptport) | 1 | 52% |xmlto
| [gperfport](https://github.com/ZOSOpenTools/gperfport) | 1 | Skipped |hello
| [groffport](https://github.com/ZOSOpenTools/groffport) | 1 | 100% |man-db
| [libpipelineport](https://github.com/ZOSOpenTools/libpipelineport) | 1 | 100% |man-db
| [lz4port](https://github.com/ZOSOpenTools/lz4port) | 1 | 100% |rsync
| [patchport](https://github.com/ZOSOpenTools/patchport) | 1 | 50% |m4
| [re2cport](https://github.com/ZOSOpenTools/re2cport) | 1 | No builds |php
| [sqliteport](https://github.com/ZOSOpenTools/sqliteport) | 1 | Skipped |php
| [xxhashport](https://github.com/ZOSOpenTools/xxhashport) | 1 | 100% |rsync
| [zipport](https://github.com/ZOSOpenTools/zipport) | 1 | 71% |unzip
| [zstdport](https://github.com/ZOSOpenTools/zstdport) | 1 | 100% |rsync
| [bzip2port](https://github.com/ZOSOpenTools/bzip2port) | 0 | 100% |
| [cscopeport](https://github.com/ZOSOpenTools/cscopeport) | 0 | 100% |
| [ctagsport](https://github.com/ZOSOpenTools/ctagsport) | 0 | 100% |
| [gnulibport](https://github.com/ZOSOpenTools/gnulibport) | 0 | No builds |
| [helloport](https://github.com/ZOSOpenTools/helloport) | 0 | 20% |
| [htopport](https://github.com/ZOSOpenTools/htopport) | 0 | No builds |
| [jqport](https://github.com/ZOSOpenTools/jqport) | 0 | 57% |
| [libpcreport](https://github.com/ZOSOpenTools/libpcreport) | 0 | 66% |
| [libxsltport](https://github.com/ZOSOpenTools/libxsltport) | 0 | No builds |
| [luaport](https://github.com/ZOSOpenTools/luaport) | 0 | 100% |
| [man-dbport](https://github.com/ZOSOpenTools/man-dbport) | 0 | No builds |
| [metaport](https://github.com/ZOSOpenTools/metaport) | 0 | 100% |
| [nanoport](https://github.com/ZOSOpenTools/nanoport) | 0 | 100% |
| [ncduport](https://github.com/ZOSOpenTools/ncduport) | 0 | Skipped |
| [ninjaport](https://github.com/ZOSOpenTools/ninjaport) | 0 | 98% |
| [phpport](https://github.com/ZOSOpenTools/phpport) | 0 | No builds |
| [pkg-configport](https://github.com/ZOSOpenTools/pkg-configport) | 0 | No builds |
| [screenport](https://github.com/ZOSOpenTools/screenport) | 0 | Skipped |
| [shufport](https://github.com/ZOSOpenTools/shufport) | 0 | No builds |
| [sshpassport](https://github.com/ZOSOpenTools/sshpassport) | 0 | No builds |
| [tclport](https://github.com/ZOSOpenTools/tclport) | 0 | Skipped |
| [texinfoport](https://github.com/ZOSOpenTools/texinfoport) | 0 | Skipped |
| [topport](https://github.com/ZOSOpenTools/topport) | 0 | No builds |
| [unzipport](https://github.com/ZOSOpenTools/unzipport) | 0 | 100% |
| [vimport](https://github.com/ZOSOpenTools/vimport) | 0 | 100% |
| [xmltoport](https://github.com/ZOSOpenTools/xmltoport) | 0 | 100% |
| [zigiport](https://github.com/ZOSOpenTools/zigiport) | 0 | Skipped |
| [zotsampleport](https://github.com/ZOSOpenTools/zotsampleport) | 0 | 100% |

Last updated:  2023-02-15 18:14:14
