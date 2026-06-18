#!/bin/bash

# Delete old CodeQL branches from previous rollout attempts
# This allows multi-gitter to create fresh PRs with updated workflows

REPOS=(
  "rsyncport"
  "cmakeport"
  "vimport"
  "makeport"
  "tigport"
  "gitport"
  "sedport"
)

echo "Deleting old codeql-security-scanning branches..."
echo ""

for repo in "${REPOS[@]}"; do
  echo "Processing $repo..."
  gh api -X DELETE /repos/Sanjana-Kondalwade/$repo/git/refs/heads/codeql-security-scanning 2>/dev/null
  if [ $? -eq 0 ]; then
    echo "  ✓ Branch deleted in $repo"
  else
    echo "  ℹ Branch not found or already deleted in $repo"
  fi
done

echo ""
echo "Done! Old branches deleted."
echo ""
echo "Next steps:"
echo "1. Close the old PRs manually on GitHub (if still open)"
echo "2. Run: ./bulk-utils/fork-test-rollout.sh"
echo ""

# Made with Bob
