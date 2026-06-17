# Bulk Utilities

This directory contains scripts for performing bulk operations across multiple repositories in an organization.

## Available Scripts

### 1. `gh_bulk_codeql_rollout.sh`

Roll out CodeQL security analysis workflows to all repositories in your organization.

**Usage:**
```bash
./bulk-utils/gh_bulk_codeql_rollout.sh <org-name> [options]
```

**Examples:**
```bash
# Basic usage
./bulk-utils/gh_bulk_codeql_rollout.sh my-org

# Dry run to preview changes
./bulk-utils/gh_bulk_codeql_rollout.sh my-org --dry-run

# Limit to 50 repos
./bulk-utils/gh_bulk_codeql_rollout.sh my-org --limit 50

# Custom languages
./bulk-utils/gh_bulk_codeql_rollout.sh my-org --languages "javascript,python,go"
```

**See:** [Complete CodeQL Rollout Guide](../docs/CodeQL-Rollout-Guide.md)

### 2. `add_workflows.sh`

Add bump.yml and build_and_test.yml workflows to repositories.

**Usage:**
```bash
# Via multi-gitter
multi-gitter run ./bulk-utils/add_workflows.sh --org my-org
```

### 3. `clone.sh`

Clone all repositories locally while maintaining folder structure.

**Usage:**
```bash
# Via multi-gitter
multi-gitter run ./bulk-utils/clone.sh --org my-org
```

### 4. `enable_disabled_workflow.sh`

Enable disabled workflows in repositories.

**Usage:**
```bash
# Via multi-gitter
multi-gitter run ./bulk-utils/enable_disabled_workflow.sh --org my-org
```

## Prerequisites

### Required Tools

1. **GitHub CLI (gh)**
   ```bash
   # macOS
   brew install gh
   
   # Linux
   curl -sS https://webi.sh/gh | sh
   
   # Authenticate
   gh auth login
   ```

2. **Multi-gitter** (Recommended)
   ```bash
   # macOS
   brew install lindell/multi-gitter/multi-gitter
   
   # Linux
   curl -s https://api.github.com/repos/lindell/multi-gitter/releases/latest | \
     grep "browser_download_url.*linux_amd64.tar.gz" | \
     cut -d : -f 2,3 | tr -d \" | wget -qi -
   ```

3. **jq** (JSON processor)
   ```bash
   # macOS
   brew install jq
   
   # Linux
   sudo apt-get install jq
   ```

### Permissions

- Admin access to the organization
- Ability to create branches and pull requests
- GitHub token with appropriate scopes

## General Workflow

1. **Test with dry run** (if supported)
2. **Start with a small batch** (5-10 repos)
3. **Review results**
4. **Scale up gradually**
5. **Monitor and adjust**

## Common Patterns

### Using Multi-gitter

```bash
multi-gitter run <script> \
  --org <org-name> \
  --branch <branch-name> \
  --commit-message "Your commit message" \
  --pr-title "Your PR title" \
  --pr-body "Your PR description"
```

### Using GitHub CLI

```bash
# Get repository list
gh repo list my-org --limit 300 --json name -q '.[].name'

# Process each repository
gh repo list my-org --limit 300 --json name -q '.[].name' | while read repo; do
  echo "Processing $repo..."
  # Your commands here
done
```

### Filtering Repositories

```bash
# Only non-archived repos
gh repo list my-org --limit 300 --json name,isArchived | \
  jq -r '.[] | select(.isArchived == false) | .name'

# Only repos with specific language
gh repo list my-org --limit 300 --json name,languages | \
  jq -r '.[] | select(.languages[].node.name == "JavaScript") | .name'

# Exclude specific repos
gh repo list my-org --limit 300 --json name -q '.[].name' | \
  grep -v -E "(repo1|repo2|repo3)"
```

## Best Practices

1. **Always test first**: Use dry-run or test on a small subset
2. **Use version control**: Commit scripts to track changes
3. **Document changes**: Keep clear commit messages and PR descriptions
4. **Monitor rate limits**: GitHub API has rate limits
5. **Handle errors gracefully**: Check exit codes and log errors
6. **Backup important data**: Before bulk operations
7. **Communicate changes**: Notify team members about bulk updates

## Troubleshooting

### Rate Limit Issues

```bash
# Check current rate limit
gh api rate_limit

# Wait for rate limit reset
gh api rate_limit | jq -r '.rate.reset' | xargs -I {} date -d @{}
```

### Authentication Issues

```bash
# Re-authenticate
gh auth login

# Check authentication status
gh auth status

# Use different token
gh auth login --with-token < token.txt
```

### Permission Issues

```bash
# Check organization membership
gh api user/memberships/orgs/my-org

# Check repository permissions
gh api repos/my-org/repo-name | jq '.permissions'
```

## Creating New Bulk Scripts

When creating new bulk utility scripts, follow this template:

```bash
#!/bin/bash

################################################################################
# Title: Your Script Title
#
# Description: 
#   Brief description of what the script does
#
# Prerequisites:
#   - List prerequisites here
#
# Usage:
#   ./bulk-utils/your-script.sh [options]
#
# Examples:
#   ./bulk-utils/your-script.sh --example
#
################################################################################

set -e  # Exit on error

# Your script logic here
```

### Script Checklist

- [ ] Clear documentation in header
- [ ] Error handling (`set -e`)
- [ ] Input validation
- [ ] Dry-run option (if applicable)
- [ ] Progress indicators
- [ ] Helpful error messages
- [ ] Exit codes
- [ ] Executable permissions (`chmod +x`)

## Resources

- [GitHub CLI Documentation](https://cli.github.com/manual/)
- [Multi-gitter Documentation](https://github.com/lindell/multi-gitter)
- [GitHub API Documentation](https://docs.github.com/en/rest)
- [jq Manual](https://stedolan.github.io/jq/manual/)

## Contributing

When adding new bulk utility scripts:

1. Follow the naming convention: `<action>_<target>.sh`
2. Add comprehensive documentation
3. Include usage examples
4. Test thoroughly before committing
5. Update this README

## Support

For issues or questions:
- Check the troubleshooting section
- Review script documentation
- Open an issue in the meta repository
- Contact the platform team

---

**Last Updated**: 2026-06-17