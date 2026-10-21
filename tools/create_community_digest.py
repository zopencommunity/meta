#!/usr/bin/env python3
"""Draft (and optionally post) the monthly zopen Community Digest.

Facts come from data, never from the model: new and updated tools from the
release cache, Python wheels and RPMs from the package catalogues, version
upgrades from the bump PRs, and everything else from merged pull requests
across the organisation.  A model (GitHub Models) only groups the human PRs
into enhancements and fixes and writes the introduction; every item it returns
must cite PR URLs that are present in the facts, or it is dropped.  The model is
GitHub Copilot through the Copilot CLI (``--ai copilot``, authenticated with
COPILOT_GITHUB_TOKEN) or any OpenAI-compatible chat completions endpoint
(``--ai openai`` with DIGEST_MODEL_URL and DIGEST_MODEL_API_KEY).  With
``--ai none`` the digest still renders, listing the merged changes per repository.

  draft:  python3 tools/create_community_digest.py draft --month 2026-09
  post:   python3 tools/create_community_digest.py post --body-file digest.md --title "..."
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import time
import urllib.error
import urllib.parse
import urllib.request


ORG = "zopencommunity"
API = "https://api.github.com"
CACHE_URL = "https://github.com/zopencommunity/meta/releases/download/api-cache/"
SITE = "https://zopen.community"
PROMPT_PATH = Path(__file__).with_name("community_digest_prompt.md")
# Accounts whose PRs are automation, not community work.
BOT_LOGINS = {"zosopentoolsmain", "dependabot[bot]", "github-actions[bot]", "Copilot", "copilot-swe-agent[bot]"}
BUMP_RE = re.compile(r"^Update (?P<tool>\S+?)-version to (?P<new>\S+) from (?P<old>\S+)")
ZOS_RE = re.compile(r"z/?os|s390|ebcdic|zopen", re.IGNORECASE)
COMING_SOON_DAYS = 90


# --- pure helpers ----------------------------------------------------------

def month_window(month: str | None, today: dt.date | None = None, through: str | None = None) -> tuple[dt.date, dt.date]:
    """Return the first day of ``month`` and the last day of ``through`` (both YYYY-MM).

    ``month`` defaults to last month and ``through`` to ``month``, so a catch-up
    digest can span several months.
    """
    if month:
        start = dt.datetime.strptime(month, "%Y-%m").date()
    else:
        first_this_month = (today or dt.date.today()).replace(day=1)
        start = (first_this_month - dt.timedelta(days=1)).replace(day=1)
    last = dt.datetime.strptime(through, "%Y-%m").date() if through else start
    next_month = (last.replace(day=28) + dt.timedelta(days=4)).replace(day=1)
    return start, next_month - dt.timedelta(days=1)


def period_name(start: dt.date, end: dt.date) -> str:
    if (start.year, start.month) == (end.year, end.month):
        return start.strftime("%B %Y")
    if start.year == end.year:
        return f"{start.strftime('%B')}–{end.strftime('%B %Y')}"
    return f"{start.strftime('%B %Y')}–{end.strftime('%B %Y')}"


def parse_date(value: str | None) -> dt.date | None:
    if not value:
        return None
    return dt.datetime.fromisoformat(value.replace("+00:00Z", "+00:00").replace("Z", "+00:00")).date()


def in_window(value: str | None, start: dt.date, end: dt.date) -> bool:
    day = parse_date(value)
    return day is not None and start <= day <= end


def parse_bump(title: str) -> dict[str, str] | None:
    match = BUMP_RE.match(title.strip())
    return match.groupdict() if match else None


def port_repo(release: dict) -> str | None:
    for asset in release.get("assets", []):
        match = re.search(r"github\.com/zopencommunity/([^/]+)/releases", asset.get("url", ""))
        if match:
            return match.group(1)
    return None


def classify_releases(release_data: dict, start: dt.date, end: dt.date) -> tuple[list[dict], list[dict]]:
    """Split tools released in the window into first releases and updates.

    The cache only reaches back to its minimum year, so a "first release" here
    is a candidate that the caller confirms against the repository.
    """
    first, updated = [], []
    for tool, releases in sorted(release_data.items()):
        dates = sorted(d for d in (parse_date(r.get("date")) for r in releases) if d)
        in_range = [r for r in releases if in_window(r.get("date"), start, end)]
        if not in_range:
            continue
        latest = max(in_range, key=lambda r: r["date"])
        asset = (latest.get("assets") or [{}])[0]
        entry = {
            "tool": tool,
            "repo": port_repo(latest),
            "version": asset.get("version"),
            "release_url": f"https://github.com/{ORG}/{port_repo(latest)}/releases/tag/{latest.get('tag_name')}",
            "dev": str(latest.get("tag_name", "")).startswith("DEV_"),
            "date": latest["date"],
        }
        (first if dates and dates[0] >= start else updated).append(entry)
    return first, updated


def short_description(text: str, limit: int = 110) -> str:
    """First sentence of a description, trimmed for a one-line bullet."""
    text = re.split(r"(?<!e\.g\.)(?<!i\.e\.)(?<=[.!?])\s", " ".join(text.split()), maxsplit=1)[0].rstrip(".")
    return text if len(text) <= limit else text[: limit - 1].rsplit(" ", 1)[0] + "…"


def packages_in_window(packages: list[dict], start: dt.date, end: dt.date) -> list[dict]:
    return [
        {"name": p["name"], "release_key": p.get("releaseKey") or p["name"], "version": p.get("version"), "url": p.get("releaseUrl") or p.get("portRepositoryUrl")}
        for p in packages
        if in_window(p.get("publishedAt"), start, end)
    ]


def split_prs(prs: list[dict]) -> tuple[list[dict], list[dict]]:
    """Separate version-bump automation from human work."""
    bumps, human = [], []
    for pr in prs:
        bump = parse_bump(pr["title"])
        if bump and pr["author"] in BOT_LOGINS:
            bumps.append({**bump, "url": pr["url"], "number": pr["number"]})
        elif pr["author"] not in BOT_LOGINS or pr["author"] in {"Copilot", "copilot-swe-agent[bot]"}:
            human.append(pr)
    return bumps, human


def validate_narrative(narrative: dict, known_urls: set[str]) -> dict:
    """Keep only model items whose every cited URL is a real PR from the facts."""
    clean = {"intro": str(narrative.get("intro", "")).strip()}
    for section in ("enhancements", "fixes", "upstream"):
        items = []
        for item in narrative.get(section) or []:
            urls = [u for u in item.get("urls") or [] if isinstance(u, str)]
            if urls and all(u in known_urls for u in urls) and item.get("summary"):
                items.append({"title": str(item.get("title", "")).strip(), "summary": str(item["summary"]).strip(), "urls": urls})
        clean[section] = items
    # The intro must not introduce links of its own.
    if re.search(r"https?://", clean["intro"]):
        clean["intro"] = ""
    return clean


def _links(urls: list[str]) -> str:
    return " ".join(f"[#{u.rstrip('/').rsplit('/', 1)[-1]}]({u})" for u in urls)


def render_digest(facts: dict, narrative: dict | None) -> str:
    month = facts["month_name"]
    lines: list[str] = []
    intro = (narrative or {}).get("intro") or (
        f"Here's what happened across the zopen community in {month}: new tools, package updates, "
        "fixes and the people who made them happen."
    )
    lines += [intro, ""]

    def tool_line(tool: dict) -> str:
        thanks = f" Thank you {', '.join('@' + c for c in tool['contributors'])}!" if tool["contributors"] else ""
        desc = f" – {tool['description']}" if tool["description"] else ""
        dev = " _(dev build)_" if tool.get("dev") else ""
        return f"* **[{tool['tool']}]({tool['release_url']})**{dev}{desc}.{thanks}"

    if facts["new_tools"]:
        lines += [":new: **New Tools Now Available**", ""]
        lines += [tool_line(tool) for tool in facts["new_tools"]]
        lines += ["", ":bulb: To install any of the new tools: `zopen install <tool>`", ""]

    new_python = facts.get("new_python_packages", [])
    if new_python or facts["python_packages"]:
        lines += [":snake: **Python Packages**", ""]
        if new_python:
            lines += ["New wheels on the zopen Python index:", ""]
            lines += [tool_line(tool) for tool in new_python]
            lines.append("")
        new_names = {tool["tool"] for tool in new_python}
        updated = [p for p in facts["python_packages"] if p["release_key"] not in new_names]
        if updated:
            names = ", ".join(f"[{p['name']} {p['version']}]({p['url']})" for p in updated)
            lines += [f"Updated in {month}: {names}.", ""]
        lines += [
            "Install with `uv pip install` or `pip install` from the zopen index.",
            "",
            f"The index now serves {facts['python_totals']['packages']} packages and {facts['python_totals']['wheels']} wheels. "
            f"See [{SITE}/PythonPackages]({SITE}/PythonPackages).",
            "",
        ]

    if facts["rpm_packages"]:
        lines += [":package: **RPM Packages**", ""]
        names = ", ".join(p["name"] for p in facts["rpm_packages"])
        lines += [
            f"{len(facts['rpm_packages'])} RPMs published or updated in {month}: {names}.",
            "",
            f"The repository now holds {facts['rpm_totals']['packages']} packages. "
            f"Set up dnf5 with [{SITE}/Guides/RpmSetup]({SITE}/Guides/RpmSetup).",
            "",
        ]

    sections = [("enhancements", ":sparkles: **Enhancements**"), ("fixes", ":wrench: **Fixes**"), ("upstream", ":arrow_up: **Upstream Contributions**")]
    if narrative:
        for key, heading in sections:
            if narrative.get(key):
                lines += [heading, ""]
                for item in narrative[key]:
                    title = f"**{item['title']}** – " if item["title"] else ""
                    lines.append(f"* {title}{item['summary']} {_links(item['urls'])}")
                lines.append("")
    else:
        if facts["human_prs"]:
            lines += [":hammer_and_wrench: **Changes Merged**", ""]
            by_repo: dict[str, list[dict]] = {}
            for pr in facts["human_prs"]:
                by_repo.setdefault(pr["repo"], []).append(pr)
            for repo, prs in sorted(by_repo.items(), key=lambda item: (-len(item[1]), item[0])):
                lines += [f"<details><summary><b>{repo.split('/', 1)[1]}</b> ({len(prs)})</summary>", ""]
                lines += [f"* {pr['title'].strip()} ([#{pr['number']}]({pr['url']}) by @{pr['author']})" for pr in prs]
                lines += ["", "</details>"]
            lines.append("")
        if facts["upstream_prs"]:
            lines += [":arrow_up: **Upstream Contributions**", ""]
            lines += [f"* {pr['repo']}: {pr['title']} ([PR]({pr['url']}) by @{pr['author']})" for pr in facts["upstream_prs"]]
            lines.append("")

    if facts["upgrades"]:
        lines += [":arrows_counterclockwise: **Tool Upgrades**", "", "We kept these tools current with upstream:", ""]
        lines += [f"* {u['tool']} {u['old']} → {u['new']}" for u in facts["upgrades"]]
        lines.append("")

    if facts["coming_soon"]:
        lines += [":construction: **Coming Soon**", "", "New ports in progress – contributions and testing welcome:", ""]
        lines += [f"* [{r['name']}]({r['url']})" + (f" – {r['description']}" if r["description"] else "") for r in facts["coming_soon"]]
        lines.append("")

    if facts["contributors"]:
        lines += [":clap: **Thank You**", ""]
        lines.append(f"A big thank you to everyone who contributed in {month}: " + ", ".join("@" + c for c in facts["contributors"]) + ".")
        if facts["first_time_contributors"]:
            lines.append("Congratulations on your first merged pull request, " + ", ".join("@" + c for c in facts["first_time_contributors"]) + "!")
        lines.append("")

    lines += [
        "---",
        f"_Want something ported? [Request or vote for a package]({SITE}/PackageRequests). "
        "This digest is drafted automatically from zopen release data and merged pull requests, and reviewed by a maintainer before posting._",
    ]
    return "\n".join(lines) + "\n"


# --- GitHub access ---------------------------------------------------------

def request_json(url: str, token: str | None, body: dict | None = None, retries: int = 3, accept: str = "application/vnd.github+json") -> dict | list:
    headers = {"Accept": accept, "User-Agent": "zopen-community-digest/1.0", "X-GitHub-Api-Version": "2022-11-28"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    data = None
    if body is not None:
        data = json.dumps(body).encode("utf-8")
        headers["Content-Type"] = "application/json"
    for attempt in range(retries):
        try:
            with urllib.request.urlopen(urllib.request.Request(url, data=data, headers=headers), timeout=60) as response:
                return json.loads(response.read().decode("utf-8"))
        except urllib.error.HTTPError as error:
            # Search is limited to 30 requests a minute; wait out secondary limits.
            if error.code in (403, 429) and attempt < retries - 1:
                time.sleep(int(error.headers.get("Retry-After", "30")))
                continue
            raise
    raise RuntimeError(f"unreachable: {url}")


def github(path: str, token: str | None, **params: object) -> dict | list:
    query = f"?{urllib.parse.urlencode(params)}" if params else ""
    return request_json(f"{API}{path}{query}", token)


def graphql(query: str, token: str, **variables: object) -> dict:
    result = request_json(f"{API}/graphql", token, {"query": query, "variables": variables})
    if result.get("errors"):
        raise RuntimeError(json.dumps(result["errors"]))
    return result["data"]


def search_prs(query: str, token: str | None) -> list[dict]:
    prs, page = [], 1
    while True:
        result = github("/search/issues", token, q=query, per_page=100, page=page)
        for item in result["items"]:
            prs.append({
                "repo": item["repository_url"].rsplit("/", 2)[-2] + "/" + item["repository_url"].rsplit("/", 1)[-1],
                "number": item["number"],
                "title": item["title"],
                "url": item["html_url"],
                "author": item["user"]["login"],
                "body": (item.get("body") or "")[:600],
            })
        if len(result["items"]) < 100 or page * 100 >= min(result["total_count"], 1000):
            return prs
        page += 1
        time.sleep(2)


def search_count(query: str, token: str | None) -> int:
    time.sleep(2)
    return github("/search/issues", token, q=query, per_page=1)["total_count"]


def fetch_cache(name: str) -> dict:
    return request_json(CACHE_URL + name, None)


def is_new_tool(entry: dict, start: dt.date, min_year: int, token: str | None) -> bool:
    """Confirm a cache "first release" against the repository's full history."""
    repo = github(f"/repos/{ORG}/{entry['repo']}", token)
    entry["repo_description"] = repo.get("description") or ""
    if parse_date(repo["created_at"]) >= dt.date(min_year, 1, 1):
        return True
    page = 1
    while True:
        releases = github(f"/repos/{ORG}/{entry['repo']}/releases", token, per_page=100, page=page)
        if any((parse_date(r.get("published_at")) or start) < start for r in releases):
            return False
        if len(releases) < 100:
            return True
        page += 1


def top_contributors(repo: str, token: str | None, limit: int = 3) -> list[str]:
    try:
        people = github(f"/repos/{ORG}/{repo}/contributors", token, per_page=20)
    except urllib.error.HTTPError:
        return []
    return [p["login"] for p in people if p.get("type") == "User" and p["login"] not in BOT_LOGINS][:limit]


def gather_facts(start: dt.date, end: dt.date, token: str | None) -> dict:
    span = f"{start.isoformat()}..{end.isoformat()}"
    releases = fetch_cache("zopen_releases.json")
    descriptions = fetch_cache("zopen_releases_descriptions.json").get("descriptions", {})
    python = fetch_cache("python_packages.json")
    rpms = fetch_cache("rpm_packages.json")

    prs = search_prs(f"org:{ORG} is:pr is:merged merged:{span}", token)
    bumps, human = split_prs(prs)

    candidates, updated = classify_releases(releases["release_data"], start, end)
    new_tools = []
    for entry in candidates:
        if entry["repo"] and is_new_tool(entry, start, int(releases.get("minimum_release_year", 2024)), token):
            new_tools.append({
                "tool": entry["tool"],
                "description": short_description(descriptions.get(entry["tool"]) or entry.get("repo_description") or ""),
                "release_url": entry["release_url"],
                "dev": entry["dev"],
                # Credit whoever landed the port this month, else the repository's main contributors.
                "contributors": sorted({pr["author"] for pr in human if pr["repo"] == f"{ORG}/{entry['repo']}" and pr["author"] not in BOT_LOGINS})
                or top_contributors(entry["repo"], token),
            })
        else:
            updated.append(entry)

    python_keys = {p.get("releaseKey") or p["name"] for p in python["packages"]}
    new_python = [t for t in new_tools if t["tool"] in python_keys]
    authors = sorted({pr["author"] for pr in human if pr["author"] not in BOT_LOGINS} | {c for t in new_tools for c in t["contributors"]}, key=str.lower)
    first_timers = [a for a in authors if search_count(f"org:{ORG} is:pr is:merged author:{a} merged:<{start.isoformat()}", token) == 0]

    upstream = []
    for author in authors:
        for pr in search_prs(f"is:pr is:merged author:{author} merged:{span} -org:{ORG} -user:{author}", token):
            if ZOS_RE.search(pr["title"] + " " + pr["body"]):
                upstream.append(pr)
        time.sleep(2)

    released_repos = {port_repo(r) for rs in releases["release_data"].values() for r in rs}
    coming_soon = []
    for repo in github(f"/orgs/{ORG}/repos", token, sort="created", direction="desc", per_page=100):
        created = parse_date(repo["created_at"])
        if created < end - dt.timedelta(days=COMING_SOON_DAYS):
            break
        if created <= end and not repo["archived"] and repo["name"].endswith("port") and repo["name"] not in released_repos:
            coming_soon.append({"name": repo["name"].removesuffix("port"), "url": repo["html_url"], "description": short_description(repo.get("description") or "")})

    latest_bump: dict[str, dict] = {}
    for bump in sorted(bumps, key=lambda b: b["number"]):
        previous = latest_bump.get(bump["tool"])
        latest_bump[bump["tool"]] = {**bump, "old": previous["old"]} if previous else bump

    return {
        "month": start.strftime("%Y-%m"),
        "month_name": period_name(start, end),
        "title": f"zopen Community Digest – {period_name(start, end)}",
        "new_tools": [t for t in new_tools if t["tool"] not in python_keys],
        "new_python_packages": new_python,
        "updated_tools": [e["tool"] for e in updated],
        "python_packages": packages_in_window(python["packages"], start, end),
        "python_totals": {"packages": python["packageCount"], "wheels": python["wheelCount"]},
        "rpm_packages": packages_in_window(rpms["packages"], start, end),
        "rpm_totals": {"packages": rpms["packageCount"], "rpms": rpms["rpmCount"]},
        "upgrades": sorted(latest_bump.values(), key=lambda b: b["tool"].lower()),
        "human_prs": human,
        "upstream_prs": upstream,
        "coming_soon": coming_soon,
        "contributors": authors,
        "first_time_contributors": first_timers,
    }


# --- model and posting -----------------------------------------------------

def model_payload(facts: dict) -> dict:
    return {
        "month": facts["month_name"],
        "new_tools": [t["tool"] for t in facts["new_tools"] + facts.get("new_python_packages", [])],
        "merged_prs": [{k: pr[k] for k in ("repo", "title", "url", "author", "body")} for pr in facts["human_prs"]],
        "upstream_prs": [{k: pr[k] for k in ("repo", "title", "url", "author")} for pr in facts["upstream_prs"]],
    }


def parse_json_reply(text: str) -> dict:
    """Read the JSON object out of a chat reply, ignoring code fences or chatter around it."""
    start, end = text.find("{"), text.rfind("}")
    if start < 0 or end < start:
        raise ValueError(f"no JSON object in model reply: {text[:200]!r}")
    return json.loads(text[start : end + 1])


def ask_copilot(facts: dict, model: str | None) -> dict:
    # No tools: PR text is untrusted input, so the model only reads and writes text.
    # The prompt goes over stdin because a month of PRs can exceed Linux's 128 KB argument limit.
    prompt = (
        PROMPT_PATH.read_text(encoding="utf-8")
        + "\nInput:\n" + json.dumps(model_payload(facts), ensure_ascii=False)
        + "\n\nReply with the JSON object only."
    )
    command = [os.environ.get("COPILOT_BIN", "copilot"), "-s", "--no-color", "--available-tools"]
    if model:
        command += ["--model", model]
    with tempfile.TemporaryDirectory() as empty:
        result = subprocess.run(command, input=prompt, capture_output=True, text=True, timeout=900, cwd=empty)
    if result.returncode != 0:
        raise RuntimeError(f"copilot exited {result.returncode}: {result.stderr.strip()[-500:]}")
    return parse_json_reply(result.stdout)


def ask_openai_compatible(facts: dict, url: str, key: str | None, model: str) -> dict:
    payload = model_payload(facts)
    result = request_json(url, key, {
        "model": model,
        "temperature": 0.2,
        "response_format": {"type": "json_object"},
        "messages": [
            {"role": "system", "content": PROMPT_PATH.read_text(encoding="utf-8")},
            {"role": "user", "content": json.dumps(payload, ensure_ascii=False)},
        ],
    }, accept="application/json")
    return parse_json_reply(result["choices"][0]["message"]["content"])


def post_discussion(repo: str, category: str, title: str, body: str, token: str, force: bool) -> str:
    owner, name = repo.split("/", 1)
    data = graphql(
        """query($owner: String!, $name: String!) {
          repository(owner: $owner, name: $name) {
            id
            discussionCategories(first: 50) { nodes { id name } }
            discussions(first: 50, orderBy: {field: CREATED_AT, direction: DESC}) { nodes { title url } }
          }
        }""",
        token, owner=owner, name=name,
    )["repository"]
    category_id = next((c["id"] for c in data["discussionCategories"]["nodes"] if c["name"].lower() == category.lower()), None)
    if not category_id:
        raise SystemExit(f"No discussion category named {category!r} in {repo}")
    duplicate = next((d["url"] for d in data["discussions"]["nodes"] if d["title"] == title), None)
    if duplicate and not force:
        raise SystemExit(f"Already posted: {duplicate} (use --force to post again)")
    created = graphql(
        """mutation($repo: ID!, $category: ID!, $title: String!, $body: String!) {
          createDiscussion(input: {repositoryId: $repo, categoryId: $category, title: $title, body: $body}) { discussion { url } }
        }""",
        token, repo=data["id"], category=category_id, title=title, body=body,
    )
    return created["createDiscussion"]["discussion"]["url"]


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    commands = parser.add_subparsers(dest="command", required=True)
    draft = commands.add_parser("draft", help="Gather facts and write the digest markdown")
    draft.add_argument("--month", help="YYYY-MM (default: last month)")
    draft.add_argument("--through", help="YYYY-MM: end a catch-up digest at this month")
    draft.add_argument("--output", default="digest.md")
    draft.add_argument("--facts", default="digest_facts.json")
    draft.add_argument("--ai", choices=("copilot", "openai", "none"), default=os.environ.get("DIGEST_AI") or "copilot",
                       help="Model that groups the merged PRs (default: copilot)")
    draft.add_argument("--model", default=os.environ.get("DIGEST_MODEL"), help="Model name for the chosen backend")
    draft.add_argument("--model-url", default=os.environ.get("DIGEST_MODEL_URL"), help="Chat completions URL for --ai openai")
    post = commands.add_parser("post", help="Post a drafted digest as a GitHub Discussion")
    post.add_argument("--body-file", default="digest.md")
    post.add_argument("--title", required=True)
    post.add_argument("--repo", default=f"{ORG}/meta")
    post.add_argument("--category", default="Digest")
    post.add_argument("--force", action="store_true", help="Post even if a discussion with this title exists")
    args = parser.parse_args()

    # Same precedence as the gh CLI: GH_TOKEN wins over GITHUB_TOKEN.
    token = os.environ.get("GH_TOKEN") or os.environ.get("GITHUB_TOKEN")
    if args.command == "post":
        if not token:
            raise SystemExit("GH_TOKEN or GITHUB_TOKEN is required to post")
        try:
            print(post_discussion(args.repo, args.category, args.title, Path(args.body_file).read_text(encoding="utf-8"), token, args.force))
        except urllib.error.HTTPError as error:
            if error.code == 401:
                raise SystemExit("GitHub rejected the token (401). Check GH_TOKEN/GITHUB_TOKEN, e.g. GH_TOKEN=$(gh auth token).")
            raise
        return

    start, end = month_window(args.month, through=args.through)
    facts = gather_facts(start, end, token)
    narrative = None
    if args.ai != "none" and facts["human_prs"]:
        try:
            if args.ai == "copilot":
                reply = ask_copilot(facts, args.model)
            else:
                if not (args.model_url and args.model):
                    raise ValueError("--ai openai needs --model-url and --model")
                reply = ask_openai_compatible(facts, args.model_url, os.environ.get("DIGEST_MODEL_API_KEY"), args.model)
            known = {pr["url"] for pr in facts["human_prs"] + facts["upstream_prs"]}
            narrative = validate_narrative(reply, known)
        except (OSError, RuntimeError, subprocess.SubprocessError, urllib.error.URLError, KeyError, ValueError) as error:
            print(f"warning: model narrative unavailable ({error}); rendering without it", file=sys.stderr)
    Path(args.facts).write_text(json.dumps(facts, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    Path(args.output).write_text(render_digest(facts, narrative), encoding="utf-8")
    print(f"{facts['title']}: {len(facts['new_tools'])} new tools, {len(facts['upgrades'])} upgrades, "
          f"{len(facts['human_prs'])} merged changes -> {args.output}")


if __name__ == "__main__":
    main()
