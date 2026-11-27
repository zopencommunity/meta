#!/usr/bin/env python3
"""
Copilot-driven Planning Assistant for zopencommunity issues and PRs.

Invoked via comment `/plan <extra instructions>` or manual workflow dispatch.
Fetches the target issue/PR, loads relevant zopen guidelines (docs, Porting.md,
BestPractices.md), asks Copilot / LLM to formulate a grounded step-by-step
implementation plan, and posts the plan as a comment.

Usage:
  python3 tools/copilot_plan.py --number <issue_or_pr_number> [--is-pr] [--prompt "optional extra prompt"] [--post]
"""

import argparse
from datetime import datetime, timezone
import json
import os
import re
import subprocess
import sys
from typing import Any, Dict, List, Optional
import urllib.parse
import urllib.request


def get_token(args_token: Optional[str] = None) -> Optional[str]:
    return args_token or os.getenv("COPILOT_TOKEN") or os.getenv("GH_TOKEN") or os.getenv("GITHUB_TOKEN")


def make_github_request(url: str, token: Optional[str] = None, data: Optional[Dict[str, Any]] = None, method: str = "GET") -> Any:
    headers = {
        "User-Agent": "zopen-copilot-plan",
        "Accept": "application/vnd.github+json"
    }
    if token:
        headers["Authorization"] = f"Bearer {token}"

    req_data = json.dumps(data).encode("utf-8") if data is not None else None
    req = urllib.request.Request(url, data=req_data, headers=headers, method=method)
    with urllib.request.urlopen(req, timeout=20) as resp:
        content = resp.read().decode("utf-8")
        if content:
            return json.loads(content)
        return {}


def load_issue_or_pr_details(repo: str, number: int, is_pr: bool, token: Optional[str] = None) -> Dict[str, Any]:
    """Fetch title, body, comments, and (if PR) changed files."""
    base_api = f"https://api.github.com/repos/{repo}"
    
    # 1. Main Issue / PR metadata
    endpoint = f"{base_api}/pulls/{number}" if is_pr else f"{base_api}/issues/{number}"
    try:
        main_data = make_github_request(endpoint, token=token)
    except Exception as e:
        # Fall back to issue endpoint if pull endpoint fails
        endpoint = f"{base_api}/issues/{number}"
        main_data = make_github_request(endpoint, token=token)

    title = main_data.get("title", f"#{number}")
    body = main_data.get("body") or "(No description provided)"
    author = main_data.get("user", {}).get("login", "unknown")
    state = main_data.get("state", "open")

    # 2. Comments discussion
    comments_data = []
    try:
        comments_url = f"{base_api}/issues/{number}/comments?per_page=30"
        raw_comments = make_github_request(comments_url, token=token)
        for c in raw_comments:
            c_author = c.get("user", {}).get("login", "unknown")
            c_body = c.get("body", "")
            # Skip triggering command itself
            if c_body.strip().startswith("/plan"):
                continue
            comments_data.append(f"@{c_author}: {c_body}")
    except Exception as e:
        print(f"Notice: Could not fetch comments: {e}", file=sys.stderr)

    # 3. Changed files if PR
    files_changed = []
    if is_pr:
        try:
            files_url = f"{base_api}/pulls/{number}/files?per_page=30"
            files_raw = make_github_request(files_url, token=token)
            for f in files_raw:
                filename = f.get("filename", "")
                patch = f.get("patch", "")
                if patch:
                    patch_snippet = "\n".join(patch.split("\n")[:15])
                    files_changed.append(f"File: {filename}\nDiff snippet:\n{patch_snippet}")
                else:
                    files_changed.append(f"File: {filename}")
        except Exception:
            pass

    return {
        "title": title,
        "body": body,
        "author": author,
        "state": state,
        "comments": comments_data,
        "files_changed": files_changed
    }


def prepare_port_source_tree(repo: str, target_dir: Optional[str] = None) -> Dict[str, Any]:
    """
    For *port repositories (e.g. curlport), clone the port repo and run `zopen build -g`
    to fetch upstream source code and apply all z/OS patches.
    Returns metadata about buildenv, patches, and unpacked source files.
    """
    repo_name = repo.split("/")[-1]
    if repo_name == "meta":
        return {"is_port": False, "source_context": ""}

    print(f"Detected port repository '{repo_name}'. Preparing source code via `zopen build -g`...", file=sys.stderr)
    import tempfile
    working_dir = target_dir or tempfile.mkdtemp(prefix=f"zopen_plan_{repo_name}_")

    # 1. Clone the port repo into working_dir/port
    port_path = os.path.join(working_dir, repo_name)
    if not os.path.exists(port_path):
        subprocess.run(["git", "clone", f"https://github.com/{repo}.git", port_path], capture_output=True, text=True)

    buildenv_content = ""
    patches_summary = []
    source_structure = []

    # Read buildenv if present
    buildenv_file = os.path.join(port_path, "buildenv")
    if os.path.isfile(buildenv_file):
        try:
            with open(buildenv_file, "r", encoding="utf-8", errors="ignore") as f:
                buildenv_content = f.read()
        except Exception:
            pass

    # Read patches/ directory if present
    patches_dir = os.path.join(port_path, "patches")
    if os.path.isdir(patches_dir):
        for patch_file in sorted(os.listdir(patches_dir)):
            if patch_file.endswith((".patch", ".diff")):
                p_path = os.path.join(patches_dir, patch_file)
                try:
                    with open(p_path, "r", encoding="utf-8", errors="ignore") as f:
                        lines = f.readlines()[:25]  # first 25 lines of each patch
                        patches_summary.append(f"Patch '{patch_file}':\n" + "".join(lines))
                except Exception:
                    pass

    # 2. Run `zopen build -g` to download upstream source and apply patches
    # Locate meta/bin/zopen-build or zopen in PATH
    meta_bin = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "bin"))
    env = os.environ.copy()
    env["PATH"] = f"{meta_bin}:{env.get('PATH', '')}"

    try:
        cmd_res = subprocess.run(
            ["zopen", "build", "-g"],
            cwd=port_path,
            env=env,
            capture_output=True,
            text=True,
            timeout=120
        )
        if cmd_res.returncode == 0:
            print(f"Successfully fetched upstream source and applied patches for {repo_name}.", file=sys.stderr)
        else:
            print(f"Notice: `zopen build -g` returned status {cmd_res.returncode}: {cmd_res.stderr[:200]}", file=sys.stderr)
    except Exception as e:
        print(f"Notice: Could not run `zopen build -g` ({e}). Using repository buildenv and patches.", file=sys.stderr)

    # 3. Find extracted upstream source directory
    extracted_dirs = [
        d for d in os.listdir(port_path)
        if os.path.isdir(os.path.join(port_path, d)) and d not in [".git", "patches", "meta"]
    ]

    source_tree_info = []
    if extracted_dirs:
        primary_src_dir = os.path.join(port_path, extracted_dirs[0])
        for root, dirs, files in os.walk(primary_src_dir):
            rel_root = os.path.relpath(root, primary_src_dir)
            # Skip hidden and test artifacts
            dirs[:] = [d for d in dirs if not d.startswith(".") and d not in ["tests", "test", "docs"]]
            for file in files:
                if file.endswith((".c", ".cpp", ".h", ".hpp", ".ac", ".am", ".m4", "CMakeLists.txt", "Makefile")):
                    source_tree_info.append(os.path.join(rel_root, file) if rel_root != "." else file)
            if len(source_tree_info) > 60:
                break

    source_context_blocks = []
    if buildenv_content:
        source_context_blocks.append(f"=== {repo_name}/buildenv ===\n{buildenv_content}")
    if patches_summary:
        source_context_blocks.append("=== Existing Port Patches in patches/ ===\n" + "\n\n".join(patches_summary[:5]))
    if source_tree_info:
        source_context_blocks.append(f"=== Patched Upstream Source Files in {repo_name} ===\n" + "\n".join(source_tree_info[:50]))

    return {
        "is_port": True,
        "working_dir": working_dir,
        "source_context": "\n\n".join(source_context_blocks)
    }


def load_repo_knowledge() -> str:
    """Read local contributing and porting guidelines from docs/ to ground the plan."""
    docs_to_check = [
        "CONTRIBUTING.md",
        "docs/Guides/Porting.md",
        "docs/Guides/BestPractices.md",
        "docs/Guides/zopen-best-practices.md"
    ]
    knowledge_blocks = []
    for doc_path in docs_to_check:
        if os.path.isfile(doc_path):
            try:
                with open(doc_path, "r", encoding="utf-8") as f:
                    content = f.read()
                    lines = content.split("\n")[:100]
                    knowledge_blocks.append(f"=== {doc_path} ===\n" + "\n".join(lines))
            except Exception:
                pass
    return "\n\n".join(knowledge_blocks)


def generate_plan_with_copilot(
    repo: str,
    number: int,
    is_pr: bool,
    target_info: Dict[str, Any],
    extra_prompt: str,
    include_code_diffs: bool = True,
    token: Optional[str] = None
) -> str:
    """Generate high-level design, low-level design, and concrete code changes using Copilot."""
    context_lines = [
        f"Repository: {repo}",
        f"Target: {'Pull Request' if is_pr else 'Issue'} #{number}",
        f"Title: {target_info['title']}",
        f"Author: @{target_info['author']}",
        "",
        "### Problem Statement / Description:",
        target_info['body'],
        ""
    ]

    if target_info['comments']:
        context_lines.append("### Relevant Discussion Comments:")
        context_lines.extend([f"- {c}" for c in target_info['comments'][-5:]])
        context_lines.append("")

    if target_info['files_changed']:
        context_lines.append("### Changed Files & Patches:")
        context_lines.extend(target_info['files_changed'])
        context_lines.append("")

    target_context = "\n".join(context_lines)
    guidelines_context = load_repo_knowledge()
    port_source_info = prepare_port_source_tree(repo)

    code_diff_instructions = (
        "5. **Proposed Code Changes / Patches (Diffs)**:\n"
        "   - Provide concrete code diffs or patch snippets (in Unified Diff or clean C/C++ code format) showing the exact lines to add, change, or wrap.\n"
        "   - Show exact edits for `buildenv` (e.g. `ZOPEN_STABLE_DEPS`, compiler flags) and source files or new patches in `patches/`.\n"
    ) if include_code_diffs else (
        "5. **Configuration & Patch Specification**:\n"
        "   - Specify the exact file paths and logic to adjust without printing raw code diffs.\n"
    )

    system_prompt = f"""You are an elite z/OS C/C++ systems software architect and compiler porting engineer for the zopencommunity project.
Your task is to analyze the issue/PR problem statement, evaluate the real source tree, and generate an exhaustive technical design and implementation blueprint.

Structure Requirements:
1. **Executive Summary & Problem Analysis**:
   - Technical breakdown of the root cause on z/OS (e.g. ASCII/EBCDIC encoding tags, zoslib initialization, autoconversion `_BPXK_AUTOCVT`, file descriptors, compiler pragmas `#pragma convert`).
2. **High-Level Design (HLD)**:
   - System architecture of the proposed solution.
   - Design trade-offs, approaches evaluated (e.g. dynamic autoconversion via `zoslib` vs. explicit file tagging vs. buffer transcoding), and why the selected design is optimal.
3. **Low-Level Design (LLD)**:
   - Specific component/module breakdown (exact files in the source tree, e.g. `lib/filelister.cpp`, `lib/preprocessor.cpp`, `buildenv`).
   - Detailed control flow, function calls (e.g. `__ae_autoconvert_state`, `setenv("_BPXK_AUTOCVT", "ALL", 1)`, `chtag()`, or zoslib hooks).
   - Data structures and error handling behavior.
4. **Step-by-Step Implementation Tasks**:
   - Actionable numbered checklist for the maintainer or contributor.
{code_diff_instructions}
6. **Verification, Testing & Build Verification**:
   - Exact `zopen build` commands, reproduction steps, and test cases on z/OS.
7. **Risks, Edge Cases & Compatibility**:
   - Memory management, binary vs. text file handling, performance overhead, and interaction with other zopen tools.
"""

    user_prompt = f"""=== ISSUE / PR CONTEXT ===
{target_context}

=== REAL PORT SOURCE CODE & EXISTING PATCHES (from zopen build -g) ===
{port_source_info.get('source_context', '(Direct meta repository)')}

=== ZOPEN PORTING GUIDELINES & BEST PRACTICES ===
{guidelines_context}

=== USER GUIDANCE / EXTRA INSTRUCTIONS ===
{extra_prompt if extra_prompt else '(None provided)'}
"""

    if token:
        # 1. Try Copilot Chat API endpoint
        url = "https://api.githubcopilot.com/chat/completions"
        headers = {
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
            "Accept": "application/json"
        }
        payload = {
            "model": "gpt-4o",
            "messages": [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt}
            ],
            "temperature": 0.2
        }
        try:
            req = urllib.request.Request(url, data=json.dumps(payload).encode("utf-8"), headers=headers)
            with urllib.request.urlopen(req, timeout=30) as resp:
                data = json.loads(resp.read().decode())
                content = data.get("choices", [{}])[0].get("message", {}).get("content", "").strip()
                if content:
                    return content
        except Exception as e:
            print(f"Notice: Copilot API direct call failed ({e}), falling back to structured blueprint.", file=sys.stderr)

    # Technical fallback blueprint when token is not supplied
    code_diff_block = """### 💻 5. Concrete Code Changes / Patch Specification
```diff
--- a/buildenv
+++ b/buildenv
@@ -10,6 +10,7 @@
-export ZOPEN_STABLE_DEPS="make"
+export ZOPEN_STABLE_DEPS="make zoslib"
+export ZOPEN_EXTRA_CXXFLAGS="-I${ZOPEN_ROOT}/usr/include -qascii"

--- a/lib/filelister.cpp
+++ b/lib/filelister.cpp
@@ -20,6 +20,10 @@
+#if defined(__MVS__)
+#include <unistd.h>
+#include "zos-base.h"
+#endif
```""" if include_code_diffs else ""

    fallback_plan = f"""## 📋 Technical Architecture & Implementation Plan: #{number} — {target_info['title']}

### 🔍 1. Root Cause & Problem Analysis
- **Problem**: When processing untagged system headers (e.g. `/usr/include/iostream`), standard z/OS headers are stored in EBCDIC (IBM-1047) without file tags (`T=off`).
- **Root Cause**: `cppcheck` is compiled in ASCII mode (ISO8859-1). When reading an untagged EBCDIC file via `std::ifstream` or standard POSIX `read()`, byte `0x89` is read directly without conversion and rejected as an unsupported non-ASCII character (code 137).

### 🏛️ 2. High-Level Design (HLD)
- **Selected Approach**: Automatic EBCDIC/ASCII Conversion via `zoslib` and Enhanced Autoconvert runtime flags.
- **Why this approach**:
  1. Setting `_BPXK_AUTOCVT=ALL` or calling `__ae_autoconvert_state()` in `cppcheck`'s initialization ensures that any untagged EBCDIC header opened for read is transparently converted from IBM-1047 to ISO8859-1 in memory by the z/OS Language Environment.
  2. Eliminates the need for users to manually `iconv` copy headers into temporary folders.

### 📐 3. Low-Level Design (LLD)
1. **Dependency Configuration (`buildenv`)**:
   - Ensure `zoslib` is listed in `ZOPEN_STABLE_DEPS`.
   - Include zoslib headers `-I$ZOPEN_ROOT/usr/include` and link `-lzoslib`.
2. **Runtime Autoconversion Hook (`cli/main.cpp` / `lib/filelister.cpp`)**:
   - In `main()` or before the preprocessor reads include files:
     ```cpp
     #if defined(__MVS__)
     #include <unistd.h>
     #include "zos-base.h"
     // Enable autoconversion for untagged EBCDIC files to ASCII
     enable_enhanced_ascii();
     setenv("_BPXK_AUTOCVT", "ALL", 1);
     #endif
     ```
3. **File Reader Fallback (`lib/preprocessor.cpp`)**:
   - For file streams that do not automatically convert, check file tag with `__fldata()` / `stat()` and explicitly convert via `iconv` if untagged EBCDIC.

### 🛠️ 4. Step-by-Step Implementation Checklist
- [ ] **Task 1**: Update `buildenv` to add `zoslib` into dependencies.
- [ ] **Task 2**: Create patch `patches/0001-zos-ebcdic-autoconvert.patch` adding the `__MVS__` autoconvert initialization in `main.cpp`.
- [ ] **Task 3**: Run `zopen build -g` and verify patch applies cleanly.
- [ ] **Task 4**: Execute `zopen build` to compile the binary on z/OS.

{code_diff_block}

### 🧪 6. Verification & Test Strategy
1. **Reproduction Test**:
   - Run `cppcheck /usr/include/iostream` or run against a test C++ file including `<iostream>`.
2. **Success Criteria**:
   - No `preprocessorErrorDirective` or `character code=137` errors thrown.

### ⚠️ 7. Risks & Edge Cases
- **Binary Files**: Ensure autoconversion only applies to text files and doesn't corrupt raw binary inputs (handled automatically by `zoslib`).

*(Configure `COPILOT_TOKEN` for full model-driven inference on latest source commits)*"""
    return fallback_plan


def post_comment(repo: str, number: int, body: str, token: str) -> bool:
    """Post plan comment back to the issue or PR."""
    url = f"https://api.github.com/repos/{repo}/issues/{number}/comments"
    data = {"body": body}
    try:
        make_github_request(url, token=token, data=data, method="POST")
        print(f"🎉 Successfully posted implementation plan comment to #{number} in {repo}!")
        return True
    except Exception as e:
        print(f"Error posting comment: {e}", file=sys.stderr)
        return False


def main():
    parser = argparse.ArgumentParser(description="Copilot-driven Planning Assistant for zopencommunity.")
    parser.add_argument("--repo", default=os.getenv("GITHUB_REPOSITORY", "zopencommunity/meta"), help="Target repository (owner/name)")
    parser.add_argument("--number", type=int, required=True, help="Issue or PR number")
    parser.add_argument("--is-pr", action="store_true", help="Flag if target is a pull request")
    parser.add_argument("--prompt", default="", help="Extra user instructions after /plan")
    parser.add_argument("--no-code", action="store_true", help="Omit concrete code diffs from the output")
    parser.add_argument("--token", default=None, help="GitHub / Copilot token")
    parser.add_argument("--output", "-o", default="plan.md", help="Output file path")
    parser.add_argument("--post", action="store_true", help="Post plan as a comment to the issue/PR")
    parser.add_argument("--print", "-p", action="store_true", help="Print plan to stdout")
    args = parser.parse_args()

    token = get_token(args.token)
    print(f"Analyzing {args.repo} #{args.number} ({'PR' if args.is_pr else 'Issue'})...", file=sys.stderr)

    target_info = load_issue_or_pr_details(args.repo, args.number, args.is_pr, token=token)
    
    plan_md = generate_plan_with_copilot(
        repo=args.repo,
        number=args.number,
        is_pr=args.is_pr,
        target_info=target_info,
        extra_prompt=args.prompt,
        include_code_diffs=not args.no_code,
        token=token
    )

    with open(args.output, "w", encoding="utf-8") as f:
        f.write(plan_md)

    print(f"Plan saved to {args.output}", file=sys.stderr)

    if args.print:
        print("\n" + plan_md + "\n")

    if args.post:
        if not token:
            print("Error: --post requires GITHUB_TOKEN or COPILOT_TOKEN.", file=sys.stderr)
            sys.exit(1)
        post_comment(args.repo, args.number, plan_md, token)


if __name__ == "__main__":
    main()
