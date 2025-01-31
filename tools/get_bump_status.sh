#!/bin/bash

# Check dependencies
command -v gh >/dev/null 2>&1 || { echo "Error: GitHub CLI (gh) required"; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "Error: jq required"; exit 1; }

# Configuration
ORG="zopencommunity"
OUTPUT_FILE="${1:-updatestatus.md}"  # Use first argument or default
WORKFLOW_FILE=".github/workflows/bump.yml"

# Initialize output
mkdir -p docs
echo "# Currency Status" > $OUTPUT_FILE
# Get all repositories sorted alphabetically
echo "⏳ Fetching repository list..."
REPOS=$(gh repo list $ORG --limit 1000 --json name -q '.[].name' | sort)

# Pending PRs Section
echo -e "\n---\n" >> $OUTPUT_FILE
echo -e "<details open>" >> $OUTPUT_FILE
echo -e '<summary><b style="font-size: 28px;">Open Update PRs</b></summary>\n' >> $OUTPUT_FILE

echo "⏳ Checking for pending PRs..."
FOUND_PR=false
while read -r repo; do
    PRS=$(gh pr list -R $ORG/$repo \
        --search "author:zosopentoolsmain Update * version" \
        --json title,url,createdAt,number \
        --jq '.[] | {title: .title, url: .url, createdAt: .createdAt, number: .number}' | 
        jq -r '@base64' 2>/dev/null)
    
    if [ -n "$PRS" ]; then
        echo -e "\n### $repo" >> $OUTPUT_FILE
        for pr in $PRS; do
            _jq() {
                echo "${pr}" | base64 --decode | jq -r "${1}"
            }
            
            PR_TITLE=$(_jq '.title')
            PR_URL=$(_jq '.url')
            PR_DATE=$(_jq '.createdAt[0:10]')
            PR_NUMBER=$(_jq '.number')
            
            # Get combined status using GraphQL
            STATUS=$(gh api graphql -F owner="$ORG" -F repo="$repo" -F pr="$PR_NUMBER" -f query='
                query($owner: String!, $repo: String!, $pr: Int!) {
                    repository(owner: $owner, name: $repo) {
                        pullRequest(number: $pr) {
                            commits(last: 1) {
                                nodes {
                                    commit {
                                        statusCheckRollup {
                                            state
                                        }
                                    }
                                }
                            }
                        }
                    }
                }' --jq '.data.repository.pullRequest.commits.nodes[0].commit.statusCheckRollup.state' 2>/dev/null)
            
            case "$STATUS" in
                "SUCCESS") EMOJI="✅" ;;
                "FAILURE") EMOJI="❌" ;;
                "PENDING") EMOJI="⏳" ;;
                *) EMOJI="❓" ;;
            esac
            
            echo "- $PR_DATE: [$PR_TITLE]($PR_URL) $EMOJI" >> $OUTPUT_FILE
        done
        FOUND_PR=true
    fi
done <<< "$REPOS"

if ! $FOUND_PR; then
    echo -e "\nNo pending version update PRs found!" >> $OUTPUT_FILE
fi
echo -e "\n</details>" >> $OUTPUT_FILE
#
# Workflow Status Section
echo -e "\n<details open>" >> $OUTPUT_FILE
echo -e '<summary><b style="font-size: 28px;">Bump Automation Status</b></summary>\n' >> $OUTPUT_FILE

ACTIVE_COUNT=0
MISSING_COUNT=0

while read -r repo; do
    # Check if workflow file exists using contents API
    if gh api "/repos/$ORG/$repo/contents/$WORKFLOW_FILE" --silent >/dev/null 2>&1; then
        echo "- ✅ $repo - [![Bump Status](https://github.com/$ORG/$repo/actions/workflows/bump.yml/badge.svg)](https://github.com/$ORG/$repo/actions/workflows/bump.yml)" >> $OUTPUT_FILE
        ((ACTIVE_COUNT++))
    else
        echo "- ❌ $repo - Workflow not configured" >> $OUTPUT_FILE
        ((MISSING_COUNT++))
    fi
done <<< "$REPOS"

echo -e "\n</details>" >> $OUTPUT_FILE
echo -e "\n**Summary:** $ACTIVE_COUNT active | $MISSING_COUNT missing" >> $OUTPUT_FILE


echo -e "\n---\n" >> $OUTPUT_FILE
echo -e "\n> Last updated: $(date +"%Y-%m-%d %H:%M:%S %Z")\n" >> $OUTPUT_FILE

echo "✅ Report generated: $OUTPUT_FILE"

# Set proper exit code
exit 0
