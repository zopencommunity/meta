# Quick Start to z/OS Open Tools

z/OS Open Tools provides a package manager for 
installation of unsupported Open Source tools that run native on your z/OS system. 

z/OS Open Tools also provides an easy to use tool for building these same tools from 
source code on your z/OS system. 

Whether you want to _use_ the tools or also _improve_ the tools is up to you.

If you have installed a version of the zopen package manager prior to September 2023, 
please note you will need to [migrate to the new package manager](Migration.md). 

If you like learning through watching, check out our [Getting Started Video](https://ibm.box.com/s/xh9a6tld8z51a5x3qauhnk0idp7vgkrw). 

## Getting the zopen package manager

- Download the latest [meta pax](https://github.com/ZOSOpenTools/meta/releases) to your desktop, then upload to z/OS
- On z/OS, expand the pax file: `pax -rf meta-<version>.pax`. 
- cd to the unpax'ed directory: `cd meta-<version>`
- Set up the PATH to the `zopen` tool: `cd meta-<version>; . ./.env`
- Initialize the `zopen tools` environment: `zopen init`
- Install tools you want with `zopen install <tool>`
- Access the tools you installed by sourcing your configuration: `. <zopen_root>/etc/zopen-config`. 

See [The package manager](ThePackageManager.md) and [Developing Tools](developing.md) for more details.
