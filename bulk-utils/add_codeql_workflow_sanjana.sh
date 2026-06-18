#!/bin/bash

# Title: Add CodeQL workflow to Sanjana-Kondalwade repositories with 'port' in name
#
# This script adds a CodeQL workflow that calls the reusable workflow from 
# Sanjana-Kondalwade/meta repo to all repositories containing 'port' in their name.

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
# Default to c-cpp (most ports are C/C++)
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
cat > "$CODEQL_WORKFLOW" << 'EOF'
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
      languages: "LANGUAGE_PLACEHOLDER"
      build-mode: "BUILD_MODE_PLACEHOLDER"
EOF

# Replace placeholders with actual values
sed -i.bak "s/LANGUAGE_PLACEHOLDER/${LANGUAGE}/g" "$CODEQL_WORKFLOW"
sed -i.bak "s/BUILD_MODE_PLACEHOLDER/${BUILD_MODE}/g" "$CODEQL_WORKFLOW"
rm -f "${CODEQL_WORKFLOW}.bak"

echo -e "${GREEN}✓ CodeQL workflow created successfully${NC}"
echo -e "${GREEN}  Language: ${LANGUAGE}${NC}"
echo -e "${GREEN}  Build mode: ${BUILD_MODE}${NC}"

echo -e "${GREEN}CodeQL workflow setup complete for ${REPO_NAME}!${NC}"

# Made with Bob
