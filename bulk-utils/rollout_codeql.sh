#!/bin/bash
# Title: Roll out CodeQL workflow to all *port repos using gh CLI
#
# Usage (local):
#   GITHUB_TOKEN=<token> ./bulk-utils/rollout_codeql.sh
#
# In CI the GITHUB_TOKEN env var is injected automatically.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODEQL_FILE="$SCRIPT_DIR/../data/codeql-workflow.yml"
CODEQL_IN_REPO=".github/workflows/codeql.yml"

# Target user account for testing. Change to ORG="zopencommunity" for real rollout.
USER="Sanjana-Kondalwade"
BRANCH="add-codeql-workflow"
PR_TITLE="Add CodeQL security scanning workflow"
PR_BODY="This PR adds CodeQL security scanning to the repository.

## Changes
- Adds \`.github/workflows/codeql.yml\` workflow that calls the centralized CodeQL workflow from \`Sanjana-Kondalwade/meta\`
- Adds CodeQL badge to README.md

## Benefits
- Automated security vulnerability detection
- Code quality analysis
- Runs on push, pull requests, and weekly schedule

The workflow uses the reusable workflow pattern, making it easy to maintain and update across all repositories."

SKIP_REPOS=(
  "Sanjana-Kondalwade/meta"
)

should_skip() {
  local repo="$1"
  for skip in "${SKIP_REPOS[@]}"; do
    [[ "$skip" == "$repo" ]] && return 0
  done
  return 1
}

echo "Fetching *port repos from $USER..."
REPOS=$(gh repo list "$USER" --limit 300 --json nameWithOwner --jq '.[].nameWithOwner' | grep 'port$')
echo "Repos found: $(echo "$REPOS" | wc -w)"
echo "$REPOS"
echo ""

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

SUCCESS=0
SKIPPED=0
FAILED=0

for REPO in $REPOS; do
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

  # Add badge to README.md if missing
  if [ -f README.md ] && ! grep -q "CodeQL" README.md 2>/dev/null; then
    LINE="[![CodeQL](https://github.com/$REPO/actions/workflows/codeql.yml/badge.svg)](https://github.com/$REPO/actions/workflows/codeql.yml)"
    printf '%s\n\n' "$LINE" | cat - README.md > tmpfile && mv tmpfile README.md
    echo "Added CodeQL badge to README.md"
  fi

  # Stage and commit
  git add "$CODEQL_IN_REPO" README.md 2>/dev/null || git add "$CODEQL_IN_REPO"
  if ! git diff --cached --quiet; then
    git commit -m "Add CodeQL security scanning workflow"

    # Push directly to the user's own repo (no fork needed for personal account)
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
