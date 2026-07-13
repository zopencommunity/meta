# Jenkins CI/CD Pipelines

This directory contains the Jenkins Pipeline scripts (Groovy) used to orchestrate the build, packaging, testing, and publication of both **Port packages** (pax.Z format) and **RPM packages** in the zopencommunity environment.

---

## Port Pipelines

### 1. Port Orchestrator Pipeline (`pipeline.jenkins`)
* **Purpose**: The main orchestrator pipeline for standard port builds.
* **Flow**:
  1. **Build and Test**: Triggers the `Port-Build` job on a z/OS node and copies over the resulting test statuses.
  2. **Publish (Parallel)**:
     - **Port-Publish**: Publishes the `.pax.Z` packages as a GitHub release on the port's repository.
     - **UpdateReleaseAPIs**: Updates the release metadata API definitions.
     - **RPM-Publish**: Triggers `RPM-Publish` to upload generated RPMs to Pulp.
* **Key Parameters**:
  * `PORT_GITHUB_REPO`: Upstream GitHub repository URL of the port (e.g. `makeport`).
  * `PORT_BRANCH`: Git branch to build (default: `main`).
  * `BUILD_LINE`: Release line to build against (default: `stable`).
  * `NO_PROMOTE`: Boolean flag to skip the package publication step.

### 2. Port Build Pipeline (`build.groovy`)
* **Purpose**: Compiles, builds, and runs test suites for the target port project on the z/OS host machine.
* **Flow**:
  1. **Build Project**: Clones the port repository and runs `zopen-build` to compile the port.
  2. **Artifact Packaging**: Generates both `.pax.Z` and `.rpm` files and signs them using GPG keys.
  3. **Archive**: Archives build artifacts (metadata, packages, logs) inside Jenkins.
* **Key Parameters**:
  * `PORT_GITHUB_REPO`: Upstream GitHub repository URL of the port.
  * `PORT_BRANCH`: Git branch to build (default: `main`).
  * `FORCE_CLANG`: Enforces compiling the project with Clang rather than `xlclang`.
  * `GENERATE_PAX_RPM`: Boolean flag to enable/disable package generation.

### 3. Port Publish Pipeline (`publish.groovy`)
* **Purpose**: Takes `.pax.Z` build artifacts and publishes them to public GitHub releases.
* **Flow**:
  1. **Fetch Artifacts**: Copies the generated `.pax.Z` package, version, and metadata files from the upstream `Port-Build` job.
  2. **Draft Release**: Drafts a release on the port's GitHub repository.
  3. **Upload Assets**: Uploads the `.pax.Z` and checksum files to the draft release.
  4. **Publish**: Publishes the release and pushes metadata changes.
* **Key Parameters**:
  * `PROMOTED_JOB_NAME`: The upstream job to copy artifacts from (default: `Port-Build`).
  * `BUILD_SELECTOR`: The build number (e.g. `63`) to copy from.
  * `PORT_GITHUB_REPO`: GitHub repository URL of the port.
  * `BUILD_LINE`: Target release line (e.g. `stable` or `dev`).

---

## RPM Pipelines

### 1. Orchestrator Pipeline (`rpm_pipeline.jenkins`)
* **Purpose**: Orchestrates the entire end-to-end RPM build and promotion lifecycle. It triggers the z/OS build, monitors it, and subsequently publishes the generated RPMs.
* **Flow**:
  1. **RPM Build**: Triggers the `RPM-Build` job on a z/OS build node.
  2. **Promote**: Triggers the `RPM-Publish` job to upload the binary RPMs to the Pulp repository (skipped if `NO_PROMOTE` is enabled).
  3. **Notification**: Sends success/failure status notifications to Slack.
* **Key Parameters**:
  * `PROJECT_GITHUB_REPO`: Upstream GitHub repository URL of the project to build.
  * `PROJECT_BRANCH`: Git branch to checkout (default: `main`).
  * `SPEC_FILE`: Path to the RPM `.spec` file relative to the repository root.
  * `NODE_LABEL`: Jenkins node executor label for the build (default: `zos`).
  * `NO_PROMOTE`: Boolean flag to skip the package publication step.

### 2. RPM Publish Pipeline (`publish_rpm.groovy`)
* **Purpose**: Fetches binary RPM artifacts from a completed build job and uploads them into the Pulp repository.
* **Flow**:
  1. **Setup**: Clears the workspace and checks out this repository.
  2. **Fetch Artifacts**: Copies the generated `.rpm` files from the specified upstream build job using the Jenkins Copy Artifacts plugin.
  3. **Pulp Upload**: Logins to the Pulp server, uploads the binary packages, and updates the repository version.
* **Key Parameters**:
  * `PROMOTED_JOB_NAME`: **Required**. The name of the Jenkins build job to copy artifacts from (e.g. `RPM-Build`, `Port-Build`).
  * `BUILD_SELECTOR`: **Required**. The specific build number (e.g. `63`) or Copy Artifacts XML selector to fetch artifacts from.

### 3. Pulp Repo Setup Pipeline (`pulp_repo_setup.groovy`)
* **Purpose**: An administrative setup pipeline to bootstrap the Pulp repository, distribution, GPG key hosting, and client `.repo` configuration. This is typically run **once** or during maintenance.
* **Flow**:
  1. **GPG Key Hosting**: Configures a Pulp file repository (`keys`) distributed at the API/client-facing path `/pulp/content/keys/` to host the public key `zopen.pub`.
  2. **RPM Repo Setup**: Bootstraps the RPM repository and base-path distribution (`zopen`).
  3. **GPG Config**: Configures the repository signature verification parameters (`gpgcheck: 1`) and automatically generates the `.repo` client configuration file.
* **Key Parameters**:
  * `PULP_REPO`: Name of the target RPM repository (default: `zopen`).
