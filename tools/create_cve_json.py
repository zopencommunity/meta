import argparse
import json
import aiohttp
import asyncio
import sys
from cvsslib import cvss31, calculate_vector

HEADER = """
z/OS Open Tools Vulnerability JSON Generator

This tool fetches z/OS Open Tools releases and generates a list of tools and their associated CVEs using the osv.dev API.
"""

def calculate_severity(cvss_score):
    if cvss_score >= 9.0:
        return "CRITICAL"
    elif cvss_score >= 7.0:
        return "HIGH"
    elif cvss_score >= 4.0:
        return "MEDIUM"
    else:
        return "LOW"

parser = argparse.ArgumentParser(description=HEADER)
parser.add_argument('--verbose', action='store_true', help='Enable verbose output')
parser.add_argument('--output-file', dest='output_file', required=True, help='The full path to store the JSON file to')
args = parser.parse_args()

# Use the zopen_releases.json cache to iterate on releases
url = "https://raw.githubusercontent.com/ZOSOpenTools/meta/main/docs/api/zopen_releases.json"
if args.verbose:
    print("Fetching data from:", url)

# Use the OSV API: 
async def fetch_cves(session, commit):
    url = "https://api.osv.dev/v1/query"
    data = {
        "commit": commit
    }
    async with session.post(url, json=data, ssl=False) as response:
        if response.status == 200:
            cve_data = await response.json()
            return cve_data.get("vulns", [])
        else:
            print("Failed to fetch CVEs for commit:", commit)
            return []

async def get_project_cve_info(session, commit, project, release):
    if not commit:
        if args.verbose:
            print("No commit hash for release:", release["name"])
        return (project, [])
    all_cves = []
    cves = await fetch_cves(session, commit)
    for cve in cves:
        cvss_vector = cve.get("severity")[0].get("score")
        cvss_score = calculate_vector(cvss_vector, cvss31) 
        severity = calculate_severity(cvss_score[0])
        cve_info = {
            "id": cve["id"],
            "details": cve["details"],
            "published": cve["published"],
            "severity": severity
        }
        release_info = {
            "name": release["name"],
            "commit_sha": commit,
            "CVEs": cve_info
        }
        all_cves.append(release_info)
    return (project, all_cves)

async def main():
    async with aiohttp.ClientSession() as session:
        async with session.get(url, ssl=False) as response:
            if response.status != 200:
                print("Failed to fetch data from the URL.")
                return

            if args.verbose:
                print("Data fetched successfully.")
            text = await response.text()
            data = json.loads(text)
            releases_data = data.get("release_data", {})

            # Insert dummy commit hash that is known to have a vulnerability
            dummy_commit_sha = "d3e09bf4654fe5478b6dbf2b26ebab6271317d81"
            releases_data["gitdummy"] = [{
                "name": "gitdummy",
                "assets": [{
                    "name": "gitdummy",
                    "community_commitsha": dummy_commit_sha
                }]
            }]

            if args.verbose:
                print("Processing releases...")
            tasks = []
            for project, releases in releases_data.items():
                for release in releases:
                    for asset in release.get("assets", []):
                        community_commitsha = asset.get("community_commitsha")
                        # Create a coroutine for each project to fetch CVEs
                        tasks.append(get_project_cve_info(session,
                                                          community_commitsha,
                                                          project, release))

            if args.verbose:
                print("Executing tasks...")
            # Wait for all coroutines to finish and create project_info dict
            all_cves = await asyncio.gather(*tasks)
            project_info = {project: cves for project, cves in all_cves}

            with open(args.output_file, "w") as f:
                json.dump(project_info, f, indent=4)
            if args.verbose:
                print("New JSON file created:", args.output_file)

            if args.verbose:
                print("Printing JSON to stdout...")
            json.dump(project_info, sys.stdout, indent=4)
            if args.verbose:
                print("\nDone.")

asyncio.run(main())
