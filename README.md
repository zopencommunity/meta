# meta-dt
A reworking of the main meta project to add additional package management facilities, similar to utilities like apt, dpkg, yum, yast2, emerge .... just written in pure shell script (and a tiny bit of REXX) to remove any pre-reqs (like python/perl/bash etc).
This fork is designed for everyday usage of the zos Open Tools ports within the USS environment or for those who wish to download the tools; users who are interested in building and/or porting packages from scratch should use the main release of meta at this time.

## Installation
Clone the repo or download/expand a release pax.  From the bin directory run the following command, answering the questions appropriately:
```
>zopen init
```
Note that initialization will ask the question "Setting alternative: 1: meta-dt"; the correct answer is ```1<enter>```  - this is used to ensure that the currently installing fork of meta is copied and used.  See the section regarding the ```alt``` parameter below for more details.

## Sample usage
```
>./zopen init
>. $HOME/.zopen-config
>./zopen list --installed
>zopen install which
>zopen list --installed
>which which
>zopen upgrade
```


## Restrictions
Currently, the zopen build capability **DOES NOT** work with the fork due to the way package dependencies and post-built installation occurs.  This is on the roadmap...


## Important usage notes
- As zopen utilises Github for package repositories, it is strongly advised to set up a [Github API token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) . Github throttles the number of anonymous access requests to repositories; with an API token, that number is significantly increased.

- On first run, ```zopen init``` will copy this forked version of meta into the "package" area of zopen (ie. where packages are expanded and accessed from).  It will also be pinned to this release to prevent any possible updates from the "real" meta package. Removing the .pinned file from the meta-dt directory will allow for the main meta port to be installed however this will cause incompatabilities if run.

- Remote respositores utilise the suffix ```port``` - where required, packages should be specified with**OUT** the suffix. eg using ```zopen install which``` rather than ```zopen install whichport```


## Problem resolution
If the meta package does get updated to a non-dt version, then running ```./zopen alt meta -s``` from the meta-dt/bin directory within the z/OS Open Tools root filesystem should allow selection of the dt-forked meta; running any other non-forked zopen commands might break the installation or cause unexpected behaviour! 
zopen commands take a ```--verbose``` parameter to produce additional messages that can be used to aid problem diagnosis.

## Basic command introduction
Most commands have extended help available using the ```--help``` parameter.  The following usage guidance should be sufficient to get a system running

>zopen init

Used to initialise a z/OS Open Tools environment. By default, this will create a ```zopen``` directory in your ```$HOME``` directory as the root filesystem (rootfs).  The rootfs holds the various packages, configuration and environment for z/OS Open Tools packages - removing this directory will revert the system without a trace.  A z/OS Open Tools main configuration file is generated in ```$HOME/.zopen-config``` - to enable the z/OS Open Tools, this will either need to be sourced after logon to the system or the following line can be added to ```$HOME/.profile``` (or .bash_profile or...) to automatically source the z/OS Open Tools configuration file
>[ -e "$HOME/.zopen-config" ] && . $HOME/.zopen-config
It is possible to reinitialize a system using the ```re-init``` option - doing so will remove the previous configuration though the rootfs can overlap the old filesystem to reuse installed and/or cached packages for example.  Initialisation on a system that has previously had a z/OS Open Tools configuration should allow some parameters to be copied across, such as Github tokens.

>zopen install <package>...

Used to install a z/OS Open Tools package.  By default, the latest version is installed although options are available to install specific versions, tags or to pick from a selection [see ```--help``` for more]

>zopen upgrade

Used to upgrade z/OS Open Tools packages.  Without parameters, all installed packages will be upgraded; individual packages can be specified on the command line to upgrade only those packages.  Packages can be "pinned" to prevent upgrading in case a later release is found to be broken or incompatible - creating a ```.pinned``` file in the package directory prevents the upgrade; removing the file allows upgrades to occur.

>zopen clean [--cache] [--unused] [--dangling] [--all]

Used to remove resources on the system.  zopen will retain old versions of packages to allow for switching versions or quick re-installs; downloaded pax files are held in a cache while the specific version files are maintained in the directory configured during initialisation.  Using the ```clean``` option removes those unused resources.  In addition, zopen utilises symlinks for maintaining the appropriate file structure - should a problem occur during package installation, removal or version change, danling symlinks might be present; the ``--dangling`` option will (slowly) analyse the rootfs and prune any dangling symlinks.

>zopen alt [package] [-s]

Used to list versions of a package if there are multiple versions present; using the ```-s``` parameter allows for the active version to be changed

>zopen remove <package>...

Removes a package from the system, leaving the version on the system for re-use later; the ```---purge`` directory will also remove the versioned directory, requiring a potential download and/or an unpax to occur to re-install that version


>zopen list [--installed]

With no parameters, will list the available packages against the currently installed versions; more usefully, using the ```--installed``` parameter lists the actually locally-installed packages rather than all potential packages

>zopen search <package>

Searches the remote repositiory for the specified package, returning appropriate meta-data about the package if found

>zopen query <option>

Queries the local z/OS Open Tools sytem. See ```---help``` for more details




### Useful resources
- View the z/OS Open Tools project home: https://github.com/ZOSOpenTools
- View the main Meta documentation at https://zosopentools.github.io/meta/


