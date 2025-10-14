#!/usr/bin/env python3
import json
import requests
from datetime import datetime # Ensure datetime is imported
import sys
from collections import defaultdict
import matplotlib.pyplot as plt # Keep if still used for other outputs
from matplotlib import rcParams # Keep if still used
import matplotlib as mpl # Keep if still used
import matplotlib.cm as cm # Keep if still used
from github import Github
import os
import re # Ensure re is imported
import subprocess # Keep if still used
import shutil # Keep if still used
from itertools import chain # Keep if still used
rcParams.update({'figure.autolayout': True}) # Keep if still used
import html # For escaping attribute values

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

def get_dependencies(repo):
    """Get dependencies from buildenv file"""
    try:
        response = requests.get(f"https://raw.githubusercontent.com/zopencommunity/{repo.name}/main/buildenv")
        if response.status_code == 200:
            # FIX 1: Use raw string for regex
            matches = re.findall(r'export\s+ZOPEN.*DEPS\s*=\s*"([^"]*)"', response.text)
            dependencies = []
            for match in matches:
                dependencies += match.split()
            return list(set(dependencies))
    except Exception as e:
        print(f"Error getting dependencies for {repo.name}: {str(e)}", file=sys.stderr)
    return []

def write_package_item_html(package_info, category_name):
    pkg_name = package_info['package']
    status = package_info['status']
    success_rate_num = package_info['success_rate']
    latest_release_info = package_info['latest_release']
    latest_asset_info = package_info['latest_asset']
    description = package_info['description'] if package_info['description'] is not None else ""

    success_rate_str = f"{success_rate_num:.1f}%" if success_rate_num >= 0 else "N/A"
    release_tag = latest_release_info['tag_name'].replace('port', '')
    asset_url = latest_asset_info['url'] 
    repo_url = f"https://github.com/zopencommunity/{pkg_name}port"

    # Construct searchable text (same as before)
    searchable_components = [
        pkg_name, status, success_rate_str, release_tag, description, category_name, "port"
    ]
    searchable_text = " ".join(filter(None, searchable_components)) 
    searchable_text_attr = html.escape(searchable_text, quote=True)
    package_name_attr = html.escape(pkg_name, quote=True)

    # Updated HTML structure for CSS Grid
    print(f'<div class="tool-item-filterable" data-package-name="{package_name_attr}" data-searchable-text="{searchable_text_attr}" style="padding: 8px 0; border-bottom: 1px solid #eee;">')
    print(f'  <div class="tool-info-grid">') # This will be our Grid container

    # Grid items with specific classes
    print(f'    <div class="tool-name"><strong><a href="{repo_url}" target="_blank" rel="noopener noreferrer">{html.escape(pkg_name)}</a></strong></div>')
    print(f'    <div class="tool-status">Status: {html.escape(status)}</div>')
    print(f'    <div class="tool-test">Test: {html.escape(success_rate_str)}</div>')
    print(f'    <div class="tool-release"><a href="{asset_url}" target="_blank" rel="noopener noreferrer">{html.escape(release_tag)}</a></div>')
    
    desc_display_text = ""
    if description.strip():
        desc_display_text = html.escape(description)
    # Always print the div for description to maintain grid structure, even if empty.
    # The title attribute will show the full description on hover.
    print(f'    <div class="tool-desc" title="{html.escape(description, quote=True)}">{desc_display_text}</div>')
    
    print(f'  </div>') # Close tool-info-grid
    print(f'</div>\n') # Close tool-item-filterable

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
totalPatchLinesPerPort = {} # This variable is defined but not used in the provided script snippet

github_token = os.getenv('ZOPEN_GITHUB_OAUTH_TOKEN') or os.getenv('GITHUB_TOKEN')
if github_token is None:
    print("error: environment variable ZOPEN_GITHUB_OAUTH_TOKEN or GITHUB_TOKEN must be defined", file=sys.stderr)
    sys.exit(1)

g = Github(github_token)

json_url = "https://raw.githubusercontent.com/ZOSOpenTools/meta/main/docs/api/zopen_releases_latest.json"
response = requests.get(json_url)
data = json.loads(response.text)

# FIX 2: Generate todaysDate using current time
todaysDate = datetime.now().strftime("%Y-%m-%d %H:%M:%S UTC")

# Process the data and organize by categories
# data is expected to have a 'release_data' key at the top level
if 'release_data' not in data:
    print(f"Error: 'release_data' key not found in JSON from {json_url}", file=sys.stderr)
    sys.exit(1)

for package, releases in data['release_data'].items():
    if not releases:
        continue
        
    latest_release = releases[0]
    if not latest_release['assets']: # Check if assets list is empty
        print(f"Warning: No assets found for latest release of {package}. Skipping.", file=sys.stderr)
        continue
    latest_asset = latest_release['assets'][0]
    
    try:
        repo = g.get_repo(f"zopencommunity/{package}port")
    except Exception as e:
        print(f"Error getting repo for {package}port: {e}", file=sys.stderr)
        continue # Skip this package if repo info can't be fetched

    description = repo.description if repo.description else ""
    
    dependencies = get_dependencies(repo)
    if package + "port" not in dependentOn:
        dependentOn[package + "port"] = []
    for dep in dependencies:
        if dep + "port" not in dependentOn:
            dependentOn[dep + "port"] = []
        dependentOn[dep + "port"].append(package)
    
    total_tests = int(latest_asset['total_tests']) if latest_asset.get('total_tests') else 0
    passed_tests = int(latest_asset['passed_tests']) if latest_asset.get('passed_tests') else 0
    
    totalReleases = repo.get_releases().totalCount
    status = get_status_color(passed_tests, total_tests, totalReleases > 0)
    success_rate = get_success_rate(passed_tests, total_tests, totalReleases > 0)

    progressPerStatus[status] += 1
    statusPerPort[package + "port"] = success_rate
    
    current_package_download_count = 0
    for release_item in releases:
        for asset_item in release_item['assets']:
            if 'size' in asset_item and asset_item['size'] is not None:
                try:
                    current_package_download_count += int(asset_item['size'])
                except (ValueError, TypeError):
                    print(f"Warning: Invalid size for asset in {package}: {asset_item.get('name', 'N/A')}", file=sys.stderr)
    download_counts[package + "port"] = current_package_download_count
    
    categories_str = latest_asset.get('categories') if latest_asset.get('categories') else ""
    categories = categories_str.strip().split() if categories_str.strip() else ['uncategorized']
    for category in categories:
        packages_by_category[category].append({
            'package': package,
            'status': status,
            'success_rate': success_rate,
            'latest_release': latest_release,
            'latest_asset': latest_asset,
            'description': description
        })

original_stdout = sys.stdout # Save original stdout
with open('docs/Latest.md', 'w') as f:
    sys.stdout = f 
    print("# zopen community ports\n")
    print("Note: to download the latest packages, use the [zopen package manager](/Guides/QuickStart)\n")

    print("<div>")
    print("  <label for=\"category-filter\">Filter by Category: </label>")
    print("  <select id=\"category-filter\" onchange=\"filterTable()\">") 
    print("    <option value=\"All\">All</option>")
    
    for category_key in sorted(packages_by_category.keys()):
        print(f"    <option value=\"{html.escape(category_key)}\">{html.escape(category_key.title())}</option>")
    
    print("  </select>")
    print("</div>\n")

    print('<div class="tool-search-container" style="margin-top: 15px; margin-bottom: 20px;">')
    print('  <input type="text" id="toolSearchInput" placeholder="Type to search tools by name, description, release, status, etc..." style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box;">')
    print('</div>\n')

    for category_key, packages_list in sorted(packages_by_category.items()):
        print(f"<div class=\"table-category\" data-category=\"{html.escape(category_key)}\">")
        print(f"\n## {html.escape(category_key.title())} \n")
        
        sorted_packages_list = sorted(packages_list, key=lambda x: x['package'].lower())
        
        if not sorted_packages_list:
            print(f"<p><em>No packages currently listed in this category.</em></p>")

        for package_item_info in sorted_packages_list:
            write_package_item_html(package_item_info, category_key) 
        print("</div>\n")

    print('<div id="toolNoResultsMessage" style="display: none; text-align: center; padding: 20px; color: #777; margin-top: 20px;">')
    print('  <p>No tools found matching your search criteria.</p>')
    print('</div>\n')

    print("\nLast updated: ", todaysDate)

sys.stdout = original_stdout # Restore stdout

# --- Matplotlib chart generation code ---
# Ensure this section is uncommented and figures managed if charts are needed.
# Example: For the pie chart
if any(progressPerStatus.values()): # Check if there's data for the chart
    plt.figure() # Create a new figure to avoid overlap if multiple charts are made
    labels_pie = []
    sizes_pie = []
    for x, y in progressPerStatus.items():
        labels_pie.append(x)
        sizes_pie.append(y)
    colors_pie = ['#00FF00','#0000FF','#FFFF00','#FF0000','#AAAAAA','#FF8888'] # Ensure enough colors if statuses change
    plt.title("Current Porting Status")
    # Ensure sizes_pie is not all zeros before calling plt.pie to avoid errors
    if sum(sizes_pie) > 0:
        p_pie, tx_pie, autotexts_pie = plt.pie(sizes_pie, labels=labels_pie, colors=colors_pie, autopct="", shadow=True)
        for i, a_pie in enumerate(autotexts_pie):
            a_pie.set_text("{}".format(sizes_pie[i])) # Display actual counts
    else:
        plt.text(0.5, 0.5, 'No data to display', horizontalalignment='center', verticalalignment='center')
    plt.axis('equal')
    plt.savefig('docs/images/progress.png')
    plt.close() # Close the figure
else:
    print("No data for progress pie chart.", file=sys.stderr)

# --- Bar Chart Generation ---
chart_files = []
active_statusPerPort = {k: v for k, v in statusPerPort.items() if v >= 0}
if active_statusPerPort:
    sorted_ports = sorted(active_statusPerPort.items(), key=lambda item: item[1], reverse=True)
    
    chunk_size = 50
    if len(sorted_ports) == 0:
        num_chunks = 0
    else:
        num_chunks = (len(sorted_ports) + chunk_size - 1) // chunk_size
    
    for i in range(num_chunks):
        chunk = sorted_ports[i * chunk_size:(i + 1) * chunk_size]
        chunk.reverse()
        labels_bar = [item[0] for item in chunk]
        sizes_bar = [item[1] for item in chunk]

        if not labels_bar:
            continue

        fig_bar = plt.figure()
        fig_bar.set_size_inches(20, max(10, len(labels_bar) * 0.4))
        ax_bar = fig_bar.add_axes([0.2, 0.1, 0.7, 0.85])

        col_bar = []
        for val_bar in sizes_bar:
            if val_bar == 100:
                col_bar.append('green')
            elif val_bar >= 75:
                col_bar.append('blue')
            elif val_bar >= 50:
                col_bar.append('#fee12b')
            else:
                col_bar.append('red')

        ax_bar.set_xlabel('Success Rate (%)', fontsize=12)
        title = "Project Test Quality"
        if num_chunks > 1:
            title += f" (Part {i+1}/{num_chunks})"
        ax_bar.set_title(title, fontsize=16)
        ax_bar.tick_params(axis='y', labelsize=10)
        ax_bar.tick_params(axis='x', labelsize=10)

        bars_obj = ax_bar.barh(labels_bar, sizes_bar, color=col_bar, height=0.6, align='center')
        ax_bar.bar_label(bars_obj, fmt='%.1f%%', padding=3, fontsize=8)
        
        chart_filename = f'docs/images/quality_part_{i+1}.png'
        if num_chunks == 1:
            chart_filename = 'docs/images/quality.png'

        plt.savefig(chart_filename, bbox_inches="tight")
        plt.close()
        chart_files.append(chart_filename.replace('docs/', './'))
else:
    print("No data for project quality bar chart.", file=sys.stderr)


# --- Generation of Progress.md ---
with open('docs/Progress.md', 'w') as f_progress:
    sys.stdout = f_progress
    print("""
## Overall Status
* <span style="color:green">Green</span>: All tests passing
* <span style="color:blue">Blue</span>: Most tests passing (>=75%)
* <span style="color:#fee12b">Yellow</span>: Some tests passing (>=50%)
* <span style="color:red">Red</span>: Few or no tests passing (<50%)
* <span style="color:grey">Skipped</span>: Skipped or Tests are not enabled

![image info](./images/progress.png)

## Overall Status Breakdown
""")
    if not chart_files:
        print("No quality chart generated.")
    else:
        for chart_file in chart_files:
            print(f"![image info]({chart_file})")

    print("\n## Projects with skipped or no tests (or no releases resulting in skipped status)")
    count_skipped_no_tests = 0
    for x_prog, y_prog in sorted(statusPerPort.items(), key=lambda item: item[0]): # Sort alphabetically
        if y_prog == -1 or y_prog == -2: # -1 for skipped tests, -2 for no releases
            status_detail = "Tests skipped or not enabled" if y_prog == -1 else "No releases tracked"
            print(f"* [{x_prog}](https://github.com/zopencommunity/{x_prog}) - {status_detail}")
            count_skipped_no_tests +=1
    if count_skipped_no_tests == 0:
        print("All projects have tests enabled and/or releases tracked.")


    print("\n## Projects with the most dependencies\n")
    print("| Package | # of Dependent Projects | Test Success Rate | Dependent projects |") # Added extra pipe for table alignment
    print("|---|---|---|---|") # Adjusted for 4 columns
    # Sort by number of dependents (desc), then alphabetically by package name (asc)
    for x_dep, y_dep_list in sorted(dependentOn.items(), key=lambda item: (-len(item[1]), item[0])):
        status_val = statusPerPort.get(x_dep) # Use .get() for safety
        status_str = ""
        if status_val is None: # Should not happen if all packages are in statusPerPort
            status_str = "Unknown"
        elif status_val == -1:
            status_str = "Skipped"
        elif status_val == -2:
            status_str = "No builds"
        else:
            status_str = f"{status_val:.1f}%"
        
        # Format dependent projects list
        dependent_projects_str = ", ".join(sorted(str(e) for e in y_dep_list)) if y_dep_list else "None"
        print(f"| [{x_dep}](https://github.com/zopencommunity/{x_dep}) | {len(y_dep_list)} | {status_str} | {dependent_projects_str} |")

    print("\nLast updated: ", todaysDate)

sys.stdout = original_stdout # Restore stdout fully at the end
print("Script finished.")
