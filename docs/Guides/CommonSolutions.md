# Common Issues and Solutions

## C pipe, C open do not tag newly created file descriptors

> **Note:** In most cases you can use the `zoslibport` package for ASCII/EBCDIC issues. See [zoslib](https://github.com/zopencommunity/zoslibport) for details.

A common problem when porting code to z/OS and building with ASCII is that when files are created, the contents are written out in ASCII but by default the files are not tagged to indicate the content is in ASCII. Subsequently, other tools have to _guess_ what codepage the contents are in, and often the tools _guess_ EBCDIC.

There are many ways that people describe an encoding:

- ASCII, EBCDIC, Single-byte, Double-byte, Multi-byte are fairly generic terms.
- When specifying an ASCII or EBCDIC format, the more precise _coded character set identifier_ (CCSID) is used. We code to CCSID _ISO8859-1_, also known as _819_, because z/OS is optimized for this particular ASCII CCSID, and it is consistent with what people on other platforms equate to _ASCII_.

The following C code tags a file when it is opened for write as 819 (ISO8859-1):

```c
fd = open(...); /* open new file for WRITE */
if (fd < 0) { ... } /* unable to open file */
#ifdef __MVS__
  #if (__CHARSET_LIB == 1)
    setccsid(fd, 819);
  #endif
#endif
```

You can also tag a file as 819 using the shell as follows:

```bash
chtag -tc819 <file>
```

or alternatively:

```bash
chtag -tcISO8859-1 <file>
```

The z/OS-specific code needs to be double-protected. The `#ifdef __MVS__` ensures that this is specific to z/OS. The `#if (__CHARSET_LIB == 1)` ensures that this code is only active when being built with `-qascii`, so that if others want to build with EBCDIC, they won't get this behaviour. The function `setccsid` is also required. Here is a simple version:

```c
#ifdef __MVS__
 #if (__CHARSET_LIB == 1)
#   include <stdio.h>
#   include <stdlib.h>

    static int setccsid(int fd, int ccsid)
    {
      attrib_t attr;
      int rc;

      memset(&attr, 0, sizeof(attr));
      attr.att_filetagchg = 1;
      attr.att_filetag.ft_ccsid = ccsid;
      attr.att_filetag.ft_txtflag = 1;

      rc = __fchattr(fd, &attr, sizeof(attr));
      return rc;
    }
  #endif
#endif
```

Further reading:

- [chtag - Change file tag information](https://www.ibm.com/docs/en/zos/latest?topic=descriptions-chtag-change-file-tag-information)
- [ASCII and EBCDIC on z/OS](https://makingdeveloperslivesbetter.wordpress.com/2022/01/07/is-z-os-ascii-or-ebcdic-yes/)
- [Character sets](https://www.ibm.com/docs/en/ztpf/latest?topic=support-character-sets)
- [CCSID](https://en.wikipedia.org/wiki/CCSID)
- [ASCII 8859-1](https://en.wikipedia.org/wiki/ISO/IEC_8859-1)

## FSUM7327 signal number XX not conventional

> **Note:** If you are seeing this error in a source file from the gnulib tools package, a fix for this has been [upstreamed](https://git.savannah.gnu.org/gitweb/?p=gnulib.git;a=commit;h=835b3ea801782fcf72ef1f9397bb112cac0e2f50) on November 26, 2022. The fix is probably to get the software package to pick up a new version of gnulib tools.

See: [FSUM7327](https://tech.mikefulton.ca/FSUM7327) and [kill](https://tech.mikefulton.ca/POSIXSignalNumbers).

Only _some_ signals have a well-defined number that can be used when specifying an action (such as kill or trap). Signal number 13 (PIPE) is _not_ a well-defined signal number. Code that specifies signal 13 gets the cryptic error message above and can be re-coded to use `PIPE` instead.

Here is a common code sequence you might see in a shell script for testing or configuring:

```bash
do_exit='rm -f $log_file $trs_file; (exit $st); exit $st'
trap "st=129; $do_exit" 1
trap "st=130; $do_exit" 2
trap "st=141; $do_exit" 13
trap "st=143; $do_exit" 15
```

Change the `13` to `PIPE`:

```bash
do_exit='rm -f $log_file $trs_file; (exit $st); exit $st'
trap "st=129; $do_exit" 1
trap "st=130; $do_exit" 2
trap "st=141; $do_exit" PIPE
trap "st=143; $do_exit" 15
```

Ideally, use signal names throughout:

```bash
do_exit='rm -f $log_file $trs_file; (exit $st); exit $st'
trap "st=129; $do_exit" HUP
trap "st=130; $do_exit" INT
trap "st=141; $do_exit" PIPE
trap "st=143; $do_exit" TERM
```

For Linux, signal numbers can be found under [signal(7)](https://www.man7.org/linux/man-pages/man7/signal.7.html). On z/OS, see `/usr/include/le/signals.h`.

## CEE3728S The use of a function not supported by this release of Language Environment

LE provides stubs for some functions that are not yet implemented. This means that they exist in the DLL and side deck, but if you call them they just output the CEE3728S error message. This causes a problem for builds which detect the available functions on the target OS and conditionally include source based on the detected functions.

The issue can be addressed with a workaround which removes the stub functions from the side deck:

- Clone the [https://github.com/MikeFultonDev/sbin](https://github.com/MikeFultonDev/sbin) repository to your z/OS system.
- Run the `rmceertfm` script to produce an edited side deck in `/tmp`.
- Take your own copy of the `CEE.SCEELIB` dataset with all members.
- Replace the `CELQS003` member with the modified version created by `rmceertfm`:

```bash
cp /tmp/celqs003.x "//'FRED.ZOPEN.ZOS204.SCEELIB(CELQS003)'"
```

- Take your own copy of the xlclang configuration file:

```bash
cp /usr/lpp/cbclib/xlclang/etc/xlclang.cfg /u/fred/xlclang.cfg.zos204.noceertfm
```

- Edit the copy of the config file, updating `exportlist_c_64` and `exportlist_cpp_64` to point to the modified SCEELIB dataset:

```
exportlist_c_64   = fred.zopen.zos204.sceelib(celqs003)
exportlist_cpp_64 = fred.zopen.zos204.sceelib(celqs003,celqscpp,cxxrt64)
```

- Tell the compiler to use the modified config file:

```bash
export CLC_CONFIG=/u/fred/xlclang.cfg.zos204.noceertfm
```

## S_TYPEISSHM macro gives an error when compiled

The error might be something like: `called object type 'int' is not a function or function pointer`

This is due to a bug in the LE header file `sys/modes.h` which defines the macros as:

```c
#ifdef __SUSV3_POSIX
  #define S_TYPEISMQ  (0)         /* Test for a message queue */
  #define S_TYPEISSEM (0)         /* Test for a semaphore     */
  #define S_TYPEISSHM (0)         /* Test for a shared memory object */
#endif /* __SUSV3_POSIX */
```

This is wrong because the macro expects a parameter. The simplest workaround is to provide a patch:

```c
+#ifdef __MVS__
+  /* z/OS incorrectly defined these macros - redefine them */
+  #ifdef S_TYPEISSEM
+     #undef S_TYPEISSEM
+     #define S_TYPEISSEM(x) (0)
+  #endif
+  #ifdef S_TYPEISMQ
+     #undef S_TYPEISMQ
+     #define S_TYPEISMQ(x) (0)
+  #endif
+  #ifdef S_TYPEISSHM
+     #undef S_TYPEISSHM
+     #define S_TYPEISSHM(x) (0)
+  #endif
+  #ifdef S_TYPEISTMO
+     #undef S_TYPEISTMO
+     #define S_TYPEISTMO(x) (0)
+  #endif
+#endif
```

## Libtool complains that passing .o object files as libraries is not allowed

By default, projects that use libtool during the build phase will complain about the use of `.o` files as libraries when they are passed in via the `LIBS` variable. For example:

```
libtool:   error: cannot build libtool library 'liblzma.la' from non-libtool objects on this host: /home/itodoro/zopen-data/prod/zoslib-autocvt_tty/lib/celquopt.s.o
```

When zoslib is included as a dependency, it automatically adds `.o` files to the `ZOPEN_EXTRA_LIBS` environment variable, which will eventually be passed as the `LIBS` variable.

To override this, modify the `configure` script as follows:

```
+openedition)
+  lt_cv_deplibs_check_method=pass_all
+  ;;
```

See this example pull request for man-db: [https://github.com/zopencommunity/man-dbport/pull/23/files](https://github.com/zopencommunity/man-dbport/pull/23/files).

## Displaying compile commands in the build output

When building projects, it can be helpful to see the actual compile commands being executed. The `zopen build` tool provides a `-vv` option for very verbose output:

```bash
zopen build -vv
```

Internally, zopen sets the `V` and `VERBOSE` environment variables to `1` when the `-vv` option is specified. GNU Make and other build systems respect these variables and display the executed commands during the build process.

## Some of the text colors are too bright for my terminal's background

If your background is a lighter color, the header or warning colors could be almost impossible to read as they are by default yellow. Set the following **bash** environment variable to change the color scheme to fit a light terminal background:

```bash
export COLORFGBG="0;15"
```
