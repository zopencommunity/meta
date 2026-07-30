#!/bin/env bash
#
# This script will run nightly
#
set -e

UpdateGithub() {
  multi-gitter --config ./cicd/multi-gitter-config run ./bulk-utils/enable_disabled_workflow.sh
}

UpdateDocs() {
  # Update Progress page in documentation
  git clone git@github.com:zopencommunity/meta.git meta_update
  cd meta_update

  # Generate the currency status
  ./tools/get_bump_status.sh docs/updatestatus.md

  # Generate the upstream status
  python3 ./tools/generate_zopencommunity_patch_report.py --report docs/upstreamstatus.md --images docs/images/upstream --start-date=2023-01-01

  python3 ./tools/generate_zopen_files_list.py -o docs/api/zopen_files.json

  # This script updates the status page
  python3 tools/getbinaries.py

  # Generate a view of the vulnerabilities in package releases
  python3 tools/create_vulnerability_doc.py --md-output-file docs/Vulnerabilities.md --xml-output-file docs/vulnerabilities_rss.xml

  set -x
  # Generate zopen API Reference
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

  # Generate markdown pages only
  for man in man/man1/*.1;
  do
    base=${man##*/};
    name=${base%%.1};
    md="docs/reference/${name}.md";
    
    # Generate temporary HTML from the man page
    temp_html=$(mktemp)
    groff -m mandoc -Thtml -Wall "${man}" > "${temp_html}";
    
    # Extract only the content between <body> and </body>
    # This avoids injecting full-document tags (<html>, <head>, <body>) into markdown
    body_content=$(sed -n '/<body>/,/<\/body>/p' "${temp_html}" | sed '1d;$d' | sed '/<a href="#/d' | sed '/<a name="[^"]*"><\/a>/d' | sed '/<br>$/d' | sed '/<hr>/d')
    
    # Remove <i>, <em>, <b>, and <strong> tags to avoid Vue parsing issues
    body_content=$(echo "${body_content}" | sed 's|<i>||g' | sed 's|</i>||g' | sed 's|<em>||g' | sed 's|</em>||g' | sed 's|<b>||g' | sed 's|</b>||g' | sed 's|<strong>||g' | sed 's|</strong>||g')
    
    # Fix table cell closing tags that appear on the same line as content
    # This handles cases like: <p>content</p> </td> which Vue can't parse properly
    body_content=$(echo "${body_content}" | sed 's|</p> </td>|</p></td>|g')
    
    # Ensure all table-related tags are on their own lines for proper Vue parsing
    body_content=$(echo "${body_content}" | sed 's|<table|\'$'\n''<table|g' | sed 's|</table>|</table>\'$'\n''|g')
    body_content=$(echo "${body_content}" | sed 's|<tr|\'$'\n''<tr|g' | sed 's|</tr>|</tr>\'$'\n''|g')
    body_content=$(echo "${body_content}" | sed 's|<td|\'$'\n''<td|g' | sed 's|</td>|</td>\'$'\n''|g')
    
    # Convert groff OPTIONS <p> pairs into <ul><li> list for VitePress rendering.
    # Groff emits option names at margin-left:11% and descriptions at margin-left:22%.
    # This transforms those pairs into proper HTML list items so new options added to
    # any zopen-* script appear as a list on the generated VitePress page automatically.
    body_content=$(echo "${body_content}" | python3 - <<'PYEOF'
import sys, re

content = sys.stdin.read()

def convert_options_section(section_html):
    """
    Within an OPTIONS section, convert consecutive groff <p> indent pairs:
      <p style="margin-left:11%...">OPTION</p>
      <p style="margin-left:22%;">DESCRIPTION</p>
    into:
      <ul>
        <li><strong>OPTION</strong> — DESCRIPTION</li>
        ...
      </ul>
    """
    # Match option-name paragraphs (11% indent) followed by description (22% indent)
    pattern = re.compile(
        r'<p[^>]*margin-left:11%[^>]*>(.*?)</p>\s*'
        r'<p[^>]*margin-left:22%[^>]*>(.*?)</p>',
        re.DOTALL
    )
    items = pattern.findall(section_html)
    if not items:
        return section_html

    list_html = '<ul>\n'
    for flag, desc in items:
        flag = flag.strip().replace('\n', ' ')
        desc = desc.strip().replace('\n', ' ')
        list_html += f'<li><strong>{flag}</strong> &mdash; {desc}</li>\n'
    list_html += '</ul>'

    return pattern.sub('', section_html).rstrip() + '\n' + list_html

# Split around <h2>OPTIONS</h2> ... next <h2>
parts = re.split(r'(<h2[^>]*>\s*OPTIONS.*?</h2>)', content, flags=re.DOTALL|re.IGNORECASE)

if len(parts) >= 3:
    # parts[0] = before OPTIONS heading
    # parts[1] = the OPTIONS <h2> tag
    # parts[2] = content after OPTIONS heading (up to next section or end)
    # Find next <h2> in parts[2] to isolate the OPTIONS body
    next_h2 = re.search(r'<h2', parts[2], re.IGNORECASE)
    if next_h2:
        options_body = parts[2][:next_h2.start()]
        rest = parts[2][next_h2.start():]
    else:
        options_body = parts[2]
        rest = ''
    converted_body = convert_options_section(options_body)
    content = parts[0] + parts[1] + converted_body + rest

print(content, end='')
PYEOF
)

    # Convert URLs (in angle brackets or bare) to proper HTML links with target="_blank"
    # - Angle-bracket form:  <https://...>  →  <a href="...">...</a>
    # - Bare form:           https://...    →  <a href="...">...</a>  (skips URLs already in href="")
    body_content=$(echo "${body_content}" | perl -pe '
      # Angle-bracket URLs: <https://...>, <http://...>, <ftp://...>
      s|<((https?|ftp)://[^>]+)>|<a href="$1" target="_blank">$1</a>|g;
      # Bare URLs not already inside href="..."
      s|(?<!href=")(https?|ftp)://([^\s<>"]+)|<a href="$1://$2" target="_blank">$1://$2</a>|g;
    ')
    
    # Validate HTML: Check for orphaned closing tags (closing tags without matching opening tags)
    # This prevents Vue parsing errors from invalid HTML structure
    orphaned_tags=$(echo "${body_content}" | grep -oE '</[a-z]+>' | sort | uniq)
    for closing_tag in ${orphaned_tags}; do
      tag_name=$(echo "${closing_tag}" | sed 's|</||' | sed 's|>||')
      opening_tag="<${tag_name}"
      
      # Count opening and closing tags
      opening_count=$(echo "${body_content}" | grep -o "${opening_tag}" | wc -l)
      closing_count=$(echo "${body_content}" | grep -o "${closing_tag}" | wc -l)
      
      # If there are more closing tags than opening tags, remove the orphaned ones
      if [ ${closing_count} -gt ${opening_count} ]; then
        echo "Warning: Found ${closing_count} closing ${closing_tag} but only ${opening_count} opening tags in ${name}. Removing orphaned closing tags."
        # Remove orphaned closing tags that appear after paragraph or other inline content
        body_content=$(echo "${body_content}" | sed "s|</p>${closing_tag}|</p>|g")
        body_content=$(echo "${body_content}" | sed "s|</b>${closing_tag}|</b>|g")
        body_content=$(echo "${body_content}" | sed "s|^${closing_tag}$||g")
      fi
    done
    
    # Clean up temporary HTML file
    rm -f "${temp_html}"
    
    # Write the markdown file using raw HTML injection
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
    
    # Validate the generated markdown file for HTML tag issues
    echo "Validating ${md} for HTML tag issues..."
    
    # Check for orphaned closing tags (closing tags without matching opening tags)
    validation_errors=0
    while IFS= read -r line_num; do
      line_content=$(sed -n "${line_num}p" "${md}")
      # Extract closing tags from this line
      closing_tags=$(echo "${line_content}" | grep -oE '</[a-z]+>' || true)
      
      for closing_tag in ${closing_tags}; do
        tag_name=$(echo "${closing_tag}" | sed 's|</||' | sed 's|>||')
        opening_tag="<${tag_name}"
        
        # Count opening and closing tags up to this line
        opening_count=$(head -n "${line_num}" "${md}" | grep -o "${opening_tag}" | wc -l | tr -d ' ')
        closing_count=$(head -n "${line_num}" "${md}" | grep -o "${closing_tag}" | wc -l | tr -d ' ')
        
        # If there are more closing tags than opening tags at this point, it's an error
        if [ "${closing_count}" -gt "${opening_count}" ]; then
          echo "ERROR: Orphaned ${closing_tag} found at line ${line_num} in ${md}"
          echo "  Line content: ${line_content}"
          validation_errors=$((validation_errors + 1))
        fi
      done
    done < <(grep -n '</' "${md}" | cut -d: -f1)
    
    # Check for unclosed opening tags (opening tags without matching closing tags)
    all_tags=$(grep -oE '<[a-z]+[^>]*>' "${md}" | grep -v '</' | sed 's|<||' | sed 's| .*||' | sed 's|>||' | sort | uniq)
    for tag_name in ${all_tags}; do
      # Skip self-closing tags and special tags
      if [[ "${tag_name}" =~ ^(br|hr|img|input|meta|link|[a-z]+[0-9]+)$ ]]; then
        continue
      fi
      
      opening_tag="<${tag_name}"
      closing_tag="</${tag_name}>"
      
      opening_count=$(grep -o "${opening_tag}" "${md}" | wc -l | tr -d ' ')
      closing_count=$(grep -o "${closing_tag}" "${md}" | wc -l | tr -d ' ')
      
      if [ "${opening_count}" -ne "${closing_count}" ]; then
        echo "ERROR: Tag mismatch in ${md}: ${opening_count} opening <${tag_name}> tags but ${closing_count} closing tags"
        validation_errors=$((validation_errors + 1))
      fi
    done
    
    if [ ${validation_errors} -gt 0 ]; then
      echo "WARNING: Found ${validation_errors} HTML validation error(s) in ${md}"
    else
      echo "✓ ${md} passed HTML validation"
    fi
    
    echo "* [${name}](./${name})" >> docs/reference/zopen-reference.md
  done

  # Commit it all back to the repo
  git config --global user.email "zosopentools@ibm.com"
  git config --global user.name "ZOS Open Tools"
  git add docs/*.md
  git add docs/*.xml
  git add docs/images/*.png
  git add docs/images/upstream/*
  git add docs/api/*
  git add docs/reference/*
  git commit -m "Updating docs/apis/reference"
  git status
  git pull --rebase
  git push origin
}

UpdateGithub
UpdateDocs
