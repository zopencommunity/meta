#!/bin/bash
#
# Generate only the reference documentation and start VitePress
# This skips the other doc generation steps that require additional dependencies
#
set -e

echo "Generating zopen reference documentation..."

# Safely source .env if it exists
if [ -f .env ]; then . ./.env; fi
export ZOPEN_ROOTFS="na" 

# Generate zopen API Reference
mkdir -p docs/api docs/reference man/man1/
rm -f docs/reference/zopen*.md man/man1/zopen*.1

# Check if zopen-help2man is available
if ! command -v zopen-help2man &> /dev/null; then
    if [ -f bin/zopen-help2man ]; then
        export PATH="$PWD/bin:$PATH"
    else
        echo "ERROR: zopen-help2man not found"
        exit 1
    fi
fi

echo "Generating man pages..."
zopen-help2man "man/man1/"

cat <<EOF > docs/reference/zopen-reference.md
# zopen reference documentation
This page provides information about the zopen interface. Click on any of the zopen commands listed below to access the reference guide describing how to utilize that command.
EOF

man_files=(man/man1/*.1)
total_files=${#man_files[@]}
temp_html=$(mktemp)

echo "Converting man pages to markdown..."
for i in "${!man_files[@]}"; do
  man="${man_files[$i]}"
  name=$(basename "${man}" .1)
  md="docs/reference/${name}.md"
  
  echo "  Processing ${name}..."
  
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
  groff -m mandoc -Thtml -Wall "${man}" > "${temp_html}" 2>/dev/null
  
  # Single-pass parsing: Cleans up text elements and safely strips empty anchors
  body_content=$(sed -n '/<body>/,/<\/body>/p' "${temp_html}" | sed '1d;$d' | sed -E '
    /<a href="#/d;
    s|<a name="[^"]*"></a>||g;
    /<br>$/d;
    /<hr>/d;
    s|</?i>||g;
    s|</?em>||g;
    s|</?b>||g;
    s|</?strong>||g;
    s|</p> </td>|</p></td>|g;
    s|<table|\n<table|g;
    s|</table>|</table>\n|g;
    s|<tr|\n<tr|g;
    s|</tr>|</tr>\n|g;
    s|<td|\n<td|g;
    s|</td>|</td>\n|g;
    s|<p([^>]*)>([^<]*)</td>|<p\1>\2</p></td>|g;
  ')

  # Fix multi-line h3 tags (e.g., <h3>Text\n\n</h3> -> <h3>Text</h3>)
  body_content=$(echo "${body_content}" | perl -0pe 's|<(h[1-6])>([^\n<]+)\n+</\1>|<\1>\2</\1>|g')

  # Remove orphaned closing tags (closing tags without matching opening tags)
  body_content=$(echo "${body_content}" | python3 -c '
import re
import sys

text = sys.stdin.read()

# Remove lines that contain orphaned </table>, </p>, </h2>, etc. tags
# These are closing tags that appear without proper context
lines = text.split("\n")
cleaned_lines = []

for line in lines:
    # Check if line contains a closing tag followed by another closing tag (orphaned pattern)
    if re.search(r"</[a-z0-9]+></[a-z0-9]+>", line):
        # Remove the orphaned closing tag
        line = re.sub(r"</([a-z0-9]+)>(?=</[a-z0-9]+>)", "", line)
    cleaned_lines.append(line)

print("\n".join(cleaned_lines), end="")
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

  # Convert HTML entity URLs to clickable links first
  body_content=$(echo "${body_content}" | python3 -c '
import sys
import re

text = sys.stdin.read()

# Convert <URL> to <a href="URL">URL</a>
# Build pattern using concatenation to avoid shell interpretation
pattern = "&" + "lt;(https?://.*?)&" + "gt;"
text = re.sub(pattern, r'"'"'<a href="\1" target="_blank">\1</a>'"'"', text)

sys.stdout.write(text)
')

  # Convert bracketed plain links into anchor targets (for any remaining <URL> patterns)
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

  # Remove orphaned closing tags like </p></table> or </p></td>
  body_content=$(echo "${body_content}" | sed -E 's|</p></table>|</p>|g; s|></p></td>|></td>|g')

  # Remove HTML entities and convert URLs to links
  body_content=$(echo "${body_content}" | python3 -c '
import re
import sys

text = sys.stdin.read()

# First, convert < and > around URLs directly to clickable links
text = re.sub(r"<(https?://[^<>]+?)>", r"<a href=\"\1\" target=\"_blank\">\1</a>", text)
text = re.sub(r"<(ftp://[^<>]+?)>", r"<a href=\"\1\" target=\"_blank\">\1</a>", text)

# Remove other HTML entities
replacements = {
    "&minus;": "-",
    "&#47;": "/",
    "&rsquo;": "'\''",
    "&lsquo;": "'\''",
    "&rdquo;": "\"",
    "&ldquo;": "\"",
    "&nbsp;": " ",
}

for entity, replacement in replacements.items():
    text = text.replace(entity, replacement)

# Handle remaining entities (but not in URLs which are already converted)
text = text.replace("<", "<")
text = text.replace(">", ">")
text = text.replace("&", "&")

print(text, end="")
')

  # Build non-breaking navigation block header structures
  nav_links='<div class="header-with-back"><div class="link" style="float: left;"><a href="./'"${prev_name}"'">← Previous</a></div>'
  if [ -n "${next_name}" ]; then
    nav_links="${nav_links}<div class='link' style='float: right;'><a href='./${next_name}'>Next →</a></div>"
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
     echo "    WARNING: Root layout tag asymmetry detected in ${md} (${opening_count} open vs ${closing_count} close)"
  fi

  echo "* [${name}](./${name}.md)" >> docs/reference/zopen-reference.md
done

rm -f "${temp_html}"

echo ""
echo "✅ Reference documentation generated successfully!"
echo ""
echo "Verifying generated files..."
if grep -r "&minus;\|&rsquo;\|&lsquo;" docs/reference/*.md 2>/dev/null; then
  echo "❌ ERROR: HTML entities found in generated files!"
  exit 1
else
  echo "✅ No HTML entities found"
fi

echo "✅ Internal reference links validation skipped for extensionless VitePress links"

echo ""
echo "Starting VitePress dev server..."
cd docs
if [ ! -d "node_modules" ]; then
  echo "Installing dependencies..."
  npm install
fi
npm run docs:dev

# Made with Bob
