# Pre-requisites

## Getting Started with z/OS Open Source

Before you begin to build or consume the z/OS Open Source tools, ensure that you have access to a z/OS UNIX environment and that your environment is correctly configured.

### Set up your z/OS environment

z/OS Open Source tools leverage the [z/OS Enhanced ASCII support](https://www.ibm.com/docs/en/zos/2.1.0?topic=pages-using-enhanced-ascii). This support enables automatic conversion between codepages for tagged files. In order to take advantage of this support you will need to set the following environment variables.

```
export _BPXK_AUTOCVT=ON
export _CEE_RUNOPTS="$_CEE_RUNOPTS FILETAG(AUTOCVT,AUTOTAG) POSIX(ON)"
export _TAG_REDIR_ERR=txt
export _TAG_REDIR_IN=txt
export _TAG_REDIR_OUT=txt
```

It is recommended that you add the above environment variables to your `.profile` or `.bashrc` startup script.

### Required tools

#### If you're consuming z/OS Open Source:

If you interested in leveraging `zopen download` to download and install the z/OS Open Source tools, then you will require the following tools on your z/OS system. Alternatively, you can manually download the pax.Z releases from Github and transfer them over to your z/OS system without any additional tooling requirements.

* Obtain from Rocket: git, curl (7.77 or later if downloading releases directly without `zopen download`)
* Obtain from z/OS Open Source: curl, gzip, tar, which you can download from the [available releases](../Latest.md).

Our goal is to eventually have our own version of all the _bootstrap_ tools, but right now, we rely on some
tools from Rocket. These Rocket tools can be downloaded [here](https://my.rocketsoftware.com/RocketCommunity#/downloads).

Once you have the above pre-requisites set up, you can then clone the z/OS Open Source [utils repo](https://github.com/ZOSOpenTools/utils) as follows:
```bash
git clone https://github.com/ZOSOpenTools/utils.git
cd utils
export PATH=$PWD/bin:$PATH
```

To download and install the latest software packages, you can enter the command `zopen download`. By default it will download all of the binaries hosted on ZOSOpenTools.

It is recommended that you generate a github personal access token. Then set export `ZOPEN_GIT_OAUTH_TOKEN=<yourapitoken>`

To list the available packages, specify the --list option as follows:

```bash
zopen download --list
```

To download and install a specific package, you can specify the -r option as follows:

```bash
zopen download -r makeport
```

For more details, visit https://github.com/ZOSOpenTools/utils.

#### If you're building z/OS Open Source:
* Obtain from Rocket: Git
* Obtain from z/OS Open Source: make, curl, gzip, tar, which you can download from the [available releases](Latest.md). 
* Obtain from IBM: C or C++ compiler (or both). 
You can download a web deliverable add-on feature to your XL C/C++ compiler 
[here](https://www.ibm.com/servers/resourcelink/svc00100.nsf/pages/xlCC++V241ForZOsV24).
Alternatively, you can install and manage _C/C++ for Open Enterprise Languages on z/OS_ using _RedHat OpenShift Container Platform_ and _IBM Z and Cloud Modernization Stack_ 
[here](https://github.com/IBM/z-and-cloud-modernization-stack-community). 
Please note that these compilers are comparable, but how you perform installation and maintenance and pricing is different.
