This guide provides a recommended set of open source tools for various roles within the zopen community. Each role, ranging from system administrators to AI engineers has unique needs, and these tools aim to boost productivity, enhance security, and simplify workflows on the mainframe. These tools can be installed, updated and managed via [zopen package manager](/Guides/ThePackageManager).

## 1. **System Administrator**
   - **Core System Tools**: 
      - `coreutils` - Essential core utilities (e.g., ls, cat) for daily operations. Recommended if you require additional function over z/OS Native /bin tools.
      - `util-linux` - Common utilities (e.g., whereis - to locate files quickly).
      - `moreutils` - Additional utilities such as sponge, parallel, and more. See this [blog](https://rentes.github.io/unix/utilities/2015/07/27/moreutils-package/) for more details.
      - `findutils`, `grep`, `sed`, `diff` - GNU based utilities with additional function over /bin tools.
   - **Networking and Security**:
      - `openssh` - Secure remote login and file transfer (includes sftp, ssh, and ssh-copy-id (great for copying an ssh key to another machine quickly)).
      - `curl`, `wget` - Tools to fetch files over HTTP/HTTPS.
      - `openssl` - Encryption and security client and library. 
      - `sudo` - Privilege escalation for executing commands.
   - **System Configuration and Management**:
      - `c3270` - c3270 emulator to access ISPF/TSO via z/OS UNIX
      - `bash` - Shell scripting and command interpreter.
      - `logrotate` - Automatic rotation and compression of logs.
      - `tmux` and `screen` - Terminal multiplexer for managing sessions.
      - `tree` - Directory and file structure visualization.
      - (WIP) `rsync` - File synchronization and transfer.
   - **Monitoring**:
      - `prometheus` - Metric-based system and application monitoring.
      - `victoriametrics` - High-performance database for time-series metrics.
      - `grafana` - Visualization tool for metrics.
   - **File Management**:
      - `ncdu` - Disk usage analyzer to detect files and dirs using up disk space.
      - `zip`, `unzip`, `gzip`, `tar`, `bzip2`, `xz`, `zstd` - Compression and archiving tools for backup or archiving data.
   - **zopen**:
      - `meta` - Package manager to install and manage tools.
      - `zopen audit` - Security command to check for vulnerabilities in packages.

## 2. **Application Developer**
   - **Core System Tools**: 
      - `coreutils` - Essential core utilities (e.g., ls, cat) for daily operations. Recommended if you require additional function over z/OS Native /bin tools.
      - `util-linux` - Common utilities (e.g., whereis - to locate files quickly).
      - `moreutils` - Additional utilities such as sponge, parallel, and more. See this [blog](https://rentes.github.io/unix/utilities/2015/07/27/moreutils-package/) for more details.
      - `findutils`, `grep`, `sed`, `diff` - GNU based utilities with additional function over /bin tools.
   - **Coding and Compilation**:
      - `cmake` - (Recommended for new projects) - Build automation tool that generates build system files for Make, Ninja and more.
      - `ninja` - Very fast build systems for compiling projects.
      - `make` -  Build systems for compiling projects.
      - `m4` - Macro processor for generating code templates.
      - `autoconf`, `automake`, `pkgconfig` - Tools for configuring software builds.
   - **Languages**
      - `lua``, `perl` - Extend functionality with embedded lua or write automation scripts using perl
   - **Libraries**:
      - `zlib` - Compression library.
      - `sqlite` - Embedded database library
      - `libgpgerror`, `libgcrypt` - Cryptographic libraries for signing content.
      - `libpcre` - Library for regex
      - `libxml2` - XML library
      - `cjson` - C JSON parsing library (used in Libdio)
      - `protobuf` - Protocol Buffers for data serialization.
   - **Text Editing**:
      - `vim`, `nano`, `emacs` - Popular text editors for coding.
   - **Data processing**:
      - `jq`, `yq` - JSON and YAML processing tools.
   - **Version Control**:
      - `git` - Git source control
      - `git-lfs` - Git large file support.
      - `gitlabcli` - Command-line interface for GitLab.
      - `githubcli` - Command-line interface for Github.
   - **Documentation**:
      - `doxygen` - Documentation generation from source code.
      - `help2man`, `man-db` - Tools for creating and managing man pages.
   - **zopen**:
      - `meta` - Package manager for installing development tools.

## 3. **DevOps / CI/CD Engineer**
   - **Automation**:
      - `buildkite` - Continuous integration agent
      - `github-runner` - Gitlab Continuous integration
   - **Version Control & Collaboration**:
      - `git`, `gitlabcli`, `githubcli` - Version control and GitHub/GitLab management.
   - **Networking and Security**:
      - `openssh`, `cosign`, `gpg` - Secure access and container signing.
      - `ntbtls`, `openssl` - Encryption and network security libraries.
   - **Monitoring and Logging**:
      - `prometheus`, `grafana`, `victoriametrics` - Monitoring and visualization tools.
      - `logrotate` - Log file management.
   - **zopen**:
      - `meta` - Comprehensive package manager for CI/CD tools.

## 4. **AI Engineer**
   - **Data Handling and Preprocessing**:
      - `duckdb` - In-process SQL database for data analytics.
      - `jq`, `yq` - JSON and YAML processing tools.
   - **Machine Learning Libraries**:
      - `llamacpp` - Lightweight machine learning library.
   - **Version Control**:
      - `git`, `git-lfs`, `githubcli` - Version control and GitHub management.
   - **zopen**:
      - `meta` - Package manager to manage machine learning and AI tools.

## 5. **Project Manager**
   - **Collaboration & Communication**:
      - `githubcli`, `gitlabcli` - GitHub and GitLab command-line interfaces.
   - **Version Control**:
      - `git`, `git-lfs` - Version control for project files.
   - **Workflow Automation**:
      - `bash`, `curl`- Tools for scripting and automating tasks.
   - **Monitoring**:
      - `prometheus`, `grafana` - Tools for tracking project metrics.
   - **zopen**:
      - `meta` - Package manager to install and manage project management tools.

