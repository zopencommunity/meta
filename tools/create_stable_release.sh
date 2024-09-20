#!/usr/bin/env bash

########################################################################
##PRE_REQUISITES 
## Bash version to be >= 4 as the associative arrays are used here
## jq library is required for parsing
########################################################################


if ((BASH_VERSINFO < 4)); then
   echo "Use bash version >= 4"
   exit 1
fi

if [ -z "$ZOPEN_GITHUB_OAUTH_TOKEN" ]; then
   echo "ZOPEN_GITHUB_OAUTH_TOKEN must be set."
   exit 1
fi

echo "Number of args = $#"
DEFAULT_OWNER="zopencommunity"
OWNERNAME=""
REPO=""
RELEASENAME=""
CURL_REPO_SUCCESS="200"
DELETE_RELEASE_CODE="204"
CRT_UPLOAD_REL_SUCCESS="201"
DEL_TAG_VALIDATION_FAIL="422"


if ! jq --version >/dev/null 2>/dev/null; then
    echo "jq is required to run this script"
    exit 1
fi
 
#The method below handles the spaces in the value of the argument passed
processOptions()
{
  args=$*
  OWNERNAME="$(echo $args | awk -F "--org" '{print $2}' |  awk -F "--" '{print $1}')"
  RELEASENAME="$(echo $args | awk -F "--release " '{print $2}' |  awk -F "--" '{print $1}' )"
  REPO="$(echo $args | awk -F "--repo " '{print $2}' |  awk -F "--" '{print $1}' )"

  OWNERNAME=$(echo "$OWNERNAME" | xargs) 
  echo "Owner=$OWNERNAME"
  RELEASENAME=$(echo "$RELEASENAME" | xargs) 
  echo "Release name=$RELEASENAME"
  REPO=$(echo "$REPO" | xargs) 
  echo "Repo=$REPO"
}

getLatestReleaseName()
{
  latestRepoUrl="https://api.github.com/repos/$OWNERNAME/$REPO/releases/latest"
  
  response=$(curl -sw "%{http_code}" \
              -H "Accept: application/vnd.github+json" \
              -H "Authorization: Bearer $ZOPEN_GITHUB_OAUTH_TOKEN" \
              $latestRepoUrl ) 
  if [ $? -gt 0 ]; then
    echo "curl command failed for getLatestReleaseName()"
    exit 1
  fi

  http_code=$(tail -n1 <<< "$response")
  if [ "$http_code" == "$CURL_REPO_SUCCESS" ]; then
    newReleaseData=$(sed '$ d' <<< "$response") 
    
    repo_json=`jq '.' <<< "$newReleaseData"`
    RELEASENAME=$(echo $repo_json | jq -r ".name")
    echo "Latest release name=$RELEASENAME"
  fi
}

processOptions $*

#Print Syntax
printSyntax()
{
  echo "Pass repo/release name -- usage: create_stable_release.sh --repo <repo> --release <releasename> --org [organization]" 
  echo "If --release is not passed, it will use the latest release"
  exit 1;
}

[ -z "${OWNERNAME}" ] && OWNERNAME=$DEFAULT_OWNER && echo "Using default organization name zopencommunity";
[ -z "${REPO}" ] && (printSyntax)
[ -z "${RELEASENAME}" ] && getLatestReleaseName


echo "Ownername = ${OWNERNAME}, Repo = ${REPO}, Release = ${RELEASENAME}"

if [ "${RELEASENAME}" == "stable-release" ]; then
    echo "Release name in argument is stable-release, no action taken"
    exit 0
fi

url="https://api.github.com/repos/$OWNERNAME/$REPO/releases"
repourl="https://api.github.com/repos/$OWNERNAME/$REPO/"

declare -A releaseNameIDMap
declare -A releaseIDToReleaseNameMap

#Fetches the releases and creates a map of release name to its release ID
populateReleaseMaps()
{
  id=""
  name=""
  releaseNameIDMap=()
  releaseIDToReleaseNameMap=()
  response=$(curl -sw "%{http_code}" -k -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $ZOPEN_GITHUB_OAUTH_TOKEN" $url)
  if [ $? -gt 0 ]; then
    echo "curl command failed for populateReleaseMaps()"
    exit 1
  fi
  http_code=$(tail -n1 <<< "$response")

  if [ "$http_code" == "$CURL_REPO_SUCCESS" ]; then
    releaseListData=$(sed '$ d' <<< "$response") 
    repo_json=`jq '.' <<< "$releaseListData"`
    repo_length_end=`jq -r ".[]| length" <<< "$releaseListData" | wc -l`
    repo_length_start=0
    while (( $repo_length_start < $repo_length_end ))
    do
            id=$(echo $repo_json | jq -r ".[$repo_length_start].id")
            name=$(echo $repo_json | jq -r ".[$repo_length_start].name")
            releaseNameIDMap[$name]=$id
            releaseIDToReleaseNameMap[$id]=$name
            repo_length_start=`expr $repo_length_start + 1`
    done
  else
    echo "Release repo list error occured - return code = $http_code"
    exit 1
  fi
}


#uses the maps populated above to check if the release name passed in arguments actually exists in repo
function checkReleaseNameExists {
    releaseID=""
    tagNameOfRelease=""

    var=$(declare -p "$1")
    echo $var
    eval "declare -A _arr="${var#*=}
    for k in "${!_arr[@]}"; do
        echo "$k: ${_arr[$k]}"
        releaseID=${_arr[$k]};
        releasevalue="${2}"
        echo "second arg = ${releasevalue}"
        echo "comparing value  = $k"
        if [ "$k" == "$releasevalue" ]; then
           echo "Both Strings are Equal."
           return 0;
        else
           echo "Both Strings are not Equal."
        fi
    done
    return 1;
}

#Method below is used to fetch the tag name of the release passed as arg
getTagNameOfRelease ()
{

  releaseUrl=$url"/""$1"
  #echo "GetTagNameOfRelease releaseUrl = $releaseUrl"

  response=$(curl -sw "%{http_code}" -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $ZOPEN_GITHUB_OAUTH_TOKEN" $releaseUrl )
  echo "curl -sw "%{http_code}" -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $ZOPEN_GITHUB_OAUTH_TOKEN" $releaseUrl"
  if [ $? -gt 0 ]; then
    echo "curl command failed for getTagNameOfRelease()"
    exit 1
  fi
  http_code=$(tail -n1 <<< "$response")
  echo "GetTagNameOfRelease , http_code = ${http_code}"
  
  if [ "$http_code" == "$CURL_REPO_SUCCESS" ]; then
    releaseListData=$(sed '$ d' <<< "$response") 
    repo_json=`jq '.' <<< "$releaseListData"`
    tag_name=$(echo $repo_json | jq -r ".tag_name")
    [ -z "$tag_name" ] && echo "No tag name" && exit 1;
    tagNameOfRelease=$tag_name

    echo "Tag name final = $tagNameOfRelease"
  else
    echo "Couldn't fetch release repo - error occured - return code = $http_code"
    exit 1
  fi
  
  #Get the SHA for the tag to retain the commit ID
  getSHAOfTag $tagNameOfRelease
}

#This method is used to fetch the SHA associated with the tag
getSHAOfTag()
{
  releaseTagUrl=$repourl"git/ref/tags/""$1"
  #echo "getSHAOfTag releaseTagUrl = $releaseTagUrl"
  response=$(curl -sw "%{http_code}" -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $ZOPEN_GITHUB_OAUTH_TOKEN" $releaseTagUrl )
  if [ $? -gt 0 ]; then
    echo "curl command failed for getSHAOfTag()"
    exit 1
  fi
  shaOfTag=""  

  http_code=$(tail -n1 <<< "$response")

  if [ "$http_code" == "$CURL_REPO_SUCCESS" ]; then
    releaseListData=$(sed '$ d' <<< "$response") 
    repo_json=`jq '.' <<< "$releaseListData"`
    sha=$(echo $repo_json | jq -r ".object.sha")
    [ -z "$sha" ] && echo "No commit ID" && exit 1;
    shaOfTag=$sha
    echo "SHA of tag = $shaOfTag"
  else
    echo "Couldn't fetch SHA of tag - error occured - return code = $http_code"
    exit 1
  fi
}

#downloads the assets of the releasedId passed in arg $1

assetNameArray=()
downloadAssetsOfRelease()
{
  assetNameArray=()
  assetUrl=$url"/""$1""/""assets"
  #echo "downloadAssetsOfRelease assetsurl = $assetUrl"
  response=$(curl -sw "%{http_code}" -k -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $ZOPEN_GITHUB_OAUTH_TOKEN" $assetUrl)
  if [ $? -gt 0 ]; then
    echo "curl command failed for downloadAssetsOfRelease()"
    exit 1
  fi
  http_code=$(tail -n1 <<< "$response")

  if [ "$http_code" == "$CURL_REPO_SUCCESS" ]; then
    releaseAssetsData=$(sed '$ d' <<< "$response") 
    
    repo_json=`jq '.' <<< "$releaseAssetsData"`
    
    if [[ $repo_json = null ]]; then
      echo "No assets data found " 
      return 0
    fi
    repo_length_end=`jq -r ".[]| length" <<< "$releaseAssetsData" | wc -l`
    repo_length_start=0

    while (( $repo_length_start < $repo_length_end ))
    do
        id=$(echo $repo_json | jq -r ".[$repo_length_start].id")
        downloadUrl=$(echo $repo_json | jq -r ".[$repo_length_start].browser_download_url")
        
        echo "ID in downloadAssetsOfRelease =$id"
        echo "DownloadUrl in downloadAssetsOfRelease =$downloadUrl"

        if [[ -z "$id" || -z "$downloadUrl" ]]; then
          echo "No data found " 
          return 0
        fi
        assetName=$(echo "$downloadUrl" | awk -F/ '{print $NF}')
        echo "Asset name = $assetName"

        [ -z "$assetName" ] && echo "No assets" && return 0;
        assetNameArray+=($assetName)
        
        response=$(curl -sw "%{http_code}" -L "$downloadUrl" --output $assetName)
        if [ $? -gt 0 ]; then
          echo "curl command failed for downloadAssetsOfRelease()"
          exit 1
        fi
        http_code=$(tail -n1 <<< "$response")
        repo_results=$(sed '$ d' <<< "$response") 
  
        repo_length_start=`expr $repo_length_start + 1`
    done
  else 
    echo "Error occurred in download asset - return code = $http_code"
  fi
}


# check if the releasename in argument is part of repo, else return without processing
# If yes, 
    #download its asset and delete the release and the tag "stable"
    # create a new release with name as "stable-release" and tag "stable" 
      #(not latest and commit level to same as the release in the arg )
    # and upload the assets

releaseDescription=""
processPassedReleaseName()
{
  checkReleaseNameExists "releaseNameIDMap" "${RELEASENAME}"
  
  if [ $? -eq 0 ]; then
     downloadAssetsOfRelease "$releaseID"
     getTagNameOfRelease $releaseID
     releaseDescription=""
     getDescriptionOfRelease "$releaseID"
     deleteBootTag
  else
     echo "Release name doesnot exist"
  fi

  echo "DescriptionData for processing release= $releaseDescription"
  echo "isBootReleaseLatest = $isBootReleaseLatest"
  
  createRelease "stable-release" "stable" "${releaseDescription}"
}

getDescriptionOfRelease()
{
  releaseUrl=$url"/""$1"

  response=$(curl -sw "%{http_code}" -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $ZOPEN_GITHUB_OAUTH_TOKEN" -H "X-GitHub-Api-Version: 2022-11-28" $releaseUrl )
  if [ $? -gt 0 ]; then
    echo "curl command failed for getDescriptionOfRelease()"
    exit 1
  fi
  http_code=$(tail -n1 <<< "$response")

  if [ "$http_code" == "$CURL_REPO_SUCCESS" ]; then
    releaseTagData=$(sed '$ d' <<< "$response") 
    
    id=`jq -r ".id"  <<< "$releaseTagData"`
    name=`jq -r ".name"  <<< "$releaseTagData"`
    bodyData=`jq -r ".body"  <<< "$releaseTagData"`

    descriptionData=$(echo ${name} | tr -d "(" | tr -d ")")
    descriptionData="This is ""$descriptionData"" release"
    echo "DescriptionData = $descriptionData"

    [ "$bodyData" = "null" ] && echo "no body for the release $name" && (bodyData="${descriptionData}");
    releaseDescription=${bodyData}
    echo "Final bodyData in getDescriptionOfRelease = $releaseDescription"
  fi
}

# the release with id $releaseID (populated in checkReleaseNameExists) is deleted here
deleteTheRelease()
{
  deleteRepoUrl="https://api.github.com/repos/$OWNERNAME/$REPO/releases/$releaseID"
  echo "DeleteTheRelease in url = $deleteRepoUrl"
  response=$(curl -sw "%{http_code}" -X DELETE -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $ZOPEN_GITHUB_OAUTH_TOKEN" $deleteRepoUrl)
  if [ $? -gt 0 ]; then
    echo "curl command failed for deleteTheRelease()"
    exit 1
  fi
  http_code=$(tail -n1 <<< "$response")
  delReleaseTagData=$(sed '$ d' <<< "$response") 
  
  if [ "$http_code" == "$DELETE_RELEASE_CODE" ]; then
     echo "Delete successful"
  fi
}


# the tag "stable" is deleted here
deleteBootTag()
{
  tagUrl=$repourl"git/refs/tags/stable"
  #echo "deleteBootTag in url = $tagUrl"
  response=$(curl -sw "%{http_code}" -X DELETE -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $ZOPEN_GITHUB_OAUTH_TOKEN" $tagUrl)
  if [ $? -gt 0 ]; then
    echo "curl command failed for deleteBootTag()"
    exit 1
  fi
  http_code=$(tail -n1 <<< "$response")

  if [ "$http_code" == "$DEL_TAG_VALIDATION_FAIL" ]; then
      echo "The endpoint has been spammed - return code - $http_code"
  fi
}


# All releases in the repo tagged as "stable" are deleted here.
deleteBootTaggedReleases()
{
  stableTagUrl="https://api.github.com/repos/$OWNERNAME/$REPO/releases/tags/stable"
  response=$(curl -sw "%{http_code}" -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $ZOPEN_GITHUB_OAUTH_TOKEN" $stableTagUrl)
  if [ $? -gt 0 ]; then
    echo "curl command failed for deleteBootTaggedReleases()"
    exit 1
  fi
  http_code=$(tail -n1 <<< "$response")
  
  if [ "$http_code" == "$CURL_REPO_SUCCESS" ]; then
    releaseTagData=$(sed '$ d' <<< "$response") 
    
    id=`jq -r ".id"  <<< "$releaseTagData"`

    echo "id in deleteBootTaggedReleases = $id , $?"
    [ "$id" = "null" ] && echo "no tagged releases" && return 0;

    deleteRepoUrl="https://api.github.com/repos/$OWNERNAME/$REPO/releases/$id"
    echo "DeleteRepoUrl = $deleteRepoUrl"

    if [ "$id" = "$releaseID" ]; then
        downloadAssetsOfRelease "$releaseID"
    fi

    response=$(curl -sw "%{http_code}" -X DELETE -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $ZOPEN_GITHUB_OAUTH_TOKEN" $deleteRepoUrl)
    if [ $? -gt 0 ]; then
      echo "curl command failed for deleteBootTaggedReleases()"
      exit 1
    fi
    http_code=$(tail -n1 <<< "$response")
    delReleaseTagData=$(sed '$ d' <<< "$response") 
    deleteBootTag
    #This call refreshes the maps as stable releases are deleted 
    populateReleaseMaps
  else 
    echo "No stable tagged releases found during deletion-  return code $http_code"
  fi
}


renameBootTaggedReleases()
{
  stableTagUrl="https://api.github.com/repos/$OWNERNAME/$REPO/releases/tags/stable"
  response=$(curl -sw "%{http_code}" -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $ZOPEN_GITHUB_OAUTH_TOKEN" $stableTagUrl)
  if [ $? -gt 0 ]; then
    echo "curl command failed for renameBootTaggedReleases()"
    exit 1
  fi
  http_code=$(tail -n1 <<< "$response")
  
  if [ "$http_code" == "$CURL_REPO_SUCCESS" ]; then
    releaseTagData=$(sed '$ d' <<< "$response") 
    
    id=`jq -r ".id"  <<< "$releaseTagData"`
    name=`jq -r ".name"  <<< "$releaseTagData"`
    bodyData=`jq -r ".body"  <<< "$releaseTagData"`

    #echo "id in renameBootTaggedReleases = $id , $?"
    origId=${id}
    #echo "bodyData in renameBootTaggedReleases = $bodyData"
    [ "$id" = "null" ] && echo "no tagged releases" && return 0;

    IsPrevBootReleaseLatest "$id"
    downloadAssetsOfRelease "$origId"
    dateVal=$(date +%C%y%m%d_%H%M%S)
    releaseName=${name}"_"$dateVal
    tagName="stable_"$dateVal
    getSHAOfTag "stable"

    echo "Name of renaming releaseName = ${releaseName}"
    echo "TagName in renameBootTaggedReleases = ${tagName}"

    descriptionData=$(echo ${name} | tr -d "(" | tr -d ")")
    #echo "DescriptionData = $descriptionData"


    [ "$bodyData" = "null" ] && echo "no body for the release $name" && (bodyData="${descriptionData}");

    echo "Final bodyData in renameBootTaggedReleases = $bodyData"
    #createRelease "${releaseName}" "${tagName}" "${bodyData}" "false"
    createRelease "${releaseName}" "${tagName}" "${bodyData}"
    creatRelVal=$?
    if [ "$creatRelVal" != "$CRT_UPLOAD_REL_SUCCESS" ]; then
        echo "ERROR: couldnot rename the stable tagged release"
        exit 1;
    fi

    #Delete releases tagged as stable, as the script tags the release mentioned in argument as stable
    deleteBootTaggedReleases

     #This call refreshes the maps as stable releases are deleted 
    populateReleaseMaps
  else 
    echo "No stable tagged releases found -  return code $http_code"
  fi
}

# The function is used to create new release with name "stable-release" and tag as stable
createRelease()
{
  createRepoUrl="https://api.github.com/repos/$OWNERNAME/$REPO/releases"

  #echo "old bodyData = $3"
  #echo "old bodyData start --------------------------------------->"
  #printf %s "$3" | od -vtc -to1

  body=$(echo $bodyData | tr -d '\n' | sed 's/\r/\\r\\n/g' )

  #echo "old bodyData end ------------------------------------------> "
  #printf %s "$body" | od -vtc -to1

  echo "new release name = $1"
  echo "new tag name = $2"
  echo "sha of new release = $shaOfTag"
  response=$(curl -sw "%{http_code}" \
              -X POST \
              -H "Accept: application/vnd.github+json" \
              -H "Authorization: Bearer $ZOPEN_GITHUB_OAUTH_TOKEN" \
              $createRepoUrl \
              -d  '{"tag_name":"'"${2}"'","target_commitish":"'"${shaOfTag}"'","name":"'"${1}"'","body":"'"${body}"'","make_latest":"false"}')
  if [ $? -gt 0 ]; then
    echo "curl command failed for createRelease()"
    exit 1
  fi

  http_code=$(tail -n1 <<< "$response")
  #echo "create release response = $response"
  echo "create release http_code = $http_code"
  if [ "$http_code" == "$CRT_UPLOAD_REL_SUCCESS" ]; then
    
    newReleaseData=$(sed '$ d' <<< "$response") 
    
    repo_json=`jq '.' <<< "$newReleaseData"`
    id=$(echo $repo_json | jq -r ".id")
    echo "Newly assigned release id =$id"

    if [ ${#assetNameArray[@]} -eq 0 ]; then
      echo " No asset found to upload"
      return $http_code;
    fi

    uploadAsset $id 
  else
    echo "Release not created successfully -  return code = $http_code"
  fi

  return $http_code;
}

#This function uploads the assets to release id passed as argument
uploadAsset()
{
  for assetName in "${assetNameArray[@]}"
  do
    echo "Upload Asset , asset name = ${assetName}"
    
    [ -z "${assetName}" ] && echo "no asset " && return 0;

    curDir=`pwd`
    curDir=$curDir"/"$assetName

    echo "Asset full path = $curDir"
    response=$(curl -sw "%{http_code}" \
    -X PUT \
     "https://uploads.github.com/repos/$OWNERNAME/$REPO/releases/$1/assets?name=${assetName}" \
    -H "Authorization: Bearer $ZOPEN_GITHUB_OAUTH_TOKEN" \
    -H "Content-Type: application/octet-stream" \
   --data-binary @${curDir})
    if [ $? -gt 0 ]; then
      echo "curl command failed for uploadAsset()"
      exit 1
    fi

    http_code=$(awk -F "}" '{print $NF}' <<< "$response")
    if [ "$http_code" == "$CRT_UPLOAD_REL_SUCCESS" ]; then
      uploadData=$(sed '$ d' <<< "$response") 
      echo "Upload asset successful - $assetName"
    else
      echo "Upload asset issue - return code = $http_code"
    fi
  done
}

getLatestReleaseID()
{
  latestRepoUrl="https://api.github.com/repos/$OWNERNAME/$REPO/releases/latest"
  
  response=$(curl -sw "%{http_code}" \
              -H "Accept: application/vnd.github+json" \
              -H "Authorization: Bearer $ZOPEN_GITHUB_OAUTH_TOKEN" \
              $latestRepoUrl ) 
  if [ $? -gt 0 ]; then
    echo "curl command failed for getLatestReleaseID()"
    exit 1
  fi

  http_code=$(tail -n1 <<< "$response")
  if [ "$http_code" == "$CURL_REPO_SUCCESS" ]; then
    newReleaseData=$(sed '$ d' <<< "$response") 
    
    repo_json=`jq '.' <<< "$newReleaseData"`
    latestReleaseId=$(echo $repo_json | jq -r ".id")
    echo "Latest release id =$latestReleaseId"
  fi
}


#This function checks if current stable release in a repo - marked as latest or not
IsPrevBootReleaseLatest()
{
  isBootReleaseLatest="false"
  [ -z "$latestReleaseId" ] && echo "No release marked as latest" && return 0;

  echo "comparing id of latest release =$latestReleaseId and id of release in arg = $1"
  if [ "$latestReleaseId" == "$1" ]; then
      isBootReleaseLatest="true"
  fi
  
  echo "isBootReleaseLatest = ${isBootReleaseLatest}"
}

#On creating backup of stable-release, the latest release is set to it, hence, we reset the latest release here
resetLatestRelease()
{
  echo "latestReleaseId in resetLatestRelease = $latestReleaseId"
  relRepoUrl="https://api.github.com/repos/$OWNERNAME/$REPO/releases/$latestReleaseId"

  response=$(curl -sw "%{http_code}" \
  -X PATCH \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $ZOPEN_GITHUB_OAUTH_TOKEN"\
  -H "X-GitHub-Api-Version: 2022-11-28" \
  $relRepoUrl \
  -d '{"make_latest":"true"}')
  if [ $? -gt 0 ]; then
    echo "curl command failed for resetLatestRelease()"
    exit 1
  fi

  http_code=$(tail -n1 <<< "$response")

  echo "http_code = $http_code"

  if [ "$http_code" == "$CURL_REPO_SUCCESS" ]; then
    echo "Release marked as latest"
  else
    echo "Release not marked as latest"
  fi

}

releaseID=""
tagNameOfRelease=""
shaOfTag=""
isBootReleaseLatest="false"

latestReleaseId=""
getLatestReleaseID

# fetch all the releases from repo and maintain a map of name to release Id
# we need this step because processing is possible only on release IDs 
populateReleaseMaps

checkReleaseNameExists "releaseNameIDMap" "${RELEASENAME}"

[ $? -eq 1 ] && echo "No release with name ${RELEASENAME} found in repo $REPO" && exit 1;

# Rename releases tagged as stable and delete them, as the script tags the release mentioned in argument as stable
renameBootTaggedReleases

# fetch all the releases from repo and maintain a map of name to release Id
# we need this step because processing is possible only on release IDs 
populateReleaseMaps

# The release name , repo and owner name passed as args - is processed to name the given release as stable-release and tag as "stable"
processPassedReleaseName

resetLatestRelease
