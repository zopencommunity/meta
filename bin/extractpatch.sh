#!/bin/sh
#
# extract a patch out of a patch set with the form:
#   <relative-file-name>:<line-number>, e.g.
#   crypto/ppccap.c:209 
#
set +x
if [ $# -ne 2 ]; then
	echo "Syntax: $0 <patch> <patch-set>" 
	exit 4
fi
patch="$1"
patchset="$2"

file=${patch%%:*}
line=${patch##*:}

start=`grep -n '^---' "${patchset}" | grep "${file}"` 
startfileline=${start%%:*}
if [ "${startfileline}x" = "x" ]; then
	echo "Could not find patch set ${patchset}" 
	exit 4
fi

start=`tail +${startfileline} "${patchset}" | grep -n "@@ -${line},"`
relativestartpatchline=${start%%:*}
if [ "${relativestartpatchline}x" = "x" ]; then
	echo "Could not find patch set ${patchset}, line ${line}" 
	exit 4
fi
startpatchline=$((startfileline+relativestartpatchline))
startsearchline=$((startpatchline+1))

end=`tail +${startsearchline} "${patchset}" | grep -n "@@ -"`
relativeendpatchline=${end%%:*}
if [ "${relativeendpatchline}x" = "x" ]; then
	endpatchline=`wc -l "${patchset}" | awk '{ print $1 }'`
	relativeendpatchline=$((endpatchline-startpatchline+1))
fi

tail +${startpatchline} "${patchset}" | head -${relativeendpatchline}
