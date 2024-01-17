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
import urllib
from collections import OrderedDict

"""
GitHub Releases JSON Cache

This tool fetches z/OS Open Tools releases and metadata and generates a minimized JSON cache file.
The cache file contains information about the releases, including assets, sizes, and metadata.
"""

parser = argparse.ArgumentParser(description='GitHub Releases JSON Cache')
parser.add_argument('--verbose', action='store_true', help='Enable verbose output')
#parser.add_argument('--max-releases', type=int, default=None, help='Maximum number of releases to consider per repository (default: consider all releases)')
parser.add_argument('--output-file', dest='output_file', required=True, help='The full path to store the json file to')
args = parser.parse_args()

organization = "ZOSOpenTools"

if os.getenv('ZOPEN_GITHUB_OAUTH_TOKEN') is None:
    print("error: environment variable ZOPEN_GITHUB_OAUTH_TOKEN must be defined")
    sys.exit(1)

release_data = OrderedDict()

g = Github(os.getenv('ZOPEN_GITHUB_OAUTH_TOKEN'))

org = g.get_organization(organization)
repositories = org.get_repos()

# Process a single asset
def process_asset(asset, body, metadata_asset_name="metadata.json"):
    if asset.name == metadata_asset_name:
        asset_name = asset.name
        asset_size = asset.size

        # Download the metadata.json asset
        download_url = asset.browser_download_url
        response = requests.get(download_url)
        metadata_content = response.content.decode('utf-8')


        # Parse metadata information from JSON
        metadata = json.loads(metadata_content).get("product", {})

        if "pax" not in metadata:
            return None

        pax_file_name = metadata.get("pax", None)
        if pax_file_name:
            full_url = urllib.parse.urljoin(download_url, pax_file_name)
        else:
            full_url = None

        # Extract the info from metadata.json file:
        total_tests = metadata.get("test_status", {}).get("total_tests", -1)
        passed_tests = metadata.get("test_status", {}).get("total_success", -1)

        runtime_dependencies_list = metadata.get("runtime_dependencies", [])
        runtime_dependency_names = [dependency.get("name", "") for dependency in runtime_dependencies_list]
        
        # TODO: We probably want runtime_dependency to be an array at some point. This is mainly for backwards compat
        runtime_dependencies = ' '.join(runtime_dependency_names)

        filtered_asset = {
            "name": pax_file_name,
            "url": full_url,
            "size": metadata.get("pax_size", 0),
            "expanded_size": metadata.get("size", 0),
            "runtime_dependencies": runtime_dependencies,
            "total_tests": total_tests,
            "passed_tests": passed_tests
        }
        print(filtered_asset)

        return filtered_asset

    # Handle other types of assets or return None if not processing this asset type
    return None


# Cap to 1 thread for now so that we don't hit the secondary rate limit
num_threads = min(int(multiprocessing.cpu_count() / 2), 1)


# Process a single release
def process_release(repo_name, release):
    assets = release.get_assets()

    filtered_assets = []
    for asset in assets:
        filtered_asset = process_asset(asset, release.body)
        if filtered_asset:
            filtered_assets.append(filtered_asset)

    if filtered_assets:
        filtered_release = {
            "name": release.title,
            "date": release.published_at,
            "tag_name": release.tag_name,
            "assets": filtered_assets
        }

        return filtered_release, repo_name
    return None, repo_name

# Process releases in parallel with a limited number of threads
with concurrent.futures.ThreadPoolExecutor(max_workers=num_threads) as executor:
    futures = []
    for repo in repositories:
        repo_name = repo.name

        if not repo_name.endswith("port"):
            continue

        project_name = re.sub(r"port$", "", repo_name)

        if args.verbose:
            print(f"Fetching releases for repository: {project_name}")

        releases = repo.get_releases()

        for release in releases:
            future = executor.submit(process_release, project_name, release)
            futures.append(future)

    for future in concurrent.futures.as_completed(futures):
        filtered_release, repo_name = future.result()
        if filtered_release:
            if repo_name not in release_data:
                release_data[repo_name] = []
            release_data[repo_name].append(filtered_release)

for _, entries in release_data.items():
    entries.sort(key=lambda entry: entry['date'], reverse=True)

# Add timestamp to the JSON data
json_data = {
    "timestamp": datetime.datetime.now().isoformat(),
    "release_data": release_data
}

with open(args.output_file, "w") as json_file:
    json.dump(json_data, json_file, indent=2, default=str)

print("JSON cache file created successfully.")

if args.verbose:
    print(f"Organization: {organization}")
    print(f"Total repositories: {repositories.totalCount}")
    print(f"Total releases: {sum(len(releases) for releases in release_data.values())}")

# Add timestamp to the JSON data
json_data = {
    "timestamp": datetime.datetime.now().isoformat(),
    "release_data": release_data
}

with open(args.output_file, "w") as json_file:
    json.dump(json_data, json_file, separators=(',', ':'), default=str)

print("JSON cache file created successfully: {args.output_file}")

# Create a JSON with the latest releases only
latest_releases_json_data = {
    "timestamp": datetime.datetime.now().isoformat(),
    "release_data": {}
}

for repo_name, entries in release_data.items():
    entries.sort(key=lambda entry: entry['date'], reverse=True)
    latest_entries = []

    for entry in entries:
        release_entry = {
            "name": entry["name"],
            "date": entry["date"],
            "tag_name": entry["tag_name"],
            "assets": entry["assets"]
        }

        if len(latest_entries) >= 1:
            break

        #Future: Skip detailed info - maybe once we alter zopen query logic to get this from metadata.json
        #if "runtime_dependencies" not in entry:
        #    release_entry.pop("runtime_dependencies", None)
        #if "total_tests" not in entry:
        #    release_entry.pop("total_tests", None)
        #if "passed_tests" not in entry:
        #    release_entry.pop("passed_tests", None)

        latest_entries.append(release_entry)

    latest_releases_json_data["release_data"][repo_name] = latest_entries

# Save the latest json
latest_output_file = args.output_file.replace('.json', '_latest.json')
with open(latest_output_file, "w") as latest_json_file:
    json.dump(latest_releases_json_data, latest_json_file, separators=(',', ':'), default=str)
print(f"JSON file with the latest releases created successfully: {latest_output_file}")
