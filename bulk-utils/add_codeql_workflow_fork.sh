#!/bin/bash

# Title: Add CodeQL workflow to YOUR forked repositories using YOUR meta fork
#
# This version uses Sanjana-Kondalwade/meta instead of zopencommunity/meta
# Use this if you want complete isolation for testing
#
# To be executed via multi-gitter.

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting CodeQL workflow addition (using YOUR meta fork)...${NC}"

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

# Create the CodeQL workflow that calls YOUR reusable workflow
cat > "$CODEQL_WORKFLOW" << EOF
name: "CodeQL"

permissions:
  actions: read
  contents: read
  security-events: write

on:
  push:
    branches: ["main"]
  pull_request:
    branches: ["main"]
  pull_request_target:
    types: [opened, synchronize, reopened]
  schedule:
    - cron: "0 0 * * 1"
  workflow_dispatch:

jobs:
  codeql:
    uses: Sanjana-Kondalwade/meta/.github/workflows/codeql.yml@main
    secrets: inherit
    permissions:
      actions: read
      contents: read
      security-events: write
    with:
      languages: "${LANGUAGE}"
      build-mode: "${BUILD_MODE}"
EOF

echo -e "${GREEN}✓ CodeQL workflow created successfully (using YOUR meta fork)${NC}"

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
