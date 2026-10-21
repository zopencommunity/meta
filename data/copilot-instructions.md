# zopen port – review and coding instructions

This repository is a zopen community port: it builds an upstream open source
project for z/OS UNIX with `zopen-build`. The upstream source is not stored here,
only `buildenv`, `patches/`, CI config and docs. Full guide:
https://zopen.community/Guides/Porting

## Review checklist (most important first)

1. **Never commit upstream source.** Extracted source directories
   (`<name>-*/`, `<name>/`) must be in `.gitignore`. Flag any PR that adds them.
2. **Changes to upstream code go in `patches/` as diffs**, generated with
   `git diff HEAD` in the extracted tree, and are listed in `patches/README.md`.
   Flag patches that are hand-edited, have rejected hunks, or carry unrelated
   changes. Prefer fixes that could be sent upstream.
3. **Guard z/OS-specific code** with `#ifdef __MVS__` (or `#if defined(__MVS__)`)
   so the patch stays upstreamable. Unguarded behaviour changes are a bug.
4. **`buildenv` is sourced by `/bin/sh`.** No bash-isms: no `[[ ]]`, `local`,
   arrays, `read -d`, or process substitution. Variable names use underscores,
   never hyphens (`PKG_NAME_VERSION`).
5. **Versions must not drift.** The version variable is defined before
   `ZOPEN_STABLE_URL`/`ZOPEN_STABLE_TAG` use it, `zopen_get_version` echoes that
   variable (not the template's `1.0.0`), and the `# bump:` pattern matches it.
6. **Dependencies are exact zopen package names** in `ZOPEN_STABLE_DEPS`
   (e.g. `check_python`, not `python`; `check_go`, not `go`). Reference a
   dependency's install root as `${<DEP>_HOME}`, not a hardcoded path.
7. **Test results must be honest.** `zopen_check_results` must sum counts across
   all runs/interpreters, must not treat a single `OK` as success, and must count
   a run that produced no output as a failure. `grep -c … || echo 0` is a bug
   (grep already prints 0).
8. **No secrets, tokens or internal hostnames** in buildenv, scripts or docs.

## z/OS facts to apply

- Text files may be ASCII (tagged ISO8859-1) or untagged EBCDIC. Do not "fix"
  encoding by rewriting a file; preserve its tag (`chtag`). Binaries use `chtag -b`.
- z/OS is big-endian. Question code that assumes little-endian layouts,
  bit-packing, or byte order in file formats, hashes and checksums.
- z/OS `/bin/find` has no `-path`; `/bin/grep` has no `-o`. GNU tools are only
  guaranteed inside `zopen-build` when declared as dependencies.
- Missing symbols in shared objects usually need `-fvisibility=default` or a
  visibility attribute, not exporting everything by hand.
- Install paths come from `${ZOPEN_INSTALL_DIR}`; never write to `/usr/local`.

## When writing code (Copilot coding agent)

- Keep changes minimal and in `buildenv`/`patches/`; explain each patch in
  `patches/README.md`.
- Do not claim a build or test passed unless CI ran it on z/OS.
