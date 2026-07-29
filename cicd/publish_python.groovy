// Python wheel publish job.
//
// Inputs:
//   BUILD_SELECTOR          : Jenkins build selector XML, build number, or lastSuccessful
//   PROMOTED_JOB_NAME       : Required job from which to copy wheel artifacts
//   PULP_URL                : Optional upload URL override
//   PULP_USER_CREDENTIAL    : Optional Jenkins username credential ID
//   PULP_PASSWORD_CREDENTIAL: Optional Jenkins password credential ID

def build_selector       = params.BUILD_SELECTOR ?: ""
def promoted_job_name    = params.PROMOTED_JOB_NAME
def pulp_url             = params.PULP_URL ?: "https://repo.zopen.community/pypi/wheels/legacy/"
def pulp_user_credential = params.PULP_USER_CREDENTIAL ?: "PULP_USERNAME"
def pulp_pass_credential = params.PULP_PASSWORD_CREDENTIAL ?: "PULP_PASSWORD"

if (!promoted_job_name) {
  error "Required parameter 'PROMOTED_JOB_NAME' is missing or empty."
}

node('linux') {
  try {
    stage('Setup') {
      deleteDir()
      checkout scm

      def selectorObj
      if (build_selector) {
        if (build_selector.contains('SpecificBuildSelector')) {
          def matcher = (build_selector =~ /<buildNumber>(.*?)<\/buildNumber>/)
          selectorObj = matcher.find() ? specific(matcher.group(1)) : lastSuccessful()
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

      copyArtifacts filter: 'wheels/**/*.whl',
                    fingerprintArtifacts: true,
                    projectName: promoted_job_name,
                    selector: selectorObj

      def wheelCount = sh(
        script: 'find wheels -type f -name "*.whl" | wc -l',
        returnStdout: true
      ).trim().toInteger()

      if (wheelCount == 0) {
        error "No Python wheels were found in the copied build artifacts."
      }
      echo "Found ${wheelCount} Python wheel(s) to publish."
    }

    stage('Pulp Upload') {
      withCredentials([
        string(credentialsId: pulp_user_credential, variable: 'PULP_USER'),
        string(credentialsId: pulp_pass_credential, variable: 'PULP_PASSWORD')
      ]) {
        withEnv(["PULP_URL=${pulp_url}"]) {
          sh '''#!/bin/bash
set -euo pipefail

if [ -f /jenkins/.env ]; then
  . /jenkins/.env
fi

publisher="${WORKSPACE}/bin/zopen-publish"
if [ ! -x "$publisher" ]; then
  echo "ERROR: zopen-publish is not available at $publisher" >&2
  exit 1
fi

wheel_files=()
while IFS= read -r -d '' wheel; do
  wheel_files+=("$wheel")
done < <(find wheels -type f -name '*.whl' -print0)

for wheel in "${wheel_files[@]}"; do
  ZOPEN_DONT_PROCESS_CONFIG=1 \
    "$publisher" --whl "$wheel" --pulp-url "$PULP_URL"
done
'''
        }
      }
    }

    stage('Public Index Verification') {
      withEnv(["PULP_URL=${pulp_url}"]) {
        sh '''#!/bin/bash
set -euo pipefail

index_url="${PULP_URL%/legacy/}/simple/"
smoke_root="${WORKSPACE}/wheel-smoke"
mkdir -p "$smoke_root"

wheel_number=0
while IFS= read -r -d '' wheel; do
  wheel_number=$((wheel_number + 1))
  wheel_name=$(basename "$wheel")

  IFS=$'\t' read -r package_name package_version normalized_name < <(
    python3 - "$wheel" <<'PY'
import email
import re
import sys
import zipfile

with zipfile.ZipFile(sys.argv[1]) as archive:
    metadata_files = [
        name for name in archive.namelist()
        if name.endswith(".dist-info/METADATA")
    ]
    if len(metadata_files) != 1:
        raise SystemExit("Wheel must contain exactly one .dist-info/METADATA file")
    metadata = email.message_from_bytes(archive.read(metadata_files[0]))

name = metadata.get("Name")
version = metadata.get("Version")
if not name or not version:
    raise SystemExit("Wheel metadata is missing Name or Version")

normalized = re.sub(r"[-_.]+", "-", name).lower()
print(f"{name}\t{version}\t{normalized}")
PY
  )

  package_page="${index_url}${normalized_name}/"
  echo "Verifying ${package_name}==${package_version} at ${package_page}"

  if [[ "$wheel_name" == *-py3-none-any.whl ]]; then
    venv="${smoke_root}/${wheel_number}"
    python3 -m venv "$venv"
    "$venv/bin/pip" install \
      --no-cache-dir \
      --no-deps \
      --index-url "$index_url" \
      "${package_name}==${package_version}"
    "$venv/bin/python" -m pip show "$package_name" >/dev/null
  else
    curl --fail --silent --show-error "$package_page" | grep -F "$wheel_name" >/dev/null
    echo "Platform-specific wheel is present in the public index; install verification is deferred to a compatible node."
  fi
done < <(find wheels -type f -name '*.whl' -print0)
'''
      }
    }
  } finally {
    deleteDir()
  }
}
