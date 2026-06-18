#!/bin/bash

# Title: List all Sanjana-Kondalwade repositories with 'port' in their name
#
# This script shows which repositories will be affected by the CodeQL rollout
# without making any changes.
#
# Usage: ./bulk-utils/list-sanjana-repos.sh

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}CodeQL Rollout - Target Repositories${NC}"
echo -e "${BLUE}Sanjana-Kondalwade Organization${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}GitHub CLI (gh) is not installed.${NC}"
    echo ""
    echo -e "${YELLOW}Based on the configuration:${NC}"
    echo -e "  - Organization: Sanjana-Kondalwade"
    echo -e "  - Pattern: Repositories containing 'port'"
    echo -e "  - Excluded: meta"
    echo ""
    echo -e "${YELLOW}Install gh with:${NC}"
    echo -e "  macOS: brew install gh"
    echo -e "  Linux: See https://github.com/cli/cli#installation"
    echo ""
    exit 1
fi

echo -e "${GREEN}Fetching repositories from Sanjana-Kondalwade...${NC}"
echo ""

# Fetch all repos containing 'port'
REPOS=$(gh repo list Sanjana-Kondalwade --limit 1000 --json name,isArchived,isFork --jq '.[] | select(.name | contains("port")) | select(.isArchived == false) | .name')

# Skip list
SKIP_REPOS=(
    "meta"
)

# Count and display
TOTAL=0
SKIPPED=0

echo -e "${BLUE}Repositories that will receive CodeQL workflow:${NC}"
echo -e "${BLUE}------------------------------------------------${NC}"

while IFS= read -r repo; do
    if [ -z "$repo" ]; then
        continue
    fi
    
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
        echo "  ✓ Sanjana-Kondalwade/$repo"
        ((TOTAL++))
    fi
done <<< "$REPOS"

echo ""
echo -e "${BLUE}------------------------------------------------${NC}"
echo -e "${GREEN}Total repositories to process: ${TOTAL}${NC}"

if [ $SKIPPED -gt 0 ]; then
    echo -e "${YELLOW}Skipped repositories: ${SKIPPED}${NC}"
fi

echo ""

# Show skipped repos
if [ $SKIPPED -gt 0 ]; then
    echo -e "${YELLOW}Skipped repositories:${NC}"
    while IFS= read -r repo; do
        if [ -z "$repo" ]; then
            continue
        fi
        for skip_repo in "${SKIP_REPOS[@]}"; do
            if [[ "$repo" == "$skip_repo" ]]; then
                echo "  ✗ Sanjana-Kondalwade/$repo (in skip list)"
            fi
        done
    done <<< "$REPOS"
    echo ""
fi

echo -e "${BLUE}Configuration details:${NC}"
echo -e "  - Pattern: .*port.* (repos containing 'port')"
echo -e "  - Organization: Sanjana-Kondalwade"
echo -e "  - Concurrent processing: 3 repos at a time"
echo -e "  - Branch name: add-codeql-workflow"
echo -e "  - Reusable workflow: Sanjana-Kondalwade/meta/.github/workflows/codeql.yml@main"
echo ""

echo -e "${GREEN}To proceed with rollout:${NC}"
echo -e "  1. Dry-run: ./bulk-utils/rollout-codeql-sanjana.sh --dry-run"
echo -e "  2. Full rollout: ./bulk-utils/rollout-codeql-sanjana.sh"
echo ""

echo -e "${YELLOW}Prerequisites:${NC}"
echo -e "  - GitHub token with repo access: export GITHUB_TOKEN=your_token"
echo -e "  - multi-gitter installed: go install github.com/lindell/multi-gitter@latest"
echo ""

# Made with Bob
