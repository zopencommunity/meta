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

// Derived from the upload URL so an overridden PULP_URL keeps everything on one
// server. The remote is the PyPI pull-through shared by both build lines; the
// reconcile step is a no-op when it does not exist, so a server without the
// proxy configured is unaffected.
def pulp_host   = pulp_url.replaceFirst(/\/pypi\/.*$/, '')
def pulp_api    = params.PULP_API ?: "${pulp_host}/pulp/api/v3"
def pulp_remote = params.PULP_REMOTE ?: 'pypi-proxy'

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
        withEnv(["PULP_URL=${pulp_url}",
                 "PULP_API=${pulp_api}",
                 "PULP_REMOTE=${pulp_remote}"]) {
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
  wheel_name=$(basename "$wheel")

  # Retry transient upload failures, matching the RPM publish job. zopen-publish
  # is safe to re-run: it re-checks the index and treats an identical wheel as a
  # no-op. Exit 2 means the failure is deterministic, so stop immediately.
  #
  # --on-conflict build-tag: a rebuild of an already published version must not
  # fail the pipeline. zopen-publish compares the two wheels by content, so a
  # wheel that differs only in generated metadata is reported as already
  # published; anything that really changed is reuploaded under the next build
  # tag, which pip prefers. Nothing already in the index is ever replaced. A
  # build tag claimed concurrently comes back as exit 1, so the retry below
  # picks the next one.
  attempt=1
  max_attempts=3
  while :; do
    set +e
    ZOPEN_DONT_PROCESS_CONFIG=1 \
      "$publisher" --whl "$wheel" --pulp-url "$PULP_URL" --on-conflict build-tag
    publish_rc=$?
    set -e

    if [ "$publish_rc" -eq 0 ]; then
      break
    fi

    if [ "$publish_rc" -eq 2 ]; then
      echo "ERROR: ${wheel_name} cannot be published; retrying would not help." >&2
      exit 1
    fi

    if [ "$attempt" -ge "$max_attempts" ]; then
      echo "ERROR: failed to publish ${wheel_name} after ${max_attempts} attempts." >&2
      exit 1
    fi

    echo "Publish of ${wheel_name} failed (attempt ${attempt}/${max_attempts}); retrying in 5s."
    attempt=$((attempt + 1))
    sleep 5
  done
done < <(find wheels -type f -name '*.whl' -print0)
'''

        // Keep the PyPI pull-through from shadowing what we just published.
        //
        // The proxy distribution merges upstream PyPI into the index, and pip
        // resolves by version across the merged view. Left alone, PyPI's newer
        // release of a package we build here wins -- and for a compiled port
        // that resolves to an sdist which cannot be built on z/OS. Excluding a
        // name from the remote makes our copy the only one pip can see.
        //
        // Derived from what was actually published rather than kept by hand,
        // because a hand-maintained list is only discovered to be stale when
        // somebody's install starts compiling from source.
        sh '''#!/bin/bash
set -euo pipefail
python3 - "$PULP_API" "$PULP_REMOTE" <<'PY'
import json, os, sys, urllib.request, base64, pathlib, re
from urllib.parse import urljoin, urlsplit

api, remote_name = sys.argv[1], sys.argv[2]
# pulp_href comes back as a site-absolute path, not a full URL, so PATCHing it
# directly fails with "unknown url type". Keep the scheme and host to rejoin it.
origin = "{0.scheme}://{0.netloc}".format(urlsplit(api))
user, password = os.environ["PULP_USER"], os.environ["PULP_PASSWORD"]
auth = base64.b64encode(f"{user}:{password}".encode()).decode()

def call(url, method="GET", body=None):
    req = urllib.request.Request(url, method=method)
    req.add_header("Authorization", f"Basic {auth}")
    if body is not None:
        req.add_header("Content-Type", "application/json")
        body = json.dumps(body).encode()
    with urllib.request.urlopen(req, body, timeout=60) as r:
        return json.load(r) if r.status != 204 else None

# PEP 503 normalisation: the index compares normalised names, so "pydantic_core"
# and "Pydantic-Core" must both land on "pydantic-core" or the exclude misses.
def normalize(n):
    return re.sub(r"[-_.]+", "-", n).lower()

published = {normalize(p.name.split("-")[0])
             for p in pathlib.Path("wheels").glob("*.whl")}
if not published:
    print("no wheels published; nothing to reconcile")
    sys.exit(0)

found = call(f"{api}/remotes/python/python/?name={remote_name}")
if not found["results"]:
    print(f"remote '{remote_name}' does not exist; skipping "
          "(the pull-through proxy is not configured on this server)")
    sys.exit(0)
remote = found["results"][0]
current = list(remote.get("excludes") or [])

# Entries carrying a version specifier are deliberate caps on third-party
# packages (e.g. "mcp>=1.20.0" avoids a dependency that needs Rust). They are
# not derivable from what we publish, so preserve them untouched.
pinned = [e for e in current if re.search(r"[<>=!~]", e)]
names = {normalize(e) for e in current if e not in pinned}

missing = published - names
if not missing:
    print(f"excludes already cover: {sorted(published)}")
    sys.exit(0)

updated = sorted(names | published) + pinned
call(urljoin(origin, remote["pulp_href"]), method="PATCH", body={"excludes": updated})
print(f"added to excludes: {sorted(missing)}")
print(f"excludes now: {updated}")
PY
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

  IFS=$'\t' read -r package_name package_version normalized_name requires_python < <(
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
print(f"{name}\t{version}\t{normalized}\t{metadata.get('Requires-Python') or ''}")
PY
  )

  package_page="${index_url}${normalized_name}/"
  echo "Verifying ${package_name}==${package_version} at ${package_page}"

  # A wheel whose Requires-Python excludes this agent cannot be installed here,
  # and pip reports that as "no matching distribution" -- indistinguishable from
  # a genuinely missing package. Decide up front so a too-old agent does not
  # fail a publish that actually succeeded.
  agent_supported=yes
  if [ -n "$requires_python" ]; then
    agent_supported=$(python3 - "$requires_python" <<'PY'
import sys

spec = sys.argv[1]
version = "%d.%d.%d" % sys.version_info[:3]

SpecifierSet = None
for module in ("packaging.specifiers", "pip._vendor.packaging.specifiers"):
    try:
        SpecifierSet = __import__(module, fromlist=["SpecifierSet"]).SpecifierSet
        break
    except Exception:
        continue

if SpecifierSet is None:
    # Cannot evaluate the specifier; let pip make the call as before.
    print("yes")
else:
    try:
        print("yes" if SpecifierSet(spec).contains(version, prereleases=True) else "no")
    except Exception:
        # Malformed specifier. Say nothing definitive and let pip decide,
        # rather than silently skipping a test that should have run.
        print("yes")
PY
    )
  fi

  # Anything other than a clear "no" means proceed, so an unexpected value
  # cannot quietly route a pure Python wheel down the presence-only path.
  [ "$agent_supported" = no ] || agent_supported=yes

  if [[ "$wheel_name" == *-py3-none-any.whl ]] && [ "$agent_supported" = yes ]; then
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
    if [ "$agent_supported" = no ]; then
      echo "Wheel is present in the public index. Skipping the install test:"
      echo "  it requires Python ${requires_python} and this agent runs $(python3 -c 'import sys; print("%d.%d.%d" % sys.version_info[:3])')."
      echo "  The wheel is fine; upgrade the agent to exercise the install path."
    else
      echo "Platform-specific wheel is present in the public index; install verification is deferred to a compatible node."
    fi
  fi
done < <(find wheels -type f -name '*.whl' -print0)
'''
      }
    }
  } finally {
    deleteDir()
  }
}
