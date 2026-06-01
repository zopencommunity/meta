#!/bin/bash
#
# Run only the UpdateDocs function from on_nightly.sh
# This script can be run locally without requiring multi-gitter
#
set -e

UpdateDocs() {
  # Update Progress page in documentation
  git clone git@github.com:zopencommunity/meta.git meta_update
  
  # Use a subshell to safely manage context switching and error catching
  (
    cd meta_update || exit 1

    # Generate the currency status
    ./tools/get_bump_status.sh docs/updatestatus.md

    # Generate the upstream status
    python3 ./tools/generate_zopencommunity_patch_report.py --report docs/upstreamstatus.md --images docs/images/upstream --start-date=2023-01-01
    python3 ./tools/generate_zopen_files_list.py -o docs/api/zopen_files.json
    python3 tools/getbinaries.py

    # Generate a view of the vulnerabilities in package releases
    python3 tools/create_vulnerability_doc.py --md-output-file docs/Vulnerabilities.md --xml-output-file docs/vulnerabilities_rss.xml

    set -x
    # Generate zopen API Reference
    mkdir -p docs/api docs/reference
    
    # Safely source .env if it exists
    if [ -f .env ]; then . ./.env; fi
    export ZOPEN_ROOTFS="na" 
    
    mkdir -p "man/man1/"
    zopen-help2man "man/man1/"

    cat <<EOF > docs/reference/zopen-reference.md
# zopen reference documentation
This page provides information about the zopen interface. Click on any of the zopen commands listed below to access the reference guide describing how to utilize that command.
EOF

    man_files=(man/man1/*.1)
    total_files=${#man_files[@]}
    temp_html=$(mktemp)

    for i in "${!man_files[@]}"; do
      man="${man_files[$i]}"
      name=$(basename "${man}" .1)
      md="docs/reference/${name}.md"
      
      # Determine previous and next files for navigation links
      prev_name="zopen-reference"
      next_name=""
      if [ "${i}" -gt 0 ]; then
        prev_name=$(basename "${man_files[$((i - 1))]}" .1)
      fi
      if [ $((i + 1)) -lt ${total_files} ]; then
        next_name=$(basename "${man_files[$((i + 1))]}" .1)
      fi
      
      # Generate temporary HTML from the man page
      groff -m mandoc -Thtml -Wall "${man}" > "${temp_html}"
      
      # Single-pass parsing: Cleans up text elements and safely strips empty anchors
      body_content=$(sed -n '/<body>/,/<\/body>/p' "${temp_html}" | sed '1d;$d' | sed -E '
        /<a href="#/d;
        s|<a name="[^"]*"></a>||g;
        /<br>$/d;
        /<hr>/d;
        s|<\/?(i|em|b|strong)>||g;
        s|</p> </td>|</p></td>|g;
        s|<table|\n<table|g;
        s|</table>|</table>\n|g;
        s|<tr|\n<tr|g;
        s|</tr>|</tr>\n|g;
        s|<td|\n<td|g;
        s|</td>|</td>\n|g;
      ')

      # Protect structural slashes, isolate placeholders, and wrap in raw code blocks
      body_content=$(echo "${body_content}" | sed -E '
        s|https://|HTTPS_PLACEHOLDER|g;
        s|http://|HTTP_PLACEHOLDER|g;
        s|ftp://|FTP_PLACEHOLDER|g;
        s|([^<])/|\1\&#47;|g;
        s|HTTPS_PLACEHOLDER|https://|g;
        s|HTTP_PLACEHOLDER|http://|g;
        s|FTP_PLACEHOLDER|ftp://|g;
      ')

      # Convert bracketed plain links into anchor targets
      body_content=$(echo "${body_content}" | sed -E '
        s|<(https?://[^>[:space:]&]+)>|<a href="\1" target="_blank">\1</a>|g;
        s|<(ftp://[^>[:space:]&]+)>|<a href="\1" target="_blank">\1</a>|g;
      ')

      # Parse through Python to catch variables like <directory> and wrap them in raw <code> blocks
      body_content=$(printf '%s\n' "${body_content}" | python3 -c '
import re
import sys

text = sys.stdin.read()
VALID_TAGS = {"p", "b", "i", "em", "strong", "pre", "code", "table", "tr", "td", "h1", "h2", "h3", "a", "div", "br", "hr"}

def process_brackets(match):
    token = match.group(0)
    is_closing = token.startswith("</")
    tag_name = token[2:-1] if is_closing else token[1:-1]
    tag_base = tag_name.split()[0].lower()

    if tag_base in VALID_TAGS:
        return token
        
    if is_closing:
        return f"<code></{tag_name}></code>"
    else:
        return f"<code><{tag_name}></code>"

pattern = re.compile(r"</?[a-zA-Z0-9_| /:-]+>")
print(pattern.sub(process_brackets, text), end="")
')

      # Inject target="_blank" into remaining pre-existing anchor href paths safely
      body_content=$(python3 -c "import sys, re; text = sys.stdin.read(); print(re.sub(r'<a href=\"([^\"]+)\"(?!.*target=)', r'<a href=\"\1\" target=\"_blank\"', text))" <<< "${body_content}")

      # Remove HTML entities
      body_content=$(echo "${body_content}" | sed -E '
        s/&minus;/-/g
        s/&rsquo;/'\''/g
        s/&lsquo;/'\''/g
        s/&rdquo;/"/g
        s/&ldquo;/"/g
        s/&nbsp;/ /g
        s/&/\&/g
        s/</</g
        s/>/>/g
        s/"/"/g
      ')

      # Build non-breaking navigation block header structures
      nav_links='<div class="header-with-back"><div class="link" style="float: left;"><a href="./'"${prev_name}.md"'">← Previous</a></div>'
      if [ -n "${next_name}" ]; then
        nav_links="${nav_links}<div class='link' style='float: right;'><a href='./${next_name}.md'>Next →</a></div>"
      fi
      nav_links="${nav_links}<div style=\"clear: both;\"></div></div>"
      
      # Write out final documentation files within a solid layout wrapper
      cat <<EOF > "${md}"
<div v-pre class="man-page-content">

${nav_links}

${body_content}

</div>
EOF
      
      # Quick-look general file validation check
      opening_count=$(grep -o "<div" "${md}" | wc -l | tr -d ' ')
      closing_count=$(grep -o "</div" "${md}" | wc -l | tr -d ' ')
      if [ "${opening_count}" -ne "${closing_count}" ]; then
         echo "WARNING: Root layout tag asymmetry detected in ${md} (${opening_count} open vs ${closing_count} close)"
      fi

      echo "* [${name}](./${name}.md)" >> docs/reference/zopen-reference.md
    done

    rm -f "${temp_html}"

    # Commit phase
    git config --global user.email "zosopentools@ibm.com"
    git config --global user.name "ZOS Open Tools"
    git add docs/*.md docs/*.xml docs/images/ docs/api/ docs/reference/
    git commit -m "Updating docs/apis/reference"
    git pull --rebase
    git push origin
  )
}

echo "Running UpdateDocs function..."
UpdateDocs
echo "UpdateDocs completed successfully!"
echo ""
echo "Starting VitePress dev server in meta_update..."
cd meta_update/docs
npm install
npm run docs:dev

# Made with Bob
