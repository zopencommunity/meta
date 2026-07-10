// Inputs:
//   PORT_GITHUB_REPO        : GitHub repository URL
//   PORT_DESCRIPTION        : Project description
//   BUILD_LINE              : dev or stable line (default: dev/stable from metadata.json)
//   NODE_LABEL              : Label of the Jenkins node to run on (default: linux)
//   BUILD_SELECTOR          : Selector for copying artifacts from Port-Build
//   GITHUB_TOKEN_CREDENTIAL : ID of the GitHub Token credential in Jenkins (default: GITHUB_TOKEN)
//   PROMOTED_JOB_NAME       : Name of the job to copy artifacts from (default: Port-Build)

def port_github_repo   = params.PORT_GITHUB_REPO   ?: ""
def port_description   = params.PORT_DESCRIPTION   ?: ""
def build_line         = params.BUILD_LINE         ?: ""
def node_label         = params.NODE_LABEL         ?: "linux"
def github_token_cred  = params.GITHUB_TOKEN_CREDENTIAL ?: "GITHUB_TOKEN3"
def promoted_job_name  = params.PROMOTED_JOB_NAME  ?: "Port-Build"
def build_selector     = params.BUILD_SELECTOR     ?: ""

node(node_label) {
  stage('Publish') {
    if (!port_github_repo) {
      error "PORT_GITHUB_REPO is required"
    }

    deleteDir()
    checkout scm

    // Determine the build selector. Supports Copy Artifact XML string, raw build numbers, or lastSuccessful fallback.
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

    // Copy artifacts from Port-Build using the resolved selectorObj
    copyArtifacts filter: '**/*.pax.Z,**/metadata.json,**/test.status,**/.builddeps,**/.version,**/.runtimedeps',
                  projectName: promoted_job_name,
                  selector: selectorObj,
                  optional: false

    withCredentials([string(credentialsId: github_token_cred, variable: 'GITHUB_TOKEN')]) {
      withEnv([
        "PORT_GITHUB_REPO=${port_github_repo}",
        "PORT_DESCRIPTION=${port_description}",
        "BUILD_LINE=${build_line}"
      ]) {
        sh '''#!/bin/bash
set -euo pipefail

echo "=== STARTING PUBLISH JOB ==="

# --- REQUIRED ENV ---
: "${PORT_GITHUB_REPO:?Missing PORT_GITHUB_REPO}"
: "${PORT_DESCRIPTION:?Missing PORT_DESCRIPTION}"
: "${BUILD_NUMBER:?Missing BUILD_NUMBER}"
: "${GITHUB_TOKEN:?Missing GITHUB_TOKEN}"

# --- STATIC CONFIG ---
GITHUB_ORGANIZATION="zopencommunity"
RELEASE_NOTES_SCRIPT="tools/create_release_notes.sh"

# --- DERIVE VALUES ---
RELEASE_PREFIX=$(basename "${PORT_GITHUB_REPO}")
RELEASE_PREFIX=${RELEASE_PREFIX%%.*}
PORT_NAME=$(echo "$RELEASE_PREFIX" | sed 's/port$//')
GITHUB_REPO=$RELEASE_PREFIX

# --- FIND FILES ---
PAX=$(find . -path "*/install/*.zos.pax.Z" -type f | head -n 1)
METADATA=$(find . -path "*/install/metadata.json" -type f | head -n 1)

[ -f "$PAX" ] || { echo "ERROR: Missing PAX file"; exit 1; }
[ -f "$METADATA" ] || { echo "ERROR: Missing metadata.json"; exit 1; }

# --- RESOLVE BUILD LINE ---
if [ -z "${BUILD_LINE:-}" ] || [ "$BUILD_LINE" = "null" ]; then
  METADATA_BUILD_LINE=$(python3 -c "import json; print(json.load(open('$METADATA'))['product'].get('buildline', ''))" 2>/dev/null || echo "")
  if [ -n "$METADATA_BUILD_LINE" ] && [ "$METADATA_BUILD_LINE" != "null" ]; then
    BUILD_LINE=$(echo "$METADATA_BUILD_LINE" | tr '[:lower:]' '[:upper:]')
    echo "Using BUILD_LINE from metadata.json: $BUILD_LINE"
  else
    BUILD_LINE="DEV"
    echo "BUILD_LINE not found in environment or metadata.json. Defaulting to: $BUILD_LINE"
  fi
fi

# --- INFO ---
BUILD_STATUS=$(find . -path "*/install/test.status" -exec cat {} + 2>/dev/null || echo "Unknown")
RUNTIME_DEPS=$(find . -path "*/install/.runtimedeps" -exec cat {} + 2>/dev/null || echo "None")
BUILD_DEPS=$(find . -path "*/install/.builddeps" -exec cat {} + 2>/dev/null || echo "None")
VERSION=$(find . -path "*/install/.version" -exec cat {} + 2>/dev/null || echo "unknown")

unset http_proxy https_proxy

PAX_BASENAME=$(basename "$PAX")
DIR_NAME=${PAX_BASENAME%%.pax.Z}
DIR_NAME=$(echo "$DIR_NAME" | sed -e "s/\\.202[0-9]*_[0-9]*\\.zos/.zos/g" -e "s/\\.zos//g")
TAG="${BUILD_LINE}_${RELEASE_PREFIX}_${BUILD_NUMBER}"
NAME="${PORT_NAME} ${VERSION} (Build ${BUILD_NUMBER}) - (${BUILD_LINE})"

# --- RELEASE NOTES ---
if [ -f "$RELEASE_NOTES_SCRIPT" ]; then
  RELEASE_NOTES=$("$RELEASE_NOTES_SCRIPT" -m release -p "$GITHUB_REPO" -t markdown || echo "No notes")
else
  RELEASE_NOTES="No release notes"
fi

echo "$RELEASE_NOTES" > CHANGELOG.md

DESCRIPTION="${PORT_DESCRIPTION}<br/>"
DESCRIPTION+="<b>Version:</b> ${VERSION}<br/>"
DESCRIPTION+="<b>Test Status:</b> ${BUILD_STATUS}<br/>"
DESCRIPTION+="<b>Runtime Dependencies:</b> ${RUNTIME_DEPS}<br/>"
DESCRIPTION+="<b>Build Dependencies:</b> ${BUILD_DEPS}<br/>"
URL_LINE="https://github.com/${GITHUB_ORGANIZATION}/${GITHUB_REPO}/releases/download/${TAG}/${PAX_BASENAME}"
DESCRIPTION+="<br/><b>Command to download and install on z/OS (if you have curl)</b> <pre>curl -o ${PAX_BASENAME} -L ${URL_LINE} && pax -rf ${PAX_BASENAME} && cd ${DIR_NAME} && . ./setup.sh</pre>"
DESCRIPTION+="<br/><b>Or use:</b> <pre>zopen install ${PORT_NAME}</pre>"
DESCRIPTION+=$'\n\n'"$RELEASE_NOTES"

# --- TOOL CHECK ---
command -v github-release >/dev/null || { echo "ERROR: github-release not installed"; exit 1; }

# --- CREATE / RECREATE RELEASE ---
if github-release info -u "$GITHUB_ORGANIZATION" -r "$GITHUB_REPO" --tag "$TAG" -j &>/dev/null; then
  github-release delete --user "$GITHUB_ORGANIZATION" --repo "$GITHUB_REPO" --tag "$TAG"
fi

github-release release \
  --user "$GITHUB_ORGANIZATION" \
  --repo "$GITHUB_REPO" \
  --tag "$TAG" \
  --name "$NAME" \
  --description "$DESCRIPTION"

echo "Waiting for GitHub to process release..."
sleep 5

# --- VALIDATE RELEASE (FIXES YOUR ERROR) ---
github-release info \
  -u "$GITHUB_ORGANIZATION" \
  -r "$GITHUB_REPO" \
  --tag "$TAG" || {
    echo "ERROR: Release creation failed"
    exit 1
}

# --- UPLOAD TO GITHUB RELEASES ---
github-release upload \
  --user "$GITHUB_ORGANIZATION" \
  --repo "$GITHUB_REPO" \
  --tag "$TAG" \
  --name "$PAX_BASENAME" \
  --file "$PAX"

github-release upload \
  --user "$GITHUB_ORGANIZATION" \
  --repo "$GITHUB_REPO" \
  --tag "$TAG" \
  --name "metadata.json" \
  --file "$METADATA"

github-release upload \
  --user "$GITHUB_ORGANIZATION" \
  --repo "$GITHUB_REPO" \
  --tag "$TAG" \
  --name "CHANGELOG.md" \
  --file "CHANGELOG.md"

echo "=== SUCCESS: PUBLISH COMPLETED ==="
'''
      }
    }
  }
}
