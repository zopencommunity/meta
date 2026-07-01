#!/bin/bash

# Title: Add CodeQL workflow if it doesn't already exist
#
# To be executed on workstation, via multi-gitter.
# multi-gitter runs this script from inside each cloned repo's root,
# so we resolve the data file relative to this script's own location (in meta).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# The file that should be added to the repo
CODEQL_FILE="$SCRIPT_DIR/../data/codeql-workflow.yml"

# Relative from any repo's root
CODEQL_IN_REP=.github/workflows/codeql.yml

# Always add/update the workflow file
echo "Adding CodeQL workflow to $REPOSITORY"

mkdir -p .github/workflows
cp $CODEQL_FILE $CODEQL_IN_REP

echo "CodeQL workflow file added/updated at $CODEQL_IN_REP"

# Add CodeQL badge to README.md if it doesn't already exist
if [ -f README.md ]; then
    if ! grep -q "CodeQL" README.md 2>/dev/null; then
        LINE="[![CodeQL](https://github.com/$REPOSITORY/actions/workflows/codeql.yml/badge.svg)](https://github.com/$REPOSITORY/actions/workflows/codeql.yml)"
        printf '%s\n\n' "$LINE" | cat - README.md > tmpfile && mv tmpfile README.md
        echo "Added CodeQL badge to README.md"
    else
        echo "CodeQL badge already exists in README.md"
    fi
else
    echo "No README.md found, skipping badge addition"
fi

echo "CodeQL workflow setup completed successfully"

# Made with Bob
