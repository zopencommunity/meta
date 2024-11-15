#!/usr/bin/env python3
import json
import requests
from datetime import datetime
import sys
from collections import defaultdict
import matplotlib.pyplot as plt
from matplotlib import rcParams
import matplotlib as mpl
import matplotlib.cm as cm
from github import Github
import os
import re
import subprocess
import shutil
from itertools import chain
rcParams.update({'figure.autolayout': True})

def get_status_color(passed_tests, total_tests, has_releases):
    if not total_tests:
        return "Skipped"
    success_rate = (passed_tests / total_tests) * 100
    if success_rate == 100:
        return "Green"
    elif success_rate >= 75:
        return "Blue"
    elif success_rate >= 50:
        return "Yellow"
    else:
        return "Red"

def get_success_rate(passed_tests, total_tests, has_releases):
    if has_releases is False:
        return -2
    if not total_tests:
        return -1
    return (passed_tests / total_tests) * 100

def write_package_table_row(package, status, success_rate, latest_release, latest_asset, description):
    """Helper function to write a consistent table row"""
    print(f"| [{package}](https://github.com/zopencommunity/{package}port)", end='')
    print(f"|{status}", end='')
    print(f"|{success_rate:.1f}%" if success_rate >= 0 else "|N/A", end='')
    print(f"|[{latest_release['tag_name'].replace('port', '')}]({latest_asset['url']})", end='')
    print(f"|{description}|")

def count_patches(repo):
    """Count patches in a repository"""
    num_patches = 0
    total_lines = 0
    try:
        # Clone repository
        if os.path.exists(repo.name):
            shutil.rmtree(repo.name)
        subprocess.run(['git', 'clone', repo.clone_url, repo.name], capture_output=True)
        
        # Count patches
        paths = ('patches', 'tarballpatches', 'gitpatches', 'stable-patches', 'dev-patches')
        for root, dirs, files in chain.from_iterable(os.walk(repo.name + "/" + path) for path in paths):
            for filename in files:
                if filename.endswith('.patch'):
                    num_patches += 1
                    with open(os.path.join(root, filename), 'r') as patch_file:
                        total_lines += len(patch_file.readlines())
        
        # Cleanup
        if os.path.exists(repo.name):
            shutil.rmtree(repo.name)
    except Exception as e:
        print(f"Error counting patches for {repo.name}: {str(e)}", file=sys.stderr)
    
    return num_patches, total_lines

def get_dependencies(repo):
    """Get dependencies from buildenv file"""
    try:
        response = requests.get(f"https://raw.githubusercontent.com/zopencommunity/{repo.name}/main/buildenv")
        if response.status_code == 200:
            matches = re.findall('export\s+ZOPEN.*DEPS\s*=\s*"([^"]*)"', response.text)
            dependencies = []
            for match in matches:
                dependencies += match.split()
            return list(set(dependencies))
    except Exception as e:
        print(f"Error getting dependencies for {repo.name}: {str(e)}", file=sys.stderr)
    return []

progressPerStatus = {
    "Green": 0,
    "Blue": 0,
    "Yellow": 0,
    "Red": 0,
    "Skipped": 0,
}

statusPerPort = {}
download_counts = {}
packages_by_category = defaultdict(list)
dependentOn = {}
patchesPerPort = {}
totalPatchLinesPerPort = {}

if os.getenv('ZOPEN_GITHUB_OAUTH_TOKEN') is None:
    print("error: environment variable ZOPEN_GITHUB_OAUTH_TOKEN must be defined")
    sys.exit(1)

g = Github(os.getenv('ZOPEN_GITHUB_OAUTH_TOKEN'))

json_url = "https://raw.githubusercontent.com/ZOSOpenTools/meta/main/docs/api/zopen_releases.json"
response = requests.get(json_url)
data = json.loads(response.text)
todaysDate = data['timestamp']

# Process the data and organize by categories
for package, releases in data['release_data'].items():
    if not releases:
        continue
            
    latest_release = releases[0]  # Releases are sorted newest first
    latest_asset = latest_release['assets'][0]
    
    # Get GitHub repo info
    repo = g.get_repo(f"zopencommunity/{package}port")
    description = repo.description or ""
    
    # Get dependencies
    dependencies = get_dependencies(repo)
    dependentOn[package + "port"] = []
    for dep in dependencies:
        if dep + "port" in dependentOn:
            dependentOn[dep + "port"].append(package)
    
    # Count patches
    num_patches, total_lines = count_patches(repo)
    patchesPerPort[package + "port"] = num_patches
    totalPatchLinesPerPort[package + "port"] = total_lines
    
    # Calculate status and success rate
    total_tests = int(latest_asset['total_tests']) if latest_asset['total_tests'] else 0
    passed_tests = int(latest_asset['passed_tests']) if latest_asset['passed_tests'] else 0
    
    totalReleases = repo.get_releases().totalCount;
    status = get_status_color(passed_tests, total_tests, totalReleases > 0)
    success_rate = get_success_rate(passed_tests, total_tests, totalReleases > 0)

    # Update counters
    progressPerStatus[status] += 1
    statusPerPort[package + "port"] = success_rate
    
    # Calculate download count
    download_counts[package + "port"] = sum(
        int(asset['size']) for release in releases 
        for asset in release['assets']
    )
    
    # Get categories and add to category lists
    categories = latest_asset['categories'].strip().split() if latest_asset['categories'] else ['uncategorized']
    for category in categories:
        packages_by_category[category].append({
            'package': package,
            'status': status,
            'success_rate': success_rate,
            'latest_release': latest_release,
            'latest_asset': latest_asset,
            'description': description
        })

# Write Latest.md with category sections
with open('docs/Latest.md', 'w') as f:
    sys.stdout = f
    print("# zopen community ports\n")
    print("Note: to download the latest packages, use the [zopen package manager](/Guides/QuickStart)\n")

    print("<div>")
    print("  <label for=\"category-filter\">Filter by Category: </label>")
    print("  <select id=\"category-filter\" onchange=\"filterTable()\">")
    print("    <option value=\"All\">All</option>")
    
    # Populate dropdown options
    for category in sorted(packages_by_category.keys()):
        print(f"    <option value=\"{category}\">{category}</option>")
    
    print("  </select>")
    print("</div>\n")

    # Write table for each category
    for category, packages in sorted(packages_by_category.items()):
        print(f"<div class=\"table-category\" data-category=\"{category}\">")
        print(f"\n## {category.title()} <!-- {{docsify-ignore}} -->\n")
        print("| Package | Status | Test Success Rate | Latest Release | Description |")
        print("|---|---|---|---|---|")
        
        # Sort packages by success rate within category
        sorted_packages = sorted(packages, key=lambda x: (-x['success_rate'] if x['success_rate'] >= 0 else float('-inf')))
        
        for package_info in sorted_packages:
            write_package_table_row(
                package_info['package'],
                package_info['status'],
                package_info['success_rate'],
                package_info['latest_release'],
                package_info['latest_asset'],
                package_info['description']
            )
        print("</div>\n")


    print("\nLast updated: ", todaysDate)


# Generate pie chart
labels = []
sizes = []
for x, y in progressPerStatus.items():
    labels.append(x)
    sizes.append(y)
colors = ['#00FF00','#0000FF','#FFFF00','#FF0000','#AAAAAA','#FF8888']
plt.title("Current Porting Status")
p, tx, autotexts = plt.pie(sizes, labels=labels, colors=colors, autopct="", shadow=True)
for i, a in enumerate(autotexts):
    a.set_text("{}".format(sizes[i]))
plt.axis('equal')
plt.savefig('docs/images/progress.png')
plt.close()

# Generate bar chart
labels = []
sizes = []
for x, y in sorted(statusPerPort.items(), key=lambda x: x[1]):
    if y >= 0:
        labels.append(x)
        sizes.append(y)
fig = plt.figure()
fig.set_size_inches(45, 32)
ax = fig.add_axes([0,0,1,1])
cmap = cm.get_cmap('Greens')
color_norm = mpl.colors.Normalize(vmin=min(sizes), vmax=max(sizes))
colors = cmap(color_norm(sizes))
ax.set_xlabel('Success Rate (%)', fontsize=18)
ax.set_title("Project Test Quality", fontsize=24)
ax.tick_params(axis='both', labelsize=18)
col = []
for val in sizes:
    if val == 100:
        col.append('green')
    elif val >= 50:
        col.append('blue')
    else:
        col.append('#FFEF00')

bars = ax.barh(labels, sizes, color=col, height=0.8, align='edge')
ax.bar_label(bars)
plt.savefig('docs/images/quality.png', bbox_inches="tight")

# Generate Progress.md with additional sections
with open('docs/Progress.md', 'w') as f:
    sys.stdout = f
    print("""
## Overall Status
* <span style="color:green">Green</a>: All tests passing
* <span style="color:blue">Blue</a>: Most tests passing
* <span style="color:#fee12b">Yellow</a>: Some tests passing
* <span style="color:red">Red</a>: No tests passing
* <span style="color:grey">Grey</a>: Skipped or Tests are not enabled

![image info](./images/progress.png)

## Overall Status Breakdown
![image info](./images/quality.png)
""")

    print("\n## Projects with skipped or no tests (grey)")
    for x, y in sorted(statusPerPort.items(), key=lambda x: x[1]):
        if y == -1:
            print(f"* [{x}](https://github.com/zopencommunity/{x})")

    print("\n## Projects with the most dependencies\n")
    print("| Package | # of Dependent Projects | Test Success Rate | Dependent projects")
    print("|---|---|---|--|")
    for x, y in sorted(dependentOn.items(), reverse=True, key=lambda x: len(x[1])):
        status = statusPerPort[x]
        if status == -1:
            status = "Skipped"
        elif status == -2:
            status = "No builds"
        else:
            status = f"{status:.1f}%"
        print(f"| [{x}](https://github.com/zopencommunity/{x}) | {len(y)} | {status} |" + ", ".join(str(e) for e in y))

    print("\n## Projects with the most patches\n")
    print("| Package | # of Patched Lines | # of Patches")
    print("|---|---|--|")
    for x, y in sorted(totalPatchLinesPerPort.items(), reverse=True, key=lambda x: x[1]):
        patches = patchesPerPort[x]
        patchLines = totalPatchLinesPerPort[x]
        checkMark = ""
        if patches == 0:
            checkMark = "&#10003;"
        print(f"| {checkMark} [{x}](https://github.com/zopencommunity/{x}) | {patchLines} | {patches}")

    print("\nLast updated: ", todaysDate)
