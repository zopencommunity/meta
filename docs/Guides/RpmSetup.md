# Setting up RPM and DNF5 on z/OS

This guide explains how to configure your z/OS Unix System Services (USS) client to consume, verify, and install RPM packages delivered by the zopen community.

> [!IMPORTANT]
> System package management operations (such as importing GPG signing keys and installing packages using `rpm` and `dnf5`) modify system directories and database files. You must perform this setup and run these commands **logged in directly under a user account with superuser authority (root user / UID 0)**.

---

## Step 0: Install Package Management Tools

If you do not have `dnf5` and `rpm` installed on your z/OS USS system, you can download and install them directly from the zopen community.

### Option 1: Using the dnf5 Quick Install Script (Recommended)

The quickest way to install dnf5 is using the one-liner install script:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/zopencommunity/meta/HEAD/tools/dnf5_install.sh)"
```

Or download and run the script:

```bash
curl -O https://raw.githubusercontent.com/zopencommunity/meta/HEAD/tools/dnf5_install.sh
chmod +x dnf5_install.sh
./dnf5_install.sh
```

This script will:
- Download the latest stable dnf5 release
- Extract and set up the package
- Create the RPM bootstrap configuration
- Initialize necessary directories

### Option 2: Using the zopen Package Manager

If you already have zopen installed, you can use it to install dnf5 and rpm:

```bash
# Install/upgrade the RPM database manager and GPG tools
zopen upgrade rpm -y

# Install/upgrade the DNF5 package manager
zopen upgrade dnf5 -y
```

### Verify Installation

Once installed, verify they are in your environment by running:
```bash
rpm --version
dnf5 --version
```
*   **Required minimum versions:**
    *   `rpm` version **6.0.1** or higher
    *   `dnf5` version **5.4.2.1** or higher

---

## Step 1: Configure the Repository (Requires Superuser/Root)

Create the configuration file to tell `dnf5` where to find the package metadata and GPG keys.

1. Ensure you are in a terminal session logged in as a **superuser (root)**.
2. Create the repository directory and ensure it has correct permissions (`755`):
   ```bash
   mkdir -p /etc/yum.repos.d
   chmod 755 /etc/yum.repos.d
   ```
3. Create the configuration file `/etc/yum.repos.d/zopen.repo`:
   ```bash
   vim /etc/yum.repos.d/zopen.repo
   ```

### Option 1: Manual Setup (Recommended)
Paste the following configuration.

> [!NOTE]
> The primary domain is `http://repo.zopen.community/`. If your system is behind a firewall that cannot resolve external domains or has TLS issues, you can fall back to the direct IP endpoint `http://163.74.83.190:8080/`.

**Primary Configuration:**
```ini
[zopen]
name=zopen
baseurl=http://repo.zopen.community/pulp/content/zopen/
gpgkey=http://repo.zopen.community/pulp/content/keys/zopen.pub
gpgcheck=1
repo_gpgcheck=0
enabled=1
metadata_expire=300
```

**Alternative (Direct IP Fallback) Configuration:**
```ini
[zopen]
name=zopen
baseurl=http://163.74.83.190:8080/pulp/content/zopen/
gpgkey=http://163.74.83.190:8080/pulp/content/keys/zopen.pub
gpgcheck=1
repo_gpgcheck=0
enabled=1
metadata_expire=300
```
*(Note: The `metadata_expire=300` tells DNF5 to check for new repository updates every 5 minutes by default).*

Ensure the file permissions are set to `644` (read-only for non-root):
```bash
chmod 644 /etc/yum.repos.d/zopen.repo
```

### Option 2: Download via Curl
Alternatively, you can download the configuration file directly:
```bash
# Primary DNS download
curl -o /etc/yum.repos.d/zopen.repo http://repo.zopen.community/pulp/content/zopen/config.repo

# Direct IP download fallback
# curl -o /etc/yum.repos.d/zopen.repo http://163.74.83.190:8080/pulp/content/zopen/config.repo

chmod 644 /etc/yum.repos.d/zopen.repo
```

---

## Step 2: Import the GPG Public Key (Requires Superuser/Root)

All RPM packages in the zopen repository are cryptographically signed to ensure security. Import the community public key into your system's RPM database:

```bash
rpm --import http://repo.zopen.community/pulp/content/keys/zopen.pub
```
*(Fallback IP URL: `http://163.74.83.190:8080/pulp/content/keys/zopen.pub`)*

### Verify the GPG Key Import
To confirm that the GPG public key has been successfully imported into the RPM database, run:
```bash
rpm -q gpg-pubkey
```
Expected output should list the imported key (e.g., `gpg-pubkey-xxxxxxxx-xxxxxxxx`). To view the detailed information of the imported zopen key (such as the signer details), run:
```bash
rpm -qi gpg-pubkey
```

---

## Step 3: Clear Cache and Initialize Metadata (Requires Superuser/Root)

Initialize the local package database cache. Because z/OS clients require uncompressed metadata formats, the repository serves XML layouts natively.

### Directory and Storage Requirements
This step writes to the following paths on `/var`:
*   **`/var/lib/rpm/`**: Stores the system RPM package database.
*   **`/var/cache/libdnf5/`**: Stores downloaded package metadata and cache.

> [!IMPORTANT]
> Ensure the filesystem hosting `/var` has at least **200 MB to 500 MB** of free space available to store the packages database and metadata cache safely.

Run the synchronization command:
```bash
# Clear any old cached files
dnf5 clean all

# Fetch the latest metadata cache for the zopen repository
dnf5 --repo=zopen makecache
```

> [!TIP]
> If a new package has just been published to the repository but `dnf5` is not showing it, you can force the metadata cache to refresh instantly from the remote server by passing the **`--refresh`** flag:
> ```bash
> dnf5 --refresh --repo=zopen makecache
> ```

---

## Step 4: Install and Query Packages (Requires Superuser/Root to Install)

Now you can list, search, and install tools from the repository.

*   **List all packages in the zopen repository:**
    ```bash
    dnf5 list
    ```
*   **Search for a package (e.g. jq):**
    ```bash
    dnf5 search jq
    ```
*   **Install a package (Requires Superuser/Root):**
    ```bash
    dnf5 install jq
    ```

### Discover Package Installation Paths
To discover exactly what files were installed by a package and where they were placed on your filesystem, use the `rpm` query command:
```bash
rpm -ql jq
```

---

## Package Installation Paths & Alternatives

All packages installed from the zopen RPM repository are placed under the **`/opt/pkg`** directory structure on the z/OS client system:

*   **Binaries:** `/opt/pkg/bin`
*   **Libraries:** `/opt/pkg/lib`
*   **Shared Resources:** `/opt/pkg/share`

To run and use the installed packages, make sure to add the binaries to your `PATH` environment variable:
```bash
export PATH="/opt/pkg/bin:$PATH"
export LIBPATH="/opt/pkg/lib:$LIBPATH"
```

### Alternatives and zopen Integration
For utilities where multiple versions might coexist (such as `openssl` or python), the system uses the **`alternatives`** command structure to manage symbolic links pointing to the active version:
*   To list or switch versions of a command, use:
    ```bash
    alternatives --config openssl
    ```
*   **zopen integration:** Future updates will investigate how to integrate alternatives in general into `zopen`'s standard user-profile environment scripts to automatically register `/opt/pkg` binaries.

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
  /etc/yum.repos.d/zopen.repo
  ```

Without `--use-host-config`, DNF5 looks for repository configuration inside the staged filesystem instead:

```text
/SERVICE/etc/yum.repos.d/zopen.repo
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
    * Re-import the GPG key: `rpm --import http://repo.zopen.community/pulp/content/keys/zopen.pub`
    * Verify the key is imported: `rpm -q gpg-pubkey`
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
5. **Monitor disk space** - Ensure `/var` has sufficient space before operations
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
