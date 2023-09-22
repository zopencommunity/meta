# The package manager

## Installing the package manager

Download the latest [meta pax](https://github.com/ZOSOpenTools/meta/releases) to z/OS
- download the file to your desktop
- use `sftp` to upload the pax file to z/OS.
- On z/OS, expand the pax using the command ```pax -rvf <filename>.pax```.  
  This will expand the pax to the current directory, listing the various included files as it does so.

- Source the .env to add `zopen` to your PATH:
```bash
> cd meta-<version>
> . ./.env
```

- Initialize your environment:
```bash
> zopen init
```

## Using the package manager

- Install any z/OS Open Tools via `zopen install`, e.g.
```bash
> zopen install which
```

- List which tools you have installed with `zopen list --installed`, e.g.
```bash
> zopen list --installed
 which which
```

- See if any tools can be upgraded with `zopen list --upgradeable`, e.g. 
```bash
> zopen list --upgradeable # list all tools that have upgrades available
```

- Upgrade your tools to the latest version with `zopen upgrade`, e.g.
```bash
> zopen upgrade
```

- Set up your environment to use your installed tools by sourcing your environment, e.g.
```bash
> . <zopen_root>/etc/zopen-config
```

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



