#!/bin/bash

# Title: Test CodeQL rollout on a small set of repositories
#
# This script helps test the CodeQL rollout on 5 repositories before
# applying it to all 300+ repositories in the zopen community.
#
# Usage: ./bulk-utils/test-codeql-rollout.sh

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}CodeQL Rollout Test Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if multi-gitter is installed
if ! command -v multi-gitter &> /dev/null; then
    echo -e "${RED}Error: multi-gitter is not installed${NC}"
    echo -e "${YELLOW}Install it with: go install github.com/lindell/multi-gitter@latest${NC}"
    exit 1
fi

# Test repositories (5 diverse repos for testing)
TEST_REPOS=(
    "zopencommunity/curlport"
    "zopencommunity/gitport"
    "zopencommunity/vimport"
    "zopencommunity/bashport"
    "zopencommunity/makeport"
)

echo -e "${GREEN}Test repositories selected:${NC}"
for repo in "${TEST_REPOS[@]}"; do
    echo -e "  - ${repo}"
done
echo ""

# Create a temporary config file for testing
TEST_CONFIG="bulk-utils/codeql-test-config"
cat > "$TEST_CONFIG" << EOF
base-branch:
  - main
branch: codeql-security-scanning-test
concurrent: 2
conflict-strategy: skip
draft: true
dry-run: false
fetch-depth: 1
fork: true
fork-owner:
git-type: cmd
interactive: false
log-file: "codeql-test-rollout.log"
log-format: text
log-level: debug
max-reviewers: 0
max-team-reviewers: 0
org:
  - zopencommunity
output: "-"
plain-output: false
platform: github
pr-title: "[TEST] Add CodeQL Security Scanning Workflow"
pr-body: |
  **THIS IS A TEST PR - DO NOT MERGE YET**
  
  This PR adds CodeQL security scanning to this repository.
  
  ## What's included:
  - CodeQL workflow that runs on push, pull requests, and weekly schedule
  - Uses the reusable workflow from zopencommunity/meta
  - Automatically detects the primary language
  - Adds CodeQL badge to README.md
  
  ## Benefits:
  - Automated security vulnerability detection
  - Code quality analysis
  - Integration with GitHub Security tab
  - Weekly scheduled scans to catch new vulnerabilities
  
  This is part of the zopen community initiative to improve security across all repositories.
  
  **Testing Phase**: This is being tested on 5 repositories before full rollout.
repo:
$(for repo in "${TEST_REPOS[@]}"; do echo "  - $repo"; done)
skip-forks: false
skip-pr: false
EOF

echo -e "${GREEN}Created test configuration: ${TEST_CONFIG}${NC}"
echo ""

# Prompt user to continue
echo -e "${YELLOW}This will create DRAFT pull requests in the following repositories:${NC}"
for repo in "${TEST_REPOS[@]}"; do
    echo -e "  - ${repo}"
done
echo ""
read -p "Do you want to continue? (yes/no): " -r
echo ""

if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo -e "${RED}Test rollout cancelled.${NC}"
    rm "$TEST_CONFIG"
    exit 0
fi

# Run multi-gitter with test configuration
echo -e "${GREEN}Starting test rollout with multi-gitter...${NC}"
echo ""

multi-gitter run ./bulk-utils/add_codeql_workflow.sh \
    --config "$TEST_CONFIG" \
    --token "${GITHUB_TOKEN}"

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Test rollout completed successfully!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "1. Review the draft PRs created in the test repositories"
    echo -e "2. Check the log file: codeql-test-rollout.log"
    echo -e "3. Verify the CodeQL workflows are correct"
    echo -e "4. If everything looks good, merge the test PRs"
    echo -e "5. Run the full rollout with: ./bulk-utils/rollout-codeql.sh"
    echo ""
else
    echo ""
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}Test rollout failed!${NC}"
    echo -e "${RED}========================================${NC}"
    echo ""
    echo -e "${YELLOW}Check the log file for details: codeql-test-rollout.log${NC}"
fi

# Keep the test config for reference
echo -e "${GREEN}Test configuration saved at: ${TEST_CONFIG}${NC}"

exit $EXIT_CODE

# Made with Bob
