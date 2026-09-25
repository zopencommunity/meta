#!/usr/bin/env python3
"""
Generate a monthly status markdown report for the zopencommunity organization.
Collects activity across zopencommunity repositories:
  - Merged Pull Requests
  - Newly Opened / Closed Issues
  - New Releases / Packages
  - Summary metrics and top contributors

Usage:
  python3 tools/generate_monthly_status.py [--days 30] [--org zopencommunity] [--output monthly_status.md]
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


def get_auth_token(token_arg: Optional[str] = None) -> Optional[str]:
    """Get GitHub Token from argument or environment."""
    return token_arg or os.getenv("GH_TOKEN") or os.getenv("GITHUB_TOKEN")


def github_api_search(query_type: str, query: str, token: Optional[str] = None) -> List[Dict[str, Any]]:
    """Fetch search results directly using GitHub REST API."""
    encoded_q = urllib.parse.quote(query)
    url = f"https://api.github.com/search/{query_type}?q={encoded_q}&per_page=100&sort=created&order=desc"
    headers = {
        "User-Agent": "zopen-status-generator",
        "Accept": "application/vnd.github+json"
    }
    if token:
        headers["Authorization"] = f"Bearer {token}"

    items = []
    try:
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req, timeout=15) as resp:
            data = json.loads(resp.read().decode())
            items = data.get("items", [])
    except Exception as e:
        print(f"Notice: GitHub API search ({query_type}) failed: {e}", file=sys.stderr)
        if not token:
            print("Tip: Pass a GitHub token via --token, GH_TOKEN, or GITHUB_TOKEN to avoid rate limits.", file=sys.stderr)
    return items


def run_command(cmd: List[str], check: bool = True) -> str:
    """Execute a CLI command and return its stdout."""
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=check)
        return result.stdout.strip()
    except FileNotFoundError:
        return ""
    except subprocess.CalledProcessError as e:
        print(f"Error running {' '.join(cmd)}: {e.stderr}", file=sys.stderr)
        if check:
            raise
        return ""


def check_gh_installed() -> bool:
    """Verify that gh CLI is available."""
    try:
        subprocess.run(["gh", "--version"], capture_output=True, check=True)
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False


def get_merged_prs(org: str, since_date: str, token: Optional[str] = None) -> List[Dict[str, Any]]:
    """Fetch all merged PRs across the organization since `since_date`."""
    if check_gh_installed():
        cmd = [
            "gh", "search", "prs",
            "--owner", org,
            "--merged-at", f">={since_date}",
            "--json", "number,title,repository,url,author,updatedAt",
            "--limit", "300"
        ]
        raw = run_command(cmd, check=False)
        if raw:
            try:
                return json.loads(raw)
            except json.JSONDecodeError:
                pass

    # Fallback to direct GitHub REST API
    query = f"org:{org} is:pr is:merged merged:>={since_date}"
    raw_items = github_api_search("issues", query, token=token)
    prs = []
    for item in raw_items:
        # Extract repo name from repository_url: https://api.github.com/repos/zopencommunity/makeport
        repo_url = item.get("repository_url", "")
        repo_name = repo_url.split("/")[-1] if repo_url else "unknown"
        user = item.get("user", {})
        prs.append({
            "number": item.get("number"),
            "title": item.get("title"),
            "url": item.get("html_url"),
            "repository": {"name": repo_name},
            "author": {"login": user.get("login") if user else "unknown"},
            "updatedAt": item.get("updated_at")
        })
    return prs


def get_recent_reviewers_and_commenters(org: str, since_date: str, token: Optional[str] = None) -> List[Dict[str, Any]]:
    """Fetch PRs that received reviews or comments across the organization since `since_date`."""
    query = f"org:{org} is:pr updated:>={since_date}"
    raw_items = github_api_search("issues", query, token=token)
    return raw_items


def get_issues(org: str, since_date: str, token: Optional[str] = None) -> List[Dict[str, Any]]:
    """Fetch issues created across the organization since `since_date`."""
    if check_gh_installed():
        cmd = [
            "gh", "search", "issues",
            "--owner", org,
            "--created", f">={since_date}",
            "--json", "number,title,repository,url,author,state,createdAt",
            "--limit", "200"
        ]
        raw = run_command(cmd, check=False)
        if raw:
            try:
                return json.loads(raw)
            except json.JSONDecodeError:
                pass

    # Fallback to direct GitHub REST API
    query = f"org:{org} is:issue created:>={since_date}"
    raw_items = github_api_search("issues", query, token=token)
    issues = []
    for item in raw_items:
        repo_url = item.get("repository_url", "")
        repo_name = repo_url.split("/")[-1] if repo_url else "unknown"
        user = item.get("user", {})
        issues.append({
            "number": item.get("number"),
            "title": item.get("title"),
            "url": item.get("html_url"),
            "repository": {"name": repo_name},
            "author": {"login": user.get("login") if user else "unknown"},
            "state": item.get("state"),
            "createdAt": item.get("created_at")
        })
    return issues


def get_recent_releases(since_date: str) -> List[Dict[str, Any]]:
    """Fetch recent releases from the central release metadata."""
    releases_data = []
    release_cache_url = "https://raw.githubusercontent.com/zopencommunity/meta/main/docs/api/zopen_releases.json"
    try:
        req = urllib.request.Request(release_cache_url, headers={"User-Agent": "zopen-status-generator"})
        with urllib.request.urlopen(req, timeout=10) as resp:
            raw_payload = resp.read().decode()
            data = json.loads(raw_payload)
            if isinstance(data, str):
                data = json.loads(data)
            since_dt = datetime.strptime(since_date, "%Y-%m-%d").replace(tzinfo=timezone.utc)
            
            # releases may be in data['release_data'] or directly under data
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
                                "tag": entry.get("tag_name", entry.get("version", "")),
                                "name": pax_name,
                                "category": category,
                                "url": url,
                                "date": date_str[:10]
                            })
    except Exception as e:
        print(f"Notice: Could not fetch central release cache: {e}", file=sys.stderr)

    return releases_data


EXCLUDED_CONTRIBUTORS = {
    "zosopentoolsmain",
    "github-actions[bot]",
    "actions@github.com",
    "bot"
}


def is_valid_contributor(login: Optional[str]) -> bool:
    """Check if contributor is a real human user rather than a bot/service account."""
    if not login:
        return False
    if "[bot]" in login.lower() or login.lower() in EXCLUDED_CONTRIBUTORS:
        return False
    return True


def get_additional_contributors(org: str, since_date: str, token: Optional[str] = None) -> set:
    """Find contributors who reviewed PRs, commented on issues/PRs, or authored issues."""
    contributors = set()
    # Search for active PRs and issues updated recently
    for q_type, q_extra in [("issues", "is:pr"), ("issues", "is:issue")]:
        query = f"org:{org} {q_extra} updated:>={since_date}"
        items = github_api_search("issues", query, token=token)
        for item in items:
            user = item.get("user", {})
            login = user.get("login")
            if is_valid_contributor(login):
                contributors.add(login)
    
    # Check known maintainers / active reviewers if they participated in the window
    known_maintainers = ["HarithaIBM", "sachintu47", "IgorTodorovskiIBM", "Sanjana-Kondalwade", "sivajrajan", "yatharth-walia", "Geetha-Sushma-Dhulipudi"]
    for handle in known_maintainers:
        q = f"org:{org} is:pr reviewed-by:{handle} updated:>={since_date}"
        reviewed = github_api_search("issues", q, token=token)
        if reviewed:
            contributors.add(handle)

    return {c for c in contributors if is_valid_contributor(c)}


def generate_markdown_report(
    org: str,
    days: int,
    since_date: str,
    prs: List[Dict[str, Any]],
    issues: List[Dict[str, Any]],
    releases: List[Dict[str, Any]],
    additional_contributors: Optional[set] = None
) -> str:
    """Format collected data into a structured Markdown status report."""
    today = datetime.now(timezone.utc).strftime("%Y-%m-%d")

    # Group PRs by repository
    prs_by_repo: Dict[str, List[Dict[str, Any]]] = {}
    contributors = {c for c in (additional_contributors or []) if is_valid_contributor(c)}

    for pr in prs:
        repo_name = pr.get("repository", {}).get("name", "other")
        prs_by_repo.setdefault(repo_name, []).append(pr)
        author = pr.get("author", {}).get("login")
        if is_valid_contributor(author):
            contributors.add(author)

    for issue in issues:
        author = issue.get("author", {}).get("login")
        if is_valid_contributor(author):
            contributors.add(author)

    # Separate meta PRs from port PRs
    meta_prs = prs_by_repo.pop("meta", [])
    port_prs = prs_by_repo

    # Sort repos alphabetically
    sorted_ports = sorted(port_prs.items(), key=lambda x: x[0])

    # Classify port activities:
    # 1. New Ports ported
    # 2. Automated Version Bumps (consolidated)
    # 3. Community Port Enhancements / Fixes
    new_ports = []
    version_bumps: Dict[str, List[Dict[str, Any]]] = {}
    community_port_enhancements: Dict[str, List[Dict[str, Any]]] = {}

    bump_pattern = re.compile(r"Update (.+?)-version to ([^ ]+) from ([^ ]+)", re.IGNORECASE)

    for repo_name, repo_prs in sorted_ports:
        for pr in repo_prs:
            title = pr.get("title", "")
            author = pr.get("author", {}).get("login", "")
            match = bump_pattern.search(title)
            if match or author == "zosopentoolsmain":
                # Version bump
                tool_label = match.group(1) if match else repo_name.replace("port", "")
                to_ver = match.group(2) if match else ""
                from_ver = match.group(3) if match else ""
                ver_info = f"`{to_ver}`" if to_ver else ""
                if from_ver and to_ver:
                    ver_info = f"`{from_ver}` ➔ `{to_ver}`"
                version_bumps.setdefault(repo_name, []).append({
                    "pr": pr,
                    "tool": tool_label,
                    "ver_info": ver_info
                })
            elif any(kw in title.lower() for kw in ["initial port", "porting ", "port:", "initial z/os port"]):
                new_ports.append({"repo": repo_name, "pr": pr})
            else:
                community_port_enhancements.setdefault(repo_name, []).append(pr)

    lines = []
    lines.append(f"# 🚀 {org} Monthly Community Status")
    lines.append("")
    lines.append(f"**Period:** `{since_date}` to `{today}` (past {days} days)  ")
    lines.append(f"**Generated at:** {datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M UTC')}")
    lines.append("")
    lines.append("---")
    lines.append("")

    # By the Numbers
    lines.append("## 📊 By the Numbers")
    lines.append("")
    lines.append("| Metric | Count |")
    lines.append("|:---|---:|")
    lines.append(f"| 🔀 **Merged Pull Requests** | **{len(prs)}** |")
    lines.append(f"| 📦 **Active Repositories Updated** | **{len(prs_by_repo) + (1 if meta_prs else 0)}** |")
    lines.append(f"| 🏷️ **Releases & Port Updates** | **{len(releases)}** |")
    lines.append(f"| 💬 **New Issues / Discussions** | **{len(issues)}** |")
    lines.append(f"| 👥 **Unique Contributors** | **{len(contributors)}** |")
    lines.append("")
    lines.append("---")
    lines.append("")

    # 1. New Ports Ported
    if new_ports:
        lines.append("## 🎉 Newly Ported Tools")
        lines.append("")
        for item in new_ports:
            repo = item["repo"]
            pr = item["pr"]
            author = pr.get("author", {}).get("login", "unknown")
            lines.append(f"- **[{repo}](https://github.com/{org}/{repo})**: [#{pr.get('number')}]({pr.get('url')}) {pr.get('title')} (*@{author}*)")
        lines.append("")

    # 2. Highlights / Meta Tooling Updates (group similar if needed)
    lines.append("## 🛠️ Core Infrastructure & Meta Updates")
    lines.append("")
    if meta_prs:
        lines.append(f"**{len(meta_prs)} changes merged into `meta`:**")
        lines.append("")
        for pr in meta_prs:
            author = pr.get("author", {}).get("login", "unknown")
            lines.append(f"- [#{pr.get('number')}]({pr.get('url')}) {pr.get('title')} (*@{author}*)")
    else:
        lines.append("*No direct core meta changes in this period.*")
    lines.append("")

    # 3. Port Releases (deduplicated by latest version per tool)
    if releases:
        lines.append("## 📦 New Port Releases & Packages")
        lines.append("")
        # Group by tool and keep only the latest release per tool
        latest_releases_by_tool: Dict[str, Dict[str, Any]] = {}
        for rel in sorted(releases, key=lambda x: x["date"], reverse=True):
            tool = rel.get("tool", "")
            if tool not in latest_releases_by_tool:
                latest_releases_by_tool[tool] = rel

        lines.append(f"**{len(latest_releases_by_tool)} tools** released updates ({len(releases)} total package builds):")
        lines.append("")
        for tool, rel in sorted(latest_releases_by_tool.items(), key=lambda x: x[0]):
            name = rel.get("name", "")
            url = rel.get("url", "")
            category = rel.get("category", "")
            date = rel.get("date", "")
            link = f"[{name}]({url})" if url else name
            cat_str = f" *(category: {category})*" if category and category != "Uncategorized" else ""
            lines.append(f"- **{tool}** (`{date}`): {link}{cat_str}")
        lines.append("")

    # 4. Port Repository Enhancements & Bug Fixes (Non-automated bumps)
    if community_port_enhancements:
        total_port_enhancements = sum(len(v) for v in community_port_enhancements.values())
        lines.append(f"## 🔧 Port Enhancements & Bug Fixes ({total_port_enhancements} PRs)")
        lines.append("")
        for repo_name, repo_prs in sorted(community_port_enhancements.items(), key=lambda x: x[0]):
            lines.append(f"### **{repo_name}** ({len(repo_prs)} PRs)")
            for pr in repo_prs:
                author = pr.get("author", {}).get("login", "unknown")
                lines.append(f"- [#{pr.get('number')}]({pr.get('url')}) {pr.get('title')} (*@{author}*)")
            lines.append("")

    # 5. Automated Version Bumps (Summarized compactly)
    if version_bumps:
        total_bumps = sum(len(v) for v in version_bumps.values())
        lines.append(f"## 🔄 Automated Version Bumps ({total_bumps} updates across {len(version_bumps)} ports)")
        lines.append("")
        lines.append("<details>")
        lines.append(f"<summary>Click to expand {len(version_bumps)} updated ports</summary>\n")
        lines.append("| Port | Updates | PRs |")
        lines.append("|:---|:---|:---|")
        for repo_name, bumps in sorted(version_bumps.items(), key=lambda x: x[0]):
            # Get latest version bump info
            ver_summaries = [b["ver_info"] for b in bumps if b["ver_info"]]
            latest_ver = ver_summaries[0] if ver_summaries else "Latest"
            pr_links = ", ".join([f"[#{b['pr'].get('number')}]({b['pr'].get('url')})" for b in bumps])
            lines.append(f"| **{repo_name}** | {latest_ver} | {pr_links} |")
        lines.append("\n</details>\n")

    # Community & Contributors
    if contributors:
        lines.append("## 🌟 Active Contributors")
        lines.append("")
        lines.append("Thanks to everyone who contributed code, reviews, and fixes:")
        lines.append("")
        contributor_tags = [f"[@{c}](https://github.com/{c})" for c in sorted(contributors, key=str.casefold)]
        lines.append(", ".join(contributor_tags))
        lines.append("")

    lines.append("---")
    lines.append("*Report automatically generated by [zopencommunity/meta](https://github.com/zopencommunity/meta).*")
    lines.append("")

    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description="Generate monthly status report for zopencommunity.")
    parser.add_argument("--days", type=int, default=30, help="Number of days to look back (default: 30)")
    parser.add_argument("--org", default="zopencommunity", help="GitHub Organization (default: zopencommunity)")
    parser.add_argument("--token", "-t", default=None, help="GitHub Personal Access Token (defaults to GITHUB_TOKEN or GH_TOKEN env var)")
    parser.add_argument("--output", "-o", default="monthly_status.md", help="Output file path (default: monthly_status.md)")
    parser.add_argument("--print", "-p", action="store_true", help="Print report to stdout")
    args = parser.parse_args()

    token = get_auth_token(args.token)

    if not check_gh_installed() and not token:
        print("Notice: GitHub CLI (gh) not detected and no GITHUB_TOKEN provided. Querying public endpoints with standard rate limits.", file=sys.stderr)

    since_date = (datetime.now(timezone.utc) - timedelta(days=args.days)).strftime("%Y-%m-%d")
    print(f"Gathering {args.org} activity since {since_date} (past {args.days} days)...", file=sys.stderr)

    prs = get_merged_prs(args.org, since_date, token=token)
    issues = get_issues(args.org, since_date, token=token)
    releases = get_recent_releases(since_date)
    additional_contributors = get_additional_contributors(args.org, since_date, token=token)

    print(f"Found: {len(prs)} merged PRs, {len(issues)} issues, {len(releases)} releases.", file=sys.stderr)

    report_md = generate_markdown_report(
        org=args.org,
        days=args.days,
        since_date=since_date,
        prs=prs,
        issues=issues,
        releases=releases,
        additional_contributors=additional_contributors
    )

    with open(args.output, "w", encoding="utf-8") as f:
        f.write(report_md)

    print(f"Successfully written monthly status report to {args.output}", file=sys.stderr)

    if args.print:
        print(report_md)


if __name__ == "__main__":
    main()
