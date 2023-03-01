#!/bin/sh

# Script to automatically update all or a select number of boot tools

if [ -z "$boottools" ]; then
  echo "Updating all boot tools"
  boottools="meta,curl,make,git,less,perl,jq,bash,diffutils,findutils,coreutils,tar,gzip,xz,bzip2,vim,ncurses"
fi

for tool in $(echo "$boottools" | tr ',' ' '); do
  ./boottool.sh --repo "${tool}port" --uname ZOSOpenTools
  if [ $? -ne 0 ]; then
    echo "boottool.sh failed for $tool"
    break
  fi
done
