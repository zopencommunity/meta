#!/bin/false
# This file is only meant to be source'd hence the dummy hashbang
# shellcheck shell=sh
#

zopenInitialize()
{
  # Monitor the intial parent process; as subshells inherit
  # variables, this will not be overridden due to param expansion
  parentPid=${parentPid:-$$}
  defineEnvironment
  defineANSI
  if [ -z "${ZOPEN_DONT_PROCESS_CONFIG}" ]; then
    processConfig
  fi

  ZOPEN_ORGNAME="zopencommunity"
  ZOPEN_GITHUB="https://github.com/${ZOPEN_ORGNAME}"
  # shellcheck disable=SC2034
  ZOPEN_ANALYTICS_JSON="${ZOPEN_ROOTFS}/var/lib/zopen/analytics.json"
  # shellcheck disable=SC2034
  ZOPEN_JSON_CACHE_URL="https://raw.githubusercontent.com/${ZOPEN_ORGNAME}/meta/main/docs/api/zopen_releases.json"
  ZOPEN_LATEST_RELEASE_JSON="https://raw.githubusercontent.com/${ZOPEN_ORGNAME}/meta/main/docs/api/zopen_releases_latest.json"
  ZOPEN_JSON_CONFIG="${ZOPEN_ROOTFS}/etc/zopen/config.json"
  if [ -n "${INCDIR}" ]; then
    ZOPEN_SCRIPTLET_DIR="${INCDIR}/scriptlets"
  else
    ZOPEN_SCRIPTLET_DIR="${ZOPEN_ROOTFS}/usr/local/zopen/meta/meta/include/scriptlets"
  fi

}
addCleanupTrapCmd(){
  # Attempt to remove any redirects; rather than test, simpler to remove 
  # and re-add if present. 
  newcmd="$1"

  tmpscriptfile="/tmp/zopen_trap.scr"
  echo "${newcmd}" >> "${tmpscriptfile}"

  if [ $$ -eq "${parentPid}" ]; then
    # Re-register handlers if already done; quicker than testing presensce
    for trappedSignal in "EXIT" "INT" "TERM" "QUIT" "HUP"; do
      trap cleanup "${trappedSignal}"
    done
  fi
}

cleanup() {
    printVerbose "Performing cleanup [in the parent process]"
    if [ -f "${tmpscriptfile}" ] && [ -s "${tmpscriptfile}" ]; then
        # Execute the commands in the cleanup file by sourcing it
        # shellcheck disable=SC1090
        . "${tmpscriptfile}" > /dev/null 2>&1
        rm "${tmpscriptfile}"
    else
        printVerbose "No cleanup script to run"
    fi
}

addCleanupTrapCmd2(){
  # Attempt to remove any redirects; rather than test, simpler to remove 
  # and re-add if present. 
  newcmd=$(echo "$cmd" | zossed -E "s/[ \t]*[1-9]*[<>][>|&]?[ \t]*[^ \t]*//g")
  newcmd="${newcmd} >/dev/null 2>&1"
  # Command Trace MUST be disabled as the output from this can become
  # interleaved with output when calling zopen sub-processes.

  # Small timing window if the script is killed between the creation
  # and removal of the temporary file; would be easier if zos sh
  # didn't have a bug -trap can't be piped/redirected anywhere except
  # a file like it can in bash or non-zos sh as it seems to create
  # and run in the subshell before returning trap handler(s)!?!
  tmpscriptfile="/tmp/clean.tmp"
  trap > "${tmpscriptfile}" 2>&1 && script=$(cat "${tmpscriptfile}")
  if [ -n "${script}" ]; then
  for trappedSignal in "EXIT" "INT" "TERM" "QUIT" "HUP"; do
    newtrapcmd=$(
        echo "${script}" | while read trapcmd; do
        sigcmd=$(echo "${trapcmd}" |
            zossed "s/trap -- \"\(.*\)\" ${trappedSignal}.*/\1/")
        # No match/replace in sed, then sigcmd remains unchanged
        [ "${sigcmd}" = "${trapcmd}" ] && continue
        # There was a match, so sigcmd contains the string of commands
        # to run for the trap. Need to remove the exit command (which
        # returns the exit code) and the initial set of the exit code
        # and ensure it is last. Note that eval is used to run commands
        # with potentially embedded variables (like the return code
        # capture/return)
        suffix="eval exit \$exitrc"
        prfx="exitrc=\$?"
        sigcmd=$(echo "${sigcmd}" |awk -v prfx="$prfx" -v suffix="$suffix" '
            BEGIN{ FS=";"; OFS=";" sep=""}
            {
              for (i=1; i<=NF; i++){
                if (substr($i, 1, length(prfx)) != prfx &&
                    substr($i, 1, length(suffix)) != suffix) {
                      printf "%s%s >/dev/null 2>&1", sep, $i
                      sep = OFS
                }
              }
            } 
            END{ printf "\n" }'
        )
       printf "%s;%s;%s;eval exit \${exitrc}" "${prfx}" "${newcmd}" "${sigcmd}"  | tr -s ';'
        break
      done
    )
    if [ -n "${newtrapcmd}" ]; then
      trap -- "${newtrapcmd}" "${trappedSignal}"
    fi
  done
    rm "${tmpscriptfile}" 2>/dev/null
  fi
  [ -n "${xtrc}" ] && set -x
}

# Temporary files
for zopen_tmp_dir in "${TMPDIR}" "${TMP}" /tmp; do
  if [ ! -z ${zopen_tmp_dir} ] && [ -d ${zopen_tmp_dir} ]; then
    break
  fi
done

if [ ! -d "${zopen_tmp_dir}" ]; then
  printError "Temporary directory not found. Please specify \$TMPDIR, \$TMP or have a valid /tmp directory."
fi

# Capture start time before setting trap
fullProcessStartTime=${SECONDS}

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


# showConfigParmWarning
# writes warning messages when a bad config parameter is found
# input: $1 - name of the paramter
#        $2 - current value of the parameter
#        $3 - valid value
#        $4 - default that will be uesd
showConfigParmWarning(){
  printWarning "Found invalid value '$2' for $1 configuration parameter [should be $3]. Defaulting to '$4'"
  if type zopen-config-helper >/dev/null 2>&1; then
    printWarning "Run 'zopen config --set $1 [$3]' to update configuration if required."
  else
    printWarning "Update zopen configuration file with a valid value [$3] for parameter '$1' if required."
  fi
}

# getParentProcess
# returns the parent process for the specified process
getParentProcess()
{
  [ -z "$1" ] && assertFailed "No process name given"
  # Get Parent Pid (ppid), with no heading (='') and strip blanks (awk)
  ps -o ppid= -p "$1" | awk '{$1=$1; print}' 
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
  [ -e "${haystackfile}" ] && addCleanupTrapCmd "rm -rf ${haystackfile}"
  needlesfile=$(mktempfile "needles")
  echo "${needles}" >"${needlesfile}"
  [ -e "${needlesfile}" ] && addCleanupTrapCmd "rm -rf ${needlesfile}"
  diffFile "${needlesfile}" "${haystackfile}"
  rm -rf "${needlesfile}" "${haystackfile}"
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
  tempdir=$(mktempfile "$1" "$2")
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

# Wrap the curl command with additional standard parameters
curlCmd()
{
  # Take the list of parameters and concat them with
  # any custom parameters the user requires in ZOPEN_CURL_PARAMS
  extra_curl_options="--no-progress-meter"
  curl ${ZOPEN_CURL_PARAMS} ${extra_curl_options} $*
}

# Wrap the gpg command with additional standard parameters
gpgCmd()
{
  if ! gpgout=$(gpg --no-secmem-warning $*); then
  	if echo "${gpgout}" | grep -q "EDC5128I No such device"; then
    printVerbose "Ignoring mmap issue not applicable on z/OS currently"
      return 0
    fi
    echo "${gpgout}"
    return 1
  fi
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

toAbsolutePath() {
  case "$1" in
      /*) echo "$1" ;;  # Already absolute
      * | . | .. | ./* | ../*) echo "$(cd "$(dirname "$1")" && pwd -P)/$(basename "$1")" ;;
  esac
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
  ESC=$(printf "\047") # Start of Escape Sequence; EBCDIC=\047, ASCII=\033
  CSI="[" # Control Sequence Introducer
  CNL="E" # Cursor Next Line
  CPL="F" # Cursor Previous Line
  CHA="G" # Cursor Horizontal Absolute - column selector
  EL="K" # Erase In Line
  SGR="m" # Select Graphic Rendition

  # shellcheck disable=SC2034
  ERASELINE=$(printf "${ESC}${CSI}2${EL}")
  # shellcheck disable=SC2034
  CRSRHIDE=$(printf "${ESC}${CSI}?25l")
  # shellcheck disable=SC2034
  CRSRSHOW=$(printf "${ESC}${CSI}?25h")
  CRSRSOL=$(printf "${ESC}${CSI}0${CHA}")
  # shellcheck disable=SC2034
  CRSRPL=$(printf "${ESC}${CSI}1${CPL}")   # Move to start of previous line
  # shellcheck disable=SC2034
  CRSRUP="A"  # CUU
  # shellcheck disable=SC2034
  CRSRDOWN="B" # CUF
  # shellcheck disable=SC2034
  CRSRRIGHT="C" # CUB
  # shellcheck disable=SC2034
  CRSRLEFT="D" # CUD



  # Color-type codes, needs explicit terminal settings
  if [ ! "${_BPX_TERMPATH-x}" = "OMVS" ] && [ -z "${NO_COLOR}" ] && [ ! "${FORCE_COLOR-x}" = "0" ] && [ -t 1 ] && [ -t 2 ]; then
    ANSION=true
    #ESC="\047"
    BLACK=$(printf "${ESC}${CSI}30${SGR}")
    RED="${ESC}${CSI}31${SGR}"
    GREEN="${ESC}${CSI}32${SGR}"
    YELLOW="${ESC}${CSI}33${SGR}"
    BLUE="${ESC}${CSI}34${SGR}"
    MAGENTA="${ESC}${CSI}35${SGR}"
    CYAN="${ESC}${CSI}36${SGR}"
    GRAY="${ESC}${CSI}37${SGR}"
    BOLD="${ESC}${CSI}1${SGR}"
    UNDERLINE="${ESC}${CSI}4${SGR}"
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
    # The following should be the last ANSI declaration. With -x trace active, the ANSI
    # codes might be interpreted by the terminal when outputing the command trace. Having
    # NC as the last value ensures that the text is returned to normal
    NC="${ESC}${CSI}0${SGR}"
  else
    # unset esc RED GREEN YELLOW BOLD UNDERLINE NC
    ANSION=false
    esc=''
    # shellcheck disable=SC2034
    BLACK=''
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    MAGENTA=''
    # shellcheck disable=SC2034
    CYAN=''
    # shellcheck disable=SC2034
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
  echostr="$3"
  ansimove "$1" "$2"
  zosecho "${echostr}\c"
}

ansimove()
{
  deltax=$1
  deltay=$2

  movestr=""
  if [ -n "${deltax}" ]; then
    if [ "${deltax}" -gt 0 ]; then
      movestr="${ESC}${CSI}${deltax}${CRSRRIGHT}"
    elif [ "${deltax}" -lt 0 ]; then
      movestr="${ESC}${CSI}$((deltax * -1))${CRSRLEFT}"
    fi
  fi
  if [ -n "${deltay}" ]; then
    if [ "${deltay}" -gt 0 ]; then
      movestr="${movestr}${ESC}${CSI}${deltay}${CRSRDOWN}"
    elif [ "${deltay}" -lt 0 ]; then
      movestr="${movestr}${ESC}${CSI}$((deltay * -1))${CRSRUP}"
    fi
  fi
  zosecho "${movestr}\c"
}

getScreenCols()
{
  # If stdout/stderr are associated with a tty terminal
  if  [ -t 1 ] && [ -t 2 ]; then
    # Note tput does not handle ssh sessions too well...
    lclcols=$(stty | awk -F'[/=;]' '/columns/ { print $4}' | tr -d " ")
  elif [ ! -z "${COLUMNS}" ]; then
    lclcols="${COLUMNS}"
  elif ! lclcols=$(tput cols 2>/dev/null); then
    # tput can fail if the terminal type is unrecognised; use fallback
    lclcols=80
  fi
  echo "${lclcols}"
}

zostr()
{
  # Use the standard z/OS 'tr' command
  /bin/tr "$@"
}
zosecho()
{
  # Use the standard z/OS echo utility; supports use of ANSI colour when
  # required and is consistent across shells as it uses the EBCDIC ANSI
  # control codes
  /bin/echo "$@"
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
  while [ "${haystack}" != "" ] && [ "${haystack}" != "/" ] && [ "${haystack}" != "./" ] && [ ! -e "${haystack}/${needle}" ]; do
    haystack=${haystack%/*}
  done
  echo "${haystack}"
}

strtrim()
{
  echo "$1" | zossed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

text_center()
{
  if [ $# -lt 2 ]; then
    echo "$1"
    return
  fi
  echo "$1" | awk -v strlen="$2" \
    '{spc = strlen - length;padding = int(spc / 2);pad = spc - padding;printf "%*s%s%*s\n", pad, "", $0, padding, ""}'
}

text_padrightr() {
  padchar="${3:- }" # Default to space char
  echo "" | awk -v str="$1" -v n="$2" -v pc="$padchar"  \
      'function padr(n,acc, c){
          if (++acc>=n) return c;
          return c padr(n, acc, c);
        }
        BEGIN{ print str padr(n,0,pc);}
      '
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
# For now, explicitly specify zosecho to ensure we get the EBCDIC echo since the escape
# sequences are EBCDIC escape sequences
#
printColors()
{
  zosecho "$@"
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

  printDebug "Calculating the offset path to store from root"
  offset=$(dirname "${versioneddir#"${rootfs}"/}")
  version=$(basename "${versioneddir}")
  tmptime=$(date +%Y%m%d%H%M%S)
  processingDir="${rootfs}/tmp/zopen.${tmptime}"
  printDebug "Temporary processing dir evaluated to: ${processingDir}"

  virtualStore="${processingDir}/${offset}"
  printDebug "Creating virtual store at: ${virtualStore}"
  mkdir -p "${virtualStore}"

  printDebug "Moving from main store location (unpax-dir) to processing store"
  mv "${versioneddir}" "${virtualStore}"

  printDebug "Creating main linked directory in store"
  cd "${virtualStore}" && ln -s "${version}" "${name}"

  printDebug "Creating virtual root directory structure"
  mkdir -p "${processingDir}/${rebaseusr}"

  printDebug "Generating relative symlinks in processing location"
  relpath=$(relativePath2 "${virtualStore}/${name}" "${processingDir}/${rebaseusr}")
  [ "${relpath}" = "/" ] && printError "Relative path calculated as root directory itself!?!"

  printDebug "Generating symlink tree"

  printDebug "Creating directory structure"
  cd "${virtualStore}/${name}" || printError "Unable to change to virtual store at '${virtualStore}/${name}'"
  # since 'ln *' doesn't invoke globbing to allow multiple files at once,
  # abuse the Recurse option; this results in "already exists" errors but
  # ignore them as the first call should generate the correct link but
  # subsequent calls would generate a symlink that has incorrect dereferencing
  # and ignoring them is actually faster than individually creating the links!
  zosfind . -type d | sort -r | while read dir; do
    dir=$(echo "${dir}" | zossed "s#^./##")
    printDebug "Processing dir: ${dir}"
    [ "${dir}" = "." ] && continue
    mkdir -p "${processingDir}/${rebaseusr}/${dir}"
    cd "${processingDir}/${rebaseusr}/${dir}" || printError "Unable to change to processing directory '${processingDir}/${rebaseusr}/${dir}'"
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
  cd "${processingDir}" && tar -S -cf "${tarfile}" "usr"

  printDebug "Generating listing for remove processing (including main symlink)"
  echo "Installed files:" > "${versioneddir}/.links"
  tar tf "${processingDir}/${tarfile}" 2> /dev/null| sort -r >> "${versioneddir}/.links"
  
  printDebug "Extracting tar to rootfs"
  cd "${processingDir}" && tar xf "${tarfile}" -C "${rootfs}" 2> /dev/null

  printDebug "Cleaning temp resources."
  rm -rf "${processingDir}" 2> /dev/null

  printDebug "Switching to previous cwd - current work dir was purged"
  cd "${currentDir}" || printError "Unable to change to '${currentDir}'"

  return 0
}

rmSymlinksFSCheck(){
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
  addCleanupTrapCmd "rm -rf ${tempTrash}"
  printDebug "Using temporary file ${tempDirFile}"
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
}

rmSymlinksFileDiff(){
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
    if [ -e "${newfilelist}" ]; then
      if ! runLogProgress "rmSymlinksFileDiff" \
          "Checking for file differences in mesh" \
          "Checked for file differences in mesh" "linkcheck"; then
        printError "Unable to remove symlinks links. Review any errors. Manual cleanup using zopen-alt might be required"
      fi
    else
      if ! runLogProgress "rmSymlinksFSCheck" \
          "Checking for orphaned symlinks in mesh" \
          "Checked for orphaned symlinks in mesh" "linkcheck"; then
        printError "Unable to remove symlinks links. Review any errors. Manual cleanup using zopen-alt might be required"
      fi
      if [ -e "${tempDirFile}" ]; then
        ndirs=$(uniq < "${tempDirFile}" | wc -l  | tr -d ' ')
        printVerbose "- Checking ${ndirs} dir links"
        for d in $(uniq < "${tempDirFile}" | sort -r) ; do 
          [ -d "${d}" ] && rmdir "${d}" >/dev/null 2>&1
        done
        rm "${tempDirFile}"
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
  # shellcheck disable=SC2154
  if ${debug}; then
    printColors "${NC}${BLUE}${BOLD}:DEBUG:${NC}: '${1}'"
  fi
  [ -n "${xtrc}" ] && set -x
  return 0
}

printVerbose()
{
  [ -z "${-%%*x*}" ] && set +x && xtrc="-x" || xtrc=""
  # shellcheck disable=SC2154
  if ${verbose}; then
    printColors "${NC}${GREEN}${BOLD}VERBOSE${NC}: ${1}"
  fi
  [ -n "${xtrc}" ] && set -x
  return 0
}

printHeader()
{
  [ -z "${-%%*x*}" ] && set +x && xtrc="-x" || xtrc=""
  printColors "${NC}${HEADERCOLOR}${BOLD}${UNDERLINE}${1}${NC}"
  [ -n "${xtrc}" ] && set -x
  return 0
}

printAttention()
{
  [ -z "${-%%*x*}" ] && set +x && xtrc="-x" || xtrc=""
  printColors "${NC}${MAGENTA}${BOLD}${UNDERLINE}${1}${NC}"
  [ -n "${xtrc}" ] && set -x
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
  printInfo "- ${2:-Running}"
  completeText="${3:-Complete}"
  animation="${4:-spinner}"

  progressHandler "${animation}" "${completeText}" &
  PROGRESS_HANDLER=$!
  killph="kill -HUP ${PROGRESS_HANDLER}"
  addCleanupTrapCmd "${killph}"
  eval "$1"
  rc=$?
  if [ -n "${SSH_TTY}" ]; then
    chtag -r "${SSH_TTY}"
  fi
  ${killph} >/dev/null 2>&1 # if the timer is not running, the kill will fail
  waitforpid ${PROGRESS_HANDLER}  # Make sure it's finished writing to screen
  return "${rc}"
}

spinloop()
{
  # in the absence of generic ms/ns reporting, spin-loop instead - not ideal
  # but without pre-reqing packages...
  i=$1
  while [ "${i}" -ge 0 ]; do
    i=$((i - 1))
  done
}

progressAnimation()
{
  [ $# -eq 0 ] && printError "Internal error: no animation strings."
  animcnt=$#
  anim=1
  firstFrame=true
  while true; do
    spinloop 3000
    # Check for daemonization of this process (ie. orphaned and PPID=1)
    # Cannot actually use "$PPID" as it is set at script initialization
    # and not updated when the parent changes so need to query.
    if ! ppid=$(getParentProcess "$$"); then
      printVerbose "Cannot determine parent process, disable animation"
      exit 1
    fi
    if [ "${ppid}" = "1" ]; then
      # We have been daemonized and owned by PPID=1
      kill HUP "$$" >/dev/null 2>&1
      sleep 1 > /dev/null 2>&1
    fi
    anim=$((anim + 1))
    [ ${anim} -gt ${animcnt} ] && anim=1
    if ${firstFrame}; then
      printf "${ERASELINE}%s\n" "$(getNthArrayArg "${anim}" "$@")"
      firstFrame=false
    else
      printf "${CRSRPL}${ERASELINE}%s\n" "$(getNthArrayArg "${anim}" "$@")"
    fi
  done
}

getNthArrayArg ()
{
    shift "$1"
    echo "$1\c"
}

waitforpid()
{
  while kill -0 "$1" >/dev/null 2>&1; do
    sleep 1
  done
}

progressHandler()
{
 
  if [ -z "${-%%*x*}" ]; then
    # Command trace is active so any progress animation 
    # writing to screen will interleave, making things cluttered.
    # Sleep for 1s (to allow the caller to setup signal handling) and exit
    sleep 1
    exit 0
  fi
  type=$1
  completiontext=$2 # Custom end text (when the process is complete)
  trap "exit" EXIT # If there is an animation error, it will just exit
  if ${ANSION}; then
    trapcmd="/bin/printf \"${CRSRSHOW}${ERASELINE}${CRSRPL}${ERASELINE}${CRSRPL}${ERASELINE}- ${completiontext:-Done}\n\";exit"
    # shellcheck disable=SC2064
    trap "${trapcmd}" HUP
    # shellcheck disable=SC2059
    printf "${CRSRHIDE}"
    case "${type}" in
      "spinner")  progressAnimation '-' '/' '|' '\\' ;;
      "network")  progressAnimation '-----' '>----' '->---' '-->--' '--->-' '---->' '-----' '----<' '---<-' '--<--' '-<---' '<----' ;;
      "mirror")   progressAnimation '#______' '##_____' '#=#____' '#==#___' '#===#__' '#====#_' '#=====#' '#_====#' '#__===#' '#___==#' '#____=#' '#_____#' ;;
      "trash")    progressAnimation 'O________' '_O_______' '__O______' '___o_____' '____o____' '_____o___' '______.__' '_______._' '________.' ;;
      "linkcheck")progressAnimation '------>' '?----->' '-?---->' '--?--->' '---?-->' '----?->' '-----?>';;
      "pkgcheck") progressAnimation '?###?###' '#?###?##' '##?###?#' '###?###?';;
      *)          progressAnimation '.' 'o' 'O' 'O' 'o' '.' ;;
    esac
  else
    trapcmd="/bin/printf \"${completiontext}\n\";exit"
    # shellcheck disable=SC2064
    trap "${trapcmd}" HUP
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
      if [ -n "${SSH_TTY}" ]; then
        chtag -r "${SSH_TTY}"
      fi
      rc=$?
      return ${rc}
    else
      sleep 1
      n=$(( n + 1))
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

assertFailed()
{
  # Used to indicate that something that should have been set in an internal
  # call was missing/borken - a program error rather than a user error
  [ -z "${-%%*x*}" ] && set +x && xtrc="-x" || xtrc=""
  printColors "${NC}${RED}${BOLD}***INTERNAL ASSERTION ERROR: ${NC}${RED}${1}${NC}" >&2
  [ -n "${xtrc}" ] && set -x
  mutexFree "zopen" # prevent lock from lingering around after an error
  exit 12
}

printError()
{
  [ -z "${-%%*x*}" ] && set +x && xtrc="-x" || xtrc=""
  printColors "${NC}${RED}${BOLD}***ERROR: ${NC}${RED}${1}${NC}" >&2
  [ -n "${xtrc}" ] && set -x
  mutexFree "zopen" # prevent lock from lingering around after an error
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
  echo "${zopen_input}"
  stty echo
}

getInput()
{
  read zopen_input
  echo "${zopen_input}"
}

printElapsedTime()
{
  printType=$1
  functionName=$2
  startTime=$3
  elapsedTime=$((SECONDS - startTime))

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
      # shellcheck source=/dev/null
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

  if [ -n "${errorMessage}" ]; then
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
  version=$(echo "${dep}" | awk -F '[>=<]+' '{print $2}')
  if [ -z "${version}" ]; then
    operator=""
    dep=$(echo "${dep}" | awk -F '[>=<]+' '{print $1}')
  else
    operator=$(echo "${dep}" | awk -F '[0-9.]+' '{print $1}' | awk -F '^[a-zA-Z]+' '{print $2}')
    dep=$(echo "${dep}" | awk -F '[>=<]+' '{print $1}')
    case ${operator} in
    ">=") ;;
    "=") ;;
    *) printError "${operator} is not supported." ;;
    esac
    major=$(echo "${version}" | awk -F. '{print $1}')
    minor=$(echo "${version}" | awk -F. '{print $2}')
    if [ -z "${minor}" ]; then
      minor=0
    fi
    patch=$(echo "${version}" | awk -F. '{print $3}')
    if [ -z "${patch}" ]; then
      patch=0
    fi
    prerelease=$(echo "${version}" | awk -F. '{print $4}')
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

getJSONCacheURL(){
  activeRepo="${ZOPEN_ROOTFS}/etc/zopen/repos.d/active"
  [ ! -e "${activeRepo}" ] && printError "Could not access repository configuration at '${activeRepo}'. Check file to ensure valid repository configuration or refresh default configuration with zopen init --refresh -y."

  type=$(jq -r ".type" "${activeRepo}")
  base=$(jq -r ".metadata_baseurl" "${activeRepo}")
  filename=$(jq -r ".metadata_file" "${activeRepo}")
  case "${type}" in
    http|https) printf "%s://%s/%s" "${type}" "${base}" "${filename}";;
    file)     printf "%s:%s/%s" "${type}" "${base}" "${filename}";;
    *)        printError "Unsupported repository type '${type}'.";;
  esac
}

updateJSONCaches()
{
  printVerbose "Ensuring cache directory exists"
  cachedir="${ZOPEN_ROOTFS}/var/cache/zopen"
  [ ! -e "${cachedir}" ] && mkdir -p "${cachedir}"
  jsonCacheURL=$(getJSONCacheURL)

  printVerbose "Checking if the JSON_CACHE already downloaded in this session"
  if [ -z "${JSON_CACHE}" ]; then
    JSON_CACHE="${cachedir}/zopen_releases.json"
    downloadJSONCacheIfExpired "${JSON_CACHE}" "${jsonCacheURL}"
  fi
  if [ -z "${JSON_LATEST_CACHE}" ]; then
    JSON_LATEST_CACHE="${cachedir}/zopen_releases_latest.json"
    latestReleaseURL="$(dirname "${jsonCacheURL}")/zopen_releases_latest.json"
    downloadJSONCacheIfExpired "${JSON_LATEST_CACHE}" "${latestReleaseURL}"
  fi
}

downloadJSONCacheIfExpired()
{
  fileToCache="$1"
  cacheUrl="$2"
  cacheTimestamp="${fileToCache}.timestamp"
  cacheTimestampCurrent="${fileToCache}.timestamp.current"

    # Need to check that we can read & write to the JSON timestamp cache files
    if [ -e "${cacheTimestampCurrent}" ]; then
      [ ! -w "${cacheTimestampCurrent}" ] || [ ! -r "${cacheTimestampCurrent}" ] && printError "Cannot access cache at '${cacheTimestampCurrent}'. Check permissions and retry request."
    fi
    if [ -e "${cacheTimestamp}" ]; then
      [ ! -w "${cacheTimestamp}" ] || [ ! -r "${cacheTimestamp}" ] && printError "Cannot access cache at '${cacheTimestamp}'. Check permissions and retry request."
    fi
    if [ -e "${fileToCache}" ]; then
      [ ! -w "${fileToCache}" ] || [ ! -r "${fileToCache}" ] && printError "Cannot access cache at '${JSON_CACHE}'. Check permissions and retry request."
    fi

    if ! curlCmd -f -L -s -I "${cacheUrl}" -o "${cacheTimestampCurrent}"; then
      printError "Failed to obtain json cache timestamp from ${cacheUrl}."
    fi
    chtag -tc 819 "${cacheTimestampCurrent}"

    if [ -f "${fileToCache}" ] \
       && [ -f "${cacheTimestamp}" ] \
       && [ "$(grep 'Last-Modified' "${cacheTimestampCurrent}")" = "$(grep 'Last-Modified' "${cacheTimestamp}")" ]; then
      # Metadata cache unchanged
      return
    fi

    printVerbose "Replacing old timestamp with latest."
    mv -f "${cacheTimestampCurrent}" "${cacheTimestamp}"

    if ! curlCmd -f -L -s -o "${fileToCache}" "${cacheUrl}"; then
      printError "Failed to obtain json cache from '${cacheUrl}'"
    fi
    chtag -tc 819 "${fileToCache}"
  if [ ! -f "${fileToCache}" ]; then
    printError "Could not download json cache from '${cacheUrl}"
  fi
}

downloadJSONCache()
{
  if ! updateJSONCaches; then
    return 1
  else
    return 0
  fi
  ##TODORM>>
  if [ -z "${JSON_CACHE}" ]; then
    cachedir="${ZOPEN_ROOTFS}/var/cache/zopen"
    [ ! -e "${cachedir}" ] && mkdir -p "${cachedir}"
    JSON_CACHE="${cachedir}/zopen_releases.json"
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

    jsonCacheURL=$(getJSONCacheURL)
    if ! curlCmd -f -L -s -I "${jsonCacheURL}" -o "${JSON_TIMESTAMP_CURRENT}"; then
      printError "Failed to obtain json cache timestamp from ${jsonCacheURL}."
    fi
    chtag -tc 819 "${JSON_TIMESTAMP_CURRENT}"

    if [ -f "${JSON_CACHE}" ] \
       && [ -f "${JSON_TIMESTAMP}" ] \
       && [ "$(grep 'Last-Modified' "${JSON_TIMESTAMP_CURRENT}")" = "$(grep 'Last-Modified' "${JSON_TIMESTAMP}")" ]; then
      # Metadata cache unchanged
      return
    fi

    printVerbose "Replacing old timestamp with latest."
    mv -f "${JSON_TIMESTAMP_CURRENT}" "${JSON_TIMESTAMP}"

    if ! curlCmd -f -L -s -o "${JSON_CACHE}" "${jsonCacheURL}"; then
      printError "Failed to obtain json cache from '${jsonCacheURL}'"
    fi
    chtag -tc 819 "${JSON_CACHE}"
  fi

  if [ ! -f "${JSON_CACHE}" ]; then
    printError "Could not download json cache from '${jsonCacheURL}"
  fi
  ## <<TODORM
}

# getRepos
# Queries the main repository list to obtain a list of all available port
# names, populating the repo_results global var
# inputs: none
# return: 0  success
#         1  failure
getRepos()
{
  updateJSONCaches
  # shellcheck disable=SC2034
  repo_results="$(jq -r '.release_data | keys[]' "${JSON_CACHE}")"
}

# isValidRepo
# Queries the main repository list to determine if the input is valid,  This 
# uses jq itself to return 0 or 1 with no output
# inputs: $1 the port name.

# return: 0  valid port name
#         1  invalid port name
isValidRepo()
{
  updateJSONCaches
  jq -r --arg needle "$1" 'if .release_data | has($needle) then empty else error("") end'  "${JSON_CACHE}" > /dev/null 2>&1
}

#Deprecated
getRepoReleases()
{
  updateJSONCaches
  repo="$1"
  ##TODO 
  ##TDORM releases="$(jq -e -r '.release_data."'${repo}'"' "${JSON_CACHE}")"
  ##TDORM if [ $? -ne 0 ]; then
    ##TDORM printError "Could not get all releases for ${repo}"
  ##TDORM fi
}

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

generateUUID() 
{
  date_part=$(date +%s)
  random_part=$((RANDOM))
  uuid="${date_part}-${random_part}"
  echo "${uuid}"
}

isURLReachable() {
  url="$1"
  timeout=5

  if curlCmd -s --fail --max-time $timeout "$url" > /dev/null; then
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
  printInfo "- Enough space to install ${package}. Proceeding installation."
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

startGPGAgent() {
  printInfo "- Starting gpg-agent..."

  SOCKET_PATH=$(gpgconf --list-dirs agent-socket)
  if [ -r "$SOCKET_PATH" ]; then
    printVerbose "gpg-agent is already running (socket found at $SOCKET_PATH)."
    return 0
  fi

  if eval "$(gpg-agent --daemon --disable-scdaemon)" >/dev/null 2>&1; then
    if [ -r "$SOCKET_PATH" ]; then
      printVerbose "gpg-agent started successfully (socket created at $SOCKET_PATH)."
    else
      printWarning "gpg-agent started, but socket was not created at $SOCKET_PATH. Please verify your GPG installation."
    fi
  else
    if [ -r "$SOCKET_PATH" ]; then
      printWarning "gpg-agent started successfully (socket created at $SOCKET_PATH), but gpg-agent returned a non-zero return code."
    else
      printError "Failed to start gpg-agent. Reinstall or upgrade GPG using \"zopen install --reinstall gpg -y\" or \"zopen upgrade gpg -y\"."
    fi
  fi
}

promptYesNoAlways() {
  message="$1"
  skip=$2
  if ! ${skip}; then
    while true; do
      /bin/printf "${message} [y/n/a] "
      read answer < /dev/tty
      answer=$(echo "${answer}" | tr '[A-Z]' '[a-z]')
      case "${answer}" in
       y|yes) return 0;;
       n|no) return 1;;
       a|always) yesToPrompts=true; return 0;;
      esac
    done
  fi
  return 1
}

getVersionedMetadata()
{
  printDebug "Specific version ${versioned} requested - checking existence and URL"
  requestedMajor=$(echo "${versioned}" | awk -F'.' '{print $1}')
  requestedMinor=$(echo "${versioned}" | awk -F'.' '{print $2}')
  requestedPatch=$(echo "${versioned}" | awk -F'.' '{print $3}')
  requestedSubrelease=$(echo "${versioned}" | awk -F'.' '{print $4}')
  requestedVersion="${requestedMajor}\\\.${requestedMinor}\\\.${requestedPatch}\\\.${requestedSubrelease}"
  printDebug "Finding URL for latest release matching version prefix: requestedVersion: ${requestedVersion}"
  releasemetadata=$(jq --arg repo "${repo}" --arg requestedVersion "${requestedVersion}" \
      '.release_data[$repo] | map(select(.assets[].version | test($requestedVersion)))[0]' "${JSON_CACHE}")
}

getTaggedMetadata()
{
  printDebug "Explicit tagged version '${tagged}' specified. Checking for match"
  releasemetadata=$(/bin/printf "%s" "${releases}" | jq -e -r '.[] | select(.tag_name == "'"${tagged}"'")')
  releasemetadata=$(jq --arg repo "${repo}" --arg requestedVersion "${requestedVersion}" \
    '.release_data[$repo][] | select(.tag_name == $tag_name)' "${JSON_CACHE}")
  printDebug "Use quick check for asset to check for existence of metadata for specific messages"
  asset=$(/bin/printf "%s" "${releasemetadata}" | jq -e -r '.assets[0]')
  if [ $? -ne 0 ]; then
    printError "Could not find release tagged '${tagged}' in repo '${repo}'"
  fi
}

getSelectMetadata()
{
  # As this is running within the generate... logic, a progress handler will have been started.
  # This needs to be terminated before trying to write to screen
  # shellcheck disable=SC2154
  kill -HUP "${PROGRESS_HANDLER}" >/dev/null 2>&1 # if the timer is not running, the kill will fail
  waitforpid "${PROGRESS_HANDLER}"  # Make sure it's finished writing to screen
  
  repo="$1"
  # Explicitly allow the user to select a release to install; useful if there are broken installs
  # as a known good release can be found, selected and pinned!
  printDebug "List individual releases and allow selection"
  i=$(jq --arg repo "${repo}" '.release_data[$repo] | length - 1' "${JSON_CACHE}")
  printInfo "Versions available for install:"
  if ! jq --raw-output --arg repo "${repo}"  \
      '.release_data[$repo] | to_entries | map("\(.key): \(.value.tag_name) - \(.value.assets[0].name) [\( ( .value.assets[0].expanded_size|tonumber)*1000 / (1024 * 1024) | ceil | . / 1000)Mb]")[]' "${JSON_CACHE}"; then
    printError "Unable to enumerate asset version strings"
  fi
  printDebug "Getting user selection"
  valid=false
  while ! ${valid}; do
    echo "Enter version to install (0-${i}): "
    read selection < /dev/tty
    if [ -n "$(echo "${selection}" | sed -e 's/[0-9]*//')" ]; then
      echo "Invalid input, must be a number between 0 and ${i}"
    elif [ "${selection}" -ge 0 ] && [ "${selection}" -le "${i}" ]; then
      valid=true
    fi
  done
  printVerbose "Selecting item ${selection} from array"
  releasemetadata=$(jq --arg repo "${repo}" --arg selection "${selection}" \
      '.release_data[$repo][$selection | tonumber]' "${JSON_CACHE}")
}

getReleaseLineMetadata()
{ 
  printDebug "Install from release line '${releaseLine}' specified"
  validatedReleaseLine=$(validateReleaseLine "${releaseLine}")
  if [ -z "${validatedReleaseLine}" ]; then
    printError "Invalid releaseline specified: '${releaseLine}'; Valid values: DEV or STABLE"
  fi
  printDebug "Finding latest asset on the release line"
  releasemetadata=$(jq --arg repo "${repo}" --arg releaseLine "${validatedReleaseLine}" \
      '.release_data[$repo] | map(select(.tag_name | startswith($releaseLine)))[0]' "${JSON_CACHE}")
  printDebug "Use quick check for asset to check for existence of metadata"
  asset="$(/bin/printf "%s" "${releasemetadata}" | jq -e -r '.assets[0]')"
  if [ $? -ne 0 ]; then
    printError "Could not find release-line ${releaseLine} releases for repo: ${repo}"
  fi
  unset "${releaseLine}"
}

calculateReleaseLineMetadata()
{
  repo="$1"
  printDebug "No explicit version/tag/releaseline, checking for pre-existing package&releaseline"
  if [ -n "${installedReleaseLine}" ]; then
    printDebug "Found existing releaseline '${installedReleaseLine}', restricting to only that releaseline"
    validatedReleaseLine="${installedReleaseLine}"  # Already validated when stored
  else 
    printDebug "Checking for system-configured releaseline"
    if [ -e "${ZOPEN_JSON_CONFIG}" ]; then
      printDebug "Using v2 configuration: '${ZOPEN_JSON_CONFIG}'"
      sysrelline=$(jq -re '.release_line' "${ZOPEN_JSON_CONFIG}")
    elif [ -e "${ZOPEN_ROOTFS}/etc/zopen/releaseline" ] ; then
      printDebug "Using legacy file-based config"
      sysrelline=$(awk ' {print toupper($1)}') < "${ZOPEN_ROOTFS}/etc/zopen/releaseline"
    fi
    printDebug "Validating value: ${sysrelline}"
    validatedReleaseLine=$(validateReleaseLine "${sysrelline}")
    if [ -n "${validatedReleaseLine}" ]; then
      printDebug "zopen system configured to use releaseline '${sysrelline}'; restricting to that releaseline"
    else
      printWarning "zopen misconfigured to use an unknown releaseline of '${sysrelline}'; defaulting to STABLE packages"
      printWarning "Set the contents of '${ZOPEN_ROOTFS}/etc/zopen/releaseline' to a valid value to remove this message"
      printWarning "Valid values are: DEV | STABLE"
      validatedReleaseLine="STABLE"
    fi
  fi

    # We have some situations that could arise
    # 1. the port being installed has no releaseline tagging yet (ie. no releases tagged STABLE_* or DEV_*)
    # 2. system is configured for STABLE but only has DEV stream available
    # 3. system is configured for DEV but only has STABLE stream available
    # 4. the port being installed has got full releaseline tagging
    # The issue could arise that the user has switched the system from DEV->STABLE or vice-versa so package
    # stream mismatches could arise but in normal case, once a package is installed [that has releaseline tagging]
    # then that specific releaseline will be used
  printDebug "Finding any releases tagged with ${validatedReleaseLine} and getting the first (newest/latest)"
  releasemetadata=$(jq --arg repo "${repo}" --arg releaseLine "${validatedReleaseLine}" \
      '.release_data[$repo] | map(select(.tag_name | startswith($releaseLine)))[0]' "${JSON_CACHE}")

  printDebug "Use quick check for asset to check for existence of metadata"
  asset="$(/bin/printf "%s" "${releasemetadata}" | jq -e -r '.assets[0]')"
  [ "${asset}" = "null" ] && asset="" # jq uses null, translate to sh's empty

  if [ -n "${asset}" ]; then
    # Case 4...
    printVerbose "Found a specific '${validatedReleaseLine}' release-line tagged version; installing..."
  else
    # Case 2 & 3
    printDebug "No releases on releaseline '${validatedReleaseLine}'; checking alternative releaseline"
    alt=$(echo "${validatedReleaseLine}" | awk ' /DEV/ { print "STABLE" } /STABLE/ { print "DEV" }')
    releasemetadata=$(jq --arg repo "${repo}" --arg releaseLine "${alt}" \
        '.release_data[$repo] | map(select(.tag_name | startswith($releaseLine)))[0]' "${JSON_CACHE}")
    printDebug "Use quick check for asset to check for existence of metadata"
    asset="$(/bin/printf "%s" "${releasemetadata}" | jq -e -r '.assets[0]')"
    [ "${asset}" = "null" ] && asset=""  # jq uses null, translate to sh's empty
    if [ $? -eq 0 ]; then
      printDebug "Found a release on the '${alt}' release line so release tagging is active"
      if [ "DEV" = "${validatedReleaseLine}" ]; then
        # The system will be configured to use DEV packages where available but if none, use latest
        printInfo "No specific DEV releaseline package, using latest available release"
        releasemetadata=$(jq --arg repo "${repo}" '.release_data[$repo][0]' "${JSON_CACHE}")
      else
        printVerbose "The system is configured to only use STABLE releaseline packages but there are none"
        printInfo "No release available on the '${validatedReleaseLine}' releaseline."
      fi
    else
      # Case 1 - old package that has no release tagging yet (no DEV or STABLE), just install latest
      printVerbose "Installing latest release"
      releasemetadata=$(jq --arg repo "${repo}" '.release_data[$repo][0]'  "${JSON_CACHE}")
    fi
  fi
}

parseRepoName()
{
  fullname="$1"
  printDebug "Name to install: ${fullname}, parsing any version ('=') or tag ('%') that has been specified"
  name=$(echo "${fullname}" | sed -e 's#[=%].*##')
  repo="${name}"
  versioned=$(echo "${fullname}" | cut -s -d '=' -f 2)
  tagged=$(echo "${fullname}" | cut -s -d '%' -f 2)
  printDebug "Name:${name};version:${versioned};tag:${tagged};repo:${repo}"
}

getPortMetaData(){
  portRequested="$1"
  invalidPortAssetFile="$2"
  printDebug "Removing any version (%) or tag (#) suffixes fron '${portRequested}"
  portName=$(echo "${portRequested}" | sed -e 's#%.*##' -e 's#=.*##')

  if ! isValidRepo "${portName}"; then
    echo "${portName}: no matching port found" >> "${invalidPortAssetFile}"
    return 1
  fi

  parseRepoName "${portRequested}" # To set the various status flags below
  getRepoReleases "${portName}"
  if [ -n "${versioned}" ]; then
    getVersionedMetadata "${portName}"
  elif [ -n "${tagged}" ]; then
    getTaggedMetadata "${portName}"   
  elif # shellcheck disable=SC2154
       ${selectVersion}; then
    selectVersion=false  # Need to set this to prevent selection of dependencies
    getSelectMetadata "${portName}"
  elif [ -n "${releaseLine}" ]; then  
    getReleaseLineMetadata "${portName}"     
  else
    calculateReleaseLineMetadata "${portName}"
  fi
  if [ -z "${releasemetadata}" ]; then 
    echo "${portName}: metadata could not be found" >> "${invalidPortAssetFile}"
    return 1
  fi
  printDebug "Getting specific asset details using metadata: ${releasemetadata}"
  if [ -z "${asset}" ] || [ "null" = "${asset}" ]; then
    printDebug "Asset not found during previous logic; setting now"
    asset=$(/bin/printf "%s" "${releasemetadata}" | jq -e -r '.assets[0]')
  fi
  if [ -z "${asset}" ]; then
    echo "${portName} asset metadata could not be found" >> "${invalidPortAssetFile}"
    return 1
  fi
  return 0
}

# createDependancyGraph
# analyzes the input file to create the list of all packages that are to
# be pulled in during install - and recurses if any added packages themselves
# pull in dependancies, dependencies being added to the front of the install queue
# inputs: $1 the file to use for install ports
#         $2 an error file for outputing failures
# return: 0  for success (output of pwd -P command)
#         8  if error
createDependancyGraph()
{
  invalidPortAssetFile=$1 && shift 
  printDebug "Getting list of dependencies"
  dependencies=$(echo "${installList}" | jq --raw-output '.installqueue[] | select(.asset.runtime_dependencies | test("No dependencies") | not )| map(try(.runtime_dependencies |= split(" ")))| .[] | .runtime_dependencies[] ')
  printDebug "Removing any dependencies already on install queue"
  installing=$(echo "${installList}" | jq --raw-output '.installqueue[] | .portname')
  # TODO: Use JQ to diff?
  missing=$(diffList "${installing}" "${dependencies}" )
  if [ -z "${missing}" ]; then
    printDebug "All dependencies are in the install graph"
    return 0
  fi
  printDebug "Adding dependencies to install graph"
  addToInstallGraph "dependancy" "${invalidPortAssetFile}" "${missing}"
  # Recurse in case the now-installing dependencies themselves have dependencies
  # Recursive dependencies should not break as the initial package will have been
  # marked for installation
  createDependancyGraph "${invalidPortAssetFile}"
}

# addToInstallGraph
# Finds appropriate metadata for the specified port(s) and
# includes that in the installation file
# inputs: $1 if the install list comes from dependency analysis
#         $2 an error file for outputing failures
#         $* requested list of packages to install
# return: 0  for success (output of pwd -P command)
#         8  if error
addToInstallGraph(){
  installtype=$1 && shift
  invalidPortAssetFile=$1 && shift 
  pkgList="$1"
  printDebug "Adding pkgList to install graph"
  for portRequested in ${pkgList}; do
    if ! getPortMetaData "${portRequested}" "${invalidPortAssetFile}"; then
      continue
    fi
    ## Merge asset into JSON install list
    installList=$(echo "${installList}" | \
      jq ".installqueue += [{\"portname\":\"${portName}\", \"asset\":${asset}, \"installtype\":\"${installtype}\"}]")
  done
  if [ -e "${invalidPortAssetFile}" ]; then
    printSoftError "The following ports cannot be installed: "
    while read invalidPort; do
      printf "${WARNING} %s\n" "${invalidPort}"
    done < "${invalidPortAssetFile}"
    printError "Confirm port names, remove any 'port' suffixes and retry command."
  fi
}

validateInstallList(){
  installees="$1"
  # shellcheck disable=SC2086 # Using set -f disables globbing
  printVerbose "Stripping any version/tagging"
  installees=$(set -f; echo ${installees} |awk  -v ORS=, -v RS=' ' '{$1=$1; sub(/[=%].*/,x); print "\""$1"\""}')
  invalidPortList=$(jq -r --argjson needles "[${installees%%,}]" \
    '.release_data| keys as $haystack | $needles | map(select(. as $needle | $haystack | index($needle)|not)) | .[]'  "${JSON_CACHE}")
  if [ -n "${invalidPortList}" ]; then
    printSoftError "The following ports could not be installed:"
    printSoftError "    $(echo "${invalidPortList}" | awk -v OFS=' ' -v ORS=' ' '{$1=$1};1' )"
    printError "Check port name(s), remove any extra 'port' suffixes and retry command."
  fi
}

dedupStringList()
{ delim="$1" && shift
  str="$1"
  echo "${str}"| awk -v delim="${delim}" '                                                                                                      
    { dlm=""; for (i=1; i<=NF; i++) {if (!seen[$i]++) {printf "%s%s", dlm, $i};dlm=delim};print ""}'
}

# generateInstallGraph
# generates a file with details for packages that are to be installed from
# the in-use repository, reporting errors if ports were invalid and
# triggering dependency graph population
# inputs: $1 the file to use for validated ports
#         $* requested list of packages to install
# return: 0  for success (output of pwd -P command)
#         8  if error
generateInstallGraph(){
  installList="{}"
  printDebug "Parsing list of packages to install and verifying validity"
  portsToInstall="$1" # start with the initial list
  portsToInstall=$(dedupStringList ' ' "${portsToInstall}")

  # Create the following file here to trigger cleanup - otherwise, multiple
  # tempfiles could be created depending on dependency graph depth
  invalidPortAssetFile=$(mktempfile "invalid" "port")
  addCleanupTrapCmd "rm -rf ${invalidPortAssetFile}"
  if ! runLogProgress " addToInstallGraph \"install\" \"\${invalidPortAssetFile}\" \"\${portsToInstall}\"" \
      "Creating install graph" "Created install graph" "linkcheck"; then
    printError "Unexpected error whilecreating install graph. Correct errors and retry command."
  fi
  ##TODORM addToInstallGraph "install" "${invalidPortAssetFile}" "${portsToInstall}"

  # shellcheck disable=SC2154
  if ! ${doNotInstallDeps} && { (! ${reinstall} && ! ${reinstallDeps}) || (${reinstall} && ${reinstallDeps}); }; then
    # doNotInstallDeps was not explicitly set and we are either not reinstalling(vanilla install) or we
    # are reinstalling AND the reinstallDependencies flag is set; we do not want
    # to reinstall a package and all it's dependencies by default, just the package itself
    printVerbose "Calculating dependancy graph"
    if ! runLogProgress "createDependancyGraph \"\${invalidPortAssetFile}\"" \
        "Creating dependancy graph" "Created dependancy graph" "linkcheck"; then
      printError "Unexpected error while creating dependancy graph. Correct errors and retry command."
    fi
    ##TODORM createDependancyGraph "${invalidPortAssetFile}"
  else
    printVerbose "- Skipping dependency analysis"
  fi

  ##TODORM>>
  # shellcheck disable=SC2154
  #if ${doNotInstallDeps}; then
  #    printVerbose "- Skipping dependency analysis"
  #else
    # calculate dependancy graph
  #  createDependancyGraph "${invalidPortAssetFile}"
  #fi
  ##<<TODORM
  # shellcheck disable=SC2154
  if "${reinstall}"; then 
    printVerbose "Not pruning already installed packages as reinstalling"
  else
    parseGraph
  fi  
}

parseGraph()
{
  printDebug "Parsing graph for valid entries"
  # shellcheck disable=SC2154
  if "${downloadOnly}"; then
    # Download the pax files, even if already installed or if they would
    # fail validation - the user wants the files downloaded for whatever reason
    return 0
  fi
  if ! processActionScripts "parseGraphPre" "${installList}"; then
    exit 1
  fi

  # Prune already installed packages at the requested level; compare the 
  # incoming file name against the port name, version and release already on the system
  # - seems to be the easiest comparison since some data is not in zopen_release vs metadata.json
  # and a local pax won't have a remote repo but should have a file name!

installList=$(jq --argjson install_list "${installList}" '
. as $input | 
{
  "installqueue": (
    $install_list.installqueue | map(select( .portname as $pnn | .asset.release as $r |
[$input[] | to_entries[] | select(.key == $pnn) | .value]| all(.product.release != $r)    
    ))) 
} ' "${ZOPEN_ROOTFS}/var/lib/zopen/packageDB.json"
)
##TODORM>>
hidden(){
  installed=$(zopen list --installed --details)
  # Ignore the version string - it varies across ports so use name and build time as that
  # should be unique enough
  installed=$(echo "${installed}"| awk 'BEGIN{ORS = "," } {print "\"" $1 "@=@" $3 "\""}')
  installed="[${installed%,}]"
  
  installList=$(echo "${installList}" | \
    jq  --argjson installees "${installed}" \
      '.installqueue |=
        map(
          select(.asset.url |
            capture(".*/(?<name>.*)-(?<ver>[^-]*)\\.(?<rel>\\d{8}_\\d{6}?)\\.zos\\.pax\\.Z$") |.rel as $rel | .name as $name |
            $installees | map(
              .|capture("(?<iname>[^@]*)@=@(?<irel>\\d{8}_\\d{6}?)$")|.iname as $iname | .irel as $irel |
              ($iname+"-"+$irel) == ($name+"-"+$rel)
            ) | any == false
          )
        )'\
  )
}  
##<<TODORM
  if ! processActionScripts "parseGraphPost"; then
    exit 1
  fi
}

checkIfPrereq(){
  # This jq query analyses the package database, looking for objects where the
  # runtime dependency contains $1 (the removee). It extracts the keys from those
  # objects into $dependents then outputs the flattened dependents array along with
  # eithr true or false depending on if there was a prereq found (true) or if not
  # false; the exit-status parameter then sets the exit code of jq dependning on that
  # true/false value!
  jq -r --exit-status --arg removee "$1" \
      '[.[] | to_entries | map(select(.value.product.runtime_dependencies[]?.name == $removee)) | .[].key] | . as $dependents | $dependents[], ($dependents | length > 0)' \
      "${ZOPEN_ROOTFS}/var/lib/zopen/packageDB.json"
}


spaceValidate(){
  spaceRequiredBytes=$1
  spaceRequiredMB=$(echo "scale=0; ${spaceRequiredBytes} / (1024 * 1024)" | bc)
  availableSpaceMB=$(/bin/df -m "${ZOPEN_ROOTFS}" | sed "1d" | awk '{ print $3 }' | awk -F'/' '{ print $1 }')

  printInfo "After this operation, ${spaceRequiredMB} MB of additional disk space will be used."
  if [ "${availableSpaceMB}" -lt "${spaceRequiredMB}" ]; then
    printWarning "Your zopen file-system (${ZOPEN_ROOTFS}) only has ${availableSpaceMB} MB of available space."
  fi
  if ! ${yesToPrompts} || [ "${availableSpaceMB}" -lt "${spaceRequiredMB}" ]; then
    while true; do
      /bin/printf "Do you want to continue [y/n/a]? "
      read continueInstall < /dev/tty
      case "${continueInstall}" in
        "y") break;;
        "n") mutexFree "zopen"; printInfo "Exiting..."; exit 0 ;;
        "a") yesToPrompts=true; break;;
        *) echo "?";;
      esac
    done
  fi
}

processRepoInstallFile(){
  printVerbose "Beginning port installation"
  mutexReq "zopen"
  
  processActionScripts "transactionPre"
  if [ 0 -eq "$(echo "${installList}" | jq --raw-output '.installqueue| length')" ]; then
    printInfo "- No packages to install"
    return 0
  fi

  # shellcheck disable=SC2154
  if ${fileinstall}; then
    : 
  else
    if ! ${quiet} >/dev/null 2>&1; then
      xIFS=$IFS
      IFS=' '
      hdr=false
      for installee in $(echo "${installList}" | jq --raw-output '.installqueue | map( (select(.installtype=="install") | .portname| sub(" ";"") ))| @sh'); do
        installee=$(echo "${installee}" |tr -d "\'" )
        [ -z "${installee}" ] && continue
        if ! ${hdr}; then
          printHeader "Installing the following packages:"
          hdr=true
        fi
        printInfo "${installee}"

      done
      hdr=false
      for dependee in $(echo "${installList}" | jq --raw-output '.installqueue | map( (select(.installtype=="dependancy") | .portname| sub(" ";"") ))| @sh'); do
        dependee=$(echo "${dependee}" |tr -d "\'" )
        [ -z "${dependee}" ] && continue
        if ! ${hdr}; then
          printHeader "Dependent packages to install:"
          hdr=true
        fi
        printInfo "${dependee}"
      done
      IFS=${xIFS}
    fi
    spaceRequiredBytes=$(echo "${installList}" | jq --raw-output '.installqueue| map(.asset.size, .asset.expanded_size)| reduce .[] as $total (0; .+($total|tonumber))')
    spaceValidate "${spaceRequiredBytes}"
  fi

  processActionScripts "transactionPre"
  for installurl in $(echo "${installList}" | jq --raw-output '.installqueue |map( (.asset.url| sub(" ";"") ))| @sh'); do
    printVerbose "Analysing :'${installurl}'"
    installurl=$(echo "${installurl}" | tr -d "' ")
    getInstallFile "${installurl}"
    if $downloadOnly; then
      continue
    fi
    installFile="${installurl##*/}"
    if [ ! "${installFile%.zos.pax.Z}" = "${installFile}" ]; then
      # Found zos.pax.Z format
      if ! installFromPax "${installFile}"; then
        printError "Package installation terminated"
      fi
    else
      printError "Unrecognised install file format"
    fi
  done
  processActionScripts "transactionPost"
  mutexFree "zopen"
  printVerbose "Port installation complete"
}

getInstallFile()
{
  installurl="$1"
  metadataJSONURL="$(dirname "${installurl}")/metadata.json"
  metadataFile="$(basename "${installurl}").json"
  downloadToDir="${ZOPEN_ROOTFS}/var/cache/zopen"
  if $downloadOnly; then
    downloadToDir="."
  else
    downloadToDir="${ZOPEN_ROOTFS}/var/cache/zopen"
  fi
  if [ -e "${downloadToDir}/${installurl##*/}" ]; then
    :
  else
    [ -e "${downloadToDir}" ] || mkdir -p "${downloadToDir}"
    [ -w "${downloadToDir}" ] || printError "No permission to save install file to '${downloadToDir}'. Check permissions and retry command."
    printVerbose "Downloading installable file"
    if ! runAndLog "cd ${downloadToDir} && curlCmd --no-progress-meter -L ${installurl} -O ${redirectToDevNull}"; then
      printError "Could not download from ${installurl}. Correct any errors and potentially retry"
    fi
    printVerbose "Downloading corresponding metadata"
    if ! runAndLog "curlCmd -L '${metadataJSONURL}' -o '${metadataFile}'" "${redirectToDevNull}"; then
      printError "Could not download from ${metadataJSONURL}. Correct any errors and potentially retry."
    else
      if command -v chtag >/dev/null 2>&1; then
        # Curl currently does not know on z/OS to set the text flag for text files
        printVerbose "Metadata file downloaded, ensuring 'text' flag set for z/OS"
        chtag -t "${metadataFile}"
      fi
    fi
  fi
}

extractMetadataFromPax()
{
  if ! pax -rf "$1" -s "%[^/]*/%/tmp/%" '*/metadata.json' ; then
    if ! details=$(pax -rf "$1" -s "%[^/]*/%/tmp/%" '*/package.json'); then
      printSoftError "Could not extract package metadata from file '$1'."
      [ -n "${details}" ] && printSoftError "Details: ${details}"
      return 1
    else
      echo "/tmp/package.json"
    fi
  else
    echo "/tmp/metadata.json"
  fi
}

installFromPax()
{
  pax="${downloadToDir}/$1"
  printDebug "Installing from '${pax}'"

  if ! metadatafile=$(extractMetadataFromPax "${pax}"); then
    return 1
  fi

  # Ideally we would use the following, 
  #  name=$(jq --raw-output '.product.name' "${metadatafile}") 
  # but name does not always map to the actual repo package name at present!
  # The repo name is in the.product.repo field so can extract from there instead -
  # though this also has issues for some packages like NATS/nats ...
  # Note that at present some metadata might refer to the legacy repo ZOSOpenTools
  # so fall back to that
  if [ -n "${USEPRODNAME}" ]; then
    printVerbose "Extracting product name from .product.repo"
    #  name=$(jq --raw-output '.product.name' "${metadatafile}") 
  else
    printVerbose "Extracting product name from .product.repo"
    name=$(jq --arg reponame "${ZOPEN_ORGNAME}" --raw-output '.product.repo | match(".*/\($reponame)/(.*)port").captures[0].string' "${metadatafile}")
    if [ -z "${name}" ] || [ "${name##*[^ ]*}" = "" ]; then  
      name=$(jq --arg reponame "ZOSOpenTools" --raw-output '.product.repo | match(".*/\($reponame)/(.*)port").captures[0].string' "${metadatafile}")
    fi
    if [ -z "${name}" ] || [ "${name##*[^ ]*}" = "" ]; then  
      printError "Unable to determine name from .product.repo in '${metadatafile}'. Check metadata is correct."
    fi
  fi


  if ! processActionScripts "installPre" "${name}" "${metadatafile}" "${pax}"; then
    printError "Failed installation pre-requisite check(s) for '${name}'. Correct previous errors and retry command"
  fi

  # Store current installation directory (if exists)
  currentderef=$(cd "${ZOPEN_PKGINSTALL}/${name}/${name}" > /dev/null 2>&1 && pwd -P)

  paxname="${installurl##*/}"
  installdirname="${name}/${paxname%.pax.Z}" # Use full pax name as default

  baseinstalldir="${ZOPEN_PKGINSTALL}"
  paxredirect="-s %[^/]*/%${ZOPEN_PKGINSTALL}/${installdirname}/%"

  printDebug "Check for existing directory for version '${installdirname}'"
  if [ -d "${ZOPEN_PKGINSTALL}/${installdirname}" ]; then 
    printVerbose "- Clearing existing directory and contents"
    rm -rf "${ZOPEN_PKGINSTALL}/${installdirname}"
  fi

  # shellcheck disable=SC2154
  if ! runLogProgress "pax -rf ${pax} -p p ${paxredirect} ${redirectToDevNull}" \
      "Expanding file: ${pax}" "Expanded file:  ${pax}"; then
    printSoftError "Unexpected errors during unpaxing, package directory state unknown"
    printError "Use zopen alt to select previous version to ensure known state"
  fi

  if [ -e "${ZOPEN_PKGINSTALL}/${name}/${name}/.pinned" ]; then
    printWarning "Current version of ${name} is pinned; not setting updated version as active"
    printWarning "Remove .pinned file and run 'zopen alt meta' to use new version"
    setactive=false
    unInstallOldVersion=false
  fi
  # shellcheck disable=SC2154
  if ${setactive}; then
    if [ -L "${ZOPEN_PKGINSTALL}/${name}/${name}" ]; then
      printDebug "Removing old symlink '${ZOPEN_PKGINSTALL}/${name}/${name}'"
      rm -f "${ZOPEN_PKGINSTALL}/${name}/${name}"
    fi
    if ! ln -s "${ZOPEN_PKGINSTALL}/${installdirname}" "${ZOPEN_PKGINSTALL}/${name}/${name}"; then
      printError "Could not create symbolic link name"
    fi 
    if ! ${nosymlink}; then
      if ! runLogProgress "mergeIntoSystem \"${name}\" \"${ZOPEN_PKGINSTALL}/${installdirname}\" \"${ZOPEN_ROOTFS}\"" \
          "Merging ${name} into symlink mesh" "Merged ${name} into symlink mesh"; then
        printSoftError "Unexpected errors merging symlinks into mesh"
        printError "Use zopen alt to select previous version to ensure known state"
      fi
      ##TODORM mergeIntoSystem "${name}" "${ZOPEN_PKGINSTALL}/${installdirname}" "${ZOPEN_ROOTFS}" 
      ##TODORM misrc=$?
      ##TODORM printDebug "The merge complete with: ${misrc}"
    fi

    printVerbose "- Checking for env file"
    if [ -f "${ZOPEN_PKGINSTALL}/${name}/${name}/.env" ] || [ -f "${ZOPEN_PKGINSTALL}/${name}/${name}/.appenv" ]; then
      printVerbose "- .env file found, adding to profiled processing"
      mkdir -p "${ZOPEN_ROOTFS}/etc/profiled/${name}"
      cat << EOF > "${ZOPEN_ROOTFS}/etc/profiled/${name}/dotenv"
curdir=\$(pwd)
cd "${ZOPEN_PKGINSTALL}/${name}/${name}" >/dev/null 2>&1
# If .appenv exists, source it as it's quicker
if [ -f ".appenv" ]; then
  . ./.appenv
elif [ -f ".env" ]; then
  . ./.env
fi
cd \${curdir}  >/dev/null 2>&1
EOF
      printVerbose "- Running any setup scripts"
      cd "${ZOPEN_PKGINSTALL}/${name}/${name}" && [ -r "./setup.sh" ] && ./setup.sh >/dev/null
    fi
  fi
  if ${unInstallOldVersion}; then
    printDebug "New version merged; checking for orphaned files from previous version"
    # This will remove any old symlinks or dirs that might have changed in an upgrade
    # as the merge process overwrites existing files to point to different version
    unsymlinkFromSystem "${name}" "${ZOPEN_ROOTFS}" "${currentderef}/.links" "${baseinstalldir}/${name}/${name}/.links"
  fi

  if ${setactive}; then
    printDebug "Marking this version as installed"
    touch "${ZOPEN_PKGINSTALL}/${name}/${name}/.active"
    installedList="${name} ${installedList}"
    syslog "${ZOPEN_LOG_PATH:-${ZOPEN_ROOTFS}/var/log}/audit.log" "${LOG_A}" "${CAT_INSTALL},${CAT_PACKAGE}" "DOWNLOAD" "handlePackageInstall" "Installed package:'${name}';version:${downloadFileVer};install_dir='${baseinstalldir}/${installdirname}';"
    addToInstallTracker "${name}"    
        # Some installation have installation caveats
    installCaveat=$(jq -r '.product.install_caveats // empty' "${metadatafile}" 2>/dev/null)
    if [ -n "$installCaveat" ]; then
      printf "${name}:\n%s\n" "${installCaveat}">> "${ZOPEN_ROOTFS}/var/cache/install_caveats.tmp"
    fi

    processActionScripts "installPost" "${name}"
  fi
  printInfo "${NC}${GREEN}Successfully installed ${name}${NC}"
}


getActivePackageDirs()
{
  (unset CD_PATH; cd "${ZOPEN_PKGINSTALL}" && zosfind  ./*/. ! -name . -prune -type l)
}


# processActionScripts
# runs any scriptlets that are applicable to the current phase of an administration
# command (install/update/remove/alternative)
# inputs: $1 the phase of the transaction that is currently executing
#         $2 the name of the package being administered
# return: 0  for success (nb. Warnings may haeve been printed to screen)
#         8  on error
processActionScripts()
{
  printVerbose "Processing phase '${1}' scriptlets"
  [ $# -lt 1 ] && printError "Internal error; missing action phase"
  phase=$1
  shift # Drop the initial parameter

  case "${phase}" in
    "installPre") scriptletDir="${ZOPEN_SCRIPTLET_DIR}/installPre";;
    "installPost") scriptletDir="${ZOPEN_SCRIPTLET_DIR}/installPost";;
    "removePre") scriptletDir="${ZOPEN_SCRIPTLET_DIR}/removePre";;
    "removePost") scriptletDir="${ZOPEN_SCRIPTLET_DIR}/removePost";;
    "transactionPre") scriptletDir="${ZOPEN_SCRIPTLET_DIR}/transactionPre";;
    "transactionPost") scriptletDir="${ZOPEN_SCRIPTLET_DIR}/transactionPost";;
    "parseGraphPre") scriptletDir="${ZOPEN_SCRIPTLET_DIR}/parseGraphPre";;
    "parseGraphPost") scriptletDir="${ZOPEN_SCRIPTLET_DIR}/parseGraphPost";;
    *) assertFailed "Invalid process action phase '${phase}'"
  esac
    printVerbose "Running script[s] from '${scriptletDir}'"

    if [ ! -d "${scriptletDir}" ]; then
      printDebug "No script directory for phase: ${phase}"
      return 0
    fi
    unset CDPATH;
  cd "${scriptletDir}" || return 1

  scriptletRcFile=$(mktempfile "zopen_actionscripts" ".err")
  find . -type l | while IFS= read -r scriptletFile; do
    if [ ! -r "${scriptletFile}" ]; then
      printWarning "Script '${scriptletDir}/${scriptletFile}' is not readable. Check permissions" >> "${scriptletRcFile}" 2>&1
      continue
    fi
    printVerbose "Attempting to run script '${scriptletFile}'"
    # Run script in a subshell to prevent environment modification
    /bin/printf "${CRSRSOL}${ERASELINE}Running ${scriptletFile}"
    scriptletOutput=$({
      # shellcheck disable=SC1090
      # shellcheck disable=SC2240
      . "$scriptletFile" "$@"
      echo $?  # Append exit status to output
      } 2>&1 
    )
    /bin/printf "${CRSRSOL}${ERASELINE}${CRSRSOL}"
    scriptletRc=$(echo "${scriptletOutput}" | tail -n 1)  # Extract exit status
    scriptletBody=$(echo "${scriptletOutput}" | sed '$d')  # Extract script output
    if [ "${scriptletRc}" -ne 0 ]; then {
      printWarning "Scriptlet '${scriptletFile}' failed with exit code ${scriptletRc}"
      printWarning "Details:"
      printWarning "${scriptletBody}"
      } >> "${scriptletRcFile}"
    fi
  done

  if [ -s "${scriptletRcFile}" ]; then  # Check if errorLog is non-empty
    printWarning "One or more scripts failed:"
    cat "${scriptletRcFile}"
    rm -f "${scriptletRcFile}"
    return 1
  fi
  rm -f "${scriptletRcFile}"
  return 0
}

# updatePackageDB
# Updates/generates the installed package database
# return: 0 for success
#         8 in error
updatePackageDB()
{
  printVerbose "Updating the installed package tracker db"

  pdb="${ZOPEN_ROOTFS}/var/lib/zopen/packageDB.json"
  if [ -e "${pdb}" ]; then
    backup=$(mktempfile "updatepdb" "bkk")
    addCleanupTrapCmd "rm -rf ${backup}"
    cp "${pdb}" "${backup}"
    rm "${pdb}"
  fi
  if ! pkgdirs=$(getActivePackageDirs); then
    printError "Unable to update the package db"
  fi
  for pkgdir in ${pkgdirs}; do
    metadataFile="${ZOPEN_PKGINSTALL}/${pkgdir}/metadata.json"
    if [ ! -e "${metadataFile}" ]; then
      # TODO: Fallback to filesystem analysis [depending on backward compatability]
      printWarning "No metadata.json found in '${ZOPEN_PKGINSTALL}/${pkgdir}'. Old package install?"
      continue
    fi
    escapedJSONFile=$(mktempfile "escaped" "json")
    addCleanupTrapCmd "rm -rf ${escapedJSONFile}"
    stripControlCharacters "${metadataFile}" "${escapedJSONFile}"
    if [ ! -e "${pdb}" ]; then
      echo "[]" > "${pdb}"
    fi
    # Ideally, use $reponame in the match but jq seems to have issues with that!
    mdj=$(jq --arg reponame "${ZOPEN_ORGNAME}" '. as $metadata | .product.repo | match(".*/zopencommunity/(.*)port").captures[0].string | [{(.):$metadata}]' \
        "${escapedJSONFile}")
    if [ -z "${mdj}" ]; then
      # Try legacy repository
      mdj=$(jq --arg reponame "${ZOPEN_ORGNAME}" '. as $metadata | .product.repo | match(".*/ZOSOpenTools/(.*)port").captures[0].string | [{(.):$metadata}]' \
        "${escapedJSONFile}")
    fi

    if [ -z "${mdj}" ]; then
      pkg=$(basename "${pkgdir}")
      printWarning "Cannot locate metadata for installed package '${pkg}' at location '${metadataFile}'. Check file existence and permissions"
    fi
    if ! jq --argjson mdj "${mdj}" '. += $mdj' \
            "${pdb}" > \
            "${pdb}.working"; then
      [ -e "${pdb}.working" ] && "${pdb}.working"
      [ -e "${pdb}" ] && mv -f "${pdb}" "${pdb}.broken" # Save for potential diagnostics
      printSoftError "Could not add metadata for '$(basename "${pkgdir}")' to install tracker."
      printError "Run 'zopen init --refresh' to attempt database regeneration and re-run command."
    fi
    mv "${pdb}.working" "${pdb}"
  done
  if [ ! -e "${pdb}" ]; then
    printVerbose "No currently installed packages [new install?]. Creating empty array[]"
    printf "[\n]\n" > "${pdb}"
  fi
}

stripControlCharacters(){
  [ ! -f "$1" ] && assertFailed "No input file specified for parsing!"
  [ -e "$2" ] && assertFailed "Output file exists so cannot be used for output!"
  tr -d '[:cntrl:]' > "$2" < "$1"

}
# JSONcontrolChar2Unicode
# ensures escaping of characters in JSON. For example, if a caveat has an
# unescaped '\n'/0x0A jq will fail to process it. Escape control characters
# 0x00->0x1F and reverse solidus. Note this should also only process unescaped 
# sequences by checking whether the character prior to the sequence is not a 
# reverse-solidus (so start-of-line [^] or any character [^\] ). If there was
# a preceding character, then capture/use that in the regex (\1) so it does not
# get discarded
# 
# inputs: $1 the input JSON file
#         $2 the output file, with sanitised JSON
# return: 0  for success (nb. Warnings may haeve been printed to screen)
#         8  on error
JSONcontrolChar2Unicode() {
  [ ! -f "$1" ] && assertFailed "No input file specified for parsing!"
  [ -e "$2" ] && assertFailed "Output file exists so cannot be used for output!"
  zossed -E ' # Note this is a long string!
      s/\\/\\\\/g; # Escape reverse-solidus; the following are the control chars 
      s/(^|[^\\])\x00/\1\\u0000/g; s/(^|[^\\])\x01/\1\\u0001/g;
      s/(^|[^\\])\x02/\1\\u0002/g; s/(^|[^\\])\x03/\1\\u0003/g;
      s/(^|[^\\])\x04/\1\\u0004/g; s/(^|[^\\])\x05/\1\\u0005/g;  
      s/(^|[^\\])\x06/\1\\u0006/g; s/(^|[^\\])\x07/\1\\u0007/g;
      s/(^|[^\\])\x08/\1\\u0008/g; s/(^|[^\\])\x09/\1\\u0009/g;
      s/(^|[^\\])\x0A/\1\\u000A/g; s/(^|[^\\])\x0B/\1\\u000B/g;  
      s/(^|[^\\])\x0C/\1\\u000C/g; s/(^|[^\\])\x0D/\1\\u000D/g;
      s/(^|[^\\])\x0E/\1\\u000E/g; s/(^|[^\\])\x0F/\1\\u000F/g;
      s/(^|[^\\])\x10/\1\\u0010/g; s/(^|[^\\])\x11/\1\\u0011/g;  
      s/(^|[^\\])\x12/\1\\u0012/g; s/(^|[^\\])\x13/\1\\u0013/g;
      s/(^|[^\\])\x14/\1\\u0014/g; s/(^|[^\\])\x15/\1\\u0015/g;
      s/(^|[^\\])\x16/\1\\u0016/g; s/(^|[^\\])\x17/\1\\u0017/g;  
      s/(^|[^\\])\x18/\1\\u0018/g; s/(^|[^\\])\x19/\1\\u0019/g;
      s/(^|[^\\])\x1A/\1\\u001A/g; s/(^|[^\\])\x1B/\1\\u001B/g;
      s/(^|[^\\])\x1C/\1\\u001C/g; s/(^|[^\\])\x1D/\1\\u001D/g;  
      s/(^|[^\\])\x1E/\1\\u001E/g; s/(^|[^\\])\x1F/\1\\u001F/g;
    '  "$1" > "$2"
}

# addToInstallTracker
# Records the installation into the database that tracks which packages have
# been installed
# inputs: $1 the name of the package
# return: 0  for success (nb. Warnings may haeve been printed to screen)
#         8  on error
addToInstallTracker()
{
  pkg=$1
  pdb="${ZOPEN_ROOTFS}/var/lib/zopen/packageDB.json"
  if [ ! -e "${pdb}" ]; then
    # Generate the packageDB
    printWarning "No package tracker found, regenerating [subsequent runs will be faster]"
    updatePackageDB
  fi
  metadataJson=$(cat "${ZOPEN_PKGINSTALL}/${pkg}/${pkg}/metadata.json")
  if ! jq --argjson mdj "[{\"${pkg}\":${metadataJson}}]" \
      "if any(.[]; has(\"${pkg}\")) then . |= map( if has(\"${pkg}\") then \$mdj[] else  . end ) else . + \$mdj end" \
        "${pdb}" > \
        "${pdb}.working"; then
    printError "Could not update metadata for '${pkg}' in package tracker. Run zopen -init -re-init to attempt regeneration."
  fi
  mv "${pdb}.working" "${pdb}"
}

# removeFromInstallTracker
# Removes the installation of the package from the database, making it
# uninstalled
# inputs: $1 the name of the package
# return: 0  for success (nb. Warnings may haeve been printed to screen)
#         8  on error
removeFromInstallTracker()
{
  pkg=$1
  pdb="${ZOPEN_ROOTFS}/var/lib/zopen/packageDB.json"
  if [ ! -e "${pdb}" ]; then
    # Generate the packageDB
    printWarning "No package tracker found, regenerating [subsequent runs will be faster]"
    updatePackageDB
  fi
  if ! jq \
      "map(select(has(\"${pkg}\") | not))" \
        "${pdb}" > \
        "${pdb}.working"; then
    printError "Could not add metadata for '${pkg}' to install tracker. Run zopen --re-init to attempt regeneration."
  fi
  mv "${pdb}.working" "${pdb}"
}

jqfunctions()
{
  # Return a set of helper functions for jq that can be prepended to
  # any jq query
  # pl(s;c;n) - padLeft with character 'c' to length 'n'
  # pr(s;c;n) - padRight with chacater 'c' to length 'n'
  # c(s;l) - center the string 's' in a string of length 'l'
  # r(dp) - round decimal to 'dp' decimal places (needs '*' & '/' 10^dp hack) 
  # shellcheck disable=SC2016
  printf "%s;%s;%s;%s;" \
  'def pl(s;c;n):c*(n-(s|length))+s' \
  'def pr(s;c;n):s+c*(n-(s|length))' \
  'def c(s;c;l):(((l - (s|length))/2 | floor ) // 0) as $lp|((l - (s|length) - $lp) // 0 )as $rp|pl("";c; $lp) + s + pr("";c; $rp)' \
  'def r(dp):.*pow(10;dp)|round/pow(10;dp)'
}

. ${INCDIR}/analytics.sh

zopenInitialize
