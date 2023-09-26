# Contributing

## Issues

Log an issue for any question or problem you might have. When in doubt, log an issue, and
any additional policies about what to include will be provided in the responses. The only
exception is security disclosures which should be sent privately.

Committers may direct you to another repository, ask for additional clarifications, and
add appropriate metadata before the issue is addressed.

## Contributions

Any change to resources in this repository must be through pull requests. This applies to all changes
to documentation, code, binary files, etc.

No pull request can be merged without being reviewed and approved.

## Validate your changes

Verify that the project is working by running `zopen build`.

## Coding Guidelines

When contributing your changes, please follow the following coding guidelines:
* patches: patches should adhere to the coding guidelines from the original project repository. Make sure to add the original project's LICENSE file within the patches
directory.
* zopen framework files: (e.g. buildenv) - It is recommended that you follow the [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)

If you are generating a new project, we recommend that you use `zopen generate` to create the correct zopen file and directory structure.

### Commit message

A good commit message should describe what changed and why.

It should:
  * contain a short description of the change
  * be entirely in lowercase with the exception of proper nouns, acronyms, and the words that refer to code, like function/variable names
  * be prefixed with one of the following words:
    * fix: bug fix
    * hotfix: urgent bug fix
    * feat: new or updated feature
    * docs: documentation updates
    * refactor: code refactoring (no functional change)
    * perf: performance improvement
    * test: tests and CI updates

### Developer's Certificate of Origin 1.1

<pre>
By making a contribution to this project, I certify that:

 (a) The contribution was created in whole or in part by me and I
     have the right to submit it under the open source license
     indicated in the file; or

 (b) The contribution is based upon previous work that, to the best
     of my knowledge, is covered under an appropriate open source
     license and I have the right under that license to submit that
     work with modifications, whether created in whole or in part
     by me, under the same open source license (unless I am
     permitted to submit under a different license), as indicated
     in the file; or

 (c) The contribution was provided directly to me by some other
     person who certified (a), (b) or (c) and I have not modified
     it.

 (d) I understand and agree that this project and the contribution
     are public and that a record of the contribution (including all
     personal information I submit with it, including my sign-off) is
     maintained indefinitely and may be redistributed consistent with
     this project or the open source license(s) involved.
</pre>
