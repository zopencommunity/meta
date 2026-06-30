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

// Helper to run a bash script — writes content to a temp file and
// invokes bash explicitly so z/OS sh is bypassed entirely.
def runBash(script) {
  sh "bash -xe -c '${script.replace("'", "'\\''")}'"
}

node(node_label) {

  def ws = env.WORKSPACE

  // Common environment setup sourced at the start of every bash invocation
  def envSetup = """
    set +e
    . /jenkins/.env
    set -e
    export PATH="${ws}/bin:\$PATH"
    export NO_COLOR=1
    export ZOPEN_IS_BOT=1
    export GIT_UTF8_CCSID=819
    export TMPDIR="${ws}/tmp"
    mkdir -p "\$TMPDIR"
  """

  stage('Setup') {
    deleteDir()
    checkout scm
    sh "bash -xe '${ws}/bin/zopen-rpmbuild' --version || true"
    sh """bash -xe -s << 'BASH'
${envSetup}
echo "Setup complete. PATH=\$PATH"
BASH"""
  }

  stage('Checkout') {
    if (!project_repo) {
      error "PROJECT_GITHUB_REPO is required"
    }

    def project_name = project_repo.tokenize('/').last().replaceAll('\\.git$', '')

    sh """bash -xe -s << 'BASH'
${envSetup}
git clone -b '${project_branch}' '${project_repo}' '${project_name}'
BASH"""

    env.PROJECT_NAME = project_name
  }

  stage('RPM Build') {
    dir("${ws}/${env.PROJECT_NAME}") {

      def cmd = "zopen-rpmbuild \"${spec_file}\""

      if (source_file) {
        cmd += " --source \"${source_file}\""
      }

      if (buildroot) {
        cmd += " --buildroot \"${buildroot}\""
      }

      if (build_binary) {
        cmd += " --build-binary"
      }

      cmd += " --verbose"

      if (sign_rpm) {
        withCredentials([
          file(credentialsId: gpg_key_cred,  variable: 'ZOPEN_GPG_SECRET_KEY_FILE'),
          file(credentialsId: gpg_pass_cred, variable: 'ZOPEN_GPG_SECRET_KEY_PASSPHRASE_FILE')
        ]) {
          sh """bash -xe -s << 'BASH'
${envSetup}
${cmd} --sign
BASH"""
        }
      } else {
        sh """bash -xe -s << 'BASH'
${envSetup}
${cmd}
BASH"""
      }
    }
  }

  stage('Archive') {
    def rpmDir = buildroot ? "${buildroot}/RPMS" : "${env.HOME}/rpmbuild/RPMS"

    archiveArtifacts artifacts: "${rpmDir}/**/*.rpm",
                     allowEmptyArchive: false,
                     fingerprint: true
  }

}
