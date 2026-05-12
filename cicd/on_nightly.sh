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
    body_content=$(sed -n '/<body>/,/<\/body>/p' "${temp_html}" | sed '1d;$d' | sed '/<a href="#/d' | sed '/<br>$/d' | sed '/<hr>/d')
    
    # Remove <i> and <em> tags to avoid Vue parsing issues
    body_content=$(echo "${body_content}" | sed 's|<i>||g' | sed 's|</i>||g' | sed 's|<em>||g' | sed 's|</em>||g')
    
    # Escape forward slashes in file paths (but not in HTML tags or URLs)
    # This regex matches forward slashes that are NOT preceded by < or : (to avoid breaking </tag> and URLs)
    body_content=$(echo "${body_content}" | sed 's|\([^<:]\)/|\1&#47;|g')
    
    # Convert URLs in angle brackets to proper HTML links with target="_blank"
    body_content=$(echo "${body_content}" | sed 's|<\(https\?://[^>]*\)>|<a href="\1" target="_blank">\1</a>|g' | sed 's|<\(ftp://[^>]*\)>|<a href="\1" target="_blank">\1</a>|g')
    
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
