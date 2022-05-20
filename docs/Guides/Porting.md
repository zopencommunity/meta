# Porting to z/OS

## Getting Started

### Leveraging the ZOS Open Tools utils repo

The utils repo (https://github.com/ZOSOpenTools/utils) consists of common tools and files that aid
in the porting process.

## build.sh
The build.sh script provides a general-purpose way to build one or more tools in the z/OS Open Tools repositories.
`build.sh` does require that you follow a prescriptive way to set up your build environment, described as follows:

### Set up your environment

This is the most cumbersome step, but is only required to be done once. 

The tools assume an ASCII/UTF-8 environment, and so you should ensure that you have the following environment
variables set:

```
if [ "${_BPXK_AUTOCVT}" != "ALL" ]; then
  export _BPXK_AUTOCVT=ON
fi
export _CEE_RUNOPTS="$_CEE_RUNOPTS FILETAG(AUTOCVT,AUTOTAG) POSIX(ON)"
export _TAG_REDIR_ERR=txt
export _TAG_REDIR_IN=txt
export _TAG_REDIR_OUT=txt
```

The z/OS Open Tools reside in `github.com`. You need to configure your user.email and user.name to check in code to the
repositories:

```
git config --global user.email "<Your E-Mail>"
git config --global user.name "<Your Name>"
```

Many tools depend on other tools to be able to build or run. You will need to provide both _bootstrap_ tools 
(i.e. binary tools not from source), as well as _prod_ tools (i.e. _production_ level tools previously built 
from another z/OS Open Tools repository). 
Our goal is to eventually have our own version of all the _bootstrap_ tools, but right now, we rely on some 
tools from Rocket. These tools can be downloaded from (https://my.rocketsoftware.com/RocketCommunity#/downloads). 

Many tools require a C or C++ compiler (or both). xlclang 2.4.1 or higher should be used for C/C++ compilation
and can be downloaded from (https://www.ibm.com/servers/resourcelink/svc00100.nsf/pages/xlCC++V241ForZOsV24). 

In order for the tools to be able to locate dependent tools, they need to be in well-defined locations. 
Tools will be searched for in the following locations, in order:
- `${HOME}/zot/prod/<tool>`
- `/usr/bin/zot/<tool>`
- `${HOME}/zot/boot/<tool>` 

So for example, `make` depends on `m4` to build. `build.sh` will search for `m4` first in the
personal _prod_ build from `${HOME}/zot/prod/m4`, then the system-wide build in `/usr/bin/zot/m4`, and
finally in the personal _boot_ directory `${HOME}/zot/boot/m4`. Symbolic links can be used as required 
to share builds between developers on a system, if desired.

Each tool is responsible for knowing how to set it's own environment up (e.g. PATH, LIBPATH, and any other environment variables).
Each tool needs to provide a `.env` program that can be source'd from it's directory to set up it's environment. 
In the example above, assume the only installed version of `m4` is `${HOME}/zot/boot/m4`. `build.sh` will:
- `cd ${HOME}/zot/boot/m4`
- `. ./env`
to set up the environment for `m4`. If the `.env` file does not exist, the build will fail. 

### Requirements to use build.sh

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



