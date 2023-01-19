# Getting Started with z/OS Open Source

Are you ready to start building or consuming z/OS Open Source tools? Before you begin, make sure you have access to a z/OS UNIX environment and that your environment is correctly configured.

## Set up your z/OS environment

z/OS Open Source tools leverage the [z/OS Enhanced ASCII support](https://www.ibm.com/docs/en/zos/2.1.0?topic=pages-using-enhanced-ascii). This support enables automatic conversion between codepages for tagged files. To take advantage of this support, you need to set the following environment variables:

```
export _BPXK_AUTOCVT=ON
export _CEE_RUNOPTS="$_CEE_RUNOPTS FILETAG(AUTOCVT,AUTOTAG) POSIX(ON)"
export _TAG_REDIR_ERR=txt
export _TAG_REDIR_IN=txt
export _TAG_REDIR_OUT=txt
```

We recommend adding these environment variables to your `.profile` or `.bashrc` startup script.

## Required Tools

### If you only want to _use_ Open Source Tools

**NOTE:** These tools are unsupported. Use them at your own discretion. While we find them extremely helpful, they have bugs and are unsupported. If you encounter problems, please tell us by opening issues in the GitHub repository for the tool you are having issues with. For general problems, open an issue in the [meta](https://github.com/ZOSOpenTools/meta/issues) repository.

For new ideas, general feedback, or to start a discussion, please see our [discussions](https://github.com/ZOSOpenTools/meta/discussions).

#### Install curl on z/OS

You will need _curl 7.77_ or later on your z/OS system so that you can download the individual Open Source packages from github. 
If you don't have curl on z/OS, you will need to download it to your desktop then use _sftp_ to upload it to z/OS and then use _pax_ to decompress it:
- Download ['boot curl'](https://github.com/ZOSOpenTools/curlport/releases/tag/boot)
- Upload the pax file: `sftp <your host>`
- decompress the pax file: `pax -rf <pax file>`
- `cd curl*`
- add curl to your environment: `. ./.env`

Once you have curl, you can now install other tools from the community.

#### Install other tools

All the tools are at: [ZOSOpenTools](https://github.com/ZOSOpenTools?tab=repositories)

- Click on the repository of the tool you want. For example, the [bashport](https://github.com/ZOSOpenTools/bashport) has bash.
- Click on the _tag_ link to see the tagged releases. For example, the [bashport tags](https://github.com/ZOSOpenTools/bashport/tags) shows the builds for bash.
- Click the tag of the release you want (likely the most recent). For example: [bashport build 223](https://github.com/ZOSOpenTools/bashport/releases/tag/bashport_223)
- Cut and paste the download and install command to your z/OS system to install the tool on z/OS
  - This command will use curl to download the pax file, unpax the file, cd into the tool directory and source `.env` in that directory to set up your environment

For more details, visit https://github.com/ZOSOpenTools/meta.

### If you want to contribute and improve the z/OS Open Source Tools 

You will need the IBM C/C++ compiler on your system. There are two options:
- You can download a web deliverable add-on feature to your XL C/C++ compiler 
[here](https://www.ibm.com/servers/resourcelink/svc00100.nsf/pages/xlCC++V241ForZOsV24).
- Alternatively, you can install and manage _C/C++ for Open Enterprise Languages on z/OS_ using _RedHat OpenShift Container Platform_ and _IBM Z and Cloud Modernization Stack_ 

In addition, to use the zopen framework set of tools like `zopen-build` and `zopen-download`, you will need git, tar, gzip, make installed. All of these tools are available from [ZOSOpenTools](https://github.com/ZOSOpenTools?tab=repositories), but instead of downloading them one at a time, there is an easier way. 
Download [zopen-setup](https://github.com/ZOSOpenTools/meta/releases/tag/v1.0.0) to z/OS and then run it, [following the instructions](https://github.com/ZOSOpenTools/meta/releases/tag/v1.0.0)

`zopen-setup` will create your own development environment with a `boot`, `prod`, and `dev` set of directories. The `boot` directory has everything you need to get started with porting.

For more details on porting, visit the [porting to z/OS guide](Porting.md).

## Downloading tools to z/OS

Once you have your development environment set up, you can download tools directly to z/OS with `zopen download`.

To download and install the latest software packages, enter the command `zopen download`. By default it will download all of the tools hosted on ZOSOpenTools.

To list the available packages, specify the --list option as follows:

```bash
zopen download --list
```

To download and install specific packages, specify them as a comma delimited list as follows:
```bash
zopen download make,curl,gzip
```
For more details, see the section on [zopen tools](zopen.md).
