#!/bin/bash
# Title: Add Copilot review instructions to a single repo
#
# Executed by multi-gitter inside each cloned *port repo — do NOT run directly.
# multi-gitter clones the target repo, runs this script at its root, commits
# any changes, and opens a PR. The REPOSITORY env var is set by multi-gitter.
#
# To run manually via multi-gitter:
#   multi-gitter --config ./cicd/multi-gitter-config \
#                --branch copilot-instructions \
#                --pr-title "Add Copilot review instructions" \
#                run ./bulk-utils/rollout_copilot_instructions.sh

set -euo pipefail

INSTRUCTIONS_IN_REPO=".github/copilot-instructions.md"
# COPILOT_INSTRUCTIONS_TEMPLATE may be injected by the workflow as an absolute path.
# Fall back to dirname-based resolution for local/manual runs.
COPILOT_INSTRUCTIONS_TEMPLATE="${COPILOT_INSTRUCTIONS_TEMPLATE:-"$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../data/copilot-instructions.md"}"

# Skip if already up to date
if [ -f "$INSTRUCTIONS_IN_REPO" ] && diff -q "$COPILOT_INSTRUCTIONS_TEMPLATE" "$INSTRUCTIONS_IN_REPO" > /dev/null 2>&1; then
  echo "SKIP: $INSTRUCTIONS_IN_REPO is already up to date in ${REPOSITORY:-<unknown>}"
  exit 0
fi

# Keep repo-specific instructions a maintainer wrote by hand
if [ -f "$INSTRUCTIONS_IN_REPO" ] && ! grep -q "^# zopen port – review and coding instructions" "$INSTRUCTIONS_IN_REPO"; then
  echo "SKIP: ${REPOSITORY:-<unknown>} has its own $INSTRUCTIONS_IN_REPO"
  exit 0
fi

mkdir -p .github
cp "$COPILOT_INSTRUCTIONS_TEMPLATE" "$INSTRUCTIONS_IN_REPO"
echo "OK: wrote $INSTRUCTIONS_IN_REPO in ${REPOSITORY:-<unknown>}"
