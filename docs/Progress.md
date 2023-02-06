
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
* [libxml2port](https://github.com/ZOSOpenTools/libxml2port)
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
| [makeport](https://github.com/ZOSOpenTools/makeport) | 64 | 100% |autoconf, automake, bash, bison, bzip2, cmake, coreutils, cscope, ctags, curl, diffutils, expat, findutils, flex, gawk, gdbm, gettext, git, gnulib, gperf, grep, groff, gzip, hello, help2man, htop, jq, less, libpcre, libpipeline, libtool, lua, lz4, m4, makeinfo, make, man-db, nano, ncdu, ncurses, ninja, openssl, patch, perl, php, re2c, rsync, screen, sed, sqlite, tar, tcl, texinfo, top, unzip, vim, wget, xxhash, xz, zip, zlib, zoslib, zotsample, zstd
| [curlport](https://github.com/ZOSOpenTools/curlport) | 48 | 99% |autoconf, automake, bash, bison, bzip2, coreutils, cscope, curl, diffutils, expat, findutils, gawk, gettext, git, gnulib, gperf, grep, groff, gzip, hello, help2man, htop, jq, less, libpipeline, libtool, lz4, m4, makeinfo, make, man-db, ncdu, ncurses, openssl, patch, php, rsync, screen, sed, tar, tcl, texinfo, top, wget, xxhash, xz, zotsample, zstd
| [gitport](https://github.com/ZOSOpenTools/gitport) | 43 | 96% |autoconf, automake, bash, bison, cmake, ctags, curl, expat, gdbm, gettext, git, gnulib, gzip, hello, help2man, htop, libpipeline, libtool, m4, makeinfo, make, man-db, meta, ncdu, ncurses, ninja, openssl, patch, perl, php, re2c, rsync, sqlite, tar, unzip, vim, wget, xz, zigi, zip, zlib, zoslib, zotsample
| [gzipport](https://github.com/ZOSOpenTools/gzipport) | 43 | 76% |autoconf, automake, bash, bison, bzip2, coreutils, cscope, ctags, curl, findutils, flex, gawk, gettext, git, gperf, hello, htop, jq, less, libtool, lz4, m4, makeinfo, make, man-db, ncdu, ncurses, openssl, patch, php, rsync, screen, sed, sqlite, tar, tcl, texinfo, top, wget, xxhash, xz, zotsample, zstd
| [zoslibport](https://github.com/ZOSOpenTools/zoslibport) | 43 | 100% |bash, bison, bzip2, coreutils, cscope, ctags, curl, diffutils, findutils, flex, gawk, git, grep, groff, gzip, hello, htop, jq, less, libpcre, libpipeline, lua, makeinfo, make, man-db, nano, ncdu, ninja, openssl, re2c, screen, sed, sqlite, tar, tcl, texinfo, unzip, vim, wget, xz, zip, zlib, zstd
| [m4port](https://github.com/ZOSOpenTools/m4port) | 27 | 98% |autoconf, automake, bison, ctags, curl, expat, flex, gettext, git, gnulib, groff, gzip, help2man, libtool, m4, makeinfo, make, man-db, openssl, php, re2c, rsync, screen, sed, tar, top, wget
| [perlport](https://github.com/ZOSOpenTools/perlport) | 27 | 100% |autoconf, automake, bison, coreutils, curl, expat, gettext, git, gnulib, groff, gzip, hello, help2man, libtool, m4, makeinfo, make, man-db, openssl, php, re2c, rsync, screen, sed, tar, texinfo, wget
| [autoconfport](https://github.com/ZOSOpenTools/autoconfport) | 26 | 98% |autoconf, automake, bison, ctags, curl, expat, gettext, git, gzip, hello, help2man, htop, libtool, m4, makeinfo, make, man-db, nano, openssl, php, re2c, rsync, screen, sed, tar, wget
| [automakeport](https://github.com/ZOSOpenTools/automakeport) | 26 | 71% |autoconf, automake, bison, ctags, curl, expat, gettext, git, gzip, hello, help2man, htop, libtool, m4, makeinfo, make, man-db, nano, openssl, php, re2c, rsync, screen, sed, tar, wget
| [tarport](https://github.com/ZOSOpenTools/tarport) | 25 | 89% |automake, bash, bzip2, coreutils, cscope, ctags, curl, findutils, flex, gettext, git, grep, htop, jq, less, m4, makeinfo, make, ncdu, ncurses, openssl, re2c, screen, sqlite, zotsample
| [coreutilsport](https://github.com/ZOSOpenTools/coreutilsport) | 22 | 84% |automake, bash, expat, gdbm, gettext, git, gnulib, grep, groff, gzip, jq, libpcre, libtool, lua, lz4, man-db, patch, re2c, sed, texinfo, xxhash, zstd
| [xzport](https://github.com/ZOSOpenTools/xzport) | 17 | 88% |autoconf, automake, bison, curl, diffutils, expat, findutils, gettext, git, gzip, help2man, libtool, m4, makeinfo, make, man-db, openssl
| [makeinfoport](https://github.com/ZOSOpenTools/makeinfoport) | 15 | 35% |autoconf, automake, bison, curl, expat, gettext, git, groff, gzip, libtool, m4, make, openssl, sed, tar
| [help2manport](https://github.com/ZOSOpenTools/help2manport) | 12 | 100% |autoconf, automake, bison, curl, expat, gettext, git, hello, libtool, m4, make, openssl
| [diffutilsport](https://github.com/ZOSOpenTools/diffutilsport) | 10 | 92% |bash, coreutils, gawk, git, gnulib, grep, groff, libpcre, re2c, texinfo
| [ncursesport](https://github.com/ZOSOpenTools/ncursesport) | 10 | 100% |bash, cscope, gettext, git, htop, less, nano, ncdu, screen, vim
| [gettextport](https://github.com/ZOSOpenTools/gettextport) | 8 | 81% |ctags, expat, git, hello, libiconv, m4, man-db, nano
| [gawkport](https://github.com/ZOSOpenTools/gawkport) | 6 | 93% |automake, curl, expat, gzip, ncurses, rsync
| [libtoolport](https://github.com/ZOSOpenTools/libtoolport) | 6 | 80% |expat, gdbm, makeinfo, man-db, php, re2c
| [opensslport](https://github.com/ZOSOpenTools/opensslport) | 5 | 90% |curl, expat, git, rsync, wget
| [zlibport](https://github.com/ZOSOpenTools/zlibport) | 5 | 100% |autoconf, curl, expat, git, wget
| [bashport](https://github.com/ZOSOpenTools/bashport) | 4 | 83% |flex, git, libxml2, re2c
| [cmakeport](https://github.com/ZOSOpenTools/cmakeport) | 4 | 74% |ninja, unzip, zip, zoslib
| [sedport](https://github.com/ZOSOpenTools/sedport) | 4 | 84% |bash, git, groff, re2c
| [findutilsport](https://github.com/ZOSOpenTools/findutilsport) | 3 | 50% |grep, re2c, texinfo
| [libiconvport](https://github.com/ZOSOpenTools/libiconvport) | 2 | 100% |libxml2, man-db
| [rsyncport](https://github.com/ZOSOpenTools/rsyncport) | 2 | 88% |m4, sed
| [wgetport](https://github.com/ZOSOpenTools/wgetport) | 2 | 18% |man-db, sed
| [bisonport](https://github.com/ZOSOpenTools/bisonport) | 1 | Skipped |php
| [expatport](https://github.com/ZOSOpenTools/expatport) | 1 | 100% |git
| [flexport](https://github.com/ZOSOpenTools/flexport) | 1 | 100% |cscope
| [gdbmport](https://github.com/ZOSOpenTools/gdbmport) | 1 | 100% |man-db
| [grepport](https://github.com/ZOSOpenTools/grepport) | 1 | 94% |libpcre
| [groffport](https://github.com/ZOSOpenTools/groffport) | 1 | 100% |man-db
| [lessport](https://github.com/ZOSOpenTools/lessport) | 1 | 100% |git
| [libpipelineport](https://github.com/ZOSOpenTools/libpipelineport) | 1 | 100% |man-db
| [lz4port](https://github.com/ZOSOpenTools/lz4port) | 1 | 100% |rsync
| [patchport](https://github.com/ZOSOpenTools/patchport) | 1 | 50% |m4
| [re2cport](https://github.com/ZOSOpenTools/re2cport) | 1 | No builds |php
| [xxhashport](https://github.com/ZOSOpenTools/xxhashport) | 1 | 100% |rsync
| [zipport](https://github.com/ZOSOpenTools/zipport) | 1 | 71% |unzip
| [zstdport](https://github.com/ZOSOpenTools/zstdport) | 1 | 100% |rsync
| [bzip2port](https://github.com/ZOSOpenTools/bzip2port) | 0 | 100% |
| [cscopeport](https://github.com/ZOSOpenTools/cscopeport) | 0 | 100% |
| [ctagsport](https://github.com/ZOSOpenTools/ctagsport) | 0 | 100% |
| [gnulibport](https://github.com/ZOSOpenTools/gnulibport) | 0 | No builds |
| [gperfport](https://github.com/ZOSOpenTools/gperfport) | 0 | Skipped |
| [helloport](https://github.com/ZOSOpenTools/helloport) | 0 | 20% |
| [htopport](https://github.com/ZOSOpenTools/htopport) | 0 | No builds |
| [jqport](https://github.com/ZOSOpenTools/jqport) | 0 | 57% |
| [libpcreport](https://github.com/ZOSOpenTools/libpcreport) | 0 | 66% |
| [libxml2port](https://github.com/ZOSOpenTools/libxml2port) | 0 | No builds |
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
| [sqliteport](https://github.com/ZOSOpenTools/sqliteport) | 0 | Skipped |
| [sshpassport](https://github.com/ZOSOpenTools/sshpassport) | 0 | No builds |
| [tclport](https://github.com/ZOSOpenTools/tclport) | 0 | Skipped |
| [texinfoport](https://github.com/ZOSOpenTools/texinfoport) | 0 | Skipped |
| [topport](https://github.com/ZOSOpenTools/topport) | 0 | No builds |
| [unzipport](https://github.com/ZOSOpenTools/unzipport) | 0 | 100% |
| [vimport](https://github.com/ZOSOpenTools/vimport) | 0 | 100% |
| [zigiport](https://github.com/ZOSOpenTools/zigiport) | 0 | Skipped |
| [zotsampleport](https://github.com/ZOSOpenTools/zotsampleport) | 0 | 100% |

Last updated:  2023-02-06 03:29:56
