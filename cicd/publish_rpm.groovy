//   BUILD_SELECTOR        : Jenkins build selector XML to copy artifacts from the build job
//   PROMOTED_JOB_NAME     : Required name of the job to copy artifacts from

def build_selector    = params.BUILD_SELECTOR       ?: ""
def promoted_job_name = params.PROMOTED_JOB_NAME

if (!promoted_job_name) {
  error "Required parameter 'PROMOTED_JOB_NAME' is missing or empty. Please specify the job name to copy artifacts from."
}

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
        PULP_HOST="http://163.74.83.190:8080"
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

          echo "Uploading \${NUM_RPMS} RPMs to Pulp repo: \${PULP_REPO}"
          for RPM in "\${RPM_FILES[@]}"; do
            RPM_NAME=\$(basename "\$RPM")
            echo "Uploading \$RPM_NAME..."
            
            # Retry upload up to 3 times in case of transient network errors
            for attempt in {1..3}; do
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

          # 3. Create publication with no metadata compression and update the distribution using the REST API directly
          echo "Generating uncompressed RPM publication..."
          REPO_HREF=\$(pulp rpm repository show --name "\${PULP_REPO}" | jq -r '.pulp_href')
          TASK_HREF=\$(curl -L -s -X POST -u "\${PULP_USERNAME}:\${PULP_PASSWORD}" \
            -H "Content-Type: application/json" \
            -d "{\\\"repository\\\": \\\"\${REPO_HREF}\\\", \\\"compression_type\\\": \\\"none\\\"}" \
            "\${PULP_HOST}/pulp/api/v3/publications/rpm/rpm/" | jq -r '.task')

          # Poll the task status until it completes (timeout: 120 seconds)
          attempt=0
          max_attempts=60
          STATE="unknown"
          while [ "\$attempt" -lt "\$max_attempts" ]; do
            TASK_STATUS=\$(curl -L -s -u "\${PULP_USERNAME}:\${PULP_PASSWORD}" "\${PULP_HOST}\${TASK_HREF}")
            STATE=\$(echo "\$TASK_STATUS" | jq -r '.state')
            if [ "\$STATE" = "completed" ]; then
              PUB_HREF=\$(echo "\$TASK_STATUS" | jq -r '.created_resources[0]')
              break
            elif [ "\$STATE" = "failed" ] || [ "\$STATE" = "canceled" ]; then
              echo "ERROR: Publication task failed: \$(echo "\$TASK_STATUS" | jq -r '.error.description')"
              exit 1
            fi
            attempt=\$((attempt + 1))
            sleep 2
          done

          if [ "\$attempt" -eq "\$max_attempts" ]; then
            echo "ERROR: Publication task timed out after 120 seconds. Last state: \${STATE}"
            exit 1
          fi

          echo "Updating distribution to point to the new uncompressed publication..."
          pulp rpm distribution update --name "\${PULP_REPO}" --publication "\${PUB_HREF}"
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
