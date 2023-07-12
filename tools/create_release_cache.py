import sys
import multiprocessing
import concurrent.futures
import os
import re
import json
import argparse
import tempfile
import tarfile
import datetime
import requests
import subprocess
import shutil

"""
GitHub Releases JSON Cache

This tool fetches z/OS Open Tools releases and metadata and generates a minimized JSON cache file.
The cache file contains information about the releases, including assets, sizes, and metadata.
"""

parser = argparse.ArgumentParser(description='GitHub Releases JSON Cache')
parser.add_argument('--verbose', action='store_true', help='Enable verbose output')
parser.add_argument('--max-assets', type=int, default=None, help='Maximum number of assets to consider per repository (default: consider all assets)')
parser.add_argument('--output-file', dest='output_file', required=True, help='The full path to store the json file to')
args = parser.parse_args()

organization = "ZOSOpenTools"

if os.getenv('ZOPEN_GITHUB_OAUTH_TOKEN') is None:
    print("error: environment variable ZOPEN_GITHUB_OAUTH_TOKEN must be defined")
    sys.exit(1)

release_data = {}

g = Github(os.getenv('ZOPEN_GITHUB_OAUTH_TOKEN'))

org = g.get_organization(organization)
repositories = org.get_repos()

# Process a single asset
def process_asset(asset):
    if asset.name.endswith("pax.Z"):
        asset_name = asset.name
        asset_size = asset.size

        # Create a temporary directory
        temp_dir = tempfile.mkdtemp()

        # Download the pax.Z asset
        download_url = asset.browser_download_url
        asset_path = os.path.join(temp_dir, asset_name)
        response = requests.get(download_url)
        with open(asset_path, "wb") as file:
            file.write(response.content)

        # Expand the pax.Z file using tar and calculate the total size
        p = subprocess.Popen(['zcat', asset_path], stdout=subprocess.PIPE)
        p2 = subprocess.Popen(['wc', '-c'], stdin=p.stdout, stdout=subprocess.PIPE)
        p.stdout.close()
        output = p2.communicate()[0].strip().decode()
        total_size = int(output)

        # Extract metadata information 
        body = release.body
        total_tests = -1
        passed_tests = -1
        runtime_dependencies = None

        if body:
            # Extract test status
            test_status_match = re.search(r"Test Status:</b>\s*\w+\s*\((\d+) tests pass out of (\d+) tests[^)]*\)", body)
            if test_status_match:
                passed_tests = test_status_match.group(1)
                total_tests = test_status_match.group(2)

            # Extract runtime dependencies
            dependencies_match = re.search(r"Runtime Dependencies:</b>\s*(.*?)<br>", body)
            if dependencies_match:
                runtime_dependencies = dependencies_match.group(1)

        filtered_asset = {
            "name": asset_name,
            "size": asset_size,
            "expanded_size": total_size,
            "runtime_dependencies": runtime_dependencies,
            "total_tests": total_tests,
            "passed_tests": passed_tests 
        }
        print(filtered_asset);

        # Remove the temporary directory
        os.remove(asset_path)

        return filtered_asset

# Determine the number of threads to use (half the number of CPUs)
num_threads = max(int(multiprocessing.cpu_count() / 2), 1)

# Iterate through the repositories and fetch releases for each
for repo in repositories:
    repo_name = repo.name
    project_name = repo_name.rstrip("port");

    if args.verbose:
        print(f"Fetching releases for repository: {project_name}")

    releases = repo.get_releases()

    # Filter the releases based on the maximum number of assets per release
    filtered_releases = []
    i = 0;
    for release in releases:
        assets = release.get_assets()

        # Consider maximum number of assets per release if specified
        if i >= args.max_assets:
            break
        i=i+1

        filtered_assets = []
        for asset in assets:
            filtered_asset = process_asset(asset)
            if filtered_asset:
                filtered_assets.append(filtered_asset)

        if filtered_assets:
            filtered_release = {
                "name": release.title,
                "tag_name": release.tag_name,
                "assets": filtered_assets
            }

            filtered_releases.append(filtered_release)

    if filtered_releases:
        release_data[project_name] = filtered_releases

json_data = {
    "timestamp": datetime.datetime.now().isoformat(),
    "release_data": release_data
}

with open(args.output_file, "w") as json_file:
    json.dump(release_data, json_file, indent=2)

print("JSON cache file created successfully.")

# Verbose output
if args.verbose:
    print(f"Organization: {organization}")
    print(f"Total repositories: {repositories.totalCount}")
    print(f"Total releases: {sum(len(releases) for releases in release_data.values())}")
    print("Release data:")
    print(json.dumps(release_data, indent=4))
