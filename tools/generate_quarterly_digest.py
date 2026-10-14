#!/usr/bin/env python3
"""
Generate the quarterly z/OS Open Tools Digest for zopencommunity and optionally publish it
as a GitHub Discussion (default category: Digest).

Uses the same format as the weekly/monthly digest (tools/digest_format.py), looking back 90 days.

Usage:
  python3 tools/generate_quarterly_digest.py [--days 90] [--publish] [--category "Digest"]

HOW TO RUN
  Manual (from the root of the meta repo):
    read -rs GH_TOKEN && export GH_TOKEN          # avoids the API rate limit
    read -rs COPILOT_TOKEN && export COPILOT_TOKEN   # optional: LLM-written PR descriptions
    File only : python3 tools/generate_quarterly_digest.py --days 90 -o quarterly_digest.md --print
    Publish   : python3 tools/generate_quarterly_digest.py --days 90 --publish --category Digest
                (GH_TOKEN needs discussions:write; the run fails if the category does not exist)

  Automated (GitHub Actions):
    .github/workflows/quarterly_digest.yml - 1 Jan/Apr/Jul/Oct 12:00 UTC, 90 days
    Run on demand: Actions tab -> "Quarterly Community Digest" -> "Run workflow"
      (inputs: days, category, publish), or
      gh workflow run quarterly_digest.yml -f days=90 -f publish=true -f category=Digest
    Scheduled runs PUBLISH to the "Digest" category of zopencommunity/meta Discussions automatically.
    Manual runs only generate the artifact unless "publish" is ticked (or -f publish=true is passed).
    Requires Discussions enabled on the repo with a category named "Digest" (Settings -> Features -> Discussions).
    Scheduled runs only fire from the default branch (merge to main first).

  Full reference (sections, secrets, troubleshooting): see the header of tools/digest_format.py
"""

import argparse
import json
import os
import sys
from typing import Optional, Tuple
import urllib.request

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import digest_format as df  # noqa: E402


def get_discussion_category_id(org: str, repo: str, category_name: str, token: str) -> Tuple[Optional[str], Optional[str]]:
    """Fetch GraphQL repository and category ID for GitHub Discussions."""
    query = """
    query($owner: String!, $name: String!) {
      repository(owner: $owner, name: $name) {
        id
        discussionCategories(first: 20) {
          nodes {
            id
            name
          }
        }
      }
    }
    """
    payload = {"query": query, "variables": {"owner": org, "name": repo}}
    req = urllib.request.Request(
        "https://api.github.com/graphql",
        data=json.dumps(payload).encode("utf-8"),
        headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    )
    try:
        with urllib.request.urlopen(req) as resp:
            data = json.loads(resp.read().decode())
            repo_node = data.get("data", {}).get("repository", {})
            repo_id = repo_node.get("id")
            categories = repo_node.get("discussionCategories", {}).get("nodes", [])
            for cat in categories:
                if cat["name"].lower() == category_name.lower():
                    return repo_id, cat["id"]
            print(f"Error: Discussion category '{category_name}' not found. Available: "
                  f"{', '.join(c['name'] for c in categories) or '(none - are Discussions enabled?)'}", file=sys.stderr)
    except Exception as e:
        print(f"Error querying discussion categories: {e}", file=sys.stderr)
    return None, None


def publish_github_discussion(org: str, repo: str, title: str, body: str, category_name: str, token: str) -> bool:
    """Create a new GitHub Discussion under the specified category."""
    repo_id, category_id = get_discussion_category_id(org, repo, category_name, token)
    if not repo_id or not category_id:
        print(f"Error: Could not resolve GitHub Discussion category '{category_name}'.", file=sys.stderr)
        return False

    mutation = """
    mutation($repositoryId: ID!, $categoryId: ID!, $title: String!, $body: String!) {
      createDiscussion(input: {repositoryId: $repositoryId, categoryId: $categoryId, title: $title, body: $body}) {
        discussion {
          url
        }
      }
    }
    """
    payload = {
        "query": mutation,
        "variables": {"repositoryId": repo_id, "categoryId": category_id, "title": title, "body": body}
    }
    req = urllib.request.Request(
        "https://api.github.com/graphql",
        data=json.dumps(payload).encode("utf-8"),
        headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    )
    try:
        with urllib.request.urlopen(req) as resp:
            data = json.loads(resp.read().decode())
            url = data.get("data", {}).get("createDiscussion", {}).get("discussion", {}).get("url")
            if url:
                print(f"Successfully published digest to GitHub Discussions: {url}")
                return True
            print(f"Discussion creation response: {data}", file=sys.stderr)
    except Exception as e:
        print(f"Error creating discussion: {e}", file=sys.stderr)
    return False


def main():
    parser = argparse.ArgumentParser(description="Generate and publish the quarterly z/OS Open Tools Digest.")
    parser.add_argument("--days", type=int, default=90, help="Days to look back (default: 90 for quarterly)")
    parser.add_argument("--org", default="zopencommunity", help="GitHub Organization (default: zopencommunity)")
    parser.add_argument("--repo", default="meta", help="Target repo for discussions (default: meta)")
    parser.add_argument("--category", default="Digest", help="Discussion category name, matched case-insensitively (default: Digest)")
    parser.add_argument("--token", default=None, help="GitHub API token (defaults to GH_TOKEN or GITHUB_TOKEN)")
    parser.add_argument("--copilot-token", default=None, help="Copilot LLM token for PR descriptions (defaults to COPILOT_TOKEN)")
    parser.add_argument("--output", "-o", default="quarterly_digest.md", help="Output file path")
    parser.add_argument("--publish", action="store_true", help="Publish directly to GitHub Discussions")
    parser.add_argument("--print", "-p", action="store_true", help="Print digest to stdout")
    args = parser.parse_args()

    gh_token = args.token or os.getenv("GH_TOKEN") or os.getenv("GITHUB_TOKEN")
    llm_token = args.copilot_token or os.getenv("COPILOT_TOKEN")
    since = df.since_date_for(args.days)

    print(f"Collecting {args.org} activity since {since}...", file=sys.stderr)
    merged = df.fetch_merged_prs(args.org, since, gh_token)
    open_prs = df.fetch_open_prs(args.org, since, gh_token)

    digest_md = df.render_digest(args.org, merged, open_prs, gh_token, llm_token, since, title_prefix="Quarterly ")

    with open(args.output, "w", encoding="utf-8") as f:
        f.write(digest_md)
    print(f"Quarterly digest written to {args.output}", file=sys.stderr)

    if args.print:
        print(digest_md)

    if args.publish:
        if not gh_token:
            print("Error: --publish requires a valid GITHUB_TOKEN / GH_TOKEN with discussions:write permissions.", file=sys.stderr)
            sys.exit(1)
        title = digest_md.splitlines()[0].lstrip("# ").strip()
        if not publish_github_discussion(args.org, args.repo, title, digest_md, args.category, gh_token):
            sys.exit(1)   # fail the workflow run so a broken scheduled publish is noticed


if __name__ == "__main__":
    main()
