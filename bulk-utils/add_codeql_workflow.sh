#!/bin/bash

# Title: Add CodeQL workflow to zopen community repositories
#
# To be executed on workstation, via multi-gitter.
# Assumes you've cloned this repo (meta) down and are running this script from the repo root.
# This will add a CodeQL workflow that calls the reusable workflow from meta repo.

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting CodeQL workflow addition...${NC}"

# Ensure .github/workflows directory exists
mkdir -p .github/workflows

# The CodeQL workflow file to be added
CODEQL_WORKFLOW=.github/workflows/codeql.yml

# Check if CodeQL workflow already exists
if [ -f "$CODEQL_WORKFLOW" ]; then
    echo -e "${YELLOW}CodeQL workflow already exists in this repository. Skipping...${NC}"
    exit 0
fi

# Determine the repository name
REPO_NAME=$(basename "$PWD")
echo -e "${GREEN}Adding CodeQL workflow to: ${REPO_NAME}${NC}"

# Detect primary language for the repository
# Default to c-cpp for zopen community (most ports are C/C++)
LANGUAGE="c-cpp"
BUILD_MODE="none"

# Check for specific language indicators
if [ -f "setup.py" ] || [ -f "pyproject.toml" ] || [ -d "python" ]; then
    LANGUAGE="python"
    BUILD_MODE="none"
elif [ -f "package.json" ]; then
    LANGUAGE="javascript-typescript"
    BUILD_MODE="none"
elif [ -f "go.mod" ]; then
    LANGUAGE="go"
    BUILD_MODE="autobuild"
elif [ -f "pom.xml" ] || [ -f "build.gradle" ]; then
    LANGUAGE="java-kotlin"
    BUILD_MODE="autobuild"
fi

echo -e "${GREEN}Detected language: ${LANGUAGE}, Build mode: ${BUILD_MODE}${NC}"

# Create the CodeQL workflow that calls the reusable workflow
cat > "$CODEQL_WORKFLOW" << EOF
name: "CodeQL Analysis"

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  schedule:
    # Run at 2:00 AM UTC every Monday
    - cron: '0 2 * * 1'
  workflow_dispatch:

jobs:
  codeql:
    name: CodeQL Security Scan
    uses: zopencommunity/meta/.github/workflows/codeql.yml@main
    with:
      languages: '${LANGUAGE}'
      build-mode: '${BUILD_MODE}'
    permissions:
      actions: read
      contents: read
      security-events: write
EOF

echo -e "${GREEN}✓ CodeQL workflow created successfully${NC}"

# Add CodeQL badge to README.md if it exists and doesn't already have it
if [ -f "README.md" ]; then
    if ! grep -q "CodeQL" README.md; then
        echo -e "${GREEN}Adding CodeQL badge to README.md...${NC}"
        BADGE_LINE="[![CodeQL](https://github.com/${REPOSITORY}/actions/workflows/codeql.yml/badge.svg)](https://github.com/${REPOSITORY}/actions/workflows/codeql.yml)"
        
        # Add badge after the first line (title)
        sed -i.bak "1a\\
$BADGE_LINE\\
" README.md && rm README.md.bak
        
        echo -e "${GREEN}✓ CodeQL badge added to README.md${NC}"
    else
        echo -e "${YELLOW}CodeQL badge already exists in README.md${NC}"
    fi
fi

echo -e "${GREEN}CodeQL workflow setup complete for ${REPO_NAME}!${NC}"

# Made with Bob
