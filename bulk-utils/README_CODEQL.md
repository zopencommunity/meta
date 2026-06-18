# CodeQL Rollout - Quick Start

This directory contains scripts to roll out CodeQL security scanning to all 300+ zopen community repositories.

## 🚀 Quick Start (3 Steps)

### 1. Prerequisites Setup (5 minutes)

```bash
# Install multi-gitter
go install github.com/lindell/multi-gitter@latest

# Install GitHub CLI (optional, for repo counting)
brew install gh  # macOS
# or download from https://cli.github.com/

# Set GitHub token
export GITHUB_TOKEN=your_personal_access_token
```

### 2. Test on 5 Repositories (15 minutes)

```bash
# Run test rollout
./bulk-utils/test-codeql-rollout.sh

# Review the 5 draft PRs created
# Check: codeql-test-rollout.log
```

### 3. Full Rollout (2-4 hours)

```bash
# Optional: Dry run first
./bulk-utils/rollout-codeql.sh --dry-run

# Full rollout
./bulk-utils/rollout-codeql.sh
```

## 📁 Files Overview

| File | Purpose |
|------|---------|
| `add_codeql_workflow.sh` | Core script that adds CodeQL to each repo |
| `codeql-rollout-config` | Multi-gitter config for full rollout |
| `test-codeql-rollout.sh` | Test on 5 repos before full rollout |
| `rollout-codeql.sh` | Full rollout to all 300+ repos |
| `CODEQL_ROLLOUT_GUIDE.md` | Detailed documentation |

## 🎯 What Gets Added

Each repository will receive:
- ✅ `.github/workflows/codeql.yml` - Calls reusable workflow from meta
- ✅ CodeQL badge in README.md
- ✅ Automatic language detection (C/C++, Python, JavaScript, etc.)
- ✅ Runs on: push, PR, weekly schedule, manual trigger

## 🔍 Example Workflow Created

```yaml
name: "CodeQL Analysis"

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  schedule:
    - cron: '0 2 * * 1'  # Weekly on Monday
  workflow_dispatch:

jobs:
  codeql:
    uses: zopencommunity/meta/.github/workflows/codeql.yml@main
    with:
      languages: 'c-cpp'
      build-mode: 'none'
```

## 📊 Rollout Strategy

```
Phase 1: Test (5 repos)
   ↓
Phase 2: Dry Run (all repos, no changes)
   ↓
Phase 3: Full Rollout (300+ repos)
   ↓
Phase 4: Monitor & Merge PRs
```

## ⚙️ Configuration

### Test Different Repositories

Edit `test-codeql-rollout.sh`:
```bash
TEST_REPOS=(
    "zopencommunity/yourrepo1"
    "zopencommunity/yourrepo2"
)
```

### Skip Repositories

Edit `codeql-rollout-config`:
```yaml
skip-repo:
  - zopencommunity/repo-to-skip
```

### Adjust Concurrency

Edit `codeql-rollout-config`:
```yaml
concurrent: 10  # Process 10 repos at once
```

## 🐛 Troubleshooting

### "multi-gitter: command not found"
```bash
go install github.com/lindell/multi-gitter@latest
export PATH=$PATH:$(go env GOPATH)/bin
```

### "Permission denied"
```bash
chmod +x bulk-utils/*.sh
```

### "GITHUB_TOKEN not set"
```bash
export GITHUB_TOKEN=ghp_your_token_here
```

## 📈 Expected Timeline

- **Test rollout**: 10-15 minutes
- **Dry run**: 5-10 minutes  
- **Full rollout**: 2-4 hours
- **PR review/merge**: 1-2 days
- **Initial scans**: 1-2 days

## 🎓 Learn More

- Full documentation: [CODEQL_ROLLOUT_GUIDE.md](./CODEQL_ROLLOUT_GUIDE.md)
- Multi-gitter docs: https://github.com/lindell/multi-gitter
- CodeQL docs: https://codeql.github.com/docs/

## 🆘 Need Help?

1. Check log files (e.g., `codeql-test-rollout.log`)
2. Review [CODEQL_ROLLOUT_GUIDE.md](./CODEQL_ROLLOUT_GUIDE.md)
3. Open an issue in the meta repository

## ✅ Success Checklist

After rollout, verify:
- [ ] CodeQL workflows present in repositories
- [ ] CodeQL badges in README files
- [ ] Security tab shows scan results
- [ ] Weekly scans are scheduled
- [ ] Scans run on push/PR

---

**Ready to start?** Run: `./bulk-utils/test-codeql-rollout.sh`