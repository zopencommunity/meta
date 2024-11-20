# Build Job : https://cicd.zopen.community/view/Framework/job/Port-Build/
# This build job will build a https://github.com/zopencommunity/meta compatible project and archive the pax.Z artifact
# This job is configured to clone the meta repo at the outset into the current working directory.
# This job must run on the z/OS zot system
# Inputs: 
#   - PORT_GITHUB_REPO : e.g: https://github.com/zopencommunity/makeport.git
#   - PORT_BRANCH : (default: main)
#   - BUILD_LINE: dev or stable
#   - FORCE_CLANG : Build using clang
# Output:
#   - pax.Z artifact is published as a Jenkins artifact
#   - package is copied to /jenkins/build on z/OS zot system

# Jenkins cannot interpret colours
export NO_COLOR=1

# Tell zopen that we're a CI/CD bot
export ZOPEN_IS_BOT=1 

# Use 819 as the ccsid for UTF8 files
export GIT_UTF8_CCSID=819

# source Jenkins environment variables on zot
. /jenkins/.env

set -e # Fail on error
set -x # Display verbose output

# Upgrade meta if updates are available
zopen upgrade meta -y

# Add cloned meta dir to PATH
export PATH="$PWD/bin:$PATH"
rm -rf packages # Remove packages pax.Z files

# Get port name based on git repo
PORT_NAME=$(basename "${PORT_GITHUB_REPO}")
PORT_NAME=${PORT_NAME%%.*}
PORT_NAME=${PORT_NAME%%port}

# Set TMPDIR to a local tmp directory
export TMPDIR="${PWD}/tmp"
mkdir -p "${TMPDIR}"

extraOptions=""
if $FORCE_CLANG; then
  extraOptions="--comp clang"
fi
if [ ! -z "$BUILD_LINE" ]; then
  extraOptions="$extraOptions --build $BUILD_LINE"
fi

if [ ! -z "$BUILD_BRANCH" ]; then
  export ZOPEN_GIT_BRANCH="$BUILD_BRANCH"
fi
git clone -b "${PORT_BRANCH}" "${PORT_GITHUB_REPO}" ${PORT_NAME} && cd ${PORT_NAME}

# Always run tests and update dependencies and generate pax file
zopen build -v -b release -u -gp -sp --no-set-active $extraOptions

# Clean the cache after build is complete
zopen clean -c -v
