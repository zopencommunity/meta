#!/bin/sh
defineColors() 
{
  if [ ! "${_BPX_TERMPATH-x}" = "OMVS" ] && [ -z "${NO_COLOR}" ] && [ ! "${FORCE_COLOR-x}" = "0" ] && [ -t 1 ] && [ -t 2 ]; then
    esc="\047"
    RED="${esc}[31m"
    GREEN="${esc}[32m"
    YELLOW="${esc}[33m"
    BOLD="${esc}[1m"
    UNDERLINE="${esc}[4m"
    NC="${esc}[0m"
  else
# unset esc RED GREEN YELLOW BOLD UNDERLINE NC

    esc=''
    RED=''
    GREEN=''
    YELLOW=''
    BOLD=''
    UNDERLINE=''
    NC=''
  fi
}

defineEnvironment()
{
  # Required for proper operation of z/OS auto-conversion support
  export _BPXK_AUTOCVT=ON
  export _CEE_RUNOPTS="$_CEE_RUNOPTS FILETAG(AUTOCVT,AUTOTAG) POSIX(ON)"
  export _TAG_REDIR_ERR=txt
  export _TAG_REDIR_IN=txt
  export _TAG_REDIR_OUT=txt

  # Required for proper operation of xlclang
  export _CC_CCMODE=1
  export _C89_CCMODE=1
  export _CXX_CCMODE=1

  # Required for proper operation of (USS shipped) sed
  export _UNIX03=YES

  # Use /bin/cat as the pager in case xlclang help is displayed, we don't want to wait for input
  export PAGER=/bin/cat
}

#
# For now, explicitly specify /bin/echo to ensure we get the EBCDIC echo since the escape
# sequences are EBCDIC escape sequences
#
printColors()
{
  /bin/echo "$1"
}

zopenInitialize()
{
  defineEnvironment
  defineColors
  processConfig
}

printVerbose()
{
  if ${verbose}; then
    printColors "${NC}${GREEN}${BOLD}VERBOSE${NC}: '${1}'" >&2
  fi
}

printHeader()
{
  printColors "${NC}${YELLOW}${BOLD}${UNDERLINE}${1}${NC}" >&2
}

runAndLog()
{
  printVerbose "$1"
  eval "$1"
  rc=$?
  if [ ! -z "${SSH_TTY}" ]; then
    chtag -r $SSH_TTY
  fi
  return $rc
}

runInBackgroundWithTimeoutAndLog()
{
  command="$1"
  timeout="$2"

  printVerbose "$command with timeout of ${timeout}s"
  eval "$command &; TEEPID=$!"
  PID=$!
  n=0
  while [ $n -le $timeout ]; do
    kill -0 $PID 2>/dev/null
    if [ $? != 0 ]; then
      wait $PID
      if [ ! -z "${SSH_TTY}" ]; then
        chtag -r $SSH_TTY
      fi
      rc=$?
      return $rc
    else
      sleep 1
      n=`expr $n + 1`
    fi
  done
  kill -9 $PID
  kill -9 $TEEPID
  printError "TIMEOUT: (PID: $PID): $command"
}

printSoftError()
{
  printColors "${NC}${RED}${BOLD}***ERROR: ${NC}${RED}${1}${NC}" >&2
}

printError()
{
  printSoftError "${1}"
  exit 4
}

printWarning()
{
  printColors "${NC}${YELLOW}${BOLD}***WARNING: ${NC}${YELLOW}${1}${NC}" >&2
}

printInfo()
{
  printColors "$1" >&2
}

getInput()
{
  read zopen_input
  echo $zopen_input
}

printElapsedTime()
{
  printType=$1
  functionName=$2
  startTime=$3
  elapsedTime=$(( $SECONDS - $startTime ))

  elapsedTimeOutput="$functionName completed in $elapsedTime seconds."

  case $printType in
    "info")
      printInfo "$elapsedTimeOutput"
      ;;
    "verbose")
      printVerbose "$elapsedTimeOutput"
      ;;
  esac
}

processConfig()
{
  if [ -f "$HOME/.zopen-config" ]; then
    . "$HOME/.zopen-config"
  fi
}

parseDeps()
{
  dep="$1"
  version=$(echo $dep | awk -F '[>=<]+' '{print $2}')
  if [ -z "$version" ]; then
    operator=""
    dep=$(echo $dep | awk -F '[>=<]+' '{print $1}')
  else
    operator=$(echo $dep | awk -F '[0-9.]+' '{print $1}' | awk -F '^[a-zA-Z]+' '{print $2}')
    dep=$(echo $dep | awk -F '[>=<]+' '{print $1}')
    case $operator in
      ">=") ;;
      "=") ;;
      *) printError "$operator is not supported."
    esac
    major=$(echo $version | awk -F. '{print $1}')
    minor=$(echo $version | awk -F. '{print $2}')
    if [ -z "$minor" ]; then
      minor=0
    fi
    patch=$(echo $version | awk -F. '{print $3}')
    if [ -z "$patch" ]; then
      patch=0
    fi
    prerelease=$(echo $version | awk -F. '{print $4}')
    if [ -z "$prerelease" ]; then
      prerelease=0
    fi
  fi

  echo "$dep|$operator|$major|$minor|$patch|$prerelease"
}

compareVersions()
{
  v1="$1"
  v2="$2"
  awk -v v1="$v1" -v v2="$v2" '
  function vercmp(v1, v2) {
    n1 = split(v1, v1_array, ".")
    n2 = split(v2, v2_array, ".")

    for (i = 1; i <= n1 || i <= n2; i++) {
      if (v1_array[i] != v2_array[i]) {
        return (v1_array[i] < v2_array[i] ? -1 : 1)
      }
    }
    return 0
  }

  BEGIN {
    if (vercmp(v1, v2) >= 0) {
      exit 0
    } else {
      exit 1
    }
  }
  '

  return $?
}

validateVersion()
{
  version=$1
  operator=$2
  requestedVersion=$3
  dependency=$4
  if [ ! -z "$operator" ] && [ -z "$version" ]; then
    printVerbose "$operator ${requestedVersion} requsted, but no version file found in $versionPath." 
    return 1
  elif [ ! -z "$operator" ] && ! compareVersions "${version}" "${requestedVersion}"; then
    printVerbose "$dependency does not satisfy ${version} $operator ${requestedVersion}"
    return 1
  fi
  return 0
}

initDefaultEnvironment()
{
  export PATH="$(getconf PATH)"
  export MANPATH=/usr/man/%L
  export LIBPATH=/usr/lib
  export _CEE_RUNOPTS="FILETAG(AUTOCVT,AUTOTAG) POSIX(ON)"
  unset STEPLIB
}

zopenInitialize
