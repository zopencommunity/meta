#!/usr/bin/env python3
"""
Generate the z/OS Open Tools Digest (weekly or monthly) for the zopencommunity organization.

Output format:
  z/OS Open Tools Digest – <date>
  :new: New Tools / :hammer_and_wrench: Miscellaneous Updates / :construction: In Progress Tools / Libs

PRs without a meaningful title or description are described by reading the PR body and
changed files (Copilot if a token is available, otherwise file-based heuristics).

Usage:
  python3 tools/generate_monthly_status.py [--days 30] [--org zopencommunity] [--output monthly_status.md]
  python3 tools/generate_monthly_status.py --days 7 --period Weekly --output weekly_status.md

HOW TO RUN
  Manual (from the root of the meta repo):
    read -rs GH_TOKEN && export GH_TOKEN          # avoids the API rate limit
    read -rs COPILOT_TOKEN && export COPILOT_TOKEN   # optional: LLM-written PR descriptions
    Weekly : python3 tools/generate_monthly_status.py --days 7  --period Weekly  -o weekly_status.md  --print
    Monthly: python3 tools/generate_monthly_status.py --days 30 --period Monthly -o monthly_status.md --print

  Automated (GitHub Actions):
    Weekly : .github/workflows/weekly_status.yml   - Mondays 12:00 UTC, 7 days
    Monthly: .github/workflows/monthly_status.yml  - 1st of each month 12:00 UTC, 30 days
    Run on demand: Actions tab -> workflow -> "Run workflow", or
      gh workflow run weekly_status.yml [-f days=14]   /   gh workflow run monthly_status.yml
    Each run uploads the .md as an artifact and appends it to the job summary.
    Scheduled runs only fire from the default branch (merge to main first).

  Full reference (sections, secrets, troubleshooting): see the header of tools/digest_format.py
"""

import argparse
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import digest_format as df  # noqa: E402


def main():
    parser = argparse.ArgumentParser(description="Generate the z/OS Open Tools Digest for zopencommunity.")
    parser.add_argument("--days", type=int, default=30, help="Number of days to look back (default: 30; use 7 for weekly)")
    parser.add_argument("--period", default="", help="Optional label placed in the title, e.g. Weekly or Monthly")
    parser.add_argument("--org", default="zopencommunity", help="GitHub Organization (default: zopencommunity)")
    parser.add_argument("--token", "-t", default=None, help="GitHub API token (defaults to GH_TOKEN or GITHUB_TOKEN)")
    parser.add_argument("--copilot-token", default=None, help="Copilot LLM token for PR descriptions (defaults to COPILOT_TOKEN)")
    parser.add_argument("--output", "-o", default="monthly_status.md", help="Output file path (default: monthly_status.md)")
    parser.add_argument("--print", "-p", action="store_true", help="Print digest to stdout")
    args = parser.parse_args()

    gh_token = args.token or os.getenv("GH_TOKEN") or os.getenv("GITHUB_TOKEN")
    llm_token = args.copilot_token or os.getenv("COPILOT_TOKEN")
    since = df.since_date_for(args.days)

    print(f"Gathering {args.org} activity since {since} (past {args.days} days)...", file=sys.stderr)
    merged = df.fetch_merged_prs(args.org, since, gh_token)
    open_prs = df.fetch_open_prs(args.org, since, gh_token)
    print(f"Found: {len(merged)} merged PRs, {len(open_prs)} open PRs.", file=sys.stderr)

    prefix = f"{args.period} " if args.period else ""
    digest = df.render_digest(args.org, merged, open_prs, gh_token, llm_token, since, title_prefix=prefix)

    with open(args.output, "w", encoding="utf-8") as f:
        f.write(digest)
    print(f"Successfully written digest to {args.output}", file=sys.stderr)

    if args.print:
        print(digest)


if __name__ == "__main__":
    main()
