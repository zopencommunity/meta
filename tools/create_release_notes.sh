#!/usr/bin/env bash

set -e  # Exit on error

# Parse command line arguments
MODE="retro"  # Default mode
PROJECTS=""
LIMIT=250

print_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -m, --mode MODE     Operation mode: 'retro' (update all releases) or 'release' (generate for new release)"
    echo "  -p, --projects LIST Comma-separated list of projects (default: all zopencommunity projects)"
    echo "  -l, --limit NUM     Limit number of releases to process (default: 250)"
    echo "  -h, --help          Show this help message"
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--mode)
            MODE="$2"
            if [[ "$MODE" != "retro" && "$MODE" != "release" ]]; then
                echo "Error: Mode must be either 'retro' or 'release'"
                exit 1
            fi
            shift 2
            ;;
        -p|--projects)
            PROJECTS="$2"
            shift 2
            ;;
        -l|--limit)
            LIMIT="$2"
            shift 2
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            print_usage
            exit 1
            ;;
    esac
done

# Get projects list if not specified
if [ -z "$PROJECTS" ]; then
    PROJECTS=$(gh repo list zopencommunity -L 300 --json name --jq .[].name)
else
    # Convert comma-separated list to space-separated
    PROJECTS=$(echo "$PROJECTS" | tr ',' ' ')
fi

# Create a temporary directory for release notes
TEMP_DIR=$(mktemp -d)
echo "Using temporary directory: $TEMP_DIR"

# Global rate limit tracking
RATE_REMAINING=5000  # Default GitHub rate limit
RATE_RESET=0

# Function to check and wait for rate limits
check_rate_limit() {
    local current_time
    current_time=$(date +%s)

    # Only check rate limit when we're running low or past reset time
    if [ "$RATE_REMAINING" -le 100 ] || [ "$current_time" -ge "$RATE_RESET" ]; then
        local rate_info
        rate_info=$(gh api /rate_limit)
        RATE_REMAINING=$(echo "$rate_info" | jq -r '.resources.core.remaining')
        RATE_RESET=$(echo "$rate_info" | jq -r '.resources.core.reset')
    fi

    if [ "$RATE_REMAINING" -le 1 ]; then
        local wait_time=$((RATE_RESET - current_time + 1))
        echo "Rate limit nearly exhausted (${RATE_REMAINING} remaining). Waiting ${wait_time} seconds for reset..."
        sleep "$wait_time"
        # Refresh our rate limit info after waiting
        rate_info=$(gh api /rate_limit)
        RATE_REMAINING=$(echo "$rate_info" | jq -r '.resources.core.remaining')
        RATE_RESET=$(echo "$rate_info" | jq -r '.resources.core.reset')
    fi

    # Decrement our remaining count
    RATE_REMAINING=$((RATE_REMAINING - 1))
}

# Function to handle GitHub API calls with error checking
gh_api_call() {
    local endpoint="$1"
    local output_file="$2"
    local max_retries=3
    local retry_count=0

    while true; do
        check_rate_limit

        if output=$(gh api "$endpoint" 2>&1); then
            echo "$output" > "$output_file"
            return 0
        else
            echo "API call to $endpoint failed with error: $output" >&2
        fi

        retry_count=$((retry_count + 1))
        if [ $retry_count -ge $max_retries ]; then
            echo "Failed to call GitHub API after $max_retries attempts" >&2
            echo "Last error: $output" >&2
            return 1
        fi

        echo "API call failed, retrying in 5 seconds..." >&2
        sleep 5
    done
}

# Function to format commit message
format_commit_message() {
    local commit_sha="$1"
    local commit_msg="$2"
    local project="$3"

    # Get the first line and clean up whitespace, preserving important content
    local first_line
    first_line=$(echo "$commit_msg" | head -n1)

    # Skip merge commits and empty messages
    if [[ "$first_line" =~ ^Merge\ (pull\ request|branch) ]] || [ -z "$first_line" ]; then
        return
    fi

    # Extract just the 40-character SHA
    commit_sha=$(echo "$commit_sha" | grep -o '[0-9a-f]\{40\}')

    # Create the commit link
    local commit_link="[${commit_sha:0:7}](https://github.com/zopencommunity/${project}/commit/${commit_sha})"

    # Clean up the message while preserving content in parentheses
    first_line=$(echo "$first_line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    # If it's a conventional commit format (type(scope): message)
    if [[ "$first_line" =~ ^([^(:]+)(\([^)]+\)):(.+)$ ]]; then
        local type="${BASH_REMATCH[1]}"
        local scope="${BASH_REMATCH[2]}"
        local message="${BASH_REMATCH[3]}"

        # Clean up the message while preserving content
        message=$(echo "$message" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

        printf "* %s%s:%s (%s)\n" "$type" "$scope" "$message" "$commit_link"
    else
        # For regular commit messages, preserve the full message
        if [ -n "$first_line" ]; then
            printf "* %s (%s)\n" "$first_line" "$commit_link"
        fi
    fi
}

# Function to create release notes for a comparison
create_release_notes() {
    local repo="$1"
    local prev_tag="$2"
    local curr_tag="$3"
    local output_file="$4"

    local title="## [Changes ${prev_tag}...${curr_tag}](https://github.com/${repo}/compare/${prev_tag}...${curr_tag})"
    generate_notes "$repo" "$prev_tag" "$curr_tag" "$output_file" "$title"
}

# Function to create release notes for unreleased changes
create_unreleased_notes() {
    local repo="$1"
    local last_tag="$2"
    local output_file="$3"

    local title="## [Changes since ${last_tag}](https://github.com/${repo}/compare/${last_tag}...HEAD)"
    generate_notes "$repo" "$last_tag" "HEAD" "$output_file" "$title"
}

# Shared function to generate release notes
generate_notes() {
    local repo="$1"
    local base_ref="$2"
    local target_ref="$3"
    local output_file="$4"
    local title="$5"

    # Extract project name from repo
    local project
    project=$(echo "$repo" | cut -d'/' -f2)

    # Get the comparison data
    local compare_file="${TEMP_DIR}/compare.json"
    if ! gh_api_call "repos/${repo}/compare/${base_ref}...${target_ref}" "$compare_file"; then
        echo "Error getting comparison data, skipping..."
        rm -f "$compare_file"
        return 1
    fi

    # Create the release notes
    {
        echo "$title"
        echo ""
        echo "### Pull Requests"
    } > "$output_file"

    # Process PRs
    local has_prs=false
    declare -A pr_commit_map

    while read -r line; do
        message=$(echo "$line" | jq -r '.message')
        sha=$(echo "$line" | jq -r '.sha')

        if [ -z "$message" ]; then
            continue
        fi
        pr_num=$(echo "$message" | sed -n 's/^Merge pull request #\([0-9]\+\).*/\1/p')
        if [ -n "$pr_num" ]; then
            local pr_file="${TEMP_DIR}/pr.json"
            if gh_api_call "repos/${repo}/pulls/${pr_num}" "$pr_file"; then
                pr_title=$(jq -r '.title' "$pr_file")
                pr_title=${pr_title//[[\]]/}
                echo "* ${pr_title} ([#${pr_num}](https://github.com/${repo}/pull/${pr_num}))" >> "$output_file"
                has_prs=true

                local commits_file="${TEMP_DIR}/commits.json"
                if gh_api_call "repos/${repo}/pulls/${pr_num}/commits" "$commits_file"; then
                    while read -r commit_sha; do
                        if [ -n "$commit_sha" ]; then
                            pr_commit_map["$commit_sha"]=1
                        fi
                    done < <(jq -r '.[].sha' "$commits_file")
                fi
                rm -f "$commits_file"
            fi
            rm -f "$pr_file"
        fi
    done < <(jq -r '.commits[] | {message: .commit.message, sha: .sha} | tojson' "$compare_file")

    if [ "$has_prs" = false ]; then
        echo "No pull requests found in this period." >> "$output_file"
    fi

    # Process direct commits
    echo -e "\n### Direct Changes" >> "$output_file"
    local has_direct=false

    while read -r line; do
        message=$(echo "$line" | jq -r '.message')
        sha=$(echo "$line" | jq -r '.sha')

        if [ -z "$message" ] || echo "$message" | grep -q '^Merge pull request'; then
            continue
        fi

        first_line=$(echo "$message" | head -n1)
        if [[ "$first_line" =~ ^Updating\ docs/apis ]] || \
           [[ "$first_line" =~ ^Reorder\ doc\ updates ]] || \
           [[ "$first_line" =~ ^Update\ .*\.md$ ]]; then
            continue
        fi

        if [ -n "$sha" ] && [ -z "${pr_commit_map[$sha]+x}" ]; then
            format_commit_message "$sha" "$message" "$project" >> "$output_file"
            has_direct=true
        fi
    done < <(jq -r '.commits[] | {message: .commit.message, sha: .sha} | tojson' "$compare_file")

    if [ "$has_direct" = false ]; then
        echo "No direct changes in this period." >> "$output_file"
    fi

    rm -f "$compare_file"
    return 0
}

# Process each project
for project in $PROJECTS; do
    echo "Processing project: $project"
    REPO="zopencommunity/$project"

    # Get releases
    RELEASES=$(gh release list --limit "$LIMIT" --repo "$REPO" --json name,tagName,publishedAt --order asc)
    if [ -z "$RELEASES" ]; then
        echo "No releases found for $REPO, skipping..."
        continue
    fi

    if [ "$MODE" = "retro" ]; then
        # Process all releases retrospectively
        prev_tag=""
        echo "$RELEASES" | jq -r '.[] | .tagName' | while read -r curr_tag; do
            if [ -n "$prev_tag" ]; then
                notes_file="${TEMP_DIR}/${project}_${curr_tag}_notes.md"
                if create_release_notes "$REPO" "$prev_tag" "$curr_tag" "$notes_file"; then
                    echo "Would execute: gh release edit --repo $REPO $curr_tag --notes-file $notes_file"
                    # Uncomment the following line to actually update the release notes
                    # gh release edit --repo "$REPO" "$curr_tag" --notes-file "$notes_file"
                fi
            fi
            prev_tag="$curr_tag"
        done
    else
        # Get the latest release tag and date - releases are in ascending order, .[-1] gives us the newest item
        LATEST_TAG=$(echo "$RELEASES" | jq -r '.[-1].tagName')
        if [ -n "$LATEST_TAG" ]; then
            if [ "$project" = "metaport" ]; then
                # Special handling for metaport - get both metaport and meta changes
                echo "Processing metaport changes..."
                notes_file="${TEMP_DIR}/${project}_unreleased_notes.md"
                if create_unreleased_notes "$REPO" "$LATEST_TAG" "$notes_file"; then
                    echo "Generated release notes for unreleased metaport changes in $notes_file"
                    cat "$notes_file"
                fi

                # Get the latest release date for metaport
                LATEST_DATE=$(echo "$RELEASES" | jq -r '.[-1].publishedAt' | cut -d'T' -f1)
                if [ -n "$LATEST_DATE" ]; then
                    echo "Processing meta changes since ${LATEST_DATE}..."

                    # Find the meta commit hash from the release date
                    meta_commit_file="${TEMP_DIR}/meta_commit.json"
                    if gh_api_call "repos/zopencommunity/meta/commits?until=${LATEST_DATE}T23:59:59Z&per_page=1" "$meta_commit_file"; then
                        META_COMMIT=$(jq -r '.[0].sha' "$meta_commit_file")
                        if [ -n "$META_COMMIT" ] && [ "$META_COMMIT" != "null" ]; then
                            meta_notes_file="${TEMP_DIR}/meta_unreleased_notes.md"
                            # Create notes for meta changes since the commit at release date
                            if create_unreleased_notes "zopencommunity/meta" "$META_COMMIT" "$meta_notes_file"; then
                                echo "Generated release notes for unreleased meta changes in $meta_notes_file"
                                cat "$meta_notes_file"
                            fi
                        else
                            echo "Could not find meta commit for date ${LATEST_DATE}"
                        fi
                        rm -f "$meta_commit_file"
                    fi
                fi
            else
                notes_file="${TEMP_DIR}/${project}_unreleased_notes.md"
                if create_unreleased_notes "$REPO" "$LATEST_TAG" "$notes_file"; then
                    echo "Generated release notes for unreleased changes in $notes_file"
                    cat "$notes_file"
                fi
            fi
        fi
    fi
done

echo "Temporary directory $TEMP_DIR contains all generated files"
# Cleanup commented out for inspection
# rm -rf "$TEMP_DIR"