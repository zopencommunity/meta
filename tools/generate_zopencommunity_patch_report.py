#!/usr/bin/env python3
# Generate the upstream status page
import os
import glob
import datetime
import argparse
import subprocess
import requests
import tempfile
import matplotlib.pyplot as plt
import calendar # Import for month range calculation

def clone_org_repos(clone_dir, org="zopencommunity"):
    """
    Query the GitHub API for all repos in the given organization.
    Clone only those repos whose names end with 'port' into clone_dir.
    """
    repos = []
    url = f"https://api.github.com/orgs/{org}/repos?per_page=100"
    while url:
        print(f"Fetching repositories from: {url}")
        response = requests.get(url)
        if response.status_code != 200:
            print(f"Error fetching repos: {response.status_code} - {response.text}")
            break
        data = response.json()
        repos.extend(data)
        if "Link" in response.headers:
            links = response.headers["Link"].split(",")
            next_url = None
            for link in links:
                parts = link.split(";")
                if len(parts) == 2 and 'rel="next"' in parts[1]:
                    next_url = parts[0].strip()[1:-1]
                    break
            url = next_url
        else:
            url = None

    for repo in repos:
        repo_name = repo["name"]
        if repo_name.endswith("port"):
            clone_url = repo["clone_url"]
            target_dir = os.path.join(clone_dir, repo_name)
            if not os.path.exists(target_dir):
                print(f"Cloning {clone_url} into {target_dir}")
                try:
                    subprocess.run(["git", "clone", clone_url, target_dir], check=True)
                except subprocess.CalledProcessError as e:
                    print(f"Error cloning {clone_url}: {e}")
            else:
                print(f"Repository {repo_name} already exists at {target_dir}, skipping clone.")
        else:
            print(f"Skipping {repo['name']} (does not end with 'port').")


def analyze_current_patches(repo_path):
    """
    Scan the current branch for patch files in any candidate directory, including subdirectories.
    When the same patch (same relative file name) appears in more than one directory,
    choose the one from the highest-priority candidate (stable-patches > dev-patches > patches).

    Returns a tuple: (list of patch info, total LOC)
    Each patch info is a dict with:
      'file' (absolute path), 'loc', 'relative' (file name without top-level dir).
    """
    candidates = [("stable-patches", 1), ("dev-patches", 2), ("patches", 3)]
    patches = {}
    total_loc = 0
    for candidate, priority in candidates:
        candidate_path = os.path.join(repo_path, candidate)
        if os.path.isdir(candidate_path):
            # Use recursive globbing to find patches in subdirectories as well
            for file in glob.glob(os.path.join(candidate_path, "**/*.patch"), recursive=True):
                rel_path_candidate = os.path.relpath(file, candidate_path) # Get relative path to candidate dir
                rel = os.path.basename(rel_path_candidate) # Use just the filename for priority comparison
                if rel not in patches or priority < patches[rel]['priority']:
                    try:
                        with open(file, 'r', encoding='utf-8', errors='ignore') as f:
                            lines = f.readlines()
                            loc = len(lines)
                    except Exception as e:
                        print(f"Error reading {file}: {e}")
                        loc = 0
                    patches[rel] = {'file': file, 'loc': loc, 'relative': rel_path_candidate, 'priority': priority} # Store relative path to candidate
    total_loc = sum(p['loc'] for p in patches.values())
    return list(patches.values()), total_loc


def get_repo_origin_date(repo_path):
    """
    Returns the date of the repo's first commit.
    """
    try:
        output = subprocess.check_output(
            ["git", "log", "--reverse", "--format=%ct"],
            cwd=repo_path, text=True, errors="ignore"
        )
        first_line = output.splitlines()[0]
        timestamp = int(first_line.strip())
        return datetime.date.fromtimestamp(timestamp)
    except Exception as e:
        print(f"Error obtaining origin date for {repo_path}: {e}")
        return None

def analyze_repo_history(repo_path, since_date):
    """
    Analyzes git history to track patch lifecycle AND generate delta-based events.

    Returns a tuple: (patch_lifecycles, events)
    - patch_lifecycles: Dictionary (same as before) for current patch LOC trend.
    - events: List of delta-based events (same format as original generate_cumulative_trend).
    """
    patch_lifecycles = {}
    events = [] # List for delta-based events
    since_str = since_date.strftime("%Y-%m-%d")
    try:
        output = subprocess.check_output(
            ["git", "log", "-M", f"--since={since_str}", "--diff-filter=ADR",
             "--pretty=format:commit:%H|%ct", "--name-status", "--", "*.patch"],
            cwd=repo_path, text=True, errors="ignore"
        )
    except subprocess.CalledProcessError as e:
        print(f"Error running git log in {repo_path}: {e}")
        return patch_lifecycles, events  # Return both even if error

    candidates = ["stable-patches/", "dev-patches/", "patches/"]
    current_commit_hash = None
    current_commit_timestamp = None

    for line in output.splitlines():
        if line.startswith("commit:"):
            try:
                parts = line[len("commit:"):].split("|")
                current_commit_hash = parts[0].strip()
                current_commit_timestamp = int(parts[1].strip())
            except Exception:
                current_commit_hash = None
                current_commit_timestamp = None
        elif current_commit_hash:
            parts = line.split("\t")
            if len(parts) < 2:
                continue
            action = parts[0]
            file_name = parts[-1]
            if action.startswith("R"):
                continue

            candidate_found = None
            for cand in candidates:
                if file_name.startswith(cand):
                    candidate_found = cand
                    break
            if not candidate_found:
                continue
            relative_file = file_name[len(candidate_found):]
            commit_date = datetime.date.fromtimestamp(current_commit_timestamp)

            if relative_file not in patch_lifecycles:
                patch_lifecycles[relative_file] = {'added_date': None, 'loc': 0, 'deletion_date': None}

            try:
                if action == "A":
                    file_content = subprocess.check_output(
                        ["git", "show", f"{current_commit_hash}:{file_name}"],
                        cwd=repo_path, text=True, errors="ignore"
                    )
                    loc = len(file_content.splitlines())
                    patch_lifecycles[relative_file]['added_date'] = commit_date
                    patch_lifecycles[relative_file]['loc'] = loc

                    events.append({ # Create 'add' event for overall cumulative trend
                        'date': commit_date,
                        'file': relative_file,
                        'delta': loc
                    })

                elif action == "D":
                    deletion_loc = patch_lifecycles[relative_file]['loc'] # Get LOC at time of addition
                    patch_lifecycles[relative_file]['deletion_date'] = commit_date

                    events.append({ # Create 'delete' event for overall cumulative trend
                        'date': commit_date,
                        'file': relative_file,
                        'delta': -deletion_loc # Negative delta for deletion
                    })

            except subprocess.CalledProcessError:
                pass

    return patch_lifecycles, events # Return both lifecycle data and events


# --- Function to calculate current patch LOC for a given date ---
def get_current_patch_loc_on_date(patch_lifecycles, date):
    """
    Calculates the total LOC of patches that were 'current' on the given date.
    Patches are 'current' if they were added on or before the date and not deleted before the date.
    """
    current_loc = 0
    for patch_info in patch_lifecycles.values():
        added_date = patch_info['added_date']
        deletion_date = patch_info['deletion_date']
        loc = patch_info['loc']

        if added_date and added_date <= date: # Patch was added by or on this date
            if deletion_date is None or deletion_date > date: # Not deleted yet OR deleted after this date
                current_loc += loc
    return current_loc


# --- Revamped Cumulative Trend Graph Function ---

def generate_current_patch_loc_trend(repo_path, repo_name, images_dir, patch_lifecycles):
    """
    Generates a trend graph showing the total LOC of patches current at different points in time.
    """
    origin_date = get_repo_origin_date(repo_path)
    if origin_date is None:
        start_date = datetime.date(2022, 4, 4)
    else:
        start_date = origin_date
    print(f"For repo {repo_name}, using start date: {start_date}")

    if not patch_lifecycles: # No patch history, return empty chart
        print(f"No patch history for {repo_name} since {start_date}")
        return None, []

    current_date = datetime.date.today()
    months = []
    y, m = start_date.year, start_date.month
    while (y < current_date.year) or (y == current_date.year and m <= current_date.month):
        months.append(f"{y}-{m:02d}")
        m += 1
        if m > 12:
            m = 1
            y += 1

    x, y_vals = [], []
    for ym in months:
        date_obj = datetime.datetime.strptime(ym, "%Y-%m")
        end_of_month_date = datetime.date(date_obj.year, date_obj.month, 1) # Get start of month
        # Go to the last day of the month
        month_range = calendar.monthrange(date_obj.year, date_obj.month)
        end_of_month_date = end_of_month_date.replace(day=month_range[1])


        x.append(date_obj)
        current_loc = get_current_patch_loc_on_date(patch_lifecycles, end_of_month_date) # Calculate current LOC for end of month
        y_vals.append(current_loc)

    fig, ax = plt.subplots(figsize=(10, 6))
    ax.plot(x, y_vals, marker='o')
    ax.set_xlabel("Date")
    ax.set_ylabel("Total LOC of Current Patches") # Updated Y-axis label
    ax.set_title(f"Trend of Current Patch LOC for {repo_name}") # Updated title
    fig.autofmt_xdate()
    plt.tight_layout()
    image_filename = f"{repo_name}_current_patch_loc_trend.png" # Updated filename
    graph_file = os.path.join(images_dir, image_filename)
    plt.savefig(graph_file)
    plt.close(fig)
    return image_filename, [] # Events are not directly used in this chart anymore, but keep returning empty list for consistency in main


def generate_overall_cumulative_trend(all_events, images_dir):
    """
    Generates an overall cumulative trend graph from all events across repos.
    """
    if not all_events:
        print("No patch events for overall cumulative trend.")
        return None
    monthly = {}
    for event in all_events:
        ym = event['date'].strftime("%Y-%m")
        monthly[ym] = monthly.get(ym, 0) + event['delta']
    earliest = min(event['date'] for event in all_events)
    start_date = max(datetime.date(2023, 1, 1), earliest) # Keep original start date logic, could be parameterizable
    current_date = datetime.date.today()
    months = []
    y, m = start_date.year, start_date.month
    while (y < current_date.year) or (y == current_date.year and m <= current_date.month):
        months.append(f"{y}-{m:02d}")
        m += 1
        if m > 12:
            m = 1
            y += 1

    x, y_vals = [], []
    cum_sum = 0 # Initialize cumulative sum at zero
    for ym in months:
        date_obj = datetime.datetime.strptime(ym, "%Y-%m")
        x.append(date_obj)
        cum_sum += monthly.get(ym, 0) # Add monthly delta
        y_vals.append(cum_sum)

    fig, ax = plt.subplots(figsize=(10, 6))
    ax.plot(x, y_vals, marker='o')
    ax.set_xlabel("Date")
    ax.set_ylabel("Cumulative LOC in .patch files (Change)") # Clarify Y-axis label
    ax.set_title("Overall Cumulative Patch LOC Trend (Change from Start Date)") # More descriptive title
    fig.autofmt_xdate()
    plt.tight_layout()
    overall_filename = "overall_cumulative_trend.png"
    graph_file = os.path.join(images_dir, overall_filename)
    plt.savefig(graph_file)
    plt.close(fig)
    return overall_filename

def generate_average_patch_loc_trend(repos_data, images_dir):
    """
    Generates a trend graph showing the average patch LOC per project over time.
    """
    if not repos_data:
        print("No repository data to generate average patch LOC trend.")
        return None

    start_date = None
    for repo_data in repos_data:
        repo_start_date = get_repo_origin_date(os.path.join(tempfile.gettempdir(), repo_data['name'])) # Access origin date based on repo data
        if repo_start_date:
            if start_date is None or repo_start_date < start_date:
                start_date = repo_start_date

    if start_date is None:
        start_date = datetime.date(2022, 4, 4) # Default if no repo origin dates found

    current_date = datetime.date.today()
    months = []
    y, m = start_date.year, start_date.month
    while (y < current_date.year) or (y == current_date.year and m <= current_date.month):
        months.append(f"{y}-{m:02d}")
        m += 1
        if m > 12:
            m = 1
            y += 1

    x, y_vals = [], []
    for ym in months:
        date_obj = datetime.datetime.strptime(ym, "%Y-%m")
        end_of_month_date = datetime.date(date_obj.year, date_obj.month, 1)
        month_range = calendar.monthrange(date_obj.year, date_obj.month)
        end_of_month_date = end_of_month_date.replace(day=month_range[1])

        x.append(date_obj)
        total_loc_sum = 0
        num_repos_count = 0
        for repo_data in repos_data: # Iterate through repos_data to calculate total_loc for each repo on date
            repo_patch_lifecycles = repo_data['patch_lifecycles'] # Access patch_lifecycles from repo_data
            repo_loc = get_current_patch_loc_on_date(repo_patch_lifecycles, end_of_month_date)
            total_loc_sum += repo_loc
            num_repos_count += 1

        average_loc = total_loc_sum / num_repos_count if num_repos_count > 0 else 0
        y_vals.append(average_loc)


    fig, ax = plt.subplots(figsize=(10, 6))
    ax.plot(x, y_vals, marker='o')
    ax.set_xlabel("Date")
    ax.set_ylabel("Average Patch LOC per Project")
    ax.set_title("Trend of Average Patch LOC per Project")
    fig.autofmt_xdate()
    plt.tight_layout()
    avg_filename = "average_patch_loc_trend.png"
    graph_file = os.path.join(images_dir, avg_filename)
    plt.savefig(graph_file)
    plt.close(fig)
    return avg_filename


# --- Pie Chart Generation ---
def generate_tools_pie_chart(repos_data, images_dir):
    """
    Generates a pie chart summarizing the distribution of tools by patch LOC.
    Categories: No Patches, 0-100 LOC, >100 LOC.
    """
    no_patches_count = 0
    low_loc_count = 0
    high_loc_count = 0

    for repo in repos_data:
        loc = repo['current_loc']
        if loc == 0:
            no_patches_count += 1
        elif 0 < loc <= 100:
            low_loc_count += 1
        else:
            high_loc_count += 1

    labels = ['No Patches', '0-100 LOC', '>100 LOC']
    sizes = [no_patches_count, low_loc_count, high_loc_count]
    colors = ['lightgray', 'lightcoral', 'lightskyblue']
    explode = (0.1, 0, 0)  # explode 1st slice

    fig, ax = plt.subplots(figsize=(8, 6))
    ax.pie(sizes, explode=explode, labels=labels, colors=colors, autopct='%1.1f%%',
            shadow=True, startangle=140)
    ax.axis('equal')  # Equal aspect ratio ensures that pie is drawn as a circle.
    ax.set_title('Distribution of Tools by Current Patch LOC')

    pie_chart_filename = "tools_patch_loc_distribution.png"
    pie_chart_file = os.path.join(images_dir, pie_chart_filename)
    plt.savefig(pie_chart_file)
    plt.close(fig)
    return pie_chart_filename


# --- Markdown Report Generation ---

def normalize_anchor(name):
    """
    Normalizes a repository name for use as a Markdown anchor.
    """
    return "repo-" + "".join(ch if ch.isalnum() or ch=="-" else "-" for ch in name.lower())

def generate_combined_markdown_report(repos_data, overall_cumulative_graph, average_loc_trend_graph, pie_chart_image, report_file, images_rel_path):
    """
    Generate a combined Markdown report that includes:
      - An overall summary with the overall cumulative trend graph and pie chart.
      - A repository breakdown table with columns: Repository, Lines of Code, # of Patch files.
        Repository names are links to their detailed sections.
      - Detailed sections for each repository.
    """
    # Sort repositories by current LOC (descending)
    repos_data.sort(key=lambda r: r['current_loc'], reverse=True)
    total_patches = sum(len(repo['current_patches']) for repo in repos_data)
    total_loc = sum(repo['current_loc'] for repo in repos_data)
    num_repos = len(repos_data) # Get the number of repositories
    average_loc_per_repo = total_loc / num_repos if num_repos > 0 else 0 # Calculate average, avoid division by zero

    md = "# Upstream Report\n\n"
    md += "## Overall Summary\n\n"
    md += f"**Total Lines of Code (Current):** {total_loc}  \n"
    md += f"**Average Patch LOC per Project:** {average_loc_per_repo:.2f} \n"
    md += f"**Total # of Patch files:** {total_patches}\n\n"

    if overall_cumulative_graph:
        md += "### Overall Cumulative Patch LOC Trend (Net Change)\n\n" # Updated title
        md += f"![Overall Cumulative Patch LOC Trend (Net Change)]({images_rel_path}/{overall_cumulative_graph})\n\n" # Updated alt text

    if average_loc_trend_graph: 
        md += "### Trend of Average Patch LOC per Project\n\n"
        md += f"![Trend of Average Patch LOC per Project]({images_rel_path}/{average_loc_trend_graph})\n\n"

    if pie_chart_image:
        md += "### Tool Patch LOC Distribution\n\n"
        md += f"![Tool Patch LOC Distribution]({images_rel_path}/{pie_chart_image})\n\n"

    md += "## Repository Breakdown (Sorted by Current Lines of Code)\n\n"
    md += "| Repository | Lines of Code | # of Patch files |\n"
    md += "| --- | --- | --- |\n"
    for repo in repos_data:
        anchor = normalize_anchor(repo['name'])
        md += f"| [{repo['name']}](#{anchor}) | {repo['current_loc']} | {len(repo['current_patches'])} |\n"

    md += "\n---\n\n"
    md += "# Detailed Repository Reports\n\n"
    for repo in repos_data:
        anchor = normalize_anchor(repo['name'])
        md += f"<a name=\"{anchor}\"></a>\n"
        md += f"## Repository: {repo['name']}\n\n"
        md += f"**Current Lines of Code:** {repo['current_loc']}  \n"
        md += f"**Current # of Patch files:** {len(repo['current_patches'])}\n\n"
        if repo.get('cumulative_trend'): # Update description for repo-specific trend
            md += "### Trend of Current Patch LOC\n\n"
            md += f"![Current Patch LOC Trend]({images_rel_path}/{repo['cumulative_trend']})\n\n"
        md += "### Current Patch Details\n\n"
        md += "| File | LOC |\n"
        md += "| --- | --- |\n"
        for patch in repo['current_patches']:
            md += f"| {patch['relative']} | {patch['loc']} |\n"
        md += "\n---\n\n"
        md += "\n### Historical Patch Event Details\n\n"
        md += "| Commit Date | File | Delta LOC |\n"
        md += "| --- | --- | --- |\n"
        for event in repo['events']: # Use repo['events'] to populate the table
            md += f"| {event['date']} | {event['file']} | {event['delta']} |\n"
        md += "\n---\n\n"

    with open(report_file, 'w', encoding='utf-8') as f:
        f.write(md)
    print(f"Combined Markdown report generated at: {report_file}")
    return report_file


# --- Main ---

def main():
    parser = argparse.ArgumentParser(
        description="Clone repos, analyze patch lifecycle, and generate reports."
    )
    parser.add_argument(
        "--report", default="docs/upstreamstatus.md",
        help="Path for the output Markdown report"
    )
    parser.add_argument(
        "--images", default="docs/images/upstream",
        help="Directory for output images"
    )
    args = parser.parse_args()

    report_file = args.report
    images_dir = args.images
    os.makedirs(images_dir, exist_ok=True)
    os.makedirs(os.path.dirname(report_file), exist_ok=True)

    repos_data = []
    all_events = [] # Initialize all_events again

    with tempfile.TemporaryDirectory() as clone_dir:
        print(f"Cloning repositories into temporary directory: {clone_dir}")
        clone_org_repos(clone_dir, org="zopencommunity")

        for item in os.listdir(clone_dir):
            repo_path = os.path.join(clone_dir, item)
            if os.path.isdir(repo_path):
                print(f"Processing repository: {item}")
                patch_lifecycles, events = analyze_repo_history(repo_path, get_repo_origin_date(repo_path) or datetime.date(2023, 1, 1)) # Get both lifecycle AND events
                image_filename, _ = generate_current_patch_loc_trend(repo_path, item, images_dir, patch_lifecycles)
                current_patches, current_loc = analyze_current_patches(repo_path)
                repos_data.append({
                    'name': item,
                    'cumulative_trend': image_filename,
                    'events': events, # Now store the events in repo_data
                    'patch_lifecycles': patch_lifecycles, # Store patch_lifecycles for average calculation
                    'current_patches': current_patches,
                    'current_loc': current_loc,
                })
                all_events.extend(events) # Extend the overall all_events list

        overall_cumulative = generate_overall_cumulative_trend(all_events, images_dir) if all_events else None # Call overall cumulative trend graph generation
        average_loc_trend_graph = generate_average_patch_loc_trend(repos_data, images_dir) # Generate average LOC trend graph
        pie_chart_image = generate_tools_pie_chart(repos_data, images_dir)
        images_rel_path = "./images/upstream"
        generate_combined_markdown_report(repos_data, overall_cumulative, average_loc_trend_graph, pie_chart_image, report_file, images_rel_path) # Pass average trend graph filename
        print("Analysis complete. Temporary clone directory will be removed.")


if __name__ == "__main__":
    main()
