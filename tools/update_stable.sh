#!/bin/bash

# Check if the required parameters are provided
if [ -z "$1" ]; then
  echo "Usage: $0 <repository> [<organization>] [<release_id>]"
  exit 1
fi

# Set variables
repository="$1"
organization="${2:-ZOSOpenTools}"
release_id="$3"
api_base="https://api.github.com/repos/$organization/$repository"
auth_token="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"

# Function to get the latest release ID
get_latest_release_id() {
  curl -s -H "Authorization: token $auth_token" "$api_base/releases/latest" | jq '.id'
}

# If release_id is not provided, use the latest release ID
if [ -z "$release_id" ]; then
  release_id=$(get_latest_release_id)
fi

echo "Fetching release data for release ID: $release_id"

# Get release details
release_data=$(curl -s -H "Authorization: token $auth_token" "$api_base/releases/$release_id")
if [ $? -ne 0 ]; then
  echo "Error: Failed to fetch release data"
  exit 1
fi

release_name=$(echo "$release_data" | jq -r '.name')
release_body=$(echo "$release_data" | jq -r '.body')
release_tag=$(echo "$release_data" | jq -r '.tag_name')

echo "Checking if stable release exists"

# Check if stable release exists
stable_release_id=$(curl -s -H "Authorization: token $auth_token" "$api_base/releases/tags/stable" | jq '.id')
if [ $? -ne 0 ]; then
  echo "Error: Failed to check if stable release exists"
  exit 1
fi

# If stable release exists, delete it
if [ "$stable_release_id" != "null" ]; then
  echo "Deleting existing stable release with ID: $stable_release_id"
  curl -s -X DELETE -H "Authorization: token $auth_token" "$api_base/releases/$stable_release_id"
  if [ $? -ne 0 ]; then
    echo "Error: Failed to delete stable release"
    exit 1
  fi
fi

echo "Creating new stable release"

# Create a new stable release
curl -s -X POST -H "Authorization: token $auth_token" -H "Content-Type: application/json" \
  -d "{\"tag_name\": \"stable\", \"name\": \"$release_name\", \"body\": \"$release_body\", \"target_commitish\": \"$release_tag\"}" \
  "$api_base/releases"
if [ $? -ne 0 ]; then
  echo "Error: Failed to create new stable release"
  exit 1
fi

echo "Marking previous latest release as the latest again"

# Mark the previous latest release as the latest again
curl -s -X PATCH -H "Authorization: token $auth_token" -H "Content-Type: application/json" \
  -d "{\"prerelease\": false}" \
  "$api_base/releases/$release_id"
if [ $? -ne 0 ]; then
  echo "Error: Failed to mark previous latest release as the latest again"
  exit 1
fi

echo "Done"

