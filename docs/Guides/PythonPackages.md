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
