#!/usr/bin/env bash
#
# Quick Install tool for zopen's meta package
# Assumes you have Curl and Bash installed (likely through Open Enterprise Foundation)
# Downloads and extracts meta into the current directory

if [[ $(uname) != "OS/390" ]]; then
  echo "Error: This script is only for z/OS systems."
  exit 1
fi

if ! command -v curl > /dev/null 2>&1; then
  echo "Error: 'curl' command not found. Please install curl. You can obtain curl from IBM Open Enterprise Foundation for z/OS."
  exit 1
fi

if ! command -v jq > /dev/null 2>&1; then
  echo "Error: 'jq' command not found. Please install jq. You can obtain jq from IBM Open Enterprise Foundation for z/OS."
  exit 1
fi

ZOPEN_RELEASE_JSON="https://raw.githubusercontent.com/zopencommunity/meta/main/docs/api/zopen_releases.json"

# ----------------------------
# DOWNLOAD RELEASE JSON
# ----------------------------
echo "> Getting latest data from zopen community..."
json=$(curl --fail-with-body --silent -L "$ZOPEN_RELEASE_JSON")
if [ $? -gt 0 ]; then
  echo "Error: Curl failed to download release json $ZOPEN_RELEASE_JSON due to: \"$json\""
  exit 1
fi

# ----------------------------
# Filter only STABLE metaport releases
url=$(echo "$json" | jq -r '
  first(
    .release_data.meta[]? 
    | select(.tag_name | startswith("STABLE_")) 
    | .assets[0].url
  )
')

paxFile=$(basename "$url")


# ----------------------------
# DOWNLOAD FILE
# ----------------------------
echo "> Downloading zopen community package..."
response=$(curl --fail-with-body -O -L "$url")
if [ $? -gt 0 ]; then
  echo "Error: Curl failed to download STABLE zopen meta due to: \"$response\"."
  exit 1
fi

if [ ! -f "$paxFile" ]; then
  echo "Error: $paxFile not present after download."
  exit 1
fi

# ----------------------------
# EXTRACT
# ----------------------------
echo "> Extracting $paxFile..."
paxOutput=$(pax -rvf "$paxFile" 2>&1)
if [ $? -gt 0 ]; then
   echo "Error: Failed to unpax file $paxFile."
   exit 1
fi

echo "> Cleaning up pax file $paxFile..."
rm -vf "$paxFile"
if [ $? -gt 0 ]; then
   echo "Warning: Failed to remove pax file $paxFile. Installation continues."
fi

dir=$(echo "$paxOutput" | head -1)
if [ ! -d "$dir" ]; then
  echo "Error: $dir is not a valid directory."
  exit 1
fi

set -e

# ----------------------------
# INSTALL
# ----------------------------
echo "> Moving to extracted directory..."
cd "$dir"

echo "> Setting up environment..."
source ./.env

echo "> Initializing zopen tools..."
zopen init

echo "> Cleaning up extracted directory..."
cd ..
rm -rvf "$dir"

echo "> zopen meta package installed successfully (stable release)."

exit 0

