// Setup / Bootstrap script for configuring Pulp Repository GPG keys.
// Runs on-demand when bootstrap/rotation is required.

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
          PULP_REPO="zopen"

          # Verify pulp CLI is installed
          if ! command -v pulp >/dev/null 2>&1; then
            if command -v pip3 >/dev/null 2>&1; then
              python3 -m pip install --user pulp-cli || true
              export PATH="\$HOME/.local/bin:\$PATH"
            fi
          fi

          if command -v pulp >/dev/null 2>&1; then
            pulp config create --base-url "\${PULP_HOST}" --username "\${PULP_USERNAME}" --password "\${PULP_PASSWORD}" --overwrite
            pulp status || { echo "ERROR: Pulp connection failed"; exit 1; }
          else
            echo "ERROR: Pulp CLI is not available. Aborting setup run." >&2
            exit 1
          fi

          # 1. Create/Update GPG Keys File Repo
          echo "--- Setting up Pulp GPG keys file repository ---"
          pulp file repository update --name "keys" --autopublish || \
          pulp file repository create --name "keys" --autopublish

          pulp file distribution update --name "keys" --repository "keys" || \
          pulp file distribution create --name "keys" --base-path "keys" --repository "keys"

          pulp file content upload --relative-path "zopen.pub" --file "\${ZOPEN_GPG_PUBLIC_KEY_FILE}" --repository "keys"

          # 2. Setup/Bootstrap RPM Repository & Distribution
          echo "--- Setting up RPM Repository & Distribution ---"
          pulp rpm repository update --name "\${PULP_REPO}" --autopublish || \
          pulp rpm repository create --name "\${PULP_REPO}" --autopublish

          pulp rpm distribution update --name "\${PULP_REPO}" --repository "\${PULP_REPO}" || \
          pulp rpm distribution create --name "\${PULP_REPO}" --base-path "\${PULP_REPO}" --repository "\${PULP_REPO}"

          # 3. Configure RPM Repository GPG Settings
          echo "--- Configuring GPG settings on RPM repository ---"
          DESIRED_KEY="\${PULP_HOST}/pulp/content/keys/zopen.pub"
          
          # Configure GPG on the repository
          pulp rpm repository update --name "\${PULP_REPO}" --repo-config "{\\\"gpgcheck\\\": 1, \\\"gpgkey\\\": \\\"\${DESIRED_KEY}\\\"}" --autopublish

          # Update the distribution to track the repository directly and enable repo-config generation
          # This allows automatic publishing to update the distribution immediately on package upload.
          pulp rpm distribution update --name "\${PULP_REPO}" --publication "" --repository "\${PULP_REPO}" --generate-repo-config
          
          echo "Pulp repository setup and GPG configuration complete."
        """
      }
    }
  } finally {
    deleteDir()
  }
}
