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

  # Generate HTML and markdown pages
 for man in man/man1/*.1;
  do
    base=${man##*/};
    name=${base%%.1};
    html="docs/reference/${name}.html";
    md="docs/reference/${name}.md";
    
    # 1. Generate raw HTML from the man page
    groff -m mandoc -Thtml -Wall "${man}" > "${html}";
    
    # 2. Extract only the content between <body> and </body>
    # This avoids injecting full-document tags (<html>, <head>, <body>) into markdown
    body_content=$(sed -n '/<body>/,/<\/body>/p' "${html}" | sed '1d;$d' | sed '/<a href="#/d' | sed '/<br>$/d' | sed '/<hr>/d')
    
    # 3. Write the markdown file using raw HTML injection
    cat <<EOF > "${md}"
<div v-pre class="man-page-content">

${body_content}

</div>

<style scoped>
.man-page-content {
  padding: 20px;
  line-height: 1.6;
  overflow-x: auto;
  background: var(--vp-c-bg-soft);
}

.man-page-content :deep(h1) {
  text-align: left;
}

.man-page-content :deep(h2) {
  margin-top: 1.5rem;
}

.man-page-content :deep(table) {
  width: 100%;
  border-collapse: collapse;
  margin: 1rem 0;
}

.man-page-content :deep(pre) {
  background: var(--vp-c-bg-soft);
  padding: 1rem;
  border-radius: 8px;
  overflow-x: auto;
  white-space: pre-wrap;
}

.man-page-content :deep(p) {
  margin: 0.5rem 0;
}

.man-page-content :deep(a) {
  color: var(--vp-c-brand-1);
}
</style>
EOF
    
    echo "* [${name}](./${name})" >> docs/reference/zopen-reference.md
    
    # Keep the generated HTML artifact alongside the markdown reference page
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