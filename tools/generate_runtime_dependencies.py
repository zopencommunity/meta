# Python script to determine the runtime dependencies of open source tools hosted on Github
# The dependencies are stored in a dictionary and printed in a markdown table format
# Only unique dependencies are stored and printed, to avoid duplication
# Note: Only run this on z/OS
import tarfile
import subprocess
from github import Github, GithubException
import os
import re
import requests
import shutil

# Initialize Github object using an access token
g = Github("access_token")

# Github Enterprise with custom hostname
g = Github(os.getenv('ZOPEN_GIT_OAUTH_TOKEN'))

# Create an empty dictionary to store dependencies
dependentOn = {}

# Iterate through all repos in the organization
repositories = g.get_user("ZOSOpenTools").get_repos();
for repo in repositories:
    # Check if the repo name ends with "port"
    if not re.search("port$", repo.name):
        continue
    dependentOn[repo.name] = []
    releases = repo.get_releases()
    if (releases.totalCount):
        #Get the latest release of the repo
        latest_release = repo.get_latest_release()
        # Iterate through all assets of the release
        for asset in latest_release.get_assets():
            # Check if the asset is a pax.Z file
            if asset.name.endswith(".pax.Z"):
                # Download the asset
                response = requests.get(asset.browser_download_url)
                open(asset.name, 'wb').write(response.content)
                # Extract the contents of the pax.Z file using gunzip and tar
                subprocess.call(["pax", "-rf", asset.name])
                os.remove(asset.name)
                current_dir = os.getcwd()
                contents = os.listdir(current_dir)
                unique_dependencies = set() # create an empty set to store unique dependencies
                # Iterate through the extracted files recursively
                for dirpath, dirnames, filenames in os.walk('.'):
                    for file_name in filenames:
                        # Open the file and read its contents
                        try:
                            with open(os.path.join(dirpath, file_name), "r") as file:
                                # file_contents = file.read()
                                # Read the first line which can have a shebang
                                file_contents = file.readline()
                        except UnicodeDecodeError:
                            continue;
                        # Iterate through all repos in the organization again
                        for other_repo in repositories:
                            # Check if the other repo name ends with "port" and is not the current repo
                            if not re.search("port$", other_repo.name) or other_repo.name == repo.name:
                                continue
                            # Check if the name of the other repo (without "port") exists in the contents of the file
                            if re.search(other_repo.name.rstrip("port"), file_contents):
                                unique_dependencies.add(other_repo.name)
                             # If it does, add it as a dependency
                dependentOn[repo.name] = list(unique_dependencies);
                # Remove the downloaded and extracted files
                for item in contents:
                    full_path = os.path.join(current_dir, item)
                    if os.path.isdir(full_path):
                        shutil.rmtree(full_path)
                    else:
                        os.remove(full_path)

# Print the dependency table in markdown format
print("# Runtime Dependencies\n")
print("| Package | Dependencies |")
print("|---|---|")
for project, dependencies in dependentOn.items():
    print("| " + project + " | " + ', '.join(dependencies) + " |")
