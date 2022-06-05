# utils
Utilities (common tools) repository used by other repos in ZOSOpenTools

The following is a description of the utilities provided in the utils repo.
For an overview	of ZOSOpenTools, see [ZOSOpenTools docs](https://zosopentools.github.io/meta/)

## build.sh

For a software package to be built with `build.sh`, it needs to provide the following:
- a script called: `setenv.sh`, located in the root directory of the git repo, which the developer will source 
before running `build.sh`
- a script called: `portchk.sh`, located in the root directory of the git repo, so that the test process can check
that the build is _good enough_ to be considered for installation.
- a script called: `portcrtenv.sh`, located in the root directory of the git repo, so that the install process can 
create the corresponding `.env` file for the software product.  For _boot_ products from Rocket, the developer will need to create the corresponding `.env` file (or copy one already made by another developer). 

The `setenv.sh` file _must_ set the following environment variables:
- `PORT_ROOT`: this environment variable is the absolute directory of the location the repo was clone'd to
- `PORT_TYPE`: one of _TARBALL_ or _GIT_ indicating where the source should be pulled from (a source tarball or git repository)
- `PORT_URL`: the URL where the source should be pulled from, including the `package.git` or `package-V.R.M.tar.gz` extension
- `PORT_DEPS`: a space-separated list of all software dependencies this package has.
Note that you can choose the fully-qualified environment variables PORT_GIT_URL, PORT_GIT_DEPS and PORT_TARBALL_URL, PORT_TARBALL_DEPS 
accordingly if you prefer. See (https://github.com/ZOSOpenTools/autoconfport/blob/main/setenv.sh) for an example.

There are several additional environment variables that can be specified to provide finer-grained control of the build process. 
For details see: (https://github.com/ZOSOpenTools/utils/blob/main/bin/build.sh). 

### Running build.sh

Run `build.sh` from the root directory of the git repo you would like to build.  For example, m4:
```
cd ${HOME}/zot/dev/m4
${HOME}/zot/dev/utils/bin/build.sh
```



