# zopen framework 

The following is a description of the zopen framework provided in the meta repo. To obtain the latest meta tools, you can clone and set up the environment as follows:

```
git clone git@github.com:zopen-community/meta.git
cd meta
. ./.env
```

Alternatively, you can download meta via [here](https://github.com/zopen-community/meta/releases/)

## If you are using Zopen Community

### zopen init

`zopen init` is used to initialise a Zopen Community environment. By default, this will create a ```zopen``` directory in your ```$HOME``` directory as the root filesystem (rootfs).  The rootfs holds the various packages, configuration and environment for Zopen Community packages - removing this directory will revert the system without a trace.  A Zopen Community main configuration file is generated in ```$rootfs/etc/zopen-config``` - to enable the Zopen Community, this will either need to be sourced after logon to the system or the following line can be added to ```$HOME/.profile``` (or .bash_profile or...) to automatically source the Zopen Community configuration file.
```bash
[ -e "$rootfs/etc/zopen-config" ] && . $rootfs/etc/zopen-config
```
It is possible to reinitialize a system using the ```re-init``` option - doing so will remove the previous configuration though the rootfs can overlap the old filesystem to reuse installed and/or cached packages for example.  Initialisation on a system that has previously had a Zopen Community configuration should allow some parameters to be copied across, such as Github tokens.

### zopen update-cacert

To update the cacert.pem file, you can use `zopen update-cacert`. This will download the latest cacert.pem file https://curl.se/docs/caextract.html. This cacert.pem file is then used by other tools such as `zopen install` and `zopen build`.

### zopen install

To download and install the latest software packages, you can use `zopen install`. 

### zopen list
To list the available packages, specify no parameters or the `--list` option as follows:
```
zopen list
```

To download and install specfic packages, you can specify the packages as a comma seperated list as follows:
```
zopen install make,vim
```

### zopen upgrade

To upgrade already installed software packages, you can use `zopen upgrade`.

```
zopen upgrade
```

To upgrade a specific set of packages, you can specify the packages as a comma seperated list as follows:
```
zopen upgrade make
```

## If you are contributing to or developing Zopen Community

### zopen build

To build a software package, you can use `zopen build`.

`zopen build` requires the files scripts in the project's root directory:
- `buildenv`, which `zopen build` will automatically source.  If you would like to source another file, you can specify it via the `-e` option as in: `zopen build -e mybuildenv`

The `buildenv` file _must_ set the following environment variables:
- `ZOPEN_BUILD_LINE`: one of DEV or STABLE indicating which build line to build off of.
- `ZOPEN_DEV_URL` or `ZOPEN_STABLE_URL`: the URL where the source should be pulled from, including the `package.git` or `package-V.R.M.tar.gz` extension
- `ZOPEN_DEV_DEPS` or `ZOPEN_STABLE_DEPS`: a space-separated list of all software dependencies this package has. These packages will automatically be downloaded if they are not present in your `$HOME/zopen/prod` or `$HOME/zopen/boot` directories.

To help gauge the build quality of the port, a `zopen_check_results()` function needs to be provided inside the buildenv. This function should process
the test results and emit a report of the failures, total number of tests, expected number of failures and expected number of tests to stdout as in the following format: 
```
actualFailures:<numberoffailures>
totalTests:<totalnumberoftests>
expectedFailures:<expectednumberoffailures>
expectedTotalTests:<expectednumberoftests>
```

The build will fail to proceed to the install step if `totalTests` is less than `expectedTotalTests` or `actualFailures` is greater than `expectedFailures`.

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
expectedTotalTests:1
ZZ
}
```

`zopen build` will generate a .env file in the install location with support for environment variables such as PATH, LIBPATH, and MANPATH.
To add your own, you can append environment variables by echo'ing them in a function called `zopen_append_to_env()`.

After the build is successful, `zopen build` will install the project to `$HOME/zopen/prod/projectname`. To perform post-processing on the installed contents, such as modifying hardcoded path contents, you can write a `zopen_post_install()` function which takes the installed path as the first argument.

Note that you can choose the fully-qualified environment variables ZOPEN_DEV_URL, ZOPEN_DEV_DEPS and ZOPEN_STABLE_URL, ZOPEN_STABLE_DEPS 
accordingly if you prefer. See (https://github.com/zopen-community/zotsampleport/blob/main/setenv.sh) for an example.

There are several additional environment variables that can be specified to provide finer-grained control of the build process. 
For details
- Run `zopen build -h` for a description of all the environment variables
- Read the code: (https://github.com/zopen-community/meta/blob/main/bin/zopen-build). 

For a sample port, visit the [zotsampleport](https://github.com/zopen-community/zotsampleport) repo.

#### Running zopen build

Run `zopen build` from the root directory of the git repo you would like to build.  For example, m4:
```
cd ${HOME}/zopen/dev/m4
zopen build
```

### zopen generate
You can generate a zopen template project with `zopen generate`. It will ask you a series of questions and then generate the zopen file structure, including a `buildenv` file that will help you get started with your project.

### zopen-importenvs
If you want to source the .env files from all of the installed zopen products under the zopen prod and boot directories, then you can use `zopen-importenvs`. 

Usage of script is: ". ./zopen-importenvs [path to buildenv to fetch dependency]"

The path to buildenv is optional.

If the buildenv path is provided, the dependencies from the buildenv file are read and the env is sourced from prod/boot directory. This is useful if you want to have the same environment as zopen build in order to reproduce a problem with the build.
Otherwise if the path is not provided then the .env from each project directory in the zopen prod/boot directories are sourced.
```
