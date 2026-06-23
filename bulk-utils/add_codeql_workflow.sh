#!/bin/bash

# Title: Add CodeQL workflow if it doesn't already exist
#
# To be executed on workstation, via multi-gitter.
# Assumes you've cloned this repo (meta) down and are running this script from the repo root.
# This will use the YAML file present in ./data/codeql-workflow.yml

# The file that should be added to the repo
CODEQL_FILE=./data/codeql-workflow.yml

# Relative from any repo's root
CODEQL_IN_REP=.github/workflows/codeql.yml

# If the file doesn't exist, add it
if [ ! -f "$CODEQL_IN_REP" ]; then
    echo "Adding CodeQL workflow to $REPOSITORY"
    
    mkdir -p .github/workflows
    cp $CODEQL_FILE $CODEQL_IN_REP
    
    # Add CodeQL badge to README.md if it doesn't already exist
    if ! grep -q "CodeQL" README.md 2>/dev/null; then
        LINE="[![CodeQL](https://github.com/$REPOSITORY/actions/workflows/codeql.yml/badge.svg)](https://github.com/$REPOSITORY/actions/workflows/codeql.yml)"
        printf '%s\n\n' "$LINE" | cat - README.md > tmpfile && mv tmpfile README.md
        echo "Added CodeQL badge to README.md"
    fi
    
    echo "CodeQL workflow added successfully"
else
    echo "CodeQL workflow already exists in $REPOSITORY, skipping"
fi

# Made with Bob
