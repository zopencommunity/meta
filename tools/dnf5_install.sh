#!/usr/bin/env bash
#
# Quick Install tool for zopen's dnf5 package
# Downloads and extracts dnf5 into the current directory
# Requires: curl, jq

if [[ $(uname) != "OS/390" ]]; then
  echo "Error: This script is only for z/OS systems."
  exit 1
fi

# Check for required commands
if ! command -v curl &> /dev/null; then
  echo "Error: curl is required but not found in PATH."
  echo "Please install curl and try again."
  exit 1
fi

if ! command -v jq &> /dev/null; then
  echo "Error: jq is required but not found in PATH."
  echo "Please install jq and try again."
  exit 1
fi

ZOPEN_RELEASE_JSON="https://raw.githubusercontent.com/zopencommunity/meta/main/docs/api/zopen_releases.json"

# ----------------------------
# DOWNLOAD RELEASE JSON
# ----------------------------
echo "> Getting latest data from zopen community..."
json=$(curl --fail-with-body --silent -L "$ZOPEN_RELEASE_JSON")
if [ $? -gt 0 ]; then
  echo "Error: Curl failed to download release json $ZOPEN_RELEASE_JSON due to: \"$json\""
  exit 1
fi

# ----------------------------
# Filter only STABLE dnf5 releases
url=$(echo "$json" | jq -r '
  first(
    .release_data.dnf5[]? 
    | select(.tag_name | startswith("STABLE_")) 
    | .assets[0].url
  )
')

paxFile=$(basename "$url")


# ----------------------------
# DOWNLOAD FILE
# ----------------------------
echo "> Downloading dnf5 package..."
response=$(curl --fail-with-body -O -L "$url")
if [ $? -gt 0 ]; then
  echo "Error: Curl failed to download STABLE dnf5 due to: \"$response\"."
  exit 1
fi

if [ ! -f "$paxFile" ]; then
  echo "Error: $paxFile not present after download."
  exit 1
fi

# ----------------------------
# EXTRACT
# ----------------------------
echo "> Extracting $paxFile..."
paxOutput=$(pax -rvf "$paxFile" 2>&1)
if [ $? -gt 0 ]; then
   echo "Error: Failed to unpax file $paxFile."
   exit 1
fi

echo "> Cleaning up pax file $paxFile..."
rm -vf "$paxFile"
if [ $? -gt 0 ]; then
   echo "Warning: Failed to remove pax file $paxFile. Installation continues."
fi

dir=$(echo "$paxOutput" | head -1)
if [ ! -d "$dir" ]; then
  echo "Error: $dir is not a valid directory."
  exit 1
fi

set -e

# ----------------------------
# SETUP ENVIRONMENT
# ----------------------------
echo "> Moving to extracted directory..."
cd "$dir"

echo "> Setting up environment..."
# Source .env to get PATH and other variables
source ./.env

# ----------------------------
# BOOTSTRAP RPM CONFIGURATION
# ----------------------------
echo "> Creating RPM configuration..."
# Override any RPM paths from .env with our bootstrap configuration
# Unset any RPM-related and zopen variables that might conflict
unset RPMDIR RPM_INSTALL_PREFIX HOME RPM_ETCCONFIGDIR RPM_BUILD_ROOT 2>/dev/null || true
unset ZOPEN_ROOTFS ZOPEN_PKGINSTALL ZOPEN_PREFIX 2>/dev/null || true
export XDG_CONFIG_HOME=$(mktemp -d)
export RPM_CONFIGDIR="$XDG_CONFIG_HOME/rpm"
export HOME="$XDG_CONFIG_HOME"

# Set up cleanup
trap "rm -rf '$XDG_CONFIG_HOME'" EXIT

# Create directory structure
mkdir -p "$XDG_CONFIG_HOME/rpm"
mkdir -p /opt/pkg/var/lib/rpm
mkdir -p /opt/pkg/var/lib/dnf
mkdir -p /opt/pkg/var/cache/dnf
mkdir -p /opt/pkg/var/log

# Create minimal rpmrc
cat > "$XDG_CONFIG_HOME/rpm/rpmrc" <<'EOF'
archcolor: s390x 2
archcolor: noarch 0
arch_canon: s390x: s390x 15
os_canon: z/OS: zos 22
arch_compat: s390x: noarch
EOF

# Create minimal macros
cat > "$XDG_CONFIG_HOME/rpm/macros" <<'EOF'
%_dbpath /opt/pkg/var/lib/rpm
%_db_backend sqlite
%_keyring rpmdb
%_dbpath_rebuild %{_dbpath}
%_keyringpath %{_dbpath}/pubkeys/
%_keyring_lockpath %{_dbpath}/.keyring.lock
%_rpmlock_path %{_dbpath}/.rpm.lock
EOF

# ----------------------------
# CREATE DNF CONFIGURATION
# ----------------------------
echo "> Creating DNF configuration..."
mkdir -p /opt/pkg/etc/dnf

cat > /opt/pkg/etc/dnf/dnf.conf <<'EOF'
[main]
keepcache=True
debuglevel=0
installonly_limit=3
clean_requirements_on_remove=True
best=True
skip_if_unavailable=False
reposdir=/opt/pkg/etc/yum.repos.d
persistdir=/opt/pkg/var/lib/dnf
cachedir=/opt/pkg/var/cache/dnf
logdir=/opt/pkg/var/log
varsdir=/opt/pkg/etc/dnf/vars /opt/pkg/usr/share/dnf5/vars.d
pluginconfpath=/opt/pkg/etc/dnf/plugins
plugin_conf_dir=/opt/pkg/etc/dnf/libdnf5-plugins /opt/pkg/usr/share/dnf5/libdnf.plugins.conf.d
transaction_history_dir=/opt/pkg/var/lib/dnf/history
system_cachedir=/opt/pkg/var/cache/dnf
system_state_dir=/opt/pkg/var/lib/dnf
pluginpath=/opt/pkg/lib/libdnf5/plugins
EOF

# ----------------------------
# CREATE ZOPEN REPOSITORY CONFIGURATION
# ----------------------------
echo "> Creating repository configuration..."
mkdir -p /opt/pkg/etc/yum.repos.d

cat > /opt/pkg/etc/yum.repos.d/zopen.repo <<'EOF'
[zopen]
name=zopen
baseurl=http://163.74.83.190:8080/pulp/content/zopen/
gpgkey=http://163.74.83.190:8080/pulp/content/keys/zopen.pub
gpgcheck=1
repo_gpgcheck=0
enabled=1
EOF

chmod 644 /opt/pkg/etc/yum.repos.d/zopen.repo

# ----------------------------
# BOOTSTRAP DNF5 INTO RPM DATABASE
# ----------------------------
echo ""
echo "> Syncing repository metadata..."
if dnf5 --config=/opt/pkg/etc/dnf/dnf.conf makecache; then
  echo "[OK] Metadata synced"
else
  echo "[WARN] Could not sync metadata"
fi
echo ""

echo "> Installing dnf5 from repository..."
RPM_INSTALLED=0
if dnf5 --config=/opt/pkg/etc/dnf/dnf.conf install --assumeyes dnf5; then
  echo "[OK] dnf5 installed from repository and registered in RPM database"
  RPM_INSTALLED=1
else
  echo "[WARN] Could not install dnf5 from repository."
  echo "       Bootstrap dnf5 is still functional but not RPM-managed."
  echo "       You can register it later:"
  echo "       dnf5 install --assumeyes dnf5"
fi
echo ""

# ----------------------------
# CLEANUP
# ----------------------------
echo "> Cleaning up extracted directory..."
cd ..
rm -rf "$dir"

echo ""
echo "==========================================="
echo "Installation Complete"
echo "==========================================="
if [ $RPM_INSTALLED -eq 1 ]; then
  echo "[OK] dnf5 installed to /opt/pkg/bin (RPM-managed)"
else
  echo "[OK] dnf5 installed to /opt/pkg/bin (bootstrap only)"
  echo "[NOTE] Run 'dnf5 install dnf5' to register in RPM database"
fi
echo "[OK] Configuration created"
echo ""
echo "Add to your PATH:"
echo "  export PATH=\"/opt/pkg/bin:\$PATH\""
echo "  export LIBPATH=\"/opt/pkg/lib:\$LIBPATH\""
echo ""
echo "Next steps:"
echo "  dnf5 install <package>"
echo "  dnf5 list"
echo ""
echo "Documentation: https://zopen.community/Guides/RpmSetup"
echo "==========================================="

exit 0
