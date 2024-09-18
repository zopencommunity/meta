#!/bin/sh
# IVT Shell Script for Zopen Community
# Checks for min OS, ARCH, and the presence of Python, ZOAU, Java and Network Connectivity to github.com

version_compare() {
    [ "$(/bin/printf '%s\n' "$1" "$2" | sort -V | head -n 1)" != "$1" ]
}

check_command() {
    command_name=$1
    print -n "Checking $command_name..."
    if ! command -v "$command_name" >/dev/null 2>&1; then
        echo "ERROR: $command_name not found in PATH."
        exit 1
    fi
    echo "Success: $command_name found in PATH."
}

check_version_at_least() {
    check_command "$1"
    required_version="$2"
    current_version=$("$1" --version 2>&1 | /bin/awk '/Python [0-9]+\.[0-9]+\.[0-9]+/{print $NF}')

    if version_compare "$required_version" "$current_version"; then
        echo "ERROR: $1 version $required_version or greater is required. Version is $required_version"
        exit 1
    fi
    echo "Success: $1 version meets requirements."
}

check_java() {
  check_command "java"

  release=$(java -version 2>&1 | head -1  | sed -e 's#.*\"\([^"]*\)".*#\1#g' | awk -F\. ' { print $1.$2 } ')
  if [ $release -le 18 ] ; then
    echo "ERROR: Java version is not supported. Please install Java 11 or later - https://www.ibm.com/support/pages/java-sdk-products-zos" >&2
    exit 1
  fi
}

check_zoaversion() {
    check_command "zoaversion"
    print -n "Checking zoaversion version..."
    zoaversion_info=$(zoaversion 2>&1)
    major_minor_version=$(echo "$zoaversion_info" | awk -F '[ V.]' '/V[0-9]+\.[0-9]+\.[0-9]+/{print $5"."$6}')
    
    if version_compare "1.2" "$major_minor_version" && version_compare "1.3" "$major_minor_version"; then
        echo "ERROR: zoaversion version V1.2 or V1.3 is required."
        exit 1
    fi

    echo "Success: zoaversion version meets requirements."
}

check_python() {
    check_version_at_least "python3" "3.11.0" # At least 3.11.0 should be installed
    print -n "Checking Python interpreter..."
    python_result=$(python3 -c 'print("Hello, World!")' 2>&1)

    if ! echo "$python_result" | grep -q "Hello, World!"; then
        echo "ERROR: $python_result"
        exit 1
    fi

    echo "Success: Python interpreter test passed. 'Hello, World!' printed."
}

check_network_connectivity() {
    check_command "ping"
    print -n "Checking network connectivity to github.com..."
    ping_result=$(/bin/ping -c 1 github.com 2>&1)

    if ! echo "$ping_result" | grep -q "Ping #1 response"; then
        echo "ERROR: $ping_result"
        exit 1
    fi

    echo "Success: Network connectivity to github.com verified."
}

check_system() {
  PROCESSOR=$(/bin/uname -m)
  RELEASE=$(/bin/uname -r | /bin/sed "s/\.[0-9]*//")
  PLATFORM=$(/bin/uname -s)

  # Checking if the platform is z/OS
  print -n "Checking for supported platform..."
  if [ ! ${PLATFORM} = "OS/390" ]; then
    echo "ERROR: This system is not a z/OS system"
    exit 1
  fi
  echo "Success"

  print -n "Checking for supported hardware..."
  # Checking if the processor is either at least zEC12 (2817)
  if [ ${PROCESSOR} -lt 2817 -a ${PROCESSOR} -ne 1090 ]; then
    echo "ERROR: A processor level (${PROCESSOR}) lower than IBM zEnterprise EC12 has been detected. The minimum requirement to compile and execute Zopen Community is IBM zEnterprise EC12."
    exit 1
  fi
  echo "Success"

  # Checking if the OS is up to date
  print -n "Checking for supported OS version..."
  if [ ${RELEASE} -lt 27 ]; then
      echo "ERROR: An OS level (${RELEASE}) lower than z/OS V2R4 (27) has been detected."
      exit 1
  fi
  echo "Success"
}

check_system

check_python

check_zoaversion

check_java

check_network_connectivity
