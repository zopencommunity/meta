// Python wheel publish job.
//
// Inputs:
//   BUILD_SELECTOR          : Jenkins build selector XML, build number, or lastSuccessful
//   PROMOTED_JOB_NAME       : Required job from which to copy wheel artifacts
//   BUILD_LINE              : dev or stable; selects the target Pulp repository
//   PULP_URL                : Optional upload URL override (must end in /legacy/)
//   PULP_USER_CREDENTIAL    : Optional Jenkins username credential ID
//   PULP_PASSWORD_CREDENTIAL: Optional Jenkins password credential ID

def build_selector       = params.BUILD_SELECTOR ?: ""
def promoted_job_name    = params.PROMOTED_JOB_NAME
def build_line           = (params.BUILD_LINE ?: "stable").toLowerCase()
def pulp_user_credential = params.PULP_USER_CREDENTIAL ?: "PULP_USERNAME"
def pulp_pass_credential = params.PULP_PASSWORD_CREDENTIAL ?: "PULP_PASSWORD"

if (!promoted_job_name) {
  error "Required parameter 'PROMOTED_JOB_NAME' is missing or empty."
}

if (!(build_line in ['dev', 'stable'])) {
  error "BUILD_LINE must be 'dev' or 'stable', got '${build_line}'."
}

// Dev and stable builds compile the same upstream project at different refs, so
// they routinely produce the same wheel filename with different content (most
// projects only bump their declared version at release time). A PyPI index is
// immutable per filename, so the two lines must never share one: keep the
// filenames truthful and separate the indexes instead.
def pulp_repo = build_line == 'dev' ? 'wheels-dev' : 'wheels'
def pulp_url  = params.PULP_URL ?: "https://repo.zopen.community/pypi/${pulp_repo}/legacy/"

// zopen-publish normalizes several URL spellings for upload, but the public
// index URL below is derived by trimming /legacy/. Reject anything else up
// front rather than uploading successfully and then verifying a bogus URL.
if (!pulp_url.endsWith('/legacy/')) {
  error "PULP_URL must be a Pulp Python legacy upload endpoint ending in '/legacy/', got '${pulp_url}'."
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
      echo "Found ${wheelCount} Python wheel(s) to publish to the '${pulp_repo}' repository (${build_line} line)."
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

# Iterate directly rather than collecting into an array first: under `set -u`
# expanding an empty array is an error on bash < 4.4.
while IFS= read -r -d '' wheel; do
  ZOPEN_DONT_PROCESS_CONFIG=1 \
    "$publisher" --whl "$wheel" --pulp-url "$PULP_URL"
done < <(find wheels -type f -name '*.whl' -print0)
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

# This stage deliberately runs outside withCredentials: it verifies what an
# unauthenticated end user actually sees. Probe the index root first so a
# private/misconfigured distribution fails with a diagnosable message rather
# than an opaque pip resolution error further down.
probe_code=$(curl --silent --show-error --output /dev/null --write-out '%{http_code}' "$index_url" || echo 000)
case "$probe_code" in
  200|301|302)
    ;;
  401|403)
    echo "ERROR: ${index_url} requires authentication (HTTP ${probe_code})." >&2
    echo "       The wheel index is expected to be publicly readable; check the" >&2
    echo "       Pulp distribution's content guard." >&2
    exit 1
    ;;
  *)
    echo "ERROR: ${index_url} is not reachable anonymously (HTTP ${probe_code})." >&2
    exit 1
    ;;
esac

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
