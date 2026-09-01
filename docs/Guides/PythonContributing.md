# Contributing Python packages to z/OS

The zopen community contribution process applies to Python packages too: prove
the port on z/OS, request a repository, submit the implementation through a pull
request, and keep the package healthy after it is published. Python adds one
important first step—establish whether a port is needed at all.

::: tip Requesting is different from contributing
If you need a package but are not ready to implement and help maintain it, use
the [package request board](/PackageRequests). Open a contribution issue only
when you intend to do the porting work. Requesting or voting does not create a
maintenance obligation.
:::

## 1. Check whether the package already works

Start with three sources:

- Search the [package request board](/PackageRequests) for an existing request,
  published Pulp artifact, or catalog entry.
- Check [Python candidate status](/Guides/PythonCandidates) for results from
  real installations on z/OS.
- Browse the [zopen wheel index](https://repo.zopen.community/pypi/wheels/simple/).

Then test the normal consumer path on z/OS:

```sh
export PIP_EXTRA_INDEX_URL="https://repo.zopen.community/pypi/wheels/simple/"
export PIP_CONSTRAINT="https://repo.zopen.community/pulp/content/constraints/zopen-constraints.txt"

python3 -m venv --system-site-packages .venv
. .venv/bin/activate
python -m pip install <package-name>
python -c "import <import_name>"
```

Run a small functional test as well as an import. A package can import its
pure-Python layer while a compiled extension is absent or unloadable.

If the package installs and its required functionality works from upstream
PyPI, it does not need a zopen port repository. Record the package request
outcome as **Already works—no port needed**, include the upstream URL and the
working installation command, and share the test evidence. This is a successful
outcome, not a rejected contribution.

## 2. Identify the Python-specific porting work

When the test fails, determine where native code enters the dependency graph:

- a C or C++ extension built by setuptools, CMake, Meson, or another backend;
- Cython-generated code;
- a Rust extension commonly built with maturin;
- a native library wrapped by the package;
- or a transitive Python dependency that needs its own z/OS wheel first.

Record the canonical PyPI distribution name, import name, upstream source and
license, build backend, native dependencies, Python versions tested, exact
command, and relevant failure. Check whether an optional accelerator can be
disabled while retaining the functionality users actually need.

Do not infer compatibility only from PyPI metadata. A missing universal wheel
does not prove a port is needed, and a successful install does not prove the
compiled code works.

## 3. Build a prototype on z/OS

Follow [Porting Python packages to z/OS](/Guides/PythonPorting) for the detailed
build system, interpreter matrix, wheel tagging, test hooks, dependency handling,
and z/OS shell pitfalls. A normal Python port begins by setting:

```sh
export ZOPEN_BUILD_SYSTEM="Python"
```

`zopen-build` then creates an isolated environment for each available targeted
interpreter, builds the appropriate wheel, installs it, runs the checks, and
stages the wheels for publication. Use `zopen_python_test` when the upstream
test command needs customization; do not replace `ZOPEN_CHECK`, hardcode
`.venv`, or install a glob of every wheel in `dist/`.

Before requesting a repository, aim to know:

1. Which source release you are building.
2. Which patches or environment changes z/OS requires.
3. Which Python versions produce usable wheels.
4. Which tests pass, fail, or must be excluded with a documented reason.
5. Which zopen, IBM Python, system, and Python dependencies are required.
6. Whether the resulting wheel installs through the documented consumer path.

## 4. Open the Python contribution issue

Open a
[Python Package Port Contribution](https://github.com/zopencommunity/meta/issues/new?template=python-contribution.yml&title=%5BNew+Python+Port%5D%3A+%3Cpackage-name%3E)
issue. Keep the canonical package name after the colon in the title; repository
creation automation uses it to create `<package-name>port`.

The form asks for the information that otherwise causes repeated follow-up:

- PyPI and upstream source URLs;
- implementation language and build backend;
- current install, import, or test result on z/OS;
- Python versions tested or targeted;
- native and transitive dependencies;
- relevant command output and proposed approach;
- confirmation that you intend to contribute and help maintain the port.

The issue receives the same `port-repo-request` label as a general port
contribution. A code owner can ask questions or suggest that a dependency be
ported first. Once the issue is approved, the existing automation creates the
repository and grants the issue author access.

## 5. Submit the port

Clone the new repository and use `zopen generate` to create the standard port
layout. Keep z/OS changes as small, reviewable patches and send generally useful
fixes upstream when practical. Include the upstream license and follow its
coding requirements for patched source.

Your pull request should include:

- the `buildenv` and generated zopen framework files;
- focused patches with their purpose explained;
- declared build and runtime dependencies;
- checks that exercise the installed package, especially native functionality;
- accurate version metadata and supported Python versions;
- documentation for known limitations or intentionally skipped tests;
- and a link to the approved contribution issue.

Run `zopen build` on z/OS before opening the pull request. The pull request must
pass automated checks and receive approval under the normal
[contribution guidelines](https://github.com/zopencommunity/meta/blob/main/CONTRIBUTING.md).
CI runs when the pull request opens or when an authorized participant comments
`/run tests`.

## 6. Verify publication like a user

For compiled packages, expect one wheel per supported CPython ABI. Pure-Python
wheels can be shared, but must still be tested with each supported interpreter.
After publication, create a fresh environment and install from the same indexes
and constraints documented for users:

```sh
python3 -m venv --system-site-packages /tmp/<package-name>-verify
. /tmp/<package-name>-verify/bin/activate
python -m pip install <package-name>
python -c "import <import_name>; print('import ok')"
```

Repeat the meaningful functional smoke test. Verify that the wheel is visible
in the zopen index, its version appears in the generated constraints, and the
corresponding package request links to the installation instructions.

## 7. Continue stewardship

Contributing the first wheel begins rather than ends stewardship. Watch upstream
releases, keep dependencies and Python versions current, investigate CI and user
reports, and document when a package becomes stale or needs another maintainer.
Maintenance is an open community responsibility and can be transferred when
availability changes.

## Related guides

- [General porting guide](/Guides/Porting)
- [Porting Python packages to z/OS](/Guides/PythonPorting)
- [Using Python packages on z/OS](/Guides/PythonPackages)
- [Python candidate status](/Guides/PythonCandidates)
- [Governance and responsibility](/Governance)
