# Getting Started with z/OS Open Tools

z/OS Open Tools lets you install unsupported Open Source tools that run native on your z/OS system. 
Whether you want to strictly _use_ the tools or also _improve_ the tools is up to you.

## Getting meta

Download [meta](https://github.com/ZOSOpenTools/meta/releases/download/TDB) to z/OS.

Expand the pax using the command ```pax -rvf <filename>.pax```.  This will expand the pax to the current directory, listing the various included files as it does so.

Source the .env to pick up the zopen environment:
```bash
. ./..env
```

Now initialize your environment with zopen init:
```bash
zopen init
```

This will create a .zopen-config configuration `<zopen_root>/etc/`. You can source this in your envrionment or add it to your .bashrc or .profile.

```bash
. <zopen_root>/etc/.zopen-config
```

You are now free to install any z/OS Open Tools via `zopen install`.

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

You are now ready to _use_ or _improve_ the tools you want.

Our docs are improving all the time. See ['Updating the docs'](../UpdateDocs) if you would like to help.
