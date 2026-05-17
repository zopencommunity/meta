#!/bin/bash
set -euo pipefail

echo "=== STARTING PUBLISH JOB ==="

# --- REQUIRED ENV ---
: "${PORT_GITHUB_REPO:?Missing PORT_GITHUB_REPO}"
: "${PORT_DESCRIPTION:?Missing PORT_DESCRIPTION}"
: "${BUILD_NUMBER:?Missing BUILD_NUMBER}"
: "${GITHUB_TOKEN:?Missing GITHUB_TOKEN}"
: "${PULP_USERNAME:?Missing PULP_USERNAME}"
: "${PULP_PASSWORD:?Missing PULP_PASSWORD}"

# --- STATIC CONFIG ---
GITHUB_ORGANIZATION="zopencommunity"
RELEASE_NOTES_SCRIPT="tools/create_release_notes.sh"
PULP_HOST="https://repo.zopen.community"

# --- DERIVE VALUES ---
RELEASE_PREFIX=$(basename "${PORT_GITHUB_REPO}")
RELEASE_PREFIX=${RELEASE_PREFIX%%.*}
PORT_NAME=$(echo "$RELEASE_PREFIX" | sed 's/port$//')
GITHUB_REPO=$RELEASE_PREFIX

# --- FIND FILES ---
PAX=$(find . -path "*/install/*.zos.pax.Z" -type f | head -n 1)
METADATA=$(find . -path "*/install/metadata.json" -type f | head -n 1)

[ -f "$PAX" ] || { echo "ERROR: Missing PAX file"; exit 1; }
[ -f "$METADATA" ] || { echo "ERROR: Missing metadata.json"; exit 1; }

# --- RESOLVE BUILD LINE ---
if [ -z "${BUILD_LINE:-}" ] || [ "$BUILD_LINE" = "null" ]; then
  METADATA_BUILD_LINE=$(python3 -c "import json; print(json.load(open('$METADATA'))['product'].get('buildline', ''))" 2>/dev/null || echo "")
  if [ -n "$METADATA_BUILD_LINE" ] && [ "$METADATA_BUILD_LINE" != "null" ]; then
    BUILD_LINE=$(echo "$METADATA_BUILD_LINE" | tr '[:lower:]' '[:upper:]')
    echo "Using BUILD_LINE from metadata.json: $BUILD_LINE"
  else
    BUILD_LINE="DEV"
    echo "BUILD_LINE not found in environment or metadata.json. Defaulting to: $BUILD_LINE"
  fi
fi

# --- RPM FILES ---
RPM_FILES=()
while IFS= read -r -d '' f; do
  RPM_FILES+=("$f")
done < <(find . -path "*/rpmbuild/RPMS/*.rpm" ! -name "*.src.rpm" -type f -print0 2>/dev/null)

NUM_RPMS=${#RPM_FILES[@]}

# --- INFO ---
BUILD_STATUS=$(find . -path "*/install/test.status" -exec cat {} + 2>/dev/null || echo "Unknown")
DEPENDENCIES=$(find . -path "*/install/.runtimedeps" -exec cat {} + 2>/dev/null || echo "None")
VERSION=$(find . -path "*/install/.version" -exec cat {} + 2>/dev/null || echo "unknown")

unset http_proxy https_proxy

PAX_BASENAME=$(basename "$PAX")
TAG="${BUILD_LINE}_${RELEASE_PREFIX}_${BUILD_NUMBER}"
NAME="${PORT_NAME} ${VERSION} (Build ${BUILD_NUMBER}) - (${BUILD_LINE})"

# --- RELEASE NOTES ---
if [ -f "$RELEASE_NOTES_SCRIPT" ]; then
  RELEASE_NOTES=$("$RELEASE_NOTES_SCRIPT" -m release -p "$GITHUB_REPO" -t markdown || echo "No notes")
else
  RELEASE_NOTES="No release notes"
fi

echo "$RELEASE_NOTES" > CHANGELOG.md

DESCRIPTION="${PORT_DESCRIPTION}<br/><b>Status:</b> ${BUILD_STATUS}<br/>"
DESCRIPTION+="<b>Dependencies:</b> ${DEPENDENCIES}<br/>"
DESCRIPTION+=$'\n\n'"$RELEASE_NOTES"

# --- TOOL CHECK ---
command -v github-release >/dev/null || { echo "ERROR: github-release not installed"; exit 1; }

# --- CREATE / RECREATE RELEASE ---
if github-release info -u "$GITHUB_ORGANIZATION" -r "$GITHUB_REPO" --tag "$TAG" -j &>/dev/null; then
  github-release delete --user "$GITHUB_ORGANIZATION" --repo "$GITHUB_REPO" --tag "$TAG"
fi

github-release release \
  --user "$GITHUB_ORGANIZATION" \
  --repo "$GITHUB_REPO" \
  --tag "$TAG" \
  --name "$NAME" \
  --description "$DESCRIPTION"

echo "Waiting for GitHub to process release..."
sleep 5

# --- VALIDATE RELEASE (FIXES YOUR ERROR) ---
github-release info \
  -u "$GITHUB_ORGANIZATION" \
  -r "$GITHUB_REPO" \
  --tag "$TAG" || {
    echo "ERROR: Release creation failed"
    exit 1
}

# --- UPLOAD TO GITHUB RELEASES ---
github-release upload \
  --user "$GITHUB_ORGANIZATION" \
  --repo "$GITHUB_REPO" \
  --tag "$TAG" \
  --name "$PAX_BASENAME" \
  --file "$PAX"

github-release upload \
  --user "$GITHUB_ORGANIZATION" \
  --repo "$GITHUB_REPO" \
  --tag "$TAG" \
  --name "metadata.json" \
  --file "$METADATA"

github-release upload \
  --user "$GITHUB_ORGANIZATION" \
  --repo "$GITHUB_REPO" \
  --tag "$TAG" \
  --name "CHANGELOG.md" \
  --file "CHANGELOG.md"

# =========================================================
# 🔧 PULP SETUP (AUTO INSTALL + CONFIG)
# =========================================================

echo "=== Checking Pulp CLI ==="

if ! command -v pulp >/dev/null 2>&1; then
  echo "Pulp CLI not found. Installing..."

  if command -v pip3 >/dev/null 2>&1; then
    python3 -m pip install --user pulp-cli || true
    export PATH="$HOME/.local/bin:$PATH"
  fi
fi

if command -v pulp >/dev/null 2>&1; then
  echo "Pulp CLI available"

  pulp config create \
    --base-url "$PULP_HOST" \
    --username "$PULP_USERNAME" \
    --password "$PULP_PASSWORD" \
    --overwrite

  pulp status || {
    echo "ERROR: Pulp connection failed"
    exit 1
  }

  PULP_AVAILABLE=true
else
  echo "WARNING: Pulp not available, skipping RPM upload"
  PULP_AVAILABLE=false
fi

# =========================================================
# 📦 RPM UPLOAD
# =========================================================

PULP_REPO="zopen"

if [ "$NUM_RPMS" -gt 0 ] && [ "$PULP_AVAILABLE" = true ]; then

  echo "--- Configuring Pulp Pipeline ---"

  # 1. Enable autopublish so every upload triggers a new live version
  pulp rpm repository update --name "$PULP_REPO" --autopublish

  # 2. Link the distribution to the repository
  pulp rpm distribution update --name "$PULP_REPO" --repository "$PULP_REPO"

  echo "Uploading $NUM_RPMS RPMs to Pulp repo: $PULP_REPO"

  for RPM in "${RPM_FILES[@]}"; do
    RPM_NAME=$(basename "$RPM")

    # Upload to Pulp (with retry)
    for attempt in 1 2 3; do
      if pulp rpm content upload --file "$RPM" --repository "$PULP_REPO"; then
        echo "SUCCESS: $RPM_NAME"
        break
      fi
      
      if [ "$attempt" -eq 3 ]; then
        echo "WARNING: Failed to upload $RPM_NAME to Pulp after 3 attempts. Skipping..."
      else
        echo "Attempt $attempt failed for $RPM_NAME, retrying in 5 seconds..."
        sleep 5
      fi
    done
  done

  echo "=== SUCCESS: Packages are being processed ==="
  echo "Check the status at: ${PULP_HOST}/pulp/content/rpm/${PULP_REPO}/"

else
  echo "Skipping RPM upload"
fi



echo "=== SUCCESS: PUBLISH COMPLETED ==="
