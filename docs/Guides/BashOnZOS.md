# Bash on z/OS

Bash, short for "Bourne-Again SHell," is a popular command-line interface and scripting language used primarily in Unix-based systems.

It is an alternative shell to the default Bourne shell (/bin/sh).

## Why Bash is Better

Here are some reasons why Bash is better:

1. Tab completion: Bash supports tab completion, which means you can type the first few letters of a command or filename, and then press the Tab key to automatically complete it. This feature can help you save time and reduce typing errors.

2. Scripting: Bash is a powerful scripting language that allows you to automate complex tasks and perform operations that are not possible with the Bourne shell. Bash scripts can use variables, loops, conditions, and other programming constructs to perform a wide range of tasks.

3. Compatibility: Bash is compatible with the Bourne shell, which means that scripts written for the Bourne shell can run in Bash without modification. This makes it easy to migrate existing scripts to Bash without having to rewrite them.

## How to Set Bash as Your Default Shell

By default, z/OS uses the Bourne shell (/bin/sh) as the default shell for its z/OS UNIX and OMVS environment. However, Bash is a more powerful and feature-rich shell that offers several advantages over the Bourne shell.

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
For more details on how to use and setup zopen, see the [zopen guide](/Guides/using).

Alternatively, you can download bash directly from https://github.com/zopencommunity/bashport/releases.

3. Enter the following command to set Bash as your default shell in your OMVS segment:
```
tsocmd "ALTUSER USERID omvs(program(/path/to/bash))"
```
where USERID is your z/OS user id and `/path/to/bash` is the path to your bash executable.

Please note that running this command requires elevated authority. For more information on authorization, please refer to the 'Authorization' section of the following link: https://www.ibm.com/docs/en/zos/latest?topic=syntax-altuser-alter-user-profile. In case you do not have the necessary permissions, please consider requesting assistance from a system administrator to execute the command.

4. To confirm that your OMVS Program Segment is set to bash, run the following command:
```
tsocmd "LISTUSER USERID OMVS" | grep PROGRAM
```

5. Log out of your z/OS system and log back in for the changes to take effect.

Congratulations! You have now set Bash as your default shell on z/OS. You can now take advantage of its many features and capabilities to be more productive and efficient in your work.

## How to Set UTF-8 Encoding in Bash

To set UTF-8 encoding in Bash on z/OS, set the LANG environment variable.

```
export LANG=en_US.UTF-8
```

Now try copying and pasting an emoji such as: ð
```
echo ð
```

You should see ð emitted to stdout.

Congratulations! You have now set UTF-8 encoding in Bash on z/OS. This can be beneficial if you need to work with Unicode characters in your scripts or commands.
