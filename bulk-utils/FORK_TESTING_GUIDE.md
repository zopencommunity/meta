# Testing CodeQL Rollout on Your Forked Repositories

This guide explains how to test the CodeQL rollout on **your forked repositories** before applying to the main zopen community.

## 🎯 Why Test on Forks First?

- ✅ Safe testing environment (your own repos)
- ✅ Full control over merge and testing
- ✅ No risk to zopen community repos
- ✅ Validate the entire workflow end-to-end
- ✅ Identify and fix issues before production rollout

## 📋 Prerequisites

1. **Fork repositories from zopen community**:
   ```bash
   # Fork these repos on GitHub (via web UI or gh CLI):
   # - curlport
   # - gitport
   # - vimport
   # - bashport
   # - makeport
   # Or any other *port repos you want to test with
   ```

2. **Install tools**:
   ```bash
   # Install multi-gitter
   go install github.com/lindell/multi-gitter@latest
   
   # Install GitHub CLI (optional but helpful)
   brew install gh
   ```

3. **Set GitHub token**:
   ```bash
   export GITHUB_TOKEN=your_personal_access_token
   ```

## 🚀 Step-by-Step Testing Process

### Step 1: Fork Repositories

Fork 5-10 repositories from zopencommunity to your account:
- Go to https://github.com/zopencommunity
- Fork repos like: curlport, gitport, vimport, bashport, makeport
- They will appear as: `Sanjana-Kondalwade/curlport`, etc.

### Step 2: Clone the Meta Repository

```bash
# Clone your fork of meta (this repo)
git clone https://github.com/Sanjana-Kondalwade/meta.git
cd meta
```

### Step 3: Make Scripts Executable

```bash
chmod +x bulk-utils/fork-test-rollout.sh
chmod +x bulk-utils/add_codeql_workflow.sh
```

### Step 4: Run the Fork Test Rollout

```bash
./bulk-utils/fork-test-rollout.sh
```

This will:
- Find all your forked repos ending with "port"
- Create PRs in each repo with CodeQL workflow
- Add CodeQL badges to README files
- Log everything to `codeql-fork-test.log`

### Step 5: Review and Merge PRs

1. Go to your GitHub repositories
2. Review the PRs created by the script
3. Check the CodeQL workflow files
4. Merge the PRs one by one

### Step 6: Verify CodeQL Runs

After merging:
1. Go to the "Actions" tab in each repo
2. Verify CodeQL workflow runs successfully
3. Check the "Security" tab for scan results
4. Fix any issues that arise

### Step 7: Iterate if Needed

If you find issues:
1. Update `add_codeql_workflow.sh` to fix the problem
2. Close the existing PRs in your forks
3. Re-run `fork-test-rollout.sh`
4. Test again

## 📁 Files for Fork Testing

| File | Purpose |
|------|---------|
| `codeql-fork-test-config` | Multi-gitter config for YOUR forks |
| `fork-test-rollout.sh` | Script to run rollout on YOUR forks |
| `add_codeql_workflow.sh` | Core script (same for forks and zopen) |

## 🔧 Configuration Details

### Your Fork Configuration (`codeql-fork-test-config`)

```yaml
user:
  - Sanjana-Kondalwade  # YOUR GitHub username (user, not org)

repo-include: ".*port$"  # Only repos ending with 'port'

fork: false  # Don't fork again (already your repos)

concurrent: 3  # Process 3 repos at a time
```

**Important**: Uses `user:` instead of `org:` because you have a personal GitHub account, not an organization.

### What Gets Targeted

The script will automatically find and process:
- ✅ `Sanjana-Kondalwade/curlport`
- ✅ `Sanjana-Kondalwade/gitport`
- ✅ `Sanjana-Kondalwade/vimport`
- ✅ `Sanjana-Kondalwade/bashport`
- ✅ `Sanjana-Kondalwade/makeport`
- ✅ Any other `*port` repos you've forked

## 🎨 Customization

### Change Your Username

Edit `fork-test-rollout.sh` and `codeql-fork-test-config`:
```bash
YOUR_USERNAME="your-github-username"
```

### Test Specific Repos Only

Edit `codeql-fork-test-config` to add specific repos:
```yaml
repo:
  - Sanjana-Kondalwade/curlport
  - Sanjana-Kondalwade/gitport
  - Sanjana-Kondalwade/vimport
```

### Skip Certain Repos

Add to skip list in `codeql-fork-test-config`:
```yaml
skip-repo:
  - Sanjana-Kondalwade/problematic-repo
```

## 🔍 Verification Checklist

After running on your forks, verify:

- [ ] PRs created in all target repos
- [ ] CodeQL workflow files present (`.github/workflows/codeql.yml`)
- [ ] CodeQL badges added to README files
- [ ] Workflows run successfully on merge
- [ ] Security tab shows scan results
- [ ] No errors in workflow runs
- [ ] Language detection is correct
- [ ] Build process works (if applicable)

## 🐛 Troubleshooting

### "No repositories found"
- Make sure you've forked repos from zopencommunity
- Check that repo names end with "port"
- Verify your GitHub username in the config

### "Permission denied"
```bash
chmod +x bulk-utils/*.sh
```

### "Token authentication failed"
```bash
# Verify token is set
echo $GITHUB_TOKEN

# Token needs these permissions:
# - repo (full control)
# - workflow (update workflows)
```

### PRs not created
- Check `codeql-fork-test.log` for errors
- Verify repos are not archived
- Ensure you have write access to your forks

## 📊 Expected Results

After successful testing on your forks:

```
✓ 5-10 PRs created in your forked repos
✓ All PRs merged successfully
✓ CodeQL workflows running on schedule
✓ Security scans completing without errors
✓ No issues with language detection
✓ Build process works correctly
```

## ➡️ Next Steps After Fork Testing

Once testing is successful on your forks:

1. **Document any issues found and fixed**
2. **Update the main rollout scripts if needed**
3. **Prepare proposal for zopen community**:
   - Show successful test results from your forks
   - Demonstrate CodeQL running successfully
   - Share any lessons learned

4. **For zopen community rollout**:
   ```bash
   # Use the main rollout scripts
   ./bulk-utils/test-codeql-rollout.sh  # Test on 5 zopen repos
   ./bulk-utils/rollout-codeql.sh       # Full rollout to 300+ repos
   ```

## 💡 Tips

1. **Start small**: Fork and test 3-5 repos first
2. **Check one thoroughly**: Merge one PR and verify completely before merging others
3. **Monitor workflows**: Watch the Actions tab for any failures
4. **Review security findings**: Check if CodeQL finds any real issues
5. **Document everything**: Keep notes on what works and what doesn't

## 📞 Support

If you encounter issues:
1. Check `codeql-fork-test.log`
2. Review the main [CODEQL_ROLLOUT_GUIDE.md](./CODEQL_ROLLOUT_GUIDE.md)
3. Test manually on one repo first
4. Open an issue in your meta fork

---

**Ready to test?** 
1. Fork 5 repos from zopencommunity
2. Run: `./bulk-utils/fork-test-rollout.sh`
3. Review and merge the PRs
4. Verify CodeQL runs successfully