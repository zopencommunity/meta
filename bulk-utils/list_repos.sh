#!/bin/bash

# Diagnostic script to see what repos we can access

GITHUB_TOKEN="${GITHUB_TOKEN}"
ORG="zopencommunity"

echo "Testing GitHub API access for org: $ORG..."
echo ""

# Test API call — uses orgs endpoint for organisation repos (supports >100 via pagination)
page=1
all_names=""
while true; do
  response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
      "https://api.github.com/orgs/$ORG/repos?per_page=100&page=${page}")

  names=$(echo "$response" | jq -r '.[].name' 2>/dev/null)
  [ -z "$names" ] && break
  all_names="${all_names}"$'\n'"${names}"
  count=$(echo "$names" | wc -l)
  [ "$count" -lt 100 ] && break
  (( page++ ))
done

all_names=$(echo "$all_names" | sed '/^$/d')

echo "Total repos found: $(echo "$all_names" | wc -l)"
echo ""

# Filter port repos
echo "Repos ending with 'port':"
echo "$all_names" | grep 'port$'
