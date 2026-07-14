// Build Job : https://cicd.zopen.community/view/Framework/job/Port-Build/
// This build job will build a https://github.com/zopencommunity/meta compatible project and archive the pax.Z artifact
// This job is configured to clone the meta repo at the outset into the current working directory.
// This job must run on the z/OS zot system
// Inputs: 
//   - PORT_GITHUB_REPO : e.g: https://github.com/zopencommunity/makeport.git
//   - PORT_BRANCH : (default: main)
//   - PORT_SOURCE_URL : optional alternate source URL passed through to zopen-build as ZOPEN_SOURCE_URL
//   - BUILD_LINE: dev or stable
//   - FORCE_CLANG : Build using clang
//   - GENERATE_PAX_RPM : (default: true) Generate pax and RPM packages. Set to false to skip -gr -sp options
//   - NODE_LABEL: Label of the Jenkins node to run on (default: zos)
// Output:
//   - pax.Z artifact is published as a Jenkins artifact
//   - package is copied to /jenkins/build on z/OS zot system

def port_github_repo = params.PORT_GITHUB_REPO ?: ""
def port_branch      = params.PORT_BRANCH      ?: "main"
def port_source_url  = params.PORT_SOURCE_URL  ?: ""
def build_line       = params.BUILD_LINE       ?: ""
def force_clang      = params.FORCE_CLANG != null ? params.FORCE_CLANG : false
def generate_pax_rpm = params.GENERATE_PAX_RPM != null ? params.GENERATE_PAX_RPM : true
def skip_test        = params.SKIP_TEST != null ? params.SKIP_TEST : false
def node_label       = params.node ?: (params.NODE_LABEL ?: "zos")

node(node_label) {
  def ws = env.WORKSPACE

  stage('Build Project') {
    if (!port_github_repo) {
      error "PORT_GITHUB_REPO is required"
    }
    def port_name = port_github_repo.tokenize('/').last().replaceAll('\\.git$', '')

    // Determine SCM branch fallback dynamically from the SCM definition
    def scmBranch = "main"
    if (scm && scm.branches && scm.branches.size() > 0) {
      scmBranch = scm.branches[0].name.replaceAll('\\*\\/', '').replaceAll('refs/heads/', '').replaceAll('origin/', '')
    }

    // Determine build options
    def extraOptions = ""
    if (force_clang) {
      extraOptions += " --comp clang"
    }
    if (build_line) {
      extraOptions += " --build ${build_line}"
    }

    def paxRpmOptions = "-gp -sp -gr -sr"
    if (!generate_pax_rpm) {
      paxRpmOptions = ""
    }

    def testOption = skip_test ? "-sc" : ""

    deleteDir()

    def gpgBindings = [
      file(credentialsId: 'ZOPEN_GPG_PUBLIC_KEY_FILE', variable: 'ZOPEN_GPG_PUBLIC_KEY_FILE'),
      file(credentialsId: 'ZOPEN_GPG_SECRET_KEY_FILE', variable: 'ZOPEN_GPG_SECRET_KEY_FILE'),
      file(credentialsId: 'ZOPEN_GPG_SECRET_KEY_PASSPHRASE_FILE', variable: 'ZOPEN_GPG_SECRET_KEY_PASSPHRASE_FILE')
    ]

    try {
      withCredentials(gpgBindings) {
        withEnv([
          "PORT_NAME=${port_name}",
          "PORT_BRANCH=${port_branch}",
          "PORT_GITHUB_REPO=${port_github_repo}",
          "BUILD_BRANCH=${params.BUILD_BRANCH ?: ''}",
          "META_BRANCH=${scmBranch}",
          "PORT_SOURCE_URL=${port_source_url}",
          "EXTRA_OPTIONS=${extraOptions}",
          "PAX_RPM_OPTIONS=${paxRpmOptions}",
          "TEST_OPTION=${testOption}"
        ]) {
          sh '''bash -e -s << \'BASH\'
            set +e
            . /jenkins/.env
            set -e
            export NO_COLOR=1
            export ZOPEN_IS_BOT=1
            export GIT_UTF8_CCSID=819
            export TMPDIR="${WORKSPACE}/tmp"
            mkdir -p "$TMPDIR"

            git init
            git remote add origin https://github.com/zopencommunity/meta.git
            git fetch --tags --force --depth=1 origin "${META_BRANCH}:refs/remotes/origin/${META_BRANCH}"
            git checkout -f "origin/${META_BRANCH}"

            export PATH="${WORKSPACE}/bin:$PATH"

            if [ ! -z "${BUILD_BRANCH}" ]; then
              export ZOPEN_GIT_BRANCH="${BUILD_BRANCH}"
            fi
            if [ ! -z "${PORT_SOURCE_URL}" ]; then
              export ZOPEN_SOURCE_URL="${PORT_SOURCE_URL}"
            fi


            # Clone and build
            git clone -b "${PORT_BRANCH}" "${PORT_GITHUB_REPO}" "${PORT_NAME}"
            cd "${PORT_NAME}"

            # Run build using the workspace version of zopen-build to test PR changes
            zopen-build -v -b release -u ${TEST_OPTION} ${PAX_RPM_OPTIONS} --no-set-active ${EXTRA_OPTIONS}

            # Clean using the workspace version of zopen-clean
            zopen-clean -c -v

            # Copy built RPMs to workspace for archiving
            if [ -d "rpmbuild/RPMS" ] && [ "$(ls -A "rpmbuild/RPMS" 2>/dev/null)" ]; then
              mkdir -p "${WORKSPACE}/rpms"
              cp -R "rpmbuild/RPMS/"* "${WORKSPACE}/rpms/" 2>/dev/null || true
            fi
BASH'''
        }
      }
    } finally {
      try {
        archiveArtifacts artifacts: '**/*.pax.Z,**/*.pax.Z.asc,**/*.rpm,**/metadata.json,**/*_config.log,**/*_build.log,**/*_check.log,**/*_install.log, **/test.status, **/*_check_failures.log, **/.builddeps, **/.version, **/.runtimedeps',
                         allowEmptyArchive: true,
                         fingerprint: true
      } finally {
        deleteDir()
      }
    }
  }
}
