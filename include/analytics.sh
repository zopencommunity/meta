#!/bin/false

isAnalyticsOn()
{
  jsonConfig="${ZOPEN_ROOTFS}/etc/zopen/config.json"
  isCollecting=$(jq -r '.is_collecting_stats' $jsonConfig)
  if [ "$isCollecting" = "true" ] || [ -z "${ZOPEN_ANALYTICS_JSON}" ]; then
    return 0
  else
    return 1
  fi
}

is_ibm_hostname()
{
  ip_address=$(/bin/dig +short "$(hostname)" | tail -1)

  if /bin/dig +short -x "${ip_address}" 2>/dev/null | grep -q "ibm.com"; then
    return 0
  else
    return 1
  fi
}

sendStatsToRemote()
{
  json="$1"
curl -X POST -H "Content-Type: application/json" -d "$json" http://163.74.88.212:3000/statistics
}

registerInstall()
{
  name=$1
  version=$2
  isUpgrade=$3
  isBuildInstall=$4
  isRuntimeDependencyInstall=$5

  if ! isAnalyticsOn || [ -z "${ZOPEN_ANALYTICS_JSON}" ]; then
    return;
  fi

  timestamp=$(date +%s)
  uuid=$(jq -r '.profile' ${ZOPEN_ANALYTICS_JSON})
    
  # Local storage
  cat "${ZOPEN_ANALYTICS_JSON}" | jq '.installs += [{"name": "'$name'", "version": "'$version'", "timestamp": "'${timestamp}'", "isUpgrade": '$isUpgrade' }]' > "${ZOPEN_ANALYTICS_JSON}.tmp"
  mv "${ZOPEN_ANALYTICS_JSON}.tmp" "${ZOPEN_ANALYTICS_JSON}"

  json=$(cat << EOF
{
  "type": "installs",
  "data": {
    "uuid": "$uuid",
    "packagename": "$name",
    "version": "$version",
    "isUpgrade": $isUpgrade,
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

  # Local storage
  cat "${ZOPEN_ANALYTICS_JSON}" | jq '.removes += [{"name": "'$name'", "version": "'$version'", "timestamp": "'$(date +%s)'"}]' > "${ZOPEN_ANALYTICS_JSON}.tmp"
  mv "${ZOPEN_ANALYTICS_JSON}.tmp" "${ZOPEN_ANALYTICS_JSON}"

  uuid=$(jq -r '.profile' ${ZOPEN_ANALYTICS_JSON})
  json=$(cat << EOF
{
  "type": "removals",
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
  "type": "profile",
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

#TODO
registerError()
{
  msg=$1
  line=$2

  if ! isAnalyticsOn; then
    return;
  fi
}
