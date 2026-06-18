#!/bin/bash

# Title: Test CodeQL rollout on YOUR forked repositories
#
# This script applies CodeQL workflows to your forked repositories
# for testing before applying to the main zopen community.
#
# Usage: ./bulk-utils/fork-test-rollout.sh

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}CodeQL Fork Test Rollout${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if multi-gitter is installed
if ! command -v multi-gitter &> /dev/null; then
    echo -e "${RED}Error: multi-gitter is not installed${NC}"
    echo -e "${YELLOW}Install it with: go install github.com/lindell/multi-gitter@latest${NC}"
    exit 1
fi

# Check for GITHUB_TOKEN
if [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${RED}Error: GITHUB_TOKEN environment variable is not set${NC}"
    echo -e "${YELLOW}Set it with: export GITHUB_TOKEN=your_token_here${NC}"
    exit 1
fi

# Configuration
YOUR_USERNAME="Sanjana-Kondalwade"
CONFIG_FILE="bulk-utils/codeql-fork-test-config"

echo -e "${GREEN}Testing on YOUR forked repositories${NC}"
echo -e "  Username: ${YOUR_USERNAME}"
echo -e "  Pattern: Repositories ending with 'port'"
echo -e "  Type: User account (not organization)"
echo ""

# Check if config exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}Error: Configuration file not found: ${CONFIG_FILE}${NC}"
    exit 1
fi

# Show what repos will be affected
echo -e "${YELLOW}Fetching your forked repositories...${NC}"
if command -v gh &> /dev/null; then
    REPO_COUNT=$(gh repo list $YOUR_USERNAME --limit 100 --json name --jq '.[] | select(.name | endswith("port")) | .name' | wc -l)
    echo -e "${GREEN}Found ${REPO_COUNT} repositories ending with 'port'${NC}"
    echo ""
    echo -e "${BLUE}Repositories that will be processed:${NC}"
    gh repo list $YOUR_USERNAME --limit 100 --json name --jq '.[] | select(.name | endswith("port")) | .name' | while read repo; do
        echo "  ✓ ${YOUR_USERNAME}/${repo}"
    done
    echo ""
else
    echo -e "${YELLOW}GitHub CLI not installed. Will process all repos matching pattern.${NC}"
    echo ""
fi

# Confirmation
echo -e "${YELLOW}This will create pull requests in YOUR forked repositories.${NC}"
echo -e "${YELLOW}These are YOUR repos, so you have full control.${NC}"
echo ""
read -p "Do you want to continue? (yes/no): " -r
echo ""

if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo -e "${RED}Fork test rollout cancelled.${NC}"
    exit 0
fi

# Run multi-gitter with the fork-specific script
echo -e "${GREEN}Starting CodeQL rollout on your forks...${NC}"
echo -e "${YELLOW}Using YOUR meta fork (Sanjana-Kondalwade/meta)${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

multi-gitter run ./bulk-utils/add_codeql_workflow_fork.sh \
    --config "$CONFIG_FILE" \
    --token "${GITHUB_TOKEN}" 2>&1 | tee codeql-fork-test.log

EXIT_CODE=${PIPESTATUS[0]}

echo ""
echo -e "${BLUE}========================================${NC}"

if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}Fork test rollout completed successfully!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "1. Check the PRs created in your forked repositories"
    echo -e "2. Review the log file: codeql-fork-test.log"
    echo -e "3. Merge the PRs in your forks"
    echo -e "4. Verify CodeQL workflows run successfully"
    echo -e "5. Once verified, you can propose this to zopen community"
    echo ""
    echo -e "${GREEN}Summary:${NC}"
    echo -e "  - PRs created: $(grep -c "Created PR" codeql-fork-test.log || echo "0")"
    echo -e "  - Repositories processed: $(grep -c "Processing" codeql-fork-test.log || echo "0")"
else
    echo -e "${RED}Fork test rollout encountered errors!${NC}"
    echo -e "${RED}========================================${NC}"
    echo ""
    echo -e "${YELLOW}Check the log file: codeql-fork-test.log${NC}"
fi

echo ""
exit $EXIT_CODE

# Made with Bob
