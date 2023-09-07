# Using tools 

To use any of the tools, you first need to set up your z/OS environment. See [Getting Started](/Guides/QuickStart) for details.

# Installing tools to use

To install new tools on your system, use the `zopen install` command to install tools:

- `zopen install <tool>`

`zopen install` will download the tool package, setup the tool, and then update your environment so you can run the tool. 

Some tools require other tools to function. For example, _git_ also requires _Perl_ and _bash_. `zopen install` will install
all the tools you need automatically.

Your environment set up is not permanent - once you log off and then log in again, you will need to re-establish the 
environment for the tool:

- `. <path/to/zopen>/etc/config' # Source all the tools you need
