# Getting Started with z/OS Open Tools

z/OS Open Tools lets you install unsupported Open Source tools that run native on your z/OS system. 
Whether you want to strictly _use_ the tools or also _improve_ the tools is up to you.

The easiest way to install and build software packages from z/OS Open Tools is to setup the _zopen tools_ on your z/OS system.

We provide a program called `zopen-setup` so you can _bootstrap_ your z/OS system. Your z/OS system will need external connectivity since `zopen-setup` will connect to [z/OS Open Tools repositories](https://zosopentools.link/repos). 

## Getting zopen-setup

Download [zopen-setup](https://zosopentools.link/setup-program) to z/OS, mark the program executable, and run it. Detailed instructions follow.

### Getting zopen-setup to your z/OS system

Note: In the documentation that follows, text inside `< ... >` indicates a value you need to provide, e.g. `<z/OS system>` would be replaced with the name of the z/OS system you are using.

To get started, you need to get the _zopen-setup_ program to your z/OS system. Here is one approach:
- Log on to your desktop system
- Download [zopen-setup](https://zosopentools.link/setup-program)
- Open a terminal window on your desktop 
- `cd` into the directory you downloaded the file to
- `sftp <z/OS system>`
- Log in if required
- `put zopen-setup`
- `quit`
- `ssh <z/OS system>`
- log in if required
- `cd $HOME`
- `chmod u+x zopen-setup` # mark the program executable

If you don't have ssh, scp, sftp access to your z/OS system, we would encourage you to set it up. 
It will be much easier to work with USS using ssh, scp, and sftp.

### Running zopen-setup

- `cd $HOME`
- `./zopen-setup  <file system>` # file system is the location where the zopen tools will be installed

### Set up the zopen tools

Your zopen tools environment has been downloaded but not yet set up. To set up the environment:
- `cd $HOME/zopen/boot`
- `. ./.bootenv` # add the tools zopen needs to function, as well as zopen (don't forget the leading '.' which sources the script)

Each time you log on, you will need to set up your boot environment before you can use zopen. You do this the same way as your initial setup:
- `cd $HOME/zopen/boot`
- `. ./.bootenv`

You are now ready to _use_ or _improve_ the tools you want.

Our docs are improving all the time. See ['Updating the docs'](../UpdateDocs) if you would like to help.
