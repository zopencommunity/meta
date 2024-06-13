#!/usr/bin/env bash
# 
# Quick Install tool for zopen's meta package
# Assumes you have Curl and Bash installed (likely through Open Enterprise Foundation)

if [[ $(uname) != "OS/390" ]]; then
  echo "Error: This script is only for z/OS systems."
  exit 1
fi

if ! command -v curl > /dev/null 2>&1; then
  echo "Error: 'curl' command not found. Please install curl."
  exit 1
fi

# Download the latest json
url=$(curl --fail-with-body --silent -L https://raw.githubusercontent.com/ZOSOpenTools/meta/main/docs/api/zopen_releases_latest.json)
if [ $? -gt 0 ]; then
  echo "Error: Curl failed due to: \"$url\""
fi

# TODO: check if jq is present, and use it instead of this
url=$(echo "$url" | /bin/tr ' ' '\n' |  grep "https://github.com/ZOSOpenTools/metaport/releases/download/" |  /bin/sed -e 's/.*\(https:\/\/github.com\/ZOSOpenTools\/metaport\/releases\/download\/[^"]*\.pax\.Z\).*/\1/')
paxFile=$(basename "$url");

echo "Downloading z/OS Open Tools meta.pax.Z..."

url=$(curl --fail-with-body -O -L "$url")
if [ $? -gt 0 ]; then
  echo "Error: Curl failed due to: \"$url\""
fi

if [ ! -f $paxFile ]; then
  echo "Error: $paxFile not present"
fi

# Extract meta.pax.Z
echo "Extracting $paxFile..."
paxOutput=$(pax -rvf "$paxFile" 2>&1)
if [ $? -gt 0 ]; then
   echo "Error: Failed to unpax"
fi

dir=$(echo "$paxOutput" | head -1)

set -e
echo "Moving to extracted directory..."
cd "$dir"

echo "Setting up environment..."
source ./.env

echo "Initializing zopen tools..."
zopen init
