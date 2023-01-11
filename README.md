# meta
Meta repository to tie together the various underlying z/OS Open Source tools repositories here.

View our documentation at https://zosopentools.github.io/meta/

## Background

There are some key 'foundational' Open Source technologies needed to port software. The goal of this set of repositories is to provide minimal 'port' repositories
that can be used to get a foundational software package building on z/OS.
We are starting with what we view as some 'foundational' technologies. One is the stack of technology to be able to build [zsh](https://sourceforge.net/projects/zsh/postdownload). Another is to 
be able to build [protocol buffers](https://github.com/protocolbuffers/protobuf/releases). 

But - there is a _transitive closure_ problem to address with porting a software package, namely understanding what packages are pre-requisites 
for the software package you want to port. As an example, for zsh, we see the following:

zsh requires autoconf to configure the build scripts, GNU make to run Makefiles, ncurses
zsh is easier to develop (but doesn't require) curl and git natively on z/OS, and GNU techinfo for documentation

autoconf requires m4, automake, GNU make
m4 requires a c99 compiler with c11 features, so ensure you have the latest C/C++ compilers installed on your system

GNU make requires GNU m4, automake, autoconf, Perl, and a C compiler that is gcc compatible

Perl requires a c89 compiler
ncurses requires an ANSI C compiler 

## Order to Build _from scratch_

If you want to build the tools from scratch and not use the binary pax files available, you will want 
to tackle this in a particular order. 
First, you need to have some tools installed on your system:

### System Pre-reqs:

| Project | License | Download link |
|---------|---------|------------------------|
| [gnu make 4.1](https://www.gnu.org/software/make/) | [GPL V3 ](https://www.gnu.org/licenses/gpl-3.0.html) | [z/OS Open Tools release](https://github.com/ZOSOpenTools/makeport/releases/tag/boot) |
| [IBM XL C/C++ V2.4.1](https://www-40.ibm.com/servers/resourcelink/svc00100.nsf/pages/xlCC++V241ForZOsV24) | IBM [^ibm] | [ibm.com web download](https://www.ibm.com/marketing/iwm/iwm/web/dispatcher.do?source=swg-zosxlcc) |
| [git](https://git.kernel.org/pub/scm/git/git.git/) | [LGPL V2.1](https://git.kernel.org/pub/scm/git/git.git/tree/LGPL-2.1) | [z/OS Open Tools release](https://github.com/ZOSOpenTools/gitport/releases/tag/boot)  |
| [curl](https://github.com/curl/curl) | [curl-license](https://github.com/curl/curl/blob/master/COPYING) | [z/OS Open Tools release](https://github.com/ZOSOpenTools/curlport/releases/tag/boot) |
| [gunzip](https://www.gnu.org/software/gzip/) | [GPL V3 ](https://www.gnu.org/licenses/gpl-3.0.html) | [z/OS Open Tools release](https://github.com/ZOSOpenTools/unzipport/releases/tag/boot) |

[^ibm]: a no-charge add-on feature for clients that have enabled the XL C/C++ compiler (an optionally priced feature) on z/OS
### Recommended software:

| Project | License | Download link |
|---------|---------|------------------------|
| [bash](https://www.gnu.org/software/bash/) | [GPL V3 ](https://www.gnu.org/licenses/gpl-3.0.html) | [z/OS Open Tools release](https://github.com/ZOSOpenTools/bashport/releases/) |

Both IBM and Rocket provide supported versions of the software above for a fee.

Taking the defaults will mean there are less variables for you to configure. We recommend you structure your sandbox as follows:

 - Have the root of your development file system be `$HOME/zopen` (you will want to have several gigabytes of storage for use - we recommend at least 15GB)
 - Have sub-directories called _boot_, _prod_, _dev_.
    - _boot_: sub-directory for each tool required to bootstrap (make, git, curl, gunzip, m4)
    - _prod_: sub-directory for tools to be installed once built. These tools will be used by downstream software, e.g. make build process will use the Perl prod build
    - _dev_: sub-directory for tools you are building

### Order to build:
The tools have dependencies on other tools, and there are also typically 2 ways the tools are packaged:
 - one that is pre-configured and therefore doesn't need autoconf/automake and associated tools
 - one that is not pre-reconfigured and therefore does require autoconf/automake and associated tools

To build from scratch, start with the tarballs of the following tools:

| Project | License | Pre-requisites |
|---------|---------|------------------------|
| [m4](https://www.gnu.org/software/m4/m4.html) | [GPL V3 ](https://www.gnu.org/licenses/gpl-3.0.html) | m4, curl in boot and xlclang installed on the system |
| [perl](https://dev.perl.org/) | [GPL V3 ](https://www.gnu.org/licenses/gpl-3.0.html) | additionally requires make, git in boot and m4 in prod |
| [make](https://www.gnu.org/software/make/) | [GPL V3 ](https://www.gnu.org/licenses/gpl-3.0.html) | perl in prod for running test cases |
| [zlib](https://zlib.net/) | [zlib license](https://zlib.net/zlib_license.html) | make in prod |
| [autoconf](https://www.gnu.org/software/autoconf/) | [GPL V3 ](https://www.gnu.org/licenses/gpl-3.0.html) | libz in prod |
| [automake](https://www.gnu.org/software/automake/) | [GPL V3 ](https://www.gnu.org/licenses/gpl-3.0.html) | autoconf in prod |
 
Once you either have these tools built, or have downloaded a pre-built pax file for the build, you may want to build other tools.
Each tool has a _buildenv_ file and one of the entries will describe the tools it requires to build, depending
on where the source is from (currently TARBALL or GIT clone). So for example m4 requires:
 - ZOPEN_TARBALL_DEPS="curl gzip make m4"
and:
 - ZOPEN_GIT_DEPS="git make m4 help2man perl makeinfo xz autoconf automake gettext"

If you want to build from the GIT clone, you can see you will need to have more software pre-installed.

# zopen framework 
Utilities (common tools) repository used by other repos in ZOSOpenTools

The following is a description of the utilities provided in the meta repo.
For an overview	of ZOSOpenTools, see [ZOSOpenTools docs](https://zosopentools.github.io/meta/)

## zopen download

To download and install the latest software packages, you can use `zopen download`. By default it will download all of the binaries hosted on ZOSOpenTools.

It is recommended that you generate a [github personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token).
Then set `export ZOPEN_GIT_OAUTH_TOKEN=<yourapitoken>`

To list the available packages, specify the `--list` option as follows:
```
zopen download --list
```

To download and install specfic packages, you can specify the packages as a comma seperated list as follows:
```
zopen download make,gzip
```

This will download it to the current working directory. To change the destination directory, you can specify the `-d` option as follows:

```
zopen download make -d $HOME/zopen/prod
```

## zopen build

To build a software package, you can use `zopen build`.

`zopen build` requires the files scripts in the project's root directory:
- `buildenv`, which `zopen build` will automatically source.  If you would like to source another file, you can specify it via the `-e` option as in: `zopen build -e mybuildenv`

The `buildenv` file _must_ set the following environment variables:
- `ZOPEN_TYPE`: one of _TARBALL_ or _GIT_ indicating where the source should be pulled from (a source tarball or git repository)
- `ZOPEN_URL`: the URL where the source should be pulled from, including the `package.git` or `package-V.R.M.tar.gz` extension
- `ZOPEN_DEPS`: a space-separated list of all software dependencies this package has. These packages will automatically be downloaded if they are not present in your $HOME/zopen/prod or $HOME/zopen/boot directories.

To help guage the build quality of the port, a `zopen_check_results()` function needs to be provided inside the buildenv. This function should process
the test results and emit a report of the failures, total number of tests, and expected number of failures to stdout as in the following format: 
```
actualFailures:<numberoffailures>
totalTests:<totalnumberoftests>
expectedFailures:<expectednumberoffailures>
```

The build will fail to proceed to the install step if `actualFailures` is greater than `expectedFailures`.

Here is an example implementation of `zopen_check_results()`:

```bash
zopen_check_results()
{
chk="$1/$2_check.log"

failures=$(grep ".* Test.*in .* Categories Failed" ${chk} | cut -f1 -d' ')
totalTests=$(grep ".* Test.*in .* Categories Failed" ${chk} | cut -f5 -d' ')

cat <<ZZ
actualFailures:$failures
totalTests:$totalTests
expectedFailures:0
ZZ
}
```

`zopen build` will generate a .env file in the install location with support for environment variables such as PATH, LIBPATH, and MANPATH.
To add your own, you can append environment variables by echo'ing them in a function called `zopen_append_to_env()`.

After the build is successful, `zopen build` will install the project to `$HOME/zopen/prod/projectname`. To perform post-processing on the installed contents, such as modifying hardcoded path contents, you can write a `zopen_post_install()` function which takes the installed path as the first argument.

Note that you can choose the fully-qualified environment variables ZOPEN_GIT_URL, ZOPEN_GIT_DEPS and ZOPEN_TARBALL_URL, ZOPEN_TARBALL_DEPS 
accordingly if you prefer. See (https://github.com/ZOSOpenTools/zotsampleport/blob/main/setenv.sh) for an example.

There are several additional environment variables that can be specified to provide finer-grained control of the build process. 
For details
- Run `zopen build -h` for a description of all the environment variables
- Read the code: (https://github.com/ZOSOpenTools/meta/blob/main/bin/zopen-build). 

For a sample port, visit the [zotsampleport](https://github.com/ZOSOpenTools/zotsampleport) repo.


## zopen generate
You can generate a zopen template project with `zopen generate`. It will ask you a series of questions and then generate the zopen file structure, including a `buildenv` file that will help you get started with your project.

### Running zopen build

Run `zopen build` from the root directory of the git repo you would like to build.  For example, m4:
```
cd ${HOME}/zot/dev/m4
${HOME}/zot/dev/meta/bin/zopen build
```

## zopen-importenvs
   This script is used to source the .env from ~/zopen/prod or ~/zopen/boot direectoy as explained below:

   Usage of script is: ". ./zopen-importenvs [path to buildenv to fetch dependency]"
   The path to buildenv is optional.

   If path is provided: the dependencies from the buildenv file are read and the env is sourced from prod/boot directory.
   Else if path is not provided then the .env from each project directory in the ~/zopen/prod & ~/zopen/boot directories are sourced.
```
