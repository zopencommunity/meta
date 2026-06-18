# CodeQL Rollout Guide for zopen Community

This guide explains how to roll out CodeQL security scanning workflows to all 300+ repositories in the zopen community.

## Overview

The CodeQL rollout uses a reusable workflow approach where:
- The central `meta` repository contains the reusable CodeQL workflow
- Individual repositories call this workflow with minimal configuration
- Automated scripts handle the bulk deployment using `multi-gitter`

## Prerequisites

1. **Install multi-gitter**:
   ```bash
   go install github.com/lindell/multi-gitter@latest
   ```

2. **Install GitHub CLI** (for repository counting):
   ```bash
   # macOS
   brew install gh
   
   # Or download from https://cli.github.com/
   ```

3. **Set up GitHub Token**:
   ```bash
   export GITHUB_TOKEN=your_personal_access_token
   ```
   
   Token needs these permissions:
   - `repo` (full control)
   - `workflow` (update workflows)
   - `read:org` (read organization data)

4. **Clone the meta repository**:
   ```bash
   git clone https://github.com/zopencommunity/meta.git
   cd meta
   ```

## Files Created

### 1. `add_codeql_workflow.sh`
The main script that adds CodeQL workflow to each repository. It:
- Detects the primary programming language
- Creates appropriate CodeQL workflow configuration
- Adds CodeQL badge to README.md
- Handles repositories that already have CodeQL

### 2. `codeql-rollout-config`
Multi-gitter configuration for full rollout:
- Targets all `*port` repositories in zopencommunity
- Creates PRs with descriptive titles and bodies
- Processes 5 repositories concurrently
- Skips test/sample repositories

### 3. `test-codeql-rollout.sh`
Test script for validating on 5 repositories before full rollout:
- Creates DRAFT pull requests
- Tests on diverse repository types (curl, git, vim, bash, make)
- Generates detailed logs
- Safe to run multiple times

### 4. `rollout-codeql.sh`
Full rollout script for all 300+ repositories:
- Includes safety confirmations
- Supports dry-run mode
- Generates timestamped logs
- Provides rollout summary

## Rollout Process

### Phase 1: Test Rollout (5 Repositories)

1. **Make scripts executable**:
   ```bash
   chmod +x bulk-utils/add_codeql_workflow.sh
   chmod +x bulk-utils/test-codeql-rollout.sh
   chmod +x bulk-utils/rollout-codeql.sh
   ```

2. **Run test rollout**:
   ```bash
   ./bulk-utils/test-codeql-rollout.sh
   ```

3. **Review test results**:
   - Check the 5 draft PRs created
   - Review `codeql-test-rollout.log`
   - Verify workflows are correct
   - Test one or two by merging and checking if CodeQL runs

4. **Iterate if needed**:
   - If issues found, update `add_codeql_workflow.sh`
   - Close test PRs
   - Re-run test rollout

### Phase 2: Dry Run (All Repositories)

1. **Run dry-run to see what would happen**:
   ```bash
   ./bulk-utils/rollout-codeql.sh --dry-run
   ```

2. **Review dry-run output**:
   - Check which repositories would be affected
   - Verify skip list is correct
   - Ensure no unexpected repositories are included

### Phase 3: Full Rollout

1. **Run full rollout**:
   ```bash
   ./bulk-utils/rollout-codeql.sh
   ```

2. **Monitor progress**:
   - Watch the console output
   - Check the timestamped log file
   - Monitor GitHub for PR creation

3. **Review and merge PRs**:
   - PRs will be created across all repositories
   - Review a sample of PRs
   - Can merge in batches or use GitHub's auto-merge
   - Monitor for any failures

### Phase 4: Post-Rollout

1. **Verify CodeQL scans**:
   - Check GitHub Security tab in repositories
   - Ensure scans are running successfully
   - Review any security findings

2. **Handle failures**:
   - Check log files for errors
   - Manually fix repositories that failed
   - Re-run for specific repositories if needed

3. **Monitor ongoing**:
   - CodeQL runs weekly on schedule
   - Runs on every push and PR
   - Review security alerts as they appear

## Customization

### Modify Test Repositories

Edit `test-codeql-rollout.sh` to change test repositories:
```bash
TEST_REPOS=(
    "zopencommunity/yourrepo1"
    "zopencommunity/yourrepo2"
    # ... add more
)
```

### Adjust Language Detection

Edit `add_codeql_workflow.sh` to modify language detection logic:
```bash
# Add new language detection
if [ -f "Cargo.toml" ]; then
    LANGUAGE="rust"
    BUILD_MODE="autobuild"
fi
```

### Skip Additional Repositories

Edit `codeql-rollout-config` to skip more repositories:
```yaml
skip-repo:
  - zopencommunity/repo-to-skip
  - zopencommunity/another-repo
```

### Change Concurrency

Edit `codeql-rollout-config` to process more/fewer repos at once:
```yaml
concurrent: 10  # Process 10 at a time instead of 5
```

## Troubleshooting

### Multi-gitter Authentication Issues
```bash
# Verify token is set
echo $GITHUB_TOKEN

# Test GitHub CLI authentication
gh auth status
```

### Script Permission Denied
```bash
chmod +x bulk-utils/*.sh
```

### Repository Already Has CodeQL
The script automatically skips repositories with existing CodeQL workflows.

### PR Creation Failed
Check the log file for specific errors. Common issues:
- Token permissions insufficient
- Repository archived or disabled
- Branch protection rules blocking

### Language Detection Wrong
Manually update the workflow in the PR or modify the detection logic in `add_codeql_workflow.sh`.

## Rollback

If you need to remove CodeQL workflows:

1. Create a removal script similar to `add_codeql_workflow.sh`
2. Use multi-gitter to remove `.github/workflows/codeql.yml`
3. Remove CodeQL badges from README.md

## Best Practices

1. **Always test first** - Use the test rollout before full deployment
2. **Use dry-run** - Verify what will happen before making changes
3. **Monitor logs** - Keep log files for troubleshooting
4. **Batch merging** - Don't merge all PRs at once; do in batches
5. **Review security findings** - Act on CodeQL alerts promptly
6. **Keep workflows updated** - Update the reusable workflow in meta as needed

## Support

For issues or questions:
- Check log files first
- Review multi-gitter documentation: https://github.com/lindell/multi-gitter
- Review CodeQL documentation: https://codeql.github.com/docs/
- Open an issue in the meta repository

## Timeline Estimate

- Test rollout: 10-15 minutes
- Dry run: 5-10 minutes
- Full rollout: 2-4 hours (depending on API rate limits)
- PR review and merge: 1-2 days (can be automated)
- Initial CodeQL scans: 1-2 days (runs asynchronously)

## Success Metrics

After rollout, you should see:
- ✅ CodeQL workflows in all target repositories
- ✅ CodeQL badges in README files
- ✅ Security tab populated with scan results
- ✅ Weekly scheduled scans running
- ✅ Scans on every push and PR