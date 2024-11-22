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

## New Port Contributions

If you'd like to contribute a new z/OS port, please open an issue using the following link:
[New Port Contribution Request](https://github.com/zopencommunity/meta/issues/new?assignees=&labels=port-repo-request&projects=&template=contribution.yml&title=%5BNew+Port%5D%3A+%3Cport-name%3E)

Once the issue is created, a code owner will review your request. If approved, the issue will be labeled as "approved", and a GitHub Action will automatically create the port repository for you. If the request is not approved, the issue will be closed with an explanation.

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

## Pull Request Process

1. Fork the repository to your own GitHub account.
2. Create a new branch for your changes: `git checkout -b my-feature`
3. Make your changes and commit them to your branch.
4. Push your changes to your forked repository: `git push origin my-feature`
5. Open a pull request against the `main` branch of this repository.
6. Ensure your pull request has a clear title and description, explaining the purpose of your changes.
7. If your pull request addresses any issues, please reference them in the description using the syntax `Fixes #123` or `Closes #456`.
8. Your pull request will automatically trigger tests when opened or when you comment `/run tests`.

## Automated Tests

We have set up automated tests for this repository using GitHub Actions. When you open a pull request or comment with `/run tests`, the following action will be triggered: [build_and_test.yml](https://github.com/zopencommunity/meta/blob/main/data/build_and_test.yml).

Please make sure your changes pass all the automated tests before merging your pull request. If the tests fail, our CI/CD system will provide information on what needs to be fixed.


### Developer's Certificate of Origin 1.1

```text
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
```
