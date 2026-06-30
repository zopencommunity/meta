// RPM Build Job
// Runs zopen-rpmbuild against a spec file from a given GitHub project repo.
// meta.git is shallow cloned (depth=1) by Jenkins SCM config.
// This job must run on the z/OS zot system.
//
// Inputs:
//   PROJECT_GITHUB_REPO   : GitHub repo containing build.spec (e.g. https://github.com/zopencommunity/myport.git)
//   PROJECT_BRANCH        : Branch to checkout (default: main)
//   SPEC_FILE             : Path to spec file relative to project root (default: build.spec)
//   SOURCE_FILE           : Optional source file path relative to project root (e.g. mypackage.pax.Z)
//                           Leave empty for virtual/meta packages with no sources
//   BUILD_BINARY          : Boolean - build binary RPM only, skip source RPM (default: true)
//   SIGN_RPM              : Boolean - GPG-sign generated RPMs after build (default: true)
//   BUILDROOT             : RPM build root directory (default: ~/rpmbuild)
//   NODE_LABEL            : Label of the Jenkins node to run on (default: zos)
//   GPG_KEY_CREDENTIAL    : Jenkins credential ID for GPG secret key file (default: ZOPEN_GPG_SECRET_KEY_FILE)
//   GPG_PASS_CREDENTIAL   : Jenkins credential ID for GPG passphrase file (default: ZOPEN_GPG_SECRET_KEY_PASSPHRASE_FILE)

def node_label     = params.NODE_LABEL           ?: "zos"
def project_repo   = params.PROJECT_GITHUB_REPO  ?: ""
def project_branch = params.PROJECT_BRANCH       ?: "main"
def spec_file      = params.SPEC_FILE            ?: "build.spec"
def source_file    = params.SOURCE_FILE          ?: ""
def buildroot      = params.BUILDROOT            ?: ""
def build_binary   = params.BUILD_BINARY         ?: true
def sign_rpm       = params.SIGN_RPM             ?: true
def gpg_key_cred   = params.GPG_KEY_CREDENTIAL   ?: "ZOPEN_GPG_SECRET_KEY_FILE"
def gpg_pass_cred  = params.GPG_PASS_CREDENTIAL  ?: "ZOPEN_GPG_SECRET_KEY_PASSPHRASE_FILE"

node(node_label) {

  def ws = env.WORKSPACE

  stage('Build RPM') {
    if (!project_repo) {
      error "PROJECT_GITHUB_REPO is required"
    }

    def project_name = project_repo.tokenize('/').last().replaceAll('\\.git$', '')

    // Set default buildroot as the cloned project repository directory inside the workspace
    def localBuildroot = buildroot ?: "${ws}/${project_name}/rpmbuild"

    // Construct the zopen-rpmbuild command options
    def cmdOptions = "\"${spec_file}\" --buildroot \"${localBuildroot}\""
    if (source_file) {
      cmdOptions += " --source \"${source_file}\""
    }
    if (build_binary) {
      cmdOptions += " --build-binary"
    }

    // Run everything in a single, robust bash execution
    deleteDir()
    checkout scm

    // Construct sign flag for command execution
    if (sign_rpm) {
      cmdOptions += " --sign"
    }

    // Set up dynamic credentials mapping based on sign_rpm parameter
    def gpgBindings = sign_rpm ? [
      file(credentialsId: gpg_key_cred,  variable: 'ZOPEN_GPG_SECRET_KEY_FILE'),
      file(credentialsId: gpg_pass_cred, variable: 'ZOPEN_GPG_SECRET_KEY_PASSPHRASE_FILE')
    ] : []

    withCredentials(gpgBindings) {
      sh """bash -e -s << 'BASH'
        set +e
        . /jenkins/.env
        set -e
        export PATH="${ws}/bin:\$PATH"
        export NO_COLOR=1
        export ZOPEN_IS_BOT=1
        export GIT_UTF8_CCSID=819
        export TMPDIR="${ws}/tmp"
        export GPG_TTY="/dev/null"
        mkdir -p "\$TMPDIR"

        # 1. Print version diagnostics
        zopen-rpmbuild --version || true

        # 2. Clone repo clean
        rm -rf "${project_name}"
        git clone -b "${project_branch}" "${project_repo}" "${project_name}"

        # 3. Verify spec file exists
        if [ ! -f "${project_name}/${spec_file}" ]; then
          echo "ERROR: Spec file not found in repository: ${project_name}/${spec_file}" >&2
          exit 1
        fi

        # 4. Build
        cd "${project_name}"
        zopen-rpmbuild ${cmdOptions}

        # 5. Copy RPMs to workspace for archiving
        mkdir -p "${ws}/rpms"
        cp -R "${localBuildroot}/RPMS/"* "${ws}/rpms/" 2>/dev/null || true
BASH"""
    }

    archiveArtifacts artifacts: "rpms/**/*.rpm",
                     allowEmptyArchive: false,
                     fingerprint: true
  }

}
