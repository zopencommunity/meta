#!/usr/bin/env python3
"""
Shared helpers for the z/OS Open Tools Digest (weekly / monthly / quarterly).

Produces output in the community digest format (Markdown; "#" title, "##" sections, "###" tool/group names):

    # z/OS Open Tools Digest – <Month D, YYYY>
    ## New Tools                 (### **tool** + description)
    ## Miscellaneous Updates     (### CI/CD and CodeQL, RPM and DNF5 Support, Release Metadata,
                                  Documentation and Website, Build Framework and Package Manager,
                                  Port Updates, Version Updates)
    ## In Progress Tools / Libs
    ## Thanks for reading!

When a PR has no meaningful title/description, the PR body and changed files are read
to suggest one (via Copilot if a token is available, otherwise via file-based heuristics).

HOW EACH SECTION IS BUILT
  New Tools      Port repos (name ends in "port") CREATED inside the window (one org listing, newest first,
                 so direct pushes without PRs are caught), plus repos whose PR #1 merged inside the window.
  Misc Updates   Merged PRs in the window (meta first, then ports), capped at MAX_MISC_ITEMS. Bot version
                 bumps ("Update X-version to ...") are collapsed into one "Version Updates" line.
  In Progress    Open, non-bot PRs updated in the window - one entry per repo.

--------------------------------------------------------------------------------------------------
AUTOMATION (GitHub Actions, runs in zopencommunity/meta)
--------------------------------------------------------------------------------------------------
  Digest     Workflow file                          Schedule (UTC)            Default window  Artifact
  Weekly     .github/workflows/weekly_status.yml     Mondays 12:00             7 days          weekly-status-report
  Monthly    .github/workflows/monthly_status.yml    1st of month 12:00        30 days         monthly-status-report
  Quarterly  .github/workflows/quarterly_digest.yml  1 Jan/Apr/Jul/Oct 12:00   90 days         quarterly-digest-report

  Flow: cron / workflow_dispatch -> checkout -> run the generator script -> append the digest to the job
        summary -> upload the .md file as an artifact. Quarterly can also publish a GitHub Discussion.
  One-time setup (repo Settings -> Secrets and variables -> Actions):
    - GITHUB_TOKEN   provided automatically; used for all GitHub reads (no setup needed).
    - COPILOT_TOKEN  optional secret; enables LLM-written PR descriptions. Without it descriptions come
                     from the PR body, then the changed files.
  Trigger an automated run on demand:
    GitHub UI : Actions tab -> pick the workflow -> "Run workflow" (optionally change "days").
    gh CLI    : gh workflow run weekly_status.yml    [-f days=14]
                gh workflow run monthly_status.yml   [-f days=30]
                gh workflow run quarterly_digest.yml [-f days=90] [-f publish=true] [-f category=Announcements]
    Then      : gh run list --workflow weekly_status.yml   /   gh run download <run-id>
  Note: scheduled workflows only run from the repository's DEFAULT branch - merge to main first.

--------------------------------------------------------------------------------------------------
MANUAL RUN (from the root of the meta repo)
--------------------------------------------------------------------------------------------------
  Setup (once per shell; never paste tokens into chats, commits or scripts):
    read -rs GH_TOKEN && export GH_TOKEN        # GitHub token: avoids the API rate limit
    read -rs COPILOT_TOKEN && export COPILOT_TOKEN   # optional

  Weekly     python3 tools/generate_monthly_status.py --days 7  --period Weekly  -o weekly_status.md  --print
  Monthly    python3 tools/generate_monthly_status.py --days 30 --period Monthly -o monthly_status.md --print
  Quarterly  python3 tools/generate_quarterly_digest.py --days 90 -o quarterly_digest.md --print
  Publish    python3 tools/generate_quarterly_digest.py --days 90 --publish --category Announcements
             (needs a token with discussions:write)

  Audit which tools were detected as new:
    python3 tools/generate_monthly_status.py --days 14 --period Weekly -o /tmp/w.md 2>&1 | grep "New tool"

  Offline test of the PR-description fallback (no token needed):
    cd tools && python3 -c "import digest_format as d; \\
      d.fetch_pr_context=lambda *a,**k:{'body':'','files':['buildenv','x.patch'],'snippets':''}; \\
      print(d.describe_pr('o',{'repo':'librepoport','number':4,'title':'Use main branch'},None,None))"
    # expected: Updated build configuration and z/OS patches.

  Troubleshooting:
    "HTTP Error 403: rate limit exceeded"  -> GH_TOKEN missing/invalid; set it and re-run.
    Descriptions look generic              -> no COPILOT_TOKEN, or it was rejected (github_pat_ tokens are
                                              usually not accepted by the Copilot endpoint; errors are silent).
    Slack shows ":hammerandwrench:"        -> paste as plain text; a Markdown preview eats the underscores.
"""

from datetime import datetime, timedelta, timezone
import json
from pathlib import Path
import re
import sys
from typing import Any, Dict, List, Optional, Tuple
import urllib.parse
import urllib.request

API = "https://api.github.com"
DESCRIPTIONS_URL = "https://raw.githubusercontent.com/zopencommunity/meta/main/docs/api/zopen_releases_descriptions.json"
DESCRIPTIONS_LOCAL = Path(__file__).resolve().parent.parent / "docs" / "api" / "zopen_releases_descriptions.json"

BOT_AUTHORS = {"zosopentoolsmain", "github-actions[bot]", "github-actions", "actions@github.com", "bot"}
BUMP_RE = re.compile(r"Update (.+?)-version to ([^ ]+) from ([^ ]+)", re.IGNORECASE)
MAX_MISC_ITEMS = 20
MAX_IN_PROGRESS = 10
VAGUE_TITLE_WORDS = 4  # titles shorter than this (with no PR body) are considered not meaningful


# ---------------------------------------------------------------------------
# GitHub access
# ---------------------------------------------------------------------------

def _headers(token: Optional[str]) -> Dict[str, str]:
    h = {"User-Agent": "zopen-digest-generator", "Accept": "application/vnd.github+json"}
    if token:
        h["Authorization"] = f"Bearer {token}"
    return h


def github_get(path: str, token: Optional[str]) -> Any:
    """GET a GitHub REST path (or full URL) and return parsed JSON, or None on failure."""
    url = path if path.startswith("http") else f"{API}{path}"
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=_headers(token)), timeout=15) as resp:
            return json.loads(resp.read().decode())
    except Exception as e:
        print(f"Notice: GET {url} failed: {e}", file=sys.stderr)
        return None


def search_prs(query: str, token: Optional[str], max_pages: int = 5) -> List[Dict[str, Any]]:
    """Run a GitHub issue/PR search and return normalized PR dicts."""
    prs: List[Dict[str, Any]] = []
    for page in range(1, max_pages + 1):
        q = urllib.parse.quote(query)
        data = github_get(f"/search/issues?q={q}&per_page=100&page={page}&sort=updated&order=desc", token)
        items = (data or {}).get("items", [])
        for item in items:
            repo_url = item.get("repository_url", "")
            prs.append({
                "number": item.get("number"),
                "title": item.get("title") or "",
                "url": item.get("html_url"),
                "repo": repo_url.split("/")[-1] if repo_url else "unknown",
                "author": (item.get("user") or {}).get("login") or "unknown",
            })
        if len(items) < 100:
            break
    return prs


def fetch_merged_prs(org: str, since_date: str, token: Optional[str]) -> List[Dict[str, Any]]:
    return search_prs(f"org:{org} is:pr is:merged merged:>={since_date}", token)


def fetch_open_prs(org: str, since_date: str, token: Optional[str]) -> List[Dict[str, Any]]:
    return search_prs(f"org:{org} is:pr is:open updated:>={since_date}", token, max_pages=2)


# ---------------------------------------------------------------------------
# Tool names / descriptions
# ---------------------------------------------------------------------------

def tool_name(repo: str) -> str:
    return repo[:-4] if repo.endswith("port") else repo


def load_tool_descriptions() -> Dict[str, str]:
    """Tool -> one-line description, from the local checkout or the published meta copy."""
    try:
        if DESCRIPTIONS_LOCAL.exists():
            return json.loads(DESCRIPTIONS_LOCAL.read_text(encoding="utf-8")).get("descriptions", {})
        req = urllib.request.Request(DESCRIPTIONS_URL, headers={"User-Agent": "zopen-digest-generator"})
        with urllib.request.urlopen(req, timeout=10) as resp:
            return json.loads(resp.read().decode()).get("descriptions", {})
    except Exception as e:
        print(f"Notice: could not load tool descriptions: {e}", file=sys.stderr)
        return {}


def known_tool_description(org: str, repo: str, descriptions: Dict[str, str], token: Optional[str]) -> str:
    desc = descriptions.get(tool_name(repo), "")
    if not desc:
        data = github_get(f"/repos/{org}/{repo}", token) or {}
        desc = (data.get("description") or "").strip()
    return desc


# ---------------------------------------------------------------------------
# PR understanding (title / body / changed files -> description)
# ---------------------------------------------------------------------------

def is_bot(login: Optional[str]) -> bool:
    return not login or "[bot]" in login.lower() or login.lower() in BOT_AUTHORS


def clean_title(title: str) -> str:
    return re.sub(r"^(feat|fix|perf|chore|docs|refactor)(\(.*?\))?:\s*", "", title.strip(), flags=re.IGNORECASE)


_CTX_CACHE: Dict[Tuple[str, str, int], Dict[str, Any]] = {}


def fetch_pr_context(org: str, repo: str, number: int, token: Optional[str]) -> Dict[str, Any]:
    """PR body + changed files; cached so grouping and describing a PR cost one set of API calls."""
    key = (org, repo, number)
    if key not in _CTX_CACHE:
        _CTX_CACHE[key] = _fetch_pr_context(org, repo, number, token)
    return _CTX_CACHE[key]


def _fetch_pr_context(org: str, repo: str, number: int, token: Optional[str]) -> Dict[str, Any]:
    pr = github_get(f"/repos/{org}/{repo}/pulls/{number}", token) or {}
    files = github_get(f"/repos/{org}/{repo}/pulls/{number}/files?per_page=100", token) or []
    names = [f.get("filename", "") for f in files]
    snippets = []
    for f in files[:8]:
        patch = f.get("patch") or ""
        snippets.append(f"{f.get('filename', '')}:\n" + "\n".join(patch.split("\n")[:10]) if patch else f.get("filename", ""))
    return {"body": (pr.get("body") or "").strip(), "files": names, "snippets": "\n".join(snippets)}


TEMPLATE_NOISE_RE = re.compile(r"^(related issues?|closes|fixes|resolves|type of change|checklist|description)\b", re.IGNORECASE)
IDENTIFIER_RE = re.compile(r"(?<![`\w:/.\-])([\w.]*_[\w.]*\w)(?![`\w:/])")   # whole token, e.g. rollout_codeql.sh


def plain(text: str) -> str:
    """Single line of plain text that survives both Slack and Markdown viewers."""
    text = re.sub(r"<!--.*?-->", " ", text, flags=re.DOTALL)
    text = re.sub(r"<[^>\n]+>", " ", text)                      # HTML tags
    text = re.sub(r"!?\[([^\]]*)\]\([^)]*\)", r"\1", text)      # markdown links/images -> label
    text = text.replace("**", "").replace("`", "")
    text = re.sub(r"\s+", " ", text).strip()
    return IDENTIFIER_RE.sub(r"`\1`", text)                     # __os_install_post -> `__os_install_post`


def body_summary(body: str, limit: int = 220) -> str:
    """First meaningful sentences of a PR body, ignoring template noise, list markers and headings."""
    body = re.sub(r"<!--.*?-->", "", body, flags=re.DOTALL)
    sentences: List[str] = []
    in_code = False
    for raw in body.splitlines():
        line = raw.strip()
        if line.startswith("```"):
            in_code = not in_code
            continue
        if in_code or not line or line.startswith(("#", ">", "|", "---")):
            continue
        if re.match(r"^[-*+]\s+\[[ xX]\]", line):        # checkbox items are PR-template checklists, not descriptions
            continue
        line = re.sub(r"^([-*+]|\d+[.)])\s+", "", line).strip()                  # list markers
        if not line or TEMPLATE_NOISE_RE.match(line) or len(line.split()) < 3:
            continue
        sentences.append(line if line.endswith((".", "!", "?", ":")) else line + ".")
        if len(sentences) == 2:
            break
    text = plain(" ".join(sentences))
    return text if len(text) <= limit else text[:limit].rsplit(" ", 1)[0] + "..."


def is_meaningful(title: str, body: str) -> bool:
    return len(body_summary(body)) >= 30 or len(title.split()) >= VAGUE_TITLE_WORDS


def describe_files(files: List[str]) -> str:
    """Suggest what a PR changed purely from the file paths."""
    kinds: List[str] = []

    def add(label: str) -> None:
        if label not in kinds:
            kinds.append(label)

    for f in files:
        low = f.lower()
        if low.startswith(".github/workflows") or low.endswith((".yml", ".yaml")):
            add("CI/CD workflows")
        elif "patch" in low:
            add("z/OS patches")
        elif low.endswith("buildenv") or low.endswith(("cmakelists.txt", "makefile", ".mk")):
            add("build configuration")
        elif low.endswith((".md", ".rst", ".txt")) or low.startswith("docs/"):
            add("documentation")
        elif "test" in low:
            add("tests")
        elif low.endswith((".c", ".cc", ".cpp", ".h", ".hpp", ".py", ".sh", ".go", ".rs", ".js", ".java")):
            add("source code")
        else:
            add("project files")
    if not kinds:
        return ""
    joined = kinds[0] if len(kinds) == 1 else ", ".join(kinds[:-1]) + " and " + kinds[-1]
    return f"Updated {joined}."


def llm_complete(system: str, prompt: str, token: Optional[str]) -> Optional[str]:
    """Single GitHub Copilot chat completion; returns None when unavailable."""
    if not token:
        return None
    payload = {
        "model": "gpt-4o",
        "messages": [{"role": "system", "content": system}, {"role": "user", "content": prompt}],
        "temperature": 0.2,
    }
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json", "Accept": "application/json"}
    try:
        req = urllib.request.Request("https://api.githubcopilot.com/chat/completions",
                                     data=json.dumps(payload).encode("utf-8"), headers=headers)
        with urllib.request.urlopen(req, timeout=20) as resp:
            content = json.loads(resp.read().decode()).get("choices", [{}])[0].get("message", {}).get("content", "")
            return content.strip() or None
    except Exception:
        return None


def describe_pr(org: str, pr: Dict[str, Any], token: Optional[str], llm_token: Optional[str]) -> str:
    """One- or two-sentence description of what the PR does ('' if the title already says it all)."""
    ctx = fetch_pr_context(org, pr["repo"], pr["number"], token)
    title = clean_title(pr["title"])
    tool = tool_name(pr["repo"])

    suggestion = llm_complete(
        "You are a concise technical writer for the z/OS Open Tools community digest.",
        f"Describe in one or two plain sentences (max 40 words, no PR numbers, no author names, no markdown) "
        f"what this change does for the z/OS tool '{tool}'. Base it on the actual file changes, not only the title.\n\n"
        f"Title: {title}\nDescription: {ctx['body'] or '(none)'}\nChanged files / patches:\n{ctx['snippets'] or '(unavailable)'}",
        llm_token,
    )
    if suggestion:
        return suggestion.replace("\n", " ")

    summary = body_summary(ctx["body"])
    if summary:
        return summary
    if is_meaningful(title, ctx["body"]):
        return ""
    return describe_files(ctx["files"]) or f"New enhancements in {tool}."


def bullet(name: str, text: str, prefix: str = "") -> str:
    """One digest bullet as a Markdown block: title, hard line break, then the description."""
    head = f"• **{prefix}**: {plain(name)}" if prefix else f"• {plain(name)}"
    if text and plain(text).lower().rstrip(".") != plain(name).lower().rstrip("."):
        return f"{head}  \n{plain(text)}"
    return head


# Themes used to group `meta` PRs in Miscellaneous Updates (first match on the title wins, then on changed files)
META_GROUPS = [
    ("CI/CD and CodeQL", ("codeql", "workflow", "multi-gitter", "multi gitter", "gh auth", "rollout", "github app", "github action")),
    ("RPM and DNF5 Support", ("rpm", "dnf")),
    ("Release Metadata", ("release", "metadata", "cache")),
    ("Documentation and Website", ("doc", "blog", "readme", "guide", "website", "page")),
    ("Build Framework and Package Manager", ("zopen-build", "zopen build", "zopen-init", "zopen_", "buildenv", "dependenc", "install")),
]
OTHER_GROUP = "Other Updates"


def categorize(title: str, files: List[str]) -> str:
    low = title.lower()
    for name, keywords in META_GROUPS:
        if any(k in low for k in keywords):
            return name
    paths = " ".join(files).lower()
    for name, keywords in META_GROUPS:
        if any(k in paths for k in keywords):
            return name
    return OTHER_GROUP


# ---------------------------------------------------------------------------
# New tool detection
# ---------------------------------------------------------------------------

def new_port_repos(org: str, since_date: str, token: Optional[str], merged_prs: List[Dict[str, Any]]) -> List[str]:
    """
    Ports that first appeared inside the window, found without per-repo lookups:
      1. repos created since `since_date` - one org listing sorted newest-first, stopping at the
         first repo older than the window (covers direct pushes, no PR needed)
      2. repos whose PR #1 was merged inside the window (the repo's very first PR)
    """
    found: Dict[str, str] = {}
    for page in range(1, 4):
        data = github_get(f"/orgs/{org}/repos?type=all&sort=created&direction=desc&per_page=100&page={page}", token)
        if not data:
            break
        done = False
        for r in data:
            created = (r.get("created_at") or "")[:10]
            if created < since_date:
                done = True
                break
            if r["name"].endswith("port") and not r.get("archived") and not r.get("fork"):
                found[r["name"]] = f"repo created {created}"
        if done or len(data) < 100:
            break

    for p in merged_prs:
        if p["repo"].endswith("port") and p["number"] == 1:
            found.setdefault(p["repo"], "PR #1 merged inside the window")

    for repo, reason in sorted(found.items()):
        print(f"New tool {repo}: {reason}", file=sys.stderr)
    return sorted(found)


# ---------------------------------------------------------------------------
# Rendering
# ---------------------------------------------------------------------------

def render_digest(
    org: str,
    merged_prs: List[Dict[str, Any]],
    open_prs: List[Dict[str, Any]],
    token: Optional[str],
    llm_token: Optional[str],
    since_date: str,
    title_prefix: str = "",
    now: Optional[datetime] = None,
) -> str:
    now = now or datetime.now(timezone.utc)
    descriptions = load_tool_descriptions()

    is_bump = lambda p: bool(BUMP_RE.search(p["title"])) or is_bot(p["author"])
    bumps = [p for p in merged_prs if is_bump(p)]
    changes = [p for p in merged_prs if not is_bump(p)]

    # New tools: port repos that first appeared inside the window
    new_repos = new_port_repos(org, since_date, token, merged_prs)

    # The digest is a list of Markdown blocks joined by blank lines; "  \n" inside a block is a hard line break.
    blocks: List[str] = [
        f"# z/OS Open Tools {title_prefix}Digest – {now:%B} {now.day}, {now.year}",
        "Hello everyone!  \nWelcome to another edition of the z/OS Open Tools Digest. "
        "Here’s a summary of newly added tools, ongoing work, and recent updates.",
    ]

    # New Tools
    if new_repos:
        blocks.append("## New Tools")
        for repo in sorted(new_repos):
            desc = known_tool_description(org, repo, descriptions, token)
            if not desc:
                repo_prs = [p for p in changes if p["repo"] == repo]
                first = min(repo_prs, key=lambda p: p["number"]) if repo_prs else None
                desc = (describe_pr(org, first, token, llm_token) if first else "") or f"New z/OS port of {tool_name(repo)}."
            blocks.append(f"### **{tool_name(repo)}**")
            blocks.append(plain(desc))
        blocks.append("To install: `zopen install <tool_name>`")

    # Miscellaneous Updates: meta PRs grouped by theme, then port PRs, then version bumps
    misc = [p for p in changes if p["repo"] not in new_repos]
    misc.sort(key=lambda p: (p["repo"] != "meta", p["repo"], -p["number"]))
    shown, hidden = misc[:MAX_MISC_ITEMS], max(0, len(misc) - MAX_MISC_ITEMS)
    version_updates: Dict[str, str] = {}
    for p in bumps:
        m = BUMP_RE.search(p["title"])
        if m:
            version_updates.setdefault(m.group(1), m.group(2))

    if shown or version_updates:
        blocks.append("## Miscellaneous Updates")

        groups: Dict[str, List[str]] = {}
        for p in (p for p in shown if p["repo"] == "meta"):
            title = clean_title(p["title"])
            group = categorize(title, fetch_pr_context(org, "meta", p["number"], token)["files"])
            groups.setdefault(group, []).append(bullet(title, describe_pr(org, p, token, llm_token)))
        for name in [g for g, _ in META_GROUPS] + [OTHER_GROUP]:
            if name in groups:
                blocks.append(f"### {name}")
                blocks += groups[name]

        port_prs = [p for p in shown if p["repo"] != "meta"]
        if port_prs:
            blocks.append("### Port Updates")
            for p in port_prs:
                blocks.append(bullet(clean_title(p["title"]), describe_pr(org, p, token, llm_token), prefix=tool_name(p["repo"])))

        if hidden:
            blocks.append(f"*...and {hidden} more updates across the community repositories.*")
        if version_updates:
            blocks.append("### Version Updates")
            blocks.append(", ".join(f"{t} {v}" for t, v in sorted(version_updates.items())))

    # In Progress Tools / Libs
    seen = set()
    in_progress = []
    for p in open_prs:
        if is_bot(p["author"]) or BUMP_RE.search(p["title"]) or p["repo"] in seen:
            continue
        seen.add(p["repo"])
        in_progress.append(p)
    if in_progress:
        blocks.append("## In Progress Tools / Libs")
        for p in in_progress[:MAX_IN_PROGRESS]:
            repo = p["repo"]
            desc = "" if repo == "meta" else known_tool_description(org, repo, descriptions, token)
            blocks.append(f"• **{tool_name(repo)}** – {plain(desc or clean_title(p['title']))}")

    blocks.append("## Thanks for reading!")
    blocks.append("Stay tuned for more updates in the next digest.  \n"
                  "Feel free to reach out if you have any questions, suggestions, or contributions.")
    return "\n\n".join(blocks) + "\n"


def since_date_for(days: int) -> str:
    return (datetime.now(timezone.utc) - timedelta(days=days)).strftime("%Y-%m-%d")
