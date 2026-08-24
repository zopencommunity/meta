#!/usr/bin/env python3
"""Build the static Python package catalogue used by the documentation site.

The zopen release cache supplies release and test metadata.  The PEP 503
simple index supplies the wheel names that prove which Python interpreters are
actually covered.  Keeping the merged result in ``docs/api`` lets GitHub Pages
render the catalogue without depending on a live application API.
"""

from __future__ import annotations

import argparse
import datetime as dt
from html.parser import HTMLParser
import json
from pathlib import Path
import re
import urllib.parse
import urllib.request


DEFAULT_INDEX = "https://repo.zopen.community/pypi/wheels/simple/"
SUPPORTED_PYTHON = ("3.12", "3.13", "3.14")
RELEASE_ALIASES = {
    "xxhash": "python-xxhash",
    "zope-interface": "zopeinterface",
}
HIDDEN_PACKAGES = {"zopen-pulp-upload-test"}
INFRASTRUCTURE_DEPENDENCIES = {"check_python", "meta"}


def normalize_name(value: str) -> str:
    """Return a PEP 503-compatible normalized project name."""
    return re.sub(r"[-_.]+", "-", value.strip()).lower()


class LinkParser(HTMLParser):
    """Collect anchor hrefs and labels from a simple-index document."""

    def __init__(self) -> None:
        super().__init__()
        self.links: list[dict[str, str]] = []
        self._href = ""
        self._label: list[str] = []

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        if tag.lower() != "a":
            return
        self._href = dict(attrs).get("href") or ""
        self._label = []

    def handle_data(self, data: str) -> None:
        if self._href:
            self._label.append(data)

    def handle_endtag(self, tag: str) -> None:
        if tag.lower() == "a" and self._href:
            self.links.append({"href": self._href, "label": "".join(self._label).strip()})
            self._href = ""
            self._label = []


def parse_links(document: str) -> list[dict[str, str]]:
    parser = LinkParser()
    parser.feed(document)
    return parser.links


def fetch_text(url: str) -> str:
    request = urllib.request.Request(url, headers={"User-Agent": "zopen-python-catalog/1.0"})
    with urllib.request.urlopen(request, timeout=30) as response:
        return response.read().decode("utf-8")


def python_versions_for_wheel(filename: str) -> set[str]:
    """Return supported catalogue interpreters from a wheel filename."""
    if not filename.lower().endswith(".whl"):
        return set()
    parts = filename[:-4].rsplit("-", 3)
    if len(parts) != 4:
        return set()
    python_tag = parts[1].lower()
    if re.search(r"(?:^|\.)py3(?:$|\.)", python_tag):
        return set(SUPPORTED_PYTHON)
    versions = set()
    for major, minor in re.findall(r"cp(3)(\d{2})", python_tag):
        version = f"{major}.{int(minor)}"
        if version in SUPPORTED_PYTHON:
            versions.add(version)
    return versions


def version_from_wheel(filename: str) -> str:
    """Extract the distribution version from a normalized wheel filename."""
    if not filename.lower().endswith(".whl"):
        return ""
    parts = filename[:-4].rsplit("-", 3)
    if len(parts) != 4 or "-" not in parts[0]:
        return ""
    return parts[0].split("-", 1)[1].split("-", 1)[0]


def version_key(value: str) -> tuple[tuple[int, object], ...]:
    """Provide a stable natural ordering without requiring packaging."""
    return tuple(
        (0, int(part)) if part.isdigit() else (1, part.lower())
        for part in re.findall(r"\d+|[A-Za-z]+", value)
    )


def integer_or_none(value: object) -> int | None:
    try:
        parsed = int(str(value))
    except (TypeError, ValueError):
        return None
    return parsed if parsed >= 0 else None


def release_details(
    package_name: str,
    releases: dict[str, list[dict[str, object]]],
    descriptions: dict[str, str],
) -> dict[str, object]:
    release_key = RELEASE_ALIASES.get(package_name, package_name)
    entries = releases.get(release_key) or []
    latest = entries[0] if entries else {}
    assets = latest.get("assets") if isinstance(latest, dict) else []
    asset = assets[0] if isinstance(assets, list) and assets else {}
    if not isinstance(asset, dict):
        asset = {}
    passed = integer_or_none(asset.get("passed_tests"))
    total = integer_or_none(asset.get("total_tests"))
    verification_rate = round(passed / total * 100, 1) if passed is not None and total else None
    dependencies = [
        dependency
        for dependency in str(asset.get("runtime_dependencies") or "").split()
        if dependency not in INFRASTRUCTURE_DEPENDENCIES
    ]
    tag = str(latest.get("tag_name") or "") if isinstance(latest, dict) else ""
    return {
        "releaseKey": release_key,
        "version": str(asset.get("version") or ""),
        "description": str(descriptions.get(release_key) or descriptions.get(package_name) or ""),
        "categories": str(asset.get("categories") or "").split(),
        "runtimeDependencies": dependencies,
        "passedTests": passed,
        "totalTests": total,
        "verificationRate": verification_rate,
        "publishedAt": str(latest.get("date") or "") if isinstance(latest, dict) else "",
        "portRepositoryUrl": f"https://github.com/zopencommunity/{release_key}port",
        "releaseUrl": (
            f"https://github.com/zopencommunity/{release_key}port/releases/tag/{urllib.parse.quote(tag)}"
            if tag else ""
        ),
    }


def build_catalog(
    root_document: str,
    package_documents: dict[str, str],
    release_payload: dict[str, object],
    description_payload: dict[str, object],
    index_url: str = DEFAULT_INDEX,
) -> dict[str, object]:
    releases = release_payload.get("release_data") or {}
    descriptions = description_payload.get("descriptions") or {}
    if not isinstance(releases, dict) or not isinstance(descriptions, dict):
        raise ValueError("Release and description inputs have an unexpected shape.")

    packages = []
    total_wheels = 0
    for link in parse_links(root_document):
        display_name = link["label"].strip()
        package_name = normalize_name(display_name)
        if not package_name or package_name in HIDDEN_PACKAGES:
            continue
        package_document = package_documents.get(package_name, "")
        filenames = sorted({
            urllib.parse.unquote(urllib.parse.urlparse(item["href"]).path.rsplit("/", 1)[-1])
            for item in parse_links(package_document)
            if urllib.parse.urlparse(item["href"]).path.lower().endswith(".whl")
        })
        if not filenames:
            continue
        total_wheels += len(filenames)
        python_versions = sorted({
            version
            for filename in filenames
            for version in python_versions_for_wheel(filename)
        }, key=SUPPORTED_PYTHON.index)
        details = release_details(package_name, releases, descriptions)
        wheel_versions = {version_from_wheel(filename) for filename in filenames}
        wheel_versions.discard("")
        if not details["version"] and wheel_versions:
            details["version"] = max(wheel_versions, key=version_key)
        packages.append({
            "name": package_name,
            "displayName": display_name,
            "pythonVersions": python_versions,
            "wheelCount": len(filenames),
            "indexUrl": urllib.parse.urljoin(index_url, f"{package_name}/"),
            **details,
        })

    packages.sort(key=lambda package: str(package["name"]).casefold())
    generated_at = dt.datetime.now(dt.timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")
    return {
        "generatedAt": generated_at,
        "wheelIndexUrl": index_url,
        "supportedPythonVersions": list(SUPPORTED_PYTHON),
        "packageCount": len(packages),
        "wheelCount": total_wheels,
        "packages": packages,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--release-data", default="docs/api/zopen_releases_latest.json")
    parser.add_argument("--descriptions", default="docs/api/zopen_releases_descriptions.json")
    parser.add_argument("--output", default="docs/api/python_packages.json")
    parser.add_argument("--index-url", default=DEFAULT_INDEX)
    args = parser.parse_args()

    release_payload = json.loads(Path(args.release_data).read_text(encoding="utf-8"))
    description_payload = json.loads(Path(args.descriptions).read_text(encoding="utf-8"))
    root_document = fetch_text(args.index_url)
    package_documents = {}
    for link in parse_links(root_document):
        package_name = normalize_name(link["label"])
        if package_name and package_name not in HIDDEN_PACKAGES:
            package_documents[package_name] = fetch_text(urllib.parse.urljoin(args.index_url, link["href"]))

    catalog = build_catalog(root_document, package_documents, release_payload, description_payload, args.index_url)
    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(catalog, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"Wrote {catalog['packageCount']} packages and {catalog['wheelCount']} wheels to {output_path}")


if __name__ == "__main__":
    main()
