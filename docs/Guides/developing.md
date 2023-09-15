# Developing z/OS Open Tools

Please read [Quick Start](QuickStart.md) and [The package manager](ThePackageManager.md) if you haven't already done so.

## zopen directory structure

After running `zopen init`, you are able to install tools under the tools directory you chose, i.e. `$ZOPEN_HOME` 

You can develop z/OS Open Tools out of any directory you want, but we recommend creating a directory under `$ZOPEN_HOME/dev`. 

The _dev_ directory is where you will do your development. For example, if you wanted to make enhancements to the `zotsampleport` 
tool, you would do the following:

```bash
cd $ZOPEN_HOME/dev
git clone git@github.com:ZOSOpenTools/zotsampleport.git
cd zotsampleport
zopen build
```

This will build `zotsampleport` and then install it into `$ZOPEN_HOME/zopen/prod` directory.

We provide a number of tools under `zopen` in addition to `install` and `build`. 
To see the list of tools:
```bash
`zopen -?`
```

## To Develop z/OS Open Tools

### zopen build

To build a software package, you can use `zopen build`.

`zopen build` requires the files scripts in the project's root directory:
- `buildenv`, which `zopen build` will automatically source.  If you would like to source another file, you can specify it via the `-e` option as in: `zopen build -e mybuildenv`

The `buildenv` file _must_ set the following environment variables:
- `ZOPEN_BUILD_LINE`: one of DEV or STABLE indicating which build line to build off of.
- `ZOPEN_DEV_URL` or `ZOPEN_STABLE_URL`: the URL where the source should be pulled from, including the `package.git` or `package-V.R.M.tar.gz` extension
- `ZOPEN_DEV_DEPS` or `ZOPEN_STABLE_DEPS`: a space-separated list of all software dependencies this package has. These packages will automatically be downloaded if they are not present in your `$HOME/zopen/prod` or `$HOME/zopen/boot` directories.

To determine the build quality of the port, a `zopen_check_results()` function needs to be provided inside _buildenv_. This function should process
the test results and emit a report of the failures, total number of tests, expected number of failures and expected number of tests to stdout as in the following format: 
```
actualFailures:<numberoffailures>
totalTests:<totalnumberoftests>
expectedFailures:<expectednumberoffailures>
expectedTotalTests:<expectednumberoftests>
```

The build will fail to proceed to the install step if `totalTests` is less than `expectedTotalTests` or if `actualFailures` is greater than `expectedFailures`.

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
accordingly if you prefer. See (https://github.com/ZOSOpenTools/zotsampleport/blob/main/setenv.sh) for an example.

There are several additional environment variables that can be specified to provide finer-grained control of the build process. 
For details
- Run `zopen build -h` for a description of all the environment variables
- Read the code: (https://github.com/ZOSOpenTools/meta/blob/main/bin/zopen-build). 

For a sample port, visit the [zotsampleport](https://github.com/ZOSOpenTools/zotsampleport) repo.

#### Running zopen build

Run `zopen build` from the root directory of the git repo you would like to build.  For example, m4:
```
cd ${HOME}/zopen/dev/m4port
zopen build
```

### zopen generate
You can generate a zopen template project with `zopen generate`. It will ask you a series of questions and then generate the zopen file structure, including a `buildenv` file that will help you get started with your project.

### zopen update-cacacert

To update the cacert.pem file, you can use `zopen update-cacert`. This will download the latest cacert.pem file https://curl.se/docs/caextract.html. This cacert.pem file is then used by other tools such as `zopen install` and `zopen build`.

### zopen-importenvs
If you want to source the .env files from all of the installed zopen products under the zopen prod and boot directories, then you can use `zopen-importenvs`. 

Usage of script is: `. ./zopen-importenvs`

The path to buildenv is optional.

If the buildenv path is provided, the dependencies from the buildenv file are read and the env is sourced from prod/boot directory. This is useful if you want to have the same environment as zopen build in order to reproduce a problem with the build.
Otherwise if the path is not provided then the .env from each project directory in the zopen prod/boot directories are sourced.
