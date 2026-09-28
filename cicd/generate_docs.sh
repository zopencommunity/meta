#!/usr/bin/env bash
#
# Script to generate all documentation pages and assets required by VitePress.
# Output:
#   - docs/updatestatus.md
#   - docs/upstreamstatus.md and docs/images/upstream/*
#   - docs/Latest.md and docs/Progress.md
#   - docs/Vulnerabilities.md (and docs/vulnerabilities_rss.xml)
#   - docs/newly_released.md
#   - docs/reference/zopen-reference.md and docs/reference/*.md
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${REPO_ROOT}"

# Normalize and export GitHub token
TOKEN="${ZOPEN_GITHUB_OAUTH_TOKEN:-${GITHUB_TOKEN:-${GH_TOKEN:-}}}"
if [ -n "${TOKEN}" ]; then
  export ZOPEN_GITHUB_OAUTH_TOKEN="${TOKEN}"
  export GITHUB_TOKEN="${TOKEN}"
  export GH_TOKEN="${TOKEN}"
fi

echo "=== Generating VitePress Documentation Pages ==="

mkdir -p docs/reference
mkdir -p docs/images/upstream

# 1. Generate the currency status (docs/updatestatus.md)
echo "Generating currency status..."
./tools/get_bump_status.sh docs/updatestatus.md || echo "Warning: get_bump_status failed; continuing."

# 2. Generate the upstream status and patch report charts (docs/upstreamstatus.md)
echo "Generating upstream patch status and charts..."
python3 ./tools/generate_zopencommunity_patch_report.py \
  --report docs/upstreamstatus.md \
  --images docs/images/upstream \
  --start-date=2023-01-01 || echo "Warning: patch report failed; continuing."

# 3. Generate All Tools and Progress pages (docs/Latest.md and docs/Progress.md)
echo "Generating tools status and progress pages..."
python3 tools/getbinaries.py || echo "Warning: getbinaries failed; continuing."

# 4. Generate package vulnerabilities documentation (docs/Vulnerabilities.md)
echo "Generating vulnerabilities documentation..."
python3 tools/create_vulnerability_doc.py \
  --md-output-file docs/Vulnerabilities.md \
  --xml-output-file docs/vulnerabilities_rss.xml || echo "Warning: vulnerability doc failed; continuing."

# 5. Generate newly released tools view (docs/newly_released.md)
echo "Generating newly released tools documentation..."
python3 tools/create_latest_release_doc.py --output docs/newly_released.md || echo "Warning: newly released doc failed; continuing."

# 6. Generate zopen command reference & man pages (docs/reference/*.md)
echo "Generating CLI command reference..."
export ZOPEN_ROOTFS="${ZOPEN_ROOTFS:-na}"
export PATH="${REPO_ROOT}/bin:${PATH}"

mkdir -p "man/man1/"
if command -v help2man >/dev/null 2>&1; then
  if command -v zopen-help2man >/dev/null 2>&1; then
    zopen-help2man "man/man1/" || echo "Warning: zopen-help2man reported errors; continuing."
  elif [ -x "./bin/zopen-help2man" ]; then
    ./bin/zopen-help2man "man/man1/" || echo "Warning: zopen-help2man reported errors; continuing."
  fi
else
  echo "Warning: 'help2man' not found; skipping CLI man-page generation."
fi

cat <<EOF > docs/reference/zopen-reference.md
# zopen reference documentation
This page provides information about the zopen interface. Click on any of the zopen commands listed below to access the reference guide describing how to utilize that command.
EOF

if command -v groff >/dev/null 2>&1; then
  for man in man/man1/*.1; do
    [ -e "${man}" ] || continue
    base=${man##*/}
    name=${base%%.1}
    md="docs/reference/${name}.md"

    temp_html=$(mktemp)
    groff -m mandoc -Thtml -Wall "${man}" > "${temp_html}" || true

    python3 tools/sanitize_man_html.py "${temp_html}" "${md}"
    rm -f "${temp_html}"

    echo "* [${name}](./${name})" >> docs/reference/zopen-reference.md
  done
else
  echo "Warning: groff not found; skipping man page HTML conversion."
fi

echo "=== VitePress documentation generation complete ==="
