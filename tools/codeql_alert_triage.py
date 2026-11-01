#!/usr/bin/env python3
"""Gather CodeQL alert facts and code context for AI security triage and remediation.

This script fetches open CodeQL scanning alerts from a target repository, extracts
the relevant source code around each flagged location, and formats a fact sheet for
the AI agent to identify false positives and generate remediation patches.

Usage:
  python3 tools/codeql_alert_triage.py --repo zopencommunity/curlport --output /tmp/gh-aw/codeql/triage_facts.md
  python3 tools/codeql_alert_triage.py --repo curlport --alert-number 15 --output /tmp/gh-aw/codeql/triage_facts.md
"""

from __future__ import annotations

import argparse
import base64
import json
import os
from pathlib import Path
import re
import sys
import urllib.error
import urllib.parse
import urllib.request

ORG = "zopencommunity"
API = os.environ.get("GITHUB_API_URL", "https://api.github.com")
CONTEXT_WINDOW = 25  # Number of lines before and after the alert line


def get_token(args_token: str | None) -> str:
    token = args_token or os.environ.get("GITHUB_TOKEN") or os.environ.get("ISSUE_TOKEN") or ""
    return token.strip()


def github_request(endpoint: str, token: str) -> tuple[dict | list | None, str | None]:
    url = f"{API}/{endpoint.lstrip('/')}"
    headers = {
        "Accept": "application/vnd.github+json",
        "User-Agent": "zopen-codeql-triage",
        "X-GitHub-Api-Version": "2022-11-28",
    }
    if token:
        headers["Authorization"] = f"Bearer {token}"

    req = urllib.request.Request(url, headers=headers)
    ctx = None
    cert_path = Path(__file__).resolve().parent.parent / "cacert.pem"
    if cert_path.exists():
        import ssl
        ctx = ssl.create_default_context(cafile=str(cert_path))

    try:
        with urllib.request.urlopen(req, timeout=30, context=ctx) as resp:
            data = resp.read()
            return json.loads(data.decode("utf-8")), None
    except urllib.error.HTTPError as e:
        msg = f"HTTP {e.code} ({e.reason})"
        sys.stderr.write(f"HTTPError {e.code} fetching {url}: {e.reason}\n")
        return None, msg
    except Exception as e:
        msg = str(e)
        sys.stderr.write(f"Error fetching {url}: {e}\n")
        return None, msg


def fetch_raw_file(owner: str, repo: str, path: str, ref: str, token: str) -> str | None:
    endpoint = f"repos/{owner}/{repo}/contents/{urllib.parse.quote(path)}?ref={urllib.parse.quote(ref)}"
    res, _ = github_request(endpoint, token)
    if isinstance(res, dict) and "content" in res:
        encoding = res.get("encoding", "")
        if encoding == "base64":
            try:
                return base64.b64decode(res["content"]).decode("utf-8", errors="replace")
            except Exception:
                return None
    return None


def extract_code_snippet(file_content: str, start_line: int, end_line: int) -> str:
    lines = file_content.splitlines()
    total_lines = len(lines)
    
    first_line = max(1, start_line - CONTEXT_WINDOW)
    last_line = min(total_lines, end_line + CONTEXT_WINDOW)
    
    snippet_lines = []
    for lno in range(first_line, last_line + 1):
        idx = lno - 1
        line_str = lines[idx] if idx < total_lines else ""
        if start_line <= lno <= end_line:
            prefix = f"👉 {lno:5d} | "
        else:
            prefix = f"   {lno:5d} | "
        snippet_lines.append(f"{prefix}{line_str}")
        
    return "\n".join(snippet_lines)


def parse_repo_name(raw_repo: str) -> tuple[str, str]:
    raw = raw_repo.strip().strip("/")
    if "/" in raw:
        parts = raw.split("/", 1)
        return parts[0], parts[1]
    return ORG, raw


def parse_slash_command_args(comment_body: str) -> tuple[str | None, int | None]:
    """Extract repo name and optional alert number from a slash command comment.
    Example:
      /codeql curlport
      /analyze-codeql zopencommunity/curlport 42
      /codeql alert:15
    """
    cleaned = re.sub(r"^/(?:analyze-codeql|codeql|triage-security)\s*", "", comment_body.strip(), flags=re.IGNORECASE)
    parts = cleaned.split()
    repo = None
    alert_no = None
    
    for part in parts:
        if part.startswith("alert:") or part.startswith("#"):
            num_str = re.sub(r"[^\d]", "", part)
            if num_str.isdigit():
                alert_no = int(num_str)
        elif part.isdigit():
            alert_no = int(part)
        elif not repo and re.match(r"^[a-zA-Z0-9_\-\.\/]+$", part):
            repo = part
            
    return repo, alert_no


def main() -> int:
    parser = argparse.ArgumentParser(description="Gather CodeQL alerts and code context for AI triage.")
    parser.add_argument("--repo", help="Repository to analyze (e.g., 'curlport' or 'zopencommunity/curlport')")
    parser.add_argument("--alert-number", type=int, help="Specific alert number to triage (default: all open alerts)")
    parser.add_argument("--max-alerts", type=int, default=15, help="Maximum number of alerts to process in one run (default: 15)")
    parser.add_argument("--issue", help="Target GitHub issue or PR number")
    parser.add_argument("--aw-context", help="Agentic workflow context (JSON string)")
    parser.add_argument("--output", default="/tmp/gh-aw/codeql/triage_facts.md", help="Output Markdown path")
    parser.add_argument("--github-token", help="GitHub API Token")
    args = parser.parse_args()

    token = get_token(args.github_token)
    target_repo = args.repo
    alert_no = args.alert_number
    issue_number = args.issue

    # Parse slash command context if available
    if args.aw_context:
        try:
            ctx = json.loads(args.aw_context)
            if "comment_body" in ctx:
                parsed_repo, parsed_alert = parse_slash_command_args(ctx["comment_body"])
                if parsed_repo and not target_repo:
                    target_repo = parsed_repo
                if parsed_alert and not alert_no:
                    alert_no = parsed_alert
            if "item_number" in ctx and not issue_number:
                issue_number = str(ctx["item_number"])
        except Exception as e:
            sys.stderr.write(f"Warning: Could not parse aw_context: {e}\n")

    if not target_repo:
        sys.stderr.write("Error: No target repository specified.\n")
        return 1

    owner, repo_name = parse_repo_name(target_repo)
    if not repo_name.endswith("port") and not "/" in target_repo and repo_name != "meta":
        # If user passed "curl", check if "curlport" exists
        repo_name = f"{repo_name}port"

    out_path = Path(args.output)
    out_path.parent.mkdir(parents=True, exist_ok=True)

    print(f"Fetching CodeQL alerts for {owner}/{repo_name}...")
    
    alerts_data = []
    fetch_error = None

    # Validate target repository belongs to allowed organization
    if owner.lower() != ORG.lower():
        fetch_error = f"Target repository '{owner}/{repo_name}' is outside the '{ORG}' organization"
        sys.stderr.write(f"Error: {fetch_error}\n")
    else:
        # Verify repository visibility
        repo_info, repo_err = github_request(f"repos/{owner}/{repo_name}", token)
        if repo_err:
            fetch_error = f"Cannot verify repository '{owner}/{repo_name}': {repo_err}"
        elif isinstance(repo_info, dict) and repo_info.get("private", False):
            fetch_error = f"Repository '{owner}/{repo_name}' is private. Security triage is restricted to public repositories."

    if not fetch_error and alert_no:
        endpoint = f"repos/{owner}/{repo_name}/code-scanning/alerts/{alert_no}"
        single_alert, err = github_request(endpoint, token)
        if single_alert and isinstance(single_alert, dict) and "number" in single_alert:
            alerts_data = [single_alert]
        else:
            fetch_error = err or f"Alert #{alert_no} not found"
            sys.stderr.write(f"Alert #{alert_no} not found or inaccessible in {owner}/{repo_name}: {fetch_error}\n")
    elif not fetch_error:
        endpoint = f"repos/{owner}/{repo_name}/code-scanning/alerts?state=open&per_page={args.max_alerts}"
        res, err = github_request(endpoint, token)
        if isinstance(res, list):
            alerts_data = res
        elif err:
            fetch_error = err

    # Build facts document
    lines = []
    lines.append(f"# CodeQL Alert Triage Facts for `{owner}/{repo_name}`")
    lines.append("")
    lines.append(f"- **Target Repository:** `{owner}/{repo_name}`")
    lines.append(f"- **Issue/Context Number:** `#{issue_number}`" if issue_number else "- **Issue/Context:** Standalone / Manual Run")
    lines.append(f"- **Alerts Processed:** {len(alerts_data)}")
    lines.append("")

    if fetch_error:
        lines.append(f"> ❌ **Error accessing CodeQL alerts:** `{fetch_error}`.")
        lines.append("> Please verify that `REPO_GITHUB_TOKEN` is configured with `security-events: read` access for sibling repositories.")
        lines.append("")
        out_path.write_text("\n".join(lines), encoding="utf-8")
        print(f"Wrote {len(lines)} lines to {out_path}")
        return 0

    if not alerts_data:
        lines.append("> ℹ️ **No open CodeQL alerts found** for this repository.")
        lines.append("")
        out_path.write_text("\n".join(lines), encoding="utf-8")
        print(f"Wrote {len(lines)} lines to {out_path}")
        return 0

    lines.append("## Open Alerts to Triage")
    lines.append("")

    for alert in alerts_data:
        num = alert.get("number")
        html_url = alert.get("html_url", "")
        rule = alert.get("rule", {})
        rule_id = rule.get("id", "unknown-rule")
        rule_desc = rule.get("description", "")
        rule_tags = rule.get("tags", [])
        cwe_list = [t for t in rule_tags if t.lower().startswith("external/cwe/")]
        severity = rule.get("security_severity_level") or alert.get("rule", {}).get("severity", "medium")
        
        most_recent = alert.get("most_recent_instance", {})
        location = most_recent.get("location", {})
        file_path = location.get("path", "")
        start_line = location.get("start_line", 1)
        end_line = location.get("end_line", start_line)
        ref = most_recent.get("ref", "refs/heads/main").replace("refs/heads/", "")
        msg = most_recent.get("message", {}).get("text", "")

        lines.append(f"### Alert #{num}: `{rule_id}` ({severity.upper()})")
        lines.append(f"- **Alert Link:** [{owner}/{repo_name} #{num}]({html_url})")
        lines.append(f"- **Rule Description:** {rule_desc}")
        lines.append(f"- **Message:** {msg}")
        if cwe_list:
            lines.append(f"- **CWE:** {', '.join(cwe_list)}")
        lines.append(f"- **Location:** `{file_path}` (Lines {start_line}-{end_line})")
        lines.append("")

        # Fetch code context
        code_snippet = None
        if file_path:
            file_content = fetch_raw_file(owner, repo_name, file_path, ref, token)
            if file_content:
                code_snippet = extract_code_snippet(file_content, start_line, end_line)

        if code_snippet:
            lines.append("**Source Code Context:**")
            # Determine code fence language
            ext = Path(file_path).suffix.lstrip(".")
            lang = "c" if ext in ("c", "h", "cpp", "hpp", "cc", "cxx") else ext or "text"
            lines.append(f"```{lang}")
            lines.append(code_snippet)
            lines.append("```")
        else:
            lines.append("> ⚠️ *Could not fetch source code snippet from repository.*")
            
        lines.append("")
        lines.append("---")
        lines.append("")

    out_path.write_text("\n".join(lines), encoding="utf-8")
    print(f"✅ Successfully wrote facts for {len(alerts_data)} alerts to {out_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
