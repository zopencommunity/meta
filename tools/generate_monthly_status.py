#!/usr/bin/env python3
"""
Generate a monthly status markdown report for the zopencommunity organization.
Collects activity across zopencommunity repositories:
  - Merged Pull Requests (with deep Copilot AI or heuristic summarization)
  - Newly Opened / Closed Issues
  - New Releases / Packages
  - Summary metrics and active community contributors (excluding bots)

Usage:
  python3 tools/generate_monthly_status.py [--days 30] [--org zopencommunity] [--token "$COPILOT_TOKEN"] [--output monthly_status.md]
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
    """Check if contributor is a real human user rather than a bot/service account."""
    if not login:
        return False
    if "[bot]" in login.lower() or login.lower() in EXCLUDED_CONTRIBUTORS:
        return False
    return True


def get_auth_token(token_arg: Optional[str] = None) -> Optional[str]:
    """Get GitHub Token from argument or environment."""
    return token_arg or os.getenv("COPILOT_TOKEN") or os.getenv("GH_TOKEN") or os.getenv("GITHUB_TOKEN")


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


def get_additional_contributors(org: str, since_date: str, token: Optional[str] = None) -> set:
    """Find contributors who reviewed PRs, commented on issues/PRs, or authored issues."""
    contributors = set()
    for q_type, q_extra in [("issues", "is:pr"), ("issues", "is:issue")]:
        query = f"org:{org} {q_extra} updated:>={since_date}"
        items = github_api_search("issues", query, token=token)
        for item in items:
            user = item.get("user", {})
            login = user.get("login")
            if is_valid_contributor(login):
                contributors.add(login)
    
    known_maintainers = ["HarithaIBM", "sachintu47", "IgorTodorovskiIBM", "Sanjana-Kondalwade", "sivajrajan", "yatharth-walia", "Geetha-Sushma-Dhulipudi"]
    for handle in known_maintainers:
        q = f"org:{org} is:pr reviewed-by:{handle} updated:>={since_date}"
        reviewed = github_api_search("issues", q, token=token)
        if reviewed:
            contributors.add(handle)

    return {c for c in contributors if is_valid_contributor(c)}


def get_pr_details_and_diff(org: str, repo_name: str, pr_number: int, token: Optional[str] = None) -> Dict[str, Any]:
    """Fetch PR description and changed files with patches to understand deep context."""
    headers = {
        "User-Agent": "zopen-status-generator",
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
            for f in files_data[:8]:
                filename = f.get("filename", "")
                patch = f.get("patch", "")
                if patch:
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

    pr_context_blocks = []
    for p in pr_list[:12]:
        author_login = p.get("author", {}).get("login") if isinstance(p.get("author"), dict) else p.get("author", "unknown")
        details = get_pr_details_and_diff(org, repo_name, p["number"], token=token)
        block = [f"### PR #{p['number']}: {p['title']} (by @{author_login})"]
        if details["body"]:
            block.append(f"Description:\n{details['body']}")
        if details["files_diff"]:
            block.append(f"File changes / patches:\n{details['files_diff']}")
        pr_context_blocks.append("\n".join(block))

    full_context = "\n\n".join(pr_context_blocks)

    prompt = (
        f"You are an expert technical writer summarizing monthly engineering accomplishments for the z/OS open-source port repository '{repo_name}'.\n"
        f"Below are the merged pull requests along with their descriptions and file changes/patches:\n\n"
        f"{full_context}\n\n"
        f"Instructions:\n"
        f"1. Analyze the actual file diffs and descriptions to understand WHAT the changes really do (do not just repeat vague titles like 'use main branch' or 'check fix').\n"
        f"2. Summarize into 1 to 3 concise, clear bullet points highlighting key features, enhancements, or bug fixes.\n"
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
            {"role": "system", "content": "You are a concise open source technical writer for z/OS community updates."},
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
    except Exception:
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


def generate_markdown_report(
    org: str,
    days: int,
    since_date: str,
    prs: List[Dict[str, Any]],
    issues: List[Dict[str, Any]],
    releases: List[Dict[str, Any]],
    additional_contributors: Optional[set] = None,
    copilot_token: Optional[str] = None
) -> str:
    """Format collected data into a structured Markdown status report."""
    today = datetime.now(timezone.utc).strftime("%Y-%m-%d")

    # Group PRs by repository
    prs_by_repo: Dict[str, List[Dict[str, Any]]] = {}
    contributors = {c for c in (additional_contributors or []) if is_valid_contributor(c)}

    for pr in prs:
        repo_name = pr.get("repository", {}).get("name", "other")
        prs_by_repo.setdefault(repo_name, []).append(pr)
        author = pr.get("author", {}).get("login") if isinstance(pr.get("author"), dict) else pr.get("author")
        if is_valid_contributor(author):
            contributors.add(author)

    for issue in issues:
        author = issue.get("author", {}).get("login") if isinstance(issue.get("author"), dict) else issue.get("author")
        if is_valid_contributor(author):
            contributors.add(author)

    # Separate meta PRs from port PRs
    meta_prs = prs_by_repo.pop("meta", [])
    port_prs = prs_by_repo

    # Sort repos alphabetically
    sorted_ports = sorted(port_prs.items(), key=lambda x: x[0])

    # Classify port activities:
    # 1. New Ports ported (PR #1 or #2 merged in this period)
    # 2. Automated Version Bumps (consolidated)
    # 3. Community Port Enhancements / Fixes
    new_ports = []
    version_bumps: Dict[str, List[Dict[str, Any]]] = {}
    community_port_enhancements: Dict[str, List[Dict[str, Any]]] = {}

    bump_pattern = re.compile(r"Update (.+?)-version to ([^ ]+) from ([^ ]+)", re.IGNORECASE)

    for repo_name, repo_prs in sorted_ports:
        # Check if newly ported repository in this period
        pr_numbers = {p["number"] for p in repo_prs}
        is_new_port = (
            1 in pr_numbers or 
            any(
                any(kw in p["title"].lower() for kw in ["initial port", "porting", "initial z/os port"])
                for p in repo_prs if p["number"] <= 2
            )
        )
        if is_new_port and repo_name != "meta":
            new_ports.append(repo_name)

        for pr in repo_prs:
            title = pr.get("title", "")
            author = pr.get("author", {}).get("login", "") if isinstance(pr.get("author"), dict) else pr.get("author", "")
            match = bump_pattern.search(title)
            if match or author == "zosopentoolsmain":
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
        for repo in sorted(new_ports):
            lines.append(f"- **[{repo}](https://github.com/{org}/{repo})**")
        lines.append("")

    # 2. Highlights / Meta Tooling Updates
    lines.append("## 🛠️ Core Infrastructure & Meta Updates")
    lines.append("")
    if meta_prs:
        meta_summary = summarize_with_copilot(org, "meta", meta_prs, copilot_token)
        if meta_summary:
            lines.append(meta_summary)
            lines.append("")
            lines.append("<details><summary>View individual meta PRs</summary>\n")
            for pr in meta_prs:
                author = pr.get("author", {}).get("login", "unknown") if isinstance(pr.get("author"), dict) else pr.get("author", "unknown")
                lines.append(f"- [#{pr.get('number')}]({pr.get('url')}) {pr.get('title')} (*@{author}*)")
            lines.append("\n</details>\n")
        else:
            lines.append(f"**{len(meta_prs)} changes merged into `meta`:**")
            lines.append("")
            for pr in meta_prs:
                author = pr.get("author", {}).get("login", "unknown") if isinstance(pr.get("author"), dict) else pr.get("author", "unknown")
                lines.append(f"- [#{pr.get('number')}]({pr.get('url')}) {pr.get('title')} (*@{author}*)")
            lines.append("")
    else:
        lines.append("*No direct core meta changes in this period.*")
        lines.append("")

    # 3. Port Releases (deduplicated by latest version per tool)
    if releases:
        lines.append("## 📦 New Port Releases & Packages")
        lines.append("")
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

    # 4. Port Repository Enhancements & Bug Fixes (with AI or heuristic summarization)
    if community_port_enhancements:
        total_port_enhancements = sum(len(v) for v in community_port_enhancements.values())
        lines.append(f"## 🔧 Port Enhancements & Bug Fixes ({total_port_enhancements} PRs)")
        lines.append("")
        for repo_name, repo_prs in sorted(community_port_enhancements.items(), key=lambda x: x[0]):
            port_label = repo_name.replace("port", "")
            summary = summarize_with_copilot(org, repo_name, repo_prs, copilot_token)
            if not summary:
                summary = fallback_heuristic_summary(repo_name, repo_prs)

            lines.append(f"### **{repo_name}** ({len(repo_prs)} PRs)")
            lines.append(summary)
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
    parser.add_argument("--token", "-t", default=None, help="GitHub Personal Access / Copilot Token (defaults to COPILOT_TOKEN, GITHUB_TOKEN, or GH_TOKEN env var)")
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
        additional_contributors=additional_contributors,
        copilot_token=token
    )

    with open(args.output, "w", encoding="utf-8") as f:
        f.write(report_md)

    print(f"Successfully written monthly status report to {args.output}", file=sys.stderr)

    if args.print:
        print(report_md)


if __name__ == "__main__":
    main()
