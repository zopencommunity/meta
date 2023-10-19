#!/bin/false
# This file is only meant to be source'd hence the dummy hashbang
# shellcheck shell=sh
#

addCleanupTrapCmd()
{
  newCmd=$(echo "$1" | sed -e 's/^[ ]*//' -e 's/[ ]*$//')
  if [ -e "${ZOPEN_CLEANUP_PIPE}" ]; then
    (echo "${newCmd}" > "${ZOPEN_CLEANUP_PIPE}")&
  else
    printSoftError "Cleanup pipeline not available; temporary files and resources might not be cleared"
  fi
}

cleanupFunction()
{
  # Only action the cleanup pipeline when not in a sub-zopen-process
  parentCmd=$(ps -o args= -p "${PPID}")
  if [ -z "$parentCmd" ]; then
    printDebug "ps did not list the process details for parent \$PPID=${PPID}"
    return
  fi
  if echo "${parentCmd}" | grep "/bin/zopen" > /dev/null 2>&1; then
    # we are a child of a zopen process so do not attempt to cleanuup yet!
    return
  fi

  if [ -e "${ZOPEN_CLEANUP_PIPE}" ]; then
    # Add a cleanup of the pipe for when we are finished - explicitly
    # add to the pipeline as if a user has CTRL-C'd early, that can 
    # trigger cleanup with an empty pipeline, leaving the read of the pipe
    # waiting indefinitely
    addCleanupTrapCmd "rm -rf \"${ZOPEN_CLEANUP_PIPE}\""
    while read cleanupcmd; do
      eval "${cleanupcmd}" 2>/dev/null
    done < "${ZOPEN_CLEANUP_PIPE}"
    
    unset ZOPEN_CLEANUP_PIPE
  fi
  trap - EXIT INT TERM QUIT HUP
}

# getCurrentVersionDir
# returns the version directory that has been set as active/installed
# indicating that the $needle is active.
# inputs: $1 - package to get currently active version of
# return: 0  for success (output of pwd -P command)
#         4  if unable to access version directory (eg. not installed)
#         !0 cd or pwd -P failed
getCurrentVersionDir(){
  needle="$1"
  [ ! -L "${ZOPEN_PKGINSTALL}/${needle}/${needle}" ] \
    && echo ""\
    && return 4
  cd "${ZOPEN_PKGINSTALL}/${needle}/${needle}" 2> /dev/null \
    && pwd -P 2> /dev/null
}

# isPackageActive
# returns whether the package is active ie. has a symlink from 
#  $PKGINSTALL/pkg/pkg to a versioned directory
# inputs: $1 - package to get currently active version of
# return: 0  for active
#         !0 for not active
isPackageActive(){
  needle="$1"
  getCurrentVersionDir "$needle"
}

# Generate a file name that has a high probability of being unique for
# use as a temporary filename - the filename should be unique in the 
# instance it was generated and probability suggests it should be for
# a "reasonable" time after...
mktempfile()
{
  prefix="zopen_$1"
  suffix=".tmp"
  [ -n "$2" ] && [ ! "$2" = "." ] && suffix="$2"
  for tmp in "${TMPDIR}" "${TMP}" /tmp; do
    [ -n "${tmp}" ] && [ -d "${tmp}" ] && break
  done
  [ ! -d "${tmp}" ] && printError "Could not locate suitable temporary directory [tried \$TMPDIR \$TMP & /tmp]. Define a temporary location and retry command"
  rnd=$(od -vAn -tu8 -N8  < /dev/urandom | tr -d "[:blank:]")
  tempfile="${tmp}/${prefix%%_}_${rnd}.${suffix##.}"
  if [ -e  "${tempfile}" ]; then
    mktempfile "$1" "${suffix}" # recurse and try again
  else
    echo "${tempfile}"
  fi
}

# Create a temporary directory
mktempdir()
{
  tempdir=$(mktempfile "$1")
  [ ! -e "${tempdir}" ] && mkdir "${tempdir}" && addCleanupTrapCmd "rm -rf ${tempdir}" && echo "${tempdir}"
}

isPermString()
{
  test=$(echo "$1" | zossed "s/[-+rwxugo,=]//g")
  if [ -n "${test}" ]; then
    printDebug "Permission string '$1' was invalid"
    false; 
  else
    true;
  fi
  return # the output of the last command
}

writeConfigFile(){
  configFile="$1"
  rootfs="$2"
  pkginstall="$3"
  certPath="$4"

  cat << EOF >  "${configFile}"
# z/OS Open Tools Configuration file
# Main root location for the zopen installation; can be changed if the
# underlying root location is copied/moved elsewhere as locations are
# relative to this envvar value
ZOPEN_ROOTFS=\"\${ZOPEN_ROOTFS}:${rootfs}\"
export ZOPEN_ROOTFS
zot=\"z/OS Open Tools\"

sanitizeEnvVar(){
  # remove any envvar entries that match the specified regex
  value="\$1"
  delim="\$2"
  prefix="\$3"
  echo "\${value}" | awk -v RS="\${delim}" -v DLIM="\${delim}" -v PRFX="\${prefix}" '{ if (match(\$1, PRFX)==0) {printf("%s%s",\$1,DLIM)}}'
}

deleteDuplicateEntries() 
{
  value="\$1"
  delim="\$2"
  echo "\${value}\${delim}" | awk -v RS="\${delim}" '!(\$0 in a) {a[\$0]; printf("%s%s", col, \$0); col=RS; }' | sed "s/\${delim}$//"
}

# z/OS Open Tools environment variables
ZOPEN_PKGINSTALL=\${ZOPEN_ROOTFS}/${pkginstall}
export ZOPEN_PKGINSTALL
ZOPEN_SEARCH_PATH=\${ZOPEN_ROOTFS}/usr/share/zopen/
export ZOPEN_SEARCH_PATH
ZOPEN_CA=\"\${ZOPEN_ROOTFS}/${certPath}\"
export ZOPEN_CA
ZOPEN_LOG_PATH=\${ZOPEN_ROOTFS}/var/log
export ZOPEN_LOG_PATH

# Custom parameters for zopen default tooling
# Add any custom parameters for curl
ZOPEN_CURL_PARAMS=""

# Environment variables

if [ -z "\${ZOPEN_QUICK_LOAD}" ]; then
  if [ -e "\${ZOPEN_ROOTFS}/etc/profiled" ]; then
    dotenvs=\$(find "\${ZOPEN_ROOTFS}/etc/profiled" -type f -name 'dotenv' -print)
    printf "Processing \$zot configuration..."
    for dotenv in \$dotenvs; do
      . \$dotenv
    done 
    /bin/echo "DONE"
    unset dotenvs
  fi
fi
PATH=\${ZOPEN_ROOTFS}/usr/local/bin:\${ZOPEN_ROOTFS}/usr/bin:\${ZOPEN_ROOTFS}/bin:\${ZOPEN_ROOTFS}/boot:\$(sanitizeEnvVar \"\${PATH}\" \":\" \"^\${ZOPEN_PKGINSTALL}/.*\$\")
export PATH=\$(deleteDuplicateEntries \"\${PATH}\" \":\")
LIBPATH=\${ZOPEN_ROOTFS}/usr/local/lib:\${ZOPEN_ROOTFS}/usr/lib:\$(sanitizeEnvVar "\${LIBPATH}" ":" "^\${ZOPEN_PKGINSTALL}/.*\$")
export LIBPATH=\$(deleteDuplicateEntries \"\${LIBPATH}\" \":\")
MANPATH=\${ZOPEN_ROOTFS}/usr/local/share/man:\${ZOPEN_ROOTFS}/usr/local/share/man/\%L:\${ZOPEN_ROOTFS}/usr/share/man:\${ZOPEN_ROOTFS}/usr/share/man/\%L:\$(sanitizeEnvVar \"\${MANPATH}\" \":\" \"^\${ZOPEN_PKGINSTALL}/.*\$\")
export MANPATH=\$(deleteDuplicateEntries \"\${MANPATH}\" \":\")
EOF

}

curlCmd()
{
  # Take the list of parameters and concat them with
  # any custom parameters the user requires in ZOPEN_CURL_PARAMS
  curl ${ZOPEN_CURL_PARAMS} $*
}

validateReleaseLine()
{
  echo "$1" | awk '
    toupper($1)=="DEV"    {print toupper($0)}
    toupper($1)=="STABLE" {print toupper($0)}
                          { print ""}
  '
}

# Attempt to fully dereference a symlink without any bashisms or arcane set logic
# using some simplistic (recursive!) logic
deref()
{
  testpath="$1"
  if [ -L "${testpath}" ]; then
    child=$(basename "${testpath}")
    symlink=$(ls -l "${testpath}" | sed 's/.*-> \(.*\)/\1/')
    parent=$(dirname "${testpath}")
    relpath="${parent}/${symlink}"
    relparent=$(dirname "${relpath}")
    abspath=$(cd "${relparent}" && pwd -P)
    testpath="${abspath}/${child}"
    deref "${testpath}"
  else
    [ -n "${testpath}" ] && echo "${testpath}" && unset testpath
  fi
}

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

ansiline()
{
  deltax=$1
  deltay=$2
  echostr=$3
  if [ ${deltax} -gt 0 ]; then
    echostr="${ESC}[${deltax}A${echostr}"
  elif [ ${deltax} -lt 0 ]; then
    echostr="${ESC}[$(expr ${deltax} \* -1)A${echostr}"
  fi
  if [ ${deltay} -gt 0 ]; then
    echostr="${ESC}[${deltax}C${echostr}"
  elif [ ${deltay} -lt 0 ]; then
    echostr="${ESC}[$(expr ${deltax} \* -1)D${echostr}"
  fi
  /bin/echo "${echostr}"

}

getScreenCols()
{
  # Note tput does not handle ssh sessions too well...
  stty | awk -F'[/=;]' '/columns/ { print $4}' | tr -d " "
}

zossed()
{
  # Use the standard z/OS sed utility; If the sed package is installed
  # GNU sed becomes the dominant version which might change how
  # matching is performed
  /bin/sed "$@"
}

zosfind()
{
  # Use the standard z/OS find utility; If the findutils package is installed,
  # the installed find command takes precedence but is not compatible with the
  # standard zos find [regex searches for "-name" are not allowed, but
  # "-wholename" is not available on standard zosfind. For the tooling to be
  # consistent across platforms (where findutils is/is not installed) use the
  # standard zos version
  /bin/find "$@"
}

findrev()
{
  haystack="$1"
  needle="$2"
  while [[ "${haystack}" != "" && "${haystack}" != "/" && "${haystack}" != "./" && ! -e "${haystack}/${needle}" ]]; do
    haystack=${haystack%/*}
  done
  echo "${haystack}"
}

strtrim()
{
  echo "$1" | sed -e 's/^[ ]*//' -e 's/[ ]*$//'
}

defineEnvironment()
{
  # Required for proper operation of z/OS auto-conversion support
  export _BPXK_AUTOCVT=ON
  export _CEE_RUNOPTS="${_CEE_RUNOPTS} FILETAG(AUTOCVT,AUTOTAG) POSIX(ON)"
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

  # Set a default umask of read and execute for user and group
  umask 0022
}

#
# For now, explicitly specify /bin/echo to ensure we get the EBCDIC echo since the escape
# sequences are EBCDIC escape sequences
#
printColors()
{
  /bin/echo "$@"
}

mutexReq()
{
  mutex=$1
  lockdir="${ZOPEN_ROOTFS}/var/lock"
  [ -e lockdir ] || mkdir -p ${lockdir}
  mutex="${lockdir}/${mutex}"
  mypid=$(exec sh -c 'echo ${PPID}')
  if [ -e "${mutex}" ]; then
    lockedpid=$(cat ${mutex})
    {
      [ ! "${lockedpid}" = "${mypid}" ] && [ ! "${lockedpid}" = "${PPID}" ]
    } && kill -0 "${lockedpid}" 2> /dev/null && echo "Aborting, Active process '${lockedpid}' holds the '$2' lock: '${mutex}'" && exit -1
  fi
  addCleanupTrapCmd "rm -rf ${mutex}"
  echo "${mypid}" > ${mutex}
}

mutexFree()
{
  mutex=$1
  lockdir="${ZOPEN_ROOTFS}/var/lock"
  mutex="${lockdir}/${mutex}"
  [ -e "${mutex}" ] && rm -f ${mutex}
}

relativePath2()
{
  sourcePath=$1
  targetPath=$2
  currentIFS="${IFS}"
  IFS="/"
  relativePath=''
  set -- ${targetPath}
  for elem in ${sourcePath}; do
    if [ -z "${relativePath}" ]; then
      if [ "$1" = "${elem}" ]; then
        shift
        continue
      else
        relativePath="../${elem}"
      fi
    else
      if [ -z "$1" ]; then
        relativePath="${relativePath}/${elem}"
      else
        relativePath="../${relativePath}/${elem}"
      fi
    fi
    if [ $# -gt 0 ]; then
      shift
    fi
  done
  # if the target is longer than the source, there might be some additional
  # elements in the shifted $0 to append
  if [ $# -gt 0 ]; then
    relativePath=${relativePath}/$(echo $* | sed "s/ /\//g")
  fi
  IFS="${currentIFS}"
  echo "${relativePath}"
}

# Merges a package directory's symlinks into the main zopen root filesystem
mergeIntoSystem()
{
  name=$1         # Name of the package being processed
  versioneddir=$2 # The directory where the unpax occurred
  rootfs="$3"
  rebaseusr="$4"

  [ -z "${rebaseusr}" ] && rebaseusr="usr/local"

  currentDir="${PWD}"
  targetdir="${rootfs}/${rebaseusr}" # The main rootfs/usr location

  printDebug "Calculating the offset path to store from root"
  offset=$(dirname "${versioneddir#"${rootfs}"/}")
  version=$(basename ${versioneddir})
  tmptime=$(date +%Y%m%d%H%M%S)
  processingDir="${rootfs}/tmp/zopen.${tmptime}"
  printDebug "Temporary processing dir evaluated to: ${processingDir}"

  virtualStore="${processingDir}/${offset}"
  printDebug "Creating virtual store at: ${virtualStore}"
  mkdir -p "${virtualStore}"

  printDebug "Moving from main store location (unpax-dir) to processing store"
  mv "${versioneddir}" "${virtualStore}"

  printDebug "Creating main linked directory in store"
  $(cd "${virtualStore}" && ln -s "${version}" "${name}")

  printDebug "Creating virtual root directory structure"
  mkdir -p "${processingDir}/${rebaseusr}"

  printDebug "Generating relative symlinks in processing location"
  relpath=$(relativePath2 "${virtualStore}/${name}" "${processingDir}/${rebaseusr}")
  [ "${relpath}" = "/" ] && printError "Relative path calculated as root directory itself!?!"

  printDebug "Generating symlink tree"

  printDebug "Creating directory structure"
  curdir="${PWD}"
  cd "${virtualStore}/${name}" || exit
  # since 'ln *' doesn't invoke globbing to allow multiple files at once,
  # abuse the Recurse option; this results in "already exists" errors but
  # ignore them as the first call should generate the correct link but
  # subsequent calls would generate a symlink that has incorrect dereferencing
  # and ignoring them is actually faster than individually creating the links!
  zosfind . -type d | sort -r | while read dir; do
    dir=$(echo "${dir}" | sed "s#^./##")
    printDebug "Processing dir: ${dir}"
    [ ${dir} = "." ] && continue
    mkdir -p "${processingDir}/${rebaseusr}/${dir}"
    cd "${processingDir}/${rebaseusr}/${dir}" || exit
    dirrelpath=$(relativePath2 "${virtualStore}/${name}/${dir}" "${processingDir}/${rebaseusr}/${dir}")
    ln -Rs "${dirrelpath}/" "." 2> /dev/null
  done

  printDebug "Moving unpaxed processing-directory back to main rootfs store"
  # this *must* be done before the merge step below or relative symlinks can't
  # work
  versioneddirname=$(basename "${versioneddir}")
  mv "${virtualStore}/${versioneddirname}" "${rootfs}/${offset}"

  tarfile="${name}.usr.tar"
  printDebug "Merge symlinks into main filesystem using tmp tar file ${tarfile}"

  printDebug "Generating intermediary tar file"
  # Need '-S' to allow long symlinks
  $(cd "${processingDir}" && tar -S -cf "${tarfile}" "usr")

  printDebug "Generating listing for remove processing (including main symlink)"
  listing=$(tar tf "${processingDir}/${tarfile}" 2> /dev/null | sort -r)
  echo "Installed files:" > "${versioneddir}/.links"
  echo "${listing}" >> "${versioneddir}/.links"

  printDebug "Extracting tar to rootfs"
  cd "${processingDir}" && tar xf "${tarfile}" -C "${rootfs}" 2> /dev/null

  printDebug "Cleaning temp resources"
  rm -rf "${processingDir}" 2> /dev/null

  printDebug "Switching to previous cwd - current work dir was purged"
  cd "${currentDir}" || exit

  printInfo "- Integration complete"
  return 0
}

# The following function will remove any orphaned symlinks left after either:
# - a different version has been installed (where the old symlinks are not reused for
#   that different version  version ie. the file has been removed from updated version
# - the main package->version-dir symlink has been removed (which renders any symlinks to
#   it as dangling so removable)
unsymlinkFromSystem()
{
  pkg=$1
  rootfs=$2
  dotlinks=$3
  if [ -e "${dotlinks}" ]; then
    printInfo "- Checking for obsoleted files in ${rootfs}/usr/ tree from ${pkg}"
    # Use sed to skip header line in .links file
    # Note that the contents of the links file are ordered such that
    # processing occurs depth-first; if, after removing orphaned symlinks,
    # a directory is empty, then it can be removed.
    nfiles=$(sed '1d;$d' "${dotlinks}" | wc -l | tr -d ' ')
    flecnt=0
    pct=0

    printDebug "Creating Temporary dirname file"
    tempDirFile="${ZOPEN_ROOTFS}/tmp/zopen.rmdir.${RANDOM}"
    tempTrash="${tempDirFile}.trash"
    [ -e "${tempDirFile}" ] && rm -f "${tempDirFile}" > /dev/null 2>&1
    touch "${tempDirFile}"
    addCleanupTrapCmd "rm -rf ${tempDirFile}"
    printDebug "Using temporary file ${tempDirFile}"
    printInfo "- Checking ${nfiles} potential links"

    rm_fileprocs=15
    [ -e "${rootfs}/etc/zopen/rm_fileprocs" ] && rm_fileprocs=$(cat "${rootfs}/etc/zopen/rm_fileprocs")
    threshold=$((nfiles / rm_fileprocs))
    threshold=$((threshold + 1))
    printDebug "Threshold of files per worker [files/procs] calculated as: ${threshold}"
    [ "${threshold}" -le 50 ] && threshold=50 && printVerbose "Threshold below min: using 50" # Don't spawn too many
    printDebug "Starting spinner..."
    progressHandler "spinner" "- Complete" &
    ph=$!
    killph="kill -HUP ${ph}"
    addCleanupTrapCmd "${killph}"

    printDebug "Spawning as subshell to handle threading"
    # Note that this all must happen in a subshell as the above started
    # progressHandler is a signal-terminated process - and a wait issued in
    # the parent will never complete until that ph is signalled/terminated!
    deletethreads=$(
      tid=0
      filenames=""
      while read filetounlink; do
        tid=$((tid + 1))
        filetounlink=$(echo "${filetounlink}" | sed 's/\(.*\).symbolic.*/\1/')
        filenames=$(/bin/printf "%s\n%s" "${filenames}" "${filetounlink}")
        if [ "$((tid % threshold))" -eq 0 ]; then
          deletethread "${filenames}" "${tempDirFile}" &
          printDebug "Started delete thread: $!"
          filenames=""
        fi
      done << EOF
$(sed '1d;$d' "${dotlinks}")
EOF
      if [ -n "${filenames}" ]; then
        # Handle when there are not enough to trigger the threshold of a new thread above,
        # there will still be items in the "array"
        deletethread "${filenames}" "${tempDirFile}" #&
        printDebug "Started delete thread: $!"
      fi
      wait
    )
    ${killph} 2> /dev/null # if the timer is not running, the kill will fail
    if [ -e "${tempDirFile}" ]; then
      ndirs=$(cat "${tempDirFile}" | uniq | wc -l | tr -d ' ')
      printInfo "- Checking ${ndirs} dir links"
      for d in $(cat "${tempDirFile}" | uniq | sort -r); do
        [ -d "${d}" ] && rmdir "${d}" > /dev/null 2>&1
      done
    fi
  else
    printWarning "Could not locate list of current links to verify, dangling links might be present; run 'zopen clean -d'"
  fi
}

deletethread()
{
  filestodelete="$1"
  tempDirFile="$2"
  echo "${filestodelete}" | while read filetounlink; do
    deletetask "${tempDirFile}" "${filetounlink}"
  done
}

deletetask()
{
  tempDirFile="$1"
  filename="$2"
  [ -z "${filename}" ] && return 0
  filename="${ZOPEN_ROOTFS}/${filename}"
  if [ -d "${filename}" ]; then
    # Add to the queue for checking once files are gone if unique
    ispresent=$(grep "^${filename}[ ]*$" "${tempDirFile}")
    if [ -z "${ispresent}" ]; then
      echo " ${filename} " >> "${tempDirFile}"
    else
      alreadyfound=""
    fi
  elif [ -L "${filename}" ]; then
    if [ ! -f "${filename}" ]; then
      # the linked-to file no longer exists (ie. the symlink is dangling)
      rm -f "${filename}" > /dev/null 2>&1
    fi
  else
    echo "Unprocessable file: '${filename}'" >> "${tempTrash}"
  fi
}

zopenInitialize()
{
  # Create the cleanup pipeline and exit handler
  trap "cleanupFunction" EXIT INT TERM QUIT HUP
  [ -z "${ZOPEN_CLEANUP_PIPE}" ] \
  && [ ! -p "${ZOPEN_CLEANUP_PIPE}" ] \
  && ZOPEN_CLEANUP_PIPE=$(mktempfile "clean" "pipe") \
  && mkfifo "${ZOPEN_CLEANUP_PIPE}" \
  && chtag -tc 819 "${ZOPEN_CLEANUP_PIPE}" \
  && export ZOPEN_CLEANUP_PIPE

  addCleanupTrapCmd "stty echo" # set this as a default to ensure line visibility!
  defineEnvironment
  defineANSI
  if [ -z "${ZOPEN_DONT_PROCESS_CONFIG}" ]; then
    processConfig
  fi

  ZOPEN_JSON_CACHE_URL="https://zosopentools.github.io/meta/api/zopen_releases.json"
}


printDebug()
{
  [ -z "${-%%*x*}" ] && set +x && xtrc="-x" || xtrc=""
  if ${debug}; then
    printColors "${NC}${BLUE}${BOLD}:DEBUG:${NC}: '${1}'" >&2
  fi
  [ ! -z "${xtrc}" ] && set -x
  return 0
}

printVerbose()
{
  [ -z "${-%%*x*}" ] && set +x && xtrc="-x" || xtrc=""
  if ${verbose}; then
    printColors "${NC}${GREEN}${BOLD}VERBOSE${NC}: '${1}'" >&2
  fi
  [ ! -z "${xtrc}" ] && set -x
  return 0
}

printHeader()
{
  [ -z "${-%%*x*}" ] && set +x && xtrc="-x" || xtrc=""
  printColors "${NC}${YELLOW}${BOLD}${UNDERLINE}${1}${NC}" >&2
  [ ! -z "${xtrc}" ] && set -x
  return 0
}

runAndLog()
{
  printVerbose "$1"
  eval "$1"
  rc=$?
  if [ ! -z "${SSH_TTY}" ]; then
    chtag -r ${SSH_TTY}
  fi
  return "${rc}"
}

runLogProgress()
{
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
  progressHandler "spinner" "- ${completeText}" &
  ph=$!
  killph="kill -HUP ${ph}"
  addCleanupTrapCmd "${killph}"
  eval "$1"
  rc=$?
  if [ ! -z "${SSH_TTY}" ]; then
    chtag -r ${SSH_TTY}
  fi
  ${killph} 2> /dev/null # if the timer is not running, the kill will fail
  return "${rc}"
}

spinloop()
{
  # in the absence of generic ms/ns reporting, spin-loop instead - not ideal
  # but without pre-reqing packages...
  i=$1
  while [ ${i} -ge 0 ]; do
    true > /dev/null
    i=$((i - 1))
  done
}

progressNetwork()
{
  # Loop until signal received
  icon="-----"
  ansiline 0 0 "${icon}"
  while :; do
    spinloop 1000
    case "${icon}" in
    '-----') icon='>----' ;; '>----') icon='->---' ;; '->---') icon='-->--' ;; '-->--') icon='--->-' ;; '--->-') icon='---->' ;;
    '---->') icon='----<' ;; '----<') icon='---<-' ;; '---<-') icon='--<--' ;; '--<--') icon='-<---' ;; '-<---') icon='<----' ;; '<----') icon='-----' ;;
    esac
    ansiline 1 -1 "${icon}"
  done
}

progressSpinner()
{
  # Loop until signal received
  icon="-"
  ansiline 0 0 "${icon}"
  while :; do
    spinloop 1000
    case "${icon}" in
    '-') icon='\' ;; '\') icon='|' ;; '|') icon='/' ;; '/') icon='-' ;;
    esac
    ansiline 1 -1 "${icon}"
  done
}

progressHandler()
{
  if [ ! "${_BPX_TERMPATH-x}" = "OMVS" ] && [ -z "${NO_COLOR}" ] && [ ! "${FORCE_COLOR-x}" = "0" ] && [ -t 1 ] && [ -t 2 ]; then
    [ -z "${-%%*x*}" ] && set +x # Disable -x debug if set for this process
    type=$1
    completiontext=$2 # Custom end text (when the process is complete)

    trapcmd="exit;"
    [ -n "${completiontext}" ] && trapcmd="/bin/echo \"\047[1A\047[30D\047[2K${completiontext}\"; ${trapcmd}"
    trap "${trapcmd}" HUP
    case "${type}" in
    "network") progressNetwork ;;
    *) progressSpinner ;;
    esac
  fi
}

runInBackgroundWithTimeoutAndLog()
{
  command="$1"
  timeout="$2"

  printVerbose "${command} with timeout of ${timeout}s"
  eval "${command} &; TEEPID=$!"
  PID=$!
  n=0
  while [ ${n} -le ${timeout} ]; do
    kill -0 "${PID}" 2> /dev/null
    if [ $? != 0 ]; then
      wait "${PID}"
      if [ ! -z "${SSH_TTY}" ]; then
        chtag -r ${SSH_TTY}
      fi
      rc=$?
      return "${rc}"
    else
      sleep 1
      n=$(expr ${n} + 1)
    fi
  done
  kill -9 "${PID}"
  kill -9 ${TEEPID}
  printError "TIMEOUT: (PID: ${PID}): ${command}"
}

printSoftError()
{
  [ -z "${-%%*x*}" ] && set +x && xtrc="-x" || xtrc=""
  printColors "${NC}${RED}${BOLD}***ERROR: ${NC}${RED}${1}${NC}" >&2
  [ -n "${xtrc}" ] && set -x
}

printError()
{
  [ -z "${-%%*x*}" ] && set +x && xtrc="-x" || xtrc=""
  printColors "${NC}${RED}${BOLD}***ERROR: ${NC}${RED}${1}${NC}" >&2
  [ -n "${xtrc}" ] && set -x
  mutexFree "zopen" # prevent lock from lingering around after an error
  cleanupFunction
  exit 4
}

printWarning()
{
  [ -z "${-%%*x*}" ] && set +x && xtrc="-x" || xtrc=""
  printColors "${NC}${YELLOW}${BOLD}***WARNING: ${NC}${YELLOW}${1}${NC}" >&2
  [ -n "${xtrc}" ] && set -x
  return 0
}

printInfo()
{
  [ -z "${-%%*x*}" ] && set +x && xtrc="-x" || xtrc=""
  printColors "$1" >&2
  [ -n "${xtrc}" ] && set -x
  return 0
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
  echo ${zopen_input}
  stty echo
}

getInput()
{
  read zopen_input
  echo ${zopen_input}
}

printElapsedTime()
{
  printType=$1
  functionName=$2
  startTime=$3
  elapsedTime=$((${SECONDS} - ${startTime}))

  elapsedTimeOutput="${functionName} completed in ${elapsedTime} seconds."

  case ${printType} in
  "info")
    printInfo "${elapsedTimeOutput}"
    ;;
  "verbose")
    printVerbose "${elapsedTimeOutput}"
    ;;
  esac
}

processConfig()
{
  export ZOPEN_QUICK_LOAD=1
  if [ -z "${ZOPEN_ROOTFS}" ]; then
    relativeRootDir="$(cd "$(dirname "$0")/../.." > /dev/null 2>&1 && pwd -P)"
    if [ -f "${relativeRootDir}/etc/zopen-config" ]; then
      . "${relativeRootDir}/etc/zopen-config"
    else
      printError "Source the zopen-config prior to running $0"
    fi
  fi
}

checkIfConfigLoaded()
{
  if [ -z "${ZOPEN_CA}" ]; then
    errorMessage="\${ZOPEN_CA} was not set. Ensure zopen init has run and zopen-config has been sourced."
  fi
  if [ ! -r "${ZOPEN_CA}" ]; then
    errorMessage="Certificate at ${ZOPEN_CA} could not be accessed. Ensure zopen init has run and zopen-config has been sourced."
  fi

  if [ ! -z "${errorMessage}" ]; then
    if [ -r "${mydir}/../../../etc/zopen-config" ]; then
      relativeConfigDir="$(cd "$(dirname "${mydir}")/../../etc/" > /dev/null 2>&1 && pwd -P)"
      errorMessage="${errorMessage} Run '. ${relativeConfigDir}/zopen-config'  or add it to your .profile."
    fi
    printError "${errorMessage}"
  fi
}

parseDeps()
{
  dep="$1"
  version=$(echo ${dep} | awk -F '[>=<]+' '{print $2}')
  if [ -z "${version}" ]; then
    operator=""
    dep=$(echo ${dep} | awk -F '[>=<]+' '{print $1}')
  else
    operator=$(echo ${dep} | awk -F '[0-9.]+' '{print $1}' | awk -F '^[a-zA-Z]+' '{print $2}')
    dep=$(echo ${dep} | awk -F '[>=<]+' '{print $1}')
    case ${operator} in
    ">=") ;;
    "=") ;;
    *) printError "${operator} is not supported." ;;
    esac
    major=$(echo ${version} | awk -F. '{print $1}')
    minor=$(echo ${version} | awk -F. '{print $2}')
    if [ -z "${minor}" ]; then
      minor=0
    fi
    patch=$(echo ${version} | awk -F. '{print $3}')
    if [ -z "${patch}" ]; then
      patch=0
    fi
    prerelease=$(echo ${version} | awk -F. '{print $4}')
    if [ -z "${prerelease}" ]; then
      prerelease=0
    fi
  fi

  echo "${dep}|${operator}|${major}|${minor}|${patch}|${prerelease}"
}

compareVersions()
{
  v1="$1"
  v2="$2"
  awk -v v1="${v1}" -v v2="${v2}" '
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
  if [ -n "${operator}" ] && [ -z "${version}" ]; then
    printVerbose "${operator} ${requestedVersion} requsted, but no version file found in ${versionPath}."
    return 1
  elif [ ! -z "${operator}" ] && ! compareVersions "${version}" "${requestedVersion}"; then
    printVerbose "${dependency} does not satisfy ${version} ${operator} ${requestedVersion}"
    return 1
  fi
  return 0
}

deleteDuplicateEntries()
{
  value=$1
  delim=$2
  echo "${value}${delim}" | awk -v RS="${delim}" '!($0 in a) {a[$0]; printf("%s%s", col, $0); col=RS; }' | sed "s/${delim}$//"
}

# reworked version of above to strip blank elements between delims
deleteDuplicateEntriesRedux()
{
  value=$1
  delim=$2
  echo "${value}" | awk -v RS="${delim}" -v ORS="${delim}" ' {gsub("^[ ]+|[ ]$", "", $0); if (NF>0 && !a[$0]++) {print } }' | sed "s/${delim}$//"
}

# Logging Types
LOG_E="ERROR"   # If there was a failure and a command failed
LOG_W="WARNING" # If an error occurred but there was a workaround/fallback
LOG_I="INFO"    # General information
LOG_A="AUDIT"   # Security-type log for admin activities

# Logging Categories - more than one possible for a log entry
CAT_CONFIG="C"  # Configuration change
CAT_FILE="F"    # File handling (eg. downloading)
CAT_INSTALL="I" # Install processing
CAT_NETWORK="N" # Network processing
CAT_PKG="P"     # Package handling
CAT_QUERY="Q"   # Query processing
CAT_REMOVE="R"  # Removal handling
CAT_SYS="S"     # Related to the underlying native z/OS system
CAT_ZOPEN="Z"   # Related to the zopen system itself

syslog()
{
  fd=$1           # file
  type=$2         # LOG_? type as defined above
  categories=$3   # CAT_? type as defined above
  module=$4       # zopen-<MODULE>
  location=$5     # function
  msg=$6          # Message text
  if [ ! -e "${fd}" ]; then
    mkdir -p "$(dirname "${fd}")"
    touch "${fd}"
  fi
  echo "$(date +"%F %T") $(id | cut -d' ' -f1)::${module}:${type}:${categories}:${location}:${msg}" >> "${fd}"
}

downloadJSONCache()
{
  if [ -z "${JSON_CACHE}" ]; then
    JSON_CACHE="${ZOPEN_ROOTFS}/var/cache/zopen/zopen_releases.json"
    JSON_TIMESTAMP="${ZOPEN_ROOTFS}/var/cache/zopen/zopen_releases.timestamp"
    JSON_TIMESTAMP_CURRENT="${ZOPEN_ROOTFS}/var/cache/zopen/zopen_releases.timestamp.current"

    # Need to check that we can read & write to the JSON timestamp cache files
    if [ -e "${JSON_TIMESTAMP_CURRENT}" ]; then
      [ ! -w "${JSON_TIMESTAMP_CURRENT}" ] || [ ! -r "${JSON_TIMESTAMP_CURRENT}" ] && printError "Cannot access cache at '${JSON_TIMESTAMP_CURRENT}'. Check permissions and retry request"
    fi
    if [ -e "${JSON_TIMESTAMP}" ]; then
      [ ! -w "${JSON_TIMESTAMP}" ] || [ ! -r "${JSON_TIMESTAMP}" ] && printError "Cannot access cache at '${JSON_TIMESTAMP}'. Check permissions and retry request"
    fi
    if [ -e "${JSON_CACHE}" ]; then
      [ ! -w "${JSON_CACHE}" ] || [ ! -r "${JSON_CACHE}" ] && printError "Cannot access cache at '${JSON_CACHE}'. Check permissions and retry request"
    fi

    if ! curlCmd -L -s -I "${ZOPEN_JSON_CACHE_URL}" -o "${JSON_TIMESTAMP_CURRENT}"; then
      printError "Failed to obtain json cache timestamp from ${ZOPEN_JSON_CACHE_URL}"
    fi
    chtag -tc 819 "${JSON_TIMESTAMP_CURRENT}"

    if [ -f "${JSON_CACHE}" ] && [ -f "${JSON_TIMESTAMP}" ] && [ "$(grep 'Last-Modified' "${JSON_TIMESTAMP_CURRENT}")" = "$(grep 'Last-Modified' "${JSON_TIMESTAMP}")" ]; then
      return
    fi
    
    printVerbose "Replacing old timestamp with latest"
    mv -f "${JSON_TIMESTAMP_CURRENT}" "${JSON_TIMESTAMP}"

    if ! curlCmd -L -s -o "${JSON_CACHE}" "${ZOPEN_JSON_CACHE_URL}"; then
      printError "Failed to obtain json cache from ${ZOPEN_JSON_CACHE_URL}"
    fi
    chtag -tc 819 "${JSON_CACHE}"
  fi

  if [ ! -f "${JSON_CACHE}" ]; then
    printError "Could not download json cache from ${ZOPEN_JSON_CACHE_URL}"
  fi
}

getReposFromGithub()
{
  downloadJSONCache
  repo_results="$(cat "${JSON_CACHE}" | jq -r '.release_data | keys[]')"
}

getAllReleasesFromGithub()
{
  downloadJSONCache
  repo="$1"
  releases="$(jq -e -r '.release_data."'${repo}'"' "${JSON_CACHE}")"
  if [ $? -ne 0 ]; then
    printError "Could not get all releases for ${repo}"
  fi
}

initDefaultEnvironment()
{
  export ZOPEN_OLD_PATH=${PATH}       # Preserve PATH in case scripts need to access it
  export ZOPEN_OLD_LIBPATH=${LIBPATH} # Preserve LIBPATH in case scripts need to access it
  export PATH="$(getconf PATH)"
  export _CEE_RUNOPTS="FILETAG(AUTOCVT,AUTOTAG) POSIX(ON)"
  unset MANPATH
  export LIBPATH="/usr/lib"
  export STEPLIB=none
}

#
# checkWritable prints a message and exits if the directory above INCDIR
# is not writable. This is a safe location to check for and should be
# writable on a 'dev' environment
#
checkWritable()
{
  if [ -z "${INCDIR}" ]; then
    echo "Internal error. Caller has to have set INCDIR" >&2
    exit 16
  fi
  ROOTDIR="$(cd "${INCDIR}/../" > /dev/null 2>&1 && pwd -P)"
  if ! [ -w "${ROOTDIR}" ]; then
    printError "Tried to run an update operation (${ME}) in a read-only tools distribution" >&2
    exit 8
  fi
}

zopenInitialize
