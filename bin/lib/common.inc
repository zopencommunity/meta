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

# Merges a package directory's symlinks into the main zopen root filesystem
mergeIntoSystem(){
  name=$1          # Name of the package being processed
  versioneddir=$2  # The directory where the unpax occurred
  rootfs="$3"

  targetdir="$rootfs/usr"     # The main rootfs/usr location

  printVerbose "Calculating the offset path to store from root"
  offset=$(dirname "${versioneddir#$rootfs/}")
  version=$(basename $versioneddir)
  tmptime=$(date +%Y%m%d%H%M%S)
  processingDir="$rootfs/tmp/zopen.$tmptime"
  printVerbose "Temporary processing dir evaluated to: $processingDir"

  virtualStore="$processingDir/$offset"
  printVerbose "Creating virtual store at: $virtualStore"
  mkdir -p "$virtualStore"

  printVerbose "Moving from main store location (unpax-dir) to processing store"
  mv "$versioneddir" "$virtualStore"

  printVerbose "Creating main linked directory in store"
  $(cd "$virtualStore" && ln -s "$version" "$name")

  printVerbose "Creating virtual root directory structure"
  mkdir -p "$processingDir/usr"

  printVerbose "Generating relative symlinks in processing location"
  relpath=$(relativePath2 "$virtualStore/$name" "$processingDir/usr")
  [ "$relpath" = "/" ] && printError "Relative path calculated as root directory itself!?!"

  printVerbose "Generating symlink tree"
  
  printVerbose "Creating directory structure"
  curdir="$PWD"
  cd "$virtualStore/$name"
   # since 'ln *' doesn't invoke globbing to allow multiple files at once,
   # abuse the Recurse option; this results in "already exists" errors but 
   # ignore them as the first call should generate the correct link but 
   # subsequent calls would generate a symlink that has incorrect dereferencing 
   # and ignoring them is actually faster than individually creating the links!
  zosfind . -type d | sort -r | while read dir; do
    dir=$(echo "$dir" | sed "s#^./##")
    printVerbose "Processing dir: $dir" 
    [ $dir = "." ] && continue;
    mkdir -p "$processingDir/usr/$dir"
    cd "$processingDir/usr/$dir"
    dirrelpath=$(relativePath2 "$virtualStore/$name/$dir" "$processingDir/usr/$dir")
    ln -Rs "$dirrelpath/" "." 2>/dev/null
  done 

  printVerbose "Moving unpaxed processing-directory back to main rootfs store"
  # this *must* be done before the merge step below or relative symlinks can't
  # work
  versioneddirname=$(basename "$versioneddir")
  mv "$virtualStore/$versioneddirname" "$rootfs/$offset"

  tarfile="$name.usr.tar"
  printVerbose "Merge symlinks into main filesystem using tmp tar file $tarfile"
  
  printVerbose "Generating intermediary tar file"
  $(cd "$processingDir" && tar -cf "$tarfile" "usr")

  printVerbose "Generating listing for remove processing (including main symlink)"
  listing=$(tar tf "$processingDir/$tarfile" 2>/dev/null| sort -r)
  echo "Installed files:" > "$versioneddir/.links"
  echo "$listing" >>  "$versioneddir/.links"
  cd "$processingDir" && tar xf "$tarfile" -C "$rootfs" 2>/dev/null

  printInfo "- Integration complete"
  return 0
}

symlinkIntoSystem(){
  name=$1
  baseinstalldir=$2

  printInfo "- Integrating package into file system"
  basedir=$baseinstalldir/$name/
  printVerbose "Changing working directory to the install dir for the package"
  cd $basedir

  target="$ZOPEN_ROOTFS/usr"
  dirs=$(zosfind "$basedir" -type d | grep -v "\.git" | sort -r)
  ndirs=$(echo "$dirs" | wc -l | tr -d ' ')
  dircnt=0
  echo "# Installed links by package: $name" > $basedir/.links
  printInfo "${ERASELINE}- Processing ${dircnt} of ${ndirs}: ${pct}% (${flecnt}/${nfiles})"
  echo "$dirs" | while read dir; do
    dircnt=$(expr $dircnt + 1)
    trimdir=$(echo "$dir" | sed "s#^$basedir##")
    if [[ ! "x$trimdir" = "x" ]]; then 
      mkdir -p "$target/$trimdir"
      filestolink=$(zosfind "$dir" -type f)
      nfiles=$(echo "$filestolink" | wc -l | tr -d ' ')
      flecnt=0
      pct=0
      ansiline 1 0 "${ERASELINE}- Processing ${dircnt} of ${ndirs}: ${pct}% (${flecnt}/${nfiles})"
      echo "$filestolink" | while read filetolink; do
        flecnt=$(expr $flecnt + 1)
        pct=`expr $flecnt \* 100`
        pct=`expr $pct / $nfiles`
        ansiline 1 0 "${ERASELINE}- Processing ${dircnt} of ${ndirs}: ${pct}% (${flecnt}/${nfiles})"
        trimfile=$(echo $filetolink | sed "s#^$basedir##")
        if [ ! -z $trimfile ]; then
          relpath=$(relativePath "$target/$trimfile" "$filetolink" )
          exename="$(basename $filetolink)"
          rootdir="$(dirname $target/$trimfile)"
          if cd $rootdir && ln -fs $relpath $exename; then
            abspath=$(echo "$target/$trimfile" | sed "s#^$ZOPEN_ROOTFS/##")
            printVerbose "Converted relative path '$relpath' to absolute under zopen_rootfs: $abspath"
            echo "$abspath " >> $basedir/.links
          else
            printInfo "${ERASELINE}- ${NC}${RED}Issue with linking '$filetolink' to '$target/$trimfile'${NC}"
            printInfo "\n${ERASELINE}- Processing ${dircnt} of ${ndirs}: ${pct}% (${flecnt}/${nfiles})"
          fi
        fi
      done
    fi
  done
  ansiline 1 0 "${ERASELINE}- Processed ${ndirs} of ${ndirs}"
  printInfo "- Integration complete"
}

# The following function will remove any orphaned symlinks left after either:
# - a different version has been installed (where the old symlinks are not reused for
#   that different version  version ie. the file has been removed from updated version
# - the main package->version-dir symlink has been removed (which renders any symlinks to
#   it as dangling so removable)
unsymlinkFromSystem(){
  pkg=$1
  rootfs=$2
  dotlinks=$3
  if [ -e "$dotlinks" ]; then
    printInfo "- Checking for obsoleted files in $rootfs/usr/ tree from $pkg"
    # Use sed to skip header line in .links file
    # Note that the contents of the links file are ordered such that
    # processing occurs depth-first; if, after removing orphaned symlinks,
    # a directory is empty, then it can be removed.
    nfiles=$(sed '1d;$d' "$dotlinks" | wc -l  | tr -d ' ')
    flecnt=0
    pct=0
    printInfo "- Processing ${pct}% (${flecnt}/${nfiles})"
    sed '1d;$d' "$dotlinks"| while read filetounlink; do
      flecnt=$(expr $flecnt + 1)
      pct=`expr $flecnt \* 100`
      pct=`expr $pct / $nfiles`
      ansiline 1 0 "${ERASELINE}- Processing ${pct}% (${flecnt}/${nfiles})"
      filetounlink="${filetounlink% symbolic.*}"
      if [ -d "$ZOPEN_ROOTFS/$filetounlink" ]; then
        # rmdir will fail if the directory is not empty - which is what is required,
        # we either need to remove the empty directory or leave it in place as it is 
        # still in use
        rmdir "$rootfs/$filetounlink" 2>/dev/null
      elif [ -L "$rootfs/$filetounlink" ] && [ ! -e $rootfs/$filetounlink ]; then
        # the linked-to file no longer exists (ie. the symlink is dangling)
        rm -f "$rootfs/$filetounlink"
      fi
    done
    ansiline 1 0 "${ERASELINE}- Processed 100% (${nfiles}/${nfiles})"
  else
    printError "Could not locate list of current links to verify, dangling links might be present; run 'zopen clean'"
  fi
}

zopenInitialize()
{
  defineEnvironment
  defineANSI
  processConfig
}

printVerbose()
{
  [ -z "${-%%*x*}" ] && set +x && xtrc="-x" || xtrc=""
  if ${verbose}; then
    printColors "${NC}${GREEN}${BOLD}VERBOSE${NC}: '${1}'" >&2
  fi
  [ ! -z "$xtrc" ] && set -x
}

printHeader()
{
  [ -z "${-%%*x*}" ] && set +x && xtrc="-x" || xtrc=""
  printColors "${NC}${YELLOW}${BOLD}${UNDERLINE}${1}${NC}" >&2
  [ ! -z "$xtrc" ] && set -x
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
    [ -z "${-%%*x*}" ] && set +x  # Disable -x debug if set for this process
    type=$1
    completiontext=$2  # Custom end text (when the process is complete)
    
    # Check if there is a file redirect for stdout (where we echo progress to)
    # If so, then adding progress to the file will cause large volumes of tty commands
    # to be written - best to have no progress so ignore
    [ ! -t 1 ] && return
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
  [ -z "${-%%*x*}" ] && set +x && xtrc="-x" || xtrc=""
  printColors "${NC}${RED}${BOLD}***ERROR: ${NC}${RED}${1}${NC}" >&2
  [ -n "$xtrc" ] && set -x
}

printError()
{
  [ -z "${-%%*x*}" ] && set +x && xtrc="-x" || xtrc=""
  printColors "${NC}${RED}${BOLD}***ERROR: ${NC}${RED}${1}${NC}" >&2
  [ -n "$xtrc" ] && set -x
  cleanupFunction
  exit 4
}

printWarning()
{
  [ -z "${-%%*x*}" ] && set +x && xtrc="-x" || xtrc=""
  printColors "${NC}${YELLOW}${BOLD}***WARNING: ${NC}${YELLOW}${1}${NC}" >&2
  [ -n "$xtrc" ] && set -x
}

printInfo()
{
  [ -z "${-%%*x*}" ] && set +x && xtrc="-x" || xtrc=""
  printColors "$1" >&2
  [ -n "$xtrc" ] && set -x
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
  if [ -z "$ZOPEN_ROOTFS" ]; then
    if [ -f "$HOME/.zopen-config" ]; then
      . "$HOME/.zopen-config"
    fi
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

# Logging Types
LOG_E="ERROR"    # If there was a failure and a command failed
LOG_W="WARNING"  # If an error occurred but there was a workaround/fallback
LOG_I="INFO"     # General information
LOG_A="AUDIT"    # Security-type log for admin activities

# Logging Categories - more than one possible for a log entry
CAT_CONFIG="C"    # Configuration change
CAT_FILE="F"      # File handling (eg. downloading)
CAT_INSTALL="I"   # Install processing
CAT_NETWORK="N"   # Network processing
CAT_PKG="P"       # Package handling
CAT_QUERY="Q"     # Query processing
CAT_REMOVE="R"    # Removal handling
CAT_SYS="S"       # Related to the underlying native z/OS system
CAT_ZOPEN="Z"     # Related to the zopen system itself

syslog() {
  fd=$1
  type=$2
  categories=$3
  module=$4
  location=$5
  msg=$6
  if [ ! -e "$fd" ]; then
    mkdir -p "$(dirname "$fd")"
    touch "$fd"
  fi
  echo $(date +"%F %T") $(id | cut -d' ' -f1)::$module:$type:$categories:$location:$msg >> $fd

}
zopenInitialize
