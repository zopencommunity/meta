# CodeQL Rollout Guide for Sanjana-Kondalwade Repositories

This guide explains how to add CodeQL security scanning workflows to all repositories with "port" in their name in the Sanjana-Kondalwade organization.

## Overview

The CodeQL workflow will be added to repositories like:
- `sedport`
- `vimport`
- Any other repository containing "port" in its name

Each repository will get a workflow file that:
- Uses the reusable workflow from `Sanjana-Kondalwade/meta/.github/workflows/codeql.yml@main`
- Runs on push to main, pull requests, pull_request_target events
- Runs weekly on Monday at midnight
- Can be triggered manually
- Automatically detects the programming language (C/C++, Python, JavaScript, etc.)
- Shows results in the Security tab and Actions tab

## Prerequisites

### 1. Install Required Tools

#### GitHub CLI (gh)
```bash
# macOS
brew install gh

# Linux
# See https://github.com/cli/cli#installation
```

#### multi-gitter
```bash
go install github.com/lindell/multi-gitter@latest
```

### 2. Set Up GitHub Token

Create a GitHub Personal Access Token with the following permissions:
- `repo` (full control of private repositories)
- `workflow` (update GitHub Action workflows)

Then export it:
```bash
export GITHUB_TOKEN=your_github_token_here
```

### 3. Authenticate GitHub CLI
```bash
gh auth login
```

## Step-by-Step Process

### Step 1: List Target Repositories

First, see which repositories will be affected:

```bash
./bulk-utils/list-sanjana-repos.sh
```

This will show:
- All repositories containing "port" in their name
- Total count of repositories to process
- Any repositories that will be skipped

### Step 2: Dry Run

Test the rollout without making any actual changes:

```bash
./bulk-utils/rollout-codeql-sanjana.sh --dry-run
```

This will:
- Show what would be done
- Not create any PRs or make changes
- Help you verify everything is configured correctly

### Step 3: Execute Full Rollout

When you're ready, run the actual rollout:

```bash
./bulk-utils/rollout-codeql-sanjana.sh
```

You'll be asked to confirm by typing `YES`.

The script will:
- Process up to 3 repositories concurrently
- Create a pull request in each repository
- Add the CodeQL workflow file
- Log all actions to a timestamped log file

### Step 4: Review and Merge PRs

After the rollout:
1. Check your GitHub notifications for new pull requests
2. Review each PR to ensure the workflow is correct
3. Merge the PRs to enable CodeQL scanning
4. Monitor the Actions tab to see the first scan run

## What Gets Added

Each repository will receive a `.github/workflows/codeql.yml` file like this:

```yaml
name: "CodeQL"

permissions:
  actions: read
  contents: read
  security-events: write

on:
  push:
    branches: ["main"]
  pull_request:
    branches: ["main"]
  pull_request_target:
    types: [opened, synchronize, reopened]
  schedule:
    - cron: "0 0 * * 1"
  workflow_dispatch:

jobs:
  codeql:
    uses: Sanjana-Kondalwade/meta/.github/workflows/codeql.yml@main
    secrets: inherit
    permissions:
      actions: read
      contents: read
      security-events: write
    with:
      languages: "c-cpp"  # Auto-detected based on repository
      build-mode: "none"  # Auto-detected based on repository
```

## Configuration Files

### `codeql-sanjana-config`
Contains the multi-gitter configuration:
- Organization: `Sanjana-Kondalwade`
- Repository pattern: `.*port.*` (contains "port")
- Branch name: `add-codeql-workflow`
- Concurrent processing: 3 repositories at a time
- Skip list: `meta` repository

### `add_codeql_workflow_sanjana.sh`
The script that runs in each repository to:
- Detect the programming language
- Create the appropriate CodeQL workflow file
- Set the correct build mode

## Troubleshooting

### "multi-gitter not found"
Install it with: `go install github.com/lindell/multi-gitter@latest`

### "GITHUB_TOKEN not set"
Export your token: `export GITHUB_TOKEN=your_token_here`

### "Permission denied"
Make scripts executable: `chmod +x bulk-utils/*.sh`

### Workflow already exists
The script will skip repositories that already have a CodeQL workflow.

### Failed to create PR
Check the log file for details. You may need to:
- Verify your GitHub token has correct permissions
- Check if the repository allows PRs
- Ensure you have write access to the repository

## Monitoring Results

After merging the PRs:

1. **Actions Tab**: See workflow runs at `https://github.com/Sanjana-Kondalwade/REPO_NAME/actions`
2. **Security Tab**: View CodeQL findings at `https://github.com/Sanjana-Kondalwade/REPO_NAME/security/code-scanning`
3. **Weekly Scans**: Workflows run automatically every Monday
4. **Manual Trigger**: Use "Run workflow" button in Actions tab

## Example Workflow

```bash
# 1. List repositories
./bulk-utils/list-sanjana-repos.sh

# 2. Test with dry-run
./bulk-utils/rollout-codeql-sanjana.sh --dry-run

# 3. Execute rollout
./bulk-utils/rollout-codeql-sanjana.sh

# 4. Review log file
cat codeql-sanjana-rollout-*.log

# 5. Check PRs in GitHub
gh pr list --repo Sanjana-Kondalwade/sedport
gh pr list --repo Sanjana-Kondalwade/vimport
```

## Support

If you encounter issues:
1. Check the log file: `codeql-sanjana-rollout-*.log`
2. Review the multi-gitter documentation: https://github.com/lindell/multi-gitter
3. Verify your GitHub token permissions
4. Ensure the meta repository's reusable workflow is accessible

## Files Created

- `bulk-utils/add_codeql_workflow_sanjana.sh` - Script to add workflow to each repo
- `bulk-utils/codeql-sanjana-config` - Configuration for multi-gitter
- `bulk-utils/rollout-codeql-sanjana.sh` - Main rollout script
- `bulk-utils/list-sanjana-repos.sh` - List target repositories
- `bulk-utils/README_SANJANA_CODEQL.md` - This guide