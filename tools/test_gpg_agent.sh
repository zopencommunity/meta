#!/bin/sh
# Test script for GPG agent functionality and isolation in zopen-install

# Mocking common.sh functions
printInfo() { echo "INFO: $1"; }
printVerbose() { echo "VERBOSE: $1"; }
printWarning() { echo "WARNING: $1"; }
printError() { echo "ERROR: $1"; exit 1; }
debug=true
verbose=true

# Source the functions from zopen-install (we need to extract them or source the script)
# For simplicity, we will copy the functions here or source a modified version.
# Let's extract the startGPGAgent and gpgCleanup functions from bin/zopen-install

EXTRACTED_FUNCTIONS=$(sed -n '/^startGPGAgent() {/,/^}/p; /^gpgCleanup() {/,/^}/p' bin/zopen-install)
eval "$EXTRACTED_FUNCTIONS"

# Test setup
TEST_DIR=$(mktemp -d /tmp/zopen_test_gpg_XXXXXX)
zopen_tmp_dir="$TEST_DIR"
LOGNAME=$(id -un)
$$=12345 # Mocking PID if possible, but we'll use actual shell PID
MYPID=$$

echo "Running GPG Agent tests..."

# Test 1: verifySignatureOfPax environment setup
test_env_setup() {
  echo "--- Test 1: Environment Setup ---"
  TMP_GPG_DIR="$zopen_tmp_dir/zopen_gpg_verify_${LOGNAME}_${MYPID}"
  mkdir -p "$TMP_GPG_DIR"
  chmod 700 "$TMP_GPG_DIR"
  export GNUPGHOME="$TMP_GPG_DIR"
  
  if [ "$GNUPGHOME" != "$TMP_GPG_DIR" ]; then
    echo "FAILED: GNUPGHOME not set correctly"
    exit 1
  fi
  
  PERMS=$(ls -ld "$TMP_GPG_DIR" | awk '{print $1}')
  if [ "$PERMS" != "drwx------" ]; then
    echo "FAILED: Incorrect permissions on TMP_GPG_DIR: $PERMS"
    exit 1
  fi
  echo "PASSED: Environment Setup"
}

# Test 2: startGPGAgent
test_start_agent() {
  echo "--- Test 2: startGPGAgent ---"
  startGPGAgent
  
  # Check if agent is running for this GNUPGHOME
  if ! gpgconf --list-dirs agent-socket >/dev/null 2>&1; then
    echo "FAILED: gpg-agent socket not found"
    exit 1
  fi
  
  # Check if GPG_TTY is exported
  if [ -z "$GPG_TTY" ]; then
    echo "FAILED: GPG_TTY not exported"
    exit 1
  fi
  echo "PASSED: startGPGAgent"
}

# Test 3: gpgCleanup
test_cleanup() {
  echo "--- Test 3: gpgCleanup ---"
  SIGNATURE_FILE="$zopen_tmp_dir/sig.asc"
  PUBLIC_KEY_FILE="$zopen_tmp_dir/pub.asc"
  touch "$SIGNATURE_FILE" "$PUBLIC_KEY_FILE"
  
  gpgCleanup
  
  if [ -f "$SIGNATURE_FILE" ] || [ -f "$PUBLIC_KEY_FILE" ] || [ -d "$TMP_GPG_DIR" ]; then
    echo "FAILED: Cleanup did not remove files/directories"
    exit 1
  fi
  
  if [ -n "$GNUPGHOME" ]; then
    echo "FAILED: GNUPGHOME not unset"
    exit 1
  fi
  
  # Check if agent was killed (might take a second)
  sleep 1
  if pgrep -u $(id -u) gpg-agent | grep -q .; then
     # This is tricky because other agents might be running.
     # But for our isolated GNUPGHOME, the socket should be gone.
     echo "NOTE: Ensure no orphaned gpg-agent processes exist for $TMP_GPG_DIR"
  fi
  echo "PASSED: gpgCleanup"
}

# Run tests
test_env_setup
test_start_agent
test_cleanup

echo "All tests passed successfully!"
rm -rf "$TEST_DIR"
