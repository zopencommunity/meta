# Porting to z/OS

## Getting Started

### Leveraging the ZOS Open Tools utils repo

The utils repo (https://github.com/ZOSOpenTools/utils) consists of common tools and files that aid
in the porting process, including the `zopen` suite of tools.  Specifically, `zopen build` provides a common way to bootstrap, configure, build, check,
and install a software package.  `zopen download` provides a mechanism to download the latest published z/OS Open Tools.

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

The z/OS Open Tools reside in https://github.com/ZOSOpenTools. You need to configure your user.email and user.name to check in code to the
repositories:

```
git config --global user.email "<Your E-Mail>"
git config --global user.name "<Your Name>"
```

Many tools depend on other tools to be able to build or run. You will need to provide both _bootstrap_ tools 
(i.e. binary tools not from source), as well as _prod_ tools (i.e. _production_ level tools previously built 
from another z/OS Open Tools repository). 
Our goal is to eventually have our own version of all the _bootstrap_ tools, but right now, we rely on some 
tools from Rocket. These Rocket tools can be downloaded from (https://my.rocketsoftware.com/RocketCommunity#/downloads). 

Many tools require a C or C++ compiler (or both). xlclang 2.4.1 or higher should be used for C/C++ compilation
and can be downloaded from (https://www.ibm.com/servers/resourcelink/svc00100.nsf/pages/xlCC++V241ForZOsV24). 

In order for the tools to be able to locate dependent tools, they need to be in well-defined locations. 
Tools will be searched for in the following locations, in order:
- `${HOME}/zopen/prod/<tool>`
- `/usr/bin/zopen/<tool>`
- `${HOME}/zopen/boot/<tool>` 

So for example, `make` depends on `m4` to build. `zopen build` will search for `m4` first in the
personal _prod_ build from `${HOME}/zopen/prod/m4`, then the system-wide build in `/usr/bin/zopen/m4`, and
finally in the personal _boot_ directory `${HOME}/zopen/boot/m4`. Symbolic links can be used as required 
to share builds between developers on a system, if desired.  You can also add your own directories to the search path by specifying the -d option to `zopen build` as follows:
```bash
zopen build -d $HOME/mytools
```

Each tool is responsible for knowing how to set it's own environment up (e.g. PATH, LIBPATH, and any other environment variables).
Each tool needs to provide a `.env` program that can be source'd from it's directory to set up it's environment. 
If you are building from a ZOSOpenTools port, this `.env` file will be created as part of the install process, but if you
are providing a `boot` version of the tool (e.g. cURL), then you will need to provide your own version of `.env`. 

### Create your first z/OS port leveraging the zopen framework

Before you begin porting a tool to z/OS, you must first identify the tool or library that you wish to port. For the sake of this guide, let's assume we are porting [jq](https://stedolan.github.io/jq/), a lightweight and flexible json parser. Next, check if the tool already exists under https://github.com/ZOSOpenTools. If it does exist, then please collaborate with the existing author.

Begin first by cloning the example repository [zotsamplerepo](https://github.com/ZOSOpenTools/zotsampleport).  
This repository contains the essential elements required to begin porting your application or library to z/OS.

In addition to the zotsamplerepo, you must also clone the https://github.com/ZOSOpenTools/utils repo.  This repo contains the `zopen` framework and it is what we will use to build, test, and install our port.

```bash
# Clone the required repositories
git clone git@github.com:ZOSOpenTools/utils.git
git clone git@github.com:ZOSOpenTools/zotsampleport.git jqport # make sure to name the directory as <toolname>port
```

Next, in order to use the `zopen` suite of tools, you must set your path environment variable to the `utils/bin` directory. 
```bash
export PATH=$PWD/utils/bin:$PATH
```

Ok, now you are ready to begin porting. Change your current directory to the `jqport` directory: `cd jqport`. You will notice several files. The key files of interest are:
* buildenv - describes the minimal environment variables required to set up a port environment.
* portchk.sh - this checks the `make test` output to verify that the tests passed
* portcrtenv.sh - this creates the `.env` file that will be sourced upon installation
For more information, please visit the [zopen build README](https://github.com/ZOSOpenTools/utils)

`zopen build` supports projects based in github repositories or tarball locations. Since autoconf/automake are not currently functioning on z/OS, we typically choose the tarball location because it contains a `configure` script pre-packaged. Let's go ahead and do this for `jq`.

In the `buildenv` file, we'll erase the existing contents and the following:
```bash
export ZOPEN_ROOT=$PWD
export ZOPEN_TYPE="TARBALL"
export ZOPEN_TARBALL_URL="https://github.com/stedolan/jq/releases/download/jq-1.6/jq-1.6.tar.gz"
export ZOPEN_TARBALL_DEPS="make" 
```
ZOPEN_TARBALL_DEPS represents the set of dependencies that jq needs. We're currently only aware of `make` since it contains a Makefile.

Next, we can go ahead and test our build.  Run the following:
```bash
zopen build -v 
```

The `-v` option above specifies verbose output.

*Creating Patches*
As you may have noticed, `zopen build` downloads the `tar.gz` file, and then attempts to patch it with the patch contents in the `patches` directory.

As you port your application to z/OS, you will identify a set of _patches_. These patches represent the set of changes in order to get your tool or library to work on z/OS. To create a patch, change to the `jq-1.6` directory and perform a `git diff HEAD` and redirect your patches to a file in the patches directory.

```bash
cd jq-1.6
# Make your changes
git diff HEAD > ../patches/initial_zos.patch
```

Once you have a working prototype of your tool, you can proceed to the next step.

### Creating a repository under ZOSOpenTools

After you have a working z/OS prototype for your tool, you will need to create a repository to hold your contents.

Send an email to itodorov@ca.ibm.com or fultonm@ca.ibm.com with the following information:
* Name of the tool
* Current repository where contents reside
* List of Collaborators

Once your repository is created, you will be invited as a collaborator.

Proceed to clone the repository and submit a Pull Request including the initial contents of your z/OS port.

### Setting up the CI/CD pipeline

Once you have a working build of your z/OS Open Source tool, then you may add it to the z/OS Open Source Jenkins CI/CD pipeline.

View [CI/CD Pipeline](/Guides/Pipeline.md) for more details
