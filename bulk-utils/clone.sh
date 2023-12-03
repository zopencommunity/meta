#!/bin/bash

# Title: Clone all repositories locally while maintaining their group folder structure
# To be executed via multi-gitter, to create a local stash of all repos (configurable) locally.
# This is a one-time script, and cannot conditionally switch to `git pull` (to update local stash) instead of `git clone` if the repo already exists locally.

mkdir -p ~/_dev/zopen-multi-gitter/$REPOSITORY
cp -r . ~/_dev/zopen-multi-gitter/$REPOSITORY
