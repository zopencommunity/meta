#!/usr/bin/env bash
#
# This script will run nightly.
# It updates repository workflows and regenerates documentation and API
# metadata caches, uploading API caches to GitHub Releases (tag: api-cache)
# without polluting Git history with automated commits.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${REPO_ROOT}"

# Normalize and export GitHub token for all tools and gh
TOKEN="${ZOPEN_GITHUB_OAUTH_TOKEN:-${GITHUB_TOKEN:-${GH_TOKEN:-}}}"
if [ -z "${TOKEN}" ]; then
  echo "ERROR: GitHub token must be defined. Please set ZOPEN_GITHUB_OAUTH_TOKEN or GITHUB_TOKEN."
  exit 1
fi
export ZOPEN_GITHUB_OAUTH_TOKEN="${TOKEN}"
export GITHUB_TOKEN="${TOKEN}"
export GH_TOKEN="${TOKEN}"

UpdateGithub() {
  echo "=== Running Workflow Enabler across Organization ==="
  multi-gitter --config ./cicd/multi-gitter-config run ./bulk-utils/enable_disabled_workflow.sh
}

UpdateApiCaches() {
  echo "=== Generating Nightly API Metadata Caches ==="
  mkdir -p docs/api

  # 1. Generate zopen_files.json
  echo "Generating zopen_files.json..."
  python3 ./tools/generate_zopen_files_list.py -o docs/api/zopen_files.json

  # 2. Generate sha256 checksum for lightweight cache invalidation
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum docs/api/zopen_files.json | awk '{print $1}' > docs/api/zopen_files.json.sha256
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 docs/api/zopen_files.json | awk '{print $1}' > docs/api/zopen_files.json.sha256
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
    "docs/api/zopen_files.json"
    "docs/api/zopen_files.json.sha256"
  )
  if [ -f "docs/vulnerabilities_rss.xml" ]; then
    API_FILES+=("docs/vulnerabilities_rss.xml")
  fi
  if [ -f "docs/api/zopen_vulnerability.json" ]; then
    API_FILES+=("docs/api/zopen_vulnerability.json")
  fi

  if ! command -v gh >/dev/null 2>&1; then
    echo "ERROR: 'gh' CLI is required to upload release assets to GitHub."
    exit 1
  fi

  echo "=== Uploading API metadata to GitHub Release '${RELEASE_TAG}' in ${GITHUB_REPO} ==="

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
}

# 1. Update workflows across zopen repositories
UpdateGithub

# 2. Update nightly API caches and upload to GitHub Release (api-cache)
UpdateApiCaches

echo "=== Nightly tasks completed successfully ==="
