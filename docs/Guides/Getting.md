## Getting the zopen package manager

Download the latest [meta pax](https://github.com/ZOSOpenTools/meta/releases) to z/OS. 
This will likely involve first downloading the file to your desktop and then using `sftp` to upload the pax file to z/OS.

Expand the pax using the command ```pax -rvf <filename>.pax```.  This will expand the pax to the current directory, listing the various included files as it does so.

Source the .env to pick up the zopen environment:
```bash
cd meta-<version>
. ./.env
```

Now initialize your environment with zopen init:
```bash
zopen init
```

This will create a zopen-config configuration `<zopen_root>/etc/`. You can source this in your environment or add it to your .bashrc or .profile.

```bash
. <zopen_root>/etc/zopen-config
```

You are now free to install any z/OS Open Tools via `zopen install`.

## Sample usage
```
>./zopen init
>. <zopen_install_dir>/etc/zopen-config
>./zopen list --installed
>zopen install which
>zopen list --installed
>which which
>zopen list --upgradeable # list all tools that have upgrades available
>zopen upgrade
```
