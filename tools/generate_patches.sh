#!/bin/bash

# Script to generate the diff files/patches from source code repo to be committed to the port repo
# Steps
# 1. Apply all the patches and generate source code repo using zopen build command
# 2. Commit the files modified by applying patches. Dev/bug fix changes should be done on top of this commit
# 3. Once changes are ready, create new commit(s)
# 4. Use this script to generate patch for files modified in step 3

echo_error()
{
    echo "ERROR: $1"
}

get_commit_ids()
{
    BASE_COMMIT=      # source code gets cloned with this latest commit
    PATCHED_COMMIT=   # Run zopen build to apply all the patches from port
    CURRENT_COMMIT=   # Commit with further dev changes

    #Check here if the branch is in detached state
    if [ $(git branch -a | grep '* ' | grep -c "detached") != 0 ] 
    then
        echo_error "This is in detached state, please create a branch and try again!"
        exit 1;
    fi

    #Find the current branch name
    curr_branch=$(git branch -a | grep '* ' | cut -d ' ' -f 2)

    #Find the commit from which curr_branch diverged
    BASE_COMMIT=$(git reflog show ${curr_branch} | grep "branch: Created" | cut -d ' ' -f 1)

    #Find the first commit after curr_branch branch diverged, this is the commit 
    #with all previous patches applied
    PATCHED_COMMIT=$(git rev-list --reverse ${curr_branch} | grep -A1 ${BASE_COMMIT} | tail -n 1)

    #Find the latest commit 
    CURRENT_COMMIT=$(git rev-list ${curr_branch} | head -n 1)

    if [[ -z ${BASE_COMMIT} || -z ${PATCHED_COMMIT} || -z ${CURRENT_COMMIT} ]]
    then
        echo_error "Something is wrong, BASE_COMMIT, PATCHED_COMMIT and CURRENT_COMMIT needed but are not set"
        exit
    fi
}

gen_patches()
{
    if [ ${PATCHED_COMMIT} == ${CURRENT_COMMIT} ] 
    then
        #Generating patch files for the first time
        MODIFIED_FILES=$(git diff-tree --no-commit-id --name-only ${BASE_COMMIT} ${CURRENT_COMMIT} -r)
    else
        MODIFIED_FILES=$(git diff-tree --no-commit-id --name-only ${PATCHED_COMMIT} ${CURRENT_COMMIT} -r)
    fi
    
    echo -e "\nModified files:\n" 
    echo -e "${MODIFIED_FILES}\n"
    
    for file in ${MODIFIED_FILES}
    do
        echo "Generating diff for ${file}"
    
        #Save the patch files to port/patches/
        PATCH_FILE=${PORT_DIR}/patches/${file}.patch
        PATCH_FILE_DIR=$(dirname ${PATCH_FILE})
    
        if [ ! -d ${PATCH_FILE_DIR} ]
        then
            echo "${PATCH_FILE_DIR} does not exists, creating one"
    	    mkdir -p ${PATCH_FILE_DIR}
        fi
    
        if [ -f ${PATCH_FILE} ]
        then
            echo "WARNING: ${PATCH_FILE} already exists, contents will be overwritten"
        fi
    
        echo ""
        #Generate patch file
        git diff ${BASE_COMMIT} -- ${file} > ${PATCH_FILE}
    
        #Add the file to the staging area
        # cd ${PORT_DIR} ; git add ${PATCH_FILE} ; cd - 
    done
}

## main() STARTS HERE ##

if [ $# != "4" ]
then
    echo_error "Usage: ${0} -p <port-dir absolute path> -s <src-dir absolute path>"
    exit 1;
fi

while getopts "p:s:" opt; do
case $opt in
    p)
        PORT_DIR="$OPTARG"
        ;;
    s)
        SRC_DIR="$OPTARG"
        ;;
    :)
        echo_error "Usage: ${0} -p <port-dir absolute path> -s <src-dir absolute path>"
        exit 1
        ;;
esac
done

if [ ! -d ${SRC_DIR} ]
then
    echo_error "${SRC_DIR} does not exist"
    exit
fi

if [ ! -d ${PORT_DIR} ]
then
    echo_error "${PORT_DIR} does not exist"
    exit
fi

pushd ${SRC_DIR}

get_commit_ids

echo "SRC_DIR          ${SRC_DIR}"
echo "PORT_DIR         ${PORT_DIR}"
echo "BASE_COMMIT      ${BASE_COMMIT}"
echo "PATCHED_COMMIT   ${PATCHED_COMMIT}"
echo "CURRENT_COMMIT   ${CURRENT_COMMIT}"

# Generate patches later
gen_patches

popd
