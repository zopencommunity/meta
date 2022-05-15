#!/bin/sh
#
# General purpose build script for ZOSOpenTools ports
# 
# PORT_ROOT must be defined to the root directory of the cloned ZOSOpenTools port 
# Either PORT_TARBALL or PORT_GIT must be defined (but not both). This indicates where to pull source from
# 
# Each dependent tool will have it's corresponding environment set up by sourcing .env from the installation
# directory. The .env will be searched for in $HOME/zot/prod/<tool>, /usr/zot/<tool>, $HOME/zot/boot/<tool>

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
PORT_CHECK="${PORT_ROOT}/portchk.sh"
PORT_CREATE_ENV="${PORT_ROOT}/portcrtenv.sh"
LOG_PFX=$(date '+%Y%m%d_%T')

if [ "${PORT_ROOT}x" = "x" ]; then
	echo "PORT_ROOT needs to be defined to the root directory of the tool being ported" >&2
	exit 4
fi
if ! [ -x "${PORT_CHECK}" ]; then
	echo "${PORT_CHECK} script needs to be provided to check the results. Exit with 0 if the build can be installed" >&2
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
if ! [ -f "${ca}" ]; then
	echo "Internal Error. Certificate ${ca} is required" >&2
	exit 4
fi
if [ "${PORT_TARBALL}x" != "x" ]; then
	if [ "${PORT_TARBALL_URL}x" = "x" ]; then
		echo "PORT_TARBALL_URL needs to be defined to the root directory of the tool being ported" >&2
		exit 4
	fi
	if [ "${PORT_TARBALL_DEPS}x" = "x" ]; then
		echo "PORT_TARBALL_DEPS needs to be defined to the ported tools this depends on" >&2
		exit 4
	fi
	export SSL_CERT_FILE="${ca}"
	deps="${PORT_TARBALL_DEPS}"
fi
if [ "${PORT_GIT}x" != "x" ]; then
	if [ "${PORT_GIT_URL}x" = "x" ]; then
		echo "PORT_GIT_URL needs to be defined to the root directory of the tool being ported" >&2
		exit 4
	fi
	if [ "${PORT_GIT_DEPS}x" = "x" ]; then
		echo "PORT_GIT_DEPS needs to be defined to the ported tools this depends on" >&2
		exit 4
	fi
	export GIT_SSL_CAINFO="${ca}"
	deps="${PORT_GIT_DEPS}"
fi

fail=false
for dep in $deps; do
	if ! [ -f "${HOME}/zot/prod/${dep}/.env" ] && ! [ -f "${HOME}/zot/boot/${dep}/.env" ] && ! [ -f "/usr/zot/${dep}/.env" ] ; then
		echo "Unable to find .env for dependency ${dep}" >&2
		fail=true
	fi
done
if $fail ; then
	exit 4
fi

if ! [ -d "${PORT_ROOT}" ]; then
	echo "PORT_ROOT ${PORT_ROOT} is not a directory" >&2
	exit 8
fi

BASE_CFLAGS="-DNSIG=39 -D_XOPEN_SOURCE=600 -D_ALL_SOURCE -qascii -D_AE_BIMODAL=1 -D_ENHANCED_ASCII_EXT=0xFFFFFFFF -qfloat=ieee"
BASE_CXXFLAGS="-+ -DNSIG=39 -D_XOPEN_SOURCE=600 -D_ALL_SOURCE -qascii -D_AE_BIMODAL=1 -D_ENHANCED_ASCII_EXT=0xFFFFFFFF -qfloat=ieee"
BASE_LDFLAGS="" 

export CC=xlclang
export CXX=xlclang++
export CFLAGS="${BASE_CFLAGS} ${PORT_EXTRA_CFLAGS}"
export CXXFLAGS="${BASE_CXXFLAGS} ${PORT_EXTRA_CXXFLAGS}"
export LDFLAGS="${BASE_LDFLAGS} ${PORT_EXTRA_LDFLAGS}"

for dep in $deps; do
	if [ -f "${HOME}/zot/prod/${dep}/.env" ]; then
		cd "${HOME}/zot/prod/${dep}"
	elif [ -f "/usr/zot/${dep}/.env" ] ; then
		cd "/usr/zot/${dep}"
	elif [ -f "${HOME}/zot/boot/${dep}/.env" ]; then
		cd "${HOME}/zot/boot/${dep}"
	else 
		echo "Internal error. Unable to find .env but earlier check should have caught this" >&2
		exit 16
	fi
	. ./.env
done

cd "${PORT_ROOT}" || exit 99

if [ "${PORT_GIT}x" != "x" ]; then
	if ! git --version >$STDOUT 2>$STDERR ; then
		echo "git is required to download from the git repo" >&2
		exit 4
	fi
	echo "Checking if git directory already cloned"
	gitname=$(basename $PORT_GIT_URL)
	dir=${gitname%%.*}
	if [ -d "${dir}" ]; then
		echo "Using existing git clone'd directory ${dir}"
	else
		echo "Clone and create ${dir}"
		if ! git clone "${PORT_GIT_URL}" >$STDOUT 2>$STDERR; then
                        echo "Unable to clone ${gitname} from ${PORT_GIT_URL}" >&2
                        exit 4
		else
			chtag -R -h -tcISO8859-1 "${dir}"
			cd "${dir}" || exit 99
		fi
	fi
fi	

if [ "${PORT_TARBALL}x" != "x" ]; then
	if ! curl --version >$STDOUT 2>$STDERR ; then
		echo "curl is required to download a tarball" >&2
		exit 4
	fi
	if ! gunzip --version >$STDOUT 2>$STDERR ; then
		echo "gunzip is required to unzip a tarball" >&2
		exit 4
	fi
	echo "Checking if tarball directory already created"
	tarballz=$(basename $PORT_TARBALL_URL)
	dir=${tarballz%%.tar.gz} 
	if [ -d "${dir}" ]; then
		echo "Using existing tarball directory ${dir}"
	else
		echo "Download and create ${dir}"
		if ! curl -0 -o "${tarballz}" "${PORT_TARBALL_URL}" >$STDOUT 2>$STDERR; then
			echo "Unable to download ${tarballz} from ${PORT_TARBALL_URL}" >&2
			exit 4
		else
			# curl tags the file as ISO8859-1 (oops) so the tag has to be removed
			chtag -b "${tarballz}"
			if ! gunzip "${tarballz}"; then
				echo "Unable to unzip ${tarballz}" >&2
				exit 4
			else
				tarball=${tarballz%%.gz}
				tar -xf "${tarball}" 2>&1 >/dev/null | grep -v FSUM7171 >$STDERR
				if [ $? -gt 1 ]; then
					echo "Unable to untar ${tarball}" >&2
					exit 4
				else
					rm -f "${tarball}"
					chtag -R -h -tcISO8859-1 "${dir}"
					cd "${dir}" || exit 99
					if ! git init . && git add . && git commit --allow-empty -m "Create Repository for patch management" ; then
						echo "Unable to initialize git repository for tarball" >&2
						exit 4
					fi
				fi
			fi
		fi
	fi
fi	

# Proceed to build

if [ "${PORT_GIT}x" != "x" ] && [ -f ./bootstrap ]; then
	if [ -f bootstrap.success ] ; then
		echo "Using previous successul bootstrap" >&2
	else
		bootlog="${LOG_PFX}_bootstrap.log"
		if ! ./bootstrap >${bootlog} 2>&1 ; then
			echo "Bootstrap failed. Log: ${bootlog}" >&2 
			exit 4
		fi
		touch bootstrap.success
	fi
fi

PROD_DIR="${HOME}/zot/prod/${dir}"
echo "Configure"
if [ -f config.success ] ; then
	echo "Using previous successful configuration" >&2
else
	export CONFIG_OPTS="--prefix=${PROD_DIR}"
	configlog="${LOG_PFX}_config.log"
	if ! ./configure "${CONFIG_OPTS}" >"${configlog}" 2>&1 ; then
		echo "Configure failed. Log: ${configlog}" >&2
		exit 4
	fi
	touch config.success
fi

makelog="${LOG_PFX}_make.log"
echo "Make"
if ! make >"${makelog}" 2>&1 ; then
	echo "Make failed. Log: ${makelog}" >&2
	exit 4
fi
	 
checklog="${LOG_PFX}_check.log"
echo "Check"
make check >"${checklog}" 2>&1
if ! "${PORT_CHECK}" "./${dir}" "${LOG_PFX}"; then 
	echo "Check failed. Log: ${checklog}" >&2
	exit 4
fi

echo "Install"
installlog="${LOG_PFX}_install.log"
if ! make install >"${installlog}" 2>&1 ; then
	echo "Install failed. Log: ${installlog}" >&2
	exit 4
fi
if ! "${PORT_CREATE_ENV}" "${PROD_DIR}" "${LOG_PFX}"; then 
	echo "Environment creation failed." >&2
	exit 4
fi
