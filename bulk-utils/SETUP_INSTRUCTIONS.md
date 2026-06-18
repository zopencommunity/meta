# Setup Instructions for CodeQL Rollout Testing

## 🎯 The Situation

You have:
- ✅ Forked `meta` repo to `Sanjana-Kondalwade/meta` (this repo)
- ✅ The CodeQL reusable workflow exists in `.github/workflows/codeql.yml`
- ✅ Forked other repos like `rsyncport`, `cmakeport`, etc.
- ❌ But the workflow isn't pushed to GitHub yet!

## 📋 Step-by-Step Setup

### Step 1: Push Your Meta Fork to GitHub

First, you need to push this meta repo (with the CodeQL workflow) to YOUR GitHub:

```bash
cd /Users/sanjanakondalwade/meta

# Check current status
git status

# Add all the new files we created
git add bulk-utils/
git add .github/workflows/codeql.yml
git add .github/codeql/codeql-config.yml

# Commit the changes
git commit -m "Add CodeQL rollout scripts and reusable workflow"

# Push to YOUR fork on GitHub
git push origin main
```

### Step 2: Verify the Workflow is on GitHub

Go to: `https://github.com/Sanjana-Kondalwade/meta/.github/workflows/codeql.yml`

You should see the reusable CodeQL workflow file.

### Step 3: Update the Script to Use YOUR Meta Fork

Now we need to use the script that references YOUR meta fork:

```bash
# Make the fork-specific script executable
chmod +x bulk-utils/add_codeql_workflow_fork.sh
```

### Step 4: Update the Config to Use the Fork Script

Edit `bulk-utils/codeql-fork-test-config` or create a new one:

```bash
# Close existing PRs first (they reference zopencommunity/meta)
# Then run with the updated script
```

### Step 5: Re-run the Rollout

```bash
# Close the existing PRs in your forked repos
# (Go to each PR and click "Close pull request")

# Run the rollout again with YOUR meta fork
multi-gitter run ./bulk-utils/add_codeql_workflow_fork.sh \
    --config bulk-utils/codeql-fork-test-config \
    --token $GITHUB_TOKEN
```

## 🔄 Alternative: Two-Phase Approach

### Phase 1: Test with YOUR Fork (Now)

1. Push meta to GitHub (Step 1 above)
2. Use `add_codeql_workflow_fork.sh` (references `Sanjana-Kondalwade/meta`)
3. Test on your forked repos
4. Verify everything works

### Phase 2: Propose to zopen Community (Later)

1. Create PR to `zopencommunity/meta` with:
   - The reusable CodeQL workflow
   - The rollout scripts
2. Once merged to zopen community
3. Use `add_codeql_workflow.sh` (references `zopencommunity/meta`)
4. Roll out to all 300+ repos

## 🎨 Quick Fix for Existing PRs

If you want to keep the existing PRs but fix them:

### Option A: Close and Recreate
```bash
# Close existing PRs manually on GitHub
# Run rollout again with fork script
./bulk-utils/fork-test-rollout.sh
```

### Option B: Manually Edit Each PR
1. Go to each PR
2. Edit `.github/workflows/codeql.yml`
3. Change `zopencommunity/meta` to `Sanjana-Kondalwade/meta`
4. Commit the change

## 📝 Summary

**The Issue**: 
- PRs reference `zopencommunity/meta/.github/workflows/codeql.yml`
- But that workflow doesn't exist in zopen community yet
- It only exists in YOUR fork

**The Solution**:
1. Push your meta fork to GitHub
2. Use `add_codeql_workflow_fork.sh` which references YOUR meta
3. Test everything on your forks
4. Later, propose to zopen community

**Current Status**:
- ✅ Workflow exists locally in your meta fork
- ❌ Not pushed to GitHub yet
- ❌ PRs reference wrong location

**Next Action**:
```bash
# 1. Push meta to GitHub
cd /Users/sanjanakondalwade/meta
git add -A
git commit -m "Add CodeQL rollout infrastructure"
git push origin main

# 2. Close existing PRs (via GitHub UI)

# 3. Re-run with fork script
chmod +x bulk-utils/add_codeql_workflow_fork.sh
./bulk-utils/fork-test-rollout.sh
```

## 🤔 Which Approach to Use?

### Use YOUR Fork (`Sanjana-Kondalwade/meta`) if:
- ✅ You want complete isolation for testing
- ✅ You want to test changes before proposing to zopen
- ✅ You're not ready to propose to zopen community yet

### Use zopen Community (`zopencommunity/meta`) if:
- ✅ The workflow is already merged to zopen community
- ✅ You're doing the final rollout
- ✅ You want to match production exactly

**For now, use YOUR fork since the workflow isn't in zopen community yet!**