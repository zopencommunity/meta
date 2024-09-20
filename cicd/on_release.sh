#!/bin/env bash
#
# This scripts runs after a successful build of a tool
#
set -e

git clone git@github.com:zopencommunity/meta.git meta_update
cd meta_update

# Generate Release cache
python3 tools/create_release_cache.py --verbose --output-file docs/api/zopen_releases.json

# Generate a view of the newly released tools
python3 tools/create_latest_release_doc.py --output docs/newly_released.md

mkdir -p docs/api

# Commit it all back to the repo
git config --global user.email "zosopentools@ibm.com"
git config --global user.name "ZOS Open Tools"
git add docs/*.md
git add docs/images/*.png
git add docs/api/*
git add docs/reference/*
git commit -m "Updating docs/apis/reference"
git pull --rebase
git push origin
