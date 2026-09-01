# Migration Guide

> [!IMPORTANT]
> The new zopen package manager is now available as of September 2023 and is **not compatible** with the previous version of zopen.

## Migrating from the old zopen file system setup (`zopen-setup`)

1. Identify the tools you have already installed: `zopen install --list`
2. If you plan to reuse the existing zopen root directory for installing the new tools, make sure to back it up to a different directory.
3. Proceed to [Getting Started](QuickStart) and install the new package manager and the tools you had before.

## Migrating from Rocket Software Tools

Some Rocket Software tools, such as Git, ask the user to export a set of environment variables prior to running the tool — for example, `GIT_EXEC_PATH` and `GIT_TEMPLATE_DIR` for Git.

Some of these environment variables may persist in your `.profile`, `.bashrc`, or other scripts. These environment variables could lead to conflicts with zopen tools and could cause potential functional issues.

To avoid such conflicts, it is recommended to remove or unset all Rocket Software environment variables. If you are unsure, source the zopen configuration file `$ZOPEN_ROOTFS/etc/zopen-config` **after** configuring Rocket Software tools.
