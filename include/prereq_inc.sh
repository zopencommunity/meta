#!/bin/sh

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
    echo "ERROR: This system is not a z/OS system."
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
    echo "ERROR: Expected z/OS version $1 or earlier, but found z/OS version $CURRENT_VERSION"
    exit 1
  fi
}

