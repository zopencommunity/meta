# UPDATE: New zopen framework is now available!

The new zopen package manager is not compatible with the previous version of zopen. Migration involves creating a new directory structure for zopen tools. This is accomplished via the `zopen init` command, documented below.

## Before you migrate
* Identify the tools you have already installed. Use `zopen install --list`.
* If you plan to reuse the existing zopen root directory for installing the new tools, then make sure to back it up to a different directory.
* Follow the steps below and install each of the tools again via `zopen install`

# meta - Introducing the zopen package manager
Meta adds package management facilities to z/OS, via zopen. It is similar to utilities like apt, dpkg, yum, yast2, emerge. It is written in pure shell script to remove any pre-reqs (like python/perl/bash etc).
This package manager is designed for everyday usage of the z/OS Open Tools ports within the USS environment or for those who wish to download the tools.

## Pre-config
It is advised to have the following set on the system to ensure correct operation:
```
export _BPXK_AUTOCVT=ON
export _CEE_RUNOPTS="$_CEE_RUNOPTS FILETAG(AUTOCVT,AUTOTAG) POSIX(ON)"
export _TAG_REDIR_ERR=txt
export _TAG_REDIR_IN=txt
export _TAG_REDIR_OUT=txt
```

## Installation
- Download the meta pax to a suitable location (for example /tmp).
- Expand the pax using the command ```pax -rvf <filename>.pax```.  This will expand the pax to the current directory, listing the various included files as it does so.
- From the ```meta-<ver>/bin``` directory run the following command, answering the questions appropriately:
```bash
. ./.env
zopen init
```

## Sample usage
```bash
. ./.env # Source the .env from meta
zopen init
. <zopen_root_path>/etc/zopen-config
zopen list --installed
zopen install which
zopen list --installed
which which
zopen upgrade
zopen install git vim # install both git and vim
```

## Important usage notes
- On first run, ```zopen init``` will copy meta into the "package" area of zopen (ie. where packages are expanded and accessed from).  It will also be pinned to this release to prevent any possible updates from the "real" meta package. Removing the .pinned file from the meta directory will allow for the main meta port to be installed however this will cause incompatabilities if run.

- Remote respositores utilise the suffix `port` - where required, packages should be specified **without** the suffix. eg using `zopen install which` rather than `zopen install whichport`

## Root filesystem install
- Selecting `'/' ` as the root filesystem will allow the tools to be available system wide for all users who configure their usage. The install needs to be done by a sysadmin [or someone with sufficient rights using the sudo port for example] as the installer will write files to the /usr tree and configuration information to /etc. There will also be a configuration file written as ```/etc/zopen-config``` - this can be sourced by other users.
- Removing zopen and the z/OS Open Tools once installed involves: uninstalling all installed packages; removing any copies of `zopen-config`; removing the configured zopen root directory (by default ```/usr/local/zopen``` but is set during installation); and then running a command to find any final orphaned symlinks on the system, such as: `/bin/find $ZOPEN_ROOTFS -type l -exec test ! -e {} \; -print`  where $ZOPEN_ROOTFS is '/' [replace `-print` with `rm -rf` to actually remove symlinks, the example command should only list what was found - care should be taken when removing any files with sysadmin authority to prevent removing critial files!]

## Basic command introduction
Most commands have extended help available using the `--help` parameter.  The following usage guidance should be sufficient to get a system running.

```bash
zopen init
```

Used to initialise a z/OS Open Tools environment. By default, this will create a ```zopen``` directory in your ```$HOME``` directory as the root filesystem (rootfs).  The rootfs holds the various packages, configuration and environment for z/OS Open Tools packages - removing this directory will revert the system without a trace.  A z/OS Open Tools main configuration file is generated in ```$rootfs/etc/zopen-config``` - to enable the z/OS Open Tools, this will either need to be sourced after logon to the system or the following line can be added to ```$HOME/.profile``` (or .bash_profile or...) to automatically source the z/OS Open Tools configuration file.
```bash
[ -e "$rootfs/etc/zopen-config" ] && . $rootfs/etc/zopen-config
```
It is possible to reinitialize a system using the ```re-init``` option - doing so will remove the previous configuration though the rootfs can overlap the old filesystem to reuse installed and/or cached packages for example.  Initialisation on a system that has previously had a z/OS Open Tools configuration should allow some parameters to be copied across, such as Github tokens.

```
zopen install <package>...
```

Used to install a z/OS Open Tools package.  By default, the latest stable version is installed although options are available to install specific versions, tags or to pick from a selection [see ```--help``` for more]

```
zopen upgrade
```

Used to upgrade z/OS Open Tools packages.  Without parameters, all installed packages will be upgraded; individual packages can be specified on the command line to upgrade only those packages.  Packages can be "pinned" to prevent upgrading in case a later release is found to be broken or incompatible - creating a ```.pinned``` file in the package directory prevents the upgrade; removing the file allows upgrades to occur.

```
zopen clean [--cache] [--unused] [--dangling] [--all]
```

Used to remove resources on the system.  zopen will retain old versions of packages to allow for switching versions or quick re-installs; downloaded pax files are held in a cache while the specific version files are maintained in the directory configured during initialisation.  Using the ```clean``` option removes those unused resources.  In addition, zopen utilises symlinks for maintaining the appropriate file structure - should a problem occur during package installation, removal or version change, danling symlinks might be present; the ``--dangling`` option will (slowly) analyse the rootfs and prune any dangling symlinks.

```
zopen alt [package] [-s]
```

Used to list versions of a package if there are multiple versions present; using the ```-s``` parameter allows for the active version to be changed

```
zopen remove <package>...
```

Removes a package from the system, leaving the version on the system for re-use later; the ```---purge`` directory will also remove the versioned directory, requiring a potential download and/or an unpax to occur to re-install that version


```
zopen list [--installed]
```

With no parameters, will list the available packages against the currently installed versions; more usefully, using the ```--installed``` parameter lists the actually locally-installed packages rather than all potential packages

```
zopen search <package>
```

Searches the remote repositiory for the specified package, returning appropriate meta-data about the package if found

```
zopen query <option>
```

Queries the local z/OS Open Tools sytem. See ```---help``` for more details


### Useful resources
- View the z/OS Open Tools project home: https://github.com/ZOSOpenTools
- View the main Meta documentation at https://zosopentools.github.io/meta/
