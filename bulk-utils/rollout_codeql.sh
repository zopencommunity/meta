#!/bin/bash
# Title: Roll out CodeQL workflow to all *port repos using gh CLI
#
# Usage (local):
#   GITHUB_TOKEN=<token> ./bulk-utils/rollout_codeql.sh
#
# In CI the GITHUB_TOKEN env var is injected automatically.

set -euo pipefail

# Register gh as git's credential helper so git push authenticates via GH_TOKEN
# without embedding the token in any URL (avoids Vault Radar secret scanning blocks)
gh auth setup-git

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODEQL_FILE="$SCRIPT_DIR/../data/codeql-workflow.yml"
CODEQL_IN_REPO=".github/workflows/codeql.yml"

ORG="zopencommunity"
BRANCH="add-codeql-workflow"
PR_TITLE="Add CodeQL security scanning workflow"
PR_BODY="This PR adds CodeQL security scanning to the repository.

## Changes
- Adds \`.github/workflows/codeql.yml\` workflow that calls the centralized CodeQL workflow from \`zopencommunity/meta\`

## Benefits
- Automated security vulnerability detection
- Code quality analysis
- Runs on push, pull requests, and weekly schedule

The workflow uses the reusable workflow pattern, making it easy to maintain and update across all repositories."

SKIP_REPOS=(
  "zopencommunity/meta"
)

PRIORITY_REPOS=(
  "zopencommunity/gitport"
  "zopencommunity/makeport"
  "zopencommunity/curlport"
  "zopencommunity/gpgport"
  "zopencommunity/pinentryport"
  "zopencommunity/perlport"
  "zopencommunity/lessport"
  "zopencommunity/ncursesport"
  "zopencommunity/rpmport"
  "zopencommunity/dnf5port"
  "zopencommunity/vimport"
  "zopencommunity/autoconfport"
)

MAX_REPOS=50

should_skip() {
  local repo="$1"
  for skip in "${SKIP_REPOS[@]}"; do
    [[ "$skip" == "$repo" ]] && return 0
  done
  return 1
}

is_priority() {
  local repo="$1"
  for p in "${PRIORITY_REPOS[@]}"; do
    [[ "$p" == "$repo" ]] && return 0
  done
  return 1
}

echo "Fetching *port repos from $ORG..."
ALL_REPOS=$(gh repo list "$ORG" --limit 300 --json nameWithOwner --jq '.[].nameWithOwner' | grep 'port$')

# Build final list: priority repos first, then fill remaining slots from the full list
ORDERED_REPOS=()
for repo in "${PRIORITY_REPOS[@]}"; do
  ORDERED_REPOS+=("$repo")
done
REMAINING=$(( MAX_REPOS - ${#PRIORITY_REPOS[@]} ))
COUNT=0
for repo in $ALL_REPOS; do
  (( COUNT >= REMAINING )) && break
  if ! is_priority "$repo"; then
    ORDERED_REPOS+=("$repo")
    (( COUNT++ )) || true
  fi
done

echo "Repos to process: ${#ORDERED_REPOS[@]}"
printf '%s\n' "${ORDERED_REPOS[@]}"
echo ""

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

SUCCESS=0
SKIPPED=0
FAILED=0

for REPO in "${ORDERED_REPOS[@]}"; do
  if should_skip "$REPO"; then
    echo "SKIP (excluded): $REPO"
    (( SKIPPED++ )) || true
    continue
  fi

  echo "--- Processing $REPO ---"
  REPO_DIR="$TMPDIR/$(basename "$REPO")"

  # Clone shallow — authenticates via gh token
  if ! gh repo clone "$REPO" "$REPO_DIR" -- --depth=1 --quiet 2>&1; then
    echo "SKIP (clone failed): $REPO"
    (( FAILED++ )) || true
    continue
  fi

  cd "$REPO_DIR"

  # Skip if workflow already exists and is up to date
  if [ -f "$CODEQL_IN_REPO" ] && diff -q "$CODEQL_FILE" "$CODEQL_IN_REPO" > /dev/null 2>&1; then
    echo "SKIP (already up to date): $REPO"
    (( SKIPPED++ )) || true
    cd "$TMPDIR"
    continue
  fi

  # Create or switch to branch
  git checkout -b "$BRANCH" 2>/dev/null || git checkout "$BRANCH"

  # Copy workflow file
  mkdir -p .github/workflows
  cp "$CODEQL_FILE" "$CODEQL_IN_REPO"

  # Stage and commit
  git add "$CODEQL_IN_REPO"
  if ! git diff --cached --quiet; then
    git commit -m "Add CodeQL security scanning workflow"

    # Push using gh as a credential helper — no token in URL, no Vault Radar trigger
    git push origin "$BRANCH" --force

    # Open PR against main
    if gh pr create \
        --repo "$REPO" \
        --head "$BRANCH" \
        --base main \
        --title "$PR_TITLE" \
        --body "$PR_BODY" 2>&1; then
      echo "OK: PR created for $REPO"
      (( SUCCESS++ )) || true
    else
      echo "FAILED (pr create): $REPO"
      (( FAILED++ )) || true
    fi
  else
    echo "SKIP (no changes): $REPO"
    (( SKIPPED++ )) || true
  fi

  cd "$TMPDIR"
done

echo ""
echo "=== Rollout summary ==="
echo "  Created PRs : $SUCCESS"
echo "  Skipped     : $SKIPPED"
echo "  Failed      : $FAILED"
