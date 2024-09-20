# Getting Started with z/OS Open Source

Before you begin, make sure you have access to a z/OS UNIX environment and that your environment is correctly configured.

## Setting up your z/OS environment

z/OS Open Source tools leverage [z/OS Enhanced ASCII support](https://www.ibm.com/docs/en/zos/2.1.0?topic=pages-using-enhanced-ascii). This support enables automatic conversion between codepages for tagged files. To take advantage of this support, you need to set the following environment variables:

```
export _BPXK_AUTOCVT=ON
export _CEE_RUNOPTS="$_CEE_RUNOPTS FILETAG(AUTOCVT,AUTOTAG) POSIX(ON)"
export _TAG_REDIR_ERR=txt
export _TAG_REDIR_IN=txt
export _TAG_REDIR_OUT=txt
```

We recommend adding these environment variables to your `.profile` or `.bashrc` startup script.

## Required Tools

To consume zopen community, all you need is a z/OS UNIX system and unrestricted access to github.com.

### If you want to contribute and improve the z/OS Open Source Tools 

You will need the IBM C/C++ compiler on your system. There are two options:
- XL CLang 
  - The default compiler is xlclang. You can download it as a web deliverable add-on feature to your XL C/C++ compiler 
[here](https://www.ibm.com/servers/resourcelink/svc00100.nsf/pages/xlCC++V241ForZOsV24).
- Clang
  - You can download the pax edition from IBM at https://epwt-www.mybluemix.net/software/support/trial/cst/programwebsite.wss?siteId=1803. This version may be used for development of open source software.

If you are building Go projects, you will need the IBM Open Enterprise SDK for Go compiler installed. You can obtain it here: https://www.ibm.com/products/open-enterprise-sdk-go-zos

For more details on porting, visit the [porting to z/OS guide](Porting.md).
