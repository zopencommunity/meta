
## UPDATE: New zopen framework is now available as of September 2023

The new zopen package manager is not compatible with the previous version of zopen. 

## Migration process from old zopen file system setup via `zopen-setup`
* Identify the tools you have already installed. Use `zopen install --list`.
* If you plan to reuse the existing zopen root directory for installing the new tools, 
  make sure to back it up to a different directory.
* Proceed to [Getting Started](QuickStart.md) and install the new package manager, and the tools you had before.

## Migration process from Rocket Software Tools 
* Some Rocket Software tools, such as Git, ask the user to export a set of environment prior to running the tool. For example, `GIT_EXEC_PATH` and `GIT_TEMPLATE_DIR` for Git.
* Some of these environment variables may persist in your .profile or .bashrc or other scripts.
* These environment variables could lead to conflicts with zopen's tools and could cause potential functional issues.
* To avoid such conflicts, it is recommended to remove or unset all Rocket Software environment variables. If you are unsure, source the zopen configuration file `$ZOPEN_ROOTFS/etc/zopen-config` **after** configuring Rocket Software tools.
