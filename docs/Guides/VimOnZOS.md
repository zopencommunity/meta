# VIM on z/OS

## Why VIM?
VIM is a popular and powerful text editor that is often used by programmers for writing code. While VIM is available on many different platforms, it can also be used on z/OS.

## How to obtain VIM on z/OS?
To obtain VIM on z/OS, use the [zopen package manager](https://zosopentools.github.io/meta/#/Guides/ThePackageManager) to install it as follows:
```
zopen install vim
```
Since VIM depends on ncurses, it will automatically download ncurses as a runtime dependency.

## How to use VIM?

Now, you can use VIM to edit new or existing files:
```
vim new.txt # create a new file
vim ~/.profile # edit an existing file
```

VIM on z/OS currently understands the `IBM-1047` and `ISO8959-1` file tags. If you are editing a file that is untagged or editing a new file, VIM will save it as ISO8959-1 (ASCII). You can use change this behaviour by setting the `_ENCODE_FILE_NEW` environment variable. For example, to tag new files as IBM-1047, set `export _ENCODE_FILE_NEW=IBM=1047`

## Improving your VIM experience with various tools and plugins

### Tools

#### Cscope
**Cscope** is a tool that allows users to search for symbols, functions, and other code constructs in a codebase. This can be incredibly useful when working with large codebases on z/OS, as it allows users to quickly navigate and find the code they need.

To use Cscope, first download it using `zopen install cscope` and then source the .env file as follows: `. ./.env`

Now, navigate to a codebase. Let's take the Git source as an example. Since Git is a C-based project, we'll use Cscope to a cscope database for all of the C source files and headers.
```
find . -name '*.c' -o -name "*.h" > cscope.files
cscope -b -i cscope.files # Create the cscope db file
```

Now, load up VIM from your project root directory. You can now use the `:cscope` tool to search the references to a definition.

For example:
```
:cscope find main all
```
Will locate all references to main

To map the cscope to shortcut keys, the following vim script is recommended: https://github.com/joe-skb7/cscope-maps/blob/master/plugin/cscope_maps.vim. You can copy and paste it to your .vimrc.

#### CTags
Another useful tool is **ctags**, which is similar to cscope but operates at a lower level. Ctags generates a list of tags for a codebase, which can then be used by VIM to quickly navigate to specific functions and other code constructs. This can be a huge time-saver when working with complex codebases on z/OS.

To use CTags, first download it using `zopen install ctags` and then source the .env file as follows: `. ./.env`

Now, navigate to a codebase. Let's take the Git source as an example.
```
ctags -R . # this will create a tags file in the current dir
```

You can now load up VIM on a source file and then place your cursor on a function, variable, or type and use the ctrl-] short-cut to jump to its definition. To jump back, you can use ctrl-t.

For more details on ctags and cscope, read this lovely tutorial: https://www.embeddedts.com/blog/tag-jumping-in-a-codebase-using-ctags-and-cscope-in-vim/

### Plugins

#### Install vim-plug

vim-plug is a popular plug-in manager for Vim that makes it easy to install and manage plugins.

Install vim-plug by running the following command:
> curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

This command downloads and places the plug.vim file in the ~/.vim/autoload/ directory.

#### Configure vim-plug 

Open your Vim configuration file (~/.vimrc) or create it if it doesn’t exist
> vim ~/.vimrc

Add the following lines to your .vimrc to initialize vim-plug and install the vim-gnupg plugin

> " Set up vim-plug (plugin manager) <br/><br/>
> call plug#begin('~/.vim/plugged') <br/><br/>
> " Add plugins here<br/>
> 
> " Initialize plugin system <br/>
> call plug#end()


This configuration tells vim-plug to manage plugins and specifies vim-gnupg as a plugin to be installed

#### Plugins for GPG

Add the following in .vimrc file between plu#begin and plug#end:

> " Install the vim-gnupg plugin <br/>
> Plug 'jamessan/vim-gnupg'

#### Install vim-gnupg Plugin

After saving the .vimrc file, open Vim and run the following command to install the plugins

> :PlugInstall


vim-plug will download and install the vim-gnupg plugin for you

#### Using vim-gnupg
**Encrypting a file:**
	Open or create a file with a .gpg, .pgp, or .asc extension in Vim: <br/>
> vim secretfile.gpg

When you save the file, vim-gnupg will automatically encrypt it

**Decrypting a File:**
	Open an encrypted file in Vim by running
> vim secretfile.gpg


#### NERDTree
In addition to cscope and ctags, VIM users on z/OS may also want to consider using NERDTree, a plugin that allows users to view and navigate the directory structure of a codebase. This can be useful for quickly switching between files and folders, and is especially useful for working with large codebases that have many different directories and files.

Add the following in .vimrc file between plu#begin and plug#end:

> " Install the NERDTree plugin<br/>
> Plug 'preservim/nerdtree'

#### Install NERDTree Plugin

After saving the .vimrc file, open Vim and run the following command to install the plugins

> :PlugInstall

For more details on NERDTree, visit https://github.com/preservim/nerdtree.

#### Plugins for Git

#### vim-fugitive

To quote [its README](https://github.com/tpope/vim-fugitive?tab=readme-ov-file#fugitivevim):

> Fugitive is the premier Vim plugin for Git. Or maybe it's the premier Git plugin for Vim? Either way, it's "so awesome, it should be illegal". That's why it's called Fugitive.

This plugin allows VIM users on z/OS to interact with Git repositories directly from within the editor. This can be incredibly useful for managing code changes and collaborating with other developers, as it allows users to easily manage branches, commit changes, and push code to remote repositories.

Add the following in .vimrc file between plu#begin and plug#end:

> " Install the Fugitive plugin<br/>
> Plug 'tpope/vim-fugitive'

#### Install the Fugitive plugin

After saving the .vimrc file, open Vim and run the following command to install the plugins

> :PlugInstall

For more details on vim-fugitive, visit [https://github.com/tpope/vim-fugitive](https://github.com/tpope/vim-fugitive?tab=readme-ov-file#fugitivevim).

#### vim-gitgutter

> A Vim plugin which shows a git diff in the sign column. It shows which lines have been added, modified, or removed. You can also preview, stage, and undo individual hunks; and stage partial hunks. The plugin also provides a hunk text object.

Add the following in .vimrc file between plu#begin and plug#end:

> " Install the gitgutter plugin <br/>
> Plug 'airblade/vim-gitgutter'

#### Install the gitgutter plugin

After saving the .vimrc file, open Vim and run the following command to install the plugins

> :PlugInstall

For more details on vim-gitgutter, visit https://github.com/airblade/vim-gitgutter.

#### The complete example of .vimrc file

> " Set up vim-plug (plugin manager)<br/>
> call plug#begin('~/.vim/plugged')<br/><br/>
> 
> " Install the vim-gnupg plugin<br/>
> Plug 'jamessan/vim-gnupg'<br/><br/>
> 
> " Install the NERDTree plugin<br/>
> Plug 'preservim/nerdtree'<br/><br/>
> 
> " Install the Fugitive plugin<br/>
> Plug 'tpope/vim-fugitive'<br/><br/>
> 
> " Install the gitgutter plugin<br/>
> Plug 'airblade/vim-gitgutter'<br/><br/>
> 
> " Initialize plugin system<br/>
> call plug#end()

