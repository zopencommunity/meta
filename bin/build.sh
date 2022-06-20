#!/bin/sh
#
# General purpose build script for ZOSOpenTools ports
#
# PORT_ROOT must be defined to the root directory of the cloned ZOSOpenTools port
# PORT_TYPE must be defined to either TARBALL or GIT. This indicates the type of package to build
#
# For more details, see the help which you can get by issuing:
# build.sh -h

#
# Functions section
#

printEnvVar()
{
  echo "\
PORT_ROOT           The directory the port repo was extracted into (defaults to current directory)
PORT_TYPE           The type of package to download. Valid types are TARBALL and GIT (required)
PORT_TARBALL_URL    The fully qualified URL that the tarball should be downloaded from (required if PORT_TYPE=TARBALL)
PORT_TARBALL_DEPS   Space-delimited set of source packages this git package depends on to build (required if PORT_TYPE=TARBALL)
PORT_GIT_URL        The fully qualified URL that the git repo should be cloned from (required if PORT_TYPE=GIT)
PORT_GIT_DEPS       Space-delimited set of source packages this tarball package depends on to build (required if PORT_TYPE=GIT)
PORT_URL            Alternate environment variable instead of PORT_TARBALL_URL or PORT_GIT_URL (alternate to PORT_TARBALL_URL or PORT_GIT_URL) 
PORT_DEPS           Alternate environment variable instead of PORT_TARBALL_DEPS or PORT_GIT_DEPS (alternate to PORT_TARBALL_DEPS or PORT_GIT_DEPS)  
CC                  C compiler (defaults to '${PORT_CCD}')
CXX                 C++ compiler (defaults to '${PORT_CXXD}')
CPPFLAGS            C/C++ pre-processor flags (defaults to '${PORT_CPPFLAGSD}')
CFLAGS              C compiler flags (defaults to '${PORT_CFLAGSD}')
CXXFLAGS            C++ compiler flags (defaults to '${PORT_CXXFLAGSD}')
LDFLAGS             C/C++ linker flags (defaults to '${PORT_LDFLAGSD}')
PORT_EXTRA_CPPFLAGS C/C++ pre-processor flags to append to CPPFLAGS (defaults to '')
PORT_EXTRA_CFLAGS   C compiler flags to append to CFLAGS (defaults to '')
PORT_EXTRA_CXXFLAGS C++ compiler flags to append to CXXFLAGS (defaults to '')
PORT_EXTRA_LDFLAGS  C/C++ linker flags to append to LDFLAGS (defaults to '')
PORT_NUM_JOBS       Number of jobs that can be run in parallel (defaults to 1/2 the CPUs on the system)
PORT_BOOTSTRAP      Bootstrap program to run. If skip is specified, no bootstrap step is performed (defaults to '${PORT_BOOTSTRAPD}')
PORT_BOOTSTRAP_OPTS Options to pass to bootstrap program (defaults to '${PORT_BOOTSTRAP_OPTSD}')
PORT_CONFIGURE      Configuration program to run. If skip is specified, no configuration step is performed (defaults to '${PORT_CONFIGURED}')
PORT_CONFIGURE_OPTS Options to pass to configuration program (defaults to '--prefix=\${PORT_INSTALL_DIR}')
PORT_EXTRA_CONFIGURE_OPTS Extra configure options to pass to configuration program (defaults to '')
PORT_INSTALL_DIR    Installation directory to pass to configuration (defaults to '\${HOME}/zot/prod/<pkg>')
PORT_MAKE           Build program to run. If skip is specified, no build step is performed (defaults to '${PORT_MAKED}')
PORT_MAKE_OPTS      Options to pass to build program (defaults to '-j\${PORT_NUM_JOBS}')
PORT_CHECK          Check program to run. If skip is specified, no check step is performed (defaults to '${PORT_CHECKD}') 
PORT_CHECK_OPTS     Options to pass to check program (defaults to '${PORT_CHECK_OPTSD}')
PORT_INSTALL        Installation program to run. If skip is specified, no installation step is performed (defaults to '${PORT_INSTALLD}')
PORT_INSTALL_OPTS   Options to pass to installation program (defaults to '${PORT_INSTALL_OPTSD}')"

}

setDefaults()
{
	export PORT_CCD="xlclang"
	export PORT_CXXD="xlclang++"
  export PORT_CPPFLAGSD="-DNSIG=9 -D_XOPEN_SOURCE=600 -D_ALL_SOURCE -D_OPEN_SYS_FILE_EXT=1 -D_AE_BIMODAL=1 -D_ENHANCED_ASCII_EXT=0xFFFFFFFF"
  export PORT_CFLAGSD="-qascii"
  export PORT_CXXFLAGSD="-+ -qascii"
	export PORT_BOOSTRAPD="./bootstrap"
	export PORT_BOOSTRAP_OPTSD=""
	export PORT_CONFIGURED="./configure"
	export PORT_MAKED="make"
	export PORT_CHECKD="make"
	export PORT_CHECK_OPTSD="check"
	export PORT_INSTALLD="make"
	export PORT_INSTALL_OPTSD="install"
}

printSyntax() 
{
  args=$*
  echo "" >&2
  echo "build.sh is a general purpose build script to be used with the ZOSOpenTools ports." >&2
  echo "The specifics of how the tool works can be controlled through environment variables." >&2
  echo "The only environment variables you _must_ specify are to tell build.sh where the " >&2 
  echo "  source is, and in what format type the source is stored." >&2
  echo "By default, the environment variables are defined in a file named setenv in the " >&2 
  echo "  root directory of the <package>port github repository" >&2
  echo "To see a fully functioning z/OSOpenTools sample port" >&2
  echo "  see: https://github.com/ZOSOpenTools/zotsampleport" >&2
  echo "" >&2
  echo "Syntax: build.sh [<option>]*" >&2
  echo "  where <option> may be one or more of:" >&2
  echo "  -h: print this information" >&2
  echo "  -v: run in verbose mode" >&2
  echo "  -e <env file>: source <env file> instead of setenv to establish build environment" >&2
  opts=$(printEnvVar)
  echo "${opts}" >&2
}

processOptions() 
{
  args=$*
  verbose=false
  for arg in $args; do
    case $arg in
      "-h" | "--h" | "-help" | "--help" | "-?" | "-syntax")
        printSyntax "${args}"
        return 4
        ;;
      "-v" | "--v" | "-verbose" | "--verbose")
        verbose=true
        ;;
      "-e" | "--env")
        printError "-e option not implemented yet"
        ;;
      *)
        printError "Unknown option ${arg} specified"
        ;;
    esac
  done
}

defineColors() 
{
  if [ ! "${_BPX_TERMPATH-x}" = "OMVS" ] && [ -z "${NO_COLOR}" ] && [ ! "${FORCE_COLOR-x}" = "0" ]; then
    esc="\047"
    RED="${esc}[31m"
    GREEN="${esc}[32m"
    YELLOW="${esc}[33m"
    BOLD="${esc}[1m"
    UNDERLINE="${esc}[4m"
    NC="${esc}[0m"
  else
#    unset esc RED GREEN YELLOW BOLD UNDERLINE NC

    esc=''
    RED=''
    GREEN=''
    YELLOW=''
    BOLD=''
    UNDERLINE=''
    NC=''
  fi
}

printVerbose()
{
  if ${verbose}; then
    printf "${NC}${GREEN}${BOLD}VERBOSE${NC}: '${1}'\n" >&2
  fi
}

printHeader()
{
  printf "${NC}${UNDERLINE}${1}...${NC}\n" >&2
}

runAndLog()
{
  printVerbose "$1"
  eval "$1"
}

printSoftError()
{
  printf "${NC}${RED}${BOLD}***ERROR: ${NC}${RED}${1}${NC}\n" >&2
}

printError()
{
  printSoftError "${1}"
  exit 4
}

printWarning()
{
  printf "${NC}${YELLOW}${BOLD}***WARNING: ${NC}${YELLOW}${1}${NC}\n" >&2
}

printInfo()
{
  printf "$1\n" >&2
}

checkDeps()
{
  deps=$*
  fail=false
  for dep in $deps; do
    if ! [ -r "${HOME}/zot/prod/${dep}/.env" ] && ! [ -r "${HOME}/zot/boot/${dep}/.env" ] && ! [ -r "/usr/bin/zot/${dep}/.env" ]; then
      fail=true
      printSoftError "Unable to find .env for dependency ${dep}"
    fi
  done
  if $fail ; then
    return 4
  fi
}

checkEnv()
{
  #
  # Specify PORT_TYPE as either TARBALL or GIT
  # To specify a URL, you can either be specific (e.g. PORT_TARBALL_URL or PORT_GIT_URL) or you can be general (e.g. PORT_URL)
  # and to specify DEPS, you can either be specific (e.g. PORT_TARBALL_DEPS or PORT_GIT_DEPS) or you can be general (e.g. PORT_DEPS).
  # This flexibility is nice so that for software packages that support both types (e.g. gnu make), you can provide all of
  # PORT_TARBALL_URL, PORT_TARBALL_DEPS, PORT_GIT_URL, PORT_GIT_DEPS in your environment set up and then specify the type using
  # PORT_TYPE=GIT|URL (e.g. only one line needs to be changed).
  # For software packages that only support one type, you can just specify PORT_URL, PORT_DEPS, and PORT_TYPE.
  #
  printHeader "Checking environment configuration"

  if [ "${PORT_ROOT}x" = "x" ]; then
    printError "PORT_ROOT needs to be defined to the root directory of the tool being ported"
  fi
  if ! [ -d "${PORT_ROOT}" ]; then
    printError "PORT_ROOT ${PORT_ROOT} is not a directory"
  fi

  if [ "${PORT_TYPE}x" = "TARBALLx" ]; then
    if [ "${PORT_TARBALL_URL}x" = "x" ]; then
      export PORT_TARBALL_URL="${PORT_URL}"
    fi
    if [ "${PORT_TARBALL_DEPS}x" = "x" ]; then
      export PORT_TARBALL_DEPS="${PORT_DEPS}"
    fi
  elif [ "${PORT_TYPE}x" = "GITx" ]; then
    if [ "${PORT_GIT_URL}x" = "x" ]; then
      export PORT_GIT_URL="${PORT_URL}"
    fi

    if [ "${PORT_GIT_DEPS}x" = "x" ]; then
      export PORT_GIT_DEPS="${PORT_DEPS}"
    fi
  else
    printError "PORT_TYPE must be one of TARBALL or GIT. PORT_TYPE=${PORT_TYPE} was specified"
  fi

  export PORT_CHECK_RESULTS="${PORT_ROOT}/portchk.sh"
  export PORT_CREATE_ENV="${PORT_ROOT}/portcrtenv.sh"
  if ! [ -x "${PORT_CHECK_RESULTS}" ]; then
    printError "${PORT_CHECK_RESULTS} script needs to be provided to check the results. Exit with 0 if the build can be installed"
  fi
  if ! [ -x "${PORT_CREATE_ENV}" ]; then
    printError "${PORT_CREATE_ENV} script needs to be provided to define the environment"
  fi

  if [ "${PORT_TYPE}x" = "TARBALLx" ]; then
    if [ "${PORT_TARBALL_URL}x" = "x" ]; then
      printError "PORT_URL or PORT_TARBALL_URL needs to be defined to the root directory of the tool being ported"
    fi
    if [ "${PORT_TARBALL_DEPS}x" = "x" ]; then
      printError "PORT_DEPS or PORT_TARBALL_DEPS needs to be defined to the ported tools this depends on"
    fi
    deps="${PORT_TARBALL_DEPS}"
  elif [ "${PORT_TYPE}x" = "GITx" ]; then
    if [ "${PORT_GIT_URL}x" = "x" ]; then
      printError "PORT_URL or PORT_GIT_URL needs to be defined to the root directory of the tool being ported"
    fi
    if [ "${PORT_GIT_DEPS}x" = "x" ]; then
      printError "PORT_DEPS or PORT_GIT_DEPS needs to be defined to the ported tools this depends on"
    fi
    deps="${PORT_GIT_DEPS}"
  fi

  if ! checkDeps "${deps}"; then
		printError "One or more dependent products aren't available"
	fi

  export PORT_CA="${utilparentdir}/cacert.pem"
  if ! [ -r "${PORT_CA}" ]; then
    printError "Internal Error. Certificate ${PORT_CA} is required"
  fi

  #
  # For the compilers and corresponding flags, you need to either specify both the compiler and flag, or neither
  # since the flags are not compatible across compilers, and only the xlclang and xlclang++ compilers are used by default
  #

  if [ "${CC}x" = "x" ] && [ "${CFLAGS}x" != "x" ]; then
    printError "Either specify both CC and CFLAGS or neither, but not just one"
  fi
  if [ "${CXX}x" = "x" ] && [ "${CXXFLAGS}x" != "x" ]; then
    printError "Either specify both CXX and CXXFLAGS or neither, but not just one"
  fi
}

setDepsEnv()
{
  if [ "${PORT_TYPE}x" = "TARBALLx" ]; then
    deps="${PORT_TARBALL_DEPS}"
  else
    deps="${PORT_GIT_DEPS}"
  fi

  orig="${PWD}"
  for dep in $deps; do
    if [ -r "${HOME}/zot/prod/${dep}/.env" ]; then
      depdir="${HOME}/zot/prod/${dep}"
    elif [ -r "/usr/bin/zot/${dep}/.env" ]; then
      depdir="/usr/bin/zot/${dep}"
    elif [ -r "${HOME}/zot/boot/${dep}/.env" ]; then
      depdir="${HOME}/zot/boot/${dep}"
    else
      printError "Internal error. Unable to find .env for ${deps} but earlier check should have caught this"
    fi
    printVerbose "Setting up ${depdir} dependency environment"
    cd "${depdir}" && . ./.env
  done
  cd "${orig}" || exit 99
}

setEnv()
{
  if [ "${CPPFLAGS}x" = "x" ]; then
    export CPPFLAGS="${PORT_CPPFLAGSD} ${PORT_EXTRA_CPPFLAGS}"
  fi
  if [ "${CC}x" = "x" ]; then
    export CC="${PORT_CCD}"
    export CFLAGS="${PORT_CFLAGSD}"
    export CFLAGS="${PORT_CFLAGSD} ${PORT_EXTRA_CFLAGS}"
  fi

  if [ "${CXX}x" = "x" ]; then
    export CXX="${PORT_CXXD}"
    export CXXFLAGS="${PORT_CXXFLAGSD} ${PORT_EXTRA_CXXFLAGS}"
  fi

	# For compatibility with the default 'make' /etc/startup.mk on z/OS
	export CCC="${CXX}"
	export CCCFLAGS="${CXXFLAGS}"

  if [ "${LDFLAGS}x" = "x" ]; then
    export LDFLAGS="${PORT_LDFLAGSD} ${PORT_EXTRA_LDFLAGS}"
  fi

  export SSL_CERT_FILE="${PORT_CA}"
  export GIT_SSL_CAINFO="${PORT_CA}"

  setDepsEnv

  if [ "${PORT_NUM_JOBS}x" = "x" ]; then
    PORT_NUM_JOBS=$("${utildir}/numcpus.rexx")

    # Use half of the CPUs by default
    export PORT_NUM_JOBS=$((PORT_NUM_JOBS / 2))
  fi

  if [ $PORT_NUM_JOBS -lt 1 ]; then
    export PORT_NUM_JOBS=1
  fi

  if [ "${PORT_BOOTSTRAP}x" = "x" ]; then
    export PORT_BOOTSTRAP="${PORT_BOOSTRAPD}"
  fi
  if [ "${PORT_BOOTSTRAP_OPTS}x" = "x" ]; then
    export PORT_BOOTSTRAP_OPTS="${PORT_BOOTSTRAP_OPTSD}"
  fi
  if [ "${PORT_CONFIGURE}x" = "x" ]; then
    export PORT_CONFIGURE="${PORT_CONFIGURED}"
  fi
  if [ "${PORT_MAKE}x" = "x" ]; then
    export PORT_MAKE="${PORT_MAKED}"
  fi
  if [ "${PORT_MAKE_OPTS}x" = "x" ]; then
    export PORT_MAKE_OPTS="-j${PORT_NUM_JOBS}"
  fi
  if [ "${PORT_CHECK}x" = "x" ]; then
    export PORT_CHECK="${PORT_CHECKD}"
  fi
  if [ "${PORT_CHECK_OPTS}x" = "x" ]; then
    export PORT_CHECK_OPTS="${PORT_CHECK_OPTSD}"
  fi
  if [ "${PORT_INSTALL}x" = "x" ]; then
    export PORT_INSTALL="${PORT_INSTALLD}"
  fi
  if [ "${PORT_INSTALL_OPTS}x" = "x" ]; then
    export PORT_INSTALL_OPTS="${PORT_INSTALL_OPTSD}"
  fi
  LOG_PFX=$(date +%C%y%m%d_%H%M%S)
}

#
# 'Quick' way to find untagged non-binary files. If the list of extensions grows, something more
# elegant is required
#
tagTree()
{
  dir="$1"
  find "${dir}" -name "*.pdf" -o -name "*.png" -o -name "*.bat" ! -type d ! -type l | xargs -I {} chtag -b {}
  find "${dir}" ! -type d ! -type l | xargs -I {} chtag -qp {} | awk '{ if ($1 == "-") { print $4; }}' | xargs -I {} chtag -tcISO8859-1 {}
}

gitClone()
{
  if ! git --version >/dev/null 2>/dev/null; then
    printError "git is required to download from the git repo"
  fi

  gitname=$(basename "$PORT_GIT_URL")
  dir=${gitname%%.*}
  if [ -d "${dir}" ]; then
    printInfo "Using existing git clone'd directory ${dir}" 
  else
    printInfo "Clone and create ${dir}" 
    if ! runAndLog "git clone \"${PORT_GIT_URL}\""; then
      printError "Unable to clone ${gitname} from ${PORT_GIT_URL}"
    fi
    if [ "${PORT_GIT_BRANCH}x" != "x" ]; then
      if ! git -C "${dir}" checkout "${PORT_GIT_BRANCH}" >/dev/null; then
        printError"Unable to checkout ${PORT_GIT_URL} branch ${PORT_GIT_BRANCH}"
      fi
    fi
    tagTree "${dir}"
  fi
  echo "${dir}"
}

extractTarBall()
{
  tarballz="$1"
  dir="$2"

  ext=${tarballz##*.}
  if [ "${ext}x" = "xzx" ]; then
    if ! xz -d "${tarballz}"; then
      printError "Unable to use xz to decompress ${tarballz}"
    fi
    tarball=${tarballz%%.xz}
  elif [ "${ext}x" = "gzx" ]; then
    if ! gunzip "${tarballz}"; then
      printError "Unable to use gunzip to decompress ${tarballz}"
    fi
    tarball=${tarballz%%.gz}
  else
    printError "Extension ${ext} is an unsupported compression technique. Add code"
  fi

  tar -xf "${tarball}" 2>&1 >/dev/null | grep -v FSUM7171 >/dev/null
  if [ $? -gt 1 ]; then
    printError "Unable to untar ${tarball}"
  fi
  rm -f "${tarball}"

  # tar will incorrectly tag files as 1047, so just clear the tags
  chtag -R -r "${dir}"

  tagTree "${dir}"
  cd "${dir}" || printError "Cannot cd to ${dir}"
  if [ -f .gitattributes ]; then
    printError "No support for existing .gitattributes file. Write some code"
  fi
  if ! echo "* text working-tree-encoding=ISO8859-1" >.gitattributes; then
    printError "Unable to create .gitattributes for tarball"
  fi

  if [ "$(chtag -p .gitattributes | cut -f2 -d' ')" != "ISO8859-1" ]; then
    if ! iconv -f IBM-1047 -tISO8859-1 <.gitattributes >.gitattrascii || ! chtag -tcISO8859-1 .gitattrascii || ! mv .gitattrascii .gitattributes; then
      printError "Unable to make .gitattributes ascii for tarball"
    fi
  fi

  files=$(find . ! -name "*.pdf" ! -name "*.png" ! -name "*.bat" ! -type d)
  if ! git init . >/dev/null || ! git add -f ${files} >/dev/null || ! git commit --allow-empty -m "Create Repository for patch management" >/dev/null; then
    printError "Unable to initialize git repository for tarball"
  fi
  # Having the directory git-managed exposes some problems in the current git for software like autoconf,
  # so move .git to the side and just use it for applying patches
  # (you will also need to move it back to do a 'git diff' on any new patches you want to develop)
  mv .git .git-for-patches
}

downloadTarBall()
{
  if ! curl --version >/dev/null; then
    printError "curl is required to download a tarball"
  fi
  tarballz=$(basename "$PORT_TARBALL_URL")
  dir=${tarballz%%.tar.*}
  if [ -d "${dir}" ]; then
    echo "Using existing tarball directory ${dir}" >&2
  else
    if ${verbose}; then
			printVerbose "curl -L -0 -o ${tarballz} ${PORT_TARBALL_URL}"
		fi
		#
		# Some older tarballs (openssl) contain a pax_global_header file. Remove it 
		# in advance so that unzip won't fail
		#
		rm -f pax_global_header
    if ! curl -L -0 -o "${tarballz}" "${PORT_TARBALL_URL}" 2>/dev/null ; then
      if [ -f "${tarballz}" ] && [ $(wc -c "${tarballz}" | awk '{print $1}') -lt 1024 ]; then
        cat "${tarballz}" >/dev/null
			else
				printError "Re-try curl for diagnostics"
				curl -L -0 -o /dev/null "${PORT_TARBALL_URL}"
      fi
      printError "Unable to download ${tarballz} from ${PORT_TARBALL_URL}"
    fi
    # curl tags the file as ISO8859-1 (oops) so the tag has to be removed
    chtag -b "${tarballz}"

    extractTarBall "${tarballz}" "${dir}"
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
applyPatches()
{
  printHeader "Applying patches"
  if [ "${PORT_TYPE}x" = "TARBALLx" ]; then
    tarballz=$(basename "$PORT_TARBALL_URL")
    code_dir="${PORT_ROOT}/${tarballz%%.tar.*}"
  else
    gitname=$(basename "$PORT_GIT_URL")
    code_dir="${PORT_ROOT}/${gitname%%.*}"
  fi

  patch_dir="${PORT_ROOT}/patches"
  if ! [ -d "${patch_dir}" ]; then
    printWarning "${patch_dir} does not exist - no patches to apply"
    return 0
  fi

  moved=false
  if [ -d "${code_dir}/.git-for-patches" ] && ! [ -d "${code_dir}/.git" ]; then
    mv "${code_dir}/.git-for-patches" "${code_dir}/.git" || exit 99
    moved=true
  fi

  if ! [ -d "${code_dir}/.git" ]; then
    printWarning "applyPatches requires ${code_dir} to be git-managed but there is no .git directory. No patches applied"
    return 0
  fi

  patches=$( (cd "${patch_dir}" && find . -name "*.patch" | sort))
  results=$( (cd "${code_dir}" && git status --porcelain --untracked-files=no 2>&1))
  failedcount=0
  if [ "${results}" != '' ]; then
    printInfo "Existing Changes are active in ${code_dir}."
    printInfo "To re-apply patches, perform a git reset on ${code_dir} prior to running applyPatches again."
  else
    for patch in $patches; do
      p="${patch_dir}/${patch}"

      patchsize=$(wc -c "${p}" | awk '{ print $1 }')
      if [ ${patchsize} -eq 0 ]; then
        printWarning "Warning: patch file ${p} is empty - nothing to be done"
      else
        printInfo "Applying ${p}"
        if ! out=$( (cd "${code_dir}" && git apply --check "${p}" 2>&1 && git apply "${p}")); then
          printSoftError "Patch of make tree failed (${p})."
          printSoftError "${out}"
          failedcount=$((failedcount + 1))
					break
        fi
      fi
    done
  fi
  if ${moved}; then
    mv "${code_dir}/.git" "${code_dir}/.git-for-patches" || exit 99
  fi

  if [ $failedcount -ne 0 ]; then
    exit $failedcount
  fi
  return 0
}

getCode()
{
  printHeader "Building ${PORT_ROOT}"
  cd "${PORT_ROOT}" || exit 99

  if [ "${PORT_TYPE}x" = "GITx" ]; then
    printInfo "Checking if git directory already cloned"
    if ! dir=$(gitClone) ; then 
      return 4
    fi
  elif [ "${PORT_TYPE}x" = "TARBALLx" ]; then
    printInfo "Checking if tarball already downloaded"
    if ! dir=$(downloadTarBall) ; then 
      return 4
    fi
  else
    printError "PORT_TYPE should be one of GIT or TARBALL"
    return 4
  fi
  echo "${dir}"
}

bootstrap()
{
  if [ "${PORT_BOOTSTRAP}x" != "skipx" ] && [ -x "${PORT_BOOTSTRAP}" ]; then
    printHeader "Running Bootstrap"
    if [ -r bootstrap.success ]; then
      echo "Using previous successful bootstrap" >&2
    else
      bootlog="${LOG_PFX}_bootstrap.log"
      if ! runAndLog "\"${PORT_BOOTSTRAP}\" ${PORT_BOOTSTRAP_OPTS} >${bootlog} 2>&1"; then
        printError "Bootstrap failed. Log: ${bootlog}" >&2
      fi
      touch bootstrap.success
    fi
  else
    printHeader "Skip Bootstrap"
  fi
}

configure()
{
  if [ "${PORT_CONFIGURE}x" != "skipx" ] && [ -x "${PORT_CONFIGURE}" ]; then
    printHeader "Running Configure"
    if [ -r config.success ]; then
      echo "Using previous successful configuration" >&2
    else
      configlog="${LOG_PFX}_config.log"
      if ! runAndLog "\"${PORT_CONFIGURE}\" ${PORT_CONFIGURE_OPTS} CC=${CC} \"CPPFLAGS=${CPPFLAGS}\" \"CFLAGS=${CFLAGS}\" CXX=${CXX} \"CXXFLAGS=${CXXFLAGS}\" \"LDFLAGS=${LDFLAGS}\" >\"${configlog}\" 2>&1"; then
        printError "Configure failed. Log: ${configlog}"
      fi
      touch config.success
    fi
  else
    printHeader "Skip Configure"
  fi
}

build()
{
  makelog="${LOG_PFX}_build.log"
  if [ "${PORT_MAKE}x" != "skipx" ] ; then
    printHeader "Running Build"
    if ! runAndLog "\"${PORT_MAKE}\" ${PORT_MAKE_OPTS} >\"${makelog}\""; then
      printError "Make failed. Log: ${makelog}"
    fi
  else
    printHeader "Skipping Build"
  fi
}

check()
{
  checklog="${LOG_PFX}_check.log"
  if [ "${PORT_CHECK}x" != "skipx" ] ; then
    printHeader "Running Check"
    runAndLog "\"${PORT_CHECK}\" ${PORT_CHECK_OPTS} >\"${checklog}\""
    if ! runAndLog "\"${PORT_CHECK_RESULTS}\" \"${PORT_ROOT}/${dir}\" \"${LOG_PFX}\""; then
      printError "Check failed. Log: ${checklog}"
    fi
  else
    printHeader "Skipping Check"
  fi
}

install()
{
  if [ "${PORT_INSTALL}x" != "skipx" ] ; then
    printHeader "Running Install"
    installlog="${LOG_PFX}_install.log"
    if ! runAndLog "\"${PORT_INSTALL}\" ${PORT_INSTALL_OPTS} >\"${installlog}\""; then
      printError "Install failed. Log: ${installlog}"
    fi
    if ! runAndLog "\"${PORT_CREATE_ENV}\" \"${PORT_INSTALL_DIR}\" \"${LOG_PFX}\""; then
      printError "Environment creation failed."
    fi
  
    PORT_NAME="${dir}"
    if [ "${PORT_TYPE}x" = "GITx" ]; then
      branch=$(git rev-parse --abbrev-ref HEAD 2>&1)
      PORT_NAME="${dir}.${branch}"
    fi

    paxFileName="${PORT_NAME}.${LOG_PFX}.zos.pax.Z";
    if ! runAndLog "pax -w -z -x pax \"-s#${PORT_INSTALL_DIR}/#${PORT_NAME}.${LOG_PFX}.zos/#\" -f \"${paxFileName}\" \"${PORT_INSTALL_DIR}/\""; then
      printError "Could not generate pax \"${paxFileName}\""
    fi
  else 
    printHeader "Skipping Install"
  fi
}

#
# Start of 'main'
#

export utildir="$( cd "$(dirname "$0")" >/dev/null 2>&1 && pwd -P )"
export utilparentdir="$( cd "$(dirname "$0")/../" >/dev/null 2>&1 && pwd -P )"

set +x 

echo ""
if ! setDefaults; then
  exit 4
fi

if ! processOptions "$*" ; then
  exit 4
fi

if ! defineColors; then
  exit 4
fi

if ! checkEnv; then
	exit 4
fi

if ! setEnv; then
	exit 4
fi

if ! dir=$(getCode); then
  exit 4
fi

#
# These variables can not be set until the 
# software package name is determined
# Perhaps we should glean this from the name
# of the git package, e.g. makeport?
#
if [ "${PORT_INSTALL_DIR}x" = "x" ]; then
	export PORT_INSTALL_DIR="${HOME}/zot/prod/${dir}"
fi
if [ "${PORT_CONFIGURE_OPTS}x" = "x" ]; then
	export PORT_CONFIGURE_OPTS="--prefix=${PORT_INSTALL_DIR} ${PORT_EXTRA_CONFIGURE_OPTS}"
fi

if ! applyPatches; then
  exit 4
fi

cd "${PORT_ROOT}/${dir}" || exit 99

if ! bootstrap; then
  exit 4
fi

if ! configure; then
  exit 4
fi

if ! build; then
  exit 4
fi

if ! check; then
  exit 4
fi

if ! install; then
  exit 4
fi

exit 0
