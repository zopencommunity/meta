#!/bin/sh
#
# General purpose build script for ZOSOpenTools ports
# 
# PORT_ROOT must be defined to the root directory of the cloned ZOSOpenTools port 
# Either PORT_TARBALL or PORT_GIT must be defined (but not both). This indicates where to pull source from
# 
# Each dependent tool will have it's corresponding environment set up by sourcing .env from the installation
# directory. The .env will be searched for in $HOME/zot/prod/<tool>, /usr/bin/zot/prod/<tool>, $HOME/zot/boot/<tool>

checkdeps() {
	deps=$*
	fail=false
	for dep in $deps; do
		if ! [ -r "${HOME}/zot/prod/${dep}/.env" ] && ! [ -r "${HOME}/zot/boot/${dep}/.env" ] && ! [ -r "/usr/bin/zot/${dep}/.env" ] ; then
			echo "Unable to find .env for dependency ${dep}" >&2
			fail=true
		fi
	done
	if $fail ; then
		exit 4
	fi
}

setdepsenv() {
	for dep in $deps; do
		if [ -r "${HOME}/zot/prod/${dep}/.env" ]; then
			cd "${HOME}/zot/prod/${dep}"
		elif [ -r "/usr/bin/zot/${dep}/.env" ] ; then
			cd "/usr/bin/zot/${dep}"
		elif [ -r "${HOME}/zot/boot/${dep}/.env" ]; then
			cd "${HOME}/zot/boot/${dep}"
		else 
			echo "Internal error. Unable to find .env but earlier check should have caught this" >&2
			exit 16
		fi
		. ./.env
	done
}

#
# 'Quick' way to find untagged non-binary files. If the list of extensions grows, something more 
# elegant is required
#
tagtree() {
	dir="$1"
	find "${dir}" -name "*.pdf" -o -name "*.png" ! -type d | xargs chtag -b
	find "${dir}" ! -type d | xargs chtag -qp | awk '{ if ($1 == "-") { print $4; }}' | xargs chtag -tcISO8859-1
}
		
gitclone() {
	if ! git --version >$STDOUT 2>$STDERR ; then
		echo "git is required to download from the git repo" >&2
		exit 4
	fi
	gitname=$(basename $PORT_GIT_URL)
	dir=${gitname%%.*}
	if [ -d "${dir}" ]; then
		echo "Using existing git clone'd directory ${dir}" >$STDERR
	else
		echo "Clone and create ${dir}" >$STDERR
		if ! git clone "${PORT_GIT_URL}" 2>$STDERR; then
                        echo "Unable to clone ${gitname} from ${PORT_GIT_URL}" >&2
                        exit 4
		fi
		tagtree "${dir}"
	fi
	echo "${dir}"
}

extracttarball() {
	tarballz="$1"
	dir="$2"

	ext=${tarballz##*.}
	if [ "${ext}x" = "xzx" ]; then
		if ! xz -d "${tarballz}"; then
			echo "Unable to use xz to decompress ${tarballz}" >&2
			exit 4
		fi
		tarball=${tarballz%%.xz}
	elif [ "${ext}x" = "gzx" ]; then 
		if ! gunzip "${tarballz}"; then
			echo "Unable to use gunzip to decompress ${tarballz}" >&2
			exit 4
		fi
		tarball=${tarballz%%.gz}
	else
		echo "Extension ${ext} is an unsupported compression technique. Add code" >&2
		exit 8
	fi

	tar -xf "${tarball}" 2>&1 >/dev/null | grep -v FSUM7171 >$STDERR
	if [ $? -gt 1 ]; then
		echo "Unable to untar ${tarball}" >&2
		exit 4
	fi
	rm -f "${tarball}"

	# tar will incorrectly tag files as 1047, so just clear the tags
	chtag -R -r "${dir}"

	tagtree "${dir}"
	cd "${dir}" || exit 99
	if [ -f .gitattributes ]; then
		echo "No support for existing .gitattributes file. Write some code" >&2
		exit 4
	fi
	if ! echo "* text working-tree-encoding=ISO8859-1" >.gitattributes ; then
		echo "Unable to create .gitattributes for tarball" >&2
		exit 4
	fi

	if ! iconv -f IBM-1047 -tISO8859-1 <.gitattributes >.gitattrascii || ! chtag -tcISO8859-1 .gitattrascii || ! mv .gitattrascii .gitattributes ; then
		echo "Unable to make .gitattributes ascii for tarball" >&2
		exit 4
	fi

	files=$(find . ! -name "*.pdf" ! -name "*.png" ! -type d)
	if ! git init . >$STDERR || ! git add ${files} >$STDERR || ! git commit --allow-empty -m "Create Repository for patch management" >$STDERR ; then
		echo "Unable to initialize git repository for tarball" >&2
		exit 4
	fi
	# Having the directory git-managed exposes some problems in the current git for software like autoconf,
	# so move .git to the side and just use it for applying patches
	# (you will also need to move it back to do a 'git diff' on any new patches you want to develop)
	mv .git .git-for-patches
}

downloadtarball() {
	if ! curl --version >$STDOUT 2>$STDERR ; then
		echo "curl is required to download a tarball" >&2
		exit 4
	fi
	tarballz=$(basename $PORT_TARBALL_URL)
	dir=${tarballz%%.tar.*} 
	if [ -d "${dir}" ]; then
		echo "Using existing tarball directory ${dir}" >&2
	else
		if ! curl -L -0 -o "${tarballz}" "${PORT_TARBALL_URL}" >$STDOUT 2>$STDERR; then
			if [ $(wc -c "${tarballz}" | awk '{print $1}') -lt 1024 ]; then
				cat "${tarballz}" >$STDERR
			fi
			echo "Unable to download ${tarballz} from ${PORT_TARBALL_URL}" >&2
			exit 4
		fi 
		# curl tags the file as ISO8859-1 (oops) so the tag has to be removed
		chtag -b "${tarballz}"

		extracttarball "${tarballz}" "${dir}"
	fi
	echo "${dir}"
}

#
# This function applies patches previously created.
# To _create_ a patch, do the following:
#  -If required, create a sub-directory in the ${PORT_ROOT}/patches directory called PR<x>, where <x> indicates 
#   the order of the pull-request (e.g. if PR3 needs to be applied before your PR, make sure your PR
#   is at least PR4)
#  -Create, or update the PR readme called ${PORT_ROOT}/patches/PR<x>/README.md describing this patch
#  -For each file you have changed:
#   -cd to the code directory and perform git diff <filename> >${PORT_ROOT}/patches/PR<x>/<filename>.patch
#
applypatches() {
	if [ "${PORT_TARBALL}x" != "x" ] ; then
		tarballz=$(basename $PORT_TARBALL_URL)
		code_dir="${PORT_ROOT}/${tarballz%%.tar.*}"
	else 
		gitname=$(basename $PORT_GIT_URL)
		code_dir="${PORT_ROOT}/${gitname%%.*}"
	fi

	patch_dir="${PORT_ROOT}/patches"
	if ! [ -d "${patch_dir}" ] ; then
		echo "${patch_dir} does not exist - no patches to apply" >$STDERR
		return 0
	fi

	if [ -d "${code_dir}/.git-for-patches" ] && ! [ -d "${code_dir}/.git" ]; then
		mv "${code_dir}/.git-for-patches" "${code_dir}/.git" || exit 99
	fi

	if ! [ -d "${code_dir}/.git" ] ; then
		echo "applypatches requires ${code_dir} to be git-managed but there is no .git directory. No patches applied" >&2
		return 0
	fi

	patches=`(cd ${patch_dir} && find . -name "*.patch")`
	results=`(cd ${code_dir} && git status --porcelain --untracked-files=no 2>&1)`
	failedcount=0
	if [ "${results}" != '' ]; then
		echo "Existing Changes are active in ${code_dir}." >$STDERR
		echo "To re-apply patches, perform a git reset on ${code_dir} prior to running applypatches again." >$STDERR
	else
		for patch in $patches; do
			p="${patch_dir}/${patch}"

			patchsize=`wc -c "${p}" | awk '{ print $1 }'`
			if [ $patchsize -eq 0 ]; then
				echo "Warning: patch file ${p} is empty - nothing to be done" >$STDERR
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
	fi
	mv "${code_dir}/.git" "${code_dir}/.git-for-patches" || exit 99

	if [ $failedcount -ne 0 ]; then
		exit $failedcount
	fi
	return 0
}

#
# Start of 'main'
#
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
PORT_CHECK_RESULTS="${PORT_ROOT}/portchk.sh"
PORT_CREATE_ENV="${PORT_ROOT}/portcrtenv.sh"
LOG_PFX=$(date '+%Y%m%d_%T')

#
# Temporary - support PORT_TARBALL / PORT_GIT _and_ PORT_TYPE until I switch everything over to use PORT_TYPE
# To specify a URL, you can either be specific (e.g. PORT_TARBALL_URL or PORT_GIT_URL) or you can be general (e.g. PORT_URL)
# and to specify DEPS, you can either be specific (e.g. PORT_TARBALL_DEPS or PORT_GIT_DEPS) or you can be general (e.g. PORT_DEPS).
# This flexibility is nice so that for software packages that support both types (e.g. gnu make), you can provide all of
# PORT_TARBALL_URL, PORT_TARBALL_DEPS, PORT_GIT_URL, PORT_GIT_DEPS in your environment set up and then specify the type using
# PORT_TYPE=GIT|URL (e.g. only one line needs to be changed).
# For software packages that only support one type, you can just specify PORT_URL, PORT_DEPS, and PORT_TYPE.
#
if [ "${PORT_TARBALL}x" = "x" ] && [ "${PORT_GIT}x" = "x" ]; then
	if [ "${PORT_TYPE}x" = "x" ]; then
		echo "One of PORT_TARBALL, PORT_GIT, or PORT_TYPE needs to be defined to specify where to pull source from" >&2
		exit 4
	elif [ "${PORT_TYPE}x" = "TARBALLx" ]; then
		export PORT_TARBALL='Y'
		if [ "${PORT_TARBALL_URL}x" = "x" ]; then 
			export PORT_TARBALL_URL="${PORT_URL}"
		fi
		if [ "${PORT_TARBALL_DEPS}x" = "x" ]; then 
			export PORT_TARBALL_DEPS="${PORT_DEPS}"
		fi
	elif [ "${PORT_TYPE}x" = "GITx" ]; then
		export PORT_GIT='Y'
		if [ "${PORT_GIT_URL}x" = "x" ]; then
			export PORT_GIT_URL="${PORT_URL}"
		fi

		if [ "${PORT_GIT_DEPS}x" = "x" ]; then
			export PORT_GIT_DEPS="${PORT_DEPS}"
		fi
	else
		echo "PORT_TYPE must be one of TARBALL or GIT. PORT_TYPE=${PORT_TYPE} was specified" >&2
		exit 4
	fi
fi

if [ "${PORT_ROOT}x" = "x" ]; then
	echo "PORT_ROOT needs to be defined to the root directory of the tool being ported" >&2
	exit 4
fi
if ! [ -d "${PORT_ROOT}" ]; then
	echo "PORT_ROOT ${PORT_ROOT} is not a directory" >&2
	exit 8
fi

if ! [ -x "${PORT_CHECK_RESULTS}" ]; then
	echo "${PORT_CHECK_RESULTS} script needs to be provided to check the results. Exit with 0 if the build can be installed" >&2
	exit 4
fi
if ! [ -x "${PORT_CREATE_ENV}" ]; then
	echo "${PORT_CREATE_ENV} script needs to be provided to define the environment" >&2
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
ca="${myparentdir}/cacert.pem"
if ! [ -r "${ca}" ]; then
	echo "Internal Error. Certificate ${ca} is required" >&2
	exit 4
fi
if [ "${PORT_TARBALL}x" != "x" ]; then
	if [ "${PORT_TARBALL_URL}x" = "x" ]; then
		echo "PORT_URL or PORT_TARBALL_URL needs to be defined to the root directory of the tool being ported" >&2
		exit 4
	fi
	if [ "${PORT_TARBALL_DEPS}x" = "x" ]; then
		echo "PORT_DEPS or PORT_TARBALL_DEPS needs to be defined to the ported tools this depends on" >&2
		exit 4
	fi
	export SSL_CERT_FILE="${ca}"
	deps="${PORT_TARBALL_DEPS}"
fi
if [ "${PORT_GIT}x" != "x" ]; then
	if [ "${PORT_GIT_URL}x" = "x" ]; then
		echo "PORT_URL or PORT_GIT_URL needs to be defined to the root directory of the tool being ported" >&2
		exit 4
	fi
	if [ "${PORT_GIT_DEPS}x" = "x" ]; then
		echo "PORT_DEPS or PORT_GIT_DEPS needs to be defined to the ported tools this depends on" >&2
		exit 4
	fi
	export GIT_SSL_CAINFO="${ca}"
	deps="${PORT_GIT_DEPS}"
fi

checkdeps ${deps}

#
# For the compilers and corresponding flags, you need to either specify both the compiler and flag, or neither
# since the flags are not compatible across compilers, and only the xlclang and xlclang++ compilers are used by default
#

if [ "${CC}x" = "x" ] && [ "${CFLAGS}x" != "x" ]; then
	echo "Either specify both CC and CFLAGS or neither, but not just one" >&2
	exit 4
fi
if [ "${CXX}x" = "x" ] && [ "${CXXFLAGS}x" != "x" ]; then
	echo "Either specify both CXX and CXXFLAGS or neither, but not just one" >&2
	exit 4
fi

if [ "${CC}x" = "x" ]; then
	export CC=xlclang
	BASE_CFLAGS="-qascii -DNSIG=39 -D_XOPEN_SOURCE=600 -D_ALL_SOURCE -D_AE_BIMODAL=1 -D_ENHANCED_ASCII_EXT=0xFFFFFFFF"
	export CFLAGS="${BASE_CFLAGS} ${PORT_EXTRA_CFLAGS}"
fi

if [ "${CXX}x" = "x" ]; then
	export CXX=xlclang++
	BASE_CXXFLAGS="-+ -qascii -DNSIG=39 -D_XOPEN_SOURCE=600 -D_ALL_SOURCE -D_AE_BIMODAL=1 -D_ENHANCED_ASCII_EXT=0xFFFFFFFF"
	export CXXFLAGS="${BASE_CXXFLAGS} ${PORT_EXTRA_CXXFLAGS}"
fi

if [ "${LDFLAGS}x" = "x" ]; then
	BASE_LDFLAGS="" 
	export LDFLAGS="${BASE_LDFLAGS} ${PORT_EXTRA_LDFLAGS}"
fi

setdepsenv $deps

cd "${PORT_ROOT}" || exit 99

if [ "${PORT_GIT}x" != "x" ]; then
	echo "Checking if git directory already cloned"
	dir=$( gitclone )
fi	

if [ "${PORT_TARBALL}x" != "x" ]; then
	echo "Checking if tarball already downloaded"
	dir=$( downloadtarball )
fi	

if [ "${PORT_BOOTSTRAP}x" = "x" ]; then
	export PORT_BOOTSTRAP="./bootstrap"
fi
if [ "${PORT_BOOTSTRAP_OPTS}x" = "x" ]; then
	export PORT_BOOTSTRAP_OPTS=""
fi
if [ "${PORT_CONFIGURE}x" = "x" ]; then
	export PORT_CONFIGURE="./configure"
fi
if [ "${PORT_CONFIGURE_OPTS}x" = "x" ]; then
	PROD_DIR="${HOME}/zot/prod/${dir}"
	export PORT_CONFIGURE_OPTS="--prefix=${PROD_DIR}"
fi
if [ "${PORT_MAKE}x" = "x" ]; then
	export PORT_MAKE=$(whence make)
fi
if [ "${PORT_MAKE_OPTS}x" = "x" ]; then
	export PORT_MAKE_OPTS=""
fi
if [ "${PORT_CHECK}x" = "x" ]; then
	export PORT_CHECK=$(whence make)
fi
if [ "${PORT_CHECK_OPTS}x" = "x" ]; then
	export PORT_CHECK_OPTS="check"
fi
if [ "${PORT_INSTALL}x" = "x" ]; then
	export PORT_INSTALL=$(whence make)
fi
if [ "${PORT_INSTALL_OPTS}x" = "x" ]; then
	export PORT_INSTALL_OPTS="install"
fi

applypatches 

cd "${PORT_ROOT}/${dir}" || exit 99

# Proceed to build

if [ "${PORT_BOOTSTRAP}x" != "skipx" ] && [ -x "${PORT_BOOTSTRAP}" ]; then
	echo "Bootstrap"
	if [ -r bootstrap.success ] ; then
		echo "Using previous successful bootstrap" >&2
	else
		bootlog="${LOG_PFX}_bootstrap.log"
		if ! "${PORT_BOOTSTRAP}" ${PORT_BOOTSTRAP_OPTS} >${bootlog} 2>&1 ; then
			echo "Bootstrap failed. Log: ${bootlog}" >&2 
			exit 4
		fi
		touch bootstrap.success
	fi
fi

if [ "${PORT_CONFIGURE}x" != "skipx" ] && [ -x "${PORT_CONFIGURE}" ]; then
	echo "Configure"
	if [ -r config.success ] ; then
		echo "Using previous successful configuration" >&2
	else
		configlog="${LOG_PFX}_config.log"
		if ! "${PORT_CONFIGURE}" ${PORT_CONFIGURE_OPTS} >"${configlog}" 2>&1 ; then
			echo "Configure failed. Log: ${configlog}" >&2
			exit 4
		fi
		touch config.success
	fi
fi

makelog="${LOG_PFX}_make.log"
if [ "${PORT_MAKE}x" != "skipx" ] && [ -x "${PORT_MAKE}" ]; then
	echo "Make"
	if ! "${PORT_MAKE}" ${PORT_MAKE_OPTS} >"${makelog}" 2>&1 ; then
		echo "Make failed. Log: ${makelog}" >&2
		exit 4
	fi
fi
	 
checklog="${LOG_PFX}_check.log"
if [ "${PORT_CHECK}x" != "skipx" ] && [ -x "${PORT_CHECK}" ]; then
	echo "Check"
	"${PORT_CHECK}" ${PORT_CHECK_OPTS} >"${checklog}" 2>&1
	if ! "${PORT_CHECK_RESULTS}" "./${dir}" "${LOG_PFX}"; then 
		echo "Check failed. Log: ${checklog}" >&2
		exit 4
	fi
fi

if [ "${PORT_INSTALL}x" != "skipx" ] && [ -x "${PORT_INSTALL}" ]; then
	echo "Install"
	installlog="${LOG_PFX}_install.log"
	if ! "${PORT_INSTALL}" ${PORT_INSTALL_OPTS} >"${installlog}" 2>&1 ; then
		echo "Install failed. Log: ${installlog}" >&2
		exit 4
	fi
	if ! "${PORT_CREATE_ENV}" "${PROD_DIR}" "${LOG_PFX}"; then 
		echo "Environment creation failed." >&2
		exit 4
	fi
fi
