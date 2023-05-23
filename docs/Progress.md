
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
* [comp_clangport](https://github.com/ZOSOpenTools/comp_clangport)
* [comp_goport](https://github.com/ZOSOpenTools/comp_goport)
* [comp_xlclangport](https://github.com/ZOSOpenTools/comp_xlclangport)
* [expectport](https://github.com/ZOSOpenTools/expectport)
* [nanoport](https://github.com/ZOSOpenTools/nanoport)
* [ncduport](https://github.com/ZOSOpenTools/ncduport)
* [pythonport](https://github.com/ZOSOpenTools/pythonport)
* [screenport](https://github.com/ZOSOpenTools/screenport)
* [sqliteport](https://github.com/ZOSOpenTools/sqliteport)
* [sshpassport](https://github.com/ZOSOpenTools/sshpassport)
* [tclport](https://github.com/ZOSOpenTools/tclport)
* [yqport](https://github.com/ZOSOpenTools/yqport)
* [zigiport](https://github.com/ZOSOpenTools/zigiport)
## Projects that do not have builds

* [direnvport](https://github.com/ZOSOpenTools/direnvport)
* [duckdbport](https://github.com/ZOSOpenTools/duckdbport)
* [emacsport](https://github.com/ZOSOpenTools/emacsport)
* [fzfport](https://github.com/ZOSOpenTools/fzfport)
* [gpgport](https://github.com/ZOSOpenTools/gpgport)
* [htopport](https://github.com/ZOSOpenTools/htopport)
* [libassuanport](https://github.com/ZOSOpenTools/libassuanport)
* [libgcryptport](https://github.com/ZOSOpenTools/libgcryptport)
* [libgit2port](https://github.com/ZOSOpenTools/libgit2port)
* [libgpgerrorport](https://github.com/ZOSOpenTools/libgpgerrorport)
* [libksbaport](https://github.com/ZOSOpenTools/libksbaport)
* [neovimport](https://github.com/ZOSOpenTools/neovimport)
* [npthport](https://github.com/ZOSOpenTools/npthport)
* [opensshport](https://github.com/ZOSOpenTools/opensshport)
* [phpport](https://github.com/ZOSOpenTools/phpport)
* [pinentryport](https://github.com/ZOSOpenTools/pinentryport)
* [powerline-goport](https://github.com/ZOSOpenTools/powerline-goport)
* [shufport](https://github.com/ZOSOpenTools/shufport)
* [sudoport](https://github.com/ZOSOpenTools/sudoport)
* [terraformport](https://github.com/ZOSOpenTools/terraformport)
* [topport](https://github.com/ZOSOpenTools/topport)

## Projects with the most dependencies

| Package | # of Dependent Projects | Test Success Rate | Dependent projects
|---|---|---|--|
| [makeport](https://github.com/ZOSOpenTools/makeport) | 85 | 100% |autoconf, automake, bash, bison, bzip2, cmake, coreutils, cscope, ctags, curl, diffutils, direnv, expat, expect, findutils, flex, fzf, gawk, getopt, gettext, git, gnulib, gperf, gpg, grep, groff, gzip, hello, help2man, htop, jq, less, libgcrypt, libgdbm, libgpgerror, libiconv, libksba, libpcre, libpipeline, libssh2, libtool, libxml2, libxslt, lua, lynx, lz4, m4, make, man-db, nano, ncdu, ncurses, neovim, ninja, npth, openssh, openssl, patch, perl, php, pinentry, pkg-config, re2c, rsync, screen, sed, sqlite, sshpass, sudo, tar, tcl, texinfo, top, unzip, vim, wget, which, xmlto, xxhash, xz, zip, zlib, zoslib, zotsample, zstd
| [zoslibport](https://github.com/ZOSOpenTools/zoslibport) | 71 | 100% |bash, bison, bzip2, coreutils, cscope, ctags, curl, diffutils, expat, expect, findutils, flex, gawk, getopt, gettext, git, gnulib, gperf, gpg, grep, groff, gzip, hello, htop, jq, less, libgcrypt, libgdbm, libgpgerror, libksba, libpcre, libpipeline, libssh2, libtool, libxml2, libxslt, lua, lynx, make, man-db, nano, ncdu, ncurses, ninja, npth, openssh, openssl, patch, perl, php, pinentry, pkg-config, re2c, rsync, screen, sed, sqlite, sshpass, sudo, tar, tcl, texinfo, unzip, vim, wget, xmlto, xz, zip, zlib, zotsample, zstd
| [curlport](https://github.com/ZOSOpenTools/curlport) | 54 | 99% |autoconf, automake, bash, bison, bzip2, coreutils, cscope, curl, diffutils, expat, findutils, gawk, gettext, git, gnulib, gperf, gpg, grep, groff, gzip, hello, help2man, jq, less, libgcrypt, libgpgerror, libksba, libpipeline, libtool, lz4, m4, make, man-db, ncdu, ncurses, neovim, npth, openssl, patch, php, pinentry, rsync, screen, sed, tar, tcl, texinfo, top, wget, which, xxhash, xz, zotsample, zstd
| [gzipport](https://github.com/ZOSOpenTools/gzipport) | 45 | 76% |autoconf, automake, bash, bison, bzip2, coreutils, cscope, ctags, curl, findutils, flex, gawk, gettext, git, gperf, hello, htop, jq, less, libtool, lz4, m4, make, man-db, ncdu, ncurses, openssh, openssl, patch, php, rsync, screen, sed, sqlite, sshpass, tar, tcl, texinfo, top, wget, which, xxhash, xz, zotsample, zstd
| [gitport](https://github.com/ZOSOpenTools/gitport) | 44 | 96% |autoconf, automake, bash, bison, cmake, ctags, curl, expat, gettext, git, gnulib, gzip, hello, help2man, htop, libgdbm, libpipeline, libtool, m4, make, man-db, meta, ncdu, ncurses, ninja, openssl, patch, perl, php, re2c, rsync, sqlite, sshpass, tar, texinfo, unzip, vim, wget, xz, zigi, zip, zlib, zoslib, zotsample
| [m4port](https://github.com/ZOSOpenTools/m4port) | 39 | 98% |autoconf, automake, bison, coreutils, ctags, curl, expat, flex, gettext, git, gnulib, gpg, groff, gzip, hello, help2man, htop, libgcrypt, libgpgerror, libiconv, libksba, libtool, m4, make, man-db, npth, openssl, php, pinentry, re2c, rsync, screen, sed, sshpass, tar, texinfo, top, wget, which
| [autoconfport](https://github.com/ZOSOpenTools/autoconfport) | 36 | 97% |autoconf, automake, bison, coreutils, ctags, curl, expat, gettext, git, gnulib, gpg, gzip, hello, help2man, htop, libgcrypt, libgpgerror, libiconv, libksba, libtool, m4, make, man-db, nano, npth, openssl, php, pinentry, re2c, rsync, screen, sed, sshpass, tar, texinfo, wget
| [automakeport](https://github.com/ZOSOpenTools/automakeport) | 36 | 71% |autoconf, automake, bison, coreutils, ctags, curl, expat, gettext, git, gnulib, gpg, gzip, hello, help2man, htop, libgcrypt, libgpgerror, libiconv, libksba, libtool, m4, make, man-db, nano, npth, openssl, php, pinentry, re2c, rsync, screen, sed, sshpass, tar, texinfo, wget
| [coreutilsport](https://github.com/ZOSOpenTools/coreutilsport) | 34 | 84% |automake, bash, expat, flex, getopt, gettext, git, gnulib, grep, groff, gzip, hello, jq, libgdbm, libiconv, libpcre, libtool, libxml2, lua, lz4, man-db, ncurses, openssh, patch, php, pkg-config, re2c, sed, sudo, texinfo, vim, which, xxhash, zstd
| [perlport](https://github.com/ZOSOpenTools/perlport) | 34 | 99% |autoconf, automake, bison, coreutils, curl, expat, gettext, git, gnulib, gpg, groff, gzip, hello, help2man, htop, libgcrypt, libgpgerror, libiconv, libksba, libtool, m4, make, man-db, npth, openssl, php, pinentry, re2c, rsync, screen, sed, tar, texinfo, wget
| [tarport](https://github.com/ZOSOpenTools/tarport) | 33 | 92% |automake, bash, bzip2, coreutils, cscope, ctags, curl, findutils, flex, gettext, git, gpg, grep, hello, htop, jq, less, libgcrypt, libgpgerror, libksba, m4, make, ncdu, ncurses, npth, openssh, openssl, pinentry, re2c, screen, sqlite, sshpass, zotsample
| [diffutilsport](https://github.com/ZOSOpenTools/diffutilsport) | 25 | 92% |bash, coreutils, flex, gawk, getopt, git, gnulib, gpg, grep, groff, libgcrypt, libgpgerror, libiconv, libksba, libpcre, libxml2, libxslt, man-db, npth, php, pinentry, re2c, texinfo, vim, xmlto
| [sedport](https://github.com/ZOSOpenTools/sedport) | 24 | 84% |bash, coreutils, git, gpg, groff, libgcrypt, libgpgerror, libiconv, libksba, libssh2, libxml2, libxslt, m4, man-db, ncurses, npth, openssh, perl, php, pinentry, pkg-config, re2c, vim, which
| [gettextport](https://github.com/ZOSOpenTools/gettextport) | 17 | 82% |coreutils, ctags, expat, getopt, git, gpg, hello, libgcrypt, libgpgerror, libiconv, libksba, m4, man-db, nano, npth, pinentry, which
| [texinfoport](https://github.com/ZOSOpenTools/texinfoport) | 17 | 35% |autoconf, automake, bison, curl, expat, gettext, git, gpg, groff, gzip, hello, libtool, m4, make, openssl, sed, tar
| [xzport](https://github.com/ZOSOpenTools/xzport) | 17 | 77% |autoconf, automake, bison, curl, diffutils, expat, findutils, gettext, git, gzip, help2man, libtool, m4, make, man-db, openssl, texinfo
| [help2manport](https://github.com/ZOSOpenTools/help2manport) | 13 | 100% |autoconf, automake, bison, curl, expat, gettext, git, hello, libtool, m4, make, openssl, texinfo
| [ncursesport](https://github.com/ZOSOpenTools/ncursesport) | 12 | 100% |bash, cscope, gettext, git, htop, less, lynx, man-db, nano, ncdu, screen, vim
| [bashport](https://github.com/ZOSOpenTools/bashport) | 10 | 80% |direnv, expat, flex, git, libiconv, libxml2, powerline-go, re2c, texinfo, xmlto
| [opensslport](https://github.com/ZOSOpenTools/opensslport) | 9 | 96% |curl, expat, git, libssh2, lynx, openssh, rsync, sudo, wget
| [zlibport](https://github.com/ZOSOpenTools/zlibport) | 9 | 100% |autoconf, curl, expat, git, libssh2, lynx, openssh, sudo, wget
| [findutilsport](https://github.com/ZOSOpenTools/findutilsport) | 8 | 50% |gnulib, grep, libiconv, libxml2, pkg-config, re2c, texinfo, vim
| [libtoolport](https://github.com/ZOSOpenTools/libtoolport) | 8 | 80% |expat, hello, libgdbm, m4, man-db, php, re2c, texinfo
| [gawkport](https://github.com/ZOSOpenTools/gawkport) | 7 | 93% |automake, curl, expat, gzip, ncurses, rsync, vim
| [grepport](https://github.com/ZOSOpenTools/grepport) | 7 | 94% |gnulib, libpcre, libxslt, m4, man-db, which, xmlto
| [bzip2port](https://github.com/ZOSOpenTools/bzip2port) | 6 | 100% |gpg, libgcrypt, libgpgerror, libksba, npth, pinentry
| [cmakeport](https://github.com/ZOSOpenTools/cmakeport) | 5 | 74% |neovim, ninja, unzip, zip, zoslib
| [libgpgerrorport](https://github.com/ZOSOpenTools/libgpgerrorport) | 5 | No builds |gpg, libgcrypt, libksba, npth, pinentry
| [gperfport](https://github.com/ZOSOpenTools/gperfport) | 3 | 100% |hello, libiconv, m4
| [libiconvport](https://github.com/ZOSOpenTools/libiconvport) | 3 | 100% |libxml2, man-db, php
| [wgetport](https://github.com/ZOSOpenTools/wgetport) | 3 | 18% |hello, man-db, sed
| [getoptport](https://github.com/ZOSOpenTools/getoptport) | 2 | 52% |flex, xmlto
| [groffport](https://github.com/ZOSOpenTools/groffport) | 2 | 100% |libiconv, man-db
| [lessport](https://github.com/ZOSOpenTools/lessport) | 2 | 100% |git, man-db
| [libassuanport](https://github.com/ZOSOpenTools/libassuanport) | 2 | No builds |gpg, pinentry
| [libxml2port](https://github.com/ZOSOpenTools/libxml2port) | 2 | 99% |libxslt, php
| [rsyncport](https://github.com/ZOSOpenTools/rsyncport) | 2 | 88% |m4, sed
| [bisonport](https://github.com/ZOSOpenTools/bisonport) | 1 | Skipped |php
| [comp_goport](https://github.com/ZOSOpenTools/comp_goport) | 1 | Skipped |powerline-go
| [expatport](https://github.com/ZOSOpenTools/expatport) | 1 | 100% |git
| [flexport](https://github.com/ZOSOpenTools/flexport) | 1 | 100% |cscope
| [gnulibport](https://github.com/ZOSOpenTools/gnulibport) | 1 | 100% |htop
| [libgcryptport](https://github.com/ZOSOpenTools/libgcryptport) | 1 | No builds |gpg
| [libgdbmport](https://github.com/ZOSOpenTools/libgdbmport) | 1 | 100% |man-db
| [libksbaport](https://github.com/ZOSOpenTools/libksbaport) | 1 | No builds |gpg
| [libpcreport](https://github.com/ZOSOpenTools/libpcreport) | 1 | 66% |git
| [libpipelineport](https://github.com/ZOSOpenTools/libpipelineport) | 1 | 100% |man-db
| [luaport](https://github.com/ZOSOpenTools/luaport) | 1 | 100% |neovim
| [lz4port](https://github.com/ZOSOpenTools/lz4port) | 1 | 100% |rsync
| [npthport](https://github.com/ZOSOpenTools/npthport) | 1 | No builds |gpg
| [patchport](https://github.com/ZOSOpenTools/patchport) | 1 | 91% |m4
| [pinentryport](https://github.com/ZOSOpenTools/pinentryport) | 1 | No builds |gpg
| [re2cport](https://github.com/ZOSOpenTools/re2cport) | 1 | 80% |php
| [sqliteport](https://github.com/ZOSOpenTools/sqliteport) | 1 | Skipped |php
| [tclport](https://github.com/ZOSOpenTools/tclport) | 1 | Skipped |expect
| [xxhashport](https://github.com/ZOSOpenTools/xxhashport) | 1 | 100% |rsync
| [zipport](https://github.com/ZOSOpenTools/zipport) | 1 | 100% |unzip
| [zstdport](https://github.com/ZOSOpenTools/zstdport) | 1 | 100% |rsync
| [comp_clangport](https://github.com/ZOSOpenTools/comp_clangport) | 0 | Skipped |
| [comp_xlclangport](https://github.com/ZOSOpenTools/comp_xlclangport) | 0 | Skipped |
| [cscopeport](https://github.com/ZOSOpenTools/cscopeport) | 0 | 100% |
| [ctagsport](https://github.com/ZOSOpenTools/ctagsport) | 0 | 100% |
| [direnvport](https://github.com/ZOSOpenTools/direnvport) | 0 | No builds |
| [duckdbport](https://github.com/ZOSOpenTools/duckdbport) | 0 | No builds |
| [emacsport](https://github.com/ZOSOpenTools/emacsport) | 0 | No builds |
| [expectport](https://github.com/ZOSOpenTools/expectport) | 0 | Skipped |
| [fzfport](https://github.com/ZOSOpenTools/fzfport) | 0 | No builds |
| [gpgport](https://github.com/ZOSOpenTools/gpgport) | 0 | No builds |
| [helloport](https://github.com/ZOSOpenTools/helloport) | 0 | 100% |
| [htopport](https://github.com/ZOSOpenTools/htopport) | 0 | No builds |
| [jqport](https://github.com/ZOSOpenTools/jqport) | 0 | 57% |
| [libgit2port](https://github.com/ZOSOpenTools/libgit2port) | 0 | No builds |
| [libssh2port](https://github.com/ZOSOpenTools/libssh2port) | 0 | 100% |
| [libxsltport](https://github.com/ZOSOpenTools/libxsltport) | 0 | 100% |
| [lynxport](https://github.com/ZOSOpenTools/lynxport) | 0 | 100% |
| [man-dbport](https://github.com/ZOSOpenTools/man-dbport) | 0 | 93% |
| [metaport](https://github.com/ZOSOpenTools/metaport) | 0 | 100% |
| [nanoport](https://github.com/ZOSOpenTools/nanoport) | 0 | Skipped |
| [ncduport](https://github.com/ZOSOpenTools/ncduport) | 0 | Skipped |
| [neovimport](https://github.com/ZOSOpenTools/neovimport) | 0 | No builds |
| [ninjaport](https://github.com/ZOSOpenTools/ninjaport) | 0 | 98% |
| [opensshport](https://github.com/ZOSOpenTools/opensshport) | 0 | No builds |
| [phpport](https://github.com/ZOSOpenTools/phpport) | 0 | No builds |
| [pkg-configport](https://github.com/ZOSOpenTools/pkg-configport) | 0 | 100% |
| [powerline-goport](https://github.com/ZOSOpenTools/powerline-goport) | 0 | No builds |
| [pythonport](https://github.com/ZOSOpenTools/pythonport) | 0 | Skipped |
| [screenport](https://github.com/ZOSOpenTools/screenport) | 0 | Skipped |
| [shufport](https://github.com/ZOSOpenTools/shufport) | 0 | No builds |
| [sshpassport](https://github.com/ZOSOpenTools/sshpassport) | 0 | Skipped |
| [sudoport](https://github.com/ZOSOpenTools/sudoport) | 0 | No builds |
| [terraformport](https://github.com/ZOSOpenTools/terraformport) | 0 | No builds |
| [topport](https://github.com/ZOSOpenTools/topport) | 0 | No builds |
| [unzipport](https://github.com/ZOSOpenTools/unzipport) | 0 | 100% |
| [vimport](https://github.com/ZOSOpenTools/vimport) | 0 | 100% |
| [whichport](https://github.com/ZOSOpenTools/whichport) | 0 | 100% |
| [xmltoport](https://github.com/ZOSOpenTools/xmltoport) | 0 | 100% |
| [yqport](https://github.com/ZOSOpenTools/yqport) | 0 | Skipped |
| [zigiport](https://github.com/ZOSOpenTools/zigiport) | 0 | Skipped |
| [zotsampleport](https://github.com/ZOSOpenTools/zotsampleport) | 0 | 100% |

## Projects with the most patches

| Package | # of Patched Lines | # of Patches
|---|---|--|
|  [bashport](https://github.com/ZOSOpenTools/bashport) | 2821 | 25
|  [cmakeport](https://github.com/ZOSOpenTools/cmakeport) | 2328 | 1
|  [gitport](https://github.com/ZOSOpenTools/gitport) | 1573 | 30
|  [htopport](https://github.com/ZOSOpenTools/htopport) | 1258 | 16
|  [sudoport](https://github.com/ZOSOpenTools/sudoport) | 1210 | 1
|  [perlport](https://github.com/ZOSOpenTools/perlport) | 619 | 1
|  [coreutilsport](https://github.com/ZOSOpenTools/coreutilsport) | 610 | 9
|  [rsyncport](https://github.com/ZOSOpenTools/rsyncport) | 381 | 7
|  [phpport](https://github.com/ZOSOpenTools/phpport) | 369 | 11
|  [flexport](https://github.com/ZOSOpenTools/flexport) | 340 | 2
|  [screenport](https://github.com/ZOSOpenTools/screenport) | 325 | 1
|  [opensshport](https://github.com/ZOSOpenTools/opensshport) | 279 | 1
|  [man-dbport](https://github.com/ZOSOpenTools/man-dbport) | 275 | 10
|  [ninjaport](https://github.com/ZOSOpenTools/ninjaport) | 274 | 1
|  [zstdport](https://github.com/ZOSOpenTools/zstdport) | 221 | 3
|  [gpgport](https://github.com/ZOSOpenTools/gpgport) | 205 | 4
|  [autoconfport](https://github.com/ZOSOpenTools/autoconfport) | 175 | 7
|  [findutilsport](https://github.com/ZOSOpenTools/findutilsport) | 161 | 6
|  [gettextport](https://github.com/ZOSOpenTools/gettextport) | 146 | 6
|  [diffutilsport](https://github.com/ZOSOpenTools/diffutilsport) | 140 | 8
|  [tclport](https://github.com/ZOSOpenTools/tclport) | 130 | 5
|  [vimport](https://github.com/ZOSOpenTools/vimport) | 125 | 6
|  [pkg-configport](https://github.com/ZOSOpenTools/pkg-configport) | 98 | 1
|  [lessport](https://github.com/ZOSOpenTools/lessport) | 94 | 5
|  [grepport](https://github.com/ZOSOpenTools/grepport) | 88 | 2
|  [patchport](https://github.com/ZOSOpenTools/patchport) | 86 | 3
|  [gawkport](https://github.com/ZOSOpenTools/gawkport) | 81 | 4
|  [curlport](https://github.com/ZOSOpenTools/curlport) | 74 | 2
|  [xmltoport](https://github.com/ZOSOpenTools/xmltoport) | 74 | 1
|  [libtoolport](https://github.com/ZOSOpenTools/libtoolport) | 71 | 3
|  [libgcryptport](https://github.com/ZOSOpenTools/libgcryptport) | 59 | 4
|  [powerline-goport](https://github.com/ZOSOpenTools/powerline-goport) | 57 | 1
|  [tarport](https://github.com/ZOSOpenTools/tarport) | 55 | 1
|  [unzipport](https://github.com/ZOSOpenTools/unzipport) | 54 | 1
|  [libgdbmport](https://github.com/ZOSOpenTools/libgdbmport) | 52 | 1
|  [nanoport](https://github.com/ZOSOpenTools/nanoport) | 52 | 1
|  [emacsport](https://github.com/ZOSOpenTools/emacsport) | 47 | 2
|  [ncursesport](https://github.com/ZOSOpenTools/ncursesport) | 46 | 1
|  [pinentryport](https://github.com/ZOSOpenTools/pinentryport) | 46 | 3
|  [luaport](https://github.com/ZOSOpenTools/luaport) | 45 | 1
|  [bisonport](https://github.com/ZOSOpenTools/bisonport) | 41 | 2
|  [xxhashport](https://github.com/ZOSOpenTools/xxhashport) | 38 | 2
|  [expatport](https://github.com/ZOSOpenTools/expatport) | 37 | 1
|  [texinfoport](https://github.com/ZOSOpenTools/texinfoport) | 33 | 2
|  [expectport](https://github.com/ZOSOpenTools/expectport) | 31 | 2
|  [lynxport](https://github.com/ZOSOpenTools/lynxport) | 30 | 1
|  [lz4port](https://github.com/ZOSOpenTools/lz4port) | 30 | 3
|  [jqport](https://github.com/ZOSOpenTools/jqport) | 29 | 1
|  [npthport](https://github.com/ZOSOpenTools/npthport) | 28 | 2
|  [getoptport](https://github.com/ZOSOpenTools/getoptport) | 25 | 1
|  [groffport](https://github.com/ZOSOpenTools/groffport) | 25 | 2
|  [wgetport](https://github.com/ZOSOpenTools/wgetport) | 22 | 1
|  [sqliteport](https://github.com/ZOSOpenTools/sqliteport) | 21 | 1
|  [fzfport](https://github.com/ZOSOpenTools/fzfport) | 20 | 1
|  [bzip2port](https://github.com/ZOSOpenTools/bzip2port) | 17 | 1
|  [makeport](https://github.com/ZOSOpenTools/makeport) | 16 | 1
|  [libksbaport](https://github.com/ZOSOpenTools/libksbaport) | 15 | 1
|  [libssh2port](https://github.com/ZOSOpenTools/libssh2port) | 15 | 1
|  [libgpgerrorport](https://github.com/ZOSOpenTools/libgpgerrorport) | 14 | 1
|  [automakeport](https://github.com/ZOSOpenTools/automakeport) | 12 | 1
| &#10003; [comp_clangport](https://github.com/ZOSOpenTools/comp_clangport) | 0 | 0
| &#10003; [comp_goport](https://github.com/ZOSOpenTools/comp_goport) | 0 | 0
| &#10003; [comp_xlclangport](https://github.com/ZOSOpenTools/comp_xlclangport) | 0 | 0
| &#10003; [cscopeport](https://github.com/ZOSOpenTools/cscopeport) | 0 | 0
| &#10003; [ctagsport](https://github.com/ZOSOpenTools/ctagsport) | 0 | 0
| &#10003; [direnvport](https://github.com/ZOSOpenTools/direnvport) | 0 | 0
| &#10003; [duckdbport](https://github.com/ZOSOpenTools/duckdbport) | 0 | 0
| &#10003; [gnulibport](https://github.com/ZOSOpenTools/gnulibport) | 0 | 0
| &#10003; [gperfport](https://github.com/ZOSOpenTools/gperfport) | 0 | 0
| &#10003; [gzipport](https://github.com/ZOSOpenTools/gzipport) | 0 | 0
| &#10003; [helloport](https://github.com/ZOSOpenTools/helloport) | 0 | 0
| &#10003; [help2manport](https://github.com/ZOSOpenTools/help2manport) | 0 | 0
| &#10003; [libassuanport](https://github.com/ZOSOpenTools/libassuanport) | 0 | 0
| &#10003; [libgit2port](https://github.com/ZOSOpenTools/libgit2port) | 0 | 0
| &#10003; [libiconvport](https://github.com/ZOSOpenTools/libiconvport) | 0 | 0
| &#10003; [libpcreport](https://github.com/ZOSOpenTools/libpcreport) | 0 | 0
| &#10003; [libpipelineport](https://github.com/ZOSOpenTools/libpipelineport) | 0 | 0
| &#10003; [libxml2port](https://github.com/ZOSOpenTools/libxml2port) | 0 | 0
| &#10003; [libxsltport](https://github.com/ZOSOpenTools/libxsltport) | 0 | 0
| &#10003; [m4port](https://github.com/ZOSOpenTools/m4port) | 0 | 0
| &#10003; [metaport](https://github.com/ZOSOpenTools/metaport) | 0 | 0
| &#10003; [ncduport](https://github.com/ZOSOpenTools/ncduport) | 0 | 0
| &#10003; [neovimport](https://github.com/ZOSOpenTools/neovimport) | 0 | 0
| &#10003; [opensslport](https://github.com/ZOSOpenTools/opensslport) | 0 | 0
| &#10003; [pythonport](https://github.com/ZOSOpenTools/pythonport) | 0 | 0
| &#10003; [re2cport](https://github.com/ZOSOpenTools/re2cport) | 0 | 0
| &#10003; [sedport](https://github.com/ZOSOpenTools/sedport) | 0 | 0
| &#10003; [shufport](https://github.com/ZOSOpenTools/shufport) | 0 | 0
| &#10003; [sshpassport](https://github.com/ZOSOpenTools/sshpassport) | 0 | 0
| &#10003; [terraformport](https://github.com/ZOSOpenTools/terraformport) | 0 | 0
| &#10003; [topport](https://github.com/ZOSOpenTools/topport) | 0 | 0
| &#10003; [whichport](https://github.com/ZOSOpenTools/whichport) | 0 | 0
| &#10003; [xzport](https://github.com/ZOSOpenTools/xzport) | 0 | 0
| &#10003; [yqport](https://github.com/ZOSOpenTools/yqport) | 0 | 0
| &#10003; [zigiport](https://github.com/ZOSOpenTools/zigiport) | 0 | 0
| &#10003; [zipport](https://github.com/ZOSOpenTools/zipport) | 0 | 0
| &#10003; [zlibport](https://github.com/ZOSOpenTools/zlibport) | 0 | 0
| &#10003; [zoslibport](https://github.com/ZOSOpenTools/zoslibport) | 0 | 0
| &#10003; [zotsampleport](https://github.com/ZOSOpenTools/zotsampleport) | 0 | 0

Last updated:  2023-05-23 15:53:09
