---
description: |
  Analyzes open CodeQL alerts for a zopen port repository, performs deep code
  triage to identify False Positives vs Real Vulnerabilities, and generates
  concrete code fixes/patches. Can be triggered via manual workflow_dispatch
  or slash command (/codeql or /analyze-codeql).

on:
  workflow_dispatch:
    inputs:
      repo:
        description: 'Repository to analyze (e.g., curlport or zopencommunity/curlport)'
        required: true
        type: string
      alert_number:
        description: 'Specific alert number to triage (optional, default: top open alerts)'
        required: false
        type: string
        default: ''
      target_issue:
        description: 'Issue/PR number to post the triage report to (optional)'
        required: false
        type: string
        default: ''
  slash_command:
    name: codeql
    events: [issues, issue_comment]
    strategy: centralized
  roles: all
  reaction: eyes

concurrency:
  job-discriminator: ${{ github.event.issue.number || github.event.inputs.repo || github.run_id }}

user-rate-limit:
  max-runs-per-window: 5
  window: 60

permissions:
  contents: read
  issues: write
  security-events: read

network: defaults

engine:
  id: copilot
  model: gpt-4.1

tools:
  github: false
  bash: ["cat"]

safe-outputs:
  add-comment:
    max: 1
  report-failure-as-issue: false
  threat-detection:
    model: gpt-4.1
    report-as-issue: false

steps:
  - name: Gather CodeQL alerts and code context
    env:
      REPO: ${{ github.event.inputs.repo }}
      ALERT_NUMBER: ${{ github.event.inputs.alert_number }}
      TARGET_ISSUE: ${{ github.event.inputs.target_issue }}
      ISSUE_NUMBER: ${{ github.event.issue.number }}
      AW_CONTEXT: ${{ github.event.inputs.aw_context }}
      GITHUB_TOKEN: ${{ github.token }}
    run: |
      mkdir -p /tmp/gh-aw/codeql
      
      # Handle repo fallback when triggered via issue or aw_context
      TARGET_REPO="${REPO}"
      if [ -z "$TARGET_REPO" ] && [ -n "$AW_CONTEXT" ]; then
        TARGET_REPO=$(python3 -c "import json, sys; ctx=json.loads(sys.argv[1]); import re; m=re.search(r'/(?:analyze-codeql|codeql)\s+([a-zA-Z0-9_\-\.\/]+)', ctx.get('comment_body','')); print(m.group(1) if m else '')" "$AW_CONTEXT" 2>/dev/null || true)
      fi
      
      # Fallback to issue title extraction if on a [New Port] issue
      if [ -z "$TARGET_REPO" ] && [ -n "$ISSUE_NUMBER" ]; then
        TITLE="${{ github.event.issue.title }}"
        if [ -n "$TITLE" ]; then
          TARGET_REPO=$(printf '%s' "$TITLE" | sed -n 's/^\[New \(Python \)\{0,1\}Port\]:[[:space:]]*//p' | tr '[:upper:] ' '[:lower:]-' | tr -cd 'a-z0-9._+-' | sed 's/port$//')
          [ -n "$TARGET_REPO" ] && TARGET_REPO="${TARGET_REPO}port"
        fi
      fi
      
      # If still empty, default to current repo
      [ -z "$TARGET_REPO" ] && TARGET_REPO="${{ github.repository }}"

      echo "Target repository for CodeQL triage: ${TARGET_REPO}"
      
      python3 tools/codeql_alert_triage.py \
        --repo "${TARGET_REPO}" \
        ${ALERT_NUMBER:+--alert-number "$ALERT_NUMBER"} \
        ${TARGET_ISSUE:+--issue "$TARGET_ISSUE"} \
        ${ISSUE_NUMBER:+--issue "$ISSUE_NUMBER"} \
        ${AW_CONTEXT:+--aw-context "$AW_CONTEXT"} \
        --output /tmp/gh-aw/codeql/triage_facts.md

timeout-minutes: 10
---

# CodeQL Security Alert Triage & Remediation Agent

You are a senior security engineer and C/C++/Python systems programmer for the **zopen community** (porting open source tools to z/OS UNIX).

Your task is to analyze the CodeQL code scanning alerts gathered in `/tmp/gh-aw/codeql/triage_facts.md`.

For each alert present in `/tmp/gh-aw/codeql/triage_facts.md`:
1. **Analyze the Alert & Code Context**:
   - Inspect the highlighted lines (`👉 line`) and surrounding code.
   - Determine whether the finding is a **False Positive** or a **True Positive (Real Vulnerability)**.
   - Take into account z/OS specifics (EBCDIC/ASCII character encodings, Enhanced ASCII runtime, 64-bit addressing, `#ifdef __MVS__` / `__TOS_390__`).

2. **Categorize and Explain**:
   - **Verdict**: State clearly `[FALSE POSITIVE]` or `[TRUE POSITIVE - ACTION REQUIRED]`.
   - **Technical Rationale**: Explain *why* in 2-3 sentences. (e.g., "The buffer size is validated by `validate_len()` at line 42 before this function is invoked, making an overflow impossible" OR "User-controlled input `len` is passed to `memcpy` without an upper bound check").

3. **Provide Concrete Fixes (for True Positives)**:
   - Provide a copy-pasteable **unified diff / patch** or clean C/C++ code snippet showing how to fix the issue.
   - Ensure the fix is safe, minimal, and follows modern secure coding best practices.

## Guidelines
- Start with a brief summary table of all triaged alerts (Alert #, Rule ID, Severity, Verdict).
- Group your detailed findings by Alert Number.
- Be precise, technical, and constructive.
- If no open alerts are found, post a friendly confirmation note that the repository has a clean bill of health.

Begin by reading `/tmp/gh-aw/codeql/triage_facts.md` using `cat` and post your grounded triage report.
