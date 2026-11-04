# z/OS Open Tools Digest – weekly, monthly and quarterly

Generates the community digest in this format:

```
z/OS Open Tools Weekly Digest – <Month D, YYYY>
:new: New Tools
:hammer_and_wrench: Miscellaneous Updates
:construction: In Progress Tools / Libs
:wave: Thanks for reading!
```

| Digest | Script | Workflow | Schedule (UTC) | Default window |
|---|---|---|---|---|
| Weekly | `tools/generate_monthly_status.py --period Weekly` | `.github/workflows/weekly_status.yml` | Mondays 12:00 | 7 days |
| Monthly | `tools/generate_monthly_status.py --period Monthly` | `.github/workflows/monthly_status.yml` | 1st of month 12:00 | 30 days |
| Quarterly | `tools/generate_quarterly_digest.py` | `.github/workflows/quarterly_digest.yml` | 1 Jan/Apr/Jul/Oct 12:00 | 90 days |

All three share `tools/digest_format.py`, so formatting and detection rules are identical.

## How each section is built

- **New Tools** – port repos (name ends in `port`) *created* inside the window, found with one org listing sorted newest-first (so direct pushes with no PR are caught), plus repos whose PR #1 merged inside the window. Description comes from `docs/api/zopen_releases_descriptions.json`, then the repo description, then the first PR.
- **Miscellaneous Updates** – merged PRs in the window (`meta` first, then ports), capped at 20. Bot version bumps (`Update X-version to ...`) are collapsed into one *Version Updates* line.
- **In Progress Tools / Libs** – open, non-bot PRs updated in the window, one entry per repo.
- **PR descriptions** – if a PR title is vague, the PR body and changed files are read. Order: Copilot (if `COPILOT_TOKEN` works) → PR body → file-type summary (e.g. "Updated build configuration and z/OS patches.") → "New enhancements in `<tool>`."

## Tokens – where to put them

| Token | Where it is used | What you do |
|---|---|---|
| `GH_TOKEN` (GitHub reads) | Manual runs on your machine | Export it in your shell (below). Not stored anywhere. |
| `GITHUB_TOKEN` | Automated runs in GitHub Actions | **Nothing.** GitHub creates it for every run, and the workflows already pass it to the scripts as `GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}`. |
| `COPILOT_TOKEN` (optional) | Both | Manual: export it. Actions: add it as a repository secret (below). |
| `DISCUSSIONS_TOKEN` (required for publish) | Automated publish to org Discussions | PAT with `write:discussion` scope stored as a repo secret (below). `GITHUB_TOKEN` cannot write org-level Discussions. |

Notes:

- You do **not** add `GH_TOKEN` in repo settings. Setting it there does nothing, because the workflows read `GITHUB_TOKEN`.
- Automated runs work with no setup. Add `COPILOT_TOKEN` only if you want LLM-written descriptions.
- `GITHUB_TOKEN` can read public repos in the org. If you ever need private repos, create a PAT, store it as a secret named e.g. `GH_PAT` (secret names cannot start with `GITHUB_`), and change the workflow line to `GH_TOKEN: ${{ secrets.GH_PAT || secrets.GITHUB_TOKEN }}`.
- The quarterly `--publish` option needs `discussions: write`. The workflow already declares it.
- Personal access tokens (`github_pat_...`) are usually rejected by the Copilot endpoint. Failures are silent and the script falls back to PR-body/file descriptions.
- Never paste tokens into chats, commits or scripts. Revoke any token that has been exposed.

### Add `DISCUSSIONS_TOKEN` as a repo secret (required for publish)

`GITHUB_TOKEN` cannot create org-level Discussions. You need a PAT:

1. Go to https://github.com/settings/tokens → **Generate new token (classic)** → tick **`write:discussion`** → copy it.
   *(Fine-grained tokens: organization permissions → Discussions → Read and write.)*
2. Repo **Settings → Secrets and variables → Actions → New repository secret** → Name `DISCUSSIONS_TOKEN` → paste → **Add secret**.

The workflow uses `DISCUSSIONS_TOKEN` when publishing and falls back to `GITHUB_TOKEN` for all other API reads.

### Add `COPILOT_TOKEN` as a repo secret

Repo **Settings → Secrets and variables → Actions → New repository secret** → Name `COPILOT_TOKEN` → paste value → Add secret.

Or with the CLI:

```bash
gh secret set COPILOT_TOKEN --repo zopencommunity/meta
```

## Manual run

From the root of the `meta` repo:

```bash
# Once per shell
read -rs GH_TOKEN && export GH_TOKEN                # avoids the API rate limit
read -rs COPILOT_TOKEN && export COPILOT_TOKEN      # optional

# Weekly
python3 tools/generate_monthly_status.py --days 7  --period Weekly  -o weekly_status.md  --print

# Monthly
python3 tools/generate_monthly_status.py --days 30 --period Monthly -o monthly_status.md --print

# Quarterly (file only)
python3 tools/generate_quarterly_digest.py --days 90 -o quarterly_digest.md --print

# Quarterly + publish as a GitHub Discussion (token needs discussions:write)
python3 tools/generate_quarterly_digest.py --days 90 --publish --category Digest
```

Options: `--days N`, `--period Weekly|Monthly`, `--org`, `--token`, `--copilot-token`, `-o/--output`, `--print`.

### Audit which tools were detected as new

```bash
python3 tools/generate_monthly_status.py --days 14 --period Weekly -o /tmp/w.md 2>&1 | grep "New tool"
# New tool postgresport: PR #1 merged inside the window
# New tool pushonlyport: repo created 2026-10-05
```

### Offline test of the PR-description fallback (no token)

```bash
cd tools && python3 -c "import digest_format as d; \
  d.fetch_pr_context=lambda *a,**k:{'body':'','files':['buildenv','x.patch'],'snippets':''}; \
  print(d.describe_pr('o',{'repo':'librepoport','number':4,'title':'Use main branch'},None,None))"
# Updated build configuration and z/OS patches.
```

## Automated runs (GitHub Actions)

Flow: cron or manual trigger → checkout → run the generator → append the digest to the job summary → upload the `.md` as an artifact. The quarterly workflow can also publish a Discussion.

Trigger on demand:

```bash
# GitHub UI: Actions tab -> pick the workflow -> "Run workflow"

gh workflow run weekly_status.yml    [-f days=14]
gh workflow run monthly_status.yml   [-f days=30]
gh workflow run quarterly_digest.yml [-f days=90] [-f publish=true] [-f category=Digest]

# Watch it and download the result
gh run list --workflow weekly_status.yml
gh run download <run-id>
```

Artifacts: `weekly-status-report`, `monthly-status-report`, `quarterly-digest-report`. Publishing a Discussion is off by default; scheduled quarterly runs only generate the artifact.

**Scheduled runs fire only from the repository's default branch.** Merge to `main` first. Manual `workflow_dispatch` can also be run from other branches once the workflow file exists on the default branch.

## Troubleshooting

| Symptom | Cause / fix |
|---|---|
| `HTTP Error 403: rate limit exceeded` | `GH_TOKEN` missing or invalid on a manual run. Set it and re-run. |
| Descriptions look generic | No `COPILOT_TOKEN`, or the endpoint rejected it (errors are silent). |
| New tool missing | Check the `New tool` audit lines. A repo created long ago and first populated this week by direct push (no PR) is not detected. |
| Slack shows `:hammerandwrench:` | A Markdown preview ate the underscores. Paste the file as plain text. |
| Bullets run together | Open the `.md` in a Markdown viewer, or paste as plain text. Bullets are separated by blank lines. |
