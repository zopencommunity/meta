#!/bin/bash

# Title: CodeQL rollout to Sanjana-Kondalwade repositories with 'port' in name
#
# This script performs the rollout of CodeQL workflows to all repositories
# containing 'port' in their name in the Sanjana-Kondalwade organization.
#
# Usage: ./bulk-utils/rollout-codeql-sanjana.sh [--dry-run]

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}CodeQL Rollout for Sanjana-Kondalwade${NC}"
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

# Parse command line arguments
DRY_RUN=false
if [ "$1" == "--dry-run" ]; then
    DRY_RUN=true
    echo -e "${YELLOW}Running in DRY-RUN mode - no changes will be made${NC}"
    echo ""
fi

# Configuration file
CONFIG_FILE="bulk-utils/codeql-sanjana-config"

if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}Error: Configuration file not found: ${CONFIG_FILE}${NC}"
    exit 1
fi

echo -e "${GREEN}Using configuration: ${CONFIG_FILE}${NC}"
echo ""

# Show what will be affected
echo -e "${YELLOW}This will:${NC}"
echo -e "  - Target all repositories with 'port' in their name"
echo -e "  - In organization: Sanjana-Kondalwade"
echo -e "  - Create pull requests with CodeQL workflows"
echo -e "  - Process up to 3 repositories concurrently"
echo -e "  - Skip repositories already with CodeQL workflows"
echo ""

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}DRY-RUN: No actual changes will be made${NC}"
    echo ""
fi

# Estimate number of repositories
echo -e "${BLUE}Fetching repository count...${NC}"
if command -v gh &> /dev/null; then
    REPO_COUNT=$(gh repo list Sanjana-Kondalwade --limit 1000 --json name --jq '.[] | select(.name | contains("port")) | .name' | wc -l | tr -d ' ')
    echo -e "${GREEN}Found ${REPO_COUNT} repositories with 'port' in their name${NC}"
    echo ""
    echo -e "${BLUE}Repositories to be processed:${NC}"
    gh repo list Sanjana-Kondalwade --limit 1000 --json name --jq '.[] | select(.name | contains("port")) | .name' | while read repo; do
        echo -e "  ✓ Sanjana-Kondalwade/${repo}"
    done
    echo ""
else
    echo -e "${YELLOW}GitHub CLI (gh) not found. Cannot list repositories.${NC}"
    echo -e "${YELLOW}Install with: brew install gh${NC}"
    echo ""
fi

# Final confirmation
if [ "$DRY_RUN" = false ]; then
    echo -e "${RED}WARNING: This will create pull requests in the repositories listed above!${NC}"
    echo ""
    read -p "Are you sure you want to proceed? Type 'YES' to continue: " -r
    echo ""
    
    if [[ ! $REPLY == "YES" ]]; then
        echo -e "${RED}Rollout cancelled.${NC}"
        exit 0
    fi
    
    echo -e "${YELLOW}Starting rollout in 3 seconds... Press Ctrl+C to cancel${NC}"
    sleep 3
fi

# Prepare log file
LOG_FILE="codeql-sanjana-rollout-$(date +%Y%m%d-%H%M%S).log"
echo -e "${GREEN}Logging to: ${LOG_FILE}${NC}"
echo ""

# Build multi-gitter command
MULTI_GITTER_CMD="multi-gitter run ./bulk-utils/add_codeql_workflow_sanjana.sh --config $CONFIG_FILE --token $GITHUB_TOKEN"

if [ "$DRY_RUN" = true ]; then
    # Update config for dry-run
    TMP_CONFIG=$(mktemp)
    sed 's/dry-run: false/dry-run: true/' "$CONFIG_FILE" > "$TMP_CONFIG"
    MULTI_GITTER_CMD="multi-gitter run ./bulk-utils/add_codeql_workflow_sanjana.sh --config $TMP_CONFIG --token $GITHUB_TOKEN"
fi

# Run multi-gitter
echo -e "${GREEN}Starting CodeQL rollout...${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

$MULTI_GITTER_CMD 2>&1 | tee "$LOG_FILE"

EXIT_CODE=${PIPESTATUS[0]}

# Cleanup temp config if dry-run
if [ "$DRY_RUN" = true ] && [ -f "$TMP_CONFIG" ]; then
    rm "$TMP_CONFIG"
fi

echo ""
echo -e "${BLUE}========================================${NC}"

if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}Rollout completed successfully!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "1. Review the log file: ${LOG_FILE}"
    echo -e "2. Check created pull requests in GitHub"
    echo -e "3. Review and merge the PRs"
    echo -e "4. Monitor CodeQL scan results in Security tab"
    echo ""
    if [ -f "$LOG_FILE" ]; then
        echo -e "${GREEN}Summary:${NC}"
        echo -e "  - PRs created: $(grep -c "Created PR" "$LOG_FILE" 2>/dev/null || echo "0")"
        echo -e "  - Repositories skipped: $(grep -c "Skipping" "$LOG_FILE" 2>/dev/null || echo "0")"
        echo -e "  - Errors: $(grep -c "Error" "$LOG_FILE" 2>/dev/null || echo "0")"
    fi
else
    echo -e "${RED}Rollout encountered errors!${NC}"
    echo -e "${RED}========================================${NC}"
    echo ""
    echo -e "${YELLOW}Check the log file for details: ${LOG_FILE}${NC}"
    echo -e "${YELLOW}You may need to re-run for failed repositories${NC}"
fi

echo ""
exit $EXIT_CODE

# Made with Bob
