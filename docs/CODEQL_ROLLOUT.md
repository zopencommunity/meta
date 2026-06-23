# CodeQL Rollout Strategy for Zopen Community

This document outlines the strategy for rolling out CodeQL security scanning across 300+ repositories in the zopen community.

## Overview

CodeQL is a semantic code analysis engine that helps identify security vulnerabilities and code quality issues. This rollout uses a centralized reusable workflow approach to maintain consistency and ease of updates across all repositories.

## Architecture

### Centralized Workflow
- **Location**: `zopencommunity/meta/.github/workflows/codeql.yml`
- **Purpose**: Reusable workflow that performs CodeQL analysis
- **Features**:
  - Supports multiple languages (default: C/C++)
  - Configurable build modes
  - Excludes test files and meta directory
  - Integrates with zopen build system

### Individual Repository Workflow
- **Location**: `.github/workflows/codeql.yml` (in each repo)
- **Purpose**: Calls the centralized workflow
- **Template**: `data/codeql-workflow.yml`

## Rollout Strategy

### Phase 1: Testing (Current Phase)

#### Testing in Forked Repositories

1. **Fork Setup**:
   - Fork `zopencommunity/meta` to your account (e.g., `Sanjana-Kondalwade/meta`)
   - This forked meta repo acts as the centralized workflow repository for testing
   - Fork or clone target repositories for testing

2. **Update Workflow Reference**:
   - In `data/codeql-workflow.yml`, the workflow references your fork:
     ```yaml
     uses: Sanjana-Kondalwade/meta/.github/workflows/codeql.yml@main
     ```

3. **Test on Sample Repositories**:
   - Apply the workflow to 2-3 test repositories
   - Verify CodeQL runs successfully
   - Check that security findings are reported correctly
   - Ensure build process works with zopen integration

4. **Validation Checklist**:
   - [ ] Workflow triggers on push to main
   - [ ] Workflow triggers on pull requests
   - [ ] Weekly scheduled scan runs
   - [ ] Manual workflow dispatch works
   - [ ] CodeQL findings appear in Security tab
   - [ ] Build completes successfully
   - [ ] No false positives from test files

### Phase 2: Pilot Rollout

1. **Select Pilot Repositories** (10-20 repos):
   - Choose diverse repositories (different sizes, languages)
   - Include both active and stable repositories
   - Update `data/codeql-workflow.yml` to use production reference:
     ```yaml
     uses: zopencommunity/meta/.github/workflows/codeql.yml@main
     ```

2. **Deploy to Pilot Group**:
   ```bash
   # Using multi-gitter for pilot group
   multi-gitter run ./bulk-utils/add_codeql_workflow.sh \
     --config cicd/multi-gitter-codeql-config \
     --repo zopencommunity/repo1port \
     --repo zopencommunity/repo2port \
     # ... add pilot repos
   ```

3. **Monitor and Iterate**:
   - Review CodeQL findings
   - Address any workflow issues
   - Gather feedback from maintainers
   - Refine configuration if needed

### Phase 3: Full Rollout

1. **Prepare for Bulk Deployment**:
   - Ensure centralized workflow is stable
   - Update multi-gitter configuration
   - Communicate rollout plan to community

2. **Execute Bulk Deployment**:
   ```bash
   # Deploy to all repositories matching pattern
   multi-gitter run ./bulk-utils/add_codeql_workflow.sh \
     --config cicd/multi-gitter-codeql-config \
     --token $GITHUB_TOKEN
   ```

3. **Configuration Details**:
   - **Branch**: `add-codeql-workflow`
   - **PR Title**: "Add CodeQL security scanning workflow"
   - **Target**: All repos matching `.*port$` pattern
   - **Concurrent**: 5 repositories at a time
   - **Excluded repos**: Listed in `cicd/multi-gitter-codeql-config`

### Phase 4: Monitoring and Maintenance

1. **Post-Deployment**:
   - Monitor PR creation and merging
   - Track workflow execution across repositories
   - Address any failures or issues

2. **Ongoing Maintenance**:
   - Review security findings regularly
   - Update centralized workflow as needed
   - All repos automatically benefit from updates

## Files Created

### 1. `data/codeql-workflow.yml`
Template workflow file that individual repositories will use. This file calls the centralized workflow.

### 2. `bulk-utils/add_codeql_workflow.sh`
Script that adds the CodeQL workflow to a repository. Used by multi-gitter for bulk deployment.

### 3. `cicd/multi-gitter-codeql-config`
Configuration file for multi-gitter tool to deploy CodeQL workflow across all repositories.

## Usage Instructions

### For Testing in Your Fork

1. **Update the workflow reference** in `data/codeql-workflow.yml`:
   ```yaml
   uses: YOUR_USERNAME/meta/.github/workflows/codeql.yml@main
   ```

2. **Test on a single repository manually**:
   ```bash
   cd /path/to/test-repo
   mkdir -p .github/workflows
   cp /path/to/meta/data/codeql-workflow.yml .github/workflows/codeql.yml
   git add .github/workflows/codeql.yml
   git commit -m "Add CodeQL workflow"
   git push
   ```

3. **Test with multi-gitter** (single repo):
   ```bash
   cd /path/to/meta
   multi-gitter run ./bulk-utils/add_codeql_workflow.sh \
     --config cicd/multi-gitter-codeql-config \
     --repo YOUR_USERNAME/test-repo \
     --token $GITHUB_TOKEN \
     --dry-run
   ```

4. **Remove `--dry-run`** when ready to create actual PR

### For Production Rollout

1. **Ensure workflow reference** points to production:
   ```yaml
   uses: zopencommunity/meta/.github/workflows/codeql.yml@main
   ```

2. **Run pilot deployment**:
   ```bash
   multi-gitter run ./bulk-utils/add_codeql_workflow.sh \
     --config cicd/multi-gitter-codeql-config \
     --repo zopencommunity/pilot-repo1 \
     --repo zopencommunity/pilot-repo2 \
     --token $GITHUB_TOKEN
   ```

3. **Run full deployment**:
   ```bash
   multi-gitter run ./bulk-utils/add_codeql_workflow.sh \
     --config cicd/multi-gitter-codeql-config \
     --token $GITHUB_TOKEN
   ```

## Troubleshooting

### Common Issues

1. **Workflow fails to find meta repository**:
   - Ensure the meta repository is cloned correctly in the workflow
   - Check network connectivity

2. **Build failures**:
   - Review build logs
   - Ensure zopen build system is compatible
   - Check for missing dependencies

3. **Too many false positives**:
   - Update `paths-ignore` in `.github/codeql/codeql-config.yml`
   - Adjust query suite if needed

4. **Permission errors**:
   - Verify `security-events: write` permission is set
   - Check repository settings for code scanning

## Benefits

1. **Centralized Management**: Update workflow once, all repos benefit
2. **Consistency**: Same security standards across all repositories
3. **Automation**: Scheduled scans and PR checks
4. **Visibility**: Security findings in GitHub Security tab
5. **Compliance**: Demonstrates security best practices

## Next Steps

1. Complete testing in forked repositories
2. Document any issues or improvements needed
3. Get approval from community maintainers
4. Execute pilot rollout
5. Monitor and iterate
6. Execute full rollout
7. Establish ongoing monitoring process

## Support

For questions or issues:
- Open an issue in `zopencommunity/meta`
- Contact the zopen community maintainers
- Review GitHub's CodeQL documentation

## References

- [GitHub CodeQL Documentation](https://docs.github.com/en/code-security/code-scanning/introduction-to-code-scanning/about-code-scanning-with-codeql)
- [Reusable Workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows)
- [Multi-gitter Documentation](https://github.com/lindell/multi-gitter)