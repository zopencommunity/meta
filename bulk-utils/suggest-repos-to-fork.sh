#!/bin/bash

# Title: Suggest additional repositories to fork for testing
#
# This script suggests diverse repositories from zopen community
# that are good candidates for testing the CodeQL rollout.
#
# Usage: ./bulk-utils/suggest-repos-to-fork.sh

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

YOUR_USERNAME="Sanjana-Kondalwade"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}CodeQL Testing - Repository Suggestions${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check what you already have
echo -e "${GREEN}Checking your current forks...${NC}"
if command -v gh &> /dev/null; then
    echo -e "${CYAN}Your current forked repositories:${NC}"
    CURRENT_FORKS=$(gh repo list $YOUR_USERNAME --limit 100 --json name --jq '.[] | select(.name | endswith("port")) | .name' 2>/dev/null || echo "")
    
    if [ -z "$CURRENT_FORKS" ]; then
        echo -e "${YELLOW}  No *port repositories found yet${NC}"
        FORK_COUNT=0
    else
        echo "$CURRENT_FORKS" | while read repo; do
            echo -e "  ✓ ${repo}"
        done
        FORK_COUNT=$(echo "$CURRENT_FORKS" | wc -l)
    fi
    echo -e "${GREEN}Total: ${FORK_COUNT} repositories${NC}"
else
    echo -e "${YELLOW}GitHub CLI not installed. Install with: brew install gh${NC}"
    echo -e "${YELLOW}You mentioned you have: rsyncport, cmakeport${NC}"
    FORK_COUNT=2
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Recommended Repositories to Fork${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

echo -e "${CYAN}For comprehensive testing, fork these diverse repositories:${NC}"
echo ""

echo -e "${GREEN}1. Simple C/C++ tools (good for basic testing):${NC}"
echo -e "   - curlport       (HTTP client, widely used)"
echo -e "   - wgetport       (Download utility)"
echo -e "   - ncursesport    (Terminal UI library)"
echo -e "   - zlibport       (Compression library)"
echo ""

echo -e "${GREEN}2. Build tools (test build detection):${NC}"
echo -e "   - makeport       (Build automation)"
echo -e "   - cmakeport      (✓ You have this!)"
echo -e "   - autoconfport   (Build configuration)"
echo -e "   - m4port         (Macro processor)"
echo ""

echo -e "${GREEN}3. Version control & utilities:${NC}"
echo -e "   - gitport        (Version control)"
echo -e "   - rsyncport      (✓ You have this!)"
echo -e "   - diffutilsport  (File comparison)"
echo -e "   - patchport      (Apply patches)"
echo ""

echo -e "${GREEN}4. Text editors (complex C projects):${NC}"
echo -e "   - vimport        (Text editor)"
echo -e "   - nanoport       (Simple editor)"
echo ""

echo -e "${GREEN}5. Shells & scripting:${NC}"
echo -e "   - bashport       (Shell)"
echo -e "   - sedport        (Stream editor)"
echo -e "   - awkport        (Text processing)"
echo ""

echo -e "${GREEN}6. Python-based tools (test Python detection):${NC}"
echo -e "   - pipport        (Python package manager)"
echo -e "   - mesonport      (Build system)"
echo ""

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${YELLOW}Recommended Testing Set (5-7 repos):${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

echo -e "For a good test coverage, fork these in addition to what you have:"
echo ""
echo -e "  1. ${CYAN}curlport${NC}      - Popular C tool, good test case"
echo -e "  2. ${CYAN}gitport${NC}       - Complex C project"
echo -e "  3. ${CYAN}bashport${NC}      - Shell, different build pattern"
echo -e "  4. ${CYAN}vimport${NC}       - Large C project"
echo -e "  5. ${CYAN}makeport${NC}      - Build tool"
echo ""

echo -e "${GREEN}With rsyncport and cmakeport, you'll have 7 diverse repos!${NC}"
echo ""

echo -e "${BLUE}========================================${NC}"
echo -e "${YELLOW}How to Fork:${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

echo -e "Option 1: Using GitHub CLI (fastest):"
echo -e "  ${CYAN}gh repo fork zopencommunity/curlport --clone=false${NC}"
echo -e "  ${CYAN}gh repo fork zopencommunity/gitport --clone=false${NC}"
echo -e "  ${CYAN}gh repo fork zopencommunity/bashport --clone=false${NC}"
echo -e "  ${CYAN}gh repo fork zopencommunity/vimport --clone=false${NC}"
echo -e "  ${CYAN}gh repo fork zopencommunity/makeport --clone=false${NC}"
echo ""

echo -e "Option 2: Using GitHub Web UI:"
echo -e "  1. Go to: https://github.com/zopencommunity/curlport"
echo -e "  2. Click 'Fork' button"
echo -e "  3. Repeat for other repos"
echo ""

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}After Forking:${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

echo -e "Run the CodeQL rollout on your forks:"
echo -e "  ${CYAN}./bulk-utils/fork-test-rollout.sh${NC}"
echo ""

echo -e "This will automatically find and process ALL your forked *port repos!"
echo ""

# Made with Bob
