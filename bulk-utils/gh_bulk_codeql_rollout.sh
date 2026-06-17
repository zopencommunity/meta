#!/bin/bash

################################################################################
# Title: Bulk CodeQL Workflow Rollout Script
#
# Description: 
#   Rolls out CodeQL analysis workflow to all repositories in an organization.
#   Uses GitHub CLI to fetch repository list and multi-gitter for bulk updates.
#
# Prerequisites:
#   - GitHub CLI (gh) installed and authenticated
#   - multi-gitter installed (https://github.com/lindell/multi-gitter)
#   - This script should be run from the meta repository root
#
# Usage:
#   ./bulk-utils/gh_bulk_codeql_rollout.sh <org-name> [options]
#
# Options:
#   --limit N          Limit to N repositories (default: 300)
#   --dry-run          Show what would be done without making changes
#   --branch NAME      Branch name for PRs (default: add-codeql-workflow)
#   --skip-archived    Skip archived repositories (default: true)
#   --languages LANGS  Comma-separated list of languages (default: javascript,python)
#
# Examples:
#   ./bulk-utils/gh_bulk_codeql_rollout.sh my-org
#   ./bulk-utils/gh_bulk_codeql_rollout.sh my-org --limit 50 --dry-run
#   ./bulk-utils/gh_bulk_codeql_rollout.sh my-org --languages "javascript,python,go"
#
################################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
LIMIT=300
DRY_RUN=false
BRANCH_NAME="add-codeql-workflow"
SKIP_ARCHIVED=true
LANGUAGES="javascript,python"
ORG_NAME=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --limit)
            LIMIT="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --branch)
            BRANCH_NAME="$2"
            shift 2
            ;;
        --skip-archived)
            SKIP_ARCHIVED=true
            shift
            ;;
        --languages)
            LANGUAGES="$2"
            shift 2
            ;;
        --help|-h)
            grep "^#" "$0" | grep -v "^#!/" | sed 's/^# //' | sed 's/^#//'
            exit 0
            ;;
        *)
            if [ -z "$ORG_NAME" ]; then
                ORG_NAME="$1"
            else
                echo -e "${RED}Error: Unknown argument: $1${NC}"
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate organization name
if [ -z "$ORG_NAME" ]; then
    echo -e "${RED}Error: Organization name is required${NC}"
    echo "Usage: $0 <org-name> [options]"
    echo "Run '$0 --help' for more information"
    exit 1
fi

# Check prerequisites
echo -e "${BLUE}Checking prerequisites...${NC}"

if ! command -v gh &> /dev/null; then
    echo -e "${RED}Error: GitHub CLI (gh) is not installed${NC}"
    echo "Install from: https://cli.github.com/"
    exit 1
fi

if ! command -v multi-gitter &> /dev/null; then
    echo -e "${YELLOW}Warning: multi-gitter is not installed${NC}"
    echo "Install from: https://github.com/lindell/multi-gitter"
    echo "Or use the manual method below"
fi

# Check if we're in the meta repository
if [ ! -f "data/codeql-analysis.yml" ]; then
    echo -e "${RED}Error: data/codeql-analysis.yml not found${NC}"
    echo "Please run this script from the meta repository root"
    exit 1
fi

echo -e "${GREEN}✓ Prerequisites check passed${NC}\n"

# Fetch repository list
echo -e "${BLUE}Fetching repositories from ${ORG_NAME}...${NC}"

QUERY_ARGS="--limit ${LIMIT} --json name,isArchived,languages"

if [ "$SKIP_ARCHIVED" = true ]; then
    REPO_LIST=$(gh repo list "$ORG_NAME" $QUERY_ARGS | jq -r '.[] | select(.isArchived == false) | .name')
else
    REPO_LIST=$(gh repo list "$ORG_NAME" $QUERY_ARGS | jq -r '.[].name')
fi

REPO_COUNT=$(echo "$REPO_LIST" | wc -l | tr -d ' ')

echo -e "${GREEN}Found ${REPO_COUNT} repositories${NC}\n"

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}DRY RUN MODE - No changes will be made${NC}\n"
    echo "Repositories that would be updated:"
    echo "$REPO_LIST"
    exit 0
fi

# Create temporary script for multi-gitter
TEMP_SCRIPT=$(mktemp)
cat > "$TEMP_SCRIPT" << 'EOFSCRIPT'
#!/bin/bash

# This script is executed by multi-gitter in each repository

CODEQL_FILE=./data/codeql-analysis.yml
CODEQL_IN_REPO=.github/workflows/codeql-analysis.yml

# Check if CodeQL workflow already exists
if [ -f "$CODEQL_IN_REPO" ]; then
    echo "CodeQL workflow already exists in $REPOSITORY, skipping..."
    exit 0
fi

echo "Adding CodeQL workflow to $REPOSITORY"

# Create .github/workflows directory if it doesn't exist
mkdir -p .github/workflows

# Copy the CodeQL workflow
cp "$CODEQL_FILE" "$CODEQL_IN_REPO"

# Optionally add badge to README (commented out by default)
# Uncomment the following lines if you want to add a badge
# if [ -f "README.md" ]; then
#     LINE="[![CodeQL](https://github.com/$REPOSITORY/actions/workflows/codeql-analysis.yml/badge.svg)](https://github.com/$REPOSITORY/actions/workflows/codeql-analysis.yml)"
#     if ! grep -q "codeql-analysis.yml" README.md; then
#         printf '%s\n\n' "$LINE" | cat - README.md > tmpfile && mv tmpfile README.md
#     fi
# fi

echo "✓ CodeQL workflow added successfully"
EOFSCRIPT

chmod +x "$TEMP_SCRIPT"

# Display summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}CodeQL Rollout Configuration${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Organization:     ${GREEN}${ORG_NAME}${NC}"
echo -e "Repositories:     ${GREEN}${REPO_COUNT}${NC}"
echo -e "Branch name:      ${GREEN}${BRANCH_NAME}${NC}"
echo -e "Languages:        ${GREEN}${LANGUAGES}${NC}"
echo -e "Skip archived:    ${GREEN}${SKIP_ARCHIVED}${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Method 1: Using multi-gitter (recommended)
if command -v multi-gitter &> /dev/null; then
    echo -e "${GREEN}Using multi-gitter for bulk rollout...${NC}\n"
    
    read -p "Do you want to proceed with multi-gitter? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        multi-gitter run "$TEMP_SCRIPT" \
            --org "$ORG_NAME" \
            --branch "$BRANCH_NAME" \
            --commit-message "Add CodeQL security analysis workflow" \
            --pr-title "Add CodeQL security analysis workflow" \
            --pr-body "This PR adds CodeQL security analysis to automatically scan code for vulnerabilities.

**What's included:**
- CodeQL workflow for automated security scanning
- Scheduled weekly scans
- Scan on push and pull requests
- Support for multiple languages: ${LANGUAGES}

**Benefits:**
- Automated vulnerability detection
- Security insights in GitHub Security tab
- Compliance with security best practices

This is part of our organization-wide security initiative." \
            --fork=false \
            --dry-run=false
        
        echo -e "\n${GREEN}✓ Multi-gitter rollout completed!${NC}"
    fi
else
    # Method 2: Manual method using gh CLI
    echo -e "${YELLOW}Multi-gitter not available. Using manual method...${NC}\n"
    echo -e "${BLUE}Manual rollout instructions:${NC}\n"
    
    echo "1. Save the repository list to a file:"
    echo "   gh repo list $ORG_NAME --limit $LIMIT --json name -q '.[].name' > repos.txt"
    echo ""
    echo "2. For each repository, run:"
    echo "   while read repo; do"
    echo "     echo \"Processing \$repo...\""
    echo "     gh repo clone $ORG_NAME/\$repo"
    echo "     cd \$repo"
    echo "     git checkout -b $BRANCH_NAME"
    echo "     mkdir -p .github/workflows"
    echo "     cp ../meta/data/codeql-analysis.yml .github/workflows/"
    echo "     git add .github/workflows/codeql-analysis.yml"
    echo "     git commit -m 'Add CodeQL security analysis workflow'"
    echo "     git push origin $BRANCH_NAME"
    echo "     gh pr create --title 'Add CodeQL security analysis workflow' --body 'Add automated security scanning'"
    echo "     cd .."
    echo "   done < repos.txt"
    echo ""
    
    # Generate the actual command
    echo -e "${GREEN}Or use this one-liner:${NC}"
    echo "gh repo list $ORG_NAME --limit $LIMIT --json name -q '.[].name' | while read repo; do gh repo clone $ORG_NAME/\$repo && cd \$repo && git checkout -b $BRANCH_NAME && mkdir -p .github/workflows && cp ../meta/data/codeql-analysis.yml .github/workflows/ && git add .github/workflows/codeql-analysis.yml && git commit -m 'Add CodeQL security analysis workflow' && git push origin $BRANCH_NAME && gh pr create --title 'Add CodeQL security analysis workflow' --body 'Add automated security scanning' && cd ..; done"
fi

# Cleanup
rm -f "$TEMP_SCRIPT"

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Next Steps:${NC}"
echo -e "${GREEN}========================================${NC}"
echo "1. Review the created pull requests"
echo "2. Merge approved PRs"
echo "3. Monitor CodeQL scans in Security tab"
echo "4. Configure code scanning alerts"
echo -e "${GREEN}========================================${NC}\n"

echo -e "${BLUE}Useful commands:${NC}"
echo "- List all PRs: gh pr list --repo $ORG_NAME/REPO_NAME"
echo "- View CodeQL results: gh api repos/$ORG_NAME/REPO_NAME/code-scanning/alerts"
echo "- Enable code scanning: gh api repos/$ORG_NAME/REPO_NAME/code-scanning/default-setup -X PATCH -f state=configured"

# Made with Bob
