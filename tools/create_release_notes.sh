#!/usr/bin/env bash

set -e  # Exit on error

# Default values and flags
MODE="retro"  # Default mode
PROJECTS=""
LIMIT=250
VERBOSE=false # Verbose output flag - default off
OUTPUT_DIR=""  # Output directory - default to temp dir
OUTPUT_TYPE="markdown" # Default output type - "markdown" or "text"

print_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -m, --mode MODE      Operation mode: 'retro' (update all releases) or 'release' (generate for new release)"
    echo "  -p, --projects LIST Comma-separated list of projects (default: all zopencommunity projects)"
    echo "  -l, --limit NUM      Limit number of releases to process (default: 250)"
    echo "  -o, --outputdir DIR  Output directory for generated files (optional, defaults to temp dir)"
    echo "  -v, --verbose      Enable verbose output"
    echo "  -t, --outputtype TYPE Output type: 'markdown' or 'text' (default: markdown)"
    echo "  -h, --help         Show this help message"
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
        -o|--outputdir)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift 1
            ;;
        -t|--outputtype)
            OUTPUT_TYPE="$2"
            if [[ "$OUTPUT_TYPE" != "markdown" && "$OUTPUT_TYPE" != "text" ]]; then
                echo "Error: Output type must be either 'markdown' or 'text'"
                exit 1
            fi
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

# Determine output directory
if [ -z "$OUTPUT_DIR" ]; then
    TEMP_DIR=$(mktemp -d)
    OUTPUT_BASE_DIR="$TEMP_DIR"
    if [[ "$VERBOSE" == "true" ]]; then
        echo "Using temporary directory: $TEMP_DIR" >&2
    fi
else
    OUTPUT_BASE_DIR="$OUTPUT_DIR"
    mkdir -p "$OUTPUT_BASE_DIR" # Create output directory if it doesn't exist
    if [[ "$VERBOSE" == "true" ]]; then
        echo "Using output directory: $OUTPUT_BASE_DIR" >&2
    fi
fi

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
        if [[ "$VERBOSE" == "true" ]]; then
            echo "Rate limit nearly exhausted (${RATE_REMAINING} remaining). Waiting ${wait_time} seconds for reset..." >&2
        fi
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

        if [[ "$VERBOSE" == "true" ]]; then
            echo "API call failed, retrying in 5 seconds..." >&2
        fi
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

    local commit_link
    if [[ "$OUTPUT_TYPE" == "markdown" ]]; then
        # Create Markdown commit link
        commit_link="[${commit_sha:0:7}](https://github.com/zopencommunity/${project}/commit/${commit_sha})"
    else
        # Plain text URL
        commit_link="https://github.com/zopencommunity/${project}/commit/${commit_sha}"
    fi

    # Clean up the message while preserving content in parentheses
    first_line=$(echo "$first_line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    # If it's a conventional commit format (type(scope): message)
    if [[ "$first_line" =~ ^([^(:]+)(\([^)]+\)):(.+)$ ]]; then
        local type="${BASH_REMATCH[1]}"
        local scope="${BASH_REMATCH[2]}"
        local message="${BASH_REMATCH[3]}"

        # Clean up the message while preserving content
        message=$(echo "$message" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

        if [[ "$OUTPUT_TYPE" == "markdown" ]]; then
            printf "* %s%s:%s (%s)\n" "$type" "$scope" "$message" "$commit_link"
        else
            printf "%s%s:%s (%s)\n" "$type" "$scope" "$message" "$commit_link" # Plain text format
        fi
    else
        # For regular commit messages, preserve the full message
        if [ -n "$first_line" ]; then
            if [[ "$OUTPUT_TYPE" == "markdown" ]]; then
                printf "* %s (%s)\n" "$first_line" "$commit_link"
            else
                printf "%s (%s)\n" "$first_line" "$commit_link" # Plain text format
            fi
        fi
    fi
}

# Function to create release notes for a comparison
create_release_notes() {
    local repo="$1"
    local prev_tag="$2"
    local curr_tag="$3"
    local output_file="$4"

    local title_md="## [Changes ${prev_tag}...${curr_tag}](https://github.com/${repo}/compare/${prev_tag}...${curr_tag})"
    local title_text="Changes ${prev_tag}...${curr_tag} (https://github.com/${repo}/compare/${prev_tag}...${curr_tag})"
    local title
    if [[ "$OUTPUT_TYPE" == "markdown" ]]; then
        title="$title_md"
    else
        title="$title_text"
    fi
    generate_notes "$repo" "$prev_tag" "$curr_tag" "$output_file" "$title"
}

# Function to create release notes for unreleased changes
create_unreleased_notes() {
    local repo="$1"
    local last_tag="$2"
    local output_file="$3"

    local title_md="## [Changes since ${last_tag}](https://github.com/${repo}/compare/${last_tag}...HEAD)"
    local title_text="Changes since ${last_tag} (https://github.com/${repo}/compare/${last_tag}...HEAD)"
    local title
    if [[ "$OUTPUT_TYPE" == "markdown" ]]; then
        title="$title_md"
    else
        title="$title_text"
    fi
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
    local compare_file="${OUTPUT_BASE_DIR}/compare.json" # Use OUTPUT_BASE_DIR
    if ! gh_api_call "repos/${repo}/compare/${base_ref}...${target_ref}" "$compare_file"; then
        echo "Error getting comparison data, skipping..." >&2
        rm -f "$compare_file"
        return 1
    fi
    if [[ "$VERBOSE" == "true" ]]; then
        echo "Got comparison data: repos/${repo}/compare/${base_ref}...${target_ref} -> $compare_file" >&2
    fi

    # Start outputting to the file
    echo "$title" > "$output_file" # Print title first

    if [[ "$OUTPUT_TYPE" == "text" ]]; then
        echo "--------------------" >> "$output_file" # Title underline
        echo "" >> "$output_file"                     # Blank line after title section
        echo "Pull Requests" >> "$output_file"          # "Pull Requests" header
        echo "-------------" >> "$output_file"          # Underline for "Pull Requests"
    elif [[ "$OUTPUT_TYPE" == "markdown" ]]; then
        echo "### Pull Requests" >> "$output_file"      # Markdown "Pull Requests" header
    else
        echo "Pull Requests" >> "$output_file"          # Default plain text header (no underline) - should not reach here but for safety
    fi


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
            local pr_file="${OUTPUT_BASE_DIR}/pr.json" # Use OUTPUT_BASE_DIR
            if gh_api_call "repos/${repo}/pulls/${pr_num}" "$pr_file"; then
                pr_title=$(jq -r '.title' "$pr_file")
                pr_title=${pr_title//[[\]]/}
                local pr_line
                if [[ "$OUTPUT_TYPE" == "markdown" ]]; then
                    pr_line="* ${pr_title} ([#${pr_num}](https://github.com/${repo}/pull/${pr_num}))"
                else
                    pr_line="${pr_title} (PR #${pr_num} - https://github.com/${repo}/pull/${pr_num})" # Plain text PR line
                fi
                echo "$pr_line" >> "$output_file"
                has_prs=true
                if [[ "$VERBOSE" == "true" ]]; then
                    echo "Processed PR #${pr_num}: ${pr_title}" >&2
                fi

                local commits_file="${OUTPUT_BASE_DIR}/commits.json" # Use OUTPUT_BASE_DIR
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
    if [[ "$OUTPUT_TYPE" == "markdown" ]]; then
        echo -e "\n### Direct Changes" >> "$output_file"
    else
        echo -e "\nDirect Changes" >> "$output_file" # Plain text heading
        echo "----------------" >> "$output_file"      # Underline for text header (using hyphens) - NOW ENSURED TO BE PRESENT
    fi
    local has_direct=false

    while read -r line; do
        message=$(echo "$line" | jq -r '.message')
        sha=$(echo "$line" | jq -r '.sha')

        if [ -z "$message" ] || echo "$message" | grep -q '^Merge pull request'; then
            continue
        fi

        first_line=$(echo "$message" | head -n1)
        if [[ "$first_line" =~ ^Updating\ docs/apis ]] ||
           [[ "$first_line" =~ ^Reorder\ doc\ updates ]] ||
           [[ "$first_line" =~ ^Update\ .*\.md$ ]]; then
            continue
        fi

        if [ -n "$sha" ] && [ -z "${pr_commit_map[$sha]+x}" ]; then
            format_commit_message "$sha" "$message" "$project" >> "$output_file"
            has_direct=true
            if [[ "$VERBOSE" == "true" ]]; then
                echo "Processed direct commit: ${sha:0:7} - ${message}" >&2
            fi
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
    if [[ "$VERBOSE" == "true" ]]; then
        echo "Processing project: $project" >&2
    fi
    REPO="zopencommunity/$project"

    # Get releases
    RELEASES=$(gh release list --limit "$LIMIT" --repo "$REPO" --json name,tagName,publishedAt --order asc)
    if [ -z "$RELEASES" ]; then
        if [[ "$VERBOSE" == "true" ]]; then
            echo "No releases found for $REPO, skipping..." >&2
        fi
        continue
    fi
    if [[ "$VERBOSE" == "true" ]]; then
        echo "Retrieved releases for $REPO" >&2
    fi

    if [ "$MODE" = "retro" ]; then
        # Process all releases retrospectively
        prev_tag=""
        echo "$RELEASES" | jq -r '.[] | .tagName' | while read -r curr_tag; do
            if [[ "$VERBOSE" == "true" ]]; then
                echo "Processing retro release: $curr_tag" >&2
            fi
            if [ -n "$prev_tag" ]; then
                file_extension=".md"
                if [[ "$OUTPUT_TYPE" == "markdown" ]]; then
                    file_extension=".md"
                elif [[ "$OUTPUT_TYPE" == "text" ]]; then
                    file_extension=".txt"
                fi
                notes_file="${OUTPUT_BASE_DIR}/${project}_${curr_tag}_notes${file_extension}" # Use correct file extension
                if create_release_notes "$REPO" "$prev_tag" "$curr_tag" "$notes_file"; then
                    if [[ "$VERBOSE" == "true" ]]; then
                        echo "Would execute: gh release edit --repo $REPO $curr_tag --notes-file $notes_file" >&2
                    fi
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
                if [[ "$VERBOSE" == "true" ]]; then
                    echo "Processing metaport changes..." >&2
                fi
                local file_extension
                if [[ "$OUTPUT_TYPE" == "markdown" ]]; then
                    file_extension=".md"
                elif [[ "$OUTPUT_TYPE" == "text" ]]; then
                    file_extension=".txt"
                else
                    file_extension=".md" # Fallback, should not happen
                fi
                notes_file="${OUTPUT_BASE_DIR}/${project}_unreleased_notes${file_extension}" # Use correct file extension
                if create_unreleased_notes "$REPO" "$LATEST_TAG" "$notes_file"; then
                    if [[ "$VERBOSE" == "true" ]]; then
                        echo "Generated release notes for unreleased metaport changes in $notes_file" >&2
                    fi
                    cat "$notes_file"
                fi

                # Get the latest release date for metaport
                LATEST_DATE=$(echo "$RELEASES" | jq -r '.[-1].publishedAt' | cut -d'T' -f1)
                if [ -n "$LATEST_DATE" ]; then
                    if [[ "$VERBOSE" == "true" ]]; then
                        echo "Processing meta changes since ${LATEST_DATE}..." >&2
                    fi

                    # Find the meta commit hash from the release date
                    meta_commit_file="${OUTPUT_BASE_DIR}/meta_commit.json" # Use OUTPUT_BASE_DIR
                    if gh_api_call "repos/zopencommunity/meta/commits?until=${LATEST_DATE}T23:59:59Z&per_page=1" "$meta_commit_file"; then
                        META_COMMIT=$(jq -r '.[0].sha' "$meta_commit_file")
                        if [ -n "$META_COMMIT" ] && [ "$META_COMMIT" != "null" ]; then
                            local file_extension
                            if [[ "$OUTPUT_TYPE" == "markdown" ]]; then
                                file_extension=".md"
                            elif [[ "$OUTPUT_TYPE" == "text" ]]; then
                                file_extension=".txt"
                            else
                                file_extension=".unknown" # Fallback, should not happen
                            fi
                            meta_notes_file="${OUTPUT_BASE_DIR}/meta_unreleased_notes${file_extension}" # Use correct file extension
                            # Create notes for meta changes since the commit at release date
                            if create_unreleased_notes "zopencommunity/meta" "$META_COMMIT" "$meta_notes_file"; then
                                if [[ "$VERBOSE" == "true" ]]; then
                                    echo "Generated release notes for unreleased meta changes in $meta_notes_file" >&2
                                fi
                                cat "$meta_notes_file"
                            fi
                        else
                            if [[ "$VERBOSE" == "true" ]]; then
                                echo "Could not find meta commit for date ${LATEST_DATE}" >&2
                            fi
                        fi
                        rm -f "$meta_commit_file"
                    fi
                fi
            else
                local file_extension
                if [[ "$OUTPUT_TYPE" == "markdown" ]]; then
                    file_extension=".md"
                elif [[ "$OUTPUT_TYPE" == "text" ]]; then
                    file_extension=".txt"
                else
                    file_extension=".unknown" # Fallback, should not happen
                fi
                notes_file="${OUTPUT_BASE_DIR}/${project}_unreleased_notes${file_extension}" # Use correct file extension
                if create_unreleased_notes "$REPO" "$LATEST_TAG" "$notes_file"; then
                    if [[ "$VERBOSE" == "true" ]]; then
                        echo "Generated release notes for unreleased changes in $notes_file" >&2
                    fi
                    cat "$notes_file"
                fi
            fi
        fi
    fi
done

if [[ "$VERBOSE" == "true" ]]; then
    echo "Output directory $OUTPUT_BASE_DIR contains all generated files" >&2
fi
# Cleanup commented out for inspection
# rm -rf "$OUTPUT_BASE_DIR"
