#!/usr/bin/env bash
#
# This script runs after a successful build and publish of a tool.
# It regenerates the release metadata caches and catalogs, and uploads
# them as assets to a GitHub Release (tag: api-cache)
# without polluting Git history with automated commits.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${REPO_ROOT}"

# Normalize and export GitHub token for all tools (create_release_cache.py and gh)
TOKEN="${ZOPEN_GITHUB_OAUTH_TOKEN:-${GITHUB_TOKEN:-${GH_TOKEN:-}}}"
if [ -z "${TOKEN}" ]; then
  echo "ERROR: GitHub token must be defined. Please set ZOPEN_GITHUB_OAUTH_TOKEN or GITHUB_TOKEN."
  exit 1
fi
export ZOPEN_GITHUB_OAUTH_TOKEN="${TOKEN}"
export GITHUB_TOKEN="${TOKEN}"
export GH_TOKEN="${TOKEN}"

echo "=== Updating Release Metadata and Package Catalogs ==="

mkdir -p docs/api

# 1. Generate release cache (zopen_releases.json, _latest.json, _descriptions.json)
python3 tools/create_release_cache.py --verbose --output-file docs/api/zopen_releases.json

# Generate sha256 checksum for lightweight cache invalidation
if command -v sha256sum >/dev/null 2>&1; then
  sha256sum docs/api/zopen_releases.json | awk '{print $1}' > docs/api/zopen_releases.json.sha256
elif command -v shasum >/dev/null 2>&1; then
  shasum -a 256 docs/api/zopen_releases.json | awk '{print $1}' > docs/api/zopen_releases.json.sha256
fi

# 2. Merge release metadata with live wheel index for Python package catalogue
python3 tools/create_python_package_catalog.py

# 3. Generate RPM package catalogue if tool exists
if [ -f "tools/create_rpm_package_catalog.py" ]; then
  python3 tools/create_rpm_package_catalog.py || echo "Warning: RPM package catalog generation failed; skipping."
fi

GITHUB_REPO="${GITHUB_REPO:-}"
if [ -z "${GITHUB_REPO}" ]; then
  if command -v gh >/dev/null 2>&1; then
    GITHUB_REPO="$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || true)"
  fi
  GITHUB_REPO="${GITHUB_REPO:-zopencommunity/meta}"
fi
RELEASE_TAG="${RELEASE_TAG:-api-cache}"

API_FILES=(
  "docs/api/zopen_releases.json"
  "docs/api/zopen_releases.json.sha256"
  "docs/api/zopen_releases_latest.json"
  "docs/api/zopen_releases_descriptions.json"
  "docs/api/python_packages.json"
)
if [ -f "docs/api/rpm_packages.json" ]; then
  API_FILES+=("docs/api/rpm_packages.json")
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "ERROR: 'gh' CLI is required to upload release assets to GitHub."
  exit 1
fi

echo "=== Uploading API metadata to GitHub Release '${RELEASE_TAG}' in ${GITHUB_REPO} ==="
export GH_TOKEN="${TOKEN}"
export GITHUB_TOKEN="${TOKEN}"

# Ensure release exists
if ! gh release view "${RELEASE_TAG}" --repo "${GITHUB_REPO}" >/dev/null 2>&1; then
  echo "Release '${RELEASE_TAG}' does not exist. Creating release..."
  gh release create "${RELEASE_TAG}" \
    --repo "${GITHUB_REPO}" \
    --title "API Metadata & Release Caches" \
    --notes "Automated release metadata and package catalogs."
fi

# Upload files with clobber (replaces existing assets in-place)
for file in "${API_FILES[@]}"; do
  if [ -f "${file}" ]; then
    echo "Uploading ${file} via gh release upload --clobber..."
    gh release upload "${RELEASE_TAG}" "${file}" --repo "${GITHUB_REPO}" --clobber
  fi
done

echo "=== API metadata successfully uploaded via gh ==="

echo "=== Release post-build steps completed successfully ==="
