#!/bin/env bash
#
# Nightly build script for zopen documentation and API generation
# Handles:
#   - Documentation updates (status, vulnerabilities, contributors)
#   - Man page to Markdown conversion via groff
#   - HTML cleaning and normalization for Vue compatibility
#   - GitHub workflow updates
#
set -e

# ============================================================================
# CONFIGURATION
# ============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_URL="git@github.com:zopencommunity/meta.git"
WORK_DIR="meta_update"
GROFF_OPT_NAME="${SCRIPT_DIR}/../docs/reference"

# ============================================================================
# LOGGING & ERROR HANDLING
# ============================================================================
log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"; }
error() { echo "[ERROR] $*" >&2; return 1; }
die() { error "$@"; exit 1; }

# ============================================================================
# GITHUB OPERATIONS
# ============================================================================
UpdateGithub() {
  log "Updating GitHub workflows..."
  multi-gitter --config ./cicd/multi-gitter-config run ./bulk-utils/enable_disabled_workflow.sh
}

# ============================================================================
# DOCUMENTATION GENERATION
# ============================================================================
UpdateDocs() {
  log "Starting documentation update..."
  
  # Clone the repository
  log "Cloning repository..."
  git clone "$REPO_URL" "$WORK_DIR"
  cd "$WORK_DIR" || die "Failed to enter work directory"
  
  # Set up git config for commits
  git config --global user.email "zosopentools@ibm.com"
  git config --global user.name "ZOS Open Tools"
  
  # Generate various documentation files
  log "Generating documentation files..."
  GenerateStatusDocs
  GenerateVulnerabilityDocs
  GenerateContributorsList
  
  # Generate API reference documentation
  log "Generating API reference documentation..."
  GenerateApiReference
  
  # Generate man page to Markdown conversions
  log "Converting man pages to Markdown..."
  ConvertManPagesToMarkdown
  
  # Commit and push all changes
  log "Committing documentation changes..."
  git add docs/*.md docs/*.xml docs/images/*.png docs/images/upstream/* docs/api/* docs/reference/*
  git commit -m "Updating docs/apis/reference" || log "No changes to commit"
  git status
  
  log "Pushing documentation changes..."
  git pull --rebase || true
  git push origin || log "Failed to push (may already be up-to-date)"
  
  cd ..
  log "Documentation update complete."
}

# ============================================================================
# STATUS & VULNERABILITY DOCUMENTATION
# ============================================================================
GenerateStatusDocs() {
  # Generate the currency status
  ./tools/get_bump_status.sh docs/updatestatus.md
  
  # Generate the upstream status
  python3 ./tools/generate_zopencommunity_patch_report.py \
    --report docs/upstreamstatus.md \
    --images docs/images/upstream \
    --start-date=2023-01-01
  
  # Generate the zopen files list
  python3 ./tools/generate_zopen_files_list.py -o docs/api/zopen_files.json
  
  # Update the status page
  python3 tools/getbinaries.py
}

GenerateVulnerabilityDocs() {
  # Refresh the vulnerability JSON by querying osv.dev for each release commit
  python3 tools/create_cve_json.py --output-file docs/api/zopen_vulnerability.json
  
  # Generate a view of the vulnerabilities in package releases
  python3 tools/create_vulnerability_doc.py \
    --md-output-file docs/Vulnerabilities.md \
    --xml-output-file docs/vulnerabilities_rss.xml
}

GenerateContributorsList() {
  # Update the contributors section in team.md with a live GitHub contributors graph
  python3 - <<'PYEOF'
import re, sys

team_file = "docs/team.md"
with open(team_file, "r") as f:
    content = f.read()

contributors_section = """## Our Contributors

We are incredibly grateful for our amazing community of contributors. You can see a full list of everyone who has contributed to the zopen project below.

[![GitHub Contributors](https://contrib.rocks/image?repo=zopencommunity/meta)](https://github.com/zopencommunity/meta/graphs/contributors)

View the full contributor graph on GitHub: [https://github.com/zopencommunity/meta/graphs/contributors](https://github.com/zopencommunity/meta/graphs/contributors)
"""

# Replace existing ## Our Contributors section (up to the next ## heading or end of file)
content = re.sub(
    r'## Our Contributors.*?(?=^## |\Z)',
    contributors_section + '\n',
    content,
    flags=re.DOTALL | re.MULTILINE
)

with open(team_file, "w") as f:
    f.write(content)

print(f"Updated contributors section in {team_file}")
PYEOF
}

GenerateApiReference() {
  mkdir -p docs/api
  mkdir -p docs/reference
  . ./.env
  export ZOPEN_ROOTFS="na" # To workaround sourcing zopen-config error
  mkdir -p "man/man1/"
  zopen-help2man "man/man1/" # Generate man pages

  cat <<EOF > docs/reference/zopen-reference.md
# zopen reference documentation
This page provides information about the zopen interface. Click on any of the zopen commands listed below to access the reference guide describing how to utilize that command.
EOF
}

# Build a sorted array of all man page names so ConvertSingleManPage can look
# up the previous and next sibling for navigation links.
_MAN_PAGE_NAMES=()
_BuildManPageIndex() {
  _MAN_PAGE_NAMES=()
  for man in man/man1/*.1; do
    local base=${man##*/}
    _MAN_PAGE_NAMES+=("${base%%.1}")
  done
  # Sort to match the order appended to zopen-reference.md
  IFS=$'\n' _MAN_PAGE_NAMES=($(printf '%s\n' "${_MAN_PAGE_NAMES[@]}" | sort))
  unset IFS
}

# ============================================================================
# MAN PAGE TO MARKDOWN CONVERSION
# ============================================================================
ConvertManPagesToMarkdown() {
  set -x

  # Build the sorted name index first so nav links are available
  _BuildManPageIndex

  # Process each man page
  for man in man/man1/*.1; do
    ConvertSingleManPage "$man"
  done
  
  set +x
}

ConvertSingleManPage() {
  local man="$1"
  local base=${man##*/}
  local name=${base%%.1}
  local md="docs/reference/${name}.md"
  local temp_html

  log "Converting $name..."

  # Determine prev/next sibling names for navigation links
  local prev_name="" next_name=""
  local i total=${#_MAN_PAGE_NAMES[@]}
  for (( i=0; i<total; i++ )); do
    if [[ "${_MAN_PAGE_NAMES[$i]}" == "$name" ]]; then
      (( i > 0 ))       && prev_name="${_MAN_PAGE_NAMES[$((i-1))]}"
      (( i < total-1 )) && next_name="${_MAN_PAGE_NAMES[$((i+1))]}"
      break
    fi
  done

  # Generate temporary HTML from the man page
  temp_html=$(mktemp) || die "Failed to create temp file"
  trap "rm -f '$temp_html'" RETURN
  
  groff -m mandoc -Thtml -Wall "$man" > "$temp_html" || die "groff failed for $name"
  
  # Extract and clean HTML body
  local body_content
  body_content=$(ExtractHtmlBody "$temp_html")
  
  # Apply HTML cleaning passes (order matters)
  body_content=$(RemoveInlineFormatting "$body_content")
  body_content=$(CollapseTableTags "$body_content")
  body_content=$(CollapseHeadingTags "$body_content")
  body_content=$(StripTrailingWhitespace "$body_content")
  body_content=$(ConvertMarginParagraphsToTables "$body_content")
  body_content=$(ConvertGroffTablesToBordered "$body_content")
  body_content=$(LinkifyUrls "$body_content")
  body_content=$(RemoveOrphanedTags "$body_content" "$md")
  
  # Write the markdown file with correct nav structure
  WriteMarkdownFile "$md" "$body_content" "$prev_name" "$next_name"
  
  # Validate the generated file
  ValidateMarkdownFile "$md" "$name"
  
  echo "* [${name}](./${name})" >> docs/reference/zopen-reference.md
}

# ============================================================================
# HTML EXTRACTION & CLEANING
# ============================================================================
ExtractHtmlBody() {
  local html_file="$1"
  
  # Extract content between <body> and </body>, removing navigation and formatting artifacts
  sed -n '/<body>/,/<\/body>/p' "$html_file" \
    | sed '1d;$d' \
    | sed '/<a href="#/d' \
    | sed '/<a name="[^"]*"><\/a>/d' \
    | sed '/<br>$/d' \
    | sed '/<hr>/d'
}

RemoveInlineFormatting() {
  # Strip italic/emphasis tags only — preserve <b>/<strong> so option names keep
  # their bold markup when wrapped in <code> cells by ConvertGroffTablesToBordered.
  echo "$1" | sed 's|<i>||g; s|</i>||g; s|<em>||g; s|</em>||g'
}

CollapseTableTags() {
  # Collapse multi-line <table ...> opening tags into one line.
  # groff -Thtml emits the tag attributes across several lines which Vue cannot parse.
  echo "$1" | perl -0pe '
    s{<table([^>]*?)\n([^>]*?)>}{"<table" . ($1.$2 =~ s/\s+/ /gr) . ">"}ge
      while /<table[^>]*\n/;
  '
}

CollapseHeadingTags() {
  # Join <h2>TEXT\n</h2> (and <h1>) onto one line – Vue rejects split heading tags.
  echo "$1" | perl -0pe '
    s{(<h[12][^>]*>[^\n]*)\n(</h[12]>)}{$1$2}g;
  '
}

StripTrailingWhitespace() {
  # Strip trailing whitespace from every line so whitespace-only lines become
  # truly empty lines (whitespace-only lines inside <tr>/<td> confuse Vue).
  echo "$1" | sed 's/[[:space:]]*$//'
}

# ============================================================================
# GROFF PARAGRAPH-TO-TABLE CONVERSION
# ============================================================================
ConvertMarginParagraphsToTables() {
  # Convert groff <p style="margin-left:11%"> / <p style="margin-left:22%"> pairs
  # into consistent HTML table rows, regardless of section or table context.
  #
  # Strategy (single Python pass):
  #   1. Walk the document section-by-section (split on <h2> boundaries).
  #   2. Within each section, find every run of 11%/22% <p> pairs outside tables.
  #   3. If such pairs immediately follow a </table>, absorb them as extra <tr> rows.
  #   4. If such pairs appear with no preceding table in the same section, wrap in new table.
  #   5. Non-pair content (single 11%/22% paragraphs, other tags) is left as-is.
  
  echo "$1" | python3 - <<'PYEOF'
import sys, re

content = sys.stdin.read()

TABLE_OPEN = '<table width="100%" border="0" rules="none" frame="void" cellspacing="0" cellpadding="0">\n'
TABLE_CLOSE = '\n</table>\n'

# Primary pattern: standard 11%/22% indent pair.
# Secondary pattern: bare <p> with NO style attribute immediately followed by a 22% description.
# Groff sometimes omits the margin-left style on the option name <p> when it follows a </table>.
PAIR_RE = re.compile(
    r'(<p(?:[^>]*margin-left:11%[^>]*|(?![^>]*\bstyle\b)[^>]*)>.*?</p>)\s*'
    r'(<p[^>]*margin-left:22%[^>]*>.*?</p>)',
    re.DOTALL,
)

def pair_to_row(p11, p22):
    """Convert a matched 11%/22% <p> pair into a <tr> row."""
    cmd  = re.sub(r'^<p[^>]*>|</p>$', '', p11, flags=re.DOTALL).strip().replace('\n', ' ')
    desc = re.sub(r'^<p[^>]*>|</p>$', '', p22, flags=re.DOTALL).strip().replace('\n', ' ')
    return (
        '<tr valign="top" align="left">\n'
        '<td width="11%"></td>\n'
        '<td width="9%">\n'
        f'<p>{cmd}</p></td>\n'
        '<td width="2%"></td>\n'
        '<td width="78%">\n'
        f'<p>{desc}</p></td>\n'
        '</tr>'
    )

# Orphaned 22%-only description paragraph immediately after a </table>.
# groff emits these for long option names that push the description off the table row.
DESC_ONLY_RE = re.compile(
    r'^\s*(<p[^>]*margin-left:22%[^>]*>.*?</p>)',
    re.DOTALL,
)

def absorb_desc_into_table(table_html, desc_p):
    """Add a description-only row to an existing table for a dangling 22% paragraph."""
    desc = re.sub(r'^<p[^>]*>|</p>$', '', desc_p, flags=re.DOTALL).strip().replace('\n', ' ')
    extra = (
        '<tr valign="top" align="left">\n'
        '<td width="11%"></td>\n'
        '<td width="9%"></td>\n'
        '<td width="2%"></td>\n'
        '<td width="78%">\n'
        f'<p>{desc}</p></td>\n'
        '</tr>'
    )
    close_pos = table_html.rfind('</table>')
    return table_html[:close_pos] + '\n' + extra + TABLE_CLOSE.lstrip('\n')

def process_outside_tables(text):
    """Convert all 11%/22% <p> pairs outside <table>...</table> blocks into table rows."""
    TABLE_BLOCK_RE = re.compile(r'(<table\b[^>]*>.*?</table>)', re.DOTALL | re.IGNORECASE)
    segments = TABLE_BLOCK_RE.split(text)

    result_parts = []
    for i, seg in enumerate(segments):
        if i % 2 == 1:
            result_parts.append(seg)
            continue

        # Check if this outside-segment starts with orphaned 22% description paragraphs.
        while result_parts and result_parts[-1].rstrip().endswith('</table>'):
            desc_m = DESC_ONLY_RE.match(seg)
            if not desc_m:
                break
            prev = result_parts.pop().rstrip()
            result_parts.append(absorb_desc_into_table(prev, desc_m.group(1)))
            seg = seg[desc_m.end():]

        # Outside a table: find all 11%/22% pairs and replace with <tr> rows.
        out = ''
        last_end = 0
        row_buffer = []

        for m in PAIR_RE.finditer(seg):
            between = seg[last_end:m.start()]
            if row_buffer and between.strip():
                # Flush accumulated rows when there is real non-whitespace content between pairs.
                if result_parts and result_parts[-1].rstrip().endswith('</table>'):
                    prev = result_parts.pop().rstrip()
                    result_parts.append(
                        prev[: prev.rfind('</table>')] +
                        '\n' + '\n'.join(row_buffer) +
                        TABLE_CLOSE
                    )
                else:
                    out += TABLE_OPEN + '\n'.join(row_buffer) + TABLE_CLOSE
                row_buffer = []
            out += between
            row_buffer.append(pair_to_row(m.group(1), m.group(2)))
            last_end = m.end()

        # Flush remaining text after the last match.
        tail = seg[last_end:]
        if row_buffer:
            if result_parts and result_parts[-1].rstrip().endswith('</table>'):
                prev = result_parts.pop().rstrip()
                result_parts.append(
                    prev[: prev.rfind('</table>')] +
                    '\n' + '\n'.join(row_buffer) +
                    TABLE_CLOSE
                )
            else:
                out += TABLE_OPEN + '\n'.join(row_buffer) + TABLE_CLOSE
            row_buffer = []
        out += tail
        result_parts.append(out)

    return ''.join(result_parts)

# Split by <h2> section boundaries so each section is processed independently.
H2_RE = re.compile(r'(<h2\b[^>]*>.*?</h2>)', re.DOTALL | re.IGNORECASE)
sections = H2_RE.split(content)
out_parts = []
for j, sec in enumerate(sections):
    if j % 2 == 1:
        # This is an <h2> heading tag — pass through unchanged
        out_parts.append(sec)
    else:
        out_parts.append(process_outside_tables(sec))

print(''.join(out_parts), end='')
PYEOF
}

# ============================================================================
# GROFF LAYOUT TABLE TO BORDERED TABLE CONVERSION
# ============================================================================
ConvertGroffTablesToBordered() {
  # Convert groff-generated layout tables into readable bordered tables with headers.
  # Targets the auto-generated <table width="100%"> rows produced by ConvertMarginParagraphsToTables
  # and replaces each table block with a styled <table border="1"> with Option/Variable/Function
  # and Description column headers.
  #
  # ROW_RE is intentionally flexible: groff emits varying column widths depending on
  # the man page content, so we match by positional order (2nd non-spacer td = label,
  # next non-spacer td = description) rather than hard-coding specific width values.

  echo "$1" | python3 - <<'PYEOF'
import sys, re

content = sys.stdin.read()

# Match any groff-layout table: border="0" rules="none" frame="void"
# Attribute order varies so we check for each attribute independently.
GROFF_TABLE_RE = re.compile(
    r'<table\b[^>]*border="0"[^>]*rules="none"[^>]*>.*?</table>',
    re.DOTALL | re.IGNORECASE,
)

# Extract all <tr> blocks from a groff layout table then pick the two
# meaningful columns: the narrower "label" td and the wider "description" td.
# We skip pure-spacer tds (empty content or only whitespace/empty-p tags).
TR_RE = re.compile(r'<tr\b[^>]*>(.*?)</tr>', re.DOTALL | re.IGNORECASE)
TD_RE = re.compile(r'<td\b[^>]*>(.*?)</td>', re.DOTALL | re.IGNORECASE)
P_CONTENT_RE = re.compile(r'<p[^>]*>(.*?)</p>', re.DOTALL | re.IGNORECASE)

def td_text(td_inner):
    """Extract visible text from a <td> cell, collapsing nested <p> tags."""
    # Try to find a <p> tag first
    p_m = P_CONTENT_RE.search(td_inner)
    text = p_m.group(1) if p_m else td_inner
    return text.strip()

def is_spacer(text):
    """Return True if this td cell carries no meaningful content."""
    return not re.sub(r'<[^>]*>', '', text).strip()

def extract_rows(table_html):
    """Return list of (label, description) pairs from a groff layout table."""
    rows = []
    for tr_m in TR_RE.finditer(table_html):
        tr_inner = tr_m.group(1)
        tds = [td_text(m.group(1)) for m in TD_RE.finditer(tr_inner)]
        # Filter out pure spacer cells; meaningful cells are label then description
        meaningful = [t for t in tds if not is_spacer(t)]
        if len(meaningful) >= 2:
            rows.append((meaningful[0], meaningful[1]))
        elif len(meaningful) == 1:
            # Description-only row (continuation / orphaned desc)
            rows.append(('', meaningful[0]))
    return rows

def pick_header(context_before):
    """Choose the first column header based on what section precedes this table."""
    ctx = context_before.lower()
    if any(k in ctx for k in ('function', 'zopen_')):
        return 'Function'
    if any(k in ctx for k in ('variable', 'environment', 'env')):
        return 'Variable'
    return 'Option'

STYLED_TABLE_OPEN = (
    '<table border="1" cellpadding="10" cellspacing="0" style="width:100%; border-collapse:collapse;">\n'
    '<tr style="background-color:#f0f0f0;">\n'
    '<th style="text-align:left; border: 1px solid #ccc;">{header}</th>\n'
    '<th style="text-align:left; border: 1px solid #ccc;">Description</th>\n'
    '</tr>\n'
)

def replace_table(m):
    table_html = m.group(0)
    rows = extract_rows(table_html)
    if not rows:
        return table_html  # leave unchanged if no rows matched

    context_before = content[:m.start()]
    header = pick_header(context_before)

    styled = STYLED_TABLE_OPEN.format(header=header)
    for label, description in rows:
        # Strip residual bold tags from label text before wrapping in <code>
        label = re.sub(r'</?(?:b|strong)\b[^>]*>', '', label).strip()
        description = description.strip()
        if label:
            styled += (
                '<tr>\n'
                f'<td style="border: 1px solid #ccc;"><code>{label}</code></td>\n'
                f'<td style="border: 1px solid #ccc;">{description}</td>\n'
                '</tr>\n'
            )
        else:
            # continuation description row — merge into last row's description cell
            if styled.endswith('</tr>\n'):
                styled = styled[:-len('</tr>\n')]
                styled = re.sub(
                    r'(<td style="border: 1px solid #ccc;">)(.*?)(</td>\n)$',
                    lambda mm: mm.group(1) + mm.group(2) + ' ' + description + mm.group(3),
                    styled,
                    flags=re.DOTALL,
                )
                styled += '</tr>\n'
            # else: orphaned description with no preceding row — skip silently
    styled += '</table>'
    return styled

result = GROFF_TABLE_RE.sub(replace_table, content)
print(result, end='')
PYEOF
}

# ============================================================================
# URL LINKIFICATION
# ============================================================================
LinkifyUrls() {
  # Convert URLs (in angle brackets or bare) to proper HTML links with target="_blank"
  # - HTML-entity angle-bracket form:  &lt;https://...&gt;  →  <a href="...">...</a>
  # - Literal angle-bracket form:      <https://...>        →  <a href="...">...</a>
  # - Bare form:                        https://...          →  <a href="...">...</a>
  # NOTE: groff -Thtml encodes angle-brackets around URLs as &lt; / &gt; entities,
  # so the entity form must be handled first, before the bare-URL pass strips &gt; into the href.
  
  echo "$1" | perl -pe '
    # Entity-encoded angle-bracket URLs: &lt;https://...&gt;
    s{&lt;((https?|ftp)://[^&]+)&gt;}{<a href="$1" target="_blank">$1</a>}g;
    # Literal angle-bracket URLs: <https://...>
    s{<((https?|ftp)://[^>]+)>}{<a href="$1" target="_blank">$1</a>}g;
    # Bare URLs not already inside an href="..." value or existing link text (preceded by " or >)
    s{(?<![">])(https?|ftp)://([^\s<>"&]+)}{<a href="$1://$2" target="_blank">$1://$2</a>}g;
  '
}

# ============================================================================
# ORPHANED TAG REMOVAL
# ============================================================================
RemoveOrphanedTags() {
  local content="$1"
  local md="$2"
  
  # Remove closing tags with no matching opening tags.
  # Uses Python for accurate counting; handles bare tags at line-start and inline
  # occurrences such as "text</p></table>" that sed approaches miss.
  
  content=$(echo "$content" | python3 - <<'PYEOF'
import sys, re
from collections import Counter

VOID = {"br","hr","img","input","meta","link","area","base","col","embed","param","source","track","wbr"}
content = sys.stdin.read()

opens  = re.findall(r'<([a-zA-Z][a-zA-Z0-9]*)\b[^>]*(?<!/)>', content)
closes = re.findall(r'</([a-zA-Z][a-zA-Z0-9]*)>', content)
oc = Counter(t.lower() for t in opens  if t.lower() not in VOID)
cc = Counter(t.lower() for t in closes)

for tag in sorted(cc):
    surplus = cc[tag] - oc.get(tag, 0)
    if surplus <= 0:
        continue
    print(f"Warning: removing {surplus} orphaned </{tag}>", file=sys.stderr)
    # Remove surplus closing tags – prefer line-isolated ones first, then inline
    for _ in range(surplus):
        # 1. bare line: just the closing tag optionally with whitespace
        content, n = re.subn(rf'(?m)^[ \t]*</{tag}>[ \t]*\n?', '', content, count=1)
        if n:
            continue
        # 2. inline after another closing tag: </x></tag>
        content, n = re.subn(rf'(</{tag}>)(?=.*</{tag}>)', '', content, count=1, flags=re.DOTALL)
        if n:
            continue
        # 3. last resort: first occurrence anywhere
        content = re.sub(rf'</{tag}>', '', content, count=1)

print(content, end='')
PYEOF
)
  
  echo "$content"
}

# ============================================================================
# MARKDOWN FILE WRITING & VALIDATION
# ============================================================================
WriteMarkdownFile() {
  local md="$1"
  local body_content="$2"
  local prev_name="${3:-}"
  local next_name="${4:-}"

  # Build the prev/next navigation links
  local nav_html=""
  if [[ -n "$prev_name" || -n "$next_name" ]]; then
    nav_html='    <div class="nav-buttons">'$'\n'
    [[ -n "$prev_name" ]] && nav_html+='    <a href="./'${prev_name}'" class="nav-link">← Prev</a>'$'\n'
    [[ -n "$next_name" ]] && nav_html+='    <a href="./'${next_name}'" class="nav-link">Next →</a>'$'\n'
    nav_html+='    </div>'
  fi

  cat <<EOF > "$md"
<div v-pre class="man-page-content">

<div class="header-with-back">
  <div class="home-link">
    <a href="./zopen-reference">🏠 Home</a>
  </div>
${nav_html}
</div>

${body_content}

</div>
EOF
}

ValidateMarkdownFile() {
  local md="$1"
  local name="$2"
  
  log "Validating ${name}..."
  
  local validation_errors=0
  
  # Check for unclosed opening tags (opening tags without matching closing tags)
  local all_tags opening_count closing_count
  all_tags=$(grep -oE '<[a-z]+[^>]*>' "$md" 2>/dev/null | grep -v '</' | sed 's|<||' | sed 's| .*||' | sed 's|>||' | sort -u)
  
  for tag_name in ${all_tags}; do
    # Skip self-closing and special tags
    if [[ "${tag_name}" =~ ^(br|hr|img|input|meta|link|[a-z]+[0-9]+)$ ]]; then
      continue
    fi
    
    opening_count=$(grep -o "<${tag_name}" "$md" 2>/dev/null | wc -l | tr -d ' ')
    closing_count=$(grep -o "</${tag_name}>" "$md" 2>/dev/null | wc -l | tr -d ' ')
    
    if [ "$opening_count" -ne "$closing_count" ]; then
      error "Tag mismatch in ${md}: ${opening_count} opening <${tag_name}> but ${closing_count} closing tags"
      validation_errors=$((validation_errors + 1))
    fi
  done
  
  if [ $validation_errors -gt 0 ]; then
    log "WARNING: Found ${validation_errors} validation error(s) in ${md}"
  else
    log "✓ ${md} passed validation"
  fi
}

# ============================================================================
# MAIN ENTRY POINT
# ============================================================================
main() {
  log "zopen nightly build starting..."
  
  UpdateGithub
  UpdateDocs
  
  log "zopen nightly build complete."
}

main "$@"
