# z/OS Open Tools - Hands on Workshop

## Pre-requisites
* Access to z/OS UNIX via a terminal
* Duration: 1 hour and 30 mins

## Introduction (15 minutes)
Welcome to the z/OS Open Tools Workshop, where we'll delve into the practical aspects of integrating open-source tools within the z/OS environment. 

In the realm of mainframes, z/OS is renowned for its unwavering reliability, security, and speed. However, it's often challenged by the limited availability of readily accessible open-source software, unlike more common platforms such as Linux or Mac.

This is where the z/OS Open Tools community comes into play. Our primary mission is to enhance the open-source landscape on z/OS. With over 130 successfully ported projects, we're committed to making essential open-source tools readily available on z/OS. Importantly, we actively contribute our enhancements back to open-source communities to keep z/OS aligned with industry developments.

In today's session, you'll engage in hands-on activities. We'll guide you through practical tasks like downloading and using the open source zopen package manager, installing core tools like Vim, Git, Make and Bash, and even introduce you to the process of porting an external tool (e.g., jq) using the zopen build command. Additionally, you'll learn how to contribute your own changes to a GitHub repository, enabling you to actively participate in the growth of the z/OS Open Tools ecosystem.

Let's get started with this workshop, focusing on the technical aspects and practical skills you'll need to harness the capabilities of open-source tools within the z/OS environment

Before participating in the workshop, we recommend that you watch Mike Fulton's 10-minute demonstration available at: https://ibm.box.com/s/xh9a6tld8z51a5x3qauhnk0idp7vgkrw

## Module 1: Accessing z/OS UNIX (10 minutes)

To log in to a z/OS system using SSH, you'll first need to set up SSH on your local machine. This involves creating a key pair and configuring the SSH client.

Here are the basic steps to create an SSH key pair on z/OS:

1. Open a terminal window.

2. Generate the SSH Key Pair: To create your SSH key pair, enter the following command:
```
   ssh-keygen
```
   You'll be prompted to specify a file name for your key pair. By default, the name is set to `id_rsa`, but you have the option to choose a different name if you prefer.

3. Set a Passphrase (Optional but Recommended): You will also be given the option to set a passphrase for your key pair. While this step is optional, it's highly recommended as it adds an additional layer of security to your SSH connection. If you choose to set a passphrase, you'll need to enter it during SSH authentication.

   Example:
```
   Enter file in which to save the key (/Users/username/.ssh/id_rsa):
   Enter passphrase (empty for no passphrase):
   Enter same passphrase again:
```
   The key pair will be generated and saved in the `.ssh` directory within your home directory. The private key will be saved as `id_rsa` (or the name you specified), and the corresponding public key will be saved as `id_rsa.pub`.

   Example output:
```
   Your identification has been saved in /Users/username/.ssh/id_rsa.
   Your public key has been saved in /Users/username/.ssh/id_rsa.pub.
```
Please note that the precise commands and prompts may vary slightly depending on your operating system and the version of SSH you are using. Once you have generated your SSH key pair, you can proceed with configuring the SSH client to establish a secure connection to z/OS UNIX.

4. Logging in via SSH: After you've generated your SSH key pair, you can use it to log in to a z/OS system. Here's an example of how to do it:

```
  ssh username@zos-system-address
```
Replace username with your z/OS username, and zos-system-address with the address or hostname of the z/OS system you want to connect to.

## Module 2: Downloading and Installing z/OS Open Tools Meta Framework (10 mins)

## Downloading the z/OS Open Tools Meta package

Note: In the documentation that follows, text inside `< ... >` indicates a value you need to provide, e.g. `<z/OS system>` would be replaced with the name of the z/OS system you are using.

To get started, you need to get the `meta-<version>.pax.Z` to your z/OS system. Here is one approach:
- on your laptop or desktop
- download the [latest meta release](https://github.com/ZOSOpenTools/meta/releases) file by clicking on the pax.Z in the **assets** section. 
- open a terminal window on your laptop or desktop
- `cd` into the directory you downloaded the file to
- `sftp <z/OS system>`
- log in if required
- `put meta-<version>.pax.Z` where `<version>` corresponds to the meta version you downloaded
- `quit`

### Setting up your z/OS environment

- `ssh <z/OS system>` via thet terminal to connect to the z/OS UNIX system
- The following environment variables are required:
```
export _BPXK_AUTOCVT=ON
export _CEE_RUNOPTS="$_CEE_RUNOPTS FILETAG(AUTOCVT,AUTOTAG) POSIX(ON)"
export _TAG_REDIR_ERR=txt
export _TAG_REDIR_IN=txt
export _TAG_REDIR_OUT=txt
```
- Add them to your .profile or .bashrc or execute the above exports in your current session.

### Installing the zopen meta framework
- `cd` into the directory you transferred the pax.Z file to
- `pax -rf meta-<version>.pax.Z` # extract the pax
- After this step, you may delete the `meta-<version>.pax.Z` file
- `cd meta-<version>`
- `. ./.env`
- `zopen init` # Follow the instructions
- Source the .zopen-config, using the dot (.) operator, as instructed in the last line from the `zopen init` output.
- `. <path/to/your/zopen/etc/zopen-config>`

## Module 3: Setting Up Favorite Tools (10 minutes)

### Use the zopen framework to list available tools
- `zopen list` # list the available tools, this will list 100+ tools available under z/OS Open Tools

### Install your favourite tools
- Install vim:
  - `zopen install vim -y`
- Install git:
  - `zopen install git -y`
  - You will notice that it install git and its runtime dependencies, bash, ncurses, and others.
- Install make:
  - `zopen install make -y`
 
## Module 3: Using your newly installed z/OS Open Tools (15 minutes)
Before you proceed, it's recommended that you re-source the zopen-config file.
- `. <path/to/your/zopen/etc/zopen-config>`

### Using Bash on z/OS
It's recommended that you use Bash on z/OS for the following reasons:
* Tab Completion: Bash offers tab completion for efficient command and filename typing, saving time and reducing errors.
* Scripting Power: Bash serves as a robust scripting language capable of automating complex tasks, enabling advanced operations with variables, loops, and conditions.
* Compatibility: Bash is compatible with the Bourne shell, allowing seamless migration of existing scripts without the need for extensive rewriting.
To invoke bash, type:
```
bash
```
You have now entered the bash shell.

Type in `ls <tab>`, <tab> will auto-complete and list all files/directories in your current working directory.

### Using Git on z/OS
#TODO: Create a fork first

Now, let's use Git to clone a remote repository:
```
git clone https://github.com/ZOSOpenTools/meta.git
```
This will clone the remote repository, meta, to your local z/OS UNIX system under the directory `meta`.

Change to the meta directory:
```
cd meta
```

Check the commit log history:
```
git log
```
Scroll up or down using the arrow keys on your keyboard

Now let's make a change. We will use `vim` to edit a file locally and make a change.

Vim the README.md file:
```
vim README.md
```

Now edit the file by pressing i to enter insert mode:
```
i
```

Now start typing text. Once you are done, press the `escape` key. You have now exited insert mode.

To save the file, press:
```
:wq
```

Now, let's use git to check what's different:
```
git diff
```

You should see your changes reflected in the view.

The next step is to commit your changes.
```
git commit -a README.md -m "My changes"
```

Once you've commited your change, typically the next step is to push your changes to remote.

## Module 4: Building existing z/OS Open Tools (20 mins)

Now that you've gained some experience with using the z/OS Open Tools, let's attempt to build an existing open source project.

We will use `which` as an existing ported tools to z/OS.

Clone the whichport repository and change to the whichport local workspace as follows:
```
git clone https://github.com/ZOSOpenTools/whichport
cd whichport
```

You will notice that there are several files, and most notably, the `buildenv` configuration. This file instructs `zopen build` on how to build the which tool.
For more details on the `buildenv` configuration, visit https://zosopentools.github.io/meta/#/Guides/Porting.

Now, let's attempt to build whichport:
```
zopen build -vv
```

#TODO: provide example output.

After approximately 10 minutes, `which` will be build, test and install.

## Module 5: Porting a new open source tools with z/OS Open Tools (20 mins)

Now that you understand the build process, let's attempt to port an open source tool to z/OS by leveraging `zopen generate`

We will choose [jq](https://stedolan.github.io/jq/), a lightweight and flexible json parser. 

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
export ZOPEN_CATEGORIES="security networking"

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
  #echo "envar|set|value"
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

Once finished, you will notice that your project was built and installed under `<zopen_root_fs>/usr/local/dev/jq/jq`.

## What's next (5 minutes)
If you're interested in participating further, we hold regular meetings to explore the latest advancements in z/OS Open Tools via the [z/OS Open Source Guild Meetings](https://github.com/orgs/ZOSOpenTools/discussions/categories/guild)

We're dedicated to building a community of z/OS enthusiasts who collaborate and share their work on GitHub through the "z/OS Open Source Guild."

Feel free to also participate in our [discussions](https://github.com/orgs/ZOSOpenTools/discussions).

For a list of existing issues and how you can get involved, visit [issues](https://github.com/orgs/ZOSOpenTools/issues).

## Resources
* [Github repository](https://github.com/orgs/ZOSOpenTools)
* [Documentation](https://zosopentools.github.io/meta)
* [Discussions](https://github.com/orgs/ZOSOpenTools/discussions)
* [Discord channel](https://discord.gg/Cgwf6F6dqj)
* [Guild meeting session](https://github.com/orgs/ZOSOpenTools/discussions/categories/guild)
