# CodeQL Bulk Rollout Guide

This guide explains how to roll out CodeQL security analysis workflows across all repositories in your organization.

## Overview

CodeQL is GitHub's semantic code analysis engine that helps identify vulnerabilities in your codebase. This solution provides:

- **Reusable workflow template** (`data/codeql-analysis.yml`)
- **Automated rollout script** (`bulk-utils/gh_bulk_codeql_rollout.sh`)
- Support for 300+ repositories
- Customizable language detection
- Automated PR creation

## Prerequisites

1. **GitHub CLI (gh)** - [Install here](https://cli.github.com/)
   ```bash
   # Verify installation
   gh --version
   
   # Authenticate
   gh auth login
   ```

2. **Multi-gitter (Optional but Recommended)** - [Install here](https://github.com/lindell/multi-gitter)
   ```bash
   # macOS
   brew install lindell/multi-gitter/multi-gitter
   
   # Linux
   curl -s https://api.github.com/repos/lindell/multi-gitter/releases/latest | \
     grep "browser_download_url.*linux_amd64.tar.gz" | \
     cut -d : -f 2,3 | tr -d \" | wget -qi -
   ```

3. **Permissions**
   - Admin access to the organization
   - Ability to create branches and PRs in target repositories

## Quick Start

### Basic Usage

```bash
# From the meta repository root
./bulk-utils/gh_bulk_codeql_rollout.sh my-org
```

### With Options

```bash
# Dry run to see what would happen
./bulk-utils/gh_bulk_codeql_rollout.sh my-org --dry-run

# Limit to first 50 repos
./bulk-utils/gh_bulk_codeql_rollout.sh my-org --limit 50

# Custom branch name
./bulk-utils/gh_bulk_codeql_rollout.sh my-org --branch security/add-codeql

# Specify languages
./bulk-utils/gh_bulk_codeql_rollout.sh my-org --languages "javascript,python,go,java"
```

## Script Options

| Option | Description | Default |
|--------|-------------|---------|
| `--limit N` | Limit to N repositories | 300 |
| `--dry-run` | Preview without making changes | false |
| `--branch NAME` | Branch name for PRs | add-codeql-workflow |
| `--skip-archived` | Skip archived repositories | true |
| `--languages LANGS` | Comma-separated language list | javascript,python |
| `--help` | Show help message | - |

## Workflow Features

The CodeQL workflow (`data/codeql-analysis.yml`) includes:

### Triggers
- **Push** to main/master branches
- **Pull requests** to main/master branches
- **Scheduled** weekly scans (Mondays at 2 AM UTC)
- **Manual** workflow dispatch

### Supported Languages
- JavaScript/TypeScript
- Python
- Java
- C/C++
- C#
- Go
- Ruby
- Swift

### Permissions
- `actions: read` - Read workflow status
- `contents: read` - Read repository contents
- `security-events: write` - Write security alerts

## Step-by-Step Process

### 1. Prepare Your Environment

```bash
# Clone the meta repository
git clone https://github.com/your-org/meta.git
cd meta

# Verify the CodeQL template exists
ls -la data/codeql-analysis.yml

# Verify the script exists and is executable
ls -la bulk-utils/gh_bulk_codeql_rollout.sh
```

### 2. Test with Dry Run

```bash
# See which repos would be affected
./bulk-utils/gh_bulk_codeql_rollout.sh my-org --limit 10 --dry-run
```

### 3. Start with a Small Batch

```bash
# Test with 5-10 repositories first
./bulk-utils/gh_bulk_codeql_rollout.sh my-org --limit 10
```

### 4. Review and Merge

```bash
# List all created PRs
gh pr list --search "author:@me Add CodeQL" --limit 100

# Review a specific PR
gh pr view <PR-NUMBER> --repo my-org/repo-name

# Merge approved PRs
gh pr merge <PR-NUMBER> --repo my-org/repo-name --squash
```

### 5. Roll Out to All Repositories

```bash
# Once confident, roll out to all repos
./bulk-utils/gh_bulk_codeql_rollout.sh my-org --limit 300
```

## Manual Method (Without Multi-gitter)

If you don't have multi-gitter installed, use this approach:

### 1. Get Repository List

```bash
gh repo list my-org --limit 300 --json name -q '.[].name' > repos.txt
```

### 2. Process Each Repository

```bash
while read repo; do
  echo "Processing $repo..."
  
  # Clone repository
  gh repo clone my-org/$repo
  cd $repo
  
  # Create branch
  git checkout -b add-codeql-workflow
  
  # Add CodeQL workflow
  mkdir -p .github/workflows
  cp ../meta/data/codeql-analysis.yml .github/workflows/
  
  # Commit and push
  git add .github/workflows/codeql-analysis.yml
  git commit -m "Add CodeQL security analysis workflow"
  git push origin add-codeql-workflow
  
  # Create PR
  gh pr create \
    --title "Add CodeQL security analysis workflow" \
    --body "This PR adds CodeQL security analysis for automated vulnerability detection.

**What's included:**
- Automated security scanning on push and PRs
- Weekly scheduled scans
- Support for multiple languages

**Benefits:**
- Early vulnerability detection
- Security insights in GitHub Security tab
- Compliance with security best practices"
  
  cd ..
done < repos.txt
```

## Customizing the Workflow

### Modify Languages

Edit `data/codeql-analysis.yml`:

```yaml
strategy:
  matrix:
    language: [ 'javascript', 'python', 'go', 'java' ]
```

### Change Schedule

```yaml
schedule:
  # Run daily at 3 AM UTC
  - cron: '0 3 * * *'
```

### Add Custom Queries

```yaml
- name: Initialize CodeQL
  uses: github/codeql-action/init@v3
  with:
    languages: ${{ matrix.language }}
    queries: security-extended,security-and-quality
```

## Monitoring and Maintenance

### View CodeQL Results

```bash
# List all code scanning alerts for a repo
gh api repos/my-org/repo-name/code-scanning/alerts

# View specific alert
gh api repos/my-org/repo-name/code-scanning/alerts/1
```

### Enable Code Scanning Default Setup

```bash
# Enable for a specific repo
gh api repos/my-org/repo-name/code-scanning/default-setup \
  -X PATCH \
  -f state=configured
```

### Bulk Enable Code Scanning

```bash
# Enable for all repos
gh repo list my-org --limit 300 --json name -q '.[].name' | while read repo; do
  echo "Enabling code scanning for $repo..."
  gh api repos/my-org/$repo/code-scanning/default-setup \
    -X PATCH \
    -f state=configured
done
```

## Troubleshooting

### Issue: "CodeQL workflow already exists"

**Solution:** The script automatically skips repositories that already have CodeQL configured.

### Issue: "Permission denied"

**Solution:** Ensure you have admin access to the organization and repositories.

```bash
# Check your permissions
gh api user/memberships/orgs/my-org
```

### Issue: "Rate limit exceeded"

**Solution:** GitHub API has rate limits. Wait or use a GitHub App token.

```bash
# Check rate limit status
gh api rate_limit
```

### Issue: "Language not detected"

**Solution:** CodeQL may not detect all languages. Manually specify in the workflow:

```yaml
strategy:
  matrix:
    language: [ 'javascript' ]  # Explicitly set languages
```

## Best Practices

1. **Start Small**: Test with 5-10 repos before full rollout
2. **Use Dry Run**: Always preview changes first
3. **Monitor Results**: Check CodeQL scans after rollout
4. **Customize Per Repo**: Some repos may need custom configurations
5. **Document Exceptions**: Keep track of repos that can't use CodeQL
6. **Regular Updates**: Keep CodeQL actions updated to latest versions
7. **Review Alerts**: Set up notifications for new security findings

## Advanced Usage

### Filter by Language

```bash
# Only add CodeQL to JavaScript repos
gh repo list my-org --limit 300 --json name,languages | \
  jq -r '.[] | select(.languages[].node.name == "JavaScript") | .name' | \
  while read repo; do
    # Process repo
  done
```

### Exclude Specific Repos

```bash
# Create exclusion list
cat > exclude.txt << EOF
repo-to-skip-1
repo-to-skip-2
EOF

# Filter repos
gh repo list my-org --limit 300 --json name -q '.[].name' | \
  grep -v -f exclude.txt > repos-to-process.txt
```

### Batch Processing

```bash
# Process in batches of 50
for i in {0..5}; do
  offset=$((i * 50))
  echo "Processing batch $((i+1))..."
  ./bulk-utils/gh_bulk_codeql_rollout.sh my-org --limit 50 --offset $offset
  sleep 60  # Wait between batches
done
```

## Security Considerations

1. **Token Security**: Never commit GitHub tokens
2. **Branch Protection**: Ensure branch protection rules allow automated PRs
3. **Review Process**: Establish a review process for security findings
4. **False Positives**: Configure CodeQL to reduce false positives
5. **Compliance**: Ensure CodeQL usage complies with your security policies

## Resources

- [CodeQL Documentation](https://codeql.github.com/docs/)
- [GitHub Code Scanning](https://docs.github.com/en/code-security/code-scanning)
- [Multi-gitter Documentation](https://github.com/lindell/multi-gitter)
- [GitHub CLI Documentation](https://cli.github.com/manual/)

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review GitHub's CodeQL documentation
3. Open an issue in the meta repository
4. Contact your organization's security team

---

**Last Updated**: 2026-06-17
**Version**: 1.0.0