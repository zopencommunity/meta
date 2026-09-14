# Setting up RPM and DNF5 on z/OS

This guide explains how to configure your z/OS Unix System Services (USS) client to consume, verify, and install RPM packages delivered by the zopen community.

## System Requirements

> [!IMPORTANT]
> **Authorization:**
> - Superuser authority (UID 0) required
> - Modifies system directories and RPM database
> 
> **Storage:**
> - Minimum 1 GB free space on `/opt/pkg` filesystem
> - Filesystem must support standard Unix permissions
> 
> **Software:**
> - `dnf5` version 5.4.4.0 or higher (rpm libraries statically linked)
> - `curl` for downloading packages
> 
> **Network:**
> - Access to `http://repo.zopen.community` (or direct IP `163.74.83.190:8080`)
> - Outbound HTTP connections required
> 
> **Permissions:**
> - 755 for directories
> - 644 for configuration files

---

## Installation Path

Choose **ONE** of the following installation methods:

---

### Path A: Automated Setup (Recommended)

Use the quick install script that automatically configures everything:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/zopencommunity/meta/HEAD/tools/dnf5_install.sh)"
```

**What this script does:**
- Downloads latest stable dnf5
- Creates `/opt/pkg` directory structure
- Configures RPM and DNF5
- Syncs repository metadata
- Installs dnf5 from repository

**Next step:** [Skip to Installing and Managing Packages](#installing-and-managing-packages)

---

### Path B: Manual Setup

If you prefer manual configuration or already have zopen installed, follow these steps:

#### Install dnf5 binaries:

**Option 1:** Using zopen package manager:
```bash
zopen upgrade dnf5 -y
```

**Option 2:** Download manually from [zopen releases](https://github.com/zopencommunity/dnf5port/releases)

#### Verify Installation:
```bash
dnf5 --version  # Should be 5.4.4.0 or higher
```

#### Step 1: Configure RPM and DNF5

> [!IMPORTANT]
> **Installation prefix:** `/opt/pkg`
> 
> **Directory structure:**
> - `/opt/pkg/bin` - Binaries
> - `/opt/pkg/lib` - Libraries  
> - `/opt/pkg/etc` - Configuration
> - `/opt/pkg/var` - Data, logs, RPM database
> - `/opt/pkg/share` - Shared files

##### Create Required Directories

First, create the directory structure for RPM database, DNF cache, and configuration files:

```bash
mkdir -p /opt/pkg/var/lib/rpm
mkdir -p /opt/pkg/var/lib/dnf
mkdir -p /opt/pkg/var/cache/dnf
mkdir -p /opt/pkg/var/log
mkdir -p /opt/pkg/etc/dnf
mkdir -p /opt/pkg/etc/yum.repos.d
```

##### Configure RPM

Create the RPM configuration directory. RPM looks for configuration in `XDG_CONFIG_HOME/rpm` or `~/.config/rpm`:

```bash
mkdir -p ~/.config/rpm
```

Create the RPM macros file `~/.config/rpm/macros`:

```bash
cat > ~/.config/rpm/macros <<'EOF'
%_dbpath /opt/pkg/var/lib/rpm
%_db_backend sqlite
%_keyring rpmdb
%_dbpath_rebuild %{_dbpath}
%_keyringpath %{_dbpath}/pubkeys/
%_keyring_lockpath %{_dbpath}/.keyring.lock
%_rpmlock_path %{_dbpath}/.rpm.lock
EOF
```

Create the RPM platform configuration file `~/.config/rpm/rpmrc`:

```bash
cat > ~/.config/rpm/rpmrc <<'EOF'
archcolor: s390x 2
archcolor: noarch 0
arch_canon: s390x: s390x 15
os_canon: z/OS: zos 22
arch_compat: s390x: noarch
EOF
```

##### Configure DNF5

Create the DNF5 main configuration file `/opt/pkg/etc/dnf/dnf.conf`:

```bash
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
```

##### Configure the zopen Repository

Create the repository configuration file `/opt/pkg/etc/yum.repos.d/zopen.repo`:

```bash
cat > /opt/pkg/etc/yum.repos.d/zopen.repo <<'EOF'
[zopen]
name=zopen
baseurl=http://repo.zopen.community/pulp/content/zopen/
gpgkey=http://repo.zopen.community/pulp/content/keys/zopen.pub
gpgcheck=1
repo_gpgcheck=0
enabled=1
EOF
```

**Alternative (Direct IP):** Use `http://163.74.83.190:8080/pulp/content/zopen/` if DNS unavailable.

Set permissions:
```bash
chmod 644 /opt/pkg/etc/yum.repos.d/zopen.repo
```

#### Step 2: Initialize Repository

Initialize the local package database cache and register dnf5 in the RPM database.

##### Storage Requirements

**Filesystem:** `/opt/pkg` must have minimum 1 GB free space

**Directories created:**
- `/opt/pkg/var/lib/rpm` - RPM database
- `/opt/pkg/var/cache/dnf` - Package metadata cache
- `/opt/pkg/var/lib/dnf` - DNF state/history

##### Initialize Repository

Initialize the repository and complete the setup:

```bash
# Clear any old cached files
dnf5 --config=/opt/pkg/etc/dnf/dnf.conf clean all

# Fetch the latest metadata cache
dnf5 --config=/opt/pkg/etc/dnf/dnf.conf --repo=zopen makecache

# Install dnf5 from the repository
dnf5 --config=/opt/pkg/etc/dnf/dnf.conf install --assumeyes dnf5
```

**✅ Setup complete**

Optional cleanup:
```bash
rm -rf ~/.config/rpm  # Bootstrap config no longer needed
```

---

## Installing and Managing Packages

All packages from the zopen RPM repository install under the **`/opt/pkg`** directory structure:

*   **Binaries:** `/opt/pkg/bin`
*   **Libraries:** `/opt/pkg/lib`
*   **Shared Resources:** `/opt/pkg/share`

### Environment Setup

Ensure `/opt/pkg/bin` is in your PATH:
> ```bash
> export PATH="/opt/pkg/bin:$PATH"
> export LIBPATH="/opt/pkg/lib:$LIBPATH"
> ```

> [!TIP]
> Make these permanent by adding to `~/.bashrc`:
> ```bash
> echo 'export PATH="/opt/pkg/bin:$PATH"' >> ~/.bashrc
> echo 'export LIBPATH="/opt/pkg/lib:$LIBPATH"' >> ~/.bashrc
> ```

### Install rpm Package (Recommended)

Install the rpm package to get command-line tools:
```bash
dnf5 install rpm
```

> [!NOTE]
> While dnf5 has rpm libraries statically linked, the rpm package provides useful CLI tools (`rpm -qa`, `rpm -ql`, `rpm -qi`, etc.) for querying packages, verifying installations, and managing the RPM database.

### Using DNF5

**List all packages in the zopen repository:**
```bash
dnf5 list
```

**Search for a package (e.g. jq):**
```bash
dnf5 search jq
```

**Install a package:**
```bash
dnf5 install jq
```

### Query Package Files

To discover what files were installed by a package:
```bash
rpm -ql jq
```

Output example:
```
/opt/pkg/bin/jq
/opt/pkg/lib/libjq.so
/opt/pkg/share/man/man1/jq.1
```

---

## Installing Packages into a Staged Filesystem

On z/OS, software is commonly installed or serviced in a separate writable filesystem before that filesystem is mounted at its production location.

For example, a filesystem can be temporarily mounted at `/SERVICE`, updated using DNF5, validated, unmounted, and then remounted at its normal production mount point.

### Install into the Staged Filesystem

To install `ztrace` into the filesystem mounted at `/SERVICE`:

```bash
dnf5 --installroot=/SERVICE --use-host-config install ztrace
```

The options have the following purposes:

* **`--installroot=/SERVICE`** tells DNF5 to treat `/SERVICE` as the root of the filesystem being serviced.
* **`--use-host-config`** tells DNF5 to use the repository configuration from the active system, including:

  ```text
  /opt/pkg/etc/yum.repos.d/zopen.repo
  ```

Without `--use-host-config`, DNF5 looks for repository configuration inside the staged filesystem instead:

```text
/SERVICE/opt/pkg/etc/yum.repos.d/zopen.repo
```

> [!IMPORTANT]
> Use the same `--installroot` value for every DNF5 command that operates on the staged filesystem. If the option is omitted, DNF5 operates on the active system root and its RPM database instead.

### List Packages Installed in the Staged Filesystem

```bash
dnf5 --installroot=/SERVICE --use-host-config list --installed
```

Example output:

```text
Installed packages
ztrace.s390x 0.1.0-1 <unknown>
```

### Query the Staged RPM Database Directly

When using `rpm`, specify the staged filesystem using `--root`:

```bash
rpm --root /SERVICE -qa
```

To query a specific package:

```bash
rpm --root /SERVICE -q ztrace
```

Commands that do not specify the staged root query the active system RPM database and may therefore return no results:

```bash
dnf5 list --installed
rpm -qa
```

### Remove or Upgrade Packages in the Staged Filesystem

Remove a package:

```bash
dnf5 --installroot=/SERVICE --use-host-config remove ztrace
```

Upgrade the packages installed in the staged filesystem:

```bash
dnf5 --installroot=/SERVICE --use-host-config upgrade
```

### Typical z/OS Deployment Flow

A typical staged deployment follows this sequence:

1. Mount the target writable filesystem at `/SERVICE`.
2. Install or upgrade packages using `--installroot=/SERVICE`.
3. Query and validate the installed packages.
4. Unmount the filesystem from `/SERVICE`.
5. Mount or remount the filesystem at its production mount point.

For example:

```bash
dnf5 --installroot=/SERVICE --use-host-config install ztrace
dnf5 --installroot=/SERVICE --use-host-config list --installed
rpm --root /SERVICE -q ztrace
```

> [!NOTE]
> Package paths are interpreted relative to the installation root. For example, a package file with the path:
>
> ```text
> /opt/pkg/bin/ztrace
> ```
>
> is written during staging as:
>
> ```text
> /SERVICE/opt/pkg/bin/ztrace
> ```
>
> After the filesystem is mounted at its production location, the files become available through the corresponding production paths.

---

## Troubleshooting

### 1. Error: `add_librepo_xattr: Operation not supported`
*   **Cause**: This is a harmless warning. The USS filesystem configuration doesn't support extended attributes (xattr) for tracking downloads.
*   **Fix**: No action is required. This warning does not block package downloading or installation.

### 2. Error: `Permission denied`
*   **Cause**: You attempted to run `rpm --import`, `dnf5 makecache`, or `dnf5 install` from a user account without superuser privileges.
*   **Fix**: Log out and log back in directly with a user account that has superuser/root authority (UID 0).

### 3. Error: `Failed to synchronize cache for repo`
*   **Cause**: Network connectivity issues or repository configuration problems.
*   **Fix**: 
    * Check network connectivity: `curl -I http://repo.zopen.community/`
    * Try the fallback IP address in the repository configuration
    * Clear cache and retry: `dnf5 clean all && dnf5 --repo=zopen makecache`

### 4. GPG verification failed
*   **Cause**: The GPG key may not be properly imported or the package signature is invalid.
*   **Fix**: 
    * The GPG key should be automatically imported on first package install. If it fails, manually import:
      ```bash
      rpm --import http://repo.zopen.community/pulp/content/keys/zopen.pub
      ```
    * Verify the key is imported: `rpm -q gpg-pubkey`
    * View key details: `rpm -qi gpg-pubkey`
    * If testing only, you can bypass GPG check (not recommended): `dnf5 install --nogpgcheck <package-name>`

---

## Best Practices

1. **Always use superuser/root account** for package management operations
2. **Verify GPG signatures** - Always keep `gpgcheck=1` in production environments
3. **Regular updates** - Keep your packages up to date:
   ```bash
   dnf5 upgrade
   ```
4. **Clean cache periodically** - Free up disk space:
   ```bash
   dnf5 clean all
   ```
5. **Monitor disk space** - Ensure `/opt/pkg` has at least 1 GB free (minimum) for database, cache, and packages
6. **Use staged deployments** - Test package installations in a staged filesystem before deploying to production
7. **Document configurations** - Keep track of installed packages and custom repository configurations

---

## Additional Resources

- [zopen Community Documentation](https://zopen.community)
- [The zopen Package Manager Guide](./ThePackageManager.md)
- [RPM Documentation](http://rpm.org/documentation.html)
- [DNF5 Documentation](https://dnf.readthedocs.io/)
- [GitHub Discussion: RPM Packages Consumption Guideline](https://github.com/orgs/zopencommunity/discussions/1223)

---

## Pending Development

*   **Bootstrapping:** Investigate and write a unified script that installs `zopen` and bootstraps the package managers automatically.
*   **var Storage Directories:** Check what specific directories under `/var` are written to by DNF5 and measure the exact filesystem size needed.
*   **Alternatives Integration:** Investigate and design how to cleanly manage and integrate alternatives in general with `zopen`'s standard profile environment scripts.
