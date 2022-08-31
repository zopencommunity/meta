# utils
Utilities (common tools) repository used by other repos in ZOSOpenTools

The following is a description of the utilities provided in the utils repo.
For an overview	of ZOSOpenTools, see [ZOSOpenTools docs](https://zosopentools.github.io/meta/)

## zopen download

To download and install the latest software packages, you can use `zopen download`. By default it will download all of the binaries hosted on ZOSOpenTools.

To download and install a specific package, you can specify the `-r` option as follows:
```
zopen download -r makeport
```

This will download it to the current working directory. To change the destination directory, you can specify the `-d` option as follows:

```
zopen download -r makeport -d $HOME/zopen
```

## zopen build

To build a software package, you can use `zopen build`.

`zopen build` requires the files scripts in the project's root directory:
-  `buildenv`, which `zopen build` will automatically source.  If you would like to source another file, you can specify it via the `-e` option as in: `zopen build -e mybuildenv`

The `buildenv` file _must_ set the following environment variables:
- `ZOPEN_TYPE`: one of _TARBALL_ or _GIT_ indicating where the source should be pulled from (a source tarball or git repository)
- `ZOPEN_URL`: the URL where the source should be pulled from, including the `package.git` or `package-V.R.M.tar.gz` extension
- `ZOPEN_DEPS`: a space-separated list of all software dependencies this package has.

To help guage the health of the port, a zopen_check_results function can be provided inside the buildenv. The following return codes map to a given status:
- 0 - Green - All tests passed
- 1 - Blue - Most tests passed
- 2 - Yellow - Most tests failed
- 3 - Red - All tests failed or check is broken
- 4 - Unknown - Skipped or something went wrong

To get started, generate a zopen project with `zopen generate`

`zopen build` will generate a .env file in the install location with support for environment variables such as PATH, LIBPATH, and MANPATH.
To add your own, you can append environment variables by echo'ing them in a function called zopen_append_to_env.

Note that you can choose the fully-qualified environment variables ZOPEN_GIT_URL, ZOPEN_GIT_DEPS and ZOPEN_TARBALL_URL, ZOPEN_TARBALL_DEPS 
accordingly if you prefer. See (https://github.com/ZOSOpenTools/zotsampleport/blob/main/setenv.sh) for an example.

There are several additional environment variables that can be specified to provide finer-grained control of the build process. 
For details
- Run `zopen build -h` for a description of all the environment variables
- Read the code: (https://github.com/ZOSOpenTools/utils/blob/main/bin/zopen-build). 

For a sample port, visit the [zotsampleport](https://github.com/ZOSOpenTools/zotsampleport) repo.

### Running zopen build

Run `zopen build` from the root directory of the git repo you would like to build.  For example, m4:
```
cd ${HOME}/zot/dev/m4
${HOME}/zot/dev/utils/bin/zopen build
```
