# Using Python packages on z/OS

How to install Python packages that zopen builds for z/OS, and the three ways a
normal `pip install` goes wrong here.

Everything on this page has been checked on z/OS against Python 3.12, 3.13 and
3.14.

## The short version

```sh
export PIP_EXTRA_INDEX_URL="https://repo.zopen.community/pypi/wheels/simple/"
export PIP_CONSTRAINT="https://repo.zopen.community/pulp/content/constraints/zopen-constraints.txt"

python3 -m venv --system-site-packages .venv
. .venv/bin/activate

pip install cryptography
```

All three lines are load-bearing. Drop any one of them and the install fails —
or, worse, appears to succeed and gives you something else. The rest of this
page explains each, because the failures are quiet and none of them says what
is actually wrong.

## Why `--system-site-packages`

The z/OS interpreters ship with packages that PyPI would normally supply, and
some of those **cannot be installed from PyPI here at all**. `cffi` is the one
that matters: it ships only an sdist for this platform, and building it needs
libffi headers that z/OS does not have.

```
ERROR: Failed building wheel for cffi
```

A plain `python3 -m venv` hides the interpreter's copy, so anything depending
on `cffi` — `cryptography`, and most packages wrapping a C library — cannot be
installed into one, whatever index or constraints you configure. Creating the
environment with `--system-site-packages` lets it see what the interpreter
already has.

Bundled versions, for reference:

| package | 3.12 | 3.13 | 3.14 |
|---|---|---|---|
| `cffi` | 1.17.1 | 2.0.0 | 2.0.0 |
| `cryptography` | 3.3.2 | 3.3.2 | 3.3.2 |

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

It reaches the wheel index and installs from it correctly, and it is
substantially faster than pip. Two limits decide whether it is usable for a
given job:

- **Python 3.12 and 3.13 only.** uv cannot use 3.14 at all.
- **Nothing that depends on `cffi`**, which rules out `cryptography`, `pynacl`
  and `paramiko`.

Both are explained below. Where either applies, use pip.

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
uv pip install --python .venv/bin/python msgpack
```

`UV_INDEX` rather than `UV_EXTRA_INDEX_URL`: uv accepts the latter but reports
it as deprecated in favour of `--index`.

### uv will not use the interpreter's bundled packages

This is the important difference, and it is why `cffi` is fatal here.

pip treats a package already present in the environment as satisfying a
requirement — which is what makes `--system-site-packages` work, and why the
`cffi` that ships with the interpreter is usable at all. uv resolves against the
index instead and installs its own copy regardless of what is already there.

So `uv venv --system-site-packages` creates the environment, and uv then ignores
the contents:

```
$ uv pip install --python .venv/bin/python cryptography
Resolved 3 packages
   Building cffi==2.1.1
  × Failed to build `cffi==2.1.1`
      _configtest.c:1:1: error: thread-local storage is not supported for the
      current target
  help: `cffi` (v2.1.1) was included because `cryptography` (v50.0.0) depends on it
```

uv found the zopen wheel for `cryptography` correctly — the failure is entirely
`cffi`, which has no z/OS wheel and cannot be compiled here. Adding
`UV_CONSTRAINT` does not change it, and neither does
`--system-site-packages`. With that flag the environment is left holding the
interpreter's `cryptography` 3.3.2 — the 2021 release with the
certificate-validation CVEs — so **check the version afterwards rather than
trusting the exit status**. Without it the install simply leaves no
`cryptography` at all, which at least fails honestly.

Everything without a `cffi` dependency installs normally.

### uv does not work with Python 3.14

uv reads the interpreter's platform and does not recognise the one 3.14 reports:

```
$ uv venv --python /path/to/python3.14 .venv
error: Failed to inspect Python interpreter
  Caused by: Unknown operating system: `zos`
```

The interpreters disagree about what to call this platform:

| interpreter | `sysconfig.get_platform()` |
|---|---|
| 3.12 | `os390-29.00-8561` |
| 3.13 | `os390-29.00-8561` |
| 3.14 | `zos` |

uv understands the `os390` form and not the bare `zos` one, so 3.12 and 3.13
work and 3.14 does not. It fails when the environment is created, so there is no
risk of it half-working. Use pip on 3.14.

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
metadata. [Porting Python packages](/Guides/PythonPorting) covers adding one.
