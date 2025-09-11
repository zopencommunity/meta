# Quick Start to zopen community

zopen community provides a package manager for 
installation of unsupported Open Source tools that run native on your z/OS system. 

zopen community also provides an easy to use tool for building these same tools from 
source code on your z/OS system. 

Whether you want to _use_ the tools or also _improve_ the tools is up to you.

If you have installed a version of the zopen package manager prior to September 2023, 
please note you will need to [migrate to the new package manager](Migration.md). 

## Installing zopen package manager <!-- {docsify-ignore} -->

Before installing, ensure **auto-conversion** is enabled by checking the environment variables `_BPXK_AUTOCVT` and `_CEE_RUNOPTS`. If they are not set, run:

```bash
export _BPXK_AUTOCVT="ON"
export _CEE_RUNOPTS="FILETAG(AUTOCVT,AUTOTAG)"
```

---

### Quick Install (if `curl` and `bash` are available)

Run the following one-liner:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/zopencommunity/meta/HEAD/tools/zopen_install.sh)"
```

---

### Manual Installation

If `curl` or `bash` are **not** available, follow these steps:

1. **Download the latest meta package**  
   Download the latest [meta pax file](https://github.com/zopencommunity/metaport/releases) to your desktop, then upload it to z/OS.  
   > **Note:** Use `sftp` to transfer the file from a non-z/OS machine to z/OS to avoid ASCII/EBCDIC conversion issues.

2. **Extract the pax file on z/OS**  
   ```bash
   pax -rf meta-<version>.pax.Z
   ```

3. **Navigate to the uncompressed directory**  
   ```bash
   cd meta-<version>
   ```

4. **Set up the PATH for the `zopen` tool**  
   ```bash
   . ./.env
   ```

5. **Initialize the zOpen environment**  
   ```bash
   zopen init
   ```

6. **Configure your zOpen environment**  
   ```bash
   . $ZOPEN_ROOTFS/etc/zopen-config
   ```  
   > Replace `$ZOPEN_ROOTFS` with the path to your zOpen file system.

7. **Install desired tools**  
   ```bash
   zopen install <tool>
   ```

8. **Cleanup**  
   After installation, you can safely remove the downloaded pax file and the extracted directory:  
   ```bash
   rm -f meta-<version>.pax.Z
   rm -rf meta-<version>
   ```



* **Note**: We recommend that you add the line `. $ZOPEN_ROOTFS/etc/zopen-config` to your `.profile` startup script. Alternatively, you can use `zopen init --append-to-profile` when setting up your zopen file-system.

See [The package manager](ThePackageManager.md) and [Developing Tools](developing.md) for more details.

## Getting Started Video <!-- {docsify-ignore} -->
If you like learning through watching, check out our getting started Video:
<video height="1080" controls>
  <source src="https://github.com/zopencommunity/collateral/raw/main/ZOSOpenToolsIntroV2-cropped.mp4" type="video/mp4">
</video>


## Upgrading zopen community <!-- {docsify-ignore} -->

zopen community can be upgraded like so:

```
$ zopen upgrade
```

In this case, all packages including the package manager, `zopen` (via the meta package manager) will
be updated sequentially while being prompted to perform the update.
Using the option `-y` will automatically accept all prompts as
shown here:

```
$ zopen upgrade -y
```


## Upgrading a single package <!-- {docsify-ignore} -->

Individual packages can be upgraded by specifiying the package
name.  For example upgrading just the package manager is
accomplished like so:

```
$ zopen upgrade meta -y
$ zopen init --re-init
# This assumes zopen is installed in your $HOME directory
$ . ~/zopen/etc/zopen-config
```

Note, for users of meta 0.6.x and earlier, if the upgrade fails because of a pinned message, find the 
`.pinned` file and remove it.  Afterwards `zopen upgrade meta -y` will
work.

For example:

```
$ cd ~/zopen
$ find . -name ".pinned"
./meta-0.6.2/.pinned
./usr/local/zopen/meta/meta-dt/.pinned
$ rm ./usr/local/zopen/meta/meta-dt/.pinned
# This is a version installed as part of the install process and
# can be safely removed once installed.
$ rm -rf ./meta-0.6.2/.pinned
```


