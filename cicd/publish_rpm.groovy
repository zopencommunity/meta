// Inputs:
//   BUILD_SELECTOR        : Jenkins build selector XML to copy artifacts from the build job
//   PROMOTED_JOB_NAME     : Name of the job to copy artifacts from (default: RPM-Build)

def build_selector    = params.BUILD_SELECTOR       ?: ""
def promoted_job_name = params.PROMOTED_JOB_NAME     ?: "RPM-Build"

node('linux') {
  try {
  def ws = env.WORKSPACE
  
  stage('Setup') {
    deleteDir()
    checkout scm

      // Determine the build selector. Supports Copy Artifact XML string from parameter widget, raw build numbers, or lastSuccessful fallback.
      def selectorObj
      if (build_selector) {
        if (build_selector.contains('SpecificBuildSelector')) {
          // Extract build number from XML: <buildNumber>123</buildNumber>
          def matcher = (build_selector =~ /<buildNumber>(.*?)<\/buildNumber>/)
          if (matcher.find()) {
            selectorObj = specific(matcher.group(1))
          } else {
            selectorObj = lastSuccessful()
          }
        } else if (build_selector.contains('StatusBuildSelector')) {
          selectorObj = lastSuccessful()
        } else if (build_selector == 'latest' || build_selector == 'lastSuccessful') {
          selectorObj = lastSuccessful()
        } else {
          selectorObj = specific(build_selector)
        }
      } else {
        selectorObj = lastSuccessful()
      }

    copyArtifacts filter: 'rpms/**/*.rpm',
                  fingerprintArtifacts: true,
                  projectName: promoted_job_name,
                  selector: selectorObj

    // Verify we actually have RPMs to publish (excluding source RPMs)
    def numRpms = sh(script: 'find rpms/ -name "*.rpm" ! -name "*.src.rpm" | wc -l', returnStdout: true).trim().toInteger()
    if (numRpms == 0) {
      error "No binary RPM files found to publish in the copied artifacts (rpms/)"
    }
    
    echo "Found ${numRpms} RPMs to publish."
  }

  stage('Pulp Upload') {
    withCredentials([
      string(credentialsId: 'PULP_USERNAME', variable: 'PULP_USERNAME'),
      string(credentialsId: 'PULP_PASSWORD', variable: 'PULP_PASSWORD')
    ]) {
      sh """#!/bin/bash
        set -euo pipefail

        # Locate RPM files
        RPM_FILES=()
        while IFS= read -r -d '' f; do
          RPM_FILES+=("\$f")
        done < <(find rpms/ -name "*.rpm" ! -name "*.src.rpm" -type f -print0 2>/dev/null)

        NUM_RPMS=\${#RPM_FILES[@]}
        PULP_HOST="https://repo.zopen.community"
        PULP_REPO="zopen"

        # Verify pulp CLI is installed
        if ! command -v pulp >/dev/null 2>&1; then
          if command -v pip3 >/dev/null 2>&1; then
            python3 -m pip install --user pulp-cli || true
            export PATH="\$HOME/.local/bin:\$PATH"
          fi
        fi

        if command -v pulp >/dev/null 2>&1; then
          pulp config create \
            --base-url "\${PULP_HOST}" \
            --username "\${PULP_USERNAME}" \
            --password "\${PULP_PASSWORD}" \
            --overwrite

          pulp status || { echo "ERROR: Pulp connection failed"; exit 1; }

          echo "--- Configuring Pulp Pipeline ---"
          pulp rpm repository update --name "\${PULP_REPO}" --autopublish
          pulp rpm distribution update --name "\${PULP_REPO}" --repository "\${PULP_REPO}"

          echo "Uploading \${NUM_RPMS} RPMs to Pulp repo: \${PULP_REPO}"
          for RPM in "\${RPM_FILES[@]}"; do
            RPM_NAME=\$(basename "\$RPM")
            for attempt in 1 2 3; do
              if pulp rpm content upload --file "\$RPM" --repository "\${PULP_REPO}"; then
                echo "SUCCESS: \$RPM_NAME"
                break
              fi
              if [ "\$attempt" -eq 3 ]; then
                echo "ERROR: Failed to upload \$RPM_NAME to Pulp after 3 attempts."
                exit 1
              else
                sleep 5
              fi
            done
          done
        else
          echo "ERROR: Pulp CLI is not available. Aborting publish run." >&2
          exit 1
        fi
      """
    }
  }
  } finally {
    deleteDir()
  }
}
