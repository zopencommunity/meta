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
  export _BPXK_AUTOCVT=ON
  export _CEE_RUNOPTS="$_CEE_RUNOPTS FILETAG(AUTOCVT,AUTOTAG) POSIX(ON)"
  export _TAG_REDIR_ERR=txt
  export _TAG_REDIR_IN=txt
  export _TAG_REDIR_OUT=txt
  export _C89_CCMODE=1
}

zopenInitialize()
{
  defineEnvironment
  defineColors
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
  rc=$?
  chtag -r $SSH_TTY
  return $rc
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

zopenInitialize
