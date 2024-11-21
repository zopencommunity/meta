#!/usr/bin/env bash

toronto_instances=(
  "zopen-v2r5-new-2 163.74.95.143"
  "zopen-v2r5-new-1 163.74.91.140"
  "zopen-v2r5-c1 163.74.83.192"
  "zopen-v2r4-ci8 163.74.88.109"
  "zopen-v2r4-ci7 163.74.91.139"
  "zopen-v2r4-ci6 163.74.95.209"
  "zopen-v2r5-c5 163.74.81.206"
  "zopen-v2r5-c4 163.74.89.15"
)


jp_instances=(
  "zopen-dev2 128.168.129.26"
  "zopen-ci5 128.168.131.34"
  "zopen-ci4 128.168.132.142"
  "zopen-ci3 128.168.140.116"
  "zopen-dev1 128.168.136.112"
)

action="restart-if-down"

monitor_instances() {
  local instances=("$@")
  local region="$1"
  shift 

  for instance in "${instances[@]}"; do
    # Skip empty or malformed entries
    [[ -z "$instance" || "$instance" =~ ^[[:space:]]*$ ]] && continue

    # Split the instance details into name and IP
    IFS=' ' read -r name ip <<< "$instance"
    
    # Skip if name or IP is missing
    [[ -z "$name" || -z "$ip" ]] && continue
    
    echo "Monitoring instance: $name with IP: $ip in region: $region"
    
    set -x
    ./monitor_vpc.sh -i "$name" -p "$ip" -a "$action" -r "$region"
    set +x
    
  done
}

monitor_instances "ca-tor" "${toronto_instances[@]}"

monitor_instances "jp-tok" "${jp_instances[@]}"
