#!/bin/false
# This file is only meant to be source'd hence the dummy hashbang
# shellcheck shell=sh
#

zopenInitialize()
{
  # Capture start time before setting trap
  fullProcessStartTime=${SECONDS}
  
  # Create the cleanup pipeline and exit handler
  trap "cleanupFunction" EXIT INT TERM QUIT HUP
  
  # Temporary files
  for zopen_tmp_dir in "${TMPDIR}" "${TMP}" /tmp; do
    if [ ! -z ${zopen_tmp_dir} ] && [ -d ${zopen_tmp_dir} ]; then
      break
    fi
  done
  
  if [ ! -d "${zopen_tmp_dir}" ]; then
    printError "Temporary directory not found. Please specify \$TMPDIR, \$TMP or have a valid /tmp directory."
  fi

  defineEnvironment
  defineANSI
  if [ -z "${ZOPEN_DONT_PROCESS_CONFIG}" ]; then
    processConfig
  fi
  ZOPEN_ANALYTICS_JSON="${ZOPEN_ROOTFS}/var/lib/zopen/analytics.json"
  ZOPEN_JSON_CACHE_URL="https://raw.githubusercontent.com/zopencommunity/meta/main/docs/api/zopen_releases.json"
  ZOPEN_DESCRIPTIONS_CACHE_URL="https://raw.githubusercontent.com/ZOSOpenTools/meta/main/docs/api/zopen_releases_descriptions.json"
  ZOPEN_JSON_CONFIG="${ZOPEN_ROOTFS}/etc/zopen/config.json"
  if [ -n "${INCDIR}" ]; then
    ZOPEN_SYSTEM_PREREQ_SCRIPT="${INCDIR}/prereq.sh"
  else
    ZOPEN_SYSTEM_PREREQ_SCRIPT="${ZOPEN_ROOTFS}/usr/local/zopen/meta/meta/include/prereq.sh"
  fi
}

addCleanupTrapCmd(){
  newcmd=$1
  [ -z "${-%%*x*}" ] && set +x && xtrc="-x" || xtrc=""
  # Small timing window if the script is killed between the creation
  # and removal of the temporary file; would be easier if zos sh
  # didn't have a bug -trap can't be piped/redirected anywhere except
  # a file like it can in bash or non-zos sh as it seems to create
  # and run in the subshell before returning trap handler(s)!?!
  tmpscriptfile="${zopen_tmp_dir}/clean.tmp"
  trap > "${tmpscriptfile}" 2>&1 && script=$(cat "${tmpscriptfile}")
  rm "${tmpscriptfile}"
  if [ -n "${script}" ]; then
    for trappedSignal in "EXIT" "INT" "TERM" "QUIT" "HUP"; do
      newtrapcmd=$(echo "${script}" | while read trapcmd; do
	       sigcmd=$(echo "${trapcmd}" | zossed "s/trap -- \"\(.*\)\" ${trappedSignal}.*/\1/")
	       [ "${sigcmd}" = "${trapcmd}" ] && continue
	       printf "%s;%s 2>/dev/null" "${sigcmd}" "${newcmd}" | tr -s ';'
         break
      done
      )
      if [ -n "${newtrapcmd}" ]; then
        trap -- "${newtrapcmd}" "${trappedSignal}"
      fi
    done
  fi
  [ -n "${xtrc}" ] && set -x
}

# Remove temporaries on exit and report elapsed time
cleanupOnExit()
{
  rv=$?
  [ -f ${ZOPEN_TEMP_C_FILE} ] && rm -rf ${ZOPEN_TEMP_C_FILE}
  [ -p ${TMP_FIFO_PIPE} ] && rm -rf ${TMP_FIFO_PIPE}
  if [ ! -z "${TEE_PID}" ]; then
    if kill -0 ${TEE_PID} 2> /dev/null; then
      kill -9 ${TEE_PID}
    fi
  fi
  [ -e "${TMP_GPG_DIR}" ] && rm -rf "${TMP_GPG_DIR}"
  [ -e "${SIGNATURE_FILE}" ] && rm -rf "${SIGNATURE_FILE}"
  [ -e "${PUBLIC_KEY_FILE}" ] && rm -rf "${PUBLIC_KEY_FILE}"
  printElapsedTime info "${0}" ${fullProcessStartTime}
  trap - EXIT # clear the EXIT trap so that it's not double called
  exit ${rv}
}

cleanupFunction()
{
  :
}

# getParentProcess
# returns the parent process for the specified process
# input: $1 - the pid to get the parent of
# return: 0 for error or parent process id
getParentProcess()
{
  parent=$(ps -o ppid= -p "$1")
  if parent=$(ps -o ppid= -p "$1"); then
    return 0
  fi
  return "${parent}"
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

# Given two input files, return those lines in haystack file that are 
# not in needles file
diffFile()
{
  haystackfile="$1"
  needlesfile="$2"
  [ -n "${needlesfile}" ] || printError "Internal error; needle file was empty/non-existent."
  diff=$(awk 'NR==FNR{needles[$0];next} 
    !($0 in needles) {print}' "${needlesfile}" "${haystackfile}")
  echo "${diff}"
}

# Given two input lists (with \n delimiters), return those lines in  
# haystack that are not in needles
diffList()
{
  haystack="$1"
  needles="$2"
  haystackfile=$(mktempfile "haystack")
  echo "${haystack}" >"${haystackfile}"
  [ -e "${haystackfile}" ] && addCleanupTrapCmd "rm -rf ${tempdir}"
  needlesfile=$(mktempfile "needles")
  echo "${needles}" >"${needlesfile}"
  [ -e "${needlesfile}" ] && addCleanupTrapCmd "rm -rf ${needlesfile}"
  diffFile "${needlesfile}" "${haystackfile}"
}

# Generate a file name that has a high probability of being unique for
# use as a temporary filename - the filename should be unique in the
# instance it was generated and probability suggests it should be for
# a "reasonable" time after... Note the caller is responsible for ensuring
# any cleanup is scheduled - the caller may not actually need to write to
# the file
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
  overrideZOSTools=$5

  cat << EOF >  "${configFile}"
#!/bin/false  # Script currently intended to be sourced, not run
# zopen community Configuration file
# Main root location for the zopen installation; can be changed if the
# underlying root location is copied/moved elsewhere as locations are
# relative to this envvar value
displayHelp() {
echo "usage: . zopen-config [--eknv] [--knv] [--quiet] [-?|--help]"
echo "  --override-zos-tools   Adds altbin/ dir to the PATH and altman/ dir to MANPATH, overriding the native z/OS tooling."
echo "  --nooverride-zos-tools Does not add altbin/ and altman/ dir to PATH and MANPATH."
echo "  --override-zos-tools-subset=<file>"
echo "      Override a subset of zos tools. Containing a subset of packages to override, delimited by newlines."
echo "  --knv                  Display zopen environment variables "
echo "  --eknv                 Display zopen environment variables, prefixed with an"
echo "                         'export ' keyword for use in scripts"
echo "  --quiet                Do not display messages"
echo "  -?, --help             Display this help"
}
EOF

if $overrideZOSTools; then
  cat << EOF >>  "${configFile}"
ZOPEN_TOOLSET_OVERRIDE=1;
EOF
fi

cat << EOF >>  "${configFile}"
knv=false
exportknv=""
displayText=true
unset overrideFile
while [ \$# -gt 0 ]; do
  case "\$1" in
    --eknv) exportknv="export "; knv=true;;
    --knv) knv=true;;
    --override-zos-tools)  export ZOPEN_TOOLSET_OVERRIDE=1;;
    --nooverride-zos-tools)  unset ZOPEN_TOOLSET_OVERRIDE;;
    --override-zos-tools-subset) shift;  export ZOPEN_TOOLSET_OVERRIDE=1; overrideFile="\$1";;
    --quiet) displayText=false;;
    -?|--help) displayHelp; return 0;;
  esac
  shift
done
if \${knv}; then
  /bin/env | /bin/sort > /tmp/zopen-config-env-orig.\$\$
fi

if [ -n "\${overrideFile}" ] && [ ! -f "\${overrideFile}" ]; then
  echo "Override file '\${overrideFile}' is not a file. Skipping..."
fi

ZOPEN_ROOTFS="${rootfs}"
export ZOPEN_ROOTFS

if [ -z "\${_BPXK_AUTOCVT}" ]; then
  export _BPXK_AUTOCVT=ON
else
  CUR_CVT="\${_BPXK_AUTOCVT}"
  if [ "\${CUR_CVT}" = "ON" ] || [ "\${CUR_CVT}" = "ALL" ]; then
    : # ok - we can source the config with these settings
  else
    echo "Error. You have _BPXK_AUTOCVT=\${CUR_CVT} and we can not source the configuration." >&2
    return 4
  fi
fi

zot="zopen community"

sanitizeEnvVar()
{
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
  echo "\${value}\${delim}" | awk -v RS="\${delim}" '!(\$0 in a) {a[\$0]; printf("%s%s", col, \$0); col=RS; }' | /bin/sed "s/\${delim}$//"
}

# zopen community environment variables
ZOPEN_PKGINSTALL=\${ZOPEN_ROOTFS}/${pkginstall}
export ZOPEN_PKGINSTALL
ZOPEN_SEARCH_PATH=\${ZOPEN_ROOTFS}/usr/share/zopen/
export ZOPEN_SEARCH_PATH
ZOPEN_CA="\${ZOPEN_ROOTFS}/${certPath}"
export ZOPEN_CA
ZOPEN_LOG_PATH=\${ZOPEN_ROOTFS}/var/log
export ZOPEN_LOG_PATH

# Custom parameters for zopen default tooling
# Add any custom parameters for curl
ZOPEN_CURL_PARAMS=""

# Do not display text for non-interactive sessions
if [ -n "\$SSH_CONNECTION" ] && [ -z "\$PS1" ] || [ ! -t 1 ]; then
  displayText=false
fi

if [ -z "\${ZOPEN_QUICK_LOAD}" ]; then
  if [ -e "\${ZOPEN_ROOTFS}/etc/profiled" ]; then
    dotenvs=\$(find "\${ZOPEN_ROOTFS}/etc/profiled" -type f -name 'dotenv' -print)
    if \$displayText; then
      /bin/printf "Processing \$zot configuration..."
    fi

    for dotenv in \$dotenvs; do
      . \$dotenv
    done
    if \$displayText; then
      /bin/echo "DONE"
      if [ -n "\${ZOPEN_TOOLSET_OVERRIDE}" ]; then
        /bin/echo "NOTE: Conflicting tools (eg. man, cat, grep, make) will take precedence over z/OS /bin tools. Pass the option --nooverride-zos-tools to avoid this."
      else
        /bin/echo "NOTE: Conflicting tools (eg. man, cat, grep, make) will NOT take precedence over z/OS /bin tools; Use the prefixed executables instead (eg. zotman, gcat, ggrep, gmake). Pass the option --override-zos-tools if you prefer zopen tools or --help for further options."
      fi
    fi
    unset dotenvs
  fi
fi
unset displayText
PATH=\${ZOPEN_ROOTFS}/usr/local/bin:\${ZOPEN_ROOTFS}/usr/bin:\${ZOPEN_ROOTFS}/bin:\${ZOPEN_ROOTFS}/boot:\$(sanitizeEnvVar "\${PATH}" ":" "^\${ZOPEN_PKGINSTALL}/.*\$")
MANPATH=\${ZOPEN_ROOTFS}/usr/local/share/man:\${ZOPEN_ROOTFS}/usr/local/share/man/\%L:\${ZOPEN_ROOTFS}/usr/share/man:\${ZOPEN_ROOTFS}/usr/share/man/\%L:\$(sanitizeEnvVar "\${MANPATH}" ":" "^\${ZOPEN_PKGINSTALL}/.*\$")

if [ -n "\$ZOPEN_TOOLSET_OVERRIDE" ]; then
  if [ -n "\${overrideFile}" ] && [ -f "\${overrideFile}" ]; then
    PATH=\$(sanitizeEnvVar "\${PATH}" ":" "^\${ZOPEN_ROOTFS}/usr/local/altbin.*\$")
    while IFS= read -r project; do
      if [ -d "\$ZOPEN_PKGINSTALL/\$project/\$project/altbin" ]; then
        PATH="\$ZOPEN_PKGINSTALL/\$project/\$project/altbin:\$PATH"
      fi
      if [ -d "\$ZOPEN_PKGINSTALL/\$project/\$project/share/altman" ]; then
        MANPATH="\$ZOPEN_PKGINSTALL/\$project/\$project/share/altman:\$MANPATH"
      fi
    done < "\${overrideFile}"
  else
    PATH="\${ZOPEN_ROOTFS}/usr/local/altbin:\$PATH"
    MANPATH="\${ZOPEN_ROOTFS}/usr/local/share/altman:\$MANPATH"
  fi
else
  PATH=\$(sanitizeEnvVar "\${PATH}" ":" "^\${ZOPEN_ROOTFS}/usr/local/altbin.*\$")
  MANPATH=\$(sanitizeEnvVar "\${MANPATH}" ":" "^\${ZOPEN_ROOTFS}/usr/local/share/altman.*\$")
fi


export PATH=\$(deleteDuplicateEntries "\${PATH}" ":")
LIBPATH=\${ZOPEN_ROOTFS}/usr/local/lib:\${ZOPEN_ROOTFS}/usr/lib:\$(sanitizeEnvVar "\${LIBPATH}" ":" "^\${ZOPEN_PKGINSTALL}/.*\$")
export LIBPATH=\$(deleteDuplicateEntries "\${LIBPATH}" ":")
export MANPATH=\$(deleteDuplicateEntries "\${MANPATH}" ":")

if \${knv}; then
  /bin/env | /bin/sort > /tmp/zopen-config-env-modded.\$\$
  diffout=\$(/bin/diff /tmp/zopen-config-env-orig.\$\$ /tmp/zopen-config-env-modded.\$\$ | /bin/grep -E '^[>]' | /bin/cut -c3- )
  echo "\${diffout}" | while IFS= read -r knvp; do
    newval=""
    envvar="\${knvp%%=*}"
    cIFS="\$IFS"
    IFS=":"
    for token in \${knvp##*=}; do
      tok=\$(echo "\${token}" | /bin/sed -e 's#/usr/local/zopen/\([^/]*\)/[^/]*/#/usr/local/zopen/\1/\1/#')
      newval=\$(printf "%s:%s" "\${newval}" "\${tok}")
    done
    echo "\${exportknv}\${envvar}=\${newval#*:}"
    IFS="\${cIFS}"
  done
  rm /tmp/zopen-config-env-orig.\$\$ /tmp/zopen-config-env-modded.\$\$ 2>/dev/null
fi


EOF

}

curlCmd()
{
  # Take the list of parameters and concat them with
  # any custom parameters the user requires in ZOPEN_CURL_PARAMS
  if  [ ! -t 1 ] || [ ! -t 2 ]; then
    extra_curl_options="--no-progress-meter"
  fi
  curl ${ZOPEN_CURL_PARAMS} ${extra_curl_options} $*
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
    symlink=$(ls -l "${testpath}" | zossed 's/.*-> \(.*\)/\1/')
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

#return 1 if brightness is dark, 0 if light, and 255 if unknown (considered to be dark as default)
darkbackground() {
  if [ "${#COLORFGBG}" -ge 3 ]; then
    bg=${COLORFGBG##*;}
    if [ ${bg} -lt 7 ]; then
      return 1
    else
      return 0
    fi
  else
    return 255
  fi
}

defineANSI()
{
  # Standard tty codes
  ESC="\047"
  # shellcheck disable=SC2034
  ERASELINE="${ESC}[2K"
  # shellcheck disable=SC2034
  CRSRHIDE="${ESC}[?25l"
  # shellcheck disable=SC2034
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
    darkbackground
    bg=$?
    if [ $bg -ne 0 ]; then
      #if the background was set to black or unknown the header and warning color will be yellow
      HEADERCOLOR="${YELLOW}"
      WARNINGCOLOR="${YELLOW}"
    else
      #else the header and warning color will become magenta
      HEADERCOLOR="${MAGENTA}"
      WARNINGCOLOR="${MAGENTA}"
    fi
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
    HEADERCOLOR=''
    WARNINGCOLOR=''

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
  # If stdout/stderr are associated with a tty terminal
  if  [ -t 1 ] && [ -t 2 ]; then
    # Note tput does not handle ssh sessions too well...
    stty | awk -F'[/=;]' '/columns/ { print $4}' | tr -d " "
  elif [ ! -z "${COLUMNS}" ]; then
    echo "${COLUMNS}"
  else
    echo "$(tput cols)"
  fi
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

zosdu()
{
  # Use the standard z/OS du utility; if the coreutils package is installed, this
  # changes the behaviour of the du command so we need to ensure we support those
  # who do not have that installed
  /bin/du "$@"
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
  echo "$1" | zossed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

defineEnvironment()
{
  # Required for proper operation of z/OS auto-conversion support
  export _BPXK_AUTOCVT=ON
  export _CEE_RUNOPTS="${_CEE_RUNOPTS} FILETAG(AUTOCVT,AUTOTAG) POSIX(ON)"
  export _TAG_REDIR_ERR=txt
  export _TAG_REDIR_IN=txt
  export _TAG_REDIR_OUT=txt
  export GIT_UTF8_CCSID=819
  unset _ENCODE_FILE_NEW # rely on the default tool encoding behaviour
  export TERM=xterm # To avoid potential issues with "FSUM6202 Unknown terminal" if using an ncurses terminal database

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
  mygrandparent=$(/bin/ps -o ppid= -p "$mypid" | awk '{print $1}')
  if [ -e "${mutex}" ]; then
    lockedpid=$(cat ${mutex})
    {
      [ ! "${lockedpid}" = "${mypid}" ] && [ ! "${lockedpid}" = "${PPID}" ] && [ ! "${lockedpid}" = "${mygrandparent}" ]
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
    relativePath=${relativePath}/$(echo $* | zossed "s/ /\//g")
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
    dir=$(echo "${dir}" | zossed "s#^./##")
    printDebug "Processing dir: ${dir}"
    [ ${dir} = "." ] && continue
    mkdir -p "${processingDir}/${rebaseusr}/${dir}"
    cd "${processingDir}/${rebaseusr}/${dir}" || exit
    dirrelpath=$(relativePath2 "${virtualStore}/${name}/${dir}" "${processingDir}/${rebaseusr}/${dir}")
    ln -Rs "${dirrelpath}/" "." 2> /dev/null
  done

  printDebug "Moving unpaxed processing-directory back to main rootfs store."
  # this *must* be done before the merge step below or relative symlinks can't
  # work
  versioneddirname=$(basename "${versioneddir}")
  mv "${virtualStore}/${versioneddirname}" "${rootfs}/${offset}"

  tarfile="${name}.usr.tar"
  printDebug "Merge symlinks into main filesystem using tmp tar file ${tarfile}"

  printDebug "Generating intermediary tar file"
  # Need '-S' to allow long symlinks
  $(cd "${processingDir}" && tar -S -cf "${tarfile}" "usr")

  printDebug "Generating listing for remove processing (including main symlink)."
  listing=$(tar tf "${processingDir}/${tarfile}" 2> /dev/null | sort -r)
  echo "Installed files:" > "${versioneddir}/.links"
  echo "${listing}" >> "${versioneddir}/.links"

  printDebug "Extracting tar to rootfs."
  cd "${processingDir}" && tar xf "${tarfile}" -C "${rootfs}" 2> /dev/null

  printDebug "Cleaning temp resources."
  rm -rf "${processingDir}" 2> /dev/null

  printDebug "Switching to previous cwd - current work dir was purged."
  cd "${currentDir}" || exit

  printInfo "- Integration complete."
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
  newfilelist=$4
  if [ -e "${dotlinks}" ]; then
    printInfo "- Checking for obsoleted files in ${rootfs}/usr/ tree from ${pkg}"

    if [ -e "${newfilelist}" ]; then
      printDebug "Release change, so the list of changes to physically remove should be smaller"
      printDebug "Starting spinner..."
      progressHandler "spinner" "- Check complete" &
      ph=$!
      killph="kill -HUP ${ph}"
      addCleanupTrapCmd "${killph}"
      obsoleteList=$(diffFile "${dotlinks}" "${newfilelist}")
      echo "${obsoleteList}" | while read obsoleteFile; do
        [ -z "${obsoleteFile}" ] && return 0
        obsoleteFile="${ZOPEN_ROOTFS}/${obsoleteFile}"
        obsoleteFile="${obsoleteFile%% symbolic*}"
        printDebug "Checking obsoletefile '${obsoleteFile}'"
        if [ -L "${obsoleteFile}" ] && [ ! -e "${obsoleteFile}" ]; then
          # the linked-to file no longer exists (ie. the symlink is dangling)
          rm -f "${obsoleteFile}" > /dev/null 2>&1
        fi 
      done
      ${killph} 2>/dev/null # if the timer is not running, the kill will fail
      sleep 1 # give spinner time to exit if running
    else
      # Slower method needed to analyse each link to see if it has
      # become orphaned. Only relevent when removing a package as 
      # upgrades/alt-switching can supply a list of files
      # Use sed to skip header line in .links file
      # Note that the contents of the links file are ordered such that
      # processing occurs depth-first; if, after removing orphaned symlinks,
      # a directory is empty, then it can be removed.
      nfiles=$(zossed '1d;$d' "${dotlinks}" | wc -l  | tr -d ' ')
      printDebug "Creating Temporary dirname file"
      tempDirFile=$(mktempfile "unsymlink")
      [ -e "${tempDirFile}" ] && rm -f "${tempDirFile}" >/dev/null 2>&1
      touch "${tempDirFile}"
      tempTrash=$(mktempfile "unsymlink" "trash")
      [ -e "${tempTrash}" ] && rm -f "${tempTrash}" >/dev/null 2>&1
      addCleanupTrapCmd "rm -rf ${tempDirFile}"
      printDebug "Using temporary file ${tempDirFile}"
      printInfo "- Checking ${nfiles} potential links"
      printDebug "Starting spinner..."
      progressHandler "spinner" "- Complete" &
      ph=$!
      killph="kill -HUP ${ph}"
      addCleanupTrapCmd "${killph}"

      while read filetounlink; do
        filetounlink=$(echo "${filetounlink}" | zossed 's/\(.*\).symbolic.*/\1/')
        filename="$filetounlink"
        [ -z "${filetounlink}" ] && continue
        filetounlink="${ZOPEN_ROOTFS}/${filetounlink}"
        [ ! -e "${filetounlink}" ] && continue  # If not there, can'e be removed!
        if [ -d "${filetounlink}" ]; then
          # Add to the directory queue for checking once files are gone if unique
          ispresent=$(grep "^${filetounlink}[ ]*$" "${tempDirFile}")
          if [ -z "${ispresent}" ]; then
            echo " ${filetounlink} " >> "${tempDirFile}"
          fi
        elif [ -L "${filetounlink}" ]; then
          if [ ! -f "${filetounlink}" ]; then
            # the linked-to file no longer exists (ie. the symlink is dangling)
            rm -f "${filetounlink}" > /dev/null 2>&1
          fi
        else
          echo "Unprocessable file: '${filetounlink}'" >> "${tempTrash}"
        fi
      done <<EOF
$(zossed '1d;$d' "${dotlinks}")
EOF
      ${killph} 2>/dev/null # if the timer is not running, the kill will fail
      sleep 1 # ensure the spinner has stopped if running
      if [ -e "${tempDirFile}" ]; then
        ndirs=$(uniq < "${tempDirFile}" | wc -l  | tr -d ' ')
        printVerbose "- Checking ${ndirs} dir links"
        for d in $(uniq < "${tempDirFile}" | sort -r) ; do 
          [ -d "${d}" ] && rmdir "${d}" >/dev/null 2>&1
        done
      fi
      if [ -e "${tempTrash}" ]; then
        printSoftError "Issues found while trying to remove the following files:"
        while read errorFile; do
          printSoftError "${errorFile}"
        done < "${tempTrash}"
        printError "Manual removal of files might be required"
      fi
    fi
  else
    printDebug "No list of current links to check - package was not installed/active"
  fi
}

printDebug()
{
  [ -z "${-%%*x*}" ] && set +x && xtrc="-x" || xtrc=""
  if ${debug}; then
    printColors "${NC}${BLUE}${BOLD}:DEBUG:${NC}: '${1}'"
  fi
  [ ! -z "${xtrc}" ] && set -x
  return 0
}

printVerbose()
{
  [ -z "${-%%*x*}" ] && set +x && xtrc="-x" || xtrc=""
  if ${verbose}; then
    printColors "${NC}${GREEN}${BOLD}VERBOSE${NC}: ${1}"
  fi
  [ ! -z "${xtrc}" ] && set -x
  return 0
}

printHeader()
{
  if [ -n "$noInfoMessages" ]; then
    return 0;
  fi
  [ -z "${-%%*x*}" ] && set +x && xtrc="-x" || xtrc=""
  printColors "${NC}${HEADERCOLOR}${BOLD}${UNDERLINE}${1}${NC}"
  [ ! -z "${xtrc}" ] && set -x
  return 0
}

printAttention()
{
  [ -z "${-%%*x*}" ] && set +x && xtrc="-x" || xtrc=""
  printColors "${NC}${MAGENTA}${BOLD}${UNDERLINE}${1}${NC}"
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
  killph="kill -HUP ${ph} 2>/dev/null"
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
    :
    i=$((i - 1))
  done
}

progressAnimation()
{
  [ $# -eq 0 ] && printError "Internal error: no animation strings."
  animcnt=$#
  anim=1
  ansiline 0 0 "$1"
  while :; do
    spinloop 1000
    # Check for daemonization of this process (ie. orphaned and PPID=1)
    # Cannot actually use "$PPID" as it is set at script initialization
    # and not updated when the parent changes so need to query.
    getParentProcess "$$" >/dev/null 2>&1
    ppid=$?
    [ "${ppid}" -eq 1 ] && kill INT "${ppid}" >/dev/null 2>&1
    anim=$((anim + 1))
    [ ${anim} -gt ${animcnt} ] && anim=1
    ansiline 1 -1 $(getNthArrayArg "${anim}" "$@")
  done
}

getNthArrayArg () {
    shift "$1"
    echo "$1"
}

progressHandler()
{
  if [ ! "${_BPX_TERMPATH-x}" = "OMVS" ] && [ -z "${NO_COLOR}" ] && [ ! "${FORCE_COLOR-x}" = "0" ] && [ -t 1 ] && [ -t 2 ]; then
    [ -z "${-%%*x*}" ] && set +x # Disable -x debug if set for this process
    type=$1
    completiontext=$2 # Custom end text (when the process is complete)
    trapcmd="exit;"
    if [ -n "${completiontext}" ]; then
      trapcmd="/bin/echo \"\047[1A\047[30D\047[2K${completiontext}\"; ${trapcmd}"
    fi
    # shellcheck disable=SC2064
    trap "${trapcmd}" HUP
    case "${type}" in
      "spinner")   progressAnimation '-' '\' '|' '/' ;;
      "network")   progressAnimation '-----' '>----' '->---' '-->--' '--->-' '---->' '-----' '----<' '---<-' '--<--' '-<---' '<----' ;;
      "linkcheck") progressAnimation '======|' '?=====|' '-?====|' '--?===|' '---?==|' '----?=|' '-----?|' '------|' '?-----|' '=?----|' '==?---|' '===?--|' '====?-|' '=====?|';;
      *) progressAnimation '.' 'o' 'O' 'O' 'o' '.'
      ;;
    esac
  fi
}

runInBackgroundWithTimeoutAndLog()
{
  command="$1"
  timeout="$2"

  printVerbose "${command} with timeout of ${timeout}s."
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
  kill -9 "${PID}" 2>/dev/null
  kill -9 "${TEEPID}" 2>/dev/null
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
  printColors "${NC}${WARNINGCOLOR}${BOLD}***WARNING: ${NC}${YELLOW}${1}${NC}" >&2
  [ -n "${xtrc}" ] && set -x
  return 0
}

printInfo()
{
  if [ -n "$noInfoMessages" ]; then
    return 0;
  fi
  [ -z "${-%%*x*}" ] && set +x && xtrc="-x" || xtrc=""
  printColors "$1"
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
      printError "Source the zopen-config prior to running $0."
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
    printVerbose "${operator} ${requestedVersion} requested, but no version file found in ${versionPath}"
    return 1
  elif [ -n "${operator}" ] && ! compareVersions "${version}" "${requestedVersion}"; then
    printVerbose "${dependency} does not satisfy ${version} ${operator} ${requestedVersion}"
    return 1
  fi
  return 0
}

deleteDuplicateEntries()
{
  value=$1
  delim=$2
  echo "${value}${delim}" | awk -v RS="${delim}" '!($0 in a) {a[$0]; printf("%s%s", col, $0); col=RS; }' | zossed "s/${delim}$//"
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
CAT_STATS="ST"  # Related to usage statistics

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
  from_readonly=$1

  if [ -z "${JSON_CACHE}" ]; then
    cachedir="${ZOPEN_ROOTFS}/var/cache/zopen"
    [ ! -e "${cachedir}" ] && mkdir -p "${cachedir}"
    JSON_CACHE="${cachedir}/zopen_releases.json"
    JSON_DESCRIPTIONS_CACHE="${cachedir}/zopen_releases_descriptions.json"
    JSON_TIMESTAMP="${cachedir}/zopen_releases.timestamp"
    JSON_TIMESTAMP_CURRENT="${cachedir}/zopen_releases.timestamp.current"

    if [ -n "$from_readonly" ]; then
      if [ -r "$JSON_CACHE" ] && [ ! -w "$JSON_CACHE" ]; then
        return; # Skip the download for read only operations when you know you can't write to it
      fi
    fi
  
    # Need to check that we can read & write to the JSON timestamp cache files
    if [ -e "${JSON_TIMESTAMP_CURRENT}" ]; then
      [ ! -w "${JSON_TIMESTAMP_CURRENT}" ] || [ ! -r "${JSON_TIMESTAMP_CURRENT}" ] && printError "Cannot access cache at '${JSON_TIMESTAMP_CURRENT}'. Check permissions and retry request."
    fi
    if [ -e "${JSON_TIMESTAMP}" ]; then
      [ ! -w "${JSON_TIMESTAMP}" ] || [ ! -r "${JSON_TIMESTAMP}" ] && printError "Cannot access cache at '${JSON_TIMESTAMP}'. Check permissions and retry request."
    fi
    if [ -e "${JSON_CACHE}" ]; then
      [ ! -w "${JSON_CACHE}" ] || [ ! -r "${JSON_CACHE}" ] && printError "Cannot access cache at '${JSON_CACHE}'. Check permissions and retry request."
    fi

    if ! curlout=$(curlCmd -L --no-progress-meter -I "${ZOPEN_JSON_CACHE_URL}" -o "${JSON_TIMESTAMP_CURRENT}"); then
      printError "Failed to obtain json cache timestamp from ${ZOPEN_JSON_CACHE_URL}; ${curlout}"
    fi
    chtag -tc 819 "${JSON_TIMESTAMP_CURRENT}"

    if [ -f "${JSON_CACHE}" ] && [ -f "${JSON_TIMESTAMP}" ] && grep -q 'ETag' "${JSON_TIMESTAMP_CURRENT}" && [ "$(grep 'ETag' "${JSON_TIMESTAMP_CURRENT}")" = "$(grep 'ETag' "${JSON_TIMESTAMP}")" ]; then
      return
    fi

    printVerbose "Replacing old timestamp with latest."
    mv -f "${JSON_TIMESTAMP_CURRENT}" "${JSON_TIMESTAMP}"

    if ! curlout=$(curlCmd -L --no-progress-meter -o "${JSON_CACHE}" "${ZOPEN_JSON_CACHE_URL}"); then
      printError "Failed to obtain json cache from ${ZOPEN_JSON_CACHE_URL}; ${curlout}"
    fi
    chtag -tc 819 "${JSON_CACHE}"

    if ! curlout=$(curlCmd -L --no-progress-meter -o "${JSON_DESCRIPTIONS_CACHE}" "${ZOPEN_DESCRIPTIONS_CACHE_URL}"); then
      printError "Failed to obtain descriptions  cache from ${ZOPEN_DESCRIPTIONS_CACHE_URL}; ${curlout}"
    fi
    chtag -tc 819 "${JSON_DESCRIPTIONS_CACHE}"

  fi

  if [ ! -f "${JSON_CACHE}" ]; then
    printError "Could not download json cache from ${ZOPEN_JSON_CACHE_URL}"
  fi
}

getReposFromGithub()
{
  downloadJSONCache $1
  repo_results="$(cat "${JSON_CACHE}" | jq -r '.release_data | keys[]')"
}

getAllReleasesFromGithub()
{
  downloadJSONCache $1
  repo="$1"
  releases="$(jq -e -r '.release_data."'${repo}'"' "${JSON_CACHE}")"
  if [ $? -ne 0 ]; then
    printError "Could not get all releases for ${repo}"
  fi
}

# Initializes a default environment for consistency in zopen builds
initDefaultEnvironment()
{
  export ZOPEN_OLD_PATH="${PATH}"       # Preserve PATH in case scripts need to access it
  export ZOPEN_OLD_LIBPATH="${LIBPATH}" # Preserve LIBPATH in case scripts need to access it
  export ZOPEN_OLD_STEPLIB="${STEPLIB}" # Preserve STEPLIB in case scripts need to access it
  export PATH="$(getconf PATH)"
  export _CEE_RUNOPTS="FILETAG(AUTOCVT,AUTOTAG) POSIX(ON)"
  unset MANPATH
  export LIBPATH="/usr/lib"
  export STEPLIB=none
  export ZUSAGE_DISABLE=1 # Avoid usage statistics within zopen-build
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
    printError "Tools distribution is read-only. Cannot run update operation '${ME}'." >&2
  fi
}

getReleaseLine()
{
  jsonConfig="${ZOPEN_ROOTFS}/etc/zopen/config.json"
  if [ ! -f "${jsonConfig}" ]; then
    jq -r '.release_line' $jsonConfig
  else
    echo "STABLE"
  fi
}

getRMProcs()
{
  jsonConfig="${ZOPEN_ROOTFS}/etc/zopen/config.json"
  if [ ! -f "${jsonConfig}" ]; then
    jq -r '.num_rm_procs' $jsonConfig
  else
    echo "5" # default
  fi
}

isURLReachable() {
  url="$1"
  timeout=5

  if curl -s --fail --max-time $timeout "$url" > /dev/null; then
    return 0
  else
    return 1
  fi
}

checkAvailableSize()
{ 
  
  package="$1"
  packageSize="$2"
  printInfo "- Checking available size to install ${package}."

  printDebug "Package Size: ${packageSize} bytes"
  packageSize=$(echo "scale=2; ${packageSize} / 1024" | bc)
  printDebug "Package Size: ${packageSize} k"
  partitionSize=$(/bin/df -k . | tail -1 | awk '{print $3}' | cut -f1 -d '/')
  printDebug "Partition Size: ${partitionSize}k [free on '$(pwd -P)']"
  
  if [ 1 -eq "$(echo "${packageSize} > ${partitionSize}" | bc)" ]; then
    printError "Not enough space in partition."
  fi
  printInfo "- Enough space to install ${package}. Proceeding with installation."
  return 0
}

promptYesOrNo() {
  message="$1"
  skip=$2
  if ! ${skip}; then
    while true; do
      printInfo "${message} [y/n]"
      read answer < /dev/tty
      answer=$(echo "${answer}" | tr '[A-Z]' '[a-z]')
      if [ "y" = "${answer}" ] || [ "yes" = "${answer}" ]; then
        return 0
      fi
      if [ "n" = "${answer}" ] || [ "no" = "${answer}" ]; then
        return 1
      fi
    done
  fi
  return 0
}

# asciiecho: we are in the process of starting to use 'echo' from coreutils.
# This echo will have a slightly different behaviour than the standard echo in that
# the file will now be tagged as ascii instead of ebcdic
# For compatibility, check the tag of the file after the echo and iconv the file IFF it is IBM-1047
asciiecho()
{
  text="$1"
  file="$2"

  if ! echo "${text}" > "${file}"; then
    echo "Unable to echo text to ${file}" >&2
    return 2
  fi
  if [ "$(chtag -p "${file}" | cut -f2 -d' ')" = "IBM-1047" ]; then
    if ! /bin/iconv -f IBM-1047 -t ISO8859-1 < "${file}" > "${file}_ascii" || ! chtag -tc ISO8859-1 "${file}_ascii" || ! mv "${file}_ascii" "${file}"; then
      printError "Unable to convert EBCDIC text to ASCII for ${file}" >&2
    fi
  fi
  return 0
}

a2e() 
{
  source="$1"

  if [ ! -w "${source}" ]; then
    printWarning "Cannot write to ${source}"
    return;
  fi

  if [ "$(chtag -p "${source}" | cut -f2 -d' ')" = "ISO8859-1" ]; then
    /bin/iconv -f ISO8859-1 -t IBM-1047 "$source" > "$source.bk"
    chtag -tc 1047 "$source.bk"
    mv "$source.bk" "$source"
  fi
}

diskusage()
{
  path=$1
  # awk to "trim" output"
  if ! size=$(zosdu -kts "${path}" | /bin/awk '{print ($1)}'); then
    printError "Unable to generate disk usage (du) report for '${path}'"
  fi
  echo "${size}"
}

formattedFileSize()
{
  filesize=$1  # in kb
  # Use awk rather than $((..)) to get floating points, using the 
  # "repeated divisions and count" method to generate an offset
  echo "${filesize}" | awk '{
    num = $1;
    unit = "k";
    if (num >= 1000000000) {
        num = num / 1000000000;
        unit = "T";
    } else if (num >= 1000000) {
        num = num / 1000000;
        unit = "G";
    } else if (num >= 1000) {
        num = num / 1000;
        unit = "M";
    } printf "%.3f%s\n", num, unit;
  }'  
}

. ${INCDIR}/analytics.sh

zopenInitialize
