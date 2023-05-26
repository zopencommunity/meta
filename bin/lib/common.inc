#!/bin/sh
export ZOPEN_CLEANUP="stty echo" # set this as a default to ensure line visibility!
addCleanupTrapCmd(){
  newCmd=$(echo "$1" | sed -e 's/^[ ]*//' -e 's/[ ]*$//')
  if [ -z "$ZOPEN_CLEANUP" ]; then
    export ZOPEN_CLEANUP="$newCmd"
  else
    export ZOPEN_CLEANUP="$(deleteDuplicateEntriesRedux "$ZOPEN_CLEANUP; $newCmd" ";")"
  fi
}
cleanupFunction() {
  [ -n "$ZOPEN_CLEANUP" ] && $(eval "$ZOPEN_CLEANUP" 2>/dev/null)
  trap - EXIT INT TERM QUIT HUP
  unset ZOPEN_CLEANUP
}
trap "cleanupFunction" EXIT INT TERM QUIT HUP

defineANSI() 
{
  # Standard tty codes
  ESC="\047"
  ERASELINE="${ESC}[2K"
  CRSRHIDE="${ESC}[?25l"
  CRSRSHOW="${ESC}[?25h"

  # Color-type codes, needs explicit terminal settings
  if [ ! "${_BPX_TERMPATH-x}" = "OMVS" ] && [ -z "${NO_COLOR}" ] && [ ! "${FORCE_COLOR-x}" = "0" ] && [ -t 1 ] && [ -t 2 ]; then
    esc="\047"
    BLACK="${esc}[30m"
    RED="${esc}[31m"
    GREEN="${esc}[32m"
    YELLOW="${esc}[33m"
    BLUE="${esc}[34m"
    MAGENTA="${esc}[35m"
    CYAN="${esc}[36m"
    GRAY="${esc}[37m"
    BOLD="${esc}[1m"
    UNDERLINE="${esc}[4m"
    NC="${esc}[0m"
  else
# unset esc RED GREEN YELLOW BOLD UNDERLINE NC

    esc=''
    BLACK=''
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    MAGENTA=''
    CYAN=''
    GRAY=''
    BOLD=''
    UNDERLINE=''
    NC=''
  fi
}
ansiline(){
  deltax=$1
  deltay=$2
  echostr=$3
  if [ $deltax -gt 0 ]; then
    echostr="${ESC}[${deltax}A$echostr"
  elif [ $deltax -lt 0 ]; then
    echostr="${ESC}[$(expr $deltax \* -1)A$echostr"
  fi
  if [ $deltay -gt 0 ]; then
    echostr="${ESC}[${deltax}C$echostr"
  elif [ $deltay -lt 0 ]; then
    echostr="${ESC}[$(expr $deltax \* -1)D$echostr"
  fi
 /bin/echo "${echostr}"

}

getScreenCols(){
  # Note tput does not handle ssh sessions too well...
  stty | awk -F'[/=;]' '/columns/ { print $4}' | tr -d " "
}

zosfind(){
  # Use the standard z/OS find utility; If the findutils package is installed,
  # the installed find command takes precedence but is not compatible with the
  # standard zos find [regex searches for "-name" are not allowed, but
  # "-wholename" is not available on standard zosfind. For the tooling to be
  # consistent across platforms (where findutils is/is not installed) use the
  # standard zos version
  /bin/find $*
}

findrev () {
  haystack="$1"
  needle="$2"
  while [[ "$haystack" != "" && "$haystack" != "/" && "$haystack" != "./" && ! -e "$haystack/$needle" ]]; do
    haystack=${haystack%/*}
  done
  echo "$haystack"
}

strtrim(){
  echo "$1" | sed -e 's/^[ ]*//' -e 's/[ ]*$//'
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
  /bin/echo "$@"
}

mutexReq(){
  mutex=$1
  lockdir="$ZOPEN_ROOTFS/var/lock"
  [ -e lockdir ] || mkdir -p $lockdir
  mutex="$lockdir/$mutex"
  mypid=$(exec sh -c 'echo $PPID')
  if [ -e "$mutex" ]; then
    lockedpid=$(cat $mutex)
    { [ ! "$lockedpid" = "$mypid" ] && [ ! "$lockedpid" = "$PPID" ]; } && echo "Aborting, Process '$lockedpid' holds the '$2' lock: '$mutex'" && exit -1
  fi
  addCleanupTrapCmd "rm -rf $mutex"
  echo "$mypid" > $mutex
}
mutexFree(){
  mutex=$1
  lockdir="$ZOPEN_ROOTFS/var/lock"
  mutex="$lockdir/$mutex"
  [ -e "$mutex" ] && rm -f $mutex
}
# Calculate the relative path from $1 to $2
relativePath(){
  sourcePath=$1
  targetPath=$2
  currentIFS="$IFS"
  IFS="/"
  relativePath=''
  set -- $targetPath
  for elem in $sourcePath; do
    if [ -z "$relativePath" ]; then
      if [ -z "$elem" ]; then
        relativePath="$1"
      elif [ "$1" = "$elem" ]; then
      else
        relativePath="../$1"
      fi
    else
      if [ -n "$elem" ]; then
        relativePath="../$relativePath"
      else
        relativePath="$relativePath/$1"
      fi
    fi
    if [ $# -gt 0 ]; then
      shift
    fi
  done
  # if the target is longer than the source, there might be some additional
  # elements in the shifted $0 to append
  if [ $# -gt 0 ]; then
     relativePath=$relativePath/$(echo $* | sed "s/ /\//g")
  fi

  IFS="$currentIFS"
  echo "$relativePath"
}
relativePath2(){
  sourcePath=$1
  targetPath=$2
  currentIFS="$IFS"
  IFS="/"
  relativePath=''
  set -- $targetPath
  for elem in $sourcePath; do
      if [ -z "$relativePath" ]; then
        if [ "$1" = "$elem" ]; then
            shift
            continue
        else
          relativePath="../$elem"
        fi
      else
        if [ -z "$1" ]; then
          relativePath="$relativePath/$elem"
        else
          relativePath="../$relativePath/$elem"
        fi
      fi
    if [ $# -gt 0 ]; then
      shift
    fi
  done
  # if the target is longer than the source, there might be some additional
  # elements in the shifted $0 to append
  if [ $# -gt 0 ]; then
     relativePath=$relativePath/$(echo $* | sed "s/ /\//g")
  fi
  IFS="$currentIFS"
  echo "$relativePath"
}
zopenInitialize()
{
  defineEnvironment
  defineANSI
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

runLogProgress(){
  printVerbose "$1"
  if [ -n "$2" ]; then
    printInfo "- $2"
  else
    printInfo "- Running"
  fi
  if [ -n "$3" ]; then
    completeText="$3"
  else
    completeText="Complete"
  fi
  progressHandler "spinner" "- $completeText" &
  ph=$!
  killph="kill -HUP $ph"
  addCleanupTrapCmd "$killph"
  eval "$1"
  rc=$?
  if [ ! -z "${SSH_TTY}" ]; then
    chtag -r $SSH_TTY
  fi
  $killph 2>/dev/null  # if the timer is not running, the kill will fail
  return $rc
}

spinloop(){
  # in the absence of generic ms/ns reporting, spin-loop instead - not ideal
  # but without pre-reqing packages...
  i=$1
  while [ $i -ge 0 ]; do
    true > /dev/null
    i=$(( i - 1 ))
  done
}
progressNetwork(){
  # Loop until signal received
  icon="-----"
  ansiline 0 0 "$icon"
  while : ; do
    spinloop 1000
    case "$icon" in
      '-----') icon='>----';; '>----') icon='->---';; '->---') icon='-->--';; '-->--') icon='--->-';; '--->-') icon='---->';;
      '---->') icon='----<';; '----<') icon='---<-';; '---<-') icon='--<--';; '--<--') icon='-<---';; '-<---') icon='<----';; '<----') icon='-----';;
    esac
    ansiline 1 -1 "$icon"
  done
}
progressSpinner(){
  # Loop until signal received
  icon="-"
  ansiline 0 0 "$icon"
  while : ; do
    spinloop 1000
    case "$icon" in
      '-') icon='\';; '\') icon='|';; '|') icon='/';; '/') icon='-';;
    esac
    ansiline 1 -1 "$icon"
  done
}
progressHandler() {
    type=$1
    completiontext=$2  # Custom end text (when the process is complete)
    trapcmd="exit;"
    [ -n "$completiontext" ] && trapcmd="/bin/echo \"\047[1A\047[30D\047[2K$completiontext\"; $trapcmd"
    trap "$trapcmd" HUP
    case "$type" in
      "network") progressNetwork;;
      *)         progressSpinner;;
    esac
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

# Used to input sensitive data - turns off echo to the screen for the input
getInputHidden()
{
  # Register trap-handler to try and ensure that we restore the screen to display 
  # chars in the event the script is terminated early (eg. user hits CTRL-C instead of 
  # answering the masked question)
  addCleanupTrapCmd "stty echo"
  stty -echo
  read zopen_input
  echo $zopen_input
  stty echo
}

getInput()
{
  read zopen_input < /dev/tty
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
  if [ -n "$operator" ] && [ -z "$version" ]; then
    printVerbose "$operator ${requestedVersion} requsted, but no version file found in $versionPath." 
    return 1
  elif [ ! -z "$operator" ] && ! compareVersions "${version}" "${requestedVersion}"; then
    printVerbose "$dependency does not satisfy ${version} $operator ${requestedVersion}"
    return 1
  fi
  return 0
}

deleteDuplicateEntries() 
{
  value=$1
  delim=$2
  echo "$value$delim" | awk -v RS="$delim" '!($0 in a) {a[$0]; printf("%s%s", col, $0); col=RS; }' | sed "s/${delim}$//"
}
# reworked version of above to strip blank elements between delims
deleteDuplicateEntriesRedux() 
{
  value=$1
  delim=$2
  echo "$value" | awk -v RS="$delim" -v ORS="$delim" ' {gsub("^[ ]+|[ ]$", "", $0); if (NF>0 && !a[$0]++) {print } }' | sed "s/${delim}$//"
}

zopenInitialize
