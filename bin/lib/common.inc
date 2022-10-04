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
  export _C89_CCMODE=1

  # Required for proper operation of (USS shipped) sed
  export _UNIX03=YES
}

zopenInitialize()
{
  defineEnvironment
  defineColors
}

printVerbose()
{
  if ${verbose}; then
    print "${NC}${GREEN}${BOLD}VERBOSE${NC}: '${1}'" >&2
  fi
}

printHeader()
{
  print "${NC}${UNDERLINE}${1}...${NC}" >&2
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
  print "${NC}${RED}${BOLD}***ERROR: ${NC}${RED}${1}${NC}" >&2
}

printError()
{
  printSoftError "${1}"
  exit 4
}

printWarning()
{
  print "${NC}${YELLOW}${BOLD}***WARNING: ${NC}${YELLOW}${1}${NC}" >&2
}

printInfo()
{
  print "$1" >&2
}

getInput()
{
  read zopen_input
  echo $zopen_input
}

zopenInitialize
