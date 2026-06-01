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
         echo "WARNING: Root layout tag asymmetry detected in ${md} (${opening_count} open vs ${closing_count} close)"
      fi

      echo "* [${name}](./${name}.md)" >> docs/reference/zopen-reference.md
    done

    # Commit phase
    git config --global user.email "zosopentools@ibm.com"
    git config --global user.name "ZOS Open Tools"
    git add docs/*.md docs/*.xml docs/images/ docs/api/ docs/reference/
    git commit -m "Updating docs/apis/reference"
    git pull --rebase
    git push origin
  )
}

UpdateGithub
UpdateDocs