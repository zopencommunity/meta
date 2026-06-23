# CodeQL Testing Guide for Forked Repositories

This guide provides step-by-step instructions for testing the CodeQL workflow in your forked repositories before rolling it out to the entire zopen community.

## Prerequisites

- GitHub account with forked repositories
- `multi-gitter` tool installed (optional, for bulk testing)
- GitHub Personal Access Token with appropriate permissions

## Setup Overview

```
Your Fork Structure:
├── Sanjana-Kondalwade/meta (centralized workflow repo)
└── Sanjana-Kondalwade/test-repos (repos to test CodeQL on)
```

## Step 1: Prepare Your Forked Meta Repository

### 1.1 Verify the Centralized Workflow

The centralized CodeQL workflow is already in your forked meta repo at:
```
.github/workflows/codeql.yml
```

This workflow:
- Accepts parameters (repo, branch, languages, build-mode)
- Clones the meta repository for zopen build tools
- Creates CodeQL configuration
- Runs CodeQL analysis
- Uploads results to GitHub Security

### 1.2 Verify the Workflow Template

Check that `data/codeql-workflow.yml` references your fork:
```yaml
uses: Sanjana-Kondalwade/meta/.github/workflows/codeql.yml@main
```

✅ This is already configured correctly for your testing!

## Step 2: Test on a Single Repository

### 2.1 Manual Testing (Recommended First)

1. **Choose a test repository** (e.g., a forked port repository)

2. **Add the workflow manually**:
   ```bash
   cd /path/to/your/test-repo
   
   # Create workflows directory if it doesn't exist
   mkdir -p .github/workflows
   
   # Copy the workflow template
   cp /path/to/your/meta/data/codeql-workflow.yml .github/workflows/codeql.yml
   
   # Commit and push
   git add .github/workflows/codeql.yml
   git commit -m "Add CodeQL workflow for testing"
   git push origin main
   ```

3. **Verify the workflow runs**:
   - Go to your repository on GitHub
   - Click on "Actions" tab
   - You should see "CodeQL" workflow
   - Click on it to see the run details

4. **Check the results**:
   - Go to "Security" tab → "Code scanning"
   - Review any findings
   - Verify no false positives from test files

### 2.2 What to Look For

✅ **Success Indicators**:
- Workflow completes without errors
- Build step succeeds
- CodeQL analysis completes
- Results appear in Security tab
- Test files are excluded from scanning

❌ **Common Issues**:
- Build failures (check zopen build compatibility)
- Permission errors (verify security-events permission)
- Timeout issues (may need to adjust build process)

## Step 3: Test with Multi-Gitter (Bulk Testing)

### 3.1 Install Multi-Gitter

```bash
# macOS
brew install lindell/multi-gitter/multi-gitter

# Linux
curl -s https://raw.githubusercontent.com/lindell/multi-gitter/master/install.sh | sh

# Or download from releases
# https://github.com/lindell/multi-gitter/releases
```

### 3.2 Set Up GitHub Token

```bash
# Create a token at: https://github.com/settings/tokens
# Required scopes: repo, workflow

export GITHUB_TOKEN="your_token_here"
```

### 3.3 Test on Multiple Repositories

1. **Dry run first** (see what would happen):
   ```bash
   cd /path/to/your/meta
   
   multi-gitter run ./bulk-utils/add_codeql_workflow.sh \
     --config cicd/multi-gitter-codeql-config \
     --repo Sanjana-Kondalwade/test-repo1 \
     --repo Sanjana-Kondalwade/test-repo2 \
     --token $GITHUB_TOKEN \
     --dry-run
   ```

2. **Review the dry run output**:
   - Check which files would be modified
   - Verify the PR title and body
   - Ensure correct repositories are targeted

3. **Execute actual deployment** (remove --dry-run):
   ```bash
   multi-gitter run ./bulk-utils/add_codeql_workflow.sh \
     --config cicd/multi-gitter-codeql-config \
     --repo Sanjana-Kondalwade/test-repo1 \
     --repo Sanjana-Kondalwade/test-repo2 \
     --token $GITHUB_TOKEN
   ```

4. **What happens**:
   - Multi-gitter clones each repository
   - Runs the `add_codeql_workflow.sh` script
   - Creates a branch `add-codeql-workflow`
   - Commits the changes
   - Creates a Pull Request
   - Adds CodeQL badge to README.md

### 3.4 Review and Merge PRs

1. **Check each PR**:
   - Review the changes
   - Verify workflow file is correct
   - Check README badge was added
   - Merge the PR

2. **Monitor workflow execution**:
   - After merging, workflow should trigger
   - Check Actions tab for execution
   - Verify results in Security tab

## Step 4: Testing Checklist

Use this checklist for each test repository:

### Pre-Deployment
- [ ] Repository is forked/cloned
- [ ] Meta repository reference is correct in workflow
- [ ] GitHub token has required permissions

### Deployment
- [ ] Workflow file added successfully
- [ ] PR created (if using multi-gitter)
- [ ] Changes reviewed and merged

### Post-Deployment
- [ ] Workflow triggers on push to main
- [ ] Workflow triggers on pull request
- [ ] Manual workflow dispatch works
- [ ] Scheduled run is configured (weekly)
- [ ] Build completes successfully
- [ ] CodeQL analysis completes
- [ ] Results appear in Security tab
- [ ] No false positives from test files
- [ ] Badge appears in README.md

### Validation
- [ ] Review security findings
- [ ] Verify findings are relevant
- [ ] Check performance (execution time)
- [ ] Confirm no impact on other workflows

## Step 5: Document Issues and Improvements

Keep track of any issues you encounter:

### Issue Template
```markdown
**Repository**: [repo-name]
**Issue**: [description]
**Error Message**: [if applicable]
**Resolution**: [how you fixed it]
**Notes**: [any additional context]
```

### Common Issues and Solutions

| Issue | Solution |
|-------|----------|
| Build timeout | Increase timeout or optimize build |
| Permission denied | Check security-events permission |
| Meta clone fails | Verify network/GitHub access |
| False positives | Update paths-ignore in config |
| Workflow not triggering | Check branch names and triggers |

## Step 6: Prepare for Production Rollout

Once testing is successful:

1. **Update workflow reference** in `data/codeql-workflow.yml`:
   ```yaml
   # Change from:
   uses: Sanjana-Kondalwade/meta/.github/workflows/codeql.yml@main
   
   # To:
   uses: zopencommunity/meta/.github/workflows/codeql.yml@main
   ```

2. **Update multi-gitter config** if needed:
   - Adjust `org` to `zopencommunity`
   - Review `skip-repo` list
   - Update PR title/body if needed

3. **Document your findings**:
   - Create a summary of test results
   - List any issues encountered
   - Recommend any configuration changes
   - Share with community maintainers

## Example Test Scenarios

### Scenario 1: Simple C/C++ Port
```bash
# Test on a basic port with C/C++ code
cd /path/to/simple-port
cp /path/to/meta/data/codeql-workflow.yml .github/workflows/codeql.yml
git add .github/workflows/codeql.yml
git commit -m "Test: Add CodeQL workflow"
git push
```

### Scenario 2: Complex Build Process
```bash
# Test on a port with complex build requirements
# May need to adjust build-mode or add custom build steps
```

### Scenario 3: Multiple Languages
```bash
# If a port has multiple languages, update the workflow:
# Edit .github/workflows/codeql.yml
# Change: languages: "c-cpp,python"
```

## Monitoring and Metrics

Track these metrics during testing:

- **Success Rate**: % of workflows that complete successfully
- **Execution Time**: Average time for workflow to complete
- **Findings**: Number and severity of security issues found
- **False Positives**: Issues that aren't real vulnerabilities
- **Build Failures**: Repos where build step fails

## Getting Help

If you encounter issues:

1. **Check workflow logs**: Actions tab → Failed workflow → View logs
2. **Review documentation**: `docs/CODEQL_ROLLOUT.md`
3. **Search existing issues**: GitHub issues in meta repo
4. **Ask for help**: Create an issue with details

## Next Steps After Testing

1. ✅ Complete testing on 3-5 diverse repositories
2. ✅ Document all findings and issues
3. ✅ Update configurations based on learnings
4. ✅ Get approval from community maintainers
5. ✅ Update workflow reference to production
6. ✅ Execute pilot rollout (10-20 repos)
7. ✅ Execute full rollout (300+ repos)

## Quick Reference Commands

```bash
# Test single repo manually
cd /path/to/test-repo
mkdir -p .github/workflows
cp /path/to/meta/data/codeql-workflow.yml .github/workflows/codeql.yml
git add .github/workflows/codeql.yml
git commit -m "Add CodeQL workflow"
git push

# Test with multi-gitter (dry run)
multi-gitter run ./bulk-utils/add_codeql_workflow.sh \
  --config cicd/multi-gitter-codeql-config \
  --repo YOUR_USERNAME/test-repo \
  --token $GITHUB_TOKEN \
  --dry-run

# Test with multi-gitter (actual)
multi-gitter run ./bulk-utils/add_codeql_workflow.sh \
  --config cicd/multi-gitter-codeql-config \
  --repo YOUR_USERNAME/test-repo \
  --token $GITHUB_TOKEN

# Check workflow status
gh run list --repo YOUR_USERNAME/test-repo --workflow=codeql.yml

# View workflow logs
gh run view --repo YOUR_USERNAME/test-repo
```

## Success Criteria

Your testing is complete when:

- ✅ Workflow runs successfully on at least 3 different repositories
- ✅ No critical issues or blockers identified
- ✅ Build process works with zopen integration
- ✅ Security findings are accurate and relevant
- ✅ Performance is acceptable (< 15 minutes per run)
- ✅ Documentation is clear and complete
- ✅ Community maintainers approve the approach

Good luck with your testing! 🚀