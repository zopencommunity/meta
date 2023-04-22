# How to Set Bash as Your Default Shell on z/OS

By default, z/OS uses the Bourne shell (/bin/sh) as the default shell for its z/OS UNIX and OMVS environment. However, Bash is a more powerful and feature-rich shell that offers several advantages over the Bourne shell.

## Why Bash is Better

Here are some reasons why Bash is better:

1. Tab completion: Bash supports tab completion, which means you can type the first few letters of a command or filename, and then press the Tab key to automatically complete it. This feature can help you save time and reduce typing errors.

2. Scripting: Bash is a powerful scripting language that allows you to automate complex tasks and perform operations that are not possible with the Bourne shell. Bash scripts can use variables, loops, conditions, and other programming constructs to perform a wide range of tasks.

3. Compatibility: Bash is compatible with the Bourne shell, which means that scripts written for the Bourne shell can run in Bash without modification. This makes it easy to migrate existing scripts to Bash without having to rewrite them.

## How to Set Bash as Your Default Shell

To set Bash as your default shell on z/OS, follow these steps:

1. Log in to your z/OS system and open a terminal session.

2. Enter the following command to check if Bash is installed:

```
type bash
```

If Bash is not installed, you can install it using the following command:
```
zopen install bash
```
or you can download it directly from https://github.com/ZOSOpenTools/bashport/releases.

3. Enter the following command to set Bash as your default shell in your OMVS segment:
```
tscmd "ALTUSER USERID omvs(program(/path/to/bash))
```
where USERID is your z/OS user id and `/path/to/bash` is the path to your bash executable.

4. To confirm that your OMVS Program Segment is set to bash, run the following command:
```
tsocmd "LISTUSER USERID OMVS" | grep PROGRAM
```

5. Log out of your z/OS system and log back in for the changes to take effect.

Congratulations! You have now set Bash as your default shell on z/OS. You can now take advantage of its many features and capabilities to be more productive and efficient in your work.
