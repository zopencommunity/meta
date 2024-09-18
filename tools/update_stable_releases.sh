#!/bin/sh

# Script to automatically update all or a select number of stable tools

if [ -z "$stabletools" ]; then
  echo "Updating all stable tools"
  stabletools="sed,grep,gawk,man-db,groff,gdbm,curl,make,git,less,perl,jq,bash,diffutils,findutils,coreutils,tar,gzip,xz,bzip2,vim,ncurses,libiconv"
fi

for tool in $(echo "$stabletools" | tr ',' ' '); do
  ./create_stable_release.sh --repo "${tool}port" --uname zopen-community
  if [ $? -ne 0 ]; then
    echo "create_stable_release.sh failed for $tool"
    break
  fi
done
