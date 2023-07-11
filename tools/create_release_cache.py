from github import Github
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
        build_quality = "Untested"
        test_status = "N/A"
        runtime_dependencies = "No dependencies"

        if body:
            # Extract build quality
            build_quality_match = re.search(r"Test Status:</b>\s*(\w+)", body)
            if build_quality_match:
                build_quality = build_quality_match.group(1)

            # Extract test status
            test_status_match = re.search(r"Test Status:</b>\s*\w+\s*\(([^)]*)\)", body)
            if test_status_match:
                test_status = test_status_match.group(1)

            # Extract runtime dependencies
            dependencies_match = re.search(r"Runtime Dependencies:</b>\s*(.*?)<br>", body)
            if dependencies_match:
                runtime_dependencies = dependencies_match.group(1)

        filtered_asset = {
            "name": asset_name,
            "size": asset_size,
            "expanded_size": total_size,
            "runtime_dependencies": runtime_dependencies,
            "quality": build_quality,
            "test_status": test_status
        }

        # Remove the temporary directory
        os.remove(asset_path)

        return filtered_asset

# Determine the number of threads to use (half the number of CPUs)
num_threads = max(int(multiprocessing.cpu_count() / 2), 1)

# Iterate through the repositories and fetch releases for each
for repo in repositories:
    repo_name = repo.name

    if args.verbose:
        print(f"Fetching releases for repository: {repo_name}")

    releases = repo.get_releases()

    # Filter and process the releases
    filtered_releases = []
    for release in releases:
        assets = release.get_assets()

        # Process assets in parallel with limited number of threads
        with concurrent.futures.ThreadPoolExecutor(max_workers=num_threads) as executor:
            results = executor.map(process_asset, assets)

        filtered_assets = [result for result in results if result is not None]

        if filtered_assets:
            filtered_release = {
                "name": release.title,
                "tag_name": release.tag_name,
                "assets": filtered_assets
            }

            filtered_releases.append(filtered_release)

        # Stop processing further releases if the maximum number of assets per repository is reached
        if args.max_assets is not None and len(filtered_assets) >= args.max_assets:
            break

    if filtered_releases:
        release_data[repo_name] = filtered_releases

# Add timestamp to the JSON data
json_data = {
    "timestamp": datetime.now().isoformat(),
    "release_data": release_data
}

with open(args.output_file, "w") as json_file:
    json.dump(release_data, json_file, indent=4)

print("JSON cache file created successfully.")

# Verbose output
if args.verbose:
    print(f"Organization: {organization}")
    print(f"Total repositories: {repositories.totalCount}")
    print(f"Total releases: {sum(len(releases) for releases in release_data.values())}")
    print("Release data:")
    print(json.dumps(release_data, indent=4))
