#!/bin/bash

# Title: List all repositories that will be targeted by CodeQL rollout
#
# This script shows which repositories will be affected by the rollout
# without making any changes.
#
# Usage: ./bulk-utils/list-target-repos.sh

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}CodeQL Rollout - Target Repositories${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${YELLOW}GitHub CLI (gh) is not installed.${NC}"
    echo -e "${YELLOW}Install it to see the exact list of repositories.${NC}"
    echo ""
    echo -e "${YELLOW}Based on the configuration:${NC}"
    echo -e "  - Organization: zopencommunity"
    echo -e "  - Pattern: Repositories ending with 'port'"
    echo -e "  - Excluded: zotsampleport, meta"
    echo ""
    echo -e "${YELLOW}Install gh with: brew install gh${NC}"
    exit 1
fi

echo -e "${GREEN}Fetching repositories from zopencommunity...${NC}"
echo ""

# Fetch all repos ending with 'port'
REPOS=$(gh repo list zopencommunity --limit 1000 --json name,isArchived,isFork --jq '.[] | select(.name | endswith("port")) | select(.isArchived == false) | .name')

# Skip list from config
SKIP_REPOS=(
    "zotsampleport"
    "meta"
)

# Count and display
TOTAL=0
SKIPPED=0

echo -e "${BLUE}Repositories that will receive CodeQL workflow:${NC}"
echo -e "${BLUE}------------------------------------------------${NC}"

while IFS= read -r repo; do
    # Check if in skip list
    SKIP=false
    for skip_repo in "${SKIP_REPOS[@]}"; do
        if [[ "$repo" == "$skip_repo" ]]; then
            SKIP=true
            ((SKIPPED++))
            break
        fi
    done
    
    if [ "$SKIP" = false ]; then
        echo "  ✓ zopencommunity/$repo"
        ((TOTAL++))
    fi
done <<< "$REPOS"

echo ""
echo -e "${BLUE}------------------------------------------------${NC}"
echo -e "${GREEN}Total repositories to process: ${TOTAL}${NC}"
echo -e "${YELLOW}Skipped repositories: ${SKIPPED}${NC}"
echo ""

# Show skipped repos
if [ $SKIPPED -gt 0 ]; then
    echo -e "${YELLOW}Skipped repositories:${NC}"
    while IFS= read -r repo; do
        for skip_repo in "${SKIP_REPOS[@]}"; do
            if [[ "$repo" == "$skip_repo" ]]; then
                echo "  ✗ zopencommunity/$repo (in skip list)"
            fi
        done
    done <<< "$REPOS"
    echo ""
fi

echo -e "${BLUE}Configuration details:${NC}"
echo -e "  - Pattern: .*port$ (repos ending with 'port')"
echo -e "  - Organization: zopencommunity"
echo -e "  - Concurrent processing: 5 repos at a time"
echo -e "  - Branch name: codeql-security-scanning"
echo ""

echo -e "${GREEN}To proceed with rollout:${NC}"
echo -e "  1. Test: ./bulk-utils/test-codeql-rollout.sh"
echo -e "  2. Dry-run: ./bulk-utils/rollout-codeql.sh --dry-run"
echo -e "  3. Full rollout: ./bulk-utils/rollout-codeql.sh"
echo ""

# Made with Bob
