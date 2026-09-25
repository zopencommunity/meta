#!/usr/bin/env python3
"""
Generate an executive Quarterly Digest for zopencommunity using GitHub Copilot / LLM summarization
and optionally publish it directly as a GitHub Discussion under the 'Digests' / 'Announcements' category.

Features:
  - Fetches 90-day activity (PRs, releases, issues, contributors) across org:zopencommunity
  - Uses GitHub Copilot Chat API (or fallback heuristics) to condense PR lists into 2-3 high-level outcome bullets per major tool (e.g. dnf5 features, llama.cpp optimizations)
  - Publishes directly to GitHub Discussions via GraphQL API

Usage:
  python3 tools/generate_quarterly_digest.py [--days 90] [--publish] [--category "Digests"]
"""

import argparse
from datetime import datetime, timedelta, timezone
import json
import os
import re
import subprocess
import sys
from typing import Any, Dict, List, Optional
import urllib.parse
import urllib.request


EXCLUDED_CONTRIBUTORS = {
    "zosopentoolsmain",
    "github-actions[bot]",
    "actions@github.com",
    "bot"
}


def is_valid_contributor(login: Optional[str]) -> bool:
    if not login:
        return False
    if "[bot]" in login.lower() or login.lower() in EXCLUDED_CONTRIBUTORS:
        return False
    return True


def get_token(args_token: Optional[str] = None) -> Optional[str]:
    return args_token or os.getenv("COPILOT_TOKEN") or os.getenv("GH_TOKEN") or os.getenv("GITHUB_TOKEN")


def github_api_search(query_type: str, query: str, token: Optional[str] = None) -> List[Dict[str, Any]]:
    encoded_q = urllib.parse.quote(query)
    url = f"https://api.github.com/search/{query_type}?q={encoded_q}&per_page=100&sort=created&order=desc"
    headers = {
        "User-Agent": "zopen-digest-generator",
        "Accept": "application/vnd.github+json"
    }
    if token:
        headers["Authorization"] = f"Bearer {token}"

    try:
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req, timeout=15) as resp:
            data = json.loads(resp.read().decode())
            return data.get("items", [])
    except Exception as e:
        print(f"Notice: GitHub API search failed: {e}", file=sys.stderr)
        return []


def get_quarterly_activity(org: str, since_date: str, token: Optional[str] = None) -> Dict[str, Any]:
    """Collect PRs, issues, releases, and contributors for the quarter."""
    print(f"Collecting {org} activity since {since_date}...", file=sys.stderr)

    # 1. Merged PRs
    query = f"org:{org} is:pr is:merged merged:>={since_date}"
    raw_prs = github_api_search("issues", query, token=token)
    prs_by_repo: Dict[str, List[Dict[str, Any]]] = {}
    contributors = set()

    for item in raw_prs:
        repo_url = item.get("repository_url", "")
        repo_name = repo_url.split("/")[-1] if repo_url else "unknown"
        user = item.get("user", {})
        login = user.get("login")
        if is_valid_contributor(login):
            contributors.add(login)

        prs_by_repo.setdefault(repo_name, []).append({
            "number": item.get("number"),
            "title": item.get("title"),
            "url": item.get("html_url"),
            "author": login or "unknown"
        })

    # 2. Issues
    issue_query = f"org:{org} is:issue created:>={since_date}"
    raw_issues = github_api_search("issues", issue_query, token=token)
    for item in raw_issues:
        user = item.get("user", {})
        login = user.get("login")
        if is_valid_contributor(login):
            contributors.add(login)

    # 3. Known reviewers check
    known_maintainers = ["HarithaIBM", "sachintu47", "IgorTodorovskiIBM", "Sanjana-Kondalwade", "sivajrajan", "yatharth-walia", "Geetha-Sushma-Dhulipudi"]
    for handle in known_maintainers:
        q = f"org:{org} is:pr reviewed-by:{handle} updated:>={since_date}"
        reviewed = github_api_search("issues", q, token=token)
        if reviewed:
            contributors.add(handle)

    # 4. Central Releases
    releases_data = []
    release_cache_url = "https://raw.githubusercontent.com/zopencommunity/meta/main/docs/api/zopen_releases.json"
    try:
        req = urllib.request.Request(release_cache_url, headers={"User-Agent": "zopen-digest-generator"})
        with urllib.request.urlopen(req, timeout=10) as resp:
            data = json.loads(resp.read().decode())
            if isinstance(data, str):
                data = json.loads(data)
            since_dt = datetime.strptime(since_date, "%Y-%m-%d").replace(tzinfo=timezone.utc)
            packages_map = data.get("release_data", data) if isinstance(data, dict) else {}
            if isinstance(packages_map, dict):
                for tool, entries in packages_map.items():
                    if not isinstance(entries, list):
                        continue
                    for entry in entries:
                        if not isinstance(entry, dict):
                            continue
                        date_str = entry.get("date")
                        if not date_str:
                            continue
                        try:
                            rel_dt = datetime.strptime(date_str, "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=timezone.utc)
                        except ValueError:
                            continue
                        if rel_dt >= since_dt:
                            assets = entry.get("assets", [{}])
                            pax_name = assets[0].get("name", f"{tool}-release") if assets else f"{tool}-release"
                            category = assets[0].get("categories", "Uncategorized") if assets else "Uncategorized"
                            url = assets[0].get("url", "").replace("download", "tag").rsplit("/", 1)[0] if assets else ""
                            releases_data.append({
                                "tool": tool,
                                "name": pax_name,
                                "category": category,
                                "url": url,
                                "date": date_str[:10]
                            })
    except Exception as e:
        print(f"Notice: Releases lookup: {e}", file=sys.stderr)

    return {
        "prs_by_repo": prs_by_repo,
        "total_prs": sum(len(p) for p in prs_by_repo.values()),
        "issues_count": len(raw_issues),
        "releases": releases_data,
        "contributors": sorted(contributors, key=str.casefold)
    }


def get_pr_details_and_diff(org: str, repo_name: str, pr_number: int, token: Optional[str] = None) -> Dict[str, Any]:
    """Fetch PR description and changed files with patches to understand deep context."""
    headers = {
        "User-Agent": "zopen-digest-generator",
        "Accept": "application/vnd.github+json"
    }
    if token:
        headers["Authorization"] = f"Bearer {token}"

    pr_url = f"https://api.github.com/repos/{org}/{repo_name}/pulls/{pr_number}"
    files_url = f"https://api.github.com/repos/{org}/{repo_name}/pulls/{pr_number}/files"
    
    body = ""
    changed_files = []
    try:
        req = urllib.request.Request(pr_url, headers=headers)
        with urllib.request.urlopen(req, timeout=10) as resp:
            data = json.loads(resp.read().decode())
            body = (data.get("body") or "").strip()
    except Exception:
        pass

    try:
        req = urllib.request.Request(files_url, headers=headers)
        with urllib.request.urlopen(req, timeout=10) as resp:
            files_data = json.loads(resp.read().decode())
            for f in files_data[:8]:  # Limit to first 8 files to stay within token limits
                filename = f.get("filename", "")
                patch = f.get("patch", "")
                if patch:
                    # Keep short patch snippet (first 10 lines)
                    patch_snippet = "\n".join(patch.split("\n")[:10])
                    changed_files.append(f"{filename}:\n{patch_snippet}")
                else:
                    changed_files.append(filename)
    except Exception:
        pass

    return {
        "body": body,
        "files_diff": "\n".join(changed_files)
    }


def summarize_with_copilot(org: str, repo_name: str, pr_list: List[Dict[str, Any]], token: Optional[str]) -> Optional[str]:
    """Call GitHub Copilot Chat API with PR titles, descriptions, and file diffs for deep semantic summarization."""
    if not token or not pr_list:
        return None

    # Gather deep PR context (titles + descriptions + changed file patches)
    pr_context_blocks = []
    for p in pr_list[:12]:  # inspect up to 12 PRs in detail
        details = get_pr_details_and_diff(org, repo_name, p["number"], token=token)
        block = [f"### PR #{p['number']}: {p['title']} (by @{p['author']})"]
        if details["body"]:
            block.append(f"Description:\n{details['body']}")
        if details["files_diff"]:
            block.append(f"File changes / patches:\n{details['files_diff']}")
        pr_context_blocks.append("\n".join(block))

    full_context = "\n\n".join(pr_context_blocks)

    prompt = (
        f"You are an expert technical writer summarizing quarterly engineering achievements for the z/OS open-source port repository '{repo_name}'.\n"
        f"Below are the merged pull requests along with their descriptions and file changes/patches:\n\n"
        f"{full_context}\n\n"
        f"Instructions:\n"
        f"1. Analyze the actual file diffs and descriptions to understand WHAT the changes really do (do not just repeat vague titles like 'use main branch' or 'check fix').\n"
        f"   For example, if 'buildenv' modified dependencies to add 'curl' or changed build flags, explain: 'Configured build environment to track upstream main and added curl dependency.'\n"
        f"2. Summarize into 1 to 3 concise, clear bullet points grouped by theme (e.g. Major Features, Enhancements, Build & Dependencies, Bug Fixes).\n"
        f"3. Do NOT list raw PR numbers or author handles.\n"
        f"4. Output only clean markdown bullet points."
    )

    url = "https://api.githubcopilot.com/chat/completions"
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
        "Accept": "application/json"
    }
    payload = {
        "model": "gpt-4o",
        "messages": [
            {"role": "system", "content": "You are a concise open source technical writer for z/OS community digests."},
            {"role": "user", "content": prompt}
        ],
        "temperature": 0.2
    }

    try:
        req = urllib.request.Request(url, data=json.dumps(payload).encode("utf-8"), headers=headers)
        with urllib.request.urlopen(req, timeout=15) as resp:
            data = json.loads(resp.read().decode())
            choice = data.get("choices", [{}])[0]
            content = choice.get("message", {}).get("content", "").strip()
            if content:
                return content
    except Exception as e:
        # Copilot Chat API may not be directly reachable without copilot extension scope
        pass

    return None


def fallback_heuristic_summary(repo_name: str, pr_list: List[Dict[str, Any]]) -> str:
    """Group PR titles when Copilot API is not active."""
    keywords = {
        "Features & Enhancements": ["add", "support", "feature", "port", "initial", "enable", "implement"],
        "Performance & Optimization": ["perf", "optimize", "speed", "accelerat", "fast"],
        "Fixes & Configuration": ["fix", "correct", "revert", "clean", "config", "patch", "macro"]
    }
    classified: Dict[str, List[str]] = {}
    for p in pr_list:
        title = p["title"]
        lower = title.lower()
        matched = False
        for cat, kw_list in keywords.items():
            if any(k in lower for k in kw_list):
                clean_title = re.sub(r'^(feat|fix|perf|chore|docs|refactor)(\(.*\))?:\s*', '', title, flags=re.IGNORECASE)
                classified.setdefault(cat, []).append(clean_title)
                matched = True
                break
        if not matched:
            classified.setdefault("General Updates", []).append(title)

    bullets = []
    for cat, items in classified.items():
        summary_text = ", ".join(items[:3])
        if len(items) > 3:
            summary_text += f" (and {len(items)-3} more)"
        bullets.append(f"- **{cat}**: {summary_text}")
    return "\n".join(bullets)


def generate_digest_markdown(
    org: str,
    quarter_name: str,
    days: int,
    since_date: str,
    activity: Dict[str, Any],
    copilot_token: Optional[str] = None
) -> str:
    today = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    prs_by_repo = activity["prs_by_repo"]
    releases = activity["releases"]
    contributors = activity["contributors"]

    # Filter out auto version bump bots to identify major ports
    major_tool_prs: Dict[str, List[Dict[str, Any]]] = {}
    new_ports = []

    for repo, pr_list in prs_by_repo.items():
        community_prs = [p for p in pr_list if p["author"] != "zosopentoolsmain"]
        if not community_prs:
            continue
        # A newly ported tool has PR #1 (or PR #2 for initial port) merged within this quarter
        pr_numbers = {p["number"] for p in pr_list}
        is_new_port = (
            1 in pr_numbers or
            any(
                any(kw in p["title"].lower() for kw in ["initial port", "porting", "initial z/os port"])
                for p in community_prs if p["number"] <= 2
            )
        )
        if is_new_port and repo != "meta":
            new_ports.append(repo)
        major_tool_prs[repo] = community_prs

    lines = []
    lines.append(f"# 📰 zopen community {quarter_name} Digest")
    lines.append("")
    lines.append(f"> Highlights, major tool features, and community milestones from `{since_date}` to `{today}`.")
    lines.append("")
    lines.append("---")
    lines.append("")

    # Executive Overview
    lines.append("## 🌟 Quarter at a Glance")
    lines.append("")
    lines.append(f"- 🚀 **{activity['total_prs']} Pull Requests Merged** across {len(prs_by_repo)} repositories.")
    lines.append(f"- 📦 **{len(releases)} Package Builds Released** for z/OS.")
    lines.append(f"- 👥 **{len(contributors)} Active Community Contributors**.")
    if new_ports:
        lines.append(f"- 🎉 **Newly Ported Tools**: " + ", ".join([f"`{p}`" for p in new_ports]))
    lines.append("")
    lines.append("---")
    lines.append("")

    # Major Tool Features & Summaries
    lines.append("## 🚀 Major Tool Highlights & Enhancements")
    lines.append("")
    lines.append("Rather than listing individual commits, here are the key functional achievements by tool:")
    lines.append("")

    # Meta Core
    if "meta" in major_tool_prs:
        meta_summary = summarize_with_copilot(org, "meta", major_tool_prs["meta"], copilot_token)
        if not meta_summary:
            meta_summary = fallback_heuristic_summary("meta", major_tool_prs["meta"])
        lines.append("### 🛠️ **Core Infrastructure & Meta Tooling**")
        lines.append(meta_summary)
        lines.append("")

    # Port Repositories
    for repo, pr_list in sorted(major_tool_prs.items(), key=lambda x: len(x[1]), reverse=True):
        if repo == "meta":
            continue
        port_name = repo.replace("port", "")
        summary = summarize_with_copilot(org, repo, pr_list, copilot_token)
        if not summary:
            summary = fallback_heuristic_summary(repo, pr_list)

        lines.append(f"### 📦 **{port_name}** ({len(pr_list)} community updates)")
        lines.append(summary)
        lines.append("")

    # Active Contributors
    if contributors:
        lines.append("---")
        lines.append("## 👏 Special Thanks to Our Contributors")
        lines.append("")
        tags = [f"[@{c}](https://github.com/{c})" for c in contributors]
        lines.append(", ".join(tags))
        lines.append("")

    lines.append("---")
    lines.append("*Published automatically by [zopencommunity/meta](https://github.com/zopencommunity/meta).*")
    return "\n".join(lines)


def get_discussion_category_id(org: str, repo: str, category_name: str, token: str) -> Optional[str]:
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
            if categories:
                # Default to first category if 'Digests' not found
                return repo_id, categories[0]["id"]
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
        "variables": {
            "repositoryId": repo_id,
            "categoryId": category_id,
            "title": title,
            "body": body
        }
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
                print(f"🎉 Successfully published Quarterly Digest to GitHub Discussions: {url}")
                return True
            else:
                print(f"Discussion creation response: {data}", file=sys.stderr)
    except Exception as e:
        print(f"Error creating discussion: {e}", file=sys.stderr)
    return False


def main():
    parser = argparse.ArgumentParser(description="Generate and publish quarterly digest for zopencommunity.")
    parser.add_argument("--days", type=int, default=90, help="Days to look back (default: 90 for quarterly)")
    parser.add_argument("--org", default="zopencommunity", help="GitHub Organization (default: zopencommunity)")
    parser.add_argument("--repo", default="meta", help="Target repo for discussions (default: meta)")
    parser.add_argument("--category", default="Announcements", help="Discussion Category (e.g., 'Announcements' or 'Digests')")
    parser.add_argument("--token", default=None, help="GitHub Token with discussions:write and copilot access")
    parser.add_argument("--output", "-o", default="quarterly_digest.md", help="Output file path")
    parser.add_argument("--publish", action="store_true", help="Publish directly to GitHub Discussions")
    parser.add_argument("--print", "-p", action="store_true", help="Print digest to stdout")
    args = parser.parse_args()

    token = get_token(args.token)
    since_date = (datetime.now(timezone.utc) - timedelta(days=args.days)).strftime("%Y-%m-%d")

    # Determine quarter title (e.g. Q3 2026)
    month = datetime.now(timezone.utc).month
    quarter_num = (month - 1) // 3 + 1
    year = datetime.now(timezone.utc).year
    quarter_name = f"Q{quarter_num} {year}"

    activity = get_quarterly_activity(args.org, since_date, token=token)

    digest_md = generate_digest_markdown(
        org=args.org,
        quarter_name=quarter_name,
        days=args.days,
        since_date=since_date,
        activity=activity,
        copilot_token=token
    )

    with open(args.output, "w", encoding="utf-8") as f:
        f.write(digest_md)

    print(f"Quarterly digest written to {args.output}", file=sys.stderr)

    if args.print:
        print(digest_md)

    if args.publish:
        if not token:
            print("Error: --publish requires a valid GITHUB_TOKEN / COPILOT_TOKEN with write permissions.", file=sys.stderr)
            sys.exit(1)
        title = f"🚀 zopen community Quarterly Digest — {quarter_name}"
        publish_github_discussion(args.org, args.repo, title, digest_md, args.category, token)


if __name__ == "__main__":
    main()
