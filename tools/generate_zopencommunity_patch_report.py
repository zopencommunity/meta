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

# --- History Analysis (Git Log) ---

def analyze_repo_history(repo_path, since_date):
    """
    Use Git log to find when *.patch files were added (A) or removed (D)
    since the specified date – including events from any candidate directory.
    For each event, if the file path starts with one of the candidate directories
    (stable-patches/, dev-patches/, patches/), the candidate prefix is removed so
    that file identity is based solely on the relative path.
    
    Rename events (status starting with "R") are skipped.
    
    Returns a list of events:
      { 'file': <relative file path>, 'delta': <+LOC or -LOC>, 'date': <commit_date> }.
    """
    events = []
    since_str = since_date.strftime("%Y-%m-%d")
    try:
        output = subprocess.check_output(
            ["git", "log", "-M", f"--since={since_str}", "--diff-filter=ADR",
             "--pretty=format:commit:%H|%ct", "--name-status", "--", "*.patch"],
            cwd=repo_path, text=True, errors="ignore"
        )
    except subprocess.CalledProcessError as e:
        print(f"Error running git log in {repo_path}: {e}")
        return events

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
            file_name = parts[-1]  # Works for both A/D and R cases.
            # Skip rename events.
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
            try:
                if action == "A":
                    file_content = subprocess.check_output(
                        ["git", "show", f"{current_commit_hash}:{file_name}"],
                        cwd=repo_path, text=True, errors="ignore"
                    )
                    loc = len(file_content.splitlines())
                    delta = loc
                elif action == "D":
                    file_content = subprocess.check_output(
                        ["git", "show", f"{current_commit_hash}^:{file_name}"],
                        cwd=repo_path, text=True, errors="ignore"
                    )
                    loc = len(file_content.splitlines())
                    delta = -loc
                else:
                    continue
            except subprocess.CalledProcessError:
                loc = 0
                delta = 0
            events.append({
                'file': relative_file,
                'delta': delta,
                'date': commit_date,
            })
    # Sort events chronologically.
    events.sort(key=lambda e: e['date'])
    return events

# --- Current Patch Listing ---

def analyze_current_patches(repo_path):
    """
    Scan the current branch for patch files in any candidate directory.
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
            for file in glob.glob(os.path.join(candidate_path, "*.patch")):
                rel = os.path.basename(file)
                if rel not in patches or priority < patches[rel]['priority']:
                    try:
                        with open(file, 'r', encoding='utf-8', errors='ignore') as f:
                            lines = f.readlines()
                        loc = len(lines)
                    except Exception as e:
                        print(f"Error reading {file}: {e}")
                        loc = 0
                    patches[rel] = {'file': file, 'loc': loc, 'relative': rel, 'priority': priority}
    total_loc = sum(p['loc'] for p in patches.values())
    return list(patches.values()), total_loc

# --- Cumulative Trend Graph (Based on Git History) ---

def generate_cumulative_trend(repo_path, repo_name, images_dir):
    """
    Generate a cumulative trend graph (based on Git history) for a repository.
    The graph shows the net cumulative number of lines (additions minus deletions)
    in *.patch files (with directory prefix removed) from the inception of the repo to now.
    """
    origin_date = get_repo_origin_date(repo_path)
    if origin_date is None:
        start_date = datetime.date(2022, 4, 4)
    else:
        start_date = origin_date
    print(f"For repo {repo_name}, using start date: {start_date}")
    events = analyze_repo_history(repo_path, start_date)
    if not events:
        print(f"No patch history for {repo_name} since {start_date}")
        return None, []
    # Group events by year-month.
    monthly = {}
    for event in events:
        ym = event['date'].strftime("%Y-%m")
        monthly[ym] = monthly.get(ym, 0) + event['delta']
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
    cum_sum = 0
    for ym in months:
        date_obj = datetime.datetime.strptime(ym, "%Y-%m")
        x.append(date_obj)
        cum_sum += monthly.get(ym, 0)
        y_vals.append(cum_sum)
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.plot(x, y_vals, marker='o')
    ax.set_xlabel("Date")
    ax.set_ylabel("Cumulative LOC in .patch files")
    ax.set_title(f"Cumulative Patch LOC Trend for {repo_name}")
    fig.autofmt_xdate()
    plt.tight_layout()
    image_filename = f"{repo_name}_cumulative_trend.png"
    graph_file = os.path.join(images_dir, image_filename)
    plt.savefig(graph_file)
    plt.close(fig)
    return image_filename, events

def generate_overall_cumulative_trend(all_events, images_dir):
    """
    Generate an overall cumulative trend graph from all events across repos.
    """
    if not all_events:
        print("No patch events for overall cumulative trend.")
        return None
    monthly = {}
    for event in all_events:
        ym = event['date'].strftime("%Y-%m")
        monthly[ym] = monthly.get(ym, 0) + event['delta']
    earliest = min(event['date'] for event in all_events)
    start_date = max(datetime.date(2023, 1, 1), earliest)
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
    cum_sum = 0
    for ym in months:
        date_obj = datetime.datetime.strptime(ym, "%Y-%m")
        x.append(date_obj)
        cum_sum += monthly.get(ym, 0)
        y_vals.append(cum_sum)
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.plot(x, y_vals, marker='o')
    ax.set_xlabel("Date")
    ax.set_ylabel("Cumulative LOC in .patch files")
    ax.set_title("Overall Cumulative Patch LOC Trend")
    fig.autofmt_xdate()
    plt.tight_layout()
    overall_filename = "overall_cumulative_trend.png"
    graph_file = os.path.join(images_dir, overall_filename)
    plt.savefig(graph_file)
    plt.close(fig)
    return overall_filename

# --- Markdown Report Generation ---

def normalize_anchor(name):
    """
    Normalizes a repository name for use as a Markdown anchor.
    """
    return "repo-" + "".join(ch if ch.isalnum() or ch=="-" else "-" for ch in name.lower())

def generate_combined_markdown_report(repos_data, overall_cumulative_graph, report_file, images_rel_path):
    """
    Generate a combined Markdown report that includes:
      - An overall summary with the overall cumulative trend graph.
      - A repository breakdown table with columns: Repository, Lines of Code, # of Patch files.
        Repository names are links to their detailed sections.
      - Detailed sections for each repository.
    """
    # Sort repositories by current LOC (descending)
    repos_data.sort(key=lambda r: r['current_loc'], reverse=True)
    total_patches = sum(len(repo['current_patches']) for repo in repos_data)
    total_loc = sum(repo['current_loc'] for repo in repos_data)
    
    md = "# Upstream Report\n\n"
    md += "## Overall Summary\n\n"
    md += f"**Total Lines of Code (Current):** {total_loc}  \n"
    md += f"**Total # of Patch files:** {total_patches}\n\n"
    
    if overall_cumulative_graph:
        md += "### Overall Cumulative Trend Graph\n\n"
        md += f"![Overall Cumulative Trend]({images_rel_path}/{overall_cumulative_graph})\n\n"
    
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
        if repo.get('cumulative_trend'):
            md += "### Cumulative Trend Graph (Based on Git History)\n\n"
            md += f"![Cumulative Trend]({images_rel_path}/{repo['cumulative_trend']})\n\n"
        md += "### Current Patch Details\n\n"
        md += "| File | LOC |\n"
        md += "| --- | --- |\n"
        for patch in repo['current_patches']:
            md += f"| {patch['relative']} | {patch['loc']} |\n"
        md += "\n### Historical Patch Event Details\n\n"
        md += "| Commit Date | File | Delta LOC |\n"
        md += "| --- | --- | --- |\n"
        for event in repo['events']:
            md += f"| {event['date']} | {event['file']} | {event['delta']} |\n"
        md += "\n---\n\n"
    
    with open(report_file, 'w', encoding='utf-8') as f:
        f.write(md)
    print(f"Combined Markdown report generated at: {report_file}")
    return report_file

# --- Main ---

def main():
    parser = argparse.ArgumentParser(
        description="Clone all repos from github.com/zopencommunity that end with 'port', "
                    "analyze Git history (from 2023 or repo origin) for *.patch file events (additions, deletions, renames), "
                    "normalize file paths (ignoring the top-level patch directory), and generate a cumulative trend graph "
                    "and a combined Markdown report."
    )
    parser.add_argument(
        "--report", default="docs/upstreamstatus.md",
        help="Path for the output Markdown report (default: docs/upstreamstatus.md)"
    )
    parser.add_argument(
        "--images", default="docs/images/upstream",
        help="Directory for output images (default: docs/images/upstream)"
    )
    args = parser.parse_args()
    
    report_file = args.report
    images_dir = args.images
    os.makedirs(images_dir, exist_ok=True)
    os.makedirs(os.path.dirname(report_file), exist_ok=True)
    
    repos_data = []
    all_events = []
    
    with tempfile.TemporaryDirectory() as clone_dir:
        print(f"Cloning repositories into temporary directory: {clone_dir}")
        clone_org_repos(clone_dir, org="zopencommunity")
        
        for item in os.listdir(clone_dir):
            repo_path = os.path.join(clone_dir, item)
            if os.path.isdir(repo_path):
                print(f"Processing repository: {item}")
                image_filename, events = generate_cumulative_trend(repo_path, item, images_dir)
                current_patches, current_loc = analyze_current_patches(repo_path)
                repos_data.append({
                    'name': item,
                    'cumulative_trend': image_filename,
                    'events': events,
                    'current_patches': current_patches,
                    'current_loc': current_loc,
                })
                all_events.extend(events)
        
        overall_cumulative = generate_overall_cumulative_trend(all_events, images_dir) if all_events else None
        images_rel_path = "./images/upstream"
        generate_combined_markdown_report(repos_data, overall_cumulative, report_file, images_rel_path)
        print("Analysis complete. Temporary clone directory will be removed.")

if __name__ == "__main__":
    main()
