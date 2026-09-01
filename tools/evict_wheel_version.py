#!/usr/bin/env python3
"""Remove one published version of one package from the wheel index.

This deletes artifacts users may already depend on, so it defaults to showing
what it would do and changes nothing without --apply.

The case it exists for: a package whose version is chosen exactly by a parent.
pydantic pins pydantic-core, and the generated constraints file pins the newest
of everything in the index, so publishing a pydantic-core newer than the one
today's pydantic asks for makes every constrained install unsatisfiable:

    ERROR: Could not find a version that satisfies pydantic-core==2.46.4
           (from versions: 0.0.1, 2.41.5, 2.48.0)

The durable fix is not to pin such packages at all, which is what the publish
job now does. This is for clearing a version that was published before that,
and is still being picked up.

Prefer leaving artifacts alone. pip resolves to the highest build tag and
ignores older ones, so an unused version is usually inert -- the exception is a
version that actively breaks resolution, as above.

Usage:

    export PULP_USER=... PULP_PASSWORD=...
    tools/evict_wheel_version.py pydantic-core 2.48.0            # show only
    tools/evict_wheel_version.py pydantic-core 2.48.0 --apply    # do it

Removing content from a Pulp repository creates a new repository version; the
files remain in storage and the same version can be published again later.
"""

import argparse
import base64
import json
import os
import re
import sys
import urllib.error
import urllib.request
from urllib.parse import urljoin, urlsplit

DEFAULT_API = "https://repo.zopen.community/pulp/api/v3"
DEFAULT_REPO = "wheels"


def make_caller(api, user, password):
    origin = "{0.scheme}://{0.netloc}".format(urlsplit(api))
    auth = base64.b64encode(f"{user}:{password}".encode()).decode()

    def call(url, method="GET", body=None):
        if url.startswith("/"):
            url = urljoin(origin, url)
        data = json.dumps(body).encode() if body is not None else None
        req = urllib.request.Request(url, method=method, data=data)
        req.add_header("Authorization", f"Basic {auth}")
        if data:
            req.add_header("Content-Type", "application/json")
        try:
            with urllib.request.urlopen(req, timeout=120) as r:
                raw = r.read()
                return json.loads(raw) if raw else {}
        except urllib.error.HTTPError as e:
            sys.exit(f"{method} {url} -> HTTP {e.code}: {e.read().decode()[:400]}")

    return call, origin


def normalise(name):
    # PEP 503: pydantic_core, pydantic.core and pydantic-core are one project.
    return re.sub(r"[-_.]+", "-", name).lower()


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("package")
    ap.add_argument("version")
    ap.add_argument("--apply", action="store_true",
                    help="actually remove; without it nothing is changed")
    ap.add_argument("--api", default=os.environ.get("PULP_API", DEFAULT_API))
    ap.add_argument("--repo", default=DEFAULT_REPO,
                    help="Pulp repository name (default: %(default)s)")
    args = ap.parse_args()

    user = os.environ.get("PULP_USER")
    password = os.environ.get("PULP_PASSWORD")
    if not user or not password:
        sys.exit("PULP_USER and PULP_PASSWORD must be set")

    call, origin = make_caller(args.api, user, password)

    repos = call(f"{args.api}/repositories/python/python/?name={args.repo}")
    if not repos.get("results"):
        sys.exit(f"no Pulp repository named {args.repo!r}")
    repo = repos["results"][0]
    version_href = repo.get("latest_version_href")
    if not version_href:
        sys.exit(f"repository {args.repo!r} has no versions")

    wanted_name = normalise(args.package)
    victims, kept = [], []
    url = (f"{args.api}/content/python/packages/"
           f"?repository_version={version_href}&limit=500")
    while url:
        page = call(url)
        for unit in page.get("results", []):
            if normalise(unit.get("name", "")) != wanted_name:
                continue
            if unit.get("version") == args.version:
                victims.append(unit)
            else:
                kept.append(unit)
        url = page.get("next")

    if not victims:
        print(f"{args.package} {args.version} is not in {args.repo}; nothing to do")
        return 0

    print(f"repository : {args.repo}")
    print(f"package    : {args.package}")
    print(f"to remove  : {len(victims)}")
    for unit in sorted(victims, key=lambda u: u.get("filename", "")):
        print(f"    {unit.get('filename')}")

    # Show what survives. Removing every copy of a package leaves anything that
    # depends on it unresolvable, which is worse than the problem being fixed.
    remaining = sorted({u.get("version") for u in kept})
    print(f"remaining  : {', '.join(remaining) if remaining else 'NOTHING'}")
    if not remaining:
        sys.exit("refusing: this would remove every version of the package")

    if not args.apply:
        print("\ndry run -- nothing changed. Re-run with --apply to remove.")
        return 0

    call(urljoin(origin, repo["pulp_href"]) + "modify/", method="POST",
         body={"remove_content_units": [u["pulp_href"] for u in victims]})
    print(f"\nremoved {len(victims)} wheel(s).")
    print("The constraints file is regenerated by the Python publish job, so it")
    print("will keep naming the old version until that job next runs.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
