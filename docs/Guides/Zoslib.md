# Leveraging the ZOSLIB library

## What is ZOSLIB?

**ZOSLIB** is a z/OS C/C++ library. It is an extended implementation of the z/OS LE C Runtime Library.

ZOSLIB implements the following:
* A subset of POSIX APIs that are not available in the LE C Runtime Library
* Overrides for C open, pipe, and more for improved functionality with z/OS auto-conversion facilities.
* EBCDIC <-> ASCII conversion C APIs
* APIs for improved diagnostic reporting
* and more!

You can find more details at the [ZOSLIB github page](https://github.com/ibmruntimes/zoslib/tree/zopen).

The corresponding `zopen` project lives [here](https://github.com/ZOSOpenTools/zoslibport).

## How can ZOSLIB help my project?

As we continue to port projects to z/OS, we have come across many common issues. Rather than repeating the same patterns and duplicating the solutions on a per project basis, we decided to take a different approach. We decided to solve the issues by linking to an intermediary library, ZOSLIB.

ZOSLIB is an actively developed library that's currently being used by 20+ z/OS Open Tools projects, including curl, git, bash and more.

ZOSLIB aims to automatically resolve the following types of issues:
* Tagging file descriptors which are not tagged appropriately via C open, mkstemp or pipe.
* Missing POSIX/glibc function or types. (e.g. posix_spawn)
* Missing header files. (e.g. sys/mount.h)

As an example, the C `open` function has been overridden to automatically tag new files as ASCII, and similarly for C `pipe` and `mkstemp`. When zoslib is added to your project, in the case of C `open` function, all references to open are mapped to a new zoslib `__open_ascii` function (defined [here](https://github.com/ibmruntimes/zoslib/blob/zopen/src/zos-io.cc#L720)), which implements this auto-tagging logic.

## How do I leverage zoslib?

Very easily!

Through the zopen framework, all you need to do is to add `zoslib` as a dependency as follows:
```bash
export ZOPEN_DEPS="curl gzip tar make zoslib"
```
Here's a [real example](https://github.com/ZOSOpenTools/curlport/blob/main/buildenv#L3) where the curl port added zoslib as a dependency.

### How does this work?
This works because ZOSLIB exposes a set of environment variable flags via it's [buildenv](https://github.com/ZOSOpenTools/zoslibport/blob/main/buildenv#L35).
These environment variable will automatically be added to your project when it is included as a dependency. They instruct the compiler to pick up the header files and link to the appropriate zoslib static archive.

## How do I contribute?
We are happy to accept community code changes!
Open a pull request at https://github.com/ibmruntimes/zoslib/pulls
