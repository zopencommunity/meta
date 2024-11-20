# VIM on z/OS

## Why VIM?
VIM is a popular and powerful text editor that is often used by programmers for writing code. While VIM is available on many different platforms, it can also be used on z/OS.

## How to obtain VIM on z/OS?
To obtain VIM on z/OS, use the [zopen package manager](https://zopencommunity.github.io/meta/#/Guides/ThePackageManager) to install it as follows:
```
zopen install vim
```
Since VIM depends on ncurses, it will automatically download ncurses as a runtime dependency.

## How to obtain Alpha release of VIM on z/OS with Dataset I/O support
To obtain [VIM on z/OS with dataset I/O support](https://github.com/zopencommunity/vimport/releases/tag/datasetio), use the [zopen package manager](https://zopencommunity.github.io/meta/#/Guides/ThePackageManager) to install it as follows:
```
zopen install vim%datasetio
```
It will automatically download ncurses and libdio as runtime dependencies.

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

Add the following in .vimrc file between plug#begin and plug#end:

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


#### vim-airline
vim-airline is a lightweight status/tabline plugin for Vim. It replaces the standard status line with a more aesthetically pleasing and feature-rich status line. It provides essential information like the current file, line number, file encoding, file type, and Git branch in a minimalistic and visually appealing manner.

#### vim-airline-themes
vim-airline-themes is a companion plugin to vim-airline that offers a variety of themes to customize the appearance of the status line. This plugin makes it easy to switch themes to match your preferred color scheme or to enhance your coding environment's visual appeal.


Add the following in .vimrc file between plug#begin and plug#end:

> " Install the airline plugin<br/>
> Plug 'vim-airline/vim-airline'<br/><br/>
> " Install the airline-themes plugin<br/>
> Plug 'vim-airline/vim-airline-themes'

#### Install vim-airline & vim-airline-themes Plugin

After saving the .vimrc file, open Vim and run the following command to install the plugins

> :PlugInstall

For more details on Airline and Airline-themes, visit https://github.com/vim-airline/vim-airline & https://github.com/vim-airline/vim-airline-themes.

#### Tagbar
Tagbar is a source code browsing tool that displays the outline of the code currently open in a Vim window. It leverages the ctags utility to generate tags—indexed elements in your code—allowing for efficient and quick navigation. Tagbar’s sidebar acts like a visual table of contents, making it simple to locate specific code segments without scrolling or searching manually.


Add the following in .vimrc file between plug#begin and plug#end:

> " Install the Tagbar plugin<br/>
> Plug 'preservim/tagbar'

#### Install Tagbar Plugin

After saving the .vimrc file, open Vim and run the following command to install the plugins

> :PlugInstall

For more details on Tagbar, visit https://github.com/preservim/tagbar.

#### NERDTree
In addition to cscope and ctags, VIM users on z/OS may also want to consider using NERDTree, a plugin that allows users to view and navigate the directory structure of a codebase. This can be useful for quickly switching between files and folders, and is especially useful for working with large codebases that have many different directories and files.

Add the following in .vimrc file between plug#begin and plug#end:

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

Add the following in .vimrc file between plug#begin and plug#end:

> " Install the Fugitive plugin<br/>
> Plug 'tpope/vim-fugitive'

#### Install the Fugitive plugin

After saving the .vimrc file, open Vim and run the following command to install the plugins

> :PlugInstall

For more details on vim-fugitive, visit [https://github.com/tpope/vim-fugitive](https://github.com/tpope/vim-fugitive?tab=readme-ov-file#fugitivevim).

#### vim-gitgutter

> A Vim plugin which shows a git diff in the sign column. It shows which lines have been added, modified, or removed. You can also preview, stage, and undo individual hunks; and stage partial hunks. The plugin also provides a hunk text object.

Add the following in .vimrc file between plug#begin and plug#end:

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
> " Install the Tagbar plugin<br/>
> Plug 'preservim/tagbar'<br/><br/>
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
> " Install the airline plugin<br/>
> Plug 'vim-airline/vim-airline'<br/><br/>
> 
> " Install the airline-themes plugin<br/>
> Plug 'vim-airline/vim-airline-themes'<br/><br/>
> 
> " Initialize plugin system<br/>
> call plug#end()

