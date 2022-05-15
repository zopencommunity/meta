#!/bin/sh
#
# General purpose utility to manage patches for a ZOSOpenTools port
# 
# PORT_ROOT must be defined to the root directory of the ZOSOpenTools port 
# Either PORT_TARBALL or PORT_GIT must be defined (but not both). This indicates where patches will be managed from

myparentdir=$( cd $( dirname $0 )/../; echo $PWD )

set +x
if [ "$1" = "-v" ]; then
	verbose=true
	STDOUT="/dev/fd1"
	STDERR="/dev/fd2"
else
	STDOUT="/dev/null"
	STDERR="/dev/null"
	verbose=false
fi
LOG_PFX=$(date '+%Y%m%d_%T')

if [ "${PORT_ROOT}x" = "x" ]; then
	echo "PORT_ROOT needs to be defined to the root directory of the tool being ported" >&2
	exit 4
fi

if [ "${PORT_TARBALL}x" = "x" ] && [ "${PORT_GIT}x" = "x" ]; then
	echo "One of PORT_TARBALL or PORT_GIT needs to be defined to specify where to pull source from" >&2
	exit 4
fi
if [ "${PORT_TARBALL}x" != "x" ] && [ "${PORT_GIT}x" != "x" ]; then
	echo "Only one of PORT_TARBALL or PORT_GIT should be defined to specify where to pull source from (both are defined)" >&2
	exit 4
fi

if [ "${PORT_TARBALL}x" != "x" ] ; then
        tarballz=$(basename $PORT_TARBALL_URL)
        code_dir="${PORT_ROOT}/${tarballz%%.tar.gz}"
else 
	gitname=$(basename $PORT_GIT_URL)
        code_dir="${PORT_ROOT}/${gitname%%.*}"
fi

if ! [ -d "${code_dir}/.git" ] ; then
	echo "managepatches requires ${code_dir} to be git-managed but there is no .git directory" >&2
	exit 4
fi

patch_dir="${PORT_ROOT}/patches"
if ! [ -d "${patch_dir}" ] ; then
	echo "${patch_dir} does not exist - no patches to apply"
	exit 0
fi


patches=`cd ${patch_dir} && find . -name "*.patch"`
results=`(cd ${code_dir} && git status --porcelain --untracked-files=no 2>&1)`
if [ "${results}" != '' ]; then
  echo "Existing Changes are active in ${code_dir}. To re-apply patches, perform a git reset on ${code_dir} prior to running managepatches again."
  exit 0
fi

failedcount=0
for patch in $patches; do
	p="${patch_dir}/${patch}"

	patchsize=`wc -c "${p}" | awk '{ print $1 }'`
	if [ $patchsize -eq 0 ]; then
		echo "Warning: patch file ${p} is empty - nothing to be done" >&2
	else
		echo "Applying ${p}"
		out=`(cd ${code_dir} && git apply "${p}" 2>&1)`
		if [ $? -gt 0 ]; then
			echo "Patch of make tree failed (${p})." >&2
			echo "${out}" >&2
			failedcount=$((failedcount+1))
		fi
	fi
done

exit $failedcount
