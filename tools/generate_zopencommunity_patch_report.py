#!/usr/bin/env python3
# Generate the upstream status page
# Tracks both Lines of Code (LOC) and Patch Count historically.

import os
import glob
import datetime
import argparse
import subprocess
import requests
import tempfile
import matplotlib # Use Agg backend for non-interactive environments
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import calendar
import traceback
import time
import concurrent.futures # For parallelism

# --- Configuration ---
DEFAULT_GITHUB_ORG = "zopencommunity"
DEFAULT_REPORT_FILE = "docs/UpstreamStatus_Checkout_Parallel.md"
DEFAULT_IMAGES_DIR = "docs/images/upstream_checkout_parallel"
DEFAULT_START_DATE_FALLBACK = datetime.date(2020, 1, 1) # Used if no repo origins found and no override
PATCH_DIRS_PRIORITY = [("stable-patches", 1), ("dev-patches", 2), ("patches", 3)] # Highest priority = 1

# --- Git and Patch Analysis Functions ---

# <<< CHANGE: Added repos_list_str parameter >>>
def clone_org_repos(clone_dir, org=DEFAULT_GITHUB_ORG, repos_list_str=None):
    """
    Clones or pulls specified repositories OR all repositories ending with 'port'
    from a GitHub organization.
    """
    print(f"Starting clone_org_repos...")
    github_token = os.environ.get('GITHUB_TOKEN')
    headers = {}
    if github_token: headers['Authorization'] = f'token {github_token}'

    repos_to_process = [] # List to hold repo data ({'name': ..., 'clone_url': ...})
    cloned_count, updated_count, error_count = 0, 0, 0
    git_found = True

    # <<< CHANGE: Logic to handle --repos list >>>
    if repos_list_str:
        repo_names = [name.strip() for name in repos_list_str.split(',') if name.strip()]
        if not repo_names:
             print("ERROR: --repos specified but no repository names found after parsing.")
             return False
        print(f"Processing specified repositories from '--repos': {', '.join(repo_names)}")
        if not org:
             print("ERROR: --org must be specified to construct repository URLs when using --repos.")
             return False # Need org context

        for repo_name in repo_names:
            # Ensure repo_name doesn't already end with .git for API URL
            if repo_name.endswith(".git"): repo_name = repo_name[:-4]

            repo_api_url = f"https://api.github.com/repos/{org}/{repo_name}"
            try:
                print(f"  Fetching details for {org}/{repo_name}...")
                response = requests.get(repo_api_url, headers=headers, timeout=30)
                response.raise_for_status() # Raise HTTPError for bad responses (4xx or 5xx)
                repo_data = response.json()

                # Validate response structure
                if not isinstance(repo_data, dict) or "name" not in repo_data or "clone_url" not in repo_data:
                     print(f"WARNING: Invalid API response structure for {org}/{repo_name}. Skipping.")
                     print(f"Response: {repo_data}")
                     error_count +=1
                     continue # Skip this repo

                # Add the essential info
                repos_to_process.append({
                    'name': repo_data['name'], # Use name from API response for correct casing etc.
                    'clone_url': repo_data['clone_url']
                })
            except requests.exceptions.HTTPError as e:
                 print(f"ERROR: HTTP error fetching details for repository '{org}/{repo_name}': {e.response.status_code} {e.response.reason}")
                 if e.response.status_code == 404:
                      print(f"  Repository '{org}/{repo_name}' not found or not accessible.")
                 else:
                      print(f"  Response body: {e.response.text[:200]}...") # Log part of the response
                 error_count +=1
                 # Continue to try processing other specified repos
            except requests.exceptions.RequestException as e:
                print(f"ERROR: Network or request error fetching details for repository '{org}/{repo_name}': {e}")
                error_count +=1
                # Continue to try processing other specified repos
            except requests.exceptions.JSONDecodeError as e:
                print(f"ERROR: Failed to decode JSON response for repository '{org}/{repo_name}': {e}")
                error_count +=1
                # Continue to try processing other specified repos

    else: # <<< CHANGE: Fallback to original behavior if --repos is not specified >>>
         print(f"Processing all repositories ending with 'port' from organization '{org}'...")
         api_url = f"https://api.github.com/orgs/{org}/repos?per_page=100"
         all_org_repos = []
         skipped_name_count = 0
         fetch_error = False

         while api_url:
            print(f"  Fetching repo list page: {api_url}")
            try:
                response = requests.get(api_url, headers=headers, timeout=30)
                response.raise_for_status()
                data = response.json()
                if not isinstance(data, list):
                     print(f"ERROR: Unexpected API response format from {api_url}. Expected list.")
                     fetch_error = True
                     break
                all_org_repos.extend(data)
            except requests.exceptions.RequestException as e:
                print(f"ERROR: Error fetching repos list from {api_url}: {e}")
                fetch_error = True
                break
            except requests.exceptions.JSONDecodeError as e:
                 print(f"ERROR: Failed to decode JSON response from {api_url}: {e}")
                 fetch_error = True
                 break

            # Handle pagination (GitHub Link header)
            next_url = None
            if "Link" in response.headers:
                links = response.headers["Link"].split(",")
                for link in links:
                    parts = link.split(";")
                    if len(parts) == 2 and 'rel="next"' in parts[1].strip():
                        next_url = parts[0].strip()[1:-1] # Extract URL from <...>
                        break
            api_url = next_url # Continue to next page or None to exit loop

         if not fetch_error:
             # Filter the fetched org repos
             for repo in all_org_repos:
                if not isinstance(repo, dict) or "name" not in repo or "clone_url" not in repo:
                    print(f"WARNING: Skipping invalid repo data item from org list: {repo}")
                    error_count += 1
                    continue
                repo_name = repo["name"]
                if repo_name.endswith("port"):
                    repos_to_process.append({
                        'name': repo['name'],
                        'clone_url': repo['clone_url']
                    })
                else:
                    skipped_name_count += 1
             print(f"Filtered {len(repos_to_process)} repositories ending in 'port'. Skipped {skipped_name_count}.")
         else:
             print("Aborting repository processing due to fetch errors.")
             return False

    # --- Common Cloning/Pulling Logic ---
    if not repos_to_process:
        print("No repositories selected for cloning/updating.")
        # If errors occurred during specific repo fetching, report them
        if repos_list_str and error_count > 0:
             print(f"Encountered {error_count} errors while fetching details for specified repositories.")
             return False # Fail if specific repos couldn't be fetched
        return True # Not an error if filter resulted in zero repos

    print(f"\nAttempting to clone/update {len(repos_to_process)} repositories.")

    for repo in repos_to_process: # Use the populated list
        repo_name = repo["name"]
        clone_url = repo["clone_url"]
        if github_token:
            # Inject token for HTTPS cloning if present
            clone_url = clone_url.replace("https://", f"https://{github_token}@")

        target_dir = os.path.join(clone_dir, repo_name)

        try:
            if not os.path.exists(target_dir):
                print(f"  Cloning {repo_name}...")
                subprocess.run(["git", "clone", "--quiet", clone_url, target_dir],
                               check=True, capture_output=True, text=True, timeout=600)
                cloned_count += 1
            else:
                print(f"  Updating {repo_name}...")
                # Use --ff-only to avoid accidental merges if local history diverged
                # Use --prune to remove stale remote-tracking refs
                subprocess.run(["git", "-C", target_dir, "pull", "--quiet", "--ff-only", "--prune"],
                               check=True, capture_output=True, text=True, timeout=180)
                updated_count += 1
        except subprocess.TimeoutExpired:
            action = "cloning" if not os.path.exists(target_dir) else "pulling"
            print(f"ERROR: Timeout {action} {repo_name}")
            error_count += 1
        except subprocess.CalledProcessError as e:
            action = "cloning" if not os.path.exists(target_dir) else "pulling"
            print(f"ERROR: Git command failed while {action} {repo_name}:")
            stderr_output = e.stderr.strip()
            print(f"  Stderr: {stderr_output}")
            # Check for specific non-fast-forward error during pull
            if "pull" in action and "fatal: Not possible to fast-forward, aborting." in stderr_output:
                 print("  Hint: Local repository history may have diverged. Manual intervention might be needed.")
            error_count += 1
        except FileNotFoundError:
            print("FATAL ERROR: 'git' command not found. Please ensure Git is installed and in your PATH.")
            git_found = False
            break # Cannot continue without git
        except Exception as e:
            action = "cloning" if not os.path.exists(target_dir) else "pulling"
            print(f"ERROR: Unexpected error during {action} {repo_name}: {e}")
            error_count += 1

    print("-" * 20)
    print("Repo Cloning/Update Summary:")
    print(f"  Cloned New: {cloned_count}")
    print(f"  Updated Existing: {updated_count}")
    print(f"  Errors during clone/pull: {error_count}")
    print("-" * 20)

    # If git wasn't found, fail early
    if not git_found:
         return False
    # If specific repos were requested and errors occurred fetching them, return False
    if repos_list_str and error_count > 0:
        # print("Failing due to errors encountered while cloning/pulling specified repositories.")
        # Let's allow analysis to proceed on successfully cloned repos, but report errors.
        pass

    return True # Return True even if some clones failed, so analysis can proceed on others


def analyze_current_patches(repo_path):
    """
    Analyzes patch files in predefined directories within the repo_path.
    Returns a tuple: (list_of_patch_details, total_loc).
    Handles priority if patches exist in multiple locations.
    """
    patches = {}
    total_loc = 0

    for candidate_dir, priority in PATCH_DIRS_PRIORITY:
        candidate_path = os.path.join(repo_path, candidate_dir)
        if os.path.isdir(candidate_path):
            patch_files = glob.glob(os.path.join(candidate_path, "**", "*.patch"), recursive=True)

            for file_path in patch_files:
                if not os.path.isfile(file_path):
                    continue

                try:
                    base_filename = os.path.basename(file_path)

                    if base_filename not in patches or priority < patches[base_filename]['priority']:
                        line_count = 0
                        try:
                            with open(file_path, 'rb') as f:
                                line_count = sum(1 for _ in f)
                        except OSError as e:
                            print(f"      Warning: Error reading/counting lines in {file_path}: {e}")
                            line_count = 0

                        patches[base_filename] = {
                            'file': file_path,
                            'loc': line_count,
                            'relative_repo': os.path.relpath(file_path, repo_path).replace(os.sep, '/'),
                            'priority': priority,
                            'source_dir': candidate_dir
                        }
                except Exception as e:
                       print(f"      Warning: Error processing patch file {file_path}: {e}")

    final_patch_list = list(patches.values())
    total_loc = sum(p['loc'] for p in final_patch_list)

    return final_patch_list, total_loc

def get_repo_origin_date(repo_path):
    """Gets the date of the first commit (returns datetime.datetime)."""
    try:
        git_command = ["git", "rev-list", "--max-parents=0", "HEAD"]
        root_commits = subprocess.run(git_command, cwd=repo_path, capture_output=True, text=True, check=True, timeout=30)
        root_commit_hashes = root_commits.stdout.strip().split("\n")
        if not root_commit_hashes or not root_commit_hashes[0]:
             print(f"      Warning: Could not find root commit for {os.path.basename(repo_path)}")
             return None
        root_commit = root_commit_hashes[0]

        git_command = ["git", "log", "--format=%ct", "-n", "1", root_commit]
        result = subprocess.run(git_command, cwd=repo_path, capture_output=True, text=True, check=True, timeout=30)
        timestamp_str = result.stdout.strip()

        if not timestamp_str:
            return None

        timestamp = int(timestamp_str)
        return datetime.datetime.fromtimestamp(timestamp)
    except (subprocess.TimeoutExpired, subprocess.CalledProcessError, ValueError, FileNotFoundError, IndexError) as e:
        print(f"      Warning: Error getting origin date for {os.path.basename(repo_path)}: {e}")
        return None

def get_default_branch(repo_path):
    """Determines the default branch name (main or master, or falls back)."""
    try:
        for branch in ['main', 'master']:
            try:
                cmd_check_remote = ['git', 'show-ref', '--verify', '--quiet', f'refs/remotes/origin/{branch}']
                subprocess.check_output(cmd_check_remote, cwd=repo_path, stderr=subprocess.DEVNULL)
                try:
                    cmd_check_local = ['git', 'show-ref', '--verify', '--quiet', f'refs/heads/{branch}']
                    subprocess.check_output(cmd_check_local, cwd=repo_path, stderr=subprocess.DEVNULL)
                except subprocess.CalledProcessError:
                     cmd_check_head = ['git', 'symbolic-ref', '--quiet', 'HEAD']
                     head_ref = subprocess.check_output(cmd_check_head, cwd=repo_path, text=True, stderr=subprocess.DEVNULL).strip()
                     if head_ref != f'refs/heads/{branch}':
                          continue
                return branch
            except subprocess.CalledProcessError:
                continue

        try:
             cmd_remote_head = ['git', 'symbolic-ref', 'refs/remotes/origin/HEAD']
             result_remote = subprocess.run(cmd_remote_head, cwd=repo_path, capture_output=True, text=True, check=True, timeout=15)
             remote_head = result_remote.stdout.strip()
             if remote_head.startswith('refs/remotes/origin/'):
                 branch = remote_head.split('/')[-1]
                 cmd_check_local = ['git', 'show-ref', '--verify', '--quiet', f'refs/heads/{branch}']
                 subprocess.check_output(cmd_check_local, cwd=repo_path, stderr=subprocess.DEVNULL)
                 print(f"        Detected default branch '{branch}' via remote HEAD for {os.path.basename(repo_path)}")
                 return branch
        except (subprocess.TimeoutExpired, subprocess.CalledProcessError):
             pass

        print(f"        ERROR: Could not determine default branch for {os.path.basename(repo_path)} after checking main, master, and origin/HEAD.")
        return None
    except (subprocess.TimeoutExpired, subprocess.CalledProcessError, FileNotFoundError) as e:
        print(f"        ERROR: Failed to get default branch for {os.path.basename(repo_path)}: {e}")
        return None


def get_commit_hash_for_date(repo_path, target_date, branch_name):
    """
    Finds the latest commit hash on the specified branch on or before the target_date.
    target_date should be a datetime.date object.
    """
    if not branch_name:
        print(f"ERROR [{os.path.basename(repo_path)}]: get_commit_hash_for_date called with no branch name.")
        return None
    try:
        target_dt = datetime.datetime.combine(target_date, datetime.time(23, 59, 59))
        before_timestamp = int(target_dt.replace(tzinfo=datetime.timezone.utc).timestamp())

        cmd = ['git', 'rev-list', '-n', '1', f'--before={before_timestamp}', branch_name]
        result = subprocess.run(cmd, cwd=repo_path, capture_output=True, text=True, check=True, timeout=30)

        commit_hash = result.stdout.strip()
        return commit_hash if commit_hash else None
    except subprocess.TimeoutExpired:
        print(f"Timeout getting commit hash for {os.path.basename(repo_path)} before {target_date} on branch {branch_name}")
        return None
    except subprocess.CalledProcessError as e:
        # This can happen if the branch didn't exist at that time, which is expected for new repos. Don't log as error.
        # print(f"Debug: No commit found for {os.path.basename(repo_path)} before {target_date} on branch {branch_name}")
        return None
    except Exception as e:
        print(f"Unexpected error in get_commit_hash_for_date for {os.path.basename(repo_path)}: {e}")
        return None


def get_patch_data_for_commit(repo_path, commit_hash, default_branch_to_restore):
    """
    Checks out a specific commit, analyzes patches, returns (patch_count, total_loc).
    Attempts to restore the original branch afterwards.
    Returns (-1, -1) on failure.
    """
    patch_count = -1
    total_loc = -1
    original_state_restored = False
    repo_basename = os.path.basename(repo_path)

    if not commit_hash:
         print(f"ERROR [{repo_basename}]: get_patch_data_for_commit called with no commit hash.")
         return -1, -1
    if not default_branch_to_restore:
         print(f"ERROR [{repo_basename}]: get_patch_data_for_commit called without default branch to restore.")
         return -1, -1

    try:
        checkout_cmd = ['git', 'checkout', '--quiet', commit_hash]
        subprocess.run(checkout_cmd, cwd=repo_path, check=True, timeout=60,
                       stderr=subprocess.PIPE, stdout=subprocess.PIPE)

        patches_list, total_loc_at_commit = analyze_current_patches(repo_path)
        patch_count = len(patches_list)
        total_loc = total_loc_at_commit

    except subprocess.TimeoutExpired as e:
        print(f"ERROR [{repo_basename}]: Timeout checking out commit {commit_hash[:7]}. Err: {e}")
    except subprocess.CalledProcessError as e:
        print(f"ERROR [{repo_basename}]: Failed checking out commit {commit_hash[:7]}. Err: {e.stderr.decode(errors='ignore').strip()}")
    except Exception as e:
        print(f"ERROR [{repo_basename}]: Exception during patch analysis at commit {commit_hash[:7]}: {e}")
    finally:
        try:
            restore_cmd = ['git', 'checkout', '--quiet', default_branch_to_restore]
            subprocess.run(restore_cmd, cwd=repo_path, check=True, timeout=60,
                           stderr=subprocess.PIPE, stdout=subprocess.PIPE)
            original_state_restored = True
        except Exception as e:
            print(f"FATAL ERROR [{repo_basename}]: Failed to restore branch {default_branch_to_restore} after checking out {commit_hash[:7]}. Err: {e}")
            print("  Further analysis for this repository might be compromised.")
            patch_count = -1
            total_loc = -1

    return patch_count, total_loc

# --- Parallel Task Function ---

def process_repo_history(repo_name, repo_path, default_branch, origin_datetime, time_points):
    """
    Worker function (runs in parallel) to process historical patch count & LOC for one repo.
    """
    pid = os.getpid()
    print(f"[PID {pid}] Processing history for: {repo_name} ({len(time_points)} months)")

    repo_monthly_data = {}
    last_commit_hash = None
    last_count = 0
    last_loc = 0

    if not default_branch:
         print(f"[PID {pid}] Skipping history for {repo_name} - could not determine default branch.")
         return repo_name, {}

    origin_date_only = origin_datetime.date() if origin_datetime else None

    try:
        subprocess.run(['git', 'checkout', '--quiet', default_branch], cwd=repo_path, check=True, timeout=30, stderr=subprocess.PIPE, stdout=subprocess.PIPE)
    except Exception as e:
        print(f"[PID {pid}] ERROR: Could not checkout default branch {default_branch} for {repo_name} before history loop. Skipping. Error: {e}")
        return repo_name, {}

    checkout_error_count = 0
    for i, (plot_dt, calc_date) in enumerate(time_points):
        month_key = calc_date.strftime('%Y-%m')
        current_count = 0
        current_loc = 0

        if origin_date_only and calc_date < origin_date_only:
            current_count = 0
            current_loc = 0
        else:
            commit_hash = get_commit_hash_for_date(repo_path, calc_date, default_branch)

            if commit_hash:
                if commit_hash == last_commit_hash:
                    current_count = last_count
                    current_loc = last_loc
                else:
                    count_at_commit, loc_at_commit = get_patch_data_for_commit(repo_path, commit_hash, default_branch)

                    if count_at_commit == -1 or loc_at_commit == -1:
                        print(f"[PID {pid}] WARNING [{repo_name}]: Error getting data for {month_key} (commit {commit_hash[:7]}). Using last known values ({last_count}, {last_loc}).")
                        current_count = last_count
                        current_loc = last_loc
                        checkout_error_count += 1
                    else:
                        current_count = count_at_commit
                        current_loc = loc_at_commit
                        last_count = current_count
                        last_loc = current_loc
                        last_commit_hash = commit_hash
            else:
                current_count = 0
                current_loc = 0
                last_commit_hash = None

        repo_monthly_data[month_key] = {'count': current_count, 'loc': current_loc}

    try:
        subprocess.run(['git', 'checkout', '--quiet', default_branch], cwd=repo_path, check=True, timeout=30, stderr=subprocess.PIPE, stdout=subprocess.PIPE)
    except Exception:
        pass

    print(f"[PID {pid}] Finished history for: {repo_name}. Checkout/analysis errors encountered: {checkout_error_count}")
    return repo_name, repo_monthly_data


# --- Graphing Functions ---

def get_monthly_time_points(start_date, end_date):
    """
    Generates list of (first_day_datetime, last_day_date) tuples for each month.
    """
    points = []
    if not start_date or not end_date or start_date > end_date:
        print(f"ERROR: Invalid start/end date for get_monthly_time_points. Start: {start_date}, End: {end_date}")
        return points

    current_year, current_month = start_date.year, start_date.month

    while True:
        try:
             plot_dt = datetime.datetime(current_year, current_month, 1)
        except ValueError:
             print(f"ERROR: Invalid date generated: {current_year}-{current_month}-01")
             break

        _, last_day_of_month = calendar.monthrange(current_year, current_month)
        calc_date = datetime.date(current_year, current_month, last_day_of_month)

        if calc_date >= end_date:
            last_plot_dt = datetime.datetime(end_date.year, end_date.month, 1)
            if not points or points[-1][0] < last_plot_dt:
                points.append((last_plot_dt, end_date))
            elif points:
                points[-1] = (points[-1][0], end_date)
            break

        points.append((plot_dt, calc_date))

        current_month += 1
        if current_month > 12:
            current_month = 1
            current_year += 1

    return points

def _extract_graph_data(repos_data, time_points, data_key):
    """
    Extracts specific data ('loc', 'count', 'loc_avg', 'count_avg') for plotting.
    """
    x_plot_dates = [tp[0] for tp in time_points]
    y_values = []
    valid_data_found = False
    is_average = data_key.endswith('_avg')
    base_data_key = data_key.replace('_avg', '')

    for plot_dt, calc_date in time_points:
        month_key = calc_date.strftime('%Y-%m')
        value = 0
        if isinstance(repos_data, list): # Overall/Average graphs
            monthly_total = 0
            active_repos_this_month = 0
            for repo in repos_data:
                repo_month_data = repo.get('monthly_data', {}).get(month_key, {})
                repo_val = repo_month_data.get(base_data_key, 0) # Default to 0 if missing

                if repo_val >= 0 : # Handle potential -1 from previous logic if still present
                    monthly_total += repo_val
                    repo_origin_datetime = repo.get('origin_date')
                    repo_origin_date_only = repo_origin_datetime.date() if repo_origin_datetime else None

                    if repo_origin_date_only is None or calc_date >= repo_origin_date_only:
                        active_repos_this_month += 1

            if is_average:
                 value = monthly_total / active_repos_this_month if active_repos_this_month > 0 else 0
            else:
                 value = monthly_total

        elif isinstance(repos_data, dict): # Individual repo graph
            repo_month_data = repos_data.get('monthly_data', {}).get(month_key, {})
            value = repo_month_data.get(base_data_key, 0) # Default to 0

        y_val = max(0, value) # Ensure non-negative
        y_values.append(y_val)
        if y_val > 0:
            valid_data_found = True

    return x_plot_dates, y_values, valid_data_found


def _generate_trend_graph(x_dates, y_values, title, ylabel, image_filename, images_dir, color='tab:blue', is_count=False):
    """Internal function to generate and save a matplotlib graph."""
    graph_basename = os.path.basename(image_filename) # For logging
    if not x_dates or not y_values:
        print(f"    Skipping graph '{graph_basename}' - No data.")
        return None
    if not any(y > 0 for y in y_values):
        print(f"    Skipping graph '{graph_basename}' - All values are zero.")
        return None

    fig, ax = plt.subplots(figsize=(12, 6))
    if 'Repository:' in title:
         fig.set_size_inches(10, 5)

    ax.plot(x_dates, y_values, marker='.', linestyle='-', markersize=4, color=color)
    ax.set_xlabel("Date")
    ax.set_ylabel(ylabel)
    ax.set_title(title)
    ax.grid(True, axis='y', linestyle='--', linewidth=0.5)

    ax.xaxis.set_major_locator(mdates.AutoDateLocator(minticks=5, maxticks=12))
    ax.xaxis.set_major_formatter(mdates.ConciseDateFormatter(ax.xaxis.get_major_locator()))
    fig.autofmt_xdate(rotation=30, ha='right')

    max_y = max(y_values) if y_values else 0
    ax.set_ylim(bottom=0, top=max_y * 1.1 + 5)
    if is_count and max_y > 0 and max_y < 50:
         ax.yaxis.set_major_locator(plt.MaxNLocator(integer=True, min_n_ticks=3))

    plt.tight_layout()
    graph_file = os.path.join(images_dir, image_filename)

    try:
        plt.savefig(graph_file)
        # print(f"       Saved graph: {graph_basename}") # Verbose logging if needed
        return image_filename
    except Exception as e:
        print(f"ERROR: Failed to save graph {graph_file}: {e}")
        return None
    finally:
        plt.close(fig)


# <<< Function added back for pie chart >>>
def generate_loc_distribution_pie_chart(counts, labels, image_filename, images_dir):
    """Generates and saves a pie chart for LoC distribution."""
    print("Generating LoC distribution pie chart...")

    if sum(counts) == 0:
        print("  Skipping LoC distribution pie chart - All counts are zero.")
        return None

    filtered_counts = []
    filtered_labels = []
    for count, label in zip(counts, labels):
        if count > 0:
            filtered_counts.append(count)
            filtered_labels.append(f"{label}\n({count} repos)")

    if not filtered_counts:
         print("  Skipping LoC distribution pie chart - No non-zero counts after filtering.")
         return None

    fig, ax = plt.subplots(figsize=(8, 8))
    colors = plt.cm.Paired(range(len(filtered_counts))) # Use a color map

    wedges, texts, autotexts = ax.pie(filtered_counts, labels=filtered_labels, autopct='%1.1f%%',
            startangle=140, colors=colors, pctdistance=0.85)

    # Improve label readability
    plt.setp(autotexts, size=8, weight="bold", color="white")
    plt.setp(texts, size=9)


    ax.axis('equal')
    ax.set_title('Repository Distribution by Current Patch LoC')
    plt.tight_layout()

    graph_file = os.path.join(images_dir, image_filename)

    try:
        plt.savefig(graph_file)
        print(f"  Saved graph: {os.path.basename(image_filename)}")
        return image_filename
    except Exception as e:
        print(f"ERROR: Failed to save pie chart {graph_file}: {e}")
        return None
    finally:
        plt.close(fig)


def generate_current_patch_loc_trend(repo_data, images_dir, time_points):
    repo_name = repo_data['name']
    x_dates, y_values, valid = _extract_graph_data(repo_data, time_points, 'loc')
    if not valid: return None
    safe_repo_name = "".join(c if c.isalnum() else '_' for c in repo_name)
    filename = f"{safe_repo_name}_current_loc_trend.png"
    title = f"Repository: {repo_name}\nTrend of Current Patch LOC"
    ylabel = "Total LOC of Patches"
    return _generate_trend_graph(x_dates, y_values, title, ylabel, filename, images_dir, color='tab:blue')

def generate_current_patch_count_trend(repo_data, images_dir, time_points):
    repo_name = repo_data['name']
    x_dates, y_values, valid = _extract_graph_data(repo_data, time_points, 'count')
    if not valid: return None
    safe_repo_name = "".join(c if c.isalnum() else '_' for c in repo_name)
    filename = f"{safe_repo_name}_current_count_trend.png"
    title = f"Repository: {repo_name}\nTrend of Current Patch Count"
    ylabel = "Number of Patch Files"
    return _generate_trend_graph(x_dates, y_values, title, ylabel, filename, images_dir, color='tab:orange', is_count=True)

def generate_overall_current_loc_trend(repos_data, images_dir, time_points):
    print("Generating overall LOC trend graph...")
    x_dates, y_values, valid = _extract_graph_data(repos_data, time_points, 'loc')
    if not valid: print("  Skipping overall LOC graph (no valid data)."); return None
    filename = "overall_current_loc_trend.png"
    title = "Overall Trend of Current Patch LOC (All Projects)"
    ylabel = "Total LOC of Patches"
    return _generate_trend_graph(x_dates, y_values, title, ylabel, filename, images_dir, color='tab:blue')

def generate_average_patch_loc_trend(repos_data, images_dir, time_points):
    print("Generating average LOC per project trend graph...")
    x_dates, y_values, valid = _extract_graph_data(repos_data, time_points, 'loc_avg')
    if not valid: print("  Skipping average LOC graph (no valid data)."); return None
    filename = "average_patch_loc_trend.png"
    title = "Trend of Average Patch LOC per Active Project"
    ylabel = "Average LOC of Patches"
    return _generate_trend_graph(x_dates, y_values, title, ylabel, filename, images_dir, color='tab:green')


# --- Markdown Report Generation ---

def normalize_anchor(name):
    anchor = name.lower()
    anchor = "".join(c if c.isalnum() else '-' for c in anchor)
    anchor = '-'.join(filter(None, anchor.split('-')))
    return "repo-" + (anchor if anchor else "unknown")

# Pass loc_pie_chart_graph filename
def generate_combined_markdown_report(
    repos_data,
    overall_loc_graph, average_loc_graph, loc_pie_chart_graph, # Added pie chart filename
    report_file, images_rel_path, time_points
    ):
    """Generates the final Markdown report."""

    print(f"Generating Markdown report: {report_file}...")
    repos_data.sort(key=lambda r: r.get('current_loc', 0), reverse=True)

    total_current_loc = sum(repo.get('current_loc', 0) for repo in repos_data)
    total_current_patch_count = sum(repo.get('current_patch_count', 0) for repo in repos_data)
    num_repos = len(repos_data)
    average_loc_per_repo = total_current_loc / num_repos if num_repos > 0 else 0
    average_count_per_repo = total_current_patch_count / num_repos if num_repos > 0 else 0

    md = f"# Upstream Patch Status Report\n\n"
    # Use current timezone from system if possible
    try:
        current_tz = datetime.datetime.now().astimezone().tzname()
        now_str = datetime.datetime.now().strftime(f'%Y-%m-%d %H:%M:%S {current_tz}')
    except: # Fallback if timezone fails
        now_str = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    md += f"*Report generated on: {now_str}.*\n\n"
    md += "## Overall Summary\n\n"
    md += f"- **Total Projects Analyzed:** {num_repos}\n"
    md += f"- **Total Current Lines of Code (LOC) in Patches:** {total_current_loc:,}\n"
    md += f"- **Total Number of Current Patch Files:** {total_current_patch_count:,}\n"
    md += f"- **Average Current Patch LOC per Project:** {average_loc_per_repo:,.2f}\n"
    md += f"- **Average Current Patch Count per Project:** {average_count_per_repo:,.2f}\n\n"

    md += "### Historical Trends (All Projects)\n\n"

    if average_loc_graph: md += f"![Average Patch LOC Trend]({images_rel_path}/{average_loc_graph})\n"
    else: md += "*(Average patch LOC trend graph not generated)*\n"
    md += "\n"

    if overall_loc_graph: md += f"![Overall Patch LOC Trend]({images_rel_path}/{overall_loc_graph})\n"
    else: md += "*(Overall patch LOC trend graph not generated)*\n"
    md += "\n"

    # Add Pie Chart section
    md += "### Repository LoC Distribution\n\n"
    if loc_pie_chart_graph:
        md += f"![Repository Distribution by LoC]({images_rel_path}/{loc_pie_chart_graph})\n\n"
    else:
        md += "*(LoC distribution pie chart not generated)*\n\n"


    md += "## Repository Breakdown (Sorted by Current Patch LOC)\n\n"
    md += "| Repository | Current Patch LOC | Delta Last Month | # Current Patches |\n"
    md += "|---|:---|:---|:---|\n"

    previous_month_key = None
    if time_points and len(time_points) >= 2:
        previous_month_date = time_points[-2][1]
        previous_month_key = previous_month_date.strftime('%Y-%m')
        print(f"Calculating LOC delta relative to: {previous_month_key}")
    elif time_points and len(time_points) == 1:
        print("Not enough history (only 1 time point) to calculate LOC delta.")
    else:
        print("No historical time points found, cannot calculate LOC delta.")


    if not repos_data:
        md += "| *No repositories found or analyzed* | - | - | - |\n"
    else:
        for repo in repos_data:
            repo_name = repo.get('name', 'Unknown Repo')
            current_loc = repo.get('current_loc', 0)
            current_count = repo.get('current_patch_count', 0)
            anchor = normalize_anchor(repo_name)

            delta_loc_str = "N/A"
            if previous_month_key:
                monthly_data = repo.get('monthly_data', {})
                previous_loc_data = monthly_data.get(previous_month_key, {}) # Get previous month dict
                # Check if the 'loc' key exists and is not None in the previous month's data
                if 'loc' in previous_loc_data and previous_loc_data['loc'] is not None:
                    previous_loc = previous_loc_data['loc']
                    delta_loc = current_loc - previous_loc
                    delta_loc_str = f"{delta_loc:+,}"
                # else: # previous month data exists but 'loc' is missing or None, treat as N/A
                    # delta_loc_str = "N/A" # This is already default

            md += f"| [{repo_name}](#{anchor}) | {current_loc:,} | {delta_loc_str} | {current_count:,} |\n"
    md += "\n"

    md += "---\n\n# Detailed Repository Reports\n\n"
    if not repos_data:
        md += "*No repository data to display.*\n"
    else:
        for repo in repos_data:
            repo_name = repo.get('name', 'Unknown Repo')
            current_loc = repo.get('current_loc', 0)
            current_patches = repo.get('current_patches', [])
            current_count = repo.get('current_patch_count', 0)
            repo_loc_trend_graph = repo.get('repo_loc_trend_graph')
            repo_count_trend_graph = repo.get('repo_count_trend_graph')
            origin_datetime_obj = repo.get('origin_date')
            anchor = normalize_anchor(repo_name)

            md += f"<a id=\"{anchor}\"></a>\n## {repo_name}\n\n"
            md += f"- **Origin Date (First Commit):** {origin_datetime_obj.strftime('%Y-%m-%d') if origin_datetime_obj else 'Unknown'}\n"
            md += f"- **Current Patch LOC:** {current_loc:,}\n"
            md += f"- **Current Patch Count:** {current_count:,}\n\n"

            md += "### Historical Trends\n\n"
            loc_graph_md = "*(Patch LOC trend graph not generated)*"
            if repo_loc_trend_graph:
                loc_graph_md = f"![LOC Trend for {repo_name}]({images_rel_path}/{repo_loc_trend_graph})"

            count_graph_md = "*(Patch count trend graph not generated)*"
            if repo_count_trend_graph:
                count_graph_md = f"![Count Trend for {repo_name}]({images_rel_path}/{repo_count_trend_graph})"

            md += f"{loc_graph_md}\n{count_graph_md}\n\n"


            md += "### Current Patch Details\n\n"
            if current_patches:
                current_patches.sort(key=lambda p: p.get('relative_repo', ''))
                md += "| Patch File (Repo Relative Path) | Source | LOC |\n|---|---|:---|\n"
                for patch in current_patches:
                    relative_path = patch.get('relative_repo', 'N/A')
                    loc = patch.get('loc', 0)
                    source_dir = patch.get('source_dir', '?')
                    md += f"| `{relative_path}` | `{source_dir}` | {loc:,} |\n"
            else:
                md += "*No current patches found in tracked directories (stable-patches, dev-patches, patches).*\n"
            md += "\n---\n\n"

    try:
        with open(report_file, 'w', encoding='utf-8') as f:
            f.write(md)
        print(f"Successfully generated Markdown report: {report_file}")
    except OSError as e:
        print(f"ERROR: Failed writing Markdown report {report_file}: {e}")
    except Exception as e:
        print(f"ERROR: Unexpected error writing report: {e}")
        print(traceback.format_exc())


# --- Main Execution ---

def main():
    parser = argparse.ArgumentParser(
        description="Generate upstream status report using git checkout history (Parallel). Tracks patch LOC and count.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("--org", default=DEFAULT_GITHUB_ORG,
                        help="GitHub organization name (required unless --repos is used effectively).")
    # <<< CHANGE: Added --repos argument >>>
    parser.add_argument("--repos", type=str, default=None,
                        help="Comma-separated list of specific repository names (e.g., 'bashport,jqport') to analyze. Overrides org-wide scan.")
    parser.add_argument("--report", default=DEFAULT_REPORT_FILE, help="Output Markdown report file path")
    parser.add_argument("--images", default=DEFAULT_IMAGES_DIR, help="Directory to save generated graph images")
    parser.add_argument("--start-date", help=f"Manual start date (YYYY-MM-DD) for history analysis. Overrides earliest repo date. Defaults to earliest found or {DEFAULT_START_DATE_FALLBACK}.")
    parser.add_argument("--workers", type=int, default=None, help="Number of parallel worker processes (default: system CPU count)")
    parser.add_argument("--temp-dir", default=None, help="Optional path to a directory for cloning repos (default: system temp dir)")

    args = parser.parse_args()

    start_time = datetime.datetime.now()
    # Use current timezone from system if possible
    try:
        current_tz = datetime.datetime.now().astimezone().tzname()
        now_str_log = datetime.datetime.now().strftime(f'%Y-%m-%d %H:%M:%S {current_tz}')
    except: # Fallback if timezone fails
        now_str_log = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    print(f"Starting Analysis ({now_str_log})")

    # <<< CHANGE: Added reporting for --repos >>>
    if args.repos:
         print(f"Specific Repos: {args.repos}")
         if not args.org:
              print("Warning: --org not specified, but required for constructing repository URLs with --repos. Using default.")
              # Keep default org or consider making org optional if repo list is provided?
              # For now, org is still needed for API calls in clone_org_repos.
    else:
         print(f"GitHub Org: {args.org} (scanning all '*port' repos)")

    print(f"Report File: {args.report}")
    print(f"Images Dir: {args.images}")
    if args.start_date: print(f"Manual Start Date: {args.start_date}")
    print(f"Max Workers: {args.workers if args.workers else 'Default (CPU Count)'}")
    if args.temp_dir: print(f"Using Custom Temp Dir: {args.temp_dir}")

    # --- Setup Directories ---
    try:
        os.makedirs(args.images, exist_ok=True)
        report_dir_path = os.path.dirname(args.report)
        if report_dir_path:
            os.makedirs(report_dir_path, exist_ok=True)
    except OSError as e:
        print(f"ERROR: Failed to create output directories: {e}")
        return 1

    # Calculate relative path for images in Markdown
    images_rel_path = ""
    try:
        report_file_abs = os.path.abspath(args.report)
        report_dir_abs = os.path.dirname(report_file_abs)
        images_dir_abs = os.path.abspath(args.images)
        images_rel_path = os.path.relpath(images_dir_abs, report_dir_abs)
        images_rel_path = images_rel_path.replace(os.sep, '/')
        print(f"Relative image path for Markdown: {images_rel_path}")
    except Exception as e:
        print(f"Warning: Could not determine relative image path cleanly, using basename: {e}")
        images_rel_path = os.path.basename(args.images)

    # --- Parse Optional Start Date ---
    override_start_date = None
    if args.start_date:
        try:
            override_start_date = datetime.datetime.strptime(args.start_date, "%Y-%m-%d").date()
        except ValueError:
            print("ERROR: Invalid --start-date format. Please use YYYY-MM-DD.")
            return 1

    # --- Main Data Structure ---
    repos_data_dict = {}
    temp_dir_context = None

    try:
        # --- Setup Temporary Directory for Clones ---
        if args.temp_dir:
            clone_dir = args.temp_dir
            os.makedirs(clone_dir, exist_ok=True)
            print(f"\nUsing provided directory for clones: {clone_dir}")
        else:
            temp_dir_context = tempfile.TemporaryDirectory(suffix="_upstream_parallel")
            clone_dir = temp_dir_context.name
            print(f"\nCreating temporary directory for clones: {clone_dir}")

        # --- Clone / Update Repositories ---
        print("\n--- Cloning / Updating Repositories ---")
        # <<< CHANGE: Pass args.repos to the function >>>
        if not clone_org_repos(clone_dir, org=args.org, repos_list_str=args.repos):
            # Function now returns False on critical errors (e.g., git not found, major API issues)
            print("Repository cloning/updating failed critically. Exiting.")
            return 1 # Exit with error code if cloning function indicated failure

        # --- Initial Analysis (Current State & History Prep) ---
        print("\n--- Initial Analysis (Current State & Prep) ---")
        repo_dirs = []
        try:
            # List only directories inside the clone_dir
            repo_dirs = [d for d in os.listdir(clone_dir) if os.path.isdir(os.path.join(clone_dir, d))]
        except FileNotFoundError:
             print(f"ERROR: Clone directory '{clone_dir}' not found or inaccessible after clone step.")
             # Attempt cleanup before exiting
             if temp_dir_context: temp_dir_context.cleanup()
             return 1

        total_repos_found_in_dir = len(repo_dirs)
        print(f"Found {total_repos_found_in_dir} potential repository directories to analyze.")
        if total_repos_found_in_dir == 0:
            print("No repositories found in the clone directory to analyze. Generating empty report.")
            generate_combined_markdown_report([], None, None, None, args.report, images_rel_path, []) # Pass None for pie chart
            return 0 # Successful exit, just nothing to do

        all_origin_datetimes = []
        repos_for_history_processing = []
        processed_repo_count = 0

        for repo_name in repo_dirs:
            repo_path = os.path.join(clone_dir, repo_name)
            if not os.path.isdir(os.path.join(repo_path, '.git')):
                # Skip non-git directories that might be present
                continue

            processed_repo_count += 1
            print(f"  Prep ({processed_repo_count}/{total_repos_found_in_dir}): {repo_name}")

            current_patches, current_loc = analyze_current_patches(repo_path)
            current_patch_count = len(current_patches)

            origin_datetime_obj = get_repo_origin_date(repo_path)
            if origin_datetime_obj:
                all_origin_datetimes.append(origin_datetime_obj)

            default_branch = get_default_branch(repo_path)

            initial_data = {
                'name': repo_name, 'path': repo_path, 'origin_date': origin_datetime_obj,
                'default_branch': default_branch, 'current_patches': current_patches,
                'current_loc': current_loc, 'current_patch_count': current_patch_count,
                'monthly_data': {}, 'repo_loc_trend_graph': None, 'repo_count_trend_graph': None,
            }
            repos_data_dict[repo_name] = initial_data

            if default_branch:
                repos_for_history_processing.append({
                    'name': repo_name, 'path': repo_path, 'branch': default_branch, 'origin': origin_datetime_obj
                    })
            else:
                 print(f"      WARNING: Skipping historical analysis for {repo_name} - could not determine default branch.")

        if not repos_data_dict: # Check if any valid repos were actually processed
            print("\nNo valid Git repositories found or prepped after checking directories. Exiting.")
            generate_combined_markdown_report([], None, None, None, args.report, images_rel_path, []) # Pass None for pie chart
            return 0

        if not repos_for_history_processing:
            print("\nWARNING: No repositories could be prepared for historical analysis. Report will only contain current data.")

        # --- Determine Date Range for History ---
        print("\n--- Determining Date Range for Analysis ---")
        graph_start_date = None
        if override_start_date:
            graph_start_date = override_start_date
            print(f"Using provided start date: {graph_start_date}")
        elif all_origin_datetimes:
            earliest_datetime = min(all_origin_datetimes)
            graph_start_date = earliest_datetime.date()
            print(f"Using earliest repository origin date found: {graph_start_date}")
        else:
            graph_start_date = DEFAULT_START_DATE_FALLBACK
            print(f"WARNING: No repository origin dates found. Falling back to default start date: {graph_start_date}")

        if graph_start_date is None:
             print("ERROR: Could not determine a valid start date for analysis.")
             return 1

        today = datetime.date.today()
        if graph_start_date > today:
            print(f"Warning: Start date {graph_start_date} is in the future. Setting start date to today: {today}")
            graph_start_date = today

        graph_end_date = today
        print(f"Analysis date range: {graph_start_date} to {graph_end_date}")

        time_points = get_monthly_time_points(graph_start_date, graph_end_date)
        if not time_points:
            print("ERROR: No time points generated for analysis. Cannot proceed with history.")
            repos_for_history_processing = []
        else:
             print(f"Analyzing {len(time_points)} monthly time points.")

        # --- Collect Historical Data (Parallel) ---
        if repos_for_history_processing:
            print(f"\n--- Collecting Historical Data ({len(repos_for_history_processing)} Repos - Parallel) ---")
            num_workers = args.workers if args.workers and args.workers > 0 else None
            worker_info = f"{num_workers} worker processes" if num_workers else "default number of worker processes"
            print(f"Using up to {worker_info}.")

            futures = []
            results_count = 0
            total_tasks = len(repos_for_history_processing)

            with concurrent.futures.ProcessPoolExecutor(max_workers=num_workers) as executor:
                for repo_info in repos_for_history_processing:
                    future = executor.submit(process_repo_history,
                                             repo_info['name'], repo_info['path'],
                                             repo_info['branch'], repo_info['origin'],
                                             time_points)
                    futures.append(future)

                print(f"Submitted {total_tasks} history analysis tasks. Waiting for completion...")

                for future in concurrent.futures.as_completed(futures):
                    try:
                        repo_name, monthly_data = future.result()
                        if repo_name in repos_data_dict:
                            repos_data_dict[repo_name]['monthly_data'] = monthly_data
                        else:
                            print(f"Warning: Received unexpected result for unknown repo '{repo_name}'")

                        results_count += 1
                        update_interval = max(1, total_tasks // 10)
                        if results_count % update_interval == 0 or results_count == total_tasks:
                            print(f"  ... {results_count} / {total_tasks} repositories' histories processed.")
                    except Exception as exc:
                        print(f'\nERROR: A worker process generated an exception: {exc}')
                        print(traceback.format_exc())

            print(f"Finished collecting historical data. {results_count} results received.")
        else:
             print("\n--- Skipping Historical Data Collection ---")


        # --- Convert dict back to list for graphing/reporting ---
        repos_data_list = list(repos_data_dict.values())

        # --- Explicitly set the LAST data point to the CURRENT HEAD state ---
        print("\n--- Overriding last data point with current HEAD state ---")
        if time_points and repos_data_list:
            last_month_key = time_points[-1][1].strftime('%Y-%m')
            print(f"Overriding data for key: {last_month_key}")
            override_count = 0
            for repo_data in repos_data_list:
                current_loc_head = repo_data.get('current_loc', 0)
                current_count_head = repo_data.get('current_patch_count', 0)
                repo_name = repo_data.get('name', 'Unknown')

                if 'monthly_data' in repo_data:
                     if repo_data['monthly_data'] is None: repo_data['monthly_data'] = {}
                     if last_month_key not in repo_data['monthly_data']:
                          repo_data['monthly_data'][last_month_key] = {'loc': 0, 'count': 0}
                     repo_data['monthly_data'][last_month_key]['loc'] = current_loc_head
                     repo_data['monthly_data'][last_month_key]['count'] = current_count_head
                     override_count += 1

            print(f"Applied current HEAD state override to {override_count} repositories for the final data point.")
        elif not time_points: print("Skipping override: No time points available.")
        else: print("Skipping override: No repository data available.")

        # --- Calculate LoC Distribution Categories ---
        print("\n--- Calculating LoC Distribution Categories ---")
        count_no_patches = 0
        count_lt_100 = 0
        count_ge_100 = 0
        if repos_data_list:
            for repo in repos_data_list:
                loc = repo.get('current_loc', 0)
                if loc == 0: count_no_patches += 1
                elif loc < 100: count_lt_100 += 1
                else: count_ge_100 += 1
            print(f"  Distribution: No Patches={count_no_patches}, <100 LoC={count_lt_100}, >=100 LoC={count_ge_100}")
        else:
            print("  No repository data to categorize.")


        # --- Generate Graphs (using collected data) ---
        print("\n--- Generating Graphs ---")
        overall_loc_graph_file = None
        average_loc_graph_file = None
        loc_pie_chart_file = None

        if not repos_data_list:
            print("No repository data collected, skipping graph generation.")
        else:
            # Generate Pie Chart
            pie_labels = ['No Patches (0 LoC)', '< 100 LoC', '>= 100 LoC']
            pie_counts = [count_no_patches, count_lt_100, count_ge_100]
            loc_pie_chart_file = generate_loc_distribution_pie_chart(
                pie_counts, pie_labels, "overall_loc_distribution_pie.png", args.images
            )

            if not time_points:
                 print("No time points for history, skipping trend graphs.")
            else:
                 overall_loc_graph_file = generate_overall_current_loc_trend(repos_data_list, args.images, time_points)
                 average_loc_graph_file = generate_average_patch_loc_trend(repos_data_list, args.images, time_points)

                 print("Generating individual repository trend graphs...")
                 individual_graphs_generated = 0
                 for repo_data in repos_data_list:
                     if repo_data.get('monthly_data'):
                         loc_graph = generate_current_patch_loc_trend(repo_data, args.images, time_points)
                         count_graph = generate_current_patch_count_trend(repo_data, args.images, time_points)
                         repo_data['repo_loc_trend_graph'] = loc_graph
                         repo_data['repo_count_trend_graph'] = count_graph
                         if loc_graph or count_graph: individual_graphs_generated +=1
                     else:
                         repo_data['repo_loc_trend_graph'] = None
                         repo_data['repo_count_trend_graph'] = None
                 print(f"  Generated trends for {individual_graphs_generated} individual repositories.")


        # --- Generate Final Report ---
        print("\n--- Generating Markdown Report ---")
        generate_combined_markdown_report(
            repos_data_list,
            overall_loc_graph_file, average_loc_graph_file, loc_pie_chart_file, # Pass pie chart
            args.report, images_rel_path, time_points
        )

    except Exception as e:
        print("\n--- An Unexpected Error Occurred During Main Processing ---")
        print(traceback.format_exc())
        # Ensure cleanup happens even on error
        if temp_dir_context:
            try: temp_dir_context.cleanup()
            except Exception as ce: print(f"Warning: Error during cleanup after exception: {ce}")
        return 1 # Indicate failure

    finally:
        # --- Cleanup Temporary Directory ---
        if temp_dir_context:
             try:
                 temp_dir_context.cleanup()
                 print(f"\nTemporary directory {clone_dir} cleaned up.")
             except Exception as e:
                 print(f"Warning: Failed to cleanup temporary directory {clone_dir}. Error: {e}")

        end_time = datetime.datetime.now()
        # Use current timezone from system if possible
        try:
            current_tz = datetime.datetime.now().astimezone().tzname()
            now_str_log = datetime.datetime.now().strftime(f'%Y-%m-%d %H:%M:%S {current_tz}')
        except: # Fallback if timezone fails
            now_str_log = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')

        print(f"\nAnalysis Finished ({now_str_log})")
        print(f"Total execution time: {end_time - start_time}")

    return 0 # Indicate success


if __name__ == "__main__":
    # Add basic check for conflicting arguments? Maybe not needed as --repos overrides.
    exit_code = main()
    exit(exit_code)
