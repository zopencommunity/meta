# Final Steps to Complete CodeQL Rollout

## ✅ Good News!
The script IS working correctly! The log shows it's creating workflows with `Sanjana-Kondalwade/meta`.

## ❌ The Problem
You have OLD pull requests from previous runs that still reference `zopencommunity/meta`. Multi-gitter can't update them because the branch already exists.

## 🔧 Solution: Close Old PRs and Let New Ones Be Created

### Step 1: Close ALL Old PRs

Go to each repository and close the old PRs:

1. **rsyncport**: https://github.com/Sanjana-Kondalwade/rsyncport/pull/3
2. **cmakeport**: https://github.com/Sanjana-Kondalwade/cmakeport/pull/3
3. **vimport**: https://github.com/Sanjana-Kondalwade/vimport/pull/3
4. **makeport**: https://github.com/Sanjana-Kondalwade/makeport/pull/3
5. **tigport**: https://github.com/Sanjana-Kondalwade/tigport/pull/3

For each PR:
- Click "Close pull request" button
- **IMPORTANT**: Also delete the branch `codeql-security-scanning`

### Step 2: Delete the Old Branches

For each repository, delete the `codeql-security-scanning` branch:

**Option A: Via GitHub UI**
1. Go to repository
2. Click "branches" (e.g., https://github.com/Sanjana-Kondalwade/rsyncport/branches)
3. Find `codeql-security-scanning` branch
4. Click the trash icon to delete it

**Option B: Via Command Line**
```bash
# For each repo
gh api -X DELETE /repos/Sanjana-Kondalwade/rsyncport/git/refs/heads/codeql-security-scanning
gh api -X DELETE /repos/Sanjana-Kondalwade/cmakeport/git/refs/heads/codeql-security-scanning
gh api -X DELETE /repos/Sanjana-Kondalwade/vimport/git/refs/heads/codeql-security-scanning
gh api -X DELETE /repos/Sanjana-Kondalwade/makeport/git/refs/heads/codeql-security-scanning
gh api -X DELETE /repos/Sanjana-Kondalwade/tigport/git/refs/heads/codeql-security-scanning
```

### Step 3: Re-run the Rollout

```bash
export GITHUB_TOKEN=your_token
./bulk-utils/fork-test-rollout.sh
```

This time it will:
- ✅ Create NEW branches
- ✅ Create NEW PRs with correct `Sanjana-Kondalwade/meta` reference
- ✅ Work properly!

## 📋 Verification

After re-running, check one of the new PRs. The workflow should look like:

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
    uses: Sanjana-Kondalwade/meta/.github/workflows/codeql.yml@main  # ← YOUR fork!
    secrets: inherit
    permissions:
      actions: read
      contents: read
      security-events: write
    with:
      languages: "c-cpp"
      build-mode: "none"
```

## 🎯 Why This Happened

1. First run created PRs with `zopencommunity/meta` (old script)
2. You updated the script to use `Sanjana-Kondalwade/meta`
3. Multi-gitter saw the branch already exists and skipped creating new PRs
4. Old PRs still have old reference

## ✨ After This Works

Once the new PRs are created and merged:
1. The workflows will run successfully
2. CodeQL will scan your code
3. You'll see results in the Security tab
4. You can then propose this to zopen community!

## 🆘 Quick Delete Script

Save this as `delete-old-branches.sh`:

```bash
#!/bin/bash
REPOS=(
  "rsyncport"
  "cmakeport"
  "vimport"
  "makeport"
  "tigport"
)

for repo in "${REPOS[@]}"; do
  echo "Deleting branch in $repo..."
  gh api -X DELETE /repos/Sanjana-Kondalwade/$repo/git/refs/heads/codeql-security-scanning || echo "Branch not found or already deleted"
done

echo "Done! Now run: ./bulk-utils/fork-test-rollout.sh"
```

Then run:
```bash
chmod +x delete-old-branches.sh
./delete-old-branches.sh