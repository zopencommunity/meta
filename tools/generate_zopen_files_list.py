#!/usr/bin/env python3
"""
Generates a binary and library files list for each project in a json.

Downloads latest zopen release metadata, downloads the .pax.Z asset,
extracts it directly and lists categorized files (binaries, libs).

Output: zopen_files.json

Requires 'tar' command-line tool capable of handling .Z decompression.
"""

import sys
import os
import json
import argparse
import datetime
import requests
import logging
import tempfile
import subprocess
import shutil
import concurrent.futures
from pathlib import Path

# --- Setup Logging ---
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - [%(threadName)s] [%(funcName)s] %(message)s')
logger = logging.getLogger(__name__)

# --- Constants ---
INPUT_JSON_URL = "https://raw.githubusercontent.com/zopencommunity/meta/main/docs/api/zopen_releases_latest.json"
DEFAULT_OUTPUT_FILE = "zopen__files.json"
DEFAULT_MAX_WORKERS = 4
BINARY_DIRS = ["bin", "sbin", "altbin"]
LIBRARY_PATTERNS = ['*.a', '*.so']
REQUESTS_TIMEOUT = 120
SUBPROCESS_TIMEOUT = 360

# --- Helper Functions ---

def check_command(command_name, required=True):
    """Checks if a command exists in the system PATH. Returns path or None."""
    path = shutil.which(command_name)
    if path is None:
        if required:
            logger.error(f"Fatal Error: Required command '{command_name}' not found in PATH.")
            logger.error("Please install it or ensure it's accessible and supports necessary features (e.g., tar handling .Z).")
        else:
            logger.debug(f"Optional command '{command_name}' not found in PATH.")
        return None
    logger.debug(f"Command '{command_name}' found at: {path}")
    return path

def download_file(url, destination_path):
    """Downloads a file from a URL to a destination path."""
    logger.debug(f"Attempting to download asset '{url}' to '{destination_path}'")
    try:
        with requests.Session() as session:
            with session.get(url, stream=True, timeout=REQUESTS_TIMEOUT) as r:
                r.raise_for_status()
                with open(destination_path, 'wb') as f:
                    for chunk in r.iter_content(chunk_size=8192*4):
                        f.write(chunk)
        if logger.isEnabledFor(logging.DEBUG):
             try:
                  file_size = os.path.getsize(destination_path)
                  logger.debug(f"Successfully downloaded asset '{url}' ({file_size} bytes)")
             except OSError:
                  logger.debug(f"Successfully downloaded asset '{url}' (could not get size)")
        return True
    except requests.exceptions.RequestException as e:
        logger.error(f"Failed to download asset {url}: {e}")
        return False
    except IOError as e:
        logger.error(f"Failed to write downloaded asset file to {destination_path}: {e}")
        return False
    except Exception as e:
        logger.error(f"An unexpected error occurred during download of {url}: {e}", exc_info=logger.isEnabledFor(logging.DEBUG))
        return False

def fetch_input_json(url):
    """Downloads and parses the input JSON data from a URL."""
    logger.info(f"Attempting to download input JSON from: {url}")
    try:
        response = requests.get(url, timeout=REQUESTS_TIMEOUT)
        response.raise_for_status()
        logger.info("Successfully downloaded input JSON data.")
        json_data = json.loads(response.content.decode('utf-8'))
        if logger.isEnabledFor(logging.DEBUG):
             logger.debug(f"Input JSON data (partial): {str(json_data)[:500]}...")
        return json_data
    except requests.exceptions.Timeout: logger.error(f"Timeout downloading input JSON from {url}"); return None
    except requests.exceptions.RequestException as e: logger.error(f"Failed to download input JSON from {url}: {e}"); return None
    except json.JSONDecodeError as e:
        logger.error(f"Failed to parse JSON data downloaded from {url}: {e}")
        if logger.isEnabledFor(logging.DEBUG) and response: logger.debug(f"Response text (partial): {response.text[:500]}...")
        return None
    except Exception as e: logger.error(f"An unexpected error occurred fetching input JSON: {e}", exc_info=logger.isEnabledFor(logging.DEBUG)); return None

def extract_archive(pax_z_file, extract_dir, tar_path):
    """
    Extracts a .pax.Z file directly using tar, assuming tar handles decompression.
    Requires full path to the tar executable.
    """
    pax_z_path = Path(pax_z_file)
    logger.debug(f"Starting direct extraction process for: {pax_z_path} using tar")

    os.makedirs(extract_dir, exist_ok=True)
    extract_success = False

    if not tar_path:
        logger.error("Error: 'tar' command path not provided or found. Cannot extract.")
        return False

    tar_flags = 'xf'

    if logger.isEnabledFor(logging.DEBUG):
        tar_flags = 'xvf' 

    tar_cmd = [tar_path, tar_flags, str(pax_z_path)]

    logger.debug(f"Attempting direct extraction with tar: {' '.join(tar_cmd)} (cwd: '{extract_dir}')")
    try:
        result = subprocess.run(tar_cmd, cwd=extract_dir, capture_output=True, text=True, check=False, timeout=SUBPROCESS_TIMEOUT)

        if logger.isEnabledFor(logging.DEBUG):
            logger.debug(f"Tar Return Code: {result.returncode}")
            if result.stdout: logger.debug(f"Tar Stdout (truncated): {result.stdout.strip()[:2000]}...")
            else: logger.debug("Tar Stdout: (empty)")
            if result.stderr: logger.debug(f"Tar Stderr: {result.stderr.strip()}")
            else: logger.debug("Tar Stderr: (empty)")

        if result.returncode == 0:
            logger.debug(f"Successfully extracted {pax_z_path.name} using tar into {extract_dir}")
            extract_success = True
        else:
            logger.error(f"Direct extraction with tar failed (Return Code: {result.returncode}). Check tar version and capabilities (does it handle .Z?).")
            if not logger.isEnabledFor(logging.DEBUG) and result.stderr:
                logger.error(f"Tar Stderr: {result.stderr.strip()}")

    except FileNotFoundError:
         logger.error(f"Error: 'tar' command not found at '{tar_path}' during execution attempt.")
    except subprocess.TimeoutExpired:
         logger.error(f"Timeout expired while extracting {pax_z_path.name} with tar.")
    except Exception as e:
         logger.error(f"Unexpected error during tar extraction: {e}", exc_info=logger.isEnabledFor(logging.DEBUG))

    if extract_success and logger.isEnabledFor(logging.DEBUG):
        try:
            logger.debug(f"--- Listing top-level contents of extraction directory '{extract_dir}' (extracted using tar):")
            contents = sorted(os.listdir(extract_dir))
            if not contents: logger.debug("    (Directory is empty)")
            else:
                for item_name in contents:
                    item_path = os.path.join(extract_dir, item_name)
                    item_type = "Dir" if os.path.isdir(item_path) else "File" if os.path.isfile(item_path) else "Other"
                    logger.debug(f"    - {item_name} ({item_type})")
            logger.debug("--- End of directory listing ---")
        except OSError as e: logger.debug(f"    (Could not list directory contents: {e})")

    return extract_success


def find_project_files(extract_dir):
    """
    Scans the extracted directory structure, detects the project root,
    and categorizes files into 'binaries' and 'libs'.
    Returns a dictionary: {'binaries': [...], 'libs': [...]}.
    """
    # NOTE: Removed global intermediate_pax_path reference, it's not needed here anymore
    results = {"binaries": set(), "libs": set()}
    extract_path = Path(extract_dir)
    logger.debug(f"Scanning for files, starting from base: '{extract_path}'")

    if not extract_path.is_dir():
        logger.warning(f"Base extraction directory '{extract_path}' does not exist. Cannot scan.")
        return {"binaries": [], "libs": []}

    scan_root = extract_path
    potential_root_dir = None
    try:
        logger.debug(f"Detecting scan root within '{extract_path}':")
        items_in_extract_dir = list(extract_path.iterdir())
        logger.debug(f"  Items found: {[item.name for item in items_in_extract_dir]}")

        # Find the first directory among the items
        for item in items_in_extract_dir:
            if item.is_dir():
                potential_root_dir = item
                logger.debug(f"  Found potential project root directory: '{item.name}'. Setting as scan root.")
                break

        if potential_root_dir is not None:
            scan_root = potential_root_dir
        else:
            logger.debug(f"  No top-level directory found. Using extraction dir itself as scan root.")

    except Exception as e:
        logger.warning(f"Could not reliably detect project root in '{extract_path}' due to error: {e}. Using extraction dir as scan root.", exc_info=logger.isEnabledFor(logging.DEBUG))

    logger.debug(f"Effective scan root set to: '{scan_root}'")

    if not scan_root.is_dir():
        logger.warning(f"Determined scan root '{scan_root}' is not a valid directory. Cannot scan files.")
        return {"binaries": [], "libs": []}

    if logger.isEnabledFor(logging.DEBUG):
         try:
            logger.debug(f"--- Listing contents of effective scan root '{scan_root}':")
            scan_root_contents = sorted(os.listdir(scan_root))
            if not scan_root_contents: logger.debug("    (Scan root directory is empty)")
            else:
                for item_name in scan_root_contents:
                    item_path = os.path.join(scan_root, item_name)
                    item_type = "Dir" if os.path.isdir(item_path) else "File" if os.path.isfile(item_path) else "Other"
                    logger.debug(f"    - {item_name} ({item_type})")
            logger.debug("--- End of scan root listing ---")
         except OSError as e: logger.debug(f"    (Could not list scan root contents: {e})")


    # --- Scan for Binaries ---
    logger.debug(f"Scanning for binaries under {BINARY_DIRS} within '{scan_root}'...")
    for dir_name in BINARY_DIRS:
        target_path = scan_root / dir_name
        if logger.isEnabledFor(logging.DEBUG): logger.debug(f"Checking binary directory: '{target_path}' (Exists: {target_path.is_dir()})")

        if target_path.is_dir():
             try:
                logger.debug(f"Scanning contents of '{target_path}'...")
                for item in target_path.rglob('*'):
                    if item.is_file():
                        binary_name = item.name
                        results["binaries"].add(binary_name)
                        if logger.isEnabledFor(logging.DEBUG):
                             logger.debug(f"  + Found binary: '{binary_name}' (Full path: {item})")
             except Exception as e:
                  logger.error(f"Error scanning binary directory '{target_path}': {e}", exc_info=logger.isEnabledFor(logging.DEBUG))

    # --- Scan for Libraries ---
    logger.debug(f"Scanning for libraries ({LIBRARY_PATTERNS}) within '{scan_root}'...")
    for pattern in LIBRARY_PATTERNS:
        try:
            logger.debug(f"Searching for pattern '{pattern}'...")
            for item in scan_root.rglob(pattern):
                 if item.is_file():
                      lib_name = item.name
                      results["libs"].add(lib_name)
                      if logger.isEnabledFor(logging.DEBUG):
                           try: rel_path = item.relative_to(scan_root)
                           except ValueError: rel_path = item
                           logger.debug(f"  + Found library: '{lib_name}' (Relative path: {rel_path})")
        except Exception as e:
             logger.error(f"Error scanning for library pattern '{pattern}' in '{scan_root}': {e}", exc_info=logger.isEnabledFor(logging.DEBUG))

    sorted_results = {
        "binaries": sorted(list(results["binaries"])),
        "libs": sorted(list(results["libs"]))
    }
    logger.debug(f"Scan complete. Found {len(sorted_results['binaries'])} unique binaries, {len(sorted_results['libs'])} unique libraries.")
    return sorted_results


def process_project(project_name, latest_release_info, tar_path):
    """
    Downloads, extracts (using tar directly), and scans for categorized files.
    Requires tar_path. Returns (project_name, file_dict) or (project_name, None).
    """
    logger.info(f"Processing project: {project_name}")

    # --- Find Asset URL ---
    if not latest_release_info: logger.warning(f"No release info for {project_name}. Skipping."); return project_name, None
    pax_asset_url = None
    pax_asset_name = None
    try:
        if not isinstance(latest_release_info, list) or not latest_release_info: raise TypeError("Expected list")
        release_details = latest_release_info[0]
        assets = release_details.get("assets", [])
        if not assets: logger.warning(f"No assets in latest release for {project_name}. Skipping."); return project_name, None
        logger.debug(f"Found {len(assets)} assets for {project_name}.")
        for asset in assets:
            if not isinstance(asset, dict): continue
            asset_name = asset.get("name")
            asset_url = asset.get("url")
            if logger.isEnabledFor(logging.DEBUG): logger.debug(f"  - Checking asset: '{asset_name}'")
            if asset_name and asset_name.endswith(".pax.Z"):
                pax_asset_url = asset_url; pax_asset_name = asset_name
                logger.debug(f"    -> Found matching pax asset: '{pax_asset_name}'")
                break
        if not pax_asset_url: logger.warning(f"No '.pax.Z' asset found for {project_name}. Skipping."); return project_name, None
    except (IndexError, TypeError, KeyError) as e: logger.warning(f"Error parsing release info for {project_name}: {e}. Skipping.", exc_info=logger.isEnabledFor(logging.DEBUG)); return project_name, None

    # --- Process within Temporary Directory ---
    try:
        with tempfile.TemporaryDirectory(prefix=f"zopen_{project_name}_") as temp_dir:
            logger.debug(f"Created temporary directory: {temp_dir}")
            pax_z_local_path = os.path.join(temp_dir, pax_asset_name)

            # 1. Download Asset
            if not download_file(pax_asset_url, pax_z_local_path):
                logger.error(f"Download failed for {pax_asset_name} ({project_name}).")
                return project_name, None

            # 2. Extract Asset 
            extract_sub_dir = os.path.join(temp_dir, "extracted")
            if not extract_archive(pax_z_local_path, extract_sub_dir, tar_path): # Pass only tar_path
                logger.error(f"Extraction failed for {pax_asset_name} ({project_name}).")
                return project_name, None

            # 3. Scan for categorized files
            categorized_files = find_project_files(extract_sub_dir)

            bin_count = len(categorized_files.get("binaries", []))
            lib_count = len(categorized_files.get("libs", []))
            if bin_count > 0 or lib_count > 0:
                 logger.info(f"Successfully processed {project_name}. Found: {bin_count} binaries, {lib_count} libs.")
            else:
                 logger.info(f"Successfully processed {project_name}, but found 0 binaries and 0 libs matching criteria.")

            return project_name, categorized_files

    except Exception as e:
         logger.error(f"Unexpected error processing project {project_name}: {e}", exc_info=logger.isEnabledFor(logging.DEBUG))
         return project_name, None

# --- Argument Parsing ---
parser = argparse.ArgumentParser(
    description='Generates JSON list of bin/sbin files in latest zopen releases.',
    formatter_class=argparse.ArgumentDefaultsHelpFormatter
)
parser.add_argument(
    '-o', '--output-file',
    default=DEFAULT_OUTPUT_FILE,
    help='Path to store the output JSON file listing categorized files.'
)
parser.add_argument(
    '-w', '--max-workers',
    type=int,
    default=DEFAULT_MAX_WORKERS,
    help='Maximum number of concurrent threads for download/extraction.'
)
parser.add_argument(
    '--verbose',
    action='store_true',
    help='Enable verbose (DEBUG level) logging for detailed diagnostics.'
)
args = parser.parse_args()

# --- Set Logging Level ---
log_level = logging.DEBUG if args.verbose else logging.INFO
logger.setLevel(log_level)
if args.verbose: logger.info("Verbose (DEBUG) logging enabled.")

# --- Pre-checks for Tools ---
logger.info("Checking for required command-line tools...")
# Now only tar is required
tar_exe = check_command("tar", required=True)

if not tar_exe:
    # Error logged by check_command
    logger.error("Please ensure 'tar' is installed and supports .Z decompression (like GNU tar).")
    sys.exit(1)

# --- Main Execution ---
logger.info(f"Starting processing. Output: '{args.output_file}', Workers: {args.max_workers}")

# --- Download Input Data ---
input_data = fetch_input_json(INPUT_JSON_URL)
if input_data is None: logger.error("Fatal: Could not get input JSON. Exiting."); sys.exit(1)
release_data = input_data.get("release_data", {})
if not isinstance(release_data, dict) or not release_data: logger.error("Fatal: Invalid or empty 'release_data' in input JSON. Exiting."); sys.exit(1)

# --- Concurrent Processing ---
final_project_files = {}
projects_to_process = list(release_data.items())
total_projects = len(projects_to_process)
processed_count = 0
failed_count = 0

logger.info(f"Found {total_projects} projects. Starting parallel processing...")

with concurrent.futures.ThreadPoolExecutor(max_workers=args.max_workers, thread_name_prefix="proj_worker") as executor:
    future_to_project = {
        # Pass only tar_exe to the worker
        executor.submit(process_project, name, info, tar_exe): name
        for name, info in projects_to_process
    }

    # Process results as they complete
    for future in concurrent.futures.as_completed(future_to_project):
        project_name = future_to_project[future]
        processed_count += 1
        try:
            p_name, file_dict = future.result()
            if file_dict is not None:
                final_project_files[p_name] = file_dict
            else:
                failed_count += 1
        except Exception as exc:
            failed_count += 1
            logger.error(f"Project {project_name} generated exception: {exc}", exc_info=args.verbose)

        if processed_count % 10 == 0 or processed_count == total_projects:
             logger.info(f"Progress: {processed_count}/{total_projects} complete ({failed_count} failed).")

# --- Final Output Generation ---
logger.info("Processing complete. Generating output JSON...")
output_data = {
    "generation_timestamp_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(timespec='seconds') + 'Z',
    "source_input_url": INPUT_JSON_URL,
    "projects_processed_attempt": total_projects,
    "projects_successfully_scanned": total_projects - failed_count,
    "project_files": final_project_files
}
try:
    output_dir = os.path.dirname(args.output_file)
    if output_dir and not os.path.exists(output_dir):
        logger.info(f"Creating output directory: {output_dir}")
        os.makedirs(output_dir, exist_ok=True)
    with open(args.output_file, "w", encoding='utf-8') as json_file:
        json.dump(output_data, json_file, indent=2, ensure_ascii=False)
    logger.info(f"Successfully wrote categorized file list to: {args.output_file}")
except IOError as e: logger.error(f"Fatal: Error writing output file: {e}"); sys.exit(1)
except TypeError as e: logger.error(f"Fatal: Error serializing data to JSON: {e}"); sys.exit(1)

logger.info("--- Summary ---")
logger.info(f"Total projects processed attempt: {total_projects}")
logger.info(f"Projects successfully extracted & scanned: {total_projects - failed_count}")
logger.info(f"Projects failed: {failed_count}")
logger.info(f"Output file generated: {args.output_file}")

if failed_count > 0: logger.warning(f"{failed_count} projects failed. Check logs (--verbose).")
else: logger.info("Script finished successfully.")
sys.exit(0)
