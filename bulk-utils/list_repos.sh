#!/bin/bash

# Diagnostic script to see what repos we can access

GITHUB_TOKEN="${GITHUB_TOKEN}"
USERNAME="Sanjana-Kondalwade"

echo "Testing GitHub API access..."
echo ""

# Test API call
response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/users/$USERNAME/repos?per_page=100&page=1")

echo "API Response:"
echo "$response" | head -20
echo ""
echo "---"
echo ""

# Try to parse repo names
echo "Attempting to extract repo names:"
echo "$response" | jq -r '.[].name' 2>&1 | head -20
echo ""

# Count total
total=$(echo "$response" | jq -r '.[].name' 2>/dev/null | wc -l)
echo "Total repos found: $total"
echo ""

# Filter port repos
echo "Repos ending with 'port':"
echo "$response" | jq -r '.[].name' 2>/dev/null | grep 'port$'
