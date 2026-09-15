#!/usr/bin/env python3
"""Build the static RPM package catalogue used by the documentation site.

The zopen release cache supplies release and test metadata. The Pulp API
supplies the RPM package information. Keeping the merged result in ``docs/api``
lets GitHub Pages render the catalogue without depending on a live application API.
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
from pathlib import Path
import urllib.request
import xml.etree.ElementTree as ET
from functools import cmp_to_key


DEFAULT_REPO_URL = "http://163.74.83.190:8080/pulp/content/zopen/"
DEFAULT_METADATA_URL = "http://163.74.83.190:8080/pulp/content/zopen/repodata/repomd.xml"
HIDDEN_PACKAGES = {"zopen-pulp-upload-test"}
INFRASTRUCTURE_DEPENDENCIES = {"check_python", "meta"}


def fetch_text(url: str) -> str:
    """Fetch text content from a URL."""
    request = urllib.request.Request(url, headers={"User-Agent": "zopen-rpm-catalog/1.0"})
    with urllib.request.urlopen(request, timeout=60) as response:
        return response.read().decode("utf-8")


def fetch_binary(url: str) -> bytes:
    """Fetch binary content from a URL."""
    request = urllib.request.Request(url, headers={"User-Agent": "zopen-rpm-catalog/1.0"})
    with urllib.request.urlopen(request, timeout=60) as response:
        return response.read()


def compare_evr(a: dict[str, object], b: dict[str, object]) -> int:
    """Compare two RPM packages by Epoch-Version-Release using RPM semantics.
    
    Returns: -1 if a < b, 0 if a == b, 1 if a > b
    """
    # Compare epochs (numeric)
    epoch_a = int(str(a.get("epoch", "0")))
    epoch_b = int(str(b.get("epoch", "0")))
    if epoch_a != epoch_b:
        return 1 if epoch_a > epoch_b else -1
    
    # Compare versions (RPM version comparison)
    ver_a = str(a.get("version", ""))
    ver_b = str(b.get("version", ""))
    ver_cmp = compare_rpm_versions(ver_a, ver_b)
    if ver_cmp != 0:
        return ver_cmp
    
    # Compare releases (RPM version comparison)
    rel_a = str(a.get("release", ""))
    rel_b = str(b.get("release", ""))
    return compare_rpm_versions(rel_a, rel_b)


def compare_rpm_versions(v1: str, v2: str) -> int:
    """Compare two version strings using RPM version comparison semantics.
    
    Returns: -1 if v1 < v2, 0 if v1 == v2, 1 if v1 > v2
    """
    if v1 == v2:
        return 0
    
    # Split into segments (alternating alpha/numeric)
    def split_version(v: str) -> list[tuple[bool, str]]:
        segments = []
        current = []
        is_digit = None
        
        for char in v:
            char_is_digit = char.isdigit()
            if is_digit is None:
                is_digit = char_is_digit
            elif is_digit != char_is_digit:
                if current:
                    segments.append((is_digit, ''.join(current)))
                current = []
                is_digit = char_is_digit
            current.append(char)
        
        if current:
            segments.append((is_digit, ''.join(current)))
        return segments
    
    segs1 = split_version(v1)
    segs2 = split_version(v2)
    
    # Compare segment by segment
    for i in range(max(len(segs1), len(segs2))):
        if i >= len(segs1):
            return -1  # v1 is shorter
        if i >= len(segs2):
            return 1   # v2 is shorter
        
        is_num1, val1 = segs1[i]
        is_num2, val2 = segs2[i]
        
        # If types differ, numeric > alpha
        if is_num1 and not is_num2:
            return 1
        if not is_num1 and is_num2:
            return -1
        
        # Both numeric: compare as integers
        if is_num1:
            num1 = int(val1)
            num2 = int(val2)
            if num1 != num2:
                return 1 if num1 > num2 else -1
        # Both alpha: compare lexicographically
        else:
            if val1 != val2:
                return 1 if val1 > val2 else -1
    
    return 0


def parse_repomd(repomd_xml: str, base_url: str) -> str | None:
    """Extract the primary metadata location from repomd.xml."""
    try:
        root = ET.fromstring(repomd_xml)
        # Handle namespace
        ns = {"repo": "http://linux.duke.edu/metadata/repo"}
        for data in root.findall("repo:data", ns):
            if data.get("type") == "primary":
                location = data.find("repo:location", ns)
                if location is not None:
                    href = location.get("href")
                    if href:
                        return f"{base_url.rstrip('/')}/{href.lstrip('/')}"
        # Try without namespace if namespaced search failed
        for data in root.findall("data"):
            if data.get("type") == "primary":
                location = data.find("location")
                if location is not None:
                    href = location.get("href")
                    if href:
                        return f"{base_url.rstrip('/')}/{href.lstrip('/')}"
    except Exception as e:
        print(f"Error parsing repomd.xml: {e}")
    return None


def parse_primary_xml(primary_xml: str) -> list[dict[str, object]]:
    """Parse primary.xml metadata to extract package information."""
    packages = []
    try:
        root = ET.fromstring(primary_xml)
        # Define namespaces
        ns = {
            "common": "http://linux.duke.edu/metadata/common",
            "rpm": "http://linux.duke.edu/metadata/rpm"
        }
        
        # Find all package elements
        package_elements = root.findall("{http://linux.duke.edu/metadata/common}package")
        
        for pkg in package_elements:
            try:
                name_elem = pkg.find("{http://linux.duke.edu/metadata/common}name")
                version_elem = pkg.find("{http://linux.duke.edu/metadata/common}version")
                arch_elem = pkg.find("{http://linux.duke.edu/metadata/common}arch")
                summary_elem = pkg.find("{http://linux.duke.edu/metadata/common}summary")
                description_elem = pkg.find("{http://linux.duke.edu/metadata/common}description")
                time_elem = pkg.find("{http://linux.duke.edu/metadata/common}time")
                
                if name_elem is None or version_elem is None:
                    continue
                
                name = name_elem.text or ""
                version = version_elem.get("ver", "")
                release = version_elem.get("rel", "")
                epoch = version_elem.get("epoch", "0")
                arch = arch_elem.text if arch_elem is not None else "s390x"
                summary = summary_elem.text if summary_elem is not None else ""
                description = description_elem.text if description_elem is not None else ""
                
                # Extract dependencies
                dependencies = []
                format_elem = pkg.find("{http://linux.duke.edu/metadata/common}format")
                if format_elem is not None:
                    requires_elem = format_elem.find("{http://linux.duke.edu/metadata/rpm}requires")
                    if requires_elem is not None:
                        for entry in requires_elem.findall("{http://linux.duke.edu/metadata/rpm}entry"):
                            dep_name = entry.get("name", "")
                            if dep_name and not dep_name.startswith("rpmlib(") and not dep_name.startswith("/"):
                                dependencies.append(dep_name)
                
                # Get time
                build_time = ""
                if time_elem is not None:
                    build_timestamp = time_elem.get("build")
                    if build_timestamp:
                        try:
                            build_time = dt.datetime.fromtimestamp(int(build_timestamp), dt.timezone.utc).isoformat().replace("+00:00", "Z")
                        except (ValueError, OSError):
                            pass
                
                packages.append({
                    "name": name,
                    "version": version,
                    "release": release,
                    "epoch": epoch,
                    "arch": arch,
                    "summary": summary,
                    "description": description,
                    "dependencies": dependencies,
                    "buildTime": build_time,
                })
            except Exception as e:
                print(f"Error parsing package: {e}")
                continue
    except Exception as e:
        print(f"Error parsing primary.xml: {e}")
    
    return packages


def integer_or_none(value: object) -> int | None:
    """Convert value to integer or None."""
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
    """Extract release details from zopen release data."""
    # Try with 'port' suffix first
    release_key = package_name
    entries = releases.get(release_key) or []
    
    # If not found, try without 'port' suffix
    if not entries and release_key.endswith("port"):
        release_key = release_key[:-4]
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
    
    categories = str(asset.get("categories") or "").split()
    
    tag = str(latest.get("tag_name") or "") if isinstance(latest, dict) else ""
    
    return {
        "releaseKey": release_key,
        "categories": categories,
        "runtimeDependencies": dependencies,
        "passedTests": passed,
        "totalTests": total,
        "verificationRate": verification_rate,
        "publishedAt": str(latest.get("date") or "") if isinstance(latest, dict) else "",
        "portRepositoryUrl": f"https://github.com/zopencommunity/{release_key}port",
        "releaseUrl": (
            f"https://github.com/zopencommunity/{release_key}port/releases/tag/{tag}"
            if tag else ""
        ),
    }


def build_catalog(
    rpm_packages: list[dict[str, object]],
    release_payload: dict[str, object],
    description_payload: dict[str, object],
    repo_url: str = DEFAULT_REPO_URL,
) -> dict[str, object]:
    """Build the RPM package catalog."""
    releases = release_payload.get("release_data") or {}
    descriptions = description_payload.get("descriptions") or {}
    if not isinstance(releases, dict) or not isinstance(descriptions, dict):
        raise ValueError("Release and description inputs have an unexpected shape.")
    
    # Group RPMs by package name (base name without version/release/arch)
    package_map: dict[str, list[dict[str, object]]] = {}
    for rpm in rpm_packages:
        name = rpm["name"]
        if name in HIDDEN_PACKAGES:
            continue
        if name not in package_map:
            package_map[name] = []
        package_map[name].append(rpm)
    
    # Build catalog entries
    packages = []
    for name, rpms in package_map.items():
        # Sort by EVR using proper RPM comparison (latest first)
        rpms.sort(key=cmp_to_key(compare_evr), reverse=True)
        latest = rpms[0]
        
        # Get only RPMs of the latest version
        latest_version_rpms = [
            r for r in rpms
            if r.get("version") == latest["version"] and r.get("release") == latest["release"]
        ]
        
        details = release_details(name, releases, descriptions)
        
        # Get unique architectures from latest version only
        architectures = sorted(set(r.get("arch", "s390x") for r in latest_version_rpms))
        
        packages.append({
            "name": name,
            "displayName": name,
            "version": latest["version"],
            "release": latest["release"],
            "epoch": latest["epoch"],
            "architectures": architectures,
            "summary": latest["summary"],
            "description": latest["description"] or descriptions.get(details["releaseKey"], ""),
            "rpmCount": len(latest_version_rpms),
            "rpmDependencies": latest["dependencies"],
            "rpmUrl": f"{repo_url.rstrip('/')}/Packages/{name[0]}/{name}-{latest['version']}-{latest['release']}.{latest['arch']}.rpm",
            "buildTime": latest["buildTime"],
            **details,
        })
    
    packages.sort(key=lambda p: str(p["name"]).lower())
    generated_at = dt.datetime.now(dt.timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")
    
    return {
        "generatedAt": generated_at,
        "repositoryUrl": repo_url,
        "packageCount": len(packages),
        "rpmCount": sum(p["rpmCount"] for p in packages),
        "packages": packages,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--release-data", default="docs/api/zopen_releases_latest.json")
    parser.add_argument("--descriptions", default="docs/api/zopen_releases_descriptions.json")
    parser.add_argument("--output", default="docs/api/rpm_packages.json")
    parser.add_argument("--repo-url", default=DEFAULT_REPO_URL)
    parser.add_argument("--metadata-url", default=DEFAULT_METADATA_URL)
    args = parser.parse_args()
    
    print("Loading release data...")
    release_payload = json.loads(Path(args.release_data).read_text(encoding="utf-8"))
    description_payload = json.loads(Path(args.descriptions).read_text(encoding="utf-8"))
    
    print("Fetching repository metadata...")
    repomd_xml = fetch_text(args.metadata_url)
    primary_url = parse_repomd(repomd_xml, args.repo_url)
    
    if not primary_url:
        raise ValueError("Could not find primary metadata URL in repomd.xml")
    
    print(f"Fetching primary metadata from {primary_url}...")
    # Primary metadata is usually gzipped XML
    import gzip
    primary_data = fetch_binary(primary_url)
    
    # Try to decompress if it's gzipped
    try:
        primary_xml = gzip.decompress(primary_data).decode("utf-8")
    except Exception:
        # If not gzipped, use as-is
        primary_xml = primary_data.decode("utf-8")
    
    print("Parsing RPM metadata...")
    rpm_packages = parse_primary_xml(primary_xml)
    print(f"Found {len(rpm_packages)} RPM packages")
    
    print("Building catalog...")
    catalog = build_catalog(rpm_packages, release_payload, description_payload, args.repo_url)
    
    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(catalog, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    
    print(f"Wrote {catalog['packageCount']} packages ({catalog['rpmCount']} RPMs) to {output_path}")


if __name__ == "__main__":
    main()
