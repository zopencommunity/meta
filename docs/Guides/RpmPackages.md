# RPM Packages on z/OS

The zopen community provides RPM packages as an alternative distribution format for z/OS Unix System Services (USS). This allows you to leverage industry-standard package management tools like RPM and DNF5 to install, update, and manage open-source software on z/OS.

## Understanding RPM and DNF5

### What is RPM?

**RPM (RPM Package Manager)** is a **package format** and set of tools for software distribution. Think of RPM as the "container" for software.

**RPM as a Format:**
- `.rpm` files are archives containing compiled software, metadata, and installation scripts
- Each RPM package includes:
  - Software binaries and libraries
  - Dependency information (what other packages are needed)
  - Version and architecture details
  - Installation/removal scripts
  - GPG signatures for verification

**RPM Command-Line Tools:**
- `rpm` command for low-level package operations
- Query installed packages: `rpm -qa`
- Inspect package contents: `rpm -ql <package>`
- Verify installations: `rpm -V <package>`

**Key Point:** RPM itself does **not** handle dependency resolution automatically. Installing an RPM that requires other packages requires manual dependency management.

### What is DNF5?

**DNF5** is a **high-level package manager** that works with RPM packages. Think of DNF5 as the "intelligent installer" that uses RPM packages.

**DNF5's Role:**
- Downloads RPM packages from repositories
- **Automatically resolves dependencies** - figures out what other packages are needed
- Installs multiple RPM packages in the correct order
- Manages package updates and removals safely
- Maintains transaction history

**DNF5 Architecture:**
- Written in C++ for performance
- Uses RPM libraries internally
- Queries repository metadata to find packages
- Downloads and installs `.rpm` files automatically

**Key Point:** DNF5 is the **recommended way** to install RPM packages because it handles all dependencies automatically.

### The Relationship: RPM vs DNF5

| Aspect | RPM | DNF5 |
|--------|-----|------|
| **Type** | Package format + low-level tools | High-level package manager |
| **What it is** | The `.rpm` file format and `rpm` command | Tool that installs/manages RPM packages |
| **Analogy** | Like a `.zip` file and unzip command | Like an app store that downloads and installs |
| **Dependencies** | Manual - you must install dependencies yourself | Automatic - resolves and installs all dependencies |
| **Repositories** | No built-in repository support | Downloads from configured repositories |
| **Use case** | Low-level operations, scripting, verification | Daily package management |
| **Commands** | `rpm -i package.rpm` (install one file) | `dnf5 install package` (install from repo with deps) |

**Example Workflow:**
1. You run: `dnf5 install vim`
2. DNF5 queries the repository for vim
3. DNF5 discovers vim needs: `ncurses`, `glibc`, `libacl`
4. DNF5 downloads all `.rpm` files
5. DNF5 installs them in correct order using RPM libraries
6. Result: vim and all dependencies installed

### Why Both?

- **DNF5** is what you use day-to-day: `dnf5 install`, `dnf5 search`, `dnf5 upgrade`
- **RPM tools** are useful for queries and verification: `rpm -qa`, `rpm -ql vim`, `rpm -V vim`
- Both work together: DNF5 uses RPM format, RPM tools query what DNF5 installed

## Why Use RPM and DNF5 on z/OS?

### Benefits for System Administrators

- **Familiar tooling** - Use the same package management commands you know from Linux
- **Enterprise-ready** - Battle-tested package format used by major Linux distributions
- **Automatic dependency resolution** - DNF5 handles all dependencies automatically
- **Centralized management** - Manage packages across multiple z/OS systems with repository servers
- **Staged deployments** - Install and validate packages in staged filesystems before production deployment
- **Audit trail** - Complete history of package installations, updates, and removals

### Benefits for Developers

- **Quick installation** - Install tools with a single command: `dnf5 install <package>`
- **Consistent environments** - Ensure all team members have the same tool versions
- **Dependency handling** - DNF5 automatically installs required libraries and dependencies
- **Version control** - Easily switch between different package versions
- **Integration** - Works alongside the traditional zopen package manager

## RPM vs Traditional zopen Packages

The zopen community provides software in multiple formats:

| Feature | zopen PAX | RPM Packages |
|---------|-----------|--------------|
| **Installation** | User-level, no root required | System-level, requires root |
| **Location** | `$ZOPEN_ROOTFS` (typically `~/zopen`) | `/opt/pkg` |
| **Dependencies** | Manual or via zopen | Automatic via DNF5 |
| **Multi-user** | Per-user installations | System-wide |
| **Updates** | `zopen upgrade` | `dnf5 upgrade` |
| **Best for** | Development, personal use | Production, system-wide deployment |

Both formats are fully supported and can coexist on the same system. Choose the format that best fits your use case.

## Getting Started

To start using RPM packages on z/OS:

1. **Install DNF5** - Use the automated script or install manually (see [Setup Guide](./RpmSetup.md))
2. **Configure the repository** - Set up access to the zopen RPM repository
3. **Install rpm tools** - Recommended first package: `dnf5 install rpm`
4. **Install other packages** - Use DNF5 to search and install additional packages

See the [Setup Guide](./RpmSetup.md) for detailed step-by-step instructions.

## Available Tools

All packages available in the zopen community are distributed in both PAX and RPM formats. You can:

- Browse available packages: [Available Tools and Libraries](/Latest.md)
- Search for packages: `dnf5 search <package-name>`
- List all available packages: `dnf5 list available`

## System Requirements

- **z/OS Version**: 2.4 or higher
- **Root access**: Required for package installation and system configuration
- **Disk space**: At least 1 GB free space on `/opt/pkg` for RPM database, cache, and packages
- **Network**: Access to `repo.zopen.community` or the fallback IP address

## Package Management Commands

Here are the most common DNF5 commands for managing RPM packages:

```bash
# Search for a package
dnf5 search vim

# Get package information
dnf5 info vim

# Install a package
dnf5 install vim

# Remove a package
dnf5 remove vim

# Update all packages
dnf5 upgrade

# List installed packages
dnf5 list --installed

# Clean package cache
dnf5 clean all
```

For more detailed usage, see the [Setup Guide](./RpmSetup.md).

## Repository Information

The zopen community maintains an RPM repository at:

- **Primary URL**: `http://repo.zopen.community/pulp/content/zopen/`
- **Fallback IP**: `http://163.74.83.190:8080/pulp/content/zopen/`
- **GPG Key**: `http://repo.zopen.community/pulp/content/keys/zopen.pub`

All packages are cryptographically signed for security and verification.

## Support and Resources

- **Setup Guide**: [Setting up RPM and DNF5](./RpmSetup.md)
- **GitHub Discussion**: [RPM Packages Consumption Guideline](https://github.com/orgs/zopencommunity/discussions/1223)
- **Community Support**: [zopen Discussions](https://github.com/zopencommunity/meta/discussions)
- **Issue Reporting**: [Report issues on GitHub](https://github.com/zopencommunity/meta/issues)

## Security Considerations

All RPM packages in the zopen repository are:

- **GPG-signed** - Each package is cryptographically signed to verify authenticity
- **Verified** - Package signatures are checked during installation (when `gpgcheck=1`)
- **Traceable** - Complete metadata about package contents and origins
- **Auditable** - Query installed packages and their files at any time

Always keep GPG verification enabled in production environments.

## Future Enhancements

The zopen community is continuously improving the RPM package experience:

- **Automated bootstrapping** - Simplified initial setup scripts
- **Alternatives integration** - Better integration with the `alternatives` system for managing multiple versions
- **Enhanced zopen integration** - Seamless use of both PAX and RPM packages

Join the discussion and contribute to these improvements on [GitHub](https://github.com/zopencommunity/meta/discussions).
