#!/usr/bin/env python3
"""Report on which candidate Python packages install on z/OS, and what blocks them.

Two questions this answers, neither of which is reliably answerable from PyPI
metadata alone:

  1. Does `pip install X` actually work on z/OS today?  A package can look pure
     Python and still fail, because a transitive dependency ships only an sdist
     with a C or Rust extension.  Only trying it on-platform settles this.

  2. When it fails, what is the thing to port?  Ranking candidates by request
     count picks the wrong work: several requested packages usually block on
     one shared dependency, and porting that one unblocks all of them.

Usage:

    # on a z/OS system with the zopen Python build environment sourced
    tools/python_candidate_report.py --probe results.txt --out report.md

`results.txt` is produced by probing each package on z/OS, one line per
package:

    <name>|<OK|IMPORT_FAIL|FAIL|PROBE_ERROR>|<sdists pip tried to build>|<trigger>

Run with --blockers-only to skip the probe and just print the dependency
analysis, which needs no z/OS access.
"""

import argparse
import collections
import json
import pathlib
import re
import sys
import urllib.request

PYPI = "https://pypi.org/pypi/{}/json"
INDEX = "https://repo.zopen.community/pypi/wheels/simple/"

_cache = {}


def meta(pkg):
    key = pkg.lower()
    if key not in _cache:
        try:
            with urllib.request.urlopen(PYPI.format(pkg), timeout=20) as r:
                _cache[key] = json.load(r)
        except Exception:
            _cache[key] = None
    return _cache[key]


def ships_pure_wheel(info):
    """A py3-none-any wheel installs anywhere; anything else may need building."""
    wheels = [u["filename"] for u in info["urls"] if u["filename"].endswith(".whl")]
    if not wheels:
        return False
    return any(w.endswith(("-py3-none-any.whl", "-py2.py3-none-any.whl")) for w in wheels)


def runtime_deps(info):
    out = []
    for req in info["info"].get("requires_dist") or []:
        if "extra ==" in req:          # optional extras are not part of a base install
            continue
        name = re.split(r"[<>=!~\[\( ;]", req.strip())[0]
        if name:
            out.append(name)
    return out


def native_closure(pkg):
    """Every distribution in pkg's runtime closure that does not ship a pure wheel."""
    seen, queue, impure = set(), [pkg], set()
    while queue:
        current = queue.pop(0)
        if current.lower() in seen:
            continue
        seen.add(current.lower())
        info = meta(current)
        if not info:
            continue
        if not ships_pure_wheel(info):
            # PEP 503 normalisation, so pydantic_core and pydantic-core are one
            # name and can be matched against what the index publishes.
            impure.add(re.sub(r"[-_.]+", "-", info["info"]["name"]).lower())
        queue.extend(runtime_deps(info))
    return impure


def ported_packages():
    """Names zopen already publishes to the wheel index."""
    try:
        with urllib.request.urlopen(INDEX, timeout=30) as r:
            html = r.read().decode()
    except Exception:
        return set()
    return {re.sub(r"[-_.]+", "-", n).lower()
            for n in re.findall(r'href="([A-Za-z0-9._-]+)/"', html)}


def read_probe(path):
    results = {}
    for line in pathlib.Path(path).read_text().splitlines():
        parts = line.split("|")
        if len(parts) >= 2:
            name = re.sub(r"[-_.]+", "-", parts[0]).lower()
            results[name] = {
                "status": parts[1],
                "sdists": parts[2] if len(parts) > 2 else "",
                "trigger": parts[3] if len(parts) > 3 else "",
            }
    return results


CANDIDATES = """pyzfile pycryptodome pyarrow pyodbc psycopg2 ninja fastmcp pydantic
paramiko pynacl requests-pkcs12 pyjwt django versioneer poetry psutil snowflake msal
confluent-kafka fastapi python-pptx uv fpdf2 python-pkcs11 pymqi pytest buildbot qiskit
pamela greenlet rst2pdf xxhash pygithub cookiecutter PyWavelets seaborn duckdb""".split()

STATUS_LABEL = {
    "OK": "works",
    "IMPORT_FAIL": "installs, import fails",
    "FAIL": "fails",
    "PROBE_ERROR": "not probed",
}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--probe", help="probe results file from a z/OS run")
    ap.add_argument("--out", default="-", help="markdown output path, or - for stdout")
    ap.add_argument("--blockers-only", action="store_true")
    args = ap.parse_args()

    probe = read_probe(args.probe) if args.probe else {}
    ported = ported_packages()

    closures, blocks = {}, collections.Counter()
    blocked_by = collections.defaultdict(set)
    for cand in CANDIDATES:
        impure = native_closure(cand)
        closures[cand] = impure
        for dep in impure:
            if dep != cand.lower():
                blocks[dep] += 1
                blocked_by[dep].add(cand)

    lines = []
    w = lines.append
    w("# Python candidate packages on z/OS")
    w("")
    w("Generated by `tools/python_candidate_report.py`. The status column is a real")
    w("`pip install` on a z/OS system using the zopen wheel index and the published")
    w("constraints file — not an inference from PyPI metadata, which cannot tell you")
    w("whether a transitive sdist will build.")
    w("")

    w("## Shared blockers")
    w("")
    w("Ranked by how many candidate packages each one blocks. Porting a blocker")
    w("unblocks every package in its row, so this ordering matters more than the")
    w("number of times a package was requested.")
    w("")
    w("| blocker | blocks | already ported | candidates waiting on it |")
    w("|---|---:|---|---|")
    for dep, count in blocks.most_common():
        if count < 2:
            continue
        mark = "yes" if dep in ported else "no"
        w(f"| `{dep}` | {count} | {mark} | {', '.join(sorted(blocked_by[dep]))} |")
    w("")

    if args.blockers_only:
        emit(lines, args.out)
        return

    w("## Candidates")
    w("")
    w("| package | status | ported by zopen | native closure still missing |")
    w("|---|---|---|---|")
    for cand in sorted(CANDIDATES, key=str.lower):
        key = re.sub(r"[-_.]+", "-", cand).lower()
        p = probe.get(key)
        status = STATUS_LABEL.get(p["status"], p["status"]) if p else "not probed"
        is_ported = "**yes**" if key in ported else ""
        missing = sorted(d for d in closures[cand] if d not in ported and d != key)
        w(f"| `{cand}` | {status} | {is_ported} | {', '.join(f'`{m}`' for m in missing) or '—'} |")
    w("")

    working = [c for c in CANDIDATES
               if probe.get(re.sub(r"[-_.]+", "-", c).lower(), {}).get("status") == "OK"]
    if working:
        w("## Installs cleanly today")
        w("")
        w(", ".join(f"`{c}`" for c in sorted(working, key=str.lower)))
        w("")

    emit(lines, args.out)


def emit(lines, out):
    text = "\n".join(lines) + "\n"
    if out == "-":
        sys.stdout.write(text)
    else:
        pathlib.Path(out).write_text(text)
        print(f"wrote {out}", file=sys.stderr)


if __name__ == "__main__":
    main()
