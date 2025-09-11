#!/bin/false
export ZOPEN_AVAILABLE_PREREQS="procfs zos31 zos25 zos24"

# This file is only meant to be source'd hence the dummy hashbang

check_zos_version() {
  PLATFORM=$(/bin/uname -s)

  # Checking if the platform is z/OS
  if [ ! ${PLATFORM} = "OS/390" ]; then
    echo "ERROR: This system is not a z/OS system."
    exit 1
  fi

  # Check version
  VERSION=$(/bin/uname -rsvI 2>/dev/null)

  if [ -z "$VERSION" ]; then
    echo "ERROR: This z/OS system does not have a valid version."
    exit 1
  fi

  MAJOR=$(echo "$VERSION" | /bin/awk '{print $3}' | /bin/sed 's/^0*//')
  MINOR=$(echo "$VERSION" | /bin/awk '{print $2}' | /bin/cut -d'.' -f1 | /bin/sed 's/^0*//')
  if [ -z "$MINOR" ]; then
    MINOR=0
  fi

  CURRENT_VERSION="$MAJOR.$MINOR"

  EXPECTED_MAJOR=$(echo "$1" | cut -d'.' -f1)
  EXPECTED_MINOR=$(echo "$1" | cut -d'.' -f2)

  VERSION_NUMBER=$((MAJOR * 100 + MINOR))
  EXPECTED_VERSION_NUMBER=$((EXPECTED_MAJOR * 100 + EXPECTED_MINOR))

  if [ "$VERSION_NUMBER" -lt "$EXPECTED_VERSION_NUMBER" ]; then
    echo "ERROR: Expected z/OS version $1 or later, but found z/OS version $CURRENT_VERSION"
    exit 1
  fi
}

procfs() {
  /bin/df /proc 2>/dev/null | /bin/grep -q "/proc.*PROC.*Available" 2>/dev/null
  if [ $? -gt 0 ]; then
    echo "ERROR: The /proc filesystem is not set up on your system"
    exit 1
  fi
}

zos31() {
  check_zos_version 3.1
}

zos25() {
  check_zos_version 2.5
  if [ ! -f /usr/include/sys/epoll.h ] || [ ! -f /usr/include/sys/eventfd.h ]; then
    echo "WARNING: Missing LE PTFs UJ94587 UJ94590. You may not have the required Language Environment APAR installed."
    echo "See: https://www.ibm.com/support/pages/apar/OA61972"
    echo "To resolve this, install the appropriate PTF for OA61972 on z/OS 2.5."
  fi
}

zos24() {
  check_zos_version 2.4
}
