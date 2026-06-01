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
  
  # Generate cleaned HTML from the man page
  body_content=$(groff -m mandoc -Thtml -Wall "${man}" | python3 tools/clean_man_html.py)

  # Build non-breaking navigation block header structures
  nav_links='<div class="header-with-back"><div class="link"><a href="./'"${prev_name}"'">← Previous</a></div>'
  if [ -n "${next_name}" ]; then
    nav_links="${nav_links}<div class='link'><a href='./${next_name}'>Next →</a></div>"
  fi
  nav_links="${nav_links}</div>"
  
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
