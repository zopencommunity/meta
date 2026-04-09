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

#  python3 tools/create_cve_json.py --verbose --output-file docs/api/zopen_vulnerability.json

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

# Generate markdown pages with embedded HTML
for man in man/man1/*.1;
do
  base=${man##*/};
  name=${base%%.1};
  md="docs/reference/${name}.md";
  
  # Generate temporary HTML
  groff -m mandoc -Thtml -Wall "${man}" > "${name}.tmp.html";
  
  # Create the MD file with frontmatter and extracted body content
  cat <<EOF > "${md}"
---
layout: doc
---

# ${name}

<div class="man-page">
EOF

  # Extract content between <body> and </body>
  sed -n '/<body>/,/<\/body>/p' "${name}.tmp.html" | sed 's/<body>//;s/<\/body>//' >> "${md}"
  
  echo "</div>" >> "${md}"
  echo "- [${name}](/reference/${name})" >> docs/reference/zopen-reference.md
  
  # Clean up temp file
  rm "${name}.tmp.html"
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
