#! /bin/env bash
echo $BASH_VERSION

########################################################################
##PRE_REQUISITES 
## Bash version to be >= 4 as the associative arrays are used here
## jq library is required for parsing
########################################################################


if ((BASH_VERSINFO < 4)); then
   echo "Use bash version >= 4"
   exit 1
fi

echo "Number of args = $#"
DEFAULT_OWNER="ZOSOpenTools"
OWNERNAME=""
REPO=""
RELEASENAME=""
CURL_POST="curl -sw "%{http_code}" -X POST -H \"Accept: application/vnd.github+json\""
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
  OWNERNAME="$(echo $args | awk -F "--uname " '{print $2}' |  awk -F "--" '{print $1}')"
  RELEASENAME="$(echo $args | awk -F "--release " '{print $2}' |  awk -F "--" '{print $1}' )"
  REPO="$(echo $args | awk -F "--repo " '{print $2}' |  awk -F "--" '{print $1}' )"

  OWNERNAME=$(echo "$OWNERNAME" | xargs) 
  echo "Owner=$OWNERNAME"
  RELEASENAME=$(echo "$RELEASENAME" | xargs) 
  echo "Release name=$RELEASENAME"
  REPO=$(echo "$REPO" | xargs) 
  echo "Repo=$REPO"
}

#process the options passed by user
processOptions $*

#Print Syntax
printSyntax()
{
  echo "Pass repo/release name -- usage: boottool.sh --repo <repo> --release <releasename> --uname [ownername]" 
  exit 1;
}

[ -z "${OWNERNAME}" ] && OWNERNAME=$DEFAULT_OWNER && echo "Using default owner name ZOSOpenTools";
[ -z "${REPO}" ] && (printSyntax)
[ -z "${RELEASENAME}" ] && printSyntax


echo "Ownername = ${OWNERNAME}, Repo = ${REPO}, Release = ${RELEASENAME}"

if [ "${RELEASENAME}" == "boot-release" ]; then
    echo "Release name in argument is boot-release , no action taken"
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
  response=$(curl -sw "%{http_code}" -k -H "Accept: application/vnd.github+json" $url)
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

  response=$(curl -sw "%{http_code}" -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $GITHUB_OAUTH_TOKEN" -H "X-GitHub-Api-Version: 2022-11-28" $releaseUrl )
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
  response=$(curl -sw "%{http_code}" -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $GITHUB_OAUTH_TOKEN" $releaseTagUrl )
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
  response=$(curl -sw "%{http_code}" -k -H "Accept: application/vnd.github+json" $assetUrl)
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
    #download its asset and delete the release and the tag "boot"
    # create a new release with name as "boot-release" and tag "boot" 
      #(not latest and commit level to same as the release in the arg )
    # and upload the assets

processPassedReleaseName()
{
  checkReleaseNameExists "releaseNameIDMap" "${RELEASENAME}"
  
  if [ $? -eq 0 ]; then
     downloadAssetsOfRelease "$releaseID"
     getTagNameOfRelease $releaseID
     deleteTheRelease
     deleteBootTag
  else
     echo "Release name doesnot exist"
  fi

  descriptionData=$(echo ${RELEASENAME} | tr -d "(" | tr -d ")")
  echo "DescriptionData = $descriptionData"
  createRelease "boot-release" "boot" "${descriptionData}"
}

# the release with id $releaseID (populated in checkReleaseNameExists) is deleted here
deleteTheRelease()
{
  deleteRepoUrl="https://api.github.com/repos/$OWNERNAME/$REPO/releases/$releaseID"
  echo "DeleteTheRelease in url = $deleteRepoUrl"
  response=$(curl -sw "%{http_code}" -X DELETE -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $GITHUB_OAUTH_TOKEN" $deleteRepoUrl)
  http_code=$(tail -n1 <<< "$response")
  delReleaseTagData=$(sed '$ d' <<< "$response") 
  
  if [ "$http_code" == "$DELETE_RELEASE_CODE" ]; then
     echo "Delete successful"
  fi
}


# the tag "boot" is deleted here
deleteBootTag()
{
  tagUrl=$repourl"git/refs/tags/boot"
  #echo "deleteBootTag in url = $tagUrl"
  response=$(curl -sw "%{http_code}" -X DELETE -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $GITHUB_OAUTH_TOKEN" $tagUrl)
  http_code=$(tail -n1 <<< "$response")
  echo "DeleteBootTag response= $response"
  if [ "$http_code" == "$DEL_TAG_VALIDATION_FAIL" ]; then
      echo "The endpoint has been spammed - return code - $http_code"
  fi
}


# All releases in the repo tagged as "boot" are deleted here.
deleteBootTaggedReleases()
{
  bootTagUrl="https://api.github.com/repos/$OWNERNAME/$REPO/releases/tags/boot"
  response=$(curl -sw "%{http_code}" -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $GITHUB_OAUTH_TOKEN" $bootTagUrl)
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

    response=$(curl -sw "%{http_code}" -X DELETE -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $GITHUB_OAUTH_TOKEN" $deleteRepoUrl)
    http_code=$(tail -n1 <<< "$response")
    delReleaseTagData=$(sed '$ d' <<< "$response") 
    deleteBootTag
    #This call refreshes the maps as boot releases are deleted 
    populateReleaseMaps
  else 
    echo "No boot tagged releases found during deletion-  return code $http_code"
  fi
}


renameBootTaggedReleases()
{
  bootTagUrl="https://api.github.com/repos/$OWNERNAME/$REPO/releases/tags/boot"
  response=$(curl -sw "%{http_code}" -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $GITHUB_OAUTH_TOKEN" $bootTagUrl)
  http_code=$(tail -n1 <<< "$response")
  
  if [ "$http_code" == "$CURL_REPO_SUCCESS" ]; then
    releaseTagData=$(sed '$ d' <<< "$response") 
    
    id=`jq -r ".id"  <<< "$releaseTagData"`
    name=`jq -r ".name"  <<< "$releaseTagData"`

    echo "id in renameBootTaggedReleases = $id , $?"
    [ "$id" = "null" ] && echo "no tagged releases" && return 0;

    downloadAssetsOfRelease "$id"
    dateVal=$(date +%C%y%m%d_%H%M%S)
    releaseName=${name}"_"$dateVal
    tagName="boot_"$dateVal
    getSHAOfTag "boot"

    echo "Name of renaming releaseName = ${releaseName}"
    echo "TagName in renameBootTaggedReleases = ${tagName}"

    descriptionData=$(echo ${name} | tr -d "(" | tr -d ")")
    echo "DescriptionData = $descriptionData"

    createRelease "${releaseName}" "${tagName}" "${descriptionData}"
    creatRelVal=$?
    if [ "$creatRelVal" != "$CRT_UPLOAD_REL_SUCCESS" ]; then
        echo "ERROR: couldnot rename the boot tagged release"
        exit 1;
    fi

    #Delete releases tagged as boot , as the script tags the release mentioned in argument as boot
    deleteBootTaggedReleases

     #This call refreshes the maps as boot releases are deleted 
    populateReleaseMaps
  else 
    echo "No boot tagged releases found -  return code $http_code"
  fi
}

# The function is used to create new release with name "boot-release" and tag as boot
createRelease()
{
  createRepoUrl="https://api.github.com/repos/$OWNERNAME/$REPO/releases"

  bodyData="This is ""$3"" release"
  QUOTE="'"
  echo "new release name = $1"
  echo "new tag name = $2"
  echo "sha of new release = $shaOfTag"
  response=$(curl -sw "%{http_code}" \
              -X POST \
              -H "Accept: application/vnd.github+json" \
              -H "Authorization: Bearer $GITHUB_OAUTH_TOKEN" \
              $createRepoUrl \
              -d  '{"tag_name":"'"${2}"'","target_commitish":"'"${shaOfTag}"'","name":"'"${1}"'","body":"'"${bodyData}"'","make_latest":"false"}')

  http_code=$(tail -n1 <<< "$response")
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
    -H "Authorization: Bearer $GITHUB_OAUTH_TOKEN" \
    -H "Content-Type: application/octet-stream" \
   --data-binary @${curDir})

    http_code=$(awk -F "}" '{print $NF}' <<< "$response")
    if [ "$http_code" == "$CRT_UPLOAD_REL_SUCCESS" ]; then
      uploadData=$(sed '$ d' <<< "$response") 
      echo "Upload asset successful - $assetName"
    else
      echo "Upload asset issue - return code = $http_code"
    fi
  done
}

releaseID=""
tagNameOfRelease=""
shaOfTag=""

#fetch all the releases from repo and maintain a map of name to release Id
# we need this step because processing is possible only on release IDs 
populateReleaseMaps

checkReleaseNameExists "releaseNameIDMap" "${RELEASENAME}"

[ $? -eq 1 ] && echo "No release with name ${RELEASENAME} found in repo $REPO" && exit 1;

#Rename releases tagged as boot and delete them, as the script tags the release mentioned in argument as boot
renameBootTaggedReleases

#fetch all the releases from repo and maintain a map of name to release Id
# we need this step because processing is possible only on release IDs 
populateReleaseMaps

#The release name , repo and owner name passed as args - is processed to name the given release as boot-release and tag as "boot"
processPassedReleaseName


