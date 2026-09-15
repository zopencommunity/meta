# RPM Packages on z/OS

The zopen community provides RPM packages as an alternative distribution format for z/OS Unix System Services (USS). This allows you to leverage industry-standard package management tools like RPM and DNF5 to install, update, and manage open-source software on z/OS.

## What are RPM Packages?

**RPM (RPM Package Manager)** is a powerful, mature package management system originally developed by Red Hat and widely adopted across the Linux ecosystem. RPM packages provide:

- **Standardized format** - Industry-standard packaging with metadata, dependencies, and versioning
- **Cryptographic signatures** - GPG-signed packages ensure authenticity and integrity
- **Dependency resolution** - Automatic handling of package dependencies
- **Transaction safety** - Atomic operations with rollback capabilities
- **Query and verification** - Tools to inspect and validate installed software

## What is DNF5?

**DNF5** is the next-generation package manager that uses RPM packages. DNF (Dandified YUM) was designed to replace the older YUM package manager, and DNF5 is a complete rewrite in C++ for better performance and reliability.

### Why DNF5 on z/OS?

The zopen community chose DNF5 for z/OS because:

- **Modern architecture** - Written in C++ with a clean API and modular design
- **Better performance** - Significantly faster than DNF4 and YUM for dependency resolution
- **Lower memory footprint** - More efficient resource usage, important for z/OS environments
- **Improved CLI** - Clearer command output and more intuitive user experience
- **Active development** - Maintained by the Fedora community with regular updates
- **Enterprise-ready** - Production-tested and widely used across the industry

### DNF5 Key Features

- **Smart dependency resolution** - Automatically installs required dependencies
- **Repository management** - Support for multiple package repositories
- **Transaction history** - Track all package operations with undo/redo capabilities
- **Modular content** - Support for multiple versions of the same software
- **Plugin system** - Extensible architecture for custom functionality
- **Fast metadata caching** - Quick package searches and queries

## Why Use RPM on z/OS?

### Benefits for System Administrators

- **Familiar tooling** - Use the same package management commands you know from Linux
- **Enterprise-ready** - Battle-tested package format used by major Linux distributions
- **Centralized management** - Manage packages across multiple z/OS systems with repository servers
- **Staged deployments** - Install and validate packages in staged filesystems before production deployment
- **Audit trail** - Complete history of package installations, updates, and removals

### Benefits for Developers

- **Quick installation** - Install tools with a single command
- **Consistent environments** - Ensure all team members have the same tool versions
- **Dependency handling** - Automatically install required libraries and dependencies
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

1. **Install the package management tools** - Install `rpm` and `dnf5` using the zopen package manager
2. **Configure the repository** - Set up access to the zopen RPM repository
3. **Install packages** - Use DNF5 to search and install packages

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
