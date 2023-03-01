#!/bin/sh

tools="curl,make,git,less,perl,jq,bash,diffutils,findutils,coreutils,tar,gzip,xz,bzip2,vim,ncurses"

for tool in $(echo "$tools" | tr ',' ' '); do
  ./boottool.sh --repo "${tool}port" --uname ZOSOpenTools
  if [ $? -ne 0 ]; then
    echo "boottool.sh failed for $tool"
    break
  fi
done
