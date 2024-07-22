# The package manager

## Pre-requisites

Access to a z/OS UNIX machine with z/OS 2.4 and above and network connectivity to github.com and githubusercontent.com.

## Installing the package manager

If you have curl and bash on your system, you can use this one liner:
```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ZOSOpenTools/meta/HEAD/tools/zopen_install.sh)"
```
Otherwise, download the latest [meta pax](https://github.com/ZOSOpenTools/metaport/releases) to z/OS
- download the file to your desktop
- use `sftp` to upload the pax file to z/OS.
- On z/OS, expand the pax using the command ```pax -rvf <filename>.pax```.  
  This will expand the pax to the current directory, listing the various included files as it does so.

- Source the .env to add `zopen` to your PATH:
```bash
cd meta-<version>
. ./.env
```

- Initialize your environment:
```bash
zopen init
# Make sure to source the zopen-config file as instructed
```

## Using the package manager

- Install any z/OS Open Tools via `zopen install`, e.g.
```bash
zopen install which # Installs which 
# Now test which
which which
```

- List which tools you have installed with `zopen list --installed`, e.g.
```bash
zopen list --installed
```

- See if any tools can be upgraded with `zopen list --upgradeable`, e.g. 
```bash
zopen list --upgradeable # list all tools that have upgrades available
```

- Upgrade your tools to the latest version with `zopen upgrade`, e.g.
```bash
zopen upgrade
```

- Set up your environment to use your installed tools by sourcing your environment, e.g.
```bash
. <zopen_root>/etc/zopen-config
```

- List known security vulnerabilities in installed tools with `zopen audit`, e.g.
```bash
zopen audit
```

## Package Collisions with z/OS UNIX tools

Packages such as `coreutils`, `gawk`, `sed`, `findutils`, `grep`, `diffutils`, `man-db` and `openssh` provide executables that collide with the z/OS UNIX tools under `/bin`.

### Prefixing for z/OS Open Tools

To ensure seamless interaction with z/OS tools under `/bin`, z/OS Open tools that collide with a z/OS UNIX tool under `<package>/bin` will be prefixed as follows:

* **`g` prefix** for GNU-based tools (Coreutils, Awk, Findutils, Diffutils, Grep, Sed) . E.g., `gmake` and `gawk`.
* **`zot` prefix** for non-GNU-based tools (Man-db, OpenSSH). E.g., `zotssh` and `zotman`

Tools that have collisions will also print out an install caveat during zopen install.

The original unprefixed binaries will be placed under `<package>/altbin`.

### Using Tools without Prefix

If you prefer to use the tools without the prefix, you can specify the `--override-zos-tools` option when sourcing `zopen-config` as follows:

```bash
. <zopen_root>/etc/zopen-config --override-zos-tools
```

Alternatively, you can add `$ZOPEN_ROOTFS/usr/local/altbin` to your $PATH.

 
# Upgrading the meta zopen package manager
The meta package, which include zopen, can be upgraded via the `zopen upgrade` command as follows:
```bash
> zopen upgrade meta
```
**Note:** If you have an older version of meta (<=0.6.3), you will need to remove the .pinned file from your zopen file system: 
```bash
> find $zopen_rootfs -name ".pinned"
# Use rm to remove .pinned entries.
```



