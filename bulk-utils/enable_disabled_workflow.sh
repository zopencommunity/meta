#!/bin/bash

# Title: If a workflow exists, check if it's disabled. If so, enable it.

# Relative from any repo's root
WORKFLOW_IN_REP=.github/workflows/bump.yml

HEADERS="\"Accept: application/vnd.github+json\" -H \"X-GitHub-Api-Version: 2022-11-28\""

WORKFLOW_LISTING="gh api -H $HEADERS /repos/$REPOSITORY/actions/workflows | jq '.workflows[] | select(.path | contains(\"bump.yml\"))'"
LISTING=$(eval "$WORKFLOW_LISTING")

WORKFLOW_ID=$(echo "$LISTING" | jq '.id')
WORKFLOW_STATE=$(echo "$LISTING" | jq '.state')

ENABLE_WORKFLOW="gh api --method PUT -H $HEADERS /repos/$REPOSITORY/actions/workflows/$WORKFLOW_ID/enable"

if [ -f "$WORKFLOW_IN_REP" ] && [[ "$WORKFLOW_STATE" == \""disabled_inactivity\"" ]]; then
  echo "----------------"
  eval "$ENABLE_WORKFLOW"
  echo "Workflow enabled"
  echo "----------------"
fi
