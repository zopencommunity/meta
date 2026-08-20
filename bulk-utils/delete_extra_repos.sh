#!/bin/bash

# Script to delete all port repos except the 10 testing ones
# WARNING: This will permanently delete repositories!

GITHUB_TOKEN="${GITHUB_TOKEN}"
USERNAME="Sanjana-Kondalwade"

# Repos to KEEP (do not delete)
KEEP_REPOS=(
    "bashport"
    "gitport"
    "vimport"
    "coreutilsport"
    "grepport"
    "sedport"
    "curlport"
    "wgetport"
    "opensshport"
    "tmuxport"
)

echo "Fetching all repositories for user: $USERNAME"
echo "This may take a moment..."
echo ""

# Get all repos with pagination (up to 300 repos)
ALL_REPOS=""
for page in 1 2 3; do
    PAGE_REPOS=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/users/$USERNAME/repos?per_page=100&page=$page" | \
        jq -r '.[].name')
    
    if [ -z "$PAGE_REPOS" ]; then
        break
    fi
    ALL_REPOS="$ALL_REPOS$PAGE_REPOS"$'\n'
done

# Filter only repos ending with 'port'
REPOS=$(echo "$ALL_REPOS" | grep 'port$' | sort | uniq)

echo "Found repositories ending with 'port':"
echo "$REPOS"
echo ""
echo "Total port repos found: $(echo "$REPOS" | wc -l | tr -d ' ')"
echo ""

# Function to check if repo should be kept
should_keep() {
    local repo=$1
    for keep in "${KEEP_REPOS[@]}"; do
        if [ "$repo" = "$keep" ]; then
            return 0
        fi
    done
    return 1
}

# Count repos to delete
TO_DELETE=()
for repo in $REPOS; do
    if [ -n "$repo" ] && ! should_keep "$repo"; then
        TO_DELETE+=("$repo")
    fi
done

echo "=========================================="
echo "Repositories to DELETE (${#TO_DELETE[@]}):"
echo "=========================================="
for repo in "${TO_DELETE[@]}"; do
    echo "  - $repo"
done
echo ""

echo "=========================================="
echo "Repositories to KEEP (${#KEEP_REPOS[@]}):"
echo "=========================================="
for repo in "${KEEP_REPOS[@]}"; do
    echo "  - $repo"
done
echo ""

if [ ${#TO_DELETE[@]} -eq 0 ]; then
    echo "No repositories to delete. Exiting."
    exit 0
fi

echo "⚠️  WARNING: This will PERMANENTLY delete ${#TO_DELETE[@]} repositories!"
echo "⚠️  This action CANNOT be undone!"
echo ""
read -p "Type 'DELETE' (in capitals) to confirm deletion: " confirm

if [ "$confirm" != "DELETE" ]; then
    echo "Deletion cancelled."
    exit 0
fi

echo ""
echo "Starting deletion..."
echo ""

# Delete repos
SUCCESS=0
FAILED=0
for repo in "${TO_DELETE[@]}"; do
    echo "Deleting $USERNAME/$repo..."
    response=$(curl -s -X DELETE \
        -H "Authorization: token $GITHUB_TOKEN" \
        -w "\n%{http_code}" \
        "https://api.github.com/repos/$USERNAME/$repo")
    
    http_code=$(echo "$response" | tail -n1)
    
    if [ "$http_code" = "204" ]; then
        echo "  ✓ Successfully deleted $repo"
        ((SUCCESS++))
    else
        echo "  ✗ Failed to delete $repo (HTTP $http_code)"
        body=$(echo "$response" | head -n-1)
        if [ -n "$body" ]; then
            echo "  Response: $body"
        fi
        ((FAILED++))
    fi
    sleep 0.5  # Rate limiting
done

echo ""
echo "=========================================="
echo "Deletion Summary:"
echo "=========================================="
echo "Successfully deleted: $SUCCESS"
echo "Failed: $FAILED"
echo "Total processed: ${#TO_DELETE[@]}"
echo ""
echo "Done!"


