# Git on z/OS

---

**Security Updates:** The Git project regularly releases updates which deal with notified vulnerabilities - their list is [here](https://github.com/git/git/security/advisories/).

For example, in 2023 the project disclosed [two security vulnerabilities](https://github.blog/2023-01-17-git-security-vulnerabilities-announced-2/) affecting v2.39.0 and older releases, and
in May 2024, [release 2.45.1](https://github.com/zopencommunity/gitport/releases/tag/STABLE_gitport_2266) fixed 5 more which you can read about in the [Github Blog](https://github.blog/2024-05-14-securing-git-addressing-5-new-vulnerabilities/).

It is important to frequently review the vulnerabilities and keep current with releases available from zopen community.

---

Git on z/OS is a version of Git that has been adapted to work on the IBM mainframe operating system, z/OS. It allows developers to take advantage of Git's powerful version control capabilities while addressing the unique challenges of the mainframe environment. With Git on z/OS, developers can manage their code, collaborate with other developers, and maintain a clear history of the changes that have been made to the codebase.

You can find the latest information on Git for z/OS by visiting the [zopen community gitport repo](https://github.com/zopencommunity/gitport)

## Encoding considerations

Git's internal standard for character encoding of text files is UTF-8, but using options specified for files on a path-specific basis it is possible to tell Git how you would like to work with those files. The `.gitattributes` file contains this information and tells Git whether you need it to convert from UTF-8 when checking out the files into a working tree (ie the workspace of VS Code, or into folders in USS). The reverse conversion will be done during `git commit`. The standard option is `working-tree-encoding`.

Git for z/OS extends this idea with `zos-working-tree-encoding` so that while UTF-8 is a common choice during a clone to a developer's IDE, the conversion performed on z/OS can be to, for example, IBM-1047 which is a commonly used EBCDIC encoding in North America. An example `.gitattributes` specification to achieve that is:

```text
text zos-working-tree-encoding=IBM-1047
```

It is important to note that if no encoding is specified, the default UTF-8 encoding is used and all files are tagged as ISO8859-1.

To find out all of the supported encodings by git, run `iconv -l` on z/OS.

When adding files, you need to make sure that both the file contents and the z/OS file tag matches the `working-tree-encoding`. Otherwise, you may encounter an error.

## Binary files

Another important aspect of Git on z/OS is its handling of binary files. Binary files, such as images, can be specified using the `binary` attribute in the `.gitattributes` file. For example, if you want all png files to be treated as binary files, you would use the following line in your .gitattributes file:

```text
*.png binary
```

It is important to note that Git on z/OS does not currently support adding untagged files. All files need to be tagged before they can be added to a repository. Additionally, multiple working-tree-encoding attributes can be specified, with later attributes overriding earlier ones in case of an overlap.

## File Tag verifications

To prevent unexpected syntax errors when building your application, like:

```bash
zopen 1: FSUM7332 syntax error: got (, expecting Newline
```

You need to export `GIT_UTF8_CCSID` before cloning your repo:

```bash
export GIT_UTF8_CCSID=819
```

Alternatively, you can run the command for global configuration:

```bash
git config --global core.utf8ccsid 819
```

Or, for local configuration:

> [!NOTE]
> Local configuration will affect only current repository

```bash
git config core.utf8ccsid 819
```

To ignore file tag verifications between the file system file tag and the encoding specified in the working-tree-encoding, you can use the core.ignorefiletags configuration option. An example is when your files may be tagged as various encodings, but you want them to be treated verbatim regardless of the file tag. By default, Git performs verifications to ensure that the file tag of the Git files matches the tag specified in the working-tree-encoding. The default codepage of a working tree encoding is UTF-8.

For a global effect, you can use the following command:

```bash
git config --global core.ignorefiletags true
```

This will disable the file tag verification for all of the repositories on your system.

For a local repository effect, you can use the following command inside your repository:

```bash
git config core.ignoretags false
```

This will only disable the file tag verification for the specific repository you are currently in.

It's important to note that disabling file tag verification may lead to unexpected behavior, so it's recommended to use this option only if necessary and with caution.

## Migration considerations

If you are migrating from Rocket Software's Git, the good news is that Git on z/OS should be compatible. However, if you encounter any issues, you can open an issue on the [Gitport GitHub page](https://github.com/zopencommunity/gitport/issues).
