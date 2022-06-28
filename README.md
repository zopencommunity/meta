# meta
Meta repository to tie together the various underlying z/OS Open Source tools repositories here

View our documentation at https://zosopentools.github.io/meta/

## Background

There are some key 'foundational' Open Source technologies needed to port software. The goal of this set of repositories is to provide minimal 'port' repositories
that can be used to get a foundational software package building on z/OS.
We are starting with what we view as some 'foundational' technologies. One is the stack of technology to be able to build [zsh](https://sourceforge.net/projects/zsh/postdownload). Another is to 
be able to build [protocol buffers](https://github.com/protocolbuffers/protobuf/releases). 

But - there is a _transitive closure_ problem to address with porting a software package, namely understanding what packages are pre-requisites 
for the software package you want to port. For zsh, we see the following:

zsh requires autoconf to configure the build scripts, GNU make to run Makefiles, ncurses
zsh is easier to develop (but doesn't require) curl and git natively on z/OS, and GNU techinfo for documentation

autoconf requires m4, automake, GNU make
m4 requires a c99 compiler with c11 features, so ensure you have the latest C/C++ compilers installed on your system

GNU make requires GNU m4, automake, autoconf, Perl, and a C compiler that is gcc compatible

Perl requires a c89 compiler
ncurses requires an ANSI C compiler 

TL;DR to port zsh, first port:
 - m4
 - Perl
 - autoconf
 - automake
 - GNU make
 - ncurses
You will likely want to port:
 - git
 - curl
 - techinfo
