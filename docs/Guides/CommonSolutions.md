# Common Issues and their solutions

## C pipe, C open do not tag newly created file descriptors
A common problem when porting code to z/OS and building with ASCII is that when files are created, the contents are written out in ASCII
but by default the files are not tagged to indicate the content is in ASCII. Subsequently, other tools have to _guess_ what codepage the contents are in, and often the tools _guess_ EBCDIC. 
The solution is to tag the file when it is opened for write, and to tag it ASCII. Here is a typical sequence:
```
fd = open(...); /* open new file for WRITE */
if (fd < 0) { ... } /* unable to open file */
#ifdef __MVS__
  #if (__CHARSET_LIB ==	1)
    setccsid(fd, 819);
  #endif
#endif
```
The z/OS specific code needs to be double-protected. The `#ifdef __MVS__` ensures that this is specific to z/OS. 
The `#if (__CHARSET_LIB == 1)` ensures that this code is only active when being built with `-qascii`, so that if others want to build with 
EBCDIC, they won't get this behaviour.
The function `setccsid` is also required. This can be either a static function if all the calls to setccsid are in one file, or an external function.
Here is a simple version - you may need something more complex if you want to check how the file is opened first (e.g. to prevent setting the CCSID if the file is being opened for READ):
```
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

## FSUM7327 signal number XX not conventional
See: [FSUM7327](https://tech.mikefulton.ca/FSUM7327) which is relatively cryptic and [kill](https://tech.mikefulton.ca/POSIXSignalNumbers).

Only _some_ signals have a well-defined number that can be used when specifying an action (such as kill or trap). In particular, signal number 13 (which is SIGPIPE) is _not_ a well-defined signal number.
As such, code that specifies signal 13 gets the cryptic error message above and can be re-coded to use SIGPIPE instead (see signal.h if the signal number in question isn't 13, in which case you will need to see what a Linux signal XX is and then re-code it with a name)
