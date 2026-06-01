#!/bin/bash
set -e

export PATH="$PWD/bin:$PATH"
export ZOPEN_ROOTFS="na"

# Generate man pages
mkdir -p docs/api docs/reference man/man1/
rm -f docs/reference/zopen*.md man/man1/zopen*.1

echo "Generating man pages..."
zopen-help2man "man/man1/" 2>/dev/null || true

# Create Python script for URL conversion
cat > /tmp/convert_urls.py <<'PYSCRIPT'
import re
import sys

text = sys.stdin.read()

# Remove orphaned closing tags
lines = text.split("\n")
cleaned_lines = []

for line in lines:
    if re.search(r"</[a-z0-9]+></[a-z0-9]+>", line):
        line = re.sub(r"</([a-z0-9]+)>(?=</[a-z0-9]+>)", "", line)
    cleaned_lines.append(line)

text = "\n".join(cleaned_lines)

# Remove orphaned </table> tags
text = re.sub(r"</p></table>", "</p>", text)
text = re.sub(r"></p></td>", "></td>", text)

# Convert < and > around URLs directly to clickable links
text = re.sub(r"<(https?://[^<>]+?)>", r'<a href="\1" target="_blank">\1</a>', text)
text = re.sub(r"<(ftp://[^<>]+?)>", r'<a href="\1" target="_blank">\1</a>', text)

# Remove other HTML entities
replacements = {
    "&minus;": "-",
    "&#47;": "/",
    "&rsquo;": "'",
    "&lsquo;": "'",
    "&rdquo;": '"',
    "&ldquo;": '"',
    "&nbsp;": " ",
}

for entity, replacement in replacements.items():
    text = text.replace(entity, replacement)

# Handle remaining entities
text = text.replace("<", "<")
text = text.replace(">", ">")
text = text.replace("&", "&")

print(text, end="")
PYSCRIPT

# Now run the conversion from the main script
cat <<'EOF' > /tmp/convert_docs.sh
#!/bin/bash
set -e

cat <<'HEADER' > docs/reference/zopen-reference.md
# zopen reference documentation
This page provides information about the zopen interface. Click on any of the zopen commands listed below to access the reference guide describing how to utilize that command.
HEADER

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
  
  # Process the HTML
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

  # Remove orphaned closing tags and convert URLs to links
  body_content=$(echo "${body_content}" | python3 /tmp/convert_urls.py)

  # Build navigation
  nav_links='<div class="header-with-back"><div class="link" style="float: left;"><a href="./'"${prev_name}"'">← Previous</a></div>'
  if [ -n "${next_name}" ]; then
    nav_links="${nav_links}<div class='link' style='float: right;'><a href='./${next_name}'>Next →</a></div>"
  fi
  nav_links="${nav_links}<div style=\"clear: both;\"></div></div>"
  
  # Write output
  cat <<MDEOF > "${md}"
<div v-pre class="man-page-content">

${nav_links}

${body_content}

</div>
MDEOF
  
  echo "* [${name}](./${name}.md)" >> docs/reference/zopen-reference.md
done

rm -f "${temp_html}"
echo "✅ Reference documentation generated successfully!"
EOF

bash /tmp/convert_docs.sh
rm /tmp/convert_docs.sh /tmp/convert_urls.py

echo "Done!"

# Made with Bob
