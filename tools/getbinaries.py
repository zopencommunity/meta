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
rcParams.update({'figure.autolayout': True})
import html # For escaping attribute values
import urllib.request
import tempfile
import matplotlib.font_manager as fm

def _load_ibm_plex_sans():
    """Download IBM Plex Sans TTF files from the IBM/plex repo and register
    them with matplotlib. Falls back silently to the default sans-serif font
    if the download fails (e.g. no network on the build host)."""
    PLEX_URLS = {
        "IBMPlexSans-Regular":  "https://github.com/IBM/plex/raw/refs/heads/master/packages/plex-sans/fonts/complete/ttf/IBMPlexSans-Regular.ttf",
        "IBMPlexSans-Bold":     "https://github.com/IBM/plex/raw/refs/heads/master/packages/plex-sans/fonts/complete/ttf/IBMPlexSans-Bold.ttf",
        "IBMPlexSans-SemiBold": "https://github.com/IBM/plex/raw/refs/heads/master/packages/plex-sans/fonts/complete/ttf/IBMPlexSans-SemiBold.ttf",
    }
    font_dir = os.path.join(tempfile.gettempdir(), "ibm_plex_fonts")
    os.makedirs(font_dir, exist_ok=True)
    try:
        for name, url in PLEX_URLS.items():
            dest = os.path.join(font_dir, f"{name}.ttf")
            if not os.path.exists(dest):
                urllib.request.urlretrieve(url, dest)
            fm.fontManager.addfont(dest)
        mpl.rcParams['font.family'] = 'IBM Plex Sans'
        print("IBM Plex Sans fonts loaded.", file=sys.stderr)
    except Exception as e:
        print(f"Warning: could not load IBM Plex Sans ({e}), using default font.", file=sys.stderr)

_load_ibm_plex_sans()

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
    "Unreleased": 0,
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
    if totalReleases == 0:
        status = "Unreleased"
        success_rate = -2
    else:
        status = get_status_color(passed_tests, total_tests, True)
        success_rate = get_success_rate(passed_tests, total_tests, True)

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

# --- Matplotlib pie chart generation ---
if any(progressPerStatus.values()):
    STATUS_COLORS = {
        "Green":      "#6abf8a",
        "Blue":       "#7bafd4",
        "Yellow":     "#f0c070",
        "Red":        "#e88080",
        "Skipped":    "#b8bfca",
        "Unreleased": "#c9b8e8",
    }

    # Only include non-zero slices
    items = [(k, v) for k, v in progressPerStatus.items() if v > 0]
    labels_pie  = [k for k, v in items]
    sizes_pie   = [v for k, v in items]
    colors_pie  = [STATUS_COLORS.get(k, "#888888") for k, v in items]
    total       = sum(sizes_pie)
    released    = total - progressPerStatus.get("Unreleased", 0)

    fig, ax = plt.subplots(figsize=(7, 5), facecolor='white')
    fig.subplots_adjust(left=0.0, right=0.6, top=0.9, bottom=0.05)

    wedges, _ = ax.pie(
        sizes_pie,
        labels=None,
        colors=colors_pie,
        startangle=90,
        wedgeprops=dict(width=0.55, edgecolor='white', linewidth=2),  # donut
    )

    # Centre text: released package count
    ax.text(0, 0.08, str(released), ha='center', va='center',
            fontsize=22, fontweight='bold', color='#1f2328')
    ax.text(0, -0.18, 'released',   ha='center', va='center',
            fontsize=10, color='#57606a')

    ax.set_title('Current Porting Status\n(all tracked packages)',
                 fontsize=12, fontweight='bold', color='#1f2328', pad=12)

    # Legend with count + percentage on the right side
    legend_labels = [f"{lbl}  {cnt}  ({cnt/total*100:.1f}%)"
                     for lbl, cnt in zip(labels_pie, sizes_pie)]
    ax.legend(
        wedges, legend_labels,
        loc='center left',
        bbox_to_anchor=(1.05, 0.5),
        fontsize=10,
        frameon=False,
    )

    plt.savefig('docs/images/progress.png', dpi=150, bbox_inches='tight',
                facecolor='white')
    plt.close()
else:
    print("No data for progress pie chart.", file=sys.stderr)

# --- Bar Chart Generation (all packages, strip 'port' suffix from labels) ---
chart_files = []
active_statusPerPort = {k: v for k, v in statusPerPort.items() if v >= 0}
if active_statusPerPort:
    sorted_ports = sorted(active_statusPerPort.items(), key=lambda item: item[1], reverse=True)

    chunk_size = 50
    num_chunks = (len(sorted_ports) + chunk_size - 1) // chunk_size

    for i in range(num_chunks):
        chunk = sorted_ports[i * chunk_size:(i + 1) * chunk_size]
        chunk.reverse()
        # Strip trailing 'port' from labels
        labels_bar = [k[:-4] if k.endswith('port') else k for k in [item[0] for item in chunk]]
        sizes_bar  = [item[1] for item in chunk]

        col_bar = []
        for val_bar in sizes_bar:
            if val_bar == 100:
                col_bar.append('#8ecba5')   # muted sage green
            elif val_bar >= 75:
                col_bar.append('#85b5d9')   # muted steel blue
            elif val_bar >= 50:
                col_bar.append('#eec07a')   # muted amber
            else:
                col_bar.append('#e89090')   # muted soft red

        row_h = 0.32
        fig_h = max(6, len(labels_bar) * row_h + 1.5)
        fig_bar, ax_bar = plt.subplots(figsize=(12, fig_h), facecolor='white')
        fig_bar.subplots_adjust(left=0.18, right=0.92, top=0.94, bottom=0.06)

        bars_obj = ax_bar.barh(
            labels_bar, sizes_bar,
            color=col_bar,
            height=0.6,
            align='center',
            edgecolor='white',
            linewidth=0.5,
        )
        ax_bar.bar_label(bars_obj, fmt='%.1f%%', padding=4, fontsize=8, color='#1f2328')

        ax_bar.set_xlabel('Success Rate (%)', fontsize=11, color='#1f2328')
        title = "Project Test Quality"
        if num_chunks > 1:
            title += f"  (Part {i+1} / {num_chunks})"
        ax_bar.set_title(title, fontsize=13, fontweight='bold', color='#1f2328', pad=10)

        ax_bar.set_xlim(0, 115)
        ax_bar.tick_params(axis='y', labelsize=8.5, colors='#1f2328')
        ax_bar.tick_params(axis='x', labelsize=9,   colors='#57606a')
        ax_bar.spines[['top', 'right']].set_visible(False)
        ax_bar.spines[['left', 'bottom']].set_color('#e5e7eb')
        ax_bar.set_facecolor('#fafafa')
        ax_bar.xaxis.grid(True, color='#e5e7eb', linewidth=0.6, zorder=0)
        ax_bar.set_axisbelow(True)

        chart_filename = f'docs/images/quality_part_{i+1}.png'
        if num_chunks == 1:
            chart_filename = 'docs/images/quality.png'

        plt.savefig(chart_filename, dpi=150, bbox_inches='tight', facecolor='white')
        plt.close()
        chart_files.append(chart_filename.replace('docs/', './'))
else:
    print("No data for project quality bar chart.", file=sys.stderr)


# --- Generation of Progress.md ---
with open('docs/Progress.md', 'w') as f_progress:
    sys.stdout = f_progress
    print(f"*Last updated: {todaysDate}*\n")
    print("""
## Overall Status
* <span style="color:#6abf8a">Green</span>: All tests passing
* <span style="color:#7bafd4">Blue</span>: Most tests passing (>=75%)
* <span style="color:#f0c070">Yellow</span>: Some tests passing (>=50%)
* <span style="color:#e88080">Red</span>: Few or no tests passing (<50%)
* <span style="color:#b8bfca">Skipped</span>: Skipped or Tests are not enabled
* <span style="color:#c9b8e8">Unreleased</span>: No official release yet

![Current Porting Status](./images/progress.png)
""")

    print("## Overall Status Breakdown\n")
    if not chart_files:
        print("No quality chart generated.")
    else:
        for chart_file in chart_files:
            print(f"![Project Test Quality](./images/quality.png)")

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
    print("""<div class="tool-item-filterable" style="padding: 8px 0; border-bottom: 1px solid #eee; font-weight: bold;">
  <div class="tool-info-grid">
    <div class="tool-name">Package</div>
    <div class="tool-status"># of Dependent Projects</div>
    <div class="tool-test">Test Success Rate</div>
    <div class="tool-release">Dependent projects</div>
    <div class="tool-desc"></div>
  </div>
</div>""")

    for x_dep, y_dep_list in sorted(dependentOn.items(), key=lambda item: (-len(item[1]), item[0])):
        status_val = statusPerPort.get(x_dep)
        status_str = ""
        if status_val is None:
            status_str = "Unknown"
        elif status_val == -1:
            status_str = "Skipped"
        elif status_val == -2:
            status_str = "No builds"
        else:
            status_str = f"{status_val:.1f}%"
        
        dependent_projects_str = ", ".join(sorted(str(e) for e in y_dep_list)) if y_dep_list else "None"
        
        print(f'<div class="tool-item-filterable" style="padding: 8px 0; border-bottom: 1px solid #eee;">')
        print(f'  <div class="tool-info-grid">')
        print(f'    <div class="tool-name"><strong><a href="https://github.com/zopencommunity/{x_dep}" target="_blank" rel="noopener noreferrer">{html.escape(x_dep)}</a></strong></div>')
        print(f'    <div class="tool-status">{len(y_dep_list)}</div>')
        print(f'    <div class="tool-test">{html.escape(status_str)}</div>')
        print(f'    <div class="tool-release">{html.escape(dependent_projects_str)}</div>')
        print(f'    <div class="tool-desc"></div>')
        print(f'  </div>')
        print(f'</div>')

    print("\nLast updated: ", todaysDate)

sys.stdout = original_stdout # Restore stdout fully at the end
print("Script finished.")
