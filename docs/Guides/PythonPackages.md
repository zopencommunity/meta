# Using Python packages on z/OS

How to install Python packages that zopen builds for z/OS, and the three ways a
normal `pip install` goes wrong here.

Everything on this page has been checked on z/OS against Python 3.12, 3.13 and
3.14.

Looking for a specific library? The [available Python packages](/PythonPackages)
catalogue shows current versions, interpreter coverage, reported verification
results, and installation commands.

## The short version

```sh
export PIP_EXTRA_INDEX_URL="https://repo.zopen.community/pypi/wheels/simple/"
export PIP_CONSTRAINT="https://repo.zopen.community/pulp/content/constraints/zopen-constraints.txt"

python3 -m venv .venv
. .venv/bin/activate

pip install cryptography
```

The index supplies z/OS wheels that PyPI does not, while the generated
constraints keep package selection aligned with the versions currently
published there.

## Why a standard virtual environment now works

The zopen index now includes z/OS wheels for native dependencies such as
`cffi`. Packages including `cryptography`, `pynacl`, and `paramiko` can therefore
be installed into an ordinary isolated virtual environment; they no longer
need to inherit the interpreter's bundled packages.

Avoid `--system-site-packages` unless you deliberately want packages from the
base interpreter. Isolation makes it easier to confirm exactly which versions
your application uses.

## Why `PIP_CONSTRAINT`

That second row is the problem. The interpreters bundle **cryptography 3.3.2**,
released in February 2021, with a long list of published CVEs including
certificate-validation bypasses.

pip treats it as satisfying a bare `pip install cryptography` and does nothing:

```
Requirement already satisfied: cryptography
```

You get a success message and stay on the vulnerable version. Nothing warns
you.

The [constraints file](https://pip.pypa.io/en/stable/user_guide/#constraints-files)
fixes this as a side effect of pinning. It says "if this package is installed,
it must satisfy this specifier", and 3.3.2 fails the pin, so pip upgrades
instead of skipping.

This is why constraints are better than `--only-binary` on z/OS rather than
merely more convenient: `--only-binary` has nothing to say about a package that
is already present.

The constraints file also caps a few third-party packages below releases that
pull in dependencies which cannot be built here. It is generated — the pins
come from the wheel index itself, so they cannot go stale.

## Why `PIP_EXTRA_INDEX_URL`

PyPI has no z/OS wheels, so without the zopen index there is nothing to install
but sdists, and a compiled package will not build.

```
https://repo.zopen.community/pypi/wheels/simple/
```

It is a PEP 503 simple index and can be browsed directly — that is the
authoritative list of what is available, always current, which is why this page
does not reproduce it.

pip resolves by version **across** both indexes, so a newer release on PyPI
still wins over a zopen wheel. That is the other thing the constraints file
prevents.

## Disk space

Compiled extensions are large here, because they are linked statically —
everything the library needs is inside the `.so` rather than resolved at run
time. `cryptography`'s extension is about 72 MB per environment, and `lxml`
ships five extension modules.

Two consequences:

- Budget on the order of 100 MB per virtual environment, not 10 MB.
- **Do not let pip's cache sit on a small filesystem.** On many systems `/u` is
  far smaller than `/tmp`. A cache that fills mid-install produces errors that
  look like dependency problems — or, worse, a truncated `.so` that fails at
  import with `CEE3512S ... reason code EF076015`, which reads like a missing
  execute bit rather than a partial file.

  ```sh
  export PIP_CACHE_DIR=/tmp/pip-cache
  ```

## Checking that an install actually worked

Importing the top-level package is not a real check for anything with a
compiled extension — the pure-Python half imports happily while the extension
is missing or unloadable. Touch the part that matters:

```sh
python -c "
import cryptography
from cryptography.hazmat.primitives import hashes
hashes.Hash(hashes.SHA256()).finalize()
print(cryptography.__version__)"
```

If you are installing something the interpreter also bundles, assert the
version too, or you may be testing the bundled copy:

```sh
python -c "import cryptography; assert cryptography.__version__ == '50.0.0'"
```

## Using uv instead of pip

`uv` is available as a port rather than from PyPI:

```sh
zopen install uv
```

It reaches the wheel index and installs from it correctly, including packages
with published native dependencies such as `cffi`, and is substantially faster
than pip.

The settings map across:

| pip | uv |
|---|---|
| `PIP_EXTRA_INDEX_URL` | `UV_INDEX` |
| `PIP_CONSTRAINT` | `UV_CONSTRAINT` |
| `PIP_CACHE_DIR` | `UV_CACHE_DIR` |

```sh
export UV_INDEX="https://repo.zopen.community/pypi/wheels/simple/"
export UV_CONSTRAINT="https://repo.zopen.community/pulp/content/constraints/zopen-constraints.txt"
export UV_CACHE_DIR=/tmp/uv-cache

uv venv .venv
uv pip install --python .venv/bin/python cryptography
```

`UV_INDEX` rather than `UV_EXTRA_INDEX_URL`: uv accepts the latter but reports
it as deprecated in favour of `--index`.

### Python 3.14 needs a recent enough uv

Older uv builds could not use 3.14 at all, failing before the environment was
created:

```
error: Failed to inspect Python interpreter
  Caused by: Unknown operating system: `zos`
```

The interpreters disagree about what to call this platform, and uv understood
only the older spelling:

| interpreter | `sysconfig.get_platform()` |
|---|---|
| 3.12 | `os390-29.00-8561` |
| 3.13 | `os390-29.00-8561` |
| 3.14 | `zos` |

The port now ships a build that recognises both, so 3.12, 3.13 and 3.14 all
work. If you see that error, you are on an older binary — reinstall with
`zopen install uv`.

(The same split shows up in wheel filenames — 3.12 and 3.13 build
`os390_29_00_8561` wheels while 3.14 builds `zos` ones — which is why the index
retags them.)

### uv cannot install interpreters

`uv python install` fetches python-build-standalone builds, which are not
published for this platform:

```
$ uv python install 3.12
error: No download found for request: cpython-3.12-zos-s390x-none
```

Use the interpreters already on the system; `uv python list` finds them.

### Keep the cache off a small filesystem

uv defaults its cache under `$HOME`, which is often far smaller than `/tmp`
here. The same warning as for pip applies, and for the same reason — set
`UV_CACHE_DIR`.

## Package-specific notes

### watchfiles

The default file watcher detects nothing on z/OS. It starts, runs, and never
fires — no error. z/OS has no inotify/kqueue equivalent, so the polling backend
is the one that works, and it has to be asked for:

```sh
export WATCHFILES_FORCE_POLLING=true
```

`zopen install watchfiles` sets this in the port's environment. If you install
the wheel from the index instead, set it yourself, or pass
`force_polling=True` to `watch()`.

## Two separate channels

zopen ships Python packages two ways, and they are not the same catalogue:

| | `pip install` from the index | `zopen install` |
|---|---|---|
| what you get | a wheel, per interpreter | a pax, installed into the zopen tree |
| interpreters | the one you install into | all supported ones share the install |
| dependencies | resolved by pip from PyPI | zopen ports only |

Everything on this page concerns the first. `zopen install <name>` is the
second, and it does not consult `PIP_CONSTRAINT` or the wheel index at all.

## When something is missing

If a package you need is not in the index, it either has not been ported or
cannot be. [Python candidate status](/Guides/PythonCandidates) records which,
measured by actually attempting the install on z/OS rather than inferred from
metadata. [Contributing Python packages](/Guides/PythonContributing) covers the
community workflow for adding one, and
[Porting Python packages](/Guides/PythonPorting) covers the build mechanics.

## Reporting problems and giving feedback

Report against the port rather than here. Each ported tool and each ported
package has its own repository named `<name>port`, and its issue tracker is
what the people maintaining that port actually watch:

| what went wrong | where it goes |
|---|---|
| a tool misbehaves — `uv`, `pip`, an interpreter | that tool's port repo |
| a wheel is broken, stale, or missing from the index | that package's port repo |
| something on this page is wrong or out of date | [meta issues](https://github.com/zopencommunity/meta/issues) |
| a question, or you cannot tell which of the above it is | [meta discussions](https://github.com/zopencommunity/meta/discussions) |

So a uv problem goes to
[uvport](https://github.com/zopencommunity/uvport/issues) and a watchfiles
problem to
[watchfilesport](https://github.com/zopencommunity/watchfilesport/issues) —
`https://github.com/zopencommunity/<name>port/issues` in general.

Most port repositories have Issues enabled but not Discussions, so anything
conversational belongs in
[meta discussions](https://github.com/zopencommunity/meta/discussions) or the
[System Z Enthusiasts Discord](https://discord.com/invite/sze).

A report is far easier to act on with the output of `zopen version`, the
interpreter (`python3 -VV`), and the failing command with its full output — the
z/OS-specific failures on this page tend to look like ordinary dependency
errors, so the raw text matters.
