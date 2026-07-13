// Setup / Bootstrap script for configuring Pulp Repository GPG keys.
// Runs on-demand when bootstrap/rotation is required.

def pulp_repo = params.PULP_REPO ?: "zopen"

node('linux') {
  try {
    stage('Pulp Repo Setup') {
      withCredentials([
        string(credentialsId: 'PULP_USERNAME', variable: 'PULP_USERNAME'),
        string(credentialsId: 'PULP_PASSWORD', variable: 'PULP_PASSWORD'),
        file(credentialsId: 'ZOPEN_GPG_PUBLIC_KEY_FILE', variable: 'ZOPEN_GPG_PUBLIC_KEY_FILE')
      ]) {
        sh """#!/bin/bash
          set -euo pipefail
          
          PULP_HOST="https://repo.zopen.community"
          PULP_REPO="${pulp_repo}"

          # Verify pulp CLI is installed
          if ! command -v pulp >/dev/null 2>&1; then
            if command -v pip3 >/dev/null 2>&1; then
              python3 -m pip install --user pulp-cli || true
              export PATH="\$HOME/.local/bin:\$PATH"
            fi
          fi

          pulp config create \
            --base-url "\${PULP_HOST}" \
            --username "\${PULP_USERNAME}" \
            --password "\${PULP_PASSWORD}" \
            --overwrite

          pulp status || { echo "ERROR: Pulp connection failed"; exit 1; }

          # 1. Setup GPG Keys File Repository & Distribution
          echo "--- Setting up Pulp GPG keys file repository ---"
          pulp file repository update --name "keys" --autopublish || \
          pulp file repository create --name "keys" --autopublish

          pulp file distribution update --name "keys" --repository "keys" || \
          pulp file distribution create --name "keys" --base-path "keys" --repository "keys"

          # Upload GPG public key
          pulp file content upload --file "\${ZOPEN_GPG_PUBLIC_KEY_FILE}" --repository "keys" --relative-path "zopen.pub"

          # 2. Setup/Bootstrap RPM Repository & Distribution
          echo "--- Setting up RPM Repository & Distribution ---"
          pulp rpm repository update --name "\${PULP_REPO}" --no-autopublish || \
          pulp rpm repository create --name "\${PULP_REPO}" --no-autopublish

          # Generate initial publication (with no compression) using the REST API directly
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

          # Re-create distribution to point to the uncompressed publication and generate repo config
          pulp rpm distribution destroy --name "\${PULP_REPO}" || true
          pulp rpm distribution create --name "\${PULP_REPO}" --base-path "\${PULP_REPO}" --publication "\${PUB_HREF}" --generate-repo-config

          # 3. Configure RPM Repository GPG Settings
          echo "--- Configuring GPG settings on RPM repository ---"
          DESIRED_KEY="\${PULP_HOST}/pulp/content/keys/zopen.pub"
          
          # Configure GPG on the repository
          pulp rpm repository update --name "\${PULP_REPO}" --repo-config "{\\\"gpgcheck\\\": 1, \\\"gpgkey\\\": \\\"\${DESIRED_KEY}\\\"}" --no-autopublish
          
          echo "Pulp repository setup and GPG configuration complete."
        """
      }
    }
  } finally {
    deleteDir()
  }
}
