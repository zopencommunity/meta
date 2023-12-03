#!/bin/bash

# Title: add bump.yml and build_and_test.yml if they don't already exist
#
# To be executed on workstation, via multi-gitter.
# Assumes you've cloned this repo (meta) down and are running this script from the repo root like so: ./tools/add_workflows.sh
# This will use YAML files present in ./data/*.yml

# The file that should be added to the repo
BUMP_FILE=./data/bump.yml
BANDT_FILE=./data/build_and_test.yml

# Relative from any repo's root
BUMP_IN_REP=.github/workflows/bump.yml
BANDT_IN_REP=.github/workflows/build_and_test.yml


# If the file doesn't exist, add it
if [ ! -f "$BUMP_IN_REP" ]; then
    echo "cp $BUMP_FILE $BUMP_IN_REP"

    mkdir -p .github/workflows
    cp $BUMP_FILE $BUMP_IN_REP

    LINE="[![Automatic version updates](https://github.com/$REPOSITORY/actions/workflows/bump.yml/badge.svg)](https://github.com/$REPOSITORY/actions/workflows/bump.yml)"
    printf '%s\n\n' "$LINE" | cat - README.md > tmpfile && mv tmpfile README.md
fi

if [ ! -f "$BANDT_IN_REP" ]; then
    echo "cp $BANDT_FILE $BANDT_IN_REP"

    mkdir -p .github/workflows
    cp $BANDT_FILE $BANDT_IN_REP
fi
