# utils
Utilities (common tools) repository used by other repos in ZOSOpenTools

The following is a description of the utilities provided in the utils repo.
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

The build will fail to proceed to the install step if `expectedFailures` is greater than `actualFailures`.

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

After the build is successful, `zopen build` will install the project to `$HOME/zopen/projectname`. To perform post-processing on the installed contents, such as modifying hardcoded path contents, you can write a `zopen_post_install()` function which takes the installed path as the first argument.

Note that you can choose the fully-qualified environment variables ZOPEN_GIT_URL, ZOPEN_GIT_DEPS and ZOPEN_TARBALL_URL, ZOPEN_TARBALL_DEPS 
accordingly if you prefer. See (https://github.com/ZOSOpenTools/zotsampleport/blob/main/setenv.sh) for an example.

There are several additional environment variables that can be specified to provide finer-grained control of the build process. 
For details
- Run `zopen build -h` for a description of all the environment variables
- Read the code: (https://github.com/ZOSOpenTools/utils/blob/main/bin/zopen-build). 

For a sample port, visit the [zotsampleport](https://github.com/ZOSOpenTools/zotsampleport) repo.


## zopen generate
You can generate a zopen template project with `zopen generate`. It will ask you a series of questions and then generate the zopen file structure, including a `buildenv` file that will help you get started with your project.

### Running zopen build

Run `zopen build` from the root directory of the git repo you would like to build.  For example, m4:
```
cd ${HOME}/zot/dev/m4
${HOME}/zot/dev/utils/bin/zopen build
```

## zopen-importenvs
   This script is used to source the .env from ~/zopen/prod or ~/zopen/boot direectoy as explained below:

   Usage of script is: ". ./zopen-importenvs [path to buildenv to fetch dependency]"
   The path to buildenv is optional.

   If path is provided: the dependencies from the buildenv file are read and the env is sourced from prod/boot directory.
   Else if path is not provided then the .env from each project directory in the ~/zopen/prod & ~/zopen/boot directories are sourced.
```

