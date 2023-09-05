# Porting to z/OS

## Getting Started

Before you get started with porting open source to z/OS, read the [Getting Started Guide](Pre-req.md) to set up your environment.

Once you have a z/OS system set up with the required zopen directory structure and pre-requisite boot tools, you will then need to set up Git as follows:

You need to configure your user.email and user.name to check in code to the repositories:

```
git config --global user.email "<Your E-Mail>"
git config --global user.name "<Your Name>"
```
This assumes that you have the latest version of [Git](https://github.com/ZOSOpenTools/gitport/releases) on your z/OS system.


### Leveraging the z/OS Open Tools meta repo

The meta repo (https://github.com/ZOSOpenTools/meta) consists of common tools and files that aid in the porting process, including the `zopen` suite of tools.  Specifically, `zopen build` provides a common way to bootstrap, configure, build, check,
and install a software package. `zopen install` provides a mechanism to install the latest published z/OS Open Tools packages.

Many tools depend on other tools to be able to build or run. You will need to provide both _bootstrap_ tools
(i.e. binary tools not from source), as well as _prod_ tools (i.e. _production_ level tools previously built
from another z/OS Open Tools repository).

Many tools require a C or C++ compiler (or both) to build. There a couple of options to obtain the C/C++ compiler:
* You can download a web deliverable add-on feature to your XL C/C++ compiler 
[here](https://www.ibm.com/servers/resourcelink/svc00100.nsf/pages/xlCC++V241ForZOsV24).
* You can install and manage _C/C++ for Open Enterprise Languages on z/OS_ using _RedHat OpenShift Container Platform_ and _IBM Z and Cloud Modernization Stack_ 
[here](https://github.com/IBM/z-and-cloud-modernization-stack-community). 
Please note that these compilers are comparable, but how you perform installation and maintenance and pricing is different.

In order for zopen to be able to locate dependent tools, they need to be in well-defined locations.

Dependencies will be searched for in the following default locations:
- `${ZOPEN_PKGINSTALL}` as configured in your <path_to_zopen_rootfs>/etc/zopen-config configuration.

You can change this location by running `zopen init` to reconfigure the install directory.

If the tool is not found, then `zopen build` will automatically install it.

Each tool is responsible for knowing how to set it's own environment up (e.g. PATH, LIBPATH, and any other environment variables).
By default, `zopen build` will automatically add PATH, LIBPATH, and MANPATH environment variables. If other environment variables are needed, then you can append them by defining a `zopen_append_to_env` function as in the case of [gitport](https://github.com/ZOSOpenTools/gitport/blob/main/buildenv#LL66-L66C20).
Once the tool is installed, the .env file needs to be source'd from its install directory to set up the environment.
If you are building from a ZOSOpenTools port, this `.env` file will be created as part of the install process.

### Create your first z/OS port leveraging the zopen framework

Before you begin porting a tool to z/OS, you must first identify the tool or library that you wish to port. For the sake of this guide, let's assume we are porting [jq](https://stedolan.github.io/jq/), a lightweight and flexible json parser. Before porting a tool, check if the project already exists under https://github.com/ZOSOpenTools. If it does exist, then please collaborate with the existing contributors.

Begin first by cloning the https://github.com/ZOSOpenTools/meta repo.  This repo contains the `zopen` framework under the `bin/` directory and it is what we will use to build, test, and install our port.

```bash
# Clone the required repositories (using Git from https://github.com/ZOSOpenTools/gitport)
git clone git@github.com:ZOSOpenTools/meta.git && cd meta
```

Next, in order to use the `zopen` suite of tools, you must set your path environment variable to the `meta/bin` directory.  
```bash
. ./.env
```

Ok, now you are ready to begin porting. 

Begin first by generating a port template project by entering the following command:
```bash
zopen generate
```

`zopen generate` will ask you a series of questions. Answer them as follows:
```
Generate a zopen project...
* What is the project name?
jq
* Provided a description of the project:
A jq parser
* Enter the jqport's Git location: (if none, press enter)
git@github.com:stedolan/jq.git
* Enter jqport's build dependencies for the Git source: (example: curl make)
git make autoconf
* Enter the jqport's Tarball location? (if none, press enter)
https://github.com/stedolan/jq/releases/download/jq-1.6/jq-1.6.tar.gz
* Enter jqport's build dependencies for the Tar source: (example: curl make)
make
* Enter the default build type: (tar or git)
tar
Generating jqportport zopen project...
jqport/buildenv created...
jqport/README.md created...
jqport project is ready! Contact Mike Fulton (fultonm@ca.ibm.com) to create https://github.com/ZOSOpenTools/jqport.git...
```

Change your current directory to the `jqport` directory: `cd jqport`. You will notice several files:
* README.md - A description of the project
* buildenv - The zopen configuration file that drives the build, testing, and installation of the project.
* cicd.groovy - The CI/CD configuration file used in the Jenkins pipeline
For more information, please visit the [zopen build README](https://github.com/ZOSOpenTools/meta)

Note: `zopen build` supports projects based in github repositories or tarball locations. Since autoconf/automake are not currently 100% functional on z/OS, we typically choose the tarball location because it contains a `configure` script pre-packaged. Let's go ahead and do this for `jq`.

In the `buildenv` file, you'll notice the following contents:
```bash
export ZOPEN_DEV_URL="git@github.com:stedolan/jq.git"
export ZOPEN_DEV_DEPS="git make autoconf"
export ZOPEN_STABLE_URL="https://github.com/stedolan/jq/releases/download/jq-1.6/jq-1.6.tar.gz"
export ZOPEN_STABLE_DEPS="make"
export ZOPEN_BUILD_LINE="STABLE"

zopen_check_results()
{
  dir="$1"
  pfx="$2"
  chk="$1/$2_check.log"
  grep "All tests passed"
}

zopen_append_to_env()
{
  # echo extra envars here:
}

zopen_append_to_zoslib_env()
{
  echo "envar|set|value"
}
```
ZOPEN_STABLE_DEPS/ZOPEN_STABLE_DEPS are used to identify the non-standard z/OS Open Tools dependencies needed to build the project. 

`zopen_append_to_env()` can be used to add additional environment variables outside of the normal environment variables. (e.g. PATH, LIBPATH, MANPATH)

Similarly, `zopen_append_to_zoslib_env()` can be used to set program specific environment variables.
It accepts the following format:
  envar|action|value
Where envar is the environment variable, action is either set, unset, or prepend, and value is the environment variable value.
The string `PROJECT_HOME` represents a special value and is replaced with the root path of the project"

To help gauge the build quality of the port, a zopen_check_results() function needs to be provided inside the buildenv. This function should process the test results and emit a report of the failures, total number of tests, expected number of failures and expected number of tests to stdout as in the following format:

```
actualFailures:<numberoffailures>
totalTests:<totalnumberoftests>
expectedFailures:<expectednumberoffailures>
expectedTotalTests:<expectednumberoftests>
```
The build will fail to proceed to the install step if totalTests is less than expectedTotalTests or actualFailures is greater than expectedFailures.

Here is an example implementation of zopen_check_results():

```
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
```

Next, we can go ahead and test our build.  Run the following:
```bash
zopen build -v
```

The `-v` option above specifies verbose output.

Once finished, you will notice that your project was built and installed under `$HOME/zopen/prod/jq`.

#### Creating Patches

As you may have noticed, `zopen build` downloads the `tar.gz` file, and then attempts to patch it with the patch contents in the `patches` directory.

As you port your application to z/OS, you will identify a set of _patches_. These patches represent the set of changes in order to get your tool or library to work on z/OS. To create a patch, change to the `jq-1.6` directory and perform a `git diff HEAD` and redirect your patches to a file in the patches directory.

```bash
cd jq-1.6
# Make your changes
# If there are any new files added, make sure to track them using git add
git add <newfiles>
git diff HEAD > ../patches/initial_zos.patch
```

Our preference is to keep patches small and to have seperate patches for each file or each group of changes. In order to filter a diff based on a filename, you can run:
```
git diff HEAD -- myfile.c > ../patches/myfile.c.patch
```

In some cases, the tool directory will not be tracked by git (when using a tarball and/or the tool directory is included in .gitignore). In this case, you will need to create the patch by hand using diff and an untouched copy of the tool directory.

```bash
diff -r jq-1.6 jq-1.6.orig > patches/initial_zos.patch
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
