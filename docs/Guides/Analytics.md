# Collecting Usage Statistics with the z/OS Open Tools Package Manager

Usage statistics collection in z/OS Open Tools Package Manager was introduced to gather anonymized usage data. 
The collected usage data plays an important role in improving functionality, identifying popular packages, and optimizing z/OS Open Tools user experience.

## How to Opt-In

* During the initialization process using the zopen init command, users will be prompted to opt-in or opt-out of statistics collection.
* Users can also pass in the following options to `zopen init:
  * `--enable-stats`: Enables the collection of usage statistics.
  * `--noenable-stats`: Disables the collection of usage statistics.

Note: IBM hostnames are automatically opted in.

## Data Captured
1. **Package Installations:**
   - **Package Name:** Identifies the installed package.
   - **Version:** Captures the version of the installed package.
   - **Timestamp:** Records the installation date and time.
   - **Upgrade Status:** Indicates whether the installation is an upgrade.

2. **Package Removals:**
   - **Package Name:** Specifies the removed package.
   - **Version:** Captures the version of the removed package.
   - **Timestamp:** Records the removal date and time.

3. **System Profile:**
   - **UUID:** Provides a unique identifier for the user's system profile.
   - **IBM Host Status:** Indicates whether the host is an IBM server.
   - **Bot Status:** Identifies whether the script is executed in a Jenkins, CI/CD environment.

## Ensuring Anonymity and Privacy

All collected data is anonymized and no personal data is recorded. If you have opted out, usage statistics will not be collected.
