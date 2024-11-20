#!/bin/bash
# Publish Job : https://cicd.zopen.community/view/Framework/job/Port-Publish/
# This publish job will a pax.Z artifact from the Port-Build (https://cicd.zopen.community/view/Framework/job/Port-Build/)
# Inputs: 
#   - PORT_GITHUB_REPO :  Github repoistory to publish the artifact to e.g: https://github.com/zopencommunity/xzport.git
#   - PORT_DESCRIPTION : Description of the tool that is presented in the Github release page
#   - BUILD_LINE: dev or stable
#  zos.pax.Z artifact is copied as input
#  requires a GITHUB_TOKEN environment variable (already configured in Jenkins)
# Output:
#   - pax.Z artifact is published as a Jenkins artifact
#   - package is copied to /jenkins/build
GITHUB_ORGANIZATION="zopencommunity"

RELEASE_PREFIX=$(basename "${PORT_GITHUB_REPO}")
# Used for Release/Tag name
RELEASE_PREFIX=${RELEASE_PREFIX%%.*}
PORT_NAME=${RELEASE_PREFIX%%port}
# Get the REPO name
GITHUB_REPO=$RELEASE_PREFIX

# PAX file should be a copied artifact
PAX=`find . -type f -path "*install/*zos.pax.Z"`
BUILD_STATUS=`find . -name "test.status" | xargs cat`
DEPENDENCIES=`find . -name ".runtimedeps" | xargs cat`
BUILD_DEPENDENCIES=`find . -name ".builddeps" | xargs cat`
VERSION=`find . -name "*install/.version" | xargs cat`

if [ ! -f "$PAX" ]; then
  echo "Port pax file does not exist";
  exit 1;
fi

if [ -z "$DEPENDENCIES" ]; then
  DEPENDENCIES="No dependencies";
fi

if [ -z "$BUILD_DEPENDENCIES" ]; then
  BUILD_DEPENDENCIES="No dependencies";
fi

if [ ! -z "$VERSION" ]; then
  VERSION="$VERSION ";
fi

PAX_BASENAME=$(basename "${PAX}")
DIR_NAME=${PAX_BASENAME%%.pax.Z}
DIR_NAME=$(echo "$DIR_NAME" | sed -e "s/\.202[0-9]*_[0-9]*\.zos/.zos/g" -e "s/\.zos//g")
BUILD_ID=${BUILD_NUMBER}

# Check for python dependencies
if pip3 show numpy &> /dev/null; then
    echo "NumPy is already installed."
else
    echo "NumPy is not installed. Installing now..."
    pip3 install numpy
fi

if pip3 show PyGithub &> /dev/null; then
    echo "PyGithub is already installed."
else
    echo "PyGithub is not installed. Installing now..."
    pip3 install PyGithub
fi

if pip3 show matplotlib &> /dev/null; then
    echo "matplotlib is already installed."
else
    echo "matplotlib is not installed. Installing now..."
    pip3 install matplotlib
fi

# Needed for uploading releases
unset http_proxy
unset https_proxy

DESCRIPTION="${PORT_DESCRIPTION}"
DESCRIPTION="${DESCRIPTION}<br /><b>Test Status:</b> ${BUILD_STATUS}<br />"
DESCRIPTION="${DESCRIPTION}<b>Runtime Dependencies:</b> ${DEPENDENCIES}<br />"
DESCRIPTION="${DESCRIPTION}<b>Build Dependencies:</b> ${BUILD_DEPENDENCIES}<br />"

if [ -z "$BUILD_LINE" ]; then
  BUILD_LINE="STABLE"
fi

TAG="${BUILD_LINE}_${RELEASE_PREFIX}_${BUILD_ID}"

URL_LINE="https://github.com/zopencommunity/${GITHUB_REPO}/releases/download/${TAG}/$PAX_BASENAME"
DESCRIPTION="${DESCRIPTION}<br /><b>Command to download and install on z/OS (if you have curl)</b> <pre>curl -o ${PAX_BASENAME} -L ${URL_LINE} && pax -rf ${PAX_BASENAME} && cd $DIR_NAME && . ./.env</pre>"
DESCRIPTION="${DESCRIPTION}<br /><b>Or use:</b> <pre>zopen install ${PORT_NAME}</pre>"

NAME="${PORT_NAME} ${VERSION}(Build ${BUILD_ID}) - ($BUILD_LINE)"

exists=$(github-release info -u ${GITHUB_ORGANIZATION} -r ${GITHUB_REPO} --tag "${TAG}" -j)
if [ $? -gt 0 ]; then
  echo "Creating a new tag in github"
  github-release -v release --user ${GITHUB_ORGANIZATION} --repo ${GITHUB_REPO} --tag "${TAG}" --name "${NAME}" --description "${DESCRIPTION}"
  if [ $? -eq 0 ]; then
    echo "Release created successfully!"
  else
    echo "Failed to create release."
    exit 1                                     
  fi
else
  echo "Deleting and creating new tag"
  github-release -v delete --user ${GITHUB_ORGANIZATION} --repo ${GITHUB_REPO} --tag "${TAG}"
  github-release -v release --user ${GITHUB_ORGANIZATION} --repo ${GITHUB_REPO} --tag "${TAG}" --name "${NAME}" --description "${DESCRIPTION}"
  if [ $? -eq 0 ]; then
    echo "Release recreated successfully!"
  else
    echo "Failed to recreate release."
    exit 1                                     
  fi
fi

# check up to 5 times for the release to appear on github                                                     
for i in {1..5}; do
  github-release info -u "${GITHUB_ORGANIZATION}" -r "${GITHUB_REPO}" --tag "${TAG}" -j
  if [ $? -eq 0 ]; then
    echo "Release found!"
    break
  else
    if [ $i -eq 5 ]; then
       echo "Command failed after 5 attempts. Recreating release..."
       github-release -v release --user ${GITHUB_ORGANIZATION} --repo ${GITHUB_REPO} --tag "${TAG}" --name "${NAME}" --description "${DESCRIPTION}"
       if [ $? -eq 0 ]; then
         echo "Release recreated successfully!"
       else
         echo "Failed to recreate release."
         exit 1                                     
       fi
    else
      echo "Command failed. Retrying in 10 seconds..."
      sleep 10
    fi
 fi
done

echo "Uploading the artifacts into github"
github-release -v upload --user ${GITHUB_ORGANIZATION} --repo ${GITHUB_REPO} --tag "${TAG}" --name "${PAX_BASENAME}" --file "${PAX}"
if [ $? -eq 0 ]; then
  echo "Artifacts uploaded successfully!"
else
  echo "Failed to upload artifacts!"
  exit 1                                     
fi
