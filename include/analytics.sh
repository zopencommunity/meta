#!/bin/false

# This is the server that is collecting zopen usage stats
ZOPEN_STATS_URL="http://163.74.88.212:3000"

isAnalyticsOn()
{
  # Currently in beta more
  if [ -z "$ZOPEN_BETA_FEATURES" ]; then
    return 2
  fi
  jsonConfig="${ZOPEN_ROOTFS}/etc/zopen/config.json"
  if [ ! -f ${jsonConfig} ]; then
    return 2
  fi
  isCollecting=$(jq -re '.is_collecting_stats' $jsonConfig)
  if [ $? -gt 0 ]; then
    return 2
  fi
  if [ "$isCollecting" = "true" ] || [ -z "${ZOPEN_ANALYTICS_JSON}" ]; then
    return 0
  else
    return 1
  fi
}

isIBMHostname()
{
  ip_address=$(/bin/dig +short "$(hostname)" 2>/dev/null | tail -1)

  if /bin/dig +short -x "${ip_address}" 2>/dev/null | grep -q "ibm.com"; then
    return 0
  else
    return 1
  fi
}

sendStatsToRemote()
{
  json="$1"
  if ! command -v curl >/dev/null 2>&1; then
    printError "curl not found. This should not occur. Please report a bug"
  fi
  response=$(curl -s -X POST -H "Content-Type: application/json" -d "$json" "${ZOPEN_STATS_URL}/statistics")
  if [ $? -eq 0 ]; then
    success=$(echo "$response" | jq -r '.success')
    if [ "$success" = "true" ]; then
      printVerbose "Successfully transmitted statistics: $json"
      syslog "${ZOPEN_LOG_PATH}/analytics.log" "${LOG_I}" "${CAT_STATS}" "ANALYTICS" "sendStatsToRemote" "Successfully sent $json to $ZOPEN_STATS_URL"
    else
      printVerbose "Statistics were not successfully transmitted: $json"
      syslog "${ZOPEN_LOG_PATH}/analytics.log" "${LOG_E}" "${CAT_STATS}" "ANALYTICS" "sendStatsToRemote" "Failed to send $json to $ZOPEN_STATS_URL"
    fi
  else
      printVerbose "Statistics were not successfully transmitted: $json"
      syslog "${ZOPEN_LOG_PATH}/analytics.log" "${LOG_E}" "${CAT_STATS}" "ANALYTICS" "sendStatsToRemote" "Failed to send $json to $ZOPEN_STATS_URL"
  fi
}

getProfileUUIDFromJSON()
{
  uuid=$(jq -re '.profile' ${ZOPEN_ANALYTICS_JSON})
  if [ $? -gt 0 ]; then
    printError "Analytics.json file is corrupted. Please re-initialize your file system using zopen init --refresh-analytics"
  fi
  echo "$uuid"
}

registerInstall()
{
  name=$1
  version=$2
  isUpgrade=$3
  isRuntimeDependencyInstall=$4
  timestamp=$5

  if ! isAnalyticsOn; then
    return;
  fi

  if [ ! -z "$ZOPEN_IN_ZOPEN_BUILD" ]; then
    isBuildInstall=true
  else
    isBuildInstall=false
  fi

  if [ -z "$isRuntimeDependencyInstall" ]; then
    isRuntimeDependencyInstall=false
  fi

  if [ -z "$timestamp" ]; then
    timestamp=$(date +%s)
  fi
  uuid=$(getProfileUUIDFromJSON)
    
  # Local storage
  cat "${ZOPEN_ANALYTICS_JSON}" | jq '.installs += [{"name": "'$name'", "version": "'$version'", "timestamp": "'${timestamp}'", "isUpgrade": '$isUpgrade' }]' > "${ZOPEN_ANALYTICS_JSON}.tmp"
  mv "${ZOPEN_ANALYTICS_JSON}.tmp" "${ZOPEN_ANALYTICS_JSON}"

  json=$(cat << EOF
{
  "type": "installs",
  "version": "0.1",
  "data": {
    "uuid": "$uuid",
    "packagename": "$name",
    "version": "$version",
    "isUpgrade": $isUpgrade,
    "isBuildInstall": $isBuildInstall,
    "isRuntimeDependencyInstall": $isRuntimeDependencyInstall,
    "timestamp": ${timestamp}
  }
}
EOF
)

  sendStatsToRemote "$json"
}

registerRemove()
{
  name=$1
  version=$2

  if ! isAnalyticsOn; then
    return;
  fi

  timestamp=$(date +%s)
  uuid=$(getProfileUUIDFromJSON)

  # Local analytics
  cat "${ZOPEN_ANALYTICS_JSON}" | jq '.removes += [{"name": "'$name'", "version": "'$version'", "timestamp": "'$timestamp'"}]' > "${ZOPEN_ANALYTICS_JSON}.tmp"
  mv "${ZOPEN_ANALYTICS_JSON}.tmp" "${ZOPEN_ANALYTICS_JSON}"

  json=$(cat << EOF
{
  "type": "removals",
  "version": "0.1",
  "data": {
    "uuid": "$uuid",
    "packagename": "$name",
    "version": "$version",
    "timestamp": ${timestamp}
  }
}
EOF
)

  sendStatsToRemote "$json"
}

registerFileSystem()
{
  uuid=$1
  isibm=$2
  isbot=$3

  if ! isAnalyticsOn; then
    return;
  fi

  json=$(cat << EOF
{
  "type": "profiles",
  "version": "0.1",
  "data": {
    "uuid": "$uuid",
    "isbot": "$isbot",
    "isibm": "$isibm"
  }
}
EOF
)

  sendStatsToRemote "$json"
}

# FUTURE: Collect errors
registerError()
{
  msg=$1
  line=$2

  if ! isAnalyticsOn; then
    return;
  fi
}

processAnalyticsFromLogFile()
{
  log_file="$ZOPEN_LOG_PATH/audit.log"
  if [ ! -f "${log_file}" ]; then
    return
  fi

  dateCmd="${INCDIR}/../utilities/date"
  if [ ! -e "$dateCmd" ]; then
    return
  fi
  encountered_packages=""

  printHeader "Processing analytics from existing installation's log files"
  grep 'handlePackageInstall.*Installed' "$log_file" | while IFS= read -r line || [ -n "$line" ]; do
    set -x
    # Extract timestamp
    timestamp=$(echo "$line" | awk '{print $1 " " $2}')
    timestamp=$($dateCmd -d "$timestamp" +"%s")

    # Extract package name
    package_name=$(echo "$line" | awk -F"'" '{print $2}')

    # Extract version
    version=$(echo "$line" | awk -F'version:' '{split($2, a, ";"); print a[1]}' | tr -d '[:space:]')

    # Check if the package has been encountered earlier in the log
    is_upgrade=0
    if echo "$encountered_packages" | grep -q ":$package_name:"; then
        is_upgrade=1
    fi

    encountered_packages="${encountered_packages}:$package_name:"

    printInfo "Processed $package_name - $version - $timestamp - isUpgrade: $is_upgrade"
    registerInstall "$package_name" "$version" ${is_upgrade} 0 "${timestamp}"
  done
}
