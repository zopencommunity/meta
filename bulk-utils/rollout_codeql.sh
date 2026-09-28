#!/bin/bash
# Title: Add CodeQL workflow to a single repo
#
# Executed by multi-gitter inside each cloned *port repo — do NOT run directly.
# multi-gitter clones the target repo, runs this script at its root, commits
# any changes, and opens a PR. The REPOSITORY env var is set by multi-gitter.
#
# To run manually via multi-gitter:
#   multi-gitter --config ./cicd/multi-gitter-config \
#                --pr-title "Add CodeQL security scanning workflow" \
#                run ./bulk-utils/rollout_codeql.sh

set -euo pipefail

CODEQL_IN_REPO=".github/workflows/codeql.yml"
# CODEQL_TEMPLATE may be injected by the workflow as an absolute path.
# Fall back to dirname-based resolution for local/manual runs.
CODEQL_TEMPLATE="${CODEQL_TEMPLATE:-"$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../data/codeql-workflow.yml"}"

# Skip if already up to date
if [ -f "$CODEQL_IN_REPO" ] && diff -q "$CODEQL_TEMPLATE" "$CODEQL_IN_REPO" > /dev/null 2>&1; then
  echo "SKIP: $CODEQL_IN_REPO is already up to date in ${REPOSITORY:-<unknown>}"
  exit 0
fi

mkdir -p .github/workflows
cp "$CODEQL_TEMPLATE" "$CODEQL_IN_REPO"
echo "OK: wrote $CODEQL_IN_REPO in ${REPOSITORY:-<unknown>}"
