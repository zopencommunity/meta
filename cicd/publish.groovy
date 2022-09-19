# Publish Job : https://128.168.139.253:8443/view/Framework/job/Port-Publish/
# This publish job will a pax.Z artifact from the Port-Build (https://128.168.139.253:8443/view/Framework/job/Port-Build/)
# Inputs: 
#   - PORT_GITHUB_REPO :  Github repoistory to publish the artifact to e.g: https://github.com/ZOSOpenTools/xzport.git
#   - PORT_DESCRIPTION : Description of the tool that is presented in the Github release page
#  zos.pax.Z artifact is copied as input
#  requires a GITHUB_TOKEN environment variable (already configured in Jenkins)
# Output:
#   - pax.Z artifact is published as a Jenkins artifact
#   - package is copied to /jenkins/build
GITHUB_ORGANIZATION="ZOSOpenTools"

RELEASE_PREFIX=$(basename "${PORT_GITHUB_REPO}")
# Used for Release/Tag name
RELEASE_PREFIX=${RELEASE_PREFIX%%.*}
# Get the REPO name
GITHUB_REPO=$RELEASE_PREFIX

# PAX file should be a copied artifact
PAX=`find . -name "*zos.pax.Z"`
BUILD_STATUS=`find . -name "test.status" | xargs cat`

if [ ! -f "$PAX" ]; then
  echo "Port pax file does not exist";
  exit 1;
fi

PAX_BASENAME=$(basename "${PAX}")
DIR_NAME=${PAX_BASENAME%%.pax.Z}
BUILD_ID=${BUILD_NUMBER}

# Needed for uploading releases
unset http_proxy
unset https_proxy

DESCRIPTION="${PORT_DESCRIPTION}"
DESCRIPTION="${DESCRIPTION}<br /><b>Test Status:</b> ${BUILD_STATUS}"

URL_LINE="https://github.com/ZOSOpenTools/${GITHUB_REPO}/releases/download/${GITHUB_REPO}_${BUILD_ID}/$PAX_BASENAME"
DESCRIPTION="${DESCRIPTION}<br /><b>Command to download and install on z/OS:</b> <pre>pax -rf <(curl -o - -L ${URL_LINE}) && cd $DIR_NAME && . ./.env</pre>"

exists=$(github-release info -u ${GITHUB_ORGANIZATION} -r ${GITHUB_REPO}  -j)
if [ $? -gt 0 ]; then
  echo "Creating a new release in github"
  github-release -v release --user ${GITHUB_ORGANIZATION} --repo ${GITHUB_REPO} --name "z/OS Release"
fi

exists=$(github-release info -u ${GITHUB_ORGANIZATION} -r ${GITHUB_REPO} --tag "${RELEASE_PREFIX}_${BUILD_ID}" -j)
if [ $? -gt 0 ]; then
  echo "Creating a new tag in github"
  github-release -v release --user ${GITHUB_ORGANIZATION} --repo ${GITHUB_REPO} --tag "${RELEASE_PREFIX}_${BUILD_ID}" --name "${RELEASE_PREFIX} (Build ${BUILD_ID})" --description "${DESCRIPTION}"
else
  echo "Deleting and creating new tag"
  github-release -v delete --user ${GITHUB_ORGANIZATION} --repo ${GITHUB_REPO} --tag "${RELEASE_PREFIX}_${BUILD_ID}"
  github-release -v release --user ${GITHUB_ORGANIZATION} --repo ${GITHUB_REPO} --tag "${RELEASE_PREFIX}_${BUILD_ID}" --name "${RELEASE_PREFIX} (Build ${BUILD_ID})" --description "${DESCRIPTION}"

fi

sleep 10 # Let github register the release

echo "Release should now exist"
github-release info -u ${GITHUB_ORGANIZATION} -r ${GITHUB_REPO} --tag "${RELEASE_PREFIX}_${BUILD_ID}" -j

echo "Uploading the artifacts into github"
github-release -v upload --user ${GITHUB_ORGANIZATION} --repo ${GITHUB_REPO} --tag "${RELEASE_PREFIX}_${BUILD_ID}" --name "${PAX_BASENAME}" --file "${PAX}"
