# zopen meta – review and coding instructions

This repository holds the zopen package manager and build framework (`bin/`,
`include/`), CI/CD, bulk utilities, data templates and the zopen.community site
(`docs/`). The scripts run on z/OS UNIX, so portability rules matter more than
style.

## Review checklist (most important first)

1. **Scripts in `bin/` and `include/` are `#!/bin/sh` and run on z/OS.**
   Flag bash-isms: `[[ ]]`, `local`, arrays, `${var//x/y}`, `read -d`,
   process substitution, `echo -e`. Use `printf` for anything non-trivial.
2. **z/OS utilities differ from GNU.** `/bin/find` has no `-path`, `/bin/grep`
   has no `-o`, `sed -i` is not portable. Prefer the helpers in
   `include/common.sh` (`zossed`, `zosfind`, `printDebug`, `printError`,
   `printVerbose`, `runAndLog`, `mktempfile`) over raw commands.
3. **Unbalanced `)` inside `$( )` breaks the z/OS shell** (FSUM7332), even
   when quoted. Flag `$(... | sed 's/)//')`-style code.
4. **Encoding and tags.** Files may be ASCII (tagged ISO8859-1) or untagged
   EBCDIC. New or rewritten files must keep the right tag (`chtag`); binaries
   are tagged binary. Do not "fix" encoding by rewriting content.
5. **Backward compatibility.** `zopen-build` sources hundreds of port
   `buildenv` files. Changing a variable name, default, or function contract
   breaks ports silently; ask for a migration path or a release note.
6. **No secrets, tokens, internal hostnames or raw IP addresses** in code,
   docs or generated data. Public URLs use `zopen.community` and
   `repo.zopen.community`.
7. **Generated files are not edited by hand:** `docs/api/*.json`,
   `docs/newly_released.md`, `docs/reference/`. Change the generator under
   `tools/` or `cicd/` instead.
8. **Workflows** declare least-privilege `permissions`, never check out PR code
   under `pull_request_target`, and pin third-party actions to a version.

## Python tools (`tools/`)

- Python 3.9+ standard library first (`urllib`, `json`, `argparse`); keep pure
  functions separate from network calls and cover them in `tools/test_*.py`
  (`python3 -m unittest`).

## Docs (`docs/`)

- Commands in docs must work as written on z/OS. Install examples use
  `zopen install <pkg>`, `pip`/`uv` with the zopen index, or `dnf5`.

## When writing code (Copilot coding agent)

- Keep PRs small and say what was tested. Do not claim something was tested
  on z/OS unless it was.
