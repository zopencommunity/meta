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

    body_content=$(sed -n '/<body>/,/<\/body>/p' "${temp_html}" | sed '1d;$d' | sed '/<a href="#/d' | sed '/<a name="[^"]*"><\/a>/d' | sed '/<br>$/d' | sed '/<hr>/d')
    body_content=$(echo "${body_content}" | sed 's|<i>||g' | sed 's|</i>||g' | sed 's|<em>||g' | sed 's|</em>||g' | sed 's|<b>||g' | sed 's|</b>||g' | sed 's|<strong>||g' | sed 's|</strong>||g')
    body_content=$(echo "${body_content}" | sed 's|</p> </td>|</p></td>|g')
    body_content=$(echo "${body_content}" | sed 's|<table|\'$'\n''<table|g' | sed 's|</table>|</table>\'$'\n''|g')
    body_content=$(echo "${body_content}" | sed 's|<tr|\'$'\n''<tr|g' | sed 's|</tr>|</tr>\'$'\n''|g')
    body_content=$(echo "${body_content}" | sed 's|<td|\'$'\n''<td|g' | sed 's|</td>|</td>\'$'\n''|g')
    body_content=$(echo "${body_content}" | sed 's|\([^<:]\)/|\1&#47;|g')
    # Normalize headings: ensure <h2> tags are properly closed on a single line
    body_content=$(echo "${body_content}" | perl -0777 -pe 's{<h2>\s*([^\n<]+)\s*(?:<a[^>]*>.*?</a>)?\s*</h2>}{<h2>$1</h2>\n<a name="$1"></a>}gs' 2>/dev/null || echo "${body_content}")

    orphaned_tags=$(echo "${body_content}" | grep -oE '</[a-z]+>' | sort | uniq || true)
    for closing_tag in ${orphaned_tags}; do
      tag_name=$(echo "${closing_tag}" | sed 's|</||' | sed 's|>||')
      opening_tag="<${tag_name}"
      opening_count=$(echo "${body_content}" | grep -o "${opening_tag}" | wc -l)
      closing_count=$(echo "${body_content}" | grep -o "${closing_tag}" | wc -l)
      if [ "${closing_count}" -gt "${opening_count}" ]; then
        body_content=$(echo "${body_content}" | sed "s|</p>${closing_tag}|</p>|g")
        body_content=$(echo "${body_content}" | sed "s|</b>${closing_tag}|</b>|g")
        body_content=$(echo "${body_content}" | sed "s|^${closing_tag}$||g")
      fi
    done
    rm -f "${temp_html}"

    cat <<EOF > "${md}"
<div v-pre class="man-page-content">

<div class="header-with-back">
  <div class="back-link">
    <a href="./zopen-reference">← Back</a>
  </div>
</div>

${body_content}

</div>
EOF

    # Validate the generated markdown file for unclosed opening tags
    all_tags=$(grep -oE '<[a-z]+[^>]*>' "${md}" | grep -v '</' | sed 's|<||' | sed 's| .*||' | sed 's|>||' | sort | uniq || true)
    for tag_name in ${all_tags}; do
      if [[ "${tag_name}" =~ ^(br|hr|img|input|meta|link|[a-z]+[0-9]+)$ ]]; then
        continue
      fi
      opening_count=$(grep -o "<${tag_name}" "${md}" | wc -l | tr -d ' ')
      closing_count=$(grep -o "</${tag_name}>" "${md}" | wc -l | tr -d ' ')
      if [ "${opening_count}" -ne "${closing_count}" ]; then
        echo "WARNING: Tag mismatch in ${md}: ${opening_count} opening <${tag_name}> tags but ${closing_count} closing tags"
      fi
    done

    echo "* [${name}](./${name})" >> docs/reference/zopen-reference.md
  done
else
  echo "Warning: groff not found; skipping man page HTML conversion."
fi

echo "=== VitePress documentation generation complete ==="
