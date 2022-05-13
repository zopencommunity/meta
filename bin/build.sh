#!/bin/sh
#
# General purpose build script for ZOSOpenTools ports
# 
# PORT_ROOT must be defined to the root directory of the cloned ZOSOpenTools port 
# Either PORT_TARBALL or PORT_GIT must be defined (but not both). This indicates where to pull source from
# 
# A certificate of the form: tarball.pem or git.pem must be in the PORT_ROOT directory 
# Each dependent tool will have it's corresponding environment set up by sourcing .env from the installation
# directory. The .env will be searched for in $HOME/zot/prod/<tool>, /usr/zot/<tool>, $HOME/zot/boot/<tool>

if [ "${PORT_ROOT}x" = "x" ]; then
	echo "PORT_ROOT needs to be defined to the root directory of the tool being ported" >&2
	exit 4
fi
if [ "${PORT_TARBALL}x" = "x" ] && [ "${PORT_GIT}x" = "x" ]; then
	echo "One of PORT_TARBALL or PORT_GIT needs to be defined to specify where to pull source from" >&2
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

BASE_CFLAGS="-std=gnu11 -DNSIG=39 -D_XOPEN_SOURCE=600 -D_ALL_SOURCE -qascii -D_AE_BIMODAL=1 -D_ENHANCED_ASCII_EXT=0xFFFFFFFF -qfloat=ieee"
BASE_LDFLAGS="" 

export CC=xlclang
export CPP=xlclang++
export CFLAGS="${BASE_CFLAGS} ${PORT_EXTRA_CFLAGS}"
export LDFLAGS="${BASE_LDFLAGS} ${PORT_EXTRA_LDFLAGS}"

for dep in $deps; do
	if [ -f "${HOME}/zot/prod/${dep}/.env" ]; then
		. "${HOME}/zot/prod/${dep}/.env"
	elif [ -f "/usr/zot/${dep}/.env" ] ; then
		. "/usr/zot/${dep}/.env"
	elif [ -f "${HOME}/zot/boot/${dep}/.env" ]; then
		. "${HOME}/zot/boot/${dep}/.env"
	else 
		echo "Internal error. Unable to find .env but earlier check should have caught this" >&2
		exit 16
	fi
done

cd "${PORT_ROOT}" || exit 99

if [ "${PORT_GIT}x" != "x" ]; then
	echo "Checking if git directory already cloned"
	gitname=$(basename $PORT_GIT_URL)
	dir=${gitname%%.*}
	if ! [ -d "${dir}" ]; then
		echo "Clone"
	fi
fi	
if [ "${PORT_TARBALL}x" != "x" ]; then
	echo "Checking if tarball directory already created"
	dir=$(basename $PORT_TARBALL_URL)
	if ! [ -d "${dir}" ]; then
		echo "Download and create"
	fi
fi	
