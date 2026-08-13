# Porting Python Packages to z/OS

How `zopen-build`'s Python build system works, what it does for you, and the
things that reliably catch people out. Read this before writing a `buildenv`
for a Python package.

## The short version

::: tip Porting with an AI assistant
Much of what follows is encoded as a reusable skill at
[zopencommunity/ai-porting](https://github.com/zopencommunity/ai-porting/blob/main/skills/zos-python-porting/SKILL.md).
It carries the failure modes below in a form an assistant can act on —
including the ones whose error messages point somewhere other than the cause.
Worth loading before starting a port, and worth updating when you hit something
new.
:::


Set one variable and `zopen-build` handles the rest:

```sh
export ZOPEN_BUILD_SYSTEM="Python"
```

It builds a wheel per interpreter, tests each one, installs the primary into
the pax, and stages every wheel for the wheel index. Most ports need nothing
else.

## The interpreter matrix

`ZOPEN_PYTHON_VERSIONS` defaults to `"3.12 3.13 3.14"`, narrowed at startup to
whichever are actually installed on the build machine.

- A version named **explicitly** must be present, or the build fails before
  compiling. Publishing fewer wheels than intended is invisible until an
  install fails with "no matching distribution".
- A **defaulted** version that is missing is skipped with a log line, so a
  machine with only one Python still builds.

Interpreters are located via `ZOPEN_PYTHON_<major>_<minor>` (exported by
`check_python`), then `python<version>` on `PATH`, then `python3`/`python` if
either reports the version asked for. Each version installs under its own
prefix and only one ends up on `PATH`, which is why the variables exist.

What this means for a `buildenv`:

- A compiled extension produces one wheel per interpreter
  (`pkg-1.0-cp312-none-any.whl`, `pkg-1.0-cp313-none-any.whl`, ...).
- A pure Python wheel is built once and shared, but still tested on each.
- **Never glob `dist/*.whl`.** That hands pip every version's wheel at once and
  it refuses with `is not a supported wheel on this platform`.
- **Never hardcode `.venv`.** That is only the primary interpreter's
  environment, so the others go untested.
- Every interpreter writes to **one** check log, so `zopen_check_results` has to
  sum across runs.

To pin a port to fewer interpreters — for example when a dependency only exists
for one — set it explicitly:

```sh
export ZOPEN_PYTHON_VERSIONS="3.12"
```

## Customising the tests

To change how tests run, define `zopen_python_test`. **Do not override
`ZOPEN_CHECK`.**

`zopen_python_test` is called once per interpreter with that interpreter's
virtual environment already active and its wheel already installed. `python`
and `pip` are the right ones and `dist/` never has to be inspected:

```sh
zopen_python_test() {
  pip install my-test-only-dep || return $?
  python -m pytest -v
}
```

Overriding `ZOPEN_CHECK` replaces the **whole loop over interpreters**, not just
the test command. Ports that have done so consistently re-implemented it
incorrectly in the same two ways — activating `.venv`, and installing
`dist/*.whl`.

### Tests that must run outside the source tree

Common for C and Rust extensions, where a source directory of the same name
shadows the installed package:

```sh
zopen_python_test() {
  test_dir="/tmp/${ZOPEN_PROJECT_NAME}_chk_$$"
  rm -rf "${test_dir}"
  mkdir -p "${test_dir}" || return $?
  cp -R tests "${test_dir}/" || return $?

  # Subshell, so a failure cannot leave the build somewhere unexpected.
  (cd "${test_dir}" && python -m pytest tests/ -v)
  rc=$?
  rm -rf "${test_dir}"
  return ${rc}
}
```

Copy `tests` as a **subdirectory**, not its contents, if fixtures use
CWD-relative paths like `Path("tests/files/x")`. Avoid the substring `tests` in
the directory name if any test asserts on `os.getcwd()`.

### Hooks that run once

`zopen_pre_check` runs **once**, before any interpreter is chosen. Do not
activate a virtual environment or install dependencies there — it can only ever
equip the primary interpreter. Put per-interpreter setup in
`zopen_python_test`; file edits that are the same for every interpreter are
fine in `zopen_pre_check`.

## Writing `zopen_check_results`

Every interpreter writes to one check log. Four mistakes, all found in shipped
ports:

**Reading the last result instead of summing.**

```sh
# WRONG - reports one interpreter's count as the whole suite
totalTests=$(grep -oE "Ran [0-9]+ test" "${chk}" | tail -1 | grep -oE "[0-9]+")
# RIGHT
totalTests=$(grep -oE "Ran [0-9]+ test" "${chk}" | awk '{s+=$2} END {print s+0}')
```

**Treating any `OK` as success.** One passing interpreter then zeroes another's
failures. Sum `failures=` and `errors=` instead.

**Counting unittest's expected failures.** A `@expectedFailure` test that fails
as designed is a pass, and unittest reports it on the *success* line —
`OK (skipped=2056, expected failures=5)`. A bare `failures=` match picks up the
`5` inside it, once per interpreter. Strip it first:

```sh
actualFailures=$(sed 's/expected failures=[0-9][0-9]*//g' "${chk}" \
  | grep -oE "(failures|errors)=[0-9]+" | cut -d= -f2 | awk '{s+=$1} END {print s+0}')
```

**`grep -c ... || echo 0`.** `grep -c` prints `0` *and exits 1* when nothing
matches, so the fallback appends a second zero and the arithmetic dies with
`FSUM9224 bad number "0\n0"`. This fires on **clean** runs, because a clean run
has no failure lines. It is not a z/OS limitation — GNU grep behaves
identically, so adding `grep` as a dependency does not help:

```sh
passed=$(grep -c "^PASS:" "${chk}" 2>/dev/null); passed=${passed:-0}
```

Also count an interpreter that produced **no** output. A wheel that fails to
import kills its run before printing any counts, which otherwise reads as
success:

```sh
runs=$(grep -c "SMOKE_TOTAL=" "${chk}"); runs=${runs:-0}
interpreters=$(grep -c "Running tests with Python" "${chk}"); interpreters=${interpreters:-0}
[ "${runs}" -lt "${interpreters}" ] && actualFailures=$((actualFailures + interpreters - runs))
```

## Dependencies are not bundled

`zopen-build` installs the port's own wheel with `--no-deps`, and the generated
`.env` adds only that port's `lib/python` to `PYTHONPATH`. A package with
runtime dependencies therefore ships a pax that cannot import.

Install the closure explicitly:

```sh
zopen_post_install() {
  pip install --disable-pip-version-check --no-warn-script-location --no-deps \
    --target "${ZOPEN_INSTALL_DIR}/lib/python" \
    <dep> <dep> ... || return $?
}
```

Dependencies needed only by the tests belong in `zopen_python_test` instead, so
each interpreter gets its own copy.

If the list is hand-maintained, it drifts on every upstream version bump, and
the failure is unfriendly: pip warns `X requires Y, which is not installed` and
then exits 0, so the build only breaks later at import. Re-check it on a bump:

```sh
python3 -c "import json,urllib.request as u; d=json.load(u.urlopen(
  'https://pypi.org/pypi/<pkg>/<ver>/json')); print([r for r in
  d['info']['requires_dist'] if 'extra ==' not in r])"
```

## Where wheels go

`zopen-build` copies every wheel to **`$ZOPEN_ROOT/install/dist/`**, next to the
pax and `metadata.json`. That is where CI looks.

Do **not** stage to `$ZOPEN_INSTALL_DIR/dist/`. That tree is what gets packaged,
so a wheel there ships a second copy of everything already under `lib/python`,
and CI never finds it — the port builds green and publishes nothing.

## Republishing an existing version

A PyPI index is immutable per filename. `zopen-publish` refuses to replace a
published wheel; pass `--on-conflict build-tag` and it compares the two by
**content**:

- **Contents identical** — reported as already published, nothing uploaded.
  This is the common case, since an unpinned build toolchain rewrites
  `.dist-info` on its own schedule.
- **Contents differ** — reuploaded as the next
  [PEP 427](https://peps.python.org/pep-0427/) build tag,
  `pkg-1.0-1-cp312-none-any.whl`, which pip prefers over the untagged wheel.
  The version users see is unchanged.

Nothing already in the index is ever replaced.

Note that compiled output is **not reproducible** on z/OS: the binder stamps
build date and time into the program object, so an unchanged source rebuild
produces a different `.so`. `SOURCE_DATE_EPOCH` does not reach it — that
controls zip entry mtimes, not the binder. Expect every rebuild of a compiled
port to earn a new build tag.

## Rust extensions and other prebuilt wheels

Some packages are Rust extensions (`pydantic-core`, `rpds-py`, `watchfiles`).
There is no native Rust toolchain for z/OS, so they cannot be compiled by
`ZOPEN_BUILD_SYSTEM=Python` on-platform.

**Check whether you need the package at all first.** Resolve the full
dependency closure and see how much is genuinely impure — it is often one
package out of a dozen. Sometimes an older release of the consumer avoids it
entirely (for example, `fastapi<=0.125.0` accepts pydantic v1, which is pure
Python; `fastapi>=0.130.0` requires v2 and therefore `pydantic-core`).

**You cannot repackage one `.so` across interpreters.** An extension tagged
`cp312` is compiled against CPython 3.12's private ABI, whose struct layouts
change between minor versions. Renaming it to `cpython-313.so` yields something
3.13 loads and then misbehaves in. Upstreams ship one wheel per interpreter for
exactly this reason. Unless the project enables PyO3's `abi3` feature, each
interpreter needs its own cross-compile.

The pattern is a `ZOPEN_TYPE="BARE"` port that downloads prebuilt wheels from
its own GitHub release assets and puts them through the rest of the pipeline —
retagged, imported on each interpreter, packaged and published. Requirements
that are easy to miss:

- **`ZOPEN_STABLE_URL` is still required.** `checkEnv` exempts only
  `ZOPEN_TYPE=LOCAL`; a BARE port without one fails with `Building from stable,
  but ZOPEN_STABLE_URL not specified` before doing anything. Nothing is fetched
  from it — `getCode` returns early for BARE — so it records which upstream
  source the binary was built from.
- **Supply `zopen_append_to_env` yourself.** The `PYTHONPATH` snippet is only
  generated for `ZOPEN_BUILD_SYSTEM="Python"` ports. Without it the module
  installs and is not importable, and install validation fails.
- **`chtag -b` the downloaded wheel.** It is a zip; tagging it as text invites
  conversion.
- **Derive the interpreter tag from Python**, not by parsing `--version`:
  `python3 -c 'import sys; print("%d%d" % sys.version_info[:2])'`.
- **Upload wheels under their native name** and let the port retag them.
  Renaming to `-none-any` by hand leaves the internal `WHEEL` metadata still
  declaring the original platform tag, which is malformed per PEP 427 — and it
  will not self-heal, because retagging treats a `-none-any` name with a `cp*`
  python tag as already done.
- **Strip the binary** before packaging. Unstripped Rust extensions have been
  an order of magnitude larger than their Linux equivalents, in every wheel,
  pax and install.
- **Keep `ZOPEN_BUILD_SYSTEM="Python"`** so the wheels reach the index and get
  imported per interpreter. A cross-compiled binary that nobody ever loaded is
  the main risk; the smoke test is what catches it. If you replace
  `ZOPEN_MAKE`, it must still create a virtual environment per interpreter,
  because the check phase runs in them.

## Consuming wheels from the index

Consumer setup — the index URL, the constraints file, `--system-site-packages`
and the traps that come with them — is on its own page:
**[Using Python packages on z/OS](/Guides/PythonPackages)**. Read it before
publishing, because a port that is unusable by the documented consumer path is
not finished.

Two things a port author owns rather than a consumer:

**The constraints file is generated.** Version pins come from the wheel index,
so publishing a port adds its pin automatically. The hand-maintained half in
`data/zopen-constraints.txt` holds only caps on third-party packages — a
ceiling below a release that pulls in something unbuildable here.

**A cap lives in two places that state it inversely.** If the server also runs
a PyPI pull-through, its remote carries an `excludes` list saying the same
thing backwards: `foo<2.0` as a constraint is `foo>=2.0` as an exclude. The
publish job only ever *adds* to `excludes`, so a ceiling the constraints file
has dropped stays in force for proxy users until someone deletes it there too.

**Or configure a PyPI pull-through** on the Pulp server. This is not simpler
for users — they still need both settings, because the proxy excludes the
packages zopen publishes and those still come from the wheels index. What it
buys is enforcement for users who never set `PIP_CONSTRAINT`, plus caching.
Three things make it work:

- The proxy **merges** upstream into the same view, so the packages you publish
  must be listed in the remote's `excludes` or PyPI still shadows them.
- Excludes are parsed as PEP 508 requirements, so version bounds work.
- Pull-through **caches into the bound repository**
  (`PULL_THROUGH_SUPPORTED = True` in pulp_python, gated on the distribution
  having a repository). Point the proxy distribution at a throwaway cache
  repository, never at the curated one, or proxied PyPI content accumulates in
  it. A distribution with a remote and *no* repository does not work — the
  index renders but downloads serve the wrong artifact.

## z/OS shell and environment traps

None of these are theoretical; each shipped in a real port or pipeline.

**`find` has no `-path`.** It rejects the expression entirely (`FSUM6372`), and
with `2>/dev/null` the search silently matches nothing. This made a CI step
report "produced no wheel" for a wheel it had just built.

**`grep` has no `-o`/`-oE`** (`FSUMA930`).

**GNU tools are not reliably on `PATH`.** zopen ships them in an `altbin`
directory that is on `PATH` on some build machines and not others, so identical
code passes on one agent and fails on another. Dependency `.env` files are
sourced **inside** `zopen-build`, so a declared tool is available to `buildenv`
functions; code running **outside** `zopen-build`, such as a CI shell step, gets
whatever `/bin` provides. Adding a dependency does not help there. Prefer POSIX
constructs, or a shell glob over `find`.

**`zopen-build` is `#!/bin/sh`.** No `[[ ]]`, `local`, `read -d`, or process
substitution in anything it sources.

**Unbalanced `)` inside `$( )` breaks the parser** (`FSUM7332`), even when
quoted — `$(... | sed 's/)//')` fails. Balanced parens are fine.

**File encoding.** Files may be tagged ASCII (`ISO8859-1`) or untagged EBCDIC,
and this differs per machine even for the same file. A shell heredoc writes
EBCDIC; if you then tag the result `ISO8859-1`, Python reads it as UTF-8 and
fails with `invalid start byte`. Tag files as what they actually are
(`chtag -tc IBM-1047` for shell-written text, `chtag -tc ISO8859-1` for
ASCII, `chtag -b` for binaries), and preserve the original tag when rewriting
one. Sourcing a tagged ASCII file from a non-interactive `ssh` shell fails with
a syntax error unless `_BPXK_AUTOCVT=ON` is set — that is not corruption.

**IBM's Python version banner differs from upstream.** `python3 --version`
prints `IBM Open Enterprise SDK for Python 3.12.13`, so the version is the
**last** field, not the second. Taking field two yields `Open` and the build
fails with `The version string "Open" uses an invalid version format`. Better
still, ask Python:

```sh
python3 -c 'import sys; print(".".join(map(str, sys.version_info[:3])))'
```

**Python 3.14 changed the platform tag** from `os390_<release>_<model>` to
`zos`, and moved from `/usr/lpp/IBM/cyp/v3rNN` to `/usr/lpp/IBM/python/v3r14`.
Anything matching `os390*` or assuming the `cyp` prefix misses 3.14.

**Explicit TCP ports are commonly reserved** in the TCP/IP profile, so binding
one fails with `EDC8115I Address already in use` even when nothing is listening.
Ephemeral binding works — start servers with `--port 0` and read the assigned
port from the server's own output.

## Don't fabricate the version

The port template ships:

```sh
zopen_get_version() {
  echo "1.0.0" # Modify to echo the version of your tool/library
}
```

Leaving it means `.version`, `metadata.json` and the RPM name are all wrong.
Echo the version variable declared at the top of the `buildenv`.

Equally, if a `# bump:` line updates a version variable, make sure
`ZOPEN_STABLE_TAG` uses it (`"v${PKG_VERSION}"`). A hardcoded tag drifts, and
the port then builds one version while reporting another.
