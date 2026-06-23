# CodeQL Rollout for Zopen Community - Quick Start

This README provides a quick overview of the CodeQL rollout setup. For detailed documentation, see the docs folder.

## 📋 What's Been Created

### 1. Workflow Template (`data/codeql-workflow.yml`)
The workflow file that will be added to each repository. Currently configured for testing with your fork:
```yaml
uses: Sanjana-Kondalwade/meta/.github/workflows/codeql.yml@main
```

### 2. Deployment Script (`bulk-utils/add_codeql_workflow.sh`)
Bash script that:
- Adds CodeQL workflow to a repository
- Adds CodeQL badge to README.md
- Skips if workflow already exists

### 3. Multi-Gitter Config (`cicd/multi-gitter-codeql-config`)
Configuration for bulk deployment across repositories:
- Targets all `*port` repositories in zopencommunity
- Creates PRs with descriptive title and body
- Excludes specific repositories (meta, sample ports, etc.)

### 4. Documentation
- **`docs/CODEQL_ROLLOUT.md`**: Complete rollout strategy and phases
- **`docs/CODEQL_TESTING_GUIDE.md`**: Step-by-step testing instructions

## 🚀 Quick Start - Testing Phase

### Option 1: Manual Test (Single Repository)

```bash
# 1. Navigate to your test repository
cd /path/to/your/test-repo

# 2. Copy the workflow file
mkdir -p .github/workflows
cp /path/to/meta/data/codeql-workflow.yml .github/workflows/codeql.yml

# 3. Commit and push
git add .github/workflows/codeql.yml
git commit -m "Add CodeQL workflow for testing"
git push origin main

# 4. Check GitHub Actions tab to see workflow run
```

### Option 2: Multi-Gitter Test (Multiple Repositories)

```bash
# 1. Set your GitHub token
export GITHUB_TOKEN="your_token_here"

# 2. Dry run first (see what would happen)
cd /path/to/meta
multi-gitter run ./bulk-utils/add_codeql_workflow.sh \
  --config cicd/multi-gitter-codeql-config \
  --repo Sanjana-Kondalwade/test-repo1 \
  --repo Sanjana-Kondalwade/test-repo2 \
  --token $GITHUB_TOKEN \
  --dry-run

# 3. Execute (remove --dry-run when ready)
multi-gitter run ./bulk-utils/add_codeql_workflow.sh \
  --config cicd/multi-gitter-codeql-config \
  --repo Sanjana-Kondalwade/test-repo1 \
  --repo Sanjana-Kondalwade/test-repo2 \
  --token $GITHUB_TOKEN
```

## 📝 Testing Checklist

For each test repository, verify:

- [ ] Workflow file added successfully
- [ ] Workflow triggers on push to main
- [ ] Workflow triggers on pull requests
- [ ] Build completes successfully
- [ ] CodeQL analysis completes
- [ ] Results appear in Security tab
- [ ] No false positives from test files
- [ ] Badge appears in README.md

## 🔄 Transition to Production

Once testing is complete and successful:

1. **Update the workflow reference** in `data/codeql-workflow.yml`:
   ```yaml
   # Change from:
   uses: Sanjana-Kondalwade/meta/.github/workflows/codeql.yml@main
   
   # To:
   uses: zopencommunity/meta/.github/workflows/codeql.yml@main
   ```

2. **Run pilot deployment** (10-20 repos):
   ```bash
   multi-gitter run ./bulk-utils/add_codeql_workflow.sh \
     --config cicd/multi-gitter-codeql-config \
     --repo zopencommunity/pilot-repo1 \
     --repo zopencommunity/pilot-repo2 \
     --token $GITHUB_TOKEN
   ```

3. **Run full deployment** (all 300+ repos):
   ```bash
   multi-gitter run ./bulk-utils/add_codeql_workflow.sh \
     --config cicd/multi-gitter-codeql-config \
     --token $GITHUB_TOKEN
   ```

## 📚 Documentation

- **[CODEQL_ROLLOUT.md](docs/CODEQL_ROLLOUT.md)**: Complete rollout strategy
  - Architecture overview
  - Phased rollout plan
  - Troubleshooting guide
  - Benefits and next steps

- **[CODEQL_TESTING_GUIDE.md](docs/CODEQL_TESTING_GUIDE.md)**: Testing instructions
  - Prerequisites and setup
  - Manual testing steps
  - Multi-gitter testing
  - Issue tracking template
  - Success criteria

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Individual Repositories                   │
│                  (300+ repos in zopencommunity)             │
│                                                              │
│  Each repo has: .github/workflows/codeql.yml                │
│  ┌────────────────────────────────────────────────────┐    │
│  │ name: "CodeQL"                                      │    │
│  │ jobs:                                               │    │
│  │   codeql:                                           │    │
│  │     uses: zopencommunity/meta/...codeql.yml@main   │────┼──┐
│  └────────────────────────────────────────────────────┘    │  │
└─────────────────────────────────────────────────────────────┘  │
                                                                  │
                                                                  │ Calls
                                                                  │
┌─────────────────────────────────────────────────────────────┐  │
│              Centralized Workflow Repository                 │  │
│                  (zopencommunity/meta)                       │  │
│                                                              │  │
│  .github/workflows/codeql.yml                               │◄─┘
│  ┌────────────────────────────────────────────────────┐    │
│  │ - Accepts parameters (repo, branch, languages)     │    │
│  │ - Clones meta for zopen build tools                │    │
│  │ - Creates CodeQL configuration                     │    │
│  │ - Runs CodeQL analysis                             │    │
│  │ - Uploads results to GitHub Security               │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

## 🎯 Benefits

1. **Centralized Management**: Update workflow once, all repos benefit
2. **Consistency**: Same security standards across all repositories
3. **Automation**: Scheduled scans and PR checks
4. **Visibility**: Security findings in GitHub Security tab
5. **Easy Rollout**: Bulk deployment with multi-gitter
6. **Maintainability**: Single source of truth for CodeQL configuration

## 🔧 Files Overview

```
meta/
├── .github/workflows/codeql.yml          # Centralized reusable workflow
├── data/codeql-workflow.yml              # Template for individual repos
├── bulk-utils/add_codeql_workflow.sh     # Deployment script
├── cicd/multi-gitter-codeql-config       # Multi-gitter configuration
├── docs/
│   ├── CODEQL_ROLLOUT.md                 # Complete rollout strategy
│   └── CODEQL_TESTING_GUIDE.md           # Testing instructions
└── README_CODEQL.md                      # This file
```

## ⚠️ Important Notes

### For Testing (Current Phase)
- Workflow references your fork: `Sanjana-Kondalwade/meta`
- Test on 3-5 repositories first
- Document any issues or improvements needed

### For Production
- Update workflow reference to: `zopencommunity/meta`
- Run pilot deployment first (10-20 repos)
- Monitor and iterate before full rollout
- Communicate with community maintainers

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| Workflow not found | Check repository reference in workflow file |
| Build fails | Review build logs, check zopen compatibility |
| Permission errors | Verify `security-events: write` permission |
| False positives | Update `paths-ignore` in CodeQL config |

## 📞 Support

- **Documentation**: See `docs/` folder
- **Issues**: Open an issue in `zopencommunity/meta`
- **Questions**: Contact zopen community maintainers

## ✅ Next Steps

1. Read the testing guide: `docs/CODEQL_TESTING_GUIDE.md`
2. Test on your forked repositories
3. Document findings and issues
4. Update configurations as needed
5. Get approval from maintainers
6. Execute pilot rollout
7. Execute full rollout

---

**Status**: 🧪 Testing Phase  
**Last Updated**: 2026-06-22  
**Maintainer**: Sanjana Kondalwade