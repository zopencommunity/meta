# Documentation of Recent Changes (May 2026)

This document summarizes the significant changes made to the `zopen` tools recently, focusing on RPM generation, Pulp integration, and dependency management improvements.

## 1. `zopen-pax2rpm` Refactoring and Improvements

The `zopen-pax2rpm` tool, used for generating RPM spec files and building RPMs from pax archives, has undergone a major overhaul:

- **Portability:** Switched shebang from `#!/bin/bash` to `#!/bin/sh`.
- **Consistency:** Integrated `setupMyself` to align with other `zopen` scripts and source `common.sh`.
- **Platform Support:** 
    - Improved architecture detection for z/OS, correctly mapping numeric machine types to `s390x`.
    - Added `%define __os_install_post %{nil}` to spec files on z/OS to prevent broken post-install processing (like stripping).
- **Robust Parsing:**
    - Improved filename parsing to handle `.zos` suffixes and avoid bash-specific syntax.
    - Enhanced pax archive analysis with higher entry limits (up to 5000) and more robust directory structure detection.
- **Improved Build Environment:**
    - Better handling of `~/.rpmmacros` and `_topdir`.
    - Uses `--define "_topdir ..."` in `rpmbuild` commands for better isolation.
- **User Interface:**
    - Added `--pkg-version` and `--version` options.
    - Improved error messages and dependency checking.

## 2. Pulp Integration for RPM Publishing

Support for the Pulp repository manager has been added to the publishing workflow:

- **`zopen-publish`**:
    - New options: `--pulp` (enable Pulp upload) and `--pulp-repo <repo>` (specify target repository).
    - Automatic detection of RPM files in common build locations (`rpmbuild/RPMS` or the same directory as the pax file).
    - New `uploadToPulp` function to handle the interaction with the Pulp CLI.
- **`cicd/publish.groovy`**:
    - Updated Jenkins pipeline to automatically push RPMs to the appropriate Pulp repository (`zopen-stable` or `zopen-dev`) during the release process.

## 3. Binary-Only Dependency Support (`:bin`)

A new mechanism for handling binary-only dependencies has been introduced to `zopen-build`:

- **Syntax:** Dependencies can now be specified with a `:bin` suffix (e.g., `git:bin`).
- **Behavior:** `:bin` dependencies are intended for tools that are only needed for execution (relying on `bin/` and `share/`), rather than for linking or compiling against.
- **`zopen-build` Changes:**
    - Refactored environment sourcing (`setDepsEnv`) to handle `:bin` dependencies by temporarily unsetting `ZOPEN_IN_ZOPEN_BUILD`.
    - Added `normalizeDeps` logic to prefer full packages if both full and `:bin` versions of the same package are requested.
- **Environment Protection:**
    - Modified `.env` generation to wrap `PKG_CONFIG_PATH` updates in a check for `ZOPEN_IN_ZOPEN_BUILD`. This prevents build-time environment variables from leaking into the runtime environment of `:bin` dependencies.

## 4. Shared Library Updates (`include/common.sh`)

New utility functions were added to `common.sh` to support the new dependency logic:
- `parseDeps`: Now correctly handles the `:bin` suffix and extracts it as a property.
- `normalizeDeps`: Deduplicates and prioritizes dependencies, ensuring a consistent environment.

## 5. Automated Reports

- **`docs/upstreamstatus.md`**: The Upstream Patch Status Report has been updated with the latest data on project patches and historical trends.
