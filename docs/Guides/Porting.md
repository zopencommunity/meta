# Porting to z/OS

## Getting Started

### Leveraging the ZOS Open Tools utils repo

The utils repo (https://github.com/ZOSOpenTools/utils) consists of common tools and files that aid
in the porting process, including `build.sh` which provides a common way to bootstrap, configure, build, check,
and install a software package.

Before you begin to build code, ensure that your environment is correctly configured

### Set up your environment

This is the most cumbersome step, but is only required to be done once. 

The tools assume an ASCII/UTF-8 environment, and so you should ensure that you have the following environment
variables set:

```
export _BPXK_AUTOCVT=ON
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
If you are building from a ZOSOpenTools port, this `.env` file will be created as part of the install process, but if you
are providing a `boot` version of the tool (e.g. cURL), then you will need to provide your own version of `.env`. 
