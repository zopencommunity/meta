#!/bin/sh
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
