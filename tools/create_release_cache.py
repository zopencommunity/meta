"""
GitHub Releases JSON Cache

This tool fetches zopen community releases and metadata from repositories
ending in 'port', processes metadata.json assets within recent releases (2024+),
handles GitHub API rate limiting with retries, includes repository descriptions
in a separate file, and generates minified JSON cache files.
"""

import sys
import multiprocessing
import concurrent.futures
import os
import re
import json
import argparse
import datetime
import requests
import urllib
import urllib.parse
import hashlib
import time
import logging
from functools import wraps

# --- Setup Logging ---
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - [%(threadName)s] [%(funcName)s] %(message)s')
logger = logging.getLogger(__name__)

# --- Constants ---
ORGANIZATION = "zopencommunity"
REPO_SUFFIX_FILTER = "port"
METADATA_ASSET_NAME = "metadata.json"
DEFAULT_MAX_WORKERS = 4 # Default concurrency level

# Retry Configuration for GitHub API calls
MAX_RETRIES = 20             # Max attempts for secondary limit errors
INITIAL_BACKOFF_SECONDS = 180 # Initial wait time for secondary limit retry
MAX_BACKOFF_SECONDS = 300    # Maximum wait time between retries
MIN_RELEASE_YEAR = 2024     # Ignore releases published before this year (can be overridden by arg)
DEFAULT_RELEASE_CACHE_URL = "https://github.com/zopencommunity/meta/releases/download/api-cache/zopen_releases.json"

# --- GitHub Connection & Rate Limiting Logic ---
try:
    # Import necessary PyGithub classes
    from github import Github, GithubException, RateLimitExceededException, BadCredentialsException, UnknownObjectException
except ImportError:
    logger.error("Fatal Error: PyGithub library not found. Please install it (`pip install PyGithub`)")
    sys.exit(1)

def should_log_tracebacks():
    """Return True when stack traces should be included in logs."""
    return logger.isEnabledFor(logging.DEBUG)

def get_github_error_message(error):
    """Extract a readable message from a GitHub exception."""
    err_data = getattr(error, "data", None)
    if isinstance(err_data, dict):
        return str(err_data.get("message", "")).strip()
    if err_data:
        return str(err_data).strip()
    return str(error).strip()

def is_secondary_rate_limit_error(error):
    """Detect GitHub secondary rate limit or abuse-throttling responses."""
    message = get_github_error_message(error).lower()
    return "secondary rate limit" in message or "abuse" in message

def is_primary_rate_limit_error(error):
    """Detect GitHub primary rate limit exhaustion responses."""
    message = get_github_error_message(error).lower()
    if is_secondary_rate_limit_error(error):
        return False
    return "api rate limit exceeded" in message or "rate limit exceeded" in message

# --- !! REVISED DECORATOR START !! ---
def create_github_retry_decorator(github_instance):
    """
    Creates a decorator to handle GitHub API rate limiting (primary & secondary)
    and retries for PyGithub function calls.
    Handles RateLimitExceededException with status 403 using backoff.
    """
    # Basic check to ensure a Github instance is passed
    if not isinstance(github_instance, Github):
         raise TypeError("github_instance must be an initialized PyGithub Github object")

    def decorator(func):
        @wraps(func) # Preserves original function metadata (name, docstring)
        def wrapper(*call_args, **call_kwargs):
            func_name = func.__name__ # Cache for logging clarity
            retries = 0
            backoff_seconds = INITIAL_BACKOFF_SECONDS
            # Loop for retries, allowing MAX_RETRIES attempts *after* the initial call fails
            while retries <= MAX_RETRIES:
                try:
                    # Attempt the actual PyGithub call
                    result = func(*call_args, **call_kwargs)
                    # If successful after retries, log it for info
                    if retries > 0:
                         logger.info(f"Call to {func_name} succeeded after {retries} retries.")
                    return result # Success

                except RateLimitExceededException as e_rate_limit:
                    # --- Handle Rate Limits (Primary or Secondary reported via this exception type) ---
                    logger.warning(f"Rate limit hit calling {func_name} (Status: {e_rate_limit.status}).")

                    # Distinguish between primary quota exhaustion and secondary throttling.
                    is_secondary_limit_behavior = is_secondary_rate_limit_error(e_rate_limit)
                    primary_limit_info_fetched = False
                    sleep_duration = 0

                    if is_primary_rate_limit_error(e_rate_limit) or not is_secondary_limit_behavior:
                        # Attempt to handle as a PRIMARY rate limit (wait for reset)
                        logger.debug(f"Attempting primary rate limit handling (wait for reset) for {func_name}.")
                        try:
                            limits = github_instance.get_rate_limit().core
                            reset_time_naive = limits.reset # PyGithub returns naive datetime in UTC
                            reset_time_utc = reset_time_naive.replace(tzinfo=datetime.timezone.utc) # Make timezone aware
                            now_utc = datetime.datetime.now(datetime.timezone.utc)
                            # Calculate sleep duration, ensure it's positive, add buffer
                            sleep_duration = max(1.0, (reset_time_utc - now_utc).total_seconds()) + 5
                            logger.warning(f"Primary rate limit details: Limit={limits.limit}, Used={limits.used}, Remaining={limits.remaining}. "
                                           f"Waiting for {sleep_duration:.2f} seconds until reset at {reset_time_utc.isoformat()}.")
                            primary_limit_info_fetched = True
                        except Exception as inner_e:
                            # Handle potential errors fetching rate limit info itself (e.g., network issue during check)
                            # Fallback to basic exponential backoff if limit info fetch fails
                            logger.error(f"Error getting rate limit info after hitting non-403 limit for {func_name}: {inner_e}. "
                                         f"Falling back to exponential backoff.", exc_info=should_log_tracebacks())
                            # Force fallback to exponential backoff below
                            is_secondary_limit_behavior = True # Treat as needing backoff if we can't get primary info

                    # --- Apply Wait Strategy ---
                    if primary_limit_info_fetched and not is_secondary_limit_behavior:
                         # Wait for primary limit reset
                         logger.debug(f"Sleeping for primary rate limit reset: {sleep_duration:.2f}s")
                         time.sleep(sleep_duration)
                         # Do not increment 'retries' count here, just wait for the window reset.
                         # Loop will automatically try the call again after sleeping.
                         continue # Explicitly continue to next loop iteration to retry
                    else:
                        # Handle as needing SECONDARY limit behavior (exponential backoff)
                        retries += 1 # Count as a retry attempt
                        if retries > MAX_RETRIES:
                            logger.error(f"Max retries ({MAX_RETRIES}) exceeded for {func_name} after hitting rate limit ({e_rate_limit.status}) and using backoff.")
                            raise e_rate_limit # Re-raise the original exception after max retries

                        # Extract error details if available
                        err_data = e_rate_limit.data if hasattr(e_rate_limit, 'data') else '(no details)'
                        logger.warning(f"Applying exponential backoff for rate limit ({e_rate_limit.status}) on {func_name}. "
                                       f"Retrying in {backoff_seconds:.2f}s... (Attempt {retries}/{MAX_RETRIES}) | Error data: {err_data}")
                        time.sleep(backoff_seconds)
                        # Exponential backoff with cap
                        backoff_seconds = min(MAX_BACKOFF_SECONDS, backoff_seconds * 2)
                        # Continue to next iteration to retry
                        continue

                except GithubException as e_github:
                    # --- Handle OTHER specific Github errors that are NOT RateLimitExceededException ---
                    # Catch potential 403s NOT reported as RateLimitExceededException, OR other errors like 404
                    if e_github.status == 403:
                        err_data = e_github.data if hasattr(e_github, 'data') else '(no details)'
                        if is_primary_rate_limit_error(e_github):
                            logger.debug(f"Attempting primary rate limit handling (wait for reset) for generic 403 in {func_name}.")
                            try:
                                limits = github_instance.get_rate_limit().core
                                reset_time_naive = limits.reset
                                reset_time_utc = reset_time_naive.replace(tzinfo=datetime.timezone.utc)
                                now_utc = datetime.datetime.now(datetime.timezone.utc)
                                sleep_duration = max(1.0, (reset_time_utc - now_utc).total_seconds()) + 5
                                logger.warning(f"Primary rate limit details: Limit={limits.limit}, Used={limits.used}, Remaining={limits.remaining}. "
                                               f"Waiting for {sleep_duration:.2f} seconds until reset at {reset_time_utc.isoformat()}.")
                                time.sleep(sleep_duration)
                                continue
                            except Exception as inner_e:
                                logger.error(f"Error getting rate limit info after hitting generic 403 limit for {func_name}: {inner_e}. "
                                             f"Falling back to exponential backoff.", exc_info=should_log_tracebacks())

                        if is_secondary_rate_limit_error(e_github) or is_primary_rate_limit_error(e_github):
                            retries += 1
                            if retries > MAX_RETRIES:
                                logger.error(f"Max retries ({MAX_RETRIES}) exceeded for {func_name} after hitting generic 403 error.")
                                raise e_github # Re-raise the exception after max retries

                            logger.warning(f"Generic 403 GithubException hit calling {func_name}. "
                                           f"Retrying in {backoff_seconds:.2f}s... (Attempt {retries}/{MAX_RETRIES}) | Error data: {err_data}")
                            time.sleep(backoff_seconds)
                            backoff_seconds = min(MAX_BACKOFF_SECONDS, backoff_seconds * 2)
                            continue # Retry the operation

                        logger.error(f"Unhandled GithubException calling {func_name} (Status: {e_github.status}): {err_data}")
                        raise e_github

                    elif e_github.status == 404:
                         # Usually no point retrying a 404 Not Found
                         logger.error(f"GitHub resource not found (404) calling {func_name} with args: {call_args}, kwargs: {call_kwargs}")
                         raise e_github # Re-raise immediately
                    # Handle other GitHub API errors (e.g., 401 Unauthorized, 5xx Server Errors)
                    else:
                        err_data = e_github.data if hasattr(e_github, 'data') else '(no details)'
                        logger.error(f"Unhandled GithubException calling {func_name} (Status: {e_github.status}): {err_data}")
                        raise e_github # Re-raise other GitHub errors immediately

                except Exception as e_unexpected:
                    # --- Catch any other unexpected errors during the API call attempt ---
                    logger.error(f"Unexpected error calling {func_name}: {e_unexpected}", exc_info=should_log_tracebacks())
                    raise e_unexpected # Re-raise unexpected errors immediately

            # --- End of While Loop ---
            # This point should only be reached if the loop condition (retries <= MAX_RETRIES) becomes false
            # which implies all retry attempts failed.
            logger.error(f"Retry logic completed for {func_name} without success after {MAX_RETRIES} retries.")
            # Re-raise the last caught GithubException if possible, otherwise raise a generic error.
            # For simplicity, raising a generic one here. Could store last exception if needed.
            raise GithubException(status=500, data={"message": f"Max retries exceeded for {func_name}"}, headers=None)

        return wrapper
    return decorator
# --- !! REVISED DECORATOR END !! ---

# --- Argument Parsing ---
parser = argparse.ArgumentParser(
    description='Fetches GitHub release data for zopencommunity/*port repositories, '
                'filters by year, includes descriptions, and generates JSON caches.',
    formatter_class=argparse.ArgumentDefaultsHelpFormatter # Show default values in help message
)
parser.add_argument(
    '--verbose',
    action='store_true',
    help='Enable verbose (DEBUG level) output, including potentially sensitive info like URLs.'
)
parser.add_argument(
    '--output-file',
    dest='output_file',
    required=True,
    help='The full path to store the main JSON file (minified).'
)
parser.add_argument(
    '--max-workers',
    type=int,
    default=DEFAULT_MAX_WORKERS,
    help='Maximum number of concurrent threads to use for fetching release data.'
)
parser.add_argument(
    '--min-year',
    type=int,
    default=MIN_RELEASE_YEAR,
    help='Ignore releases published before this year.'
)
parser.add_argument(
    '--repo',
    dest='single_repo',
    help='Optional. Limit processing/updates to this specific repository name (e.g. curlport).'
)
parser.add_argument(
    '--no-cache',
    action='store_true',
    help='Force a fresh rebuild of the cache, ignoring remote or local cache sources.'
)
parser.add_argument(
    '--cache-input',
    dest='cache_input',
    default=DEFAULT_RELEASE_CACHE_URL,
    help=f'URL or local file path to load baseline release cache from (default: {DEFAULT_RELEASE_CACHE_URL}).'
)
args = parser.parse_args()

# Targeted mode requires an existing cache baseline to preserve other repositories
if args.single_repo and args.no_cache:
    parser.error("--repo (targeted mode) cannot be combined with --no-cache because a baseline cache is required to preserve non-target repositories.")

# Set logging level based on verbosity argument
if args.verbose:
    logger.setLevel(logging.DEBUG)
    logger.debug("Verbose logging enabled.")
    # Optionally increase verbosity of underlying libraries for deep debugging
    # logging.getLogger("urllib3").setLevel(logging.DEBUG)
    # logging.getLogger("requests").setLevel(logging.DEBUG)
else:
    logger.setLevel(logging.INFO)

def parse_date(date_str):
    if not date_str:
        return None
    try:
        if date_str.endswith('Z'):
            date_str = date_str[:-1] + '+00:00'
        return datetime.datetime.fromisoformat(date_str)
    except Exception:
        return None

def compute_release_fingerprint(release_obj):
    """
    Computes a deterministic hash fingerprint of a release and its assets
    to detect if assets or release metadata were modified under the same tag.
    """
    try:
        title = release_obj.title or ""
        pub_date = str(release_obj.published_at or release_obj.created_at or "")
        
        # PyGithub release objects store the raw GitHub JSON in raw_data, which embeds assets
        raw_assets = getattr(release_obj, "raw_data", {}).get("assets", [])
        asset_signatures = []
        for a in raw_assets:
            asset_signatures.append((
                a.get("name", ""),
                a.get("size", 0),
                a.get("updated_at", "")
            ))
        asset_signatures.sort()
        
        fp_data = f"{title}|{pub_date}|{repr(asset_signatures)}"
        return hashlib.sha256(fp_data.encode("utf-8")).hexdigest()
    except Exception as e:
        logger.debug(f"Could not compute release fingerprint: {e}")
        return None

def load_json_source(source):
    """Loads JSON data from either a URL or a local file path."""
    if not source:
        return None
    if source.startswith(('http://', 'https://')):
        logger.info(f"Fetching cache from URL: {source}...")
        headers = {}
        # Security: Only attach Authorization credentials to trusted HTTPS GitHub hosts
        parsed = urllib.parse.urlparse(source)
        if parsed.scheme == 'https' and parsed.hostname in ('api.github.com', 'raw.githubusercontent.com'):
            token = os.getenv('ZOPEN_GITHUB_OAUTH_TOKEN') or os.getenv('GITHUB_TOKEN')
            if token:
                headers['Authorization'] = f"token {token}"
        resp = requests.get(source, headers=headers, timeout=60)
        resp.raise_for_status()
        return resp.json()
    elif os.path.exists(source):
        logger.info(f"Loading cache from local file: {source}...")
        with open(source, 'r', encoding='utf-8') as f:
            return json.load(f)
    else:
        logger.debug(f"Cache source does not exist: {source}")
        return None

# --- Load Existing Cache ---
existing_cache = {}
if not args.no_cache and args.cache_input:
    old_data = None
    try:
        old_data = load_json_source(args.cache_input)
    except Exception as e:
        logger.warning(f"Could not load cache from primary source {args.cache_input}: {e}.")

    # Fallback to local output file if primary source produced no data and differs
    if not old_data and os.path.exists(args.output_file) and args.output_file != args.cache_input:
        try:
            logger.info(f"Falling back to local file: {args.output_file}...")
            old_data = load_json_source(args.output_file)
        except Exception as e_local:
            logger.warning(f"Could not load local fallback cache from {args.output_file}: {e_local}.")

    if old_data:
        for repo, releases in old_data.get("release_data", {}).items():
            for release in releases:
                tag = release.get("tag_name")
                if tag:
                    date_val = release.get("date")
                    if isinstance(date_val, str):
                        release["date"] = parse_date(date_val)
                    existing_cache[(repo, tag)] = release
        logger.info(f"Loaded {len(existing_cache)} cached releases.")
    else:
        logger.info("Starting fresh without cache.")

if args.single_repo and not existing_cache:
    logger.error("Fatal Error: Targeted mode (--repo) requires a valid existing cache baseline to preserve non-target repositories, but no cache was successfully loaded. Please perform a full rebuild without --repo first.")
    sys.exit(1)


# --- Environment Check & GitHub Instance Setup ---
logger.info("Checking environment and initializing GitHub connection...")
github_token = os.getenv('ZOPEN_GITHUB_OAUTH_TOKEN')
if not github_token:
    logger.error("Fatal Error: Environment variable ZOPEN_GITHUB_OAUTH_TOKEN must be defined.")
    sys.exit(1)

try:
    # Initialize Github instance. Disable PyGithub's basic retry. Set a request timeout.
    g = Github(github_token, retry=0, timeout=60)
    # Create the decorator instance using our authenticated 'g' object
    # This decorator will be applied to helper functions below
    github_retry = create_github_retry_decorator(g) # Use the revised decorator

    # --- Decorated Helper Functions for API calls ---
    # These apply the retry logic automatically when called
    @github_retry
    def get_authenticated_user_login(user_obj):
        """Gets login of the user object, applying retry logic."""
        return user_obj.login

    @github_retry
    def get_org_with_retry(org_name):
        """Gets the organization object with retry logic."""
        logger.debug(f"Fetching organization: {org_name}")
        return g.get_organization(org_name)

    @github_retry
    def get_repos_with_retry(org_obj):
        """Gets the list of repository objects for the org with retry logic."""
        logger.debug(f"Fetching repositories for organization: {org_obj.login}")
        # Materialize pagination inside the retry wrapper so later iteration does not bypass retries.
        return list(org_obj.get_repos())

    @github_retry
    def get_single_repo_with_retry(repo_fullname):
        """Gets a single repository with retry logic."""
        logger.debug(f"Fetching repository: {repo_fullname}")
        return g.get_repo(repo_fullname)

    @github_retry
    def get_releases_with_retry(repo_obj):
        """Gets the list of release objects for the repo with retry logic."""
        logger.debug(f"Fetching releases for repository: {repo_obj.name}")
        # Materialize pagination inside the retry wrapper so later iteration does not bypass retries.
        return list(repo_obj.get_releases())

    @github_retry
    def get_assets_with_retry(release_obj):
        """Gets the list of asset objects for the release with retry logic."""
        logger.debug(f"Fetching assets for release tag: {release_obj.tag_name}")
        # Prefer assets already embedded in the release payload to avoid an extra API call per release.
        assets = release_obj.assets
        if isinstance(assets, list):
            return list(assets)
        # Fall back to the dedicated assets endpoint if needed.
        return list(release_obj.get_assets())

    # --- Verify authentication and connectivity ---
    user_login = get_authenticated_user_login(g.get_user())
    logger.info(f"Successfully authenticated to GitHub as: {user_login}")
    # Log initial rate limit status
    try:
        limits = g.get_rate_limit().core
        logger.info(f"Initial primary rate limit: {limits.remaining}/{limits.limit} requests remaining.")
    except Exception as e_rl_init:
        logger.warning(f"Could not retrieve initial rate limit status: {e_rl_init}")


except BadCredentialsException:
    logger.error("Fatal Error: GitHub authentication failed. Check your ZOPEN_GITHUB_OAUTH_TOKEN.")
    sys.exit(1)
except GithubException as e:
     logger.error(f"Fatal Error: GitHub API error during initialization (Status: {e.status}): {e.data if hasattr(e, 'data') else '(no data)'}")
     sys.exit(1)
except Exception as e:
    logger.error(f"Fatal Error: Unexpected error initializing GitHub connection: {e}", exc_info=should_log_tracebacks())
    sys.exit(1)

# --- Core Processing Functions ---

def process_asset(asset):
    """
    Downloads and parses a metadata.json asset to extract release details.
    Handles its own network/parsing errors, independent of GitHub API limits.
    Returns a dictionary of extracted asset data or None if invalid/not metadata.
    """
    # Check if it's the target metadata file by name
    if asset.name != METADATA_ASSET_NAME:
        return None # Skip non-metadata files silently

    logger.debug(f"Found target asset '{asset.name}' (ID: {asset.id}, Size: {asset.size} bytes)")
    download_url = asset.browser_download_url # Get the public download URL

    try:
        # Download the metadata.json asset using requests library
        response = requests.get(download_url, timeout=90) # Generous timeout for download
        response.raise_for_status() # Raise HTTPError for bad responses (4xx or 5xx)
        logger.debug(f"Successfully downloaded {asset.name} from {download_url}")
        # Decode content, assuming UTF-8 which is standard for JSON
        metadata_content = response.content.decode('utf-8')

        # Parse metadata information from JSON content
        metadata_full = json.loads(metadata_content)
        # Expecting structure like {"product": {...}} containing the details
        metadata = metadata_full.get("product", {})
        if not isinstance(metadata, dict) or not metadata:
            logger.warning(f"Metadata file {asset.name} (URL: {download_url}) lacks 'product' key or it's not a dictionary.")
            raise ValueError(f"Metadata file {asset.name} lacks 'product' key or it's not a dictionary.")

        # Check for mandatory 'pax' key within 'product' which names the actual artifact
        pax_file_name = metadata.get("pax")
        if not pax_file_name:
             logger.warning(f"Skipping asset {asset.name} (URL: {download_url}): Required 'pax' key missing in metadata['product']")
             raise ValueError(f"Required 'pax' key missing in metadata['product']")

        # Construct URL for the actual pax file (assumed relative to the release download URL)
        base_url = download_url.rsplit('/', 1)[0] + '/' # Get base URL of the release assets
        full_pax_url = urllib.parse.urljoin(base_url, pax_file_name)

        # Extract other relevant info safely using .get() with defaults
        test_status = metadata.get("test_status", {})
        total_tests = test_status.get("total_tests", -1) # Use -1 or None to indicate missing data
        passed_tests = test_status.get("total_success", -1)

        source_type = metadata.get("source_type")
        # Get commit SHA only if source type is GIT
        sha = metadata.get("community_commitsha") if source_type == "GIT" else None

        runtime_dependencies_list = metadata.get("runtime_dependencies", [])
        # Extract names, ensuring list items are dicts and have 'name' key
        runtime_dependency_names = [
            dep.get("name") for dep in runtime_dependencies_list
            if isinstance(dep, dict) and dep.get("name")
        ]

        # Convert the list of names into a single space-separated string
        runtime_dependencies_string = " ".join(runtime_dependency_names)

        # Build the dictionary containing processed data for this asset
        filtered_asset_data = {
            "name": pax_file_name,
            "url": full_pax_url,
            "version": metadata.get("version"),
            "release": metadata.get("release"),
            "categories": metadata.get("categories"),
            "size": metadata.get("pax_size", 0), # Size of the pax file itself
            "expanded_size": metadata.get("size", 0), # Expanded size on disk
            "runtime_dependencies": runtime_dependencies_string,
            "total_tests": total_tests,
            "passed_tests": passed_tests,
            "community_commitsha": sha
        }
        logger.debug(f"Successfully processed metadata for asset: {asset.name}, found pax file: {pax_file_name}")
        return filtered_asset_data

    # --- Error Handling for download and parsing ---
    except requests.exceptions.Timeout:
         logger.warning(f"Timeout downloading {asset.name} from {download_url}")
         raise
    except requests.exceptions.RequestException as e:
        # Log non-timeout request errors (network issues, HTTP status errors like 404 on download URL)
        logger.warning(f"Failed to download or process {asset.name} from {download_url}: {e}")
        raise
    except json.JSONDecodeError as e:
        # Handle cases where the downloaded file is not valid JSON
        logger.warning(f"Failed to parse JSON from {asset.name} (URL: {download_url}): {e}")
        raise
    except Exception as e:
        # Catch-all for any other unexpected errors during asset processing
        logger.error(f"Unexpected error processing asset {asset.name} (URL: {download_url}): {e}", exc_info=should_log_tracebacks())
        raise

# Process a single GitHub release object
def process_release(repo_name, release_obj):
    """
    Processes assets within a single GitHub release object.
    Uses decorated helper to fetch assets, then calls process_asset for each.
    Returns a tuple: (filtered_release_dict, repo_name, failed_processing).
    The filtered_release_dict contains release metadata and a list of processed assets.
    """
    release_tag = release_obj.tag_name
    cached_release = existing_cache.get((repo_name, release_tag))
    if cached_release:
        cached_fp = cached_release.get("fingerprint")
        current_fp = compute_release_fingerprint(release_obj)
        if cached_fp and current_fp and cached_fp == current_fp:
            logger.debug(f"Cache hit for release '{release_obj.title}' (tag: {release_tag}) in repo: {repo_name}")
            return cached_release, repo_name, False

    release_title = release_obj.title
    logger.debug(f"Processing release '{release_title}' (tag: {release_tag}) for repo: {repo_name}")

    assets = None # Initialize assets to None
    try:
        # Use the decorated helper function to get assets list/iterator with retry logic
        assets = get_assets_with_retry(release_obj)
        # Handle case where asset fetching itself might return None after retries (should be handled by decorator raising exception now)
        # if assets is None: # Check explicit None in case empty list is valid - Decorator should raise now instead of returning None
        #      logger.warning(f"Could not retrieve assets for release '{release_title}' (tag: {release_tag}) in repo {repo_name} after retries.")
        #      return None, repo_name

    except GithubException as e:
        # Catch error if get_assets_with_retry fails definitively after all retries
        logger.error(f"Failed to get assets for release '{release_title}' (tag: {release_tag}) in repo {repo_name} after retries: {e}")
        if cached_release:
            logger.warning(f"Preserving prior valid cached release for '{release_title}' (tag: {release_tag}) in repo {repo_name} after asset fetch failure.")
            return cached_release, repo_name, False
        return None, repo_name, True # Indicate failure for this specific release
    except Exception as e:
        # Catch any other unexpected error during asset fetching
        logger.error(f"Unexpected error fetching assets for release '{release_title}' (tag: {release_tag}) in repo {repo_name}: {e}", exc_info=should_log_tracebacks())
        if cached_release:
            logger.warning(f"Preserving prior valid cached release for '{release_title}' (tag: {release_tag}) in repo {repo_name} after asset fetch error.")
            return cached_release, repo_name, False
        return None, repo_name, True

    # --- Process the assets retrieved ---
    filtered_assets = [] # List to hold successfully processed asset data dicts
    asset_count = 0

    if assets is None:
         logger.warning(f"Asset list is None for release '{release_title}' (tag: {release_tag}) in repo {repo_name}, likely due to prior fetch error.")
         if cached_release:
             logger.warning(f"Preserving prior valid cached release for '{release_title}' (tag: {release_tag}) in repo {repo_name}.")
             return cached_release, repo_name, False
         return None, repo_name, True

    # Iterate defensively in case asset access or parsing still raises unexpectedly.
    try:
        for asset in assets:
            asset_count += 1
            # Process each asset (download metadata.json if applicable, parse)
            filtered_asset_data = process_asset(asset) # Handles its own download/parse errors
            # Add to list if processing was successful and returned data
            if filtered_asset_data:
                filtered_assets.append(filtered_asset_data)
        logger.debug(f"Checked {asset_count} assets in release '{release_title}', found {len(filtered_assets)} matching '{METADATA_ASSET_NAME}' with valid data.")
    except Exception as e:
        logger.error(f"Error occurred while processing assets for release '{release_title}' (tag: {release_tag}) in repo {repo_name}: {e}", exc_info=should_log_tracebacks())
        if cached_release:
            logger.warning(f"Preserving prior valid cached release for '{release_title}' (tag: {release_tag}) in repo {repo_name} after asset processing failure.")
            return cached_release, repo_name, False
        return None, repo_name, True


    # --- Construct final release data ---
    # Only return a structure if we found valid processed assets for this release
    if filtered_assets:
        # Ensure published_at is timezone-aware (it should be from PyGithub, but be safe)
        published_at_dt = release_obj.published_at
        if published_at_dt and published_at_dt.tzinfo is None:
            published_at_dt = published_at_dt.replace(tzinfo=datetime.timezone.utc)

        filtered_release_dict = {
            "name": release_title,
            "date": published_at_dt, # Keep as datetime object for accurate sorting
            "tag_name": release_tag,
            "fingerprint": compute_release_fingerprint(release_obj),
            "assets": filtered_assets  # List of processed asset data dictionaries
        }
        return filtered_release_dict, repo_name, False # Success
    else:
        if cached_release:
            logger.warning(f"Preserving prior valid cached release for '{release_title}' (tag: {release_tag}) in repo {repo_name} because no metadata was extracted.")
            return cached_release, repo_name, False
        # No relevant/processable assets found in this release, return None for the data part
        logger.debug(f"No relevant assets found or processed in release '{release_title}'")
        return None, repo_name, False

# --- Main Execution Logic ---
logger.info(f"Starting processing for organization '{ORGANIZATION}', repo suffix '{REPO_SUFFIX_FILTER}', min year {args.min_year}.")
# Main data structure: { repo_name: [list_of_filtered_releases] }
release_data = {}
# Dictionary to store descriptions { repo_name: description }
repo_descriptions = {}

# If doing a single repo update, pre-populate with existing cache and descriptions
target_project_name = None
if args.single_repo:
    clean_repo = args.single_repo.strip().rstrip('/')
    if clean_repo.endswith('.git'):
        clean_repo = clean_repo[:-4]
    if '/' in clean_repo:
        clean_repo = clean_repo.split('/')[-1]
    if not clean_repo.endswith(REPO_SUFFIX_FILTER):
        clean_repo = f"{clean_repo}{REPO_SUFFIX_FILTER}"
    args.single_repo = clean_repo

    target_project_name = re.sub(rf"{REPO_SUFFIX_FILTER}$", "", args.single_repo)
    logger.info(f"Single repository update mode. Target repository: {args.single_repo} (project: {target_project_name})")
    
    # Pre-populate release_data from existing_cache for all other repos, applying minimum release year filter
    for (repo, tag), release in existing_cache.items():
        if repo != target_project_name:
            rel_date = release.get('date')
            if isinstance(rel_date, str):
                rel_date = parse_date(rel_date)
                release['date'] = rel_date
            if rel_date and isinstance(rel_date, datetime.datetime):
                if rel_date.year < args.min_year:
                    continue
            if repo not in release_data:
                release_data[repo] = []
            release_data[repo].append(release)
            
    # Pre-populate repo_descriptions from descriptions file or URL alongside cache_input
    desc_source = None
    if args.cache_input:
        if args.cache_input.lower().endswith('.json'):
            desc_source = args.cache_input[:-5] + '_descriptions.json'
        else:
            desc_source = args.cache_input + '_descriptions.json'
    else:
        if args.output_file.lower().endswith('.json'):
            desc_source = args.output_file[:-5] + '_descriptions.json'
        else:
            desc_source = args.output_file + '_descriptions.json'

    old_desc_data = None
    try:
        old_desc_data = load_json_source(desc_source)
    except Exception as e:
        logger.warning(f"Could not load descriptions from primary source {desc_source}: {e}")

    # Fallback to local descriptions file alongside output_file if primary source produced no data and differs
    local_output_desc = args.output_file[:-5] + '_descriptions.json' if args.output_file.lower().endswith('.json') else args.output_file + '_descriptions.json'
    if not old_desc_data and os.path.exists(local_output_desc) and desc_source != local_output_desc:
        try:
            logger.info(f"Falling back to local descriptions file: {local_output_desc}")
            old_desc_data = load_json_source(local_output_desc)
        except Exception as e_local:
            logger.warning(f"Could not load fallback descriptions from {local_output_desc}: {e_local}")

    if old_desc_data:
        for repo, desc in old_desc_data.get("descriptions", {}).items():
            if repo != target_project_name:
                repo_descriptions[repo] = desc

    if not repo_descriptions:
        logger.error("Fatal Error: Targeted mode (--repo) requires an existing repository descriptions baseline, but none could be loaded. Please perform a full rebuild without --repo first.")
        sys.exit(1)

# Counters for tracking progress and results
total_repos_processed = 0
skipped_old_releases = 0
skipped_failed_futures = 0
repo_release_fetch_failures = 0
output_write_failures = 0

try:
    # Get the organization object using decorated helper with retries
    org = get_org_with_retry(ORGANIZATION)

    if args.single_repo:
        repo_fullname = f"{ORGANIZATION}/{args.single_repo}"
        logger.info(f"Fetching single repository: {repo_fullname}")
        try:
            repo_obj = get_single_repo_with_retry(repo_fullname)
            repositories = [repo_obj]
        except UnknownObjectException:
            logger.error(f"Repository {repo_fullname} not found on GitHub.")
            sys.exit(1)
    else:
        # Get the repositories iterator using decorated helper with retries
        repositories = get_repos_with_retry(org)
        logger.info(f"Fetching and filtering repositories from '{org.login}'...")

    # Using ThreadPoolExecutor for concurrent processing of releases and fetching of repo releases
    with concurrent.futures.ThreadPoolExecutor(
        max_workers=args.max_workers,
        thread_name_prefix="release_worker" # Helps identify threads in logs
    ) as executor:
        repo_tasks = []
        repo_count = 0 # Counter for total repos checked in the org

        # Helper function to fetch releases for a repo in a thread
        def fetch_repo_releases(p_name, r_obj):
            try:
                releases_list = get_releases_with_retry(r_obj)
                return p_name, r_obj, releases_list, None
            except Exception as e:
                return p_name, r_obj, [], e

        # Iterate through repositories (PaginatedList fetches pages automatically)
        for repo in repositories:
            repo_count += 1
            repo_name = repo.name
            logger.debug(f"Checking repo {repo_count}: {repo_name}")

            # Filter repositories by the configured suffix
            if not repo_name.endswith(REPO_SUFFIX_FILTER):
                logger.debug(f"Skipping repo {repo_name} (suffix mismatch)")
                continue # Skip to the next repository

            # Derive project name (repo name without suffix)
            project_name = re.sub(rf"{REPO_SUFFIX_FILTER}$", "", repo_name)
            total_repos_processed += 1
            logger.info(f"Processing repository: {project_name} (Source: {repo_name})")

            # Get repository description, provide default if missing
            repo_description = repo.description or "" # Use empty string if description is None
            # Store description in the separate dictionary
            repo_descriptions[project_name] = repo_description
            if args.verbose: # Log full description only if verbose
                 logger.debug(f"Repo description stored: '{repo_description}'")
            elif repo_description: # Log truncated description otherwise
                 logger.debug(f"Repo description stored: '{repo_description[:70]}...'")

            # Submit fetching task to the executor
            future = executor.submit(fetch_repo_releases, project_name, repo)
            repo_tasks.append(future)

        logger.info(f"Submitted {len(repo_tasks)} repository release fetch tasks. Waiting for completion...")
        
        release_futures = []
        future_to_release = {}
        
        def add_release_to_data(rel_dict, repo_name):
            global skipped_old_releases
            if not rel_dict or not repo_name:
                return False
            rel_date = rel_dict.get('date')
            if isinstance(rel_date, str):
                rel_date = parse_date(rel_date)
                rel_dict['date'] = rel_date
            if rel_date and isinstance(rel_date, datetime.datetime):
                if rel_date.tzinfo is None:
                    rel_date = rel_date.replace(tzinfo=datetime.timezone.utc)
                    rel_dict['date'] = rel_date
                if rel_date.year >= args.min_year:
                    if repo_name not in release_data:
                        release_data[repo_name] = []
                    release_data[repo_name].append(rel_dict)
                    return True
                else:
                    logger.debug(f"Skipping release '{rel_dict.get('name', 'N/A')}' (tag: {rel_dict.get('tag_name', 'N/A')}) from {repo_name} - Published in {rel_date.year} (before {args.min_year})")
                    skipped_old_releases += 1
                    return False
            else:
                logger.warning(f"Skipping release in {repo_name} due to missing or invalid date field: {rel_dict.get('tag_name', 'N/A')}")
                return False

        # Process results of repository release fetches
        for future in concurrent.futures.as_completed(repo_tasks):
            project_name, repo_obj, releases, err = future.result()
            if err:
                if isinstance(err, UnknownObjectException):
                    logger.warning(f"Repository {repo_obj.name} seems to have disappeared or is inaccessible (404). Skipping.")
                elif isinstance(err, GithubException):
                    logger.error(f"Could not fetch releases for repository {repo_obj.name} after retries: {err}")
                    repo_release_fetch_failures += 1
                else:
                    logger.error(f"Unexpected error processing repository {repo_obj.name}: {err}", exc_info=should_log_tracebacks())
                    repo_release_fetch_failures += 1

                # If targeted mode failed to fetch its target, abort immediately to prevent cache truncation
                if args.single_repo and project_name == target_project_name:
                    logger.error(f"Fatal Error: Failed to list releases for target repository {repo_obj.name}. Aborting targeted cache update to prevent data loss.")
                    sys.exit(1)

                # In full mode, preserve existing cached releases for this repo if available
                cached_for_repo = [rel for (r, _), rel in existing_cache.items() if r == project_name]
                if cached_for_repo:
                    logger.warning(f"Preserving {len(cached_for_repo)} existing cached releases for {project_name} due to fetch error.")
                    for rel in cached_for_repo:
                        add_release_to_data(rel, project_name)
                continue
            
            uncached_submitted = 0
            release_count_in_repo = len(releases)
            
            for release in releases:
                release_tag = release.tag_name
                
                # Check cache before submitting to the thread pool
                cached_release = existing_cache.get((project_name, release_tag))
                is_cache_hit = False

                if cached_release:
                    cached_fp = cached_release.get("fingerprint")
                    current_fp = compute_release_fingerprint(release)

                    if cached_fp and current_fp:
                        if cached_fp == current_fp:
                            is_cache_hit = True
                        else:
                            logger.info(f"Release '{release.title}' (tag: {release_tag}) was modified on GitHub (fingerprint mismatch). Refreshing metadata.")
                    else:
                        logger.info(f"Release '{release.title}' (tag: {release_tag}) lacks fingerprint (legacy entry). Refreshing metadata once.")

                if is_cache_hit:
                    logger.debug(f"Cache hit for release '{release.title}' (tag: {release_tag}) in repo: {project_name}")
                    add_release_to_data(cached_release, project_name)
                    continue

                # If not cached, submit to the executor for processing
                future_rel = executor.submit(process_release, project_name, release)
                release_futures.append(future_rel)
                future_to_release[future_rel] = (project_name, release_tag)
                uncached_submitted += 1

            if release_count_in_repo == 0:
                 logger.info(f"Repository {project_name} has no releases.")
            else:
                 logger.debug(f"Submitted {uncached_submitted} releases for {project_name} to process queue (Total in repo: {release_count_in_repo}).")

        # Step 2: Wait for all uncached release processing tasks to complete
        total_futures = len(release_futures)
        if total_futures == 0:
             logger.info("All releases were resolved from cache.")
        else:
             logger.info(f"Submitted tasks for {total_futures} uncached releases. Waiting for completion...")

        processed_futures = 0
        for future in concurrent.futures.as_completed(release_futures):
            processed_futures += 1
            # Log progress periodically or on completion
            if processed_futures % 50 == 0 or processed_futures == total_futures:
                 logger.info(f"Processing results... ({processed_futures}/{total_futures} tasks completed)")

            repo_name_fut, tag_name_fut = future_to_release.get(future, (None, None))

            try:
                # Get the result tuple from the completed future: (dict, str, bool) or (None, str, bool)
                filtered_release_dict, repo_name_result, release_failed = future.result()

                if release_failed:
                    skipped_failed_futures += 1
                    prior_cached = existing_cache.get((repo_name_fut, tag_name_fut))
                    if prior_cached and repo_name_fut:
                        logger.warning(f"Preserving prior valid cached release for {repo_name_fut} tag {tag_name_fut} after task failure.")
                        add_release_to_data(prior_cached, repo_name_fut)
                    continue

                if not filtered_release_dict:
                    # Empty successful result: release has no metadata asset. Skip without counting failure.
                    continue

                # Add the successfully processed release
                add_release_to_data(filtered_release_dict, repo_name_result)

            # --- Handle errors that occurred during future execution ---
            except concurrent.futures.CancelledError:
                 logger.warning(f"A release processing task for {repo_name_fut} tag {tag_name_fut} was cancelled.")
                 skipped_failed_futures += 1
                 prior_cached = existing_cache.get((repo_name_fut, tag_name_fut))
                 if prior_cached and repo_name_fut:
                     logger.warning(f"Preserving prior valid cached release for {repo_name_fut} tag {tag_name_fut} after task cancellation.")
                     add_release_to_data(prior_cached, repo_name_fut)
            except Exception as e:
                logger.error(f"Error retrieving result from a release processing future for {repo_name_fut} tag {tag_name_fut}: {e}", exc_info=should_log_tracebacks())
                skipped_failed_futures += 1
                prior_cached = existing_cache.get((repo_name_fut, tag_name_fut))
                if prior_cached and repo_name_fut:
                    logger.warning(f"Preserving prior valid cached release for {repo_name_fut} tag {tag_name_fut} after task error.")
                    add_release_to_data(prior_cached, repo_name_fut)

        logger.info(f"Finished processing futures. Skipped {skipped_old_releases} releases published before {args.min_year}. Encountered {skipped_failed_futures} failed release tasks.")

# --- Catch potential exceptions during overall script execution ---
except BadCredentialsException:
     # Should be caught during init, but included as safety net
     logger.error("Fatal Error: Authentication failed during processing.")
     sys.exit(1)
except GithubException as e:
    # Catch major API errors not handled by retry decorator during main loops
    logger.error(f"Fatal Error: A major GitHub API error occurred during processing (Status: {e.status}): {e.data if hasattr(e, 'data') else '(no data)'}")
    sys.exit(1)
except Exception as e:
    # Catch-all for any other unexpected errors during main setup or processing loops
    logger.error(f"Fatal Error: An unexpected error occurred during main execution: {e}", exc_info=should_log_tracebacks())
    sys.exit(1)


# --- Post-Processing and File Output ---
logger.info("Finished fetching and processing. Sorting releases and generating output files...")

# Calculate final count of releases actually included in the data structure
total_releases_included = sum(len(releases_list) for releases_list in release_data.values())
logger.info(f"Total releases included in final data (published >= {args.min_year}): {total_releases_included}")

# --- Sort Releases By Date Descending ---
logger.debug("Sorting releases by date descending for each repository...")
# Iterates directly over the lists (the values in release_data)
for repo_name, releases_list in release_data.items():
    if releases_list: # Check if list is not empty before sorting
        try:
             # Sort the list of releases *in-place*
             # Use min date with UTC timezone as fallback for entries missing a valid date
             min_fallback_date = datetime.datetime.min.replace(tzinfo=datetime.timezone.utc)
             releases_list.sort(
                 key=lambda entry: entry.get('date') if isinstance(entry.get('date'), datetime.datetime) else min_fallback_date,
                 reverse=True # Most recent first
             )
        except Exception as e:
             # Log errors during sorting for a specific repo
             logger.error(f"Error sorting releases for repo {repo_name}: {e}")

# Canonical alphabetical sorting of repositories for deterministic output order
release_data = dict(sorted(release_data.items()))
repo_descriptions = dict(sorted(repo_descriptions.items()))

# Helper function for JSON serialization (handles datetime)
def json_default_serializer(obj):
    if isinstance(obj, datetime.datetime):
        # Ensure datetime is ISO formatted and includes timezone Z for UTC
        if obj.tzinfo is None:
            # If somehow timezone is missing, assume UTC (GitHub times should be UTC)
             obj = obj.replace(tzinfo=datetime.timezone.utc)
        return obj.isoformat(timespec='seconds').replace('+00:00', 'Z')
    raise TypeError(f"Object of type {type(obj)} is not JSON serializable")


# --- Generate Full JSON Output File (Minified) ---
logger.info(f"Generating full JSON output file (minified): {args.output_file}")
# Construct the final JSON object for the main file
json_data_full = {
    "generation_timestamp_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(timespec='seconds') + 'Z',
    "source_organization": ORGANIZATION,
    "minimum_release_year": args.min_year,
    "release_data": release_data # Use the release_data (dict of lists)
}

try:
    # Write the JSON data to the specified output file
    with open(args.output_file, "w", encoding='utf-8') as json_file:
        # Use separators for minified output, remove indent
        # Use default=json_default_serializer to handle datetime objects
        json.dump(json_data_full, json_file, separators=(',', ':'), default=json_default_serializer, ensure_ascii=False)
    logger.info(f"Full JSON cache file created successfully: {args.output_file}")
except IOError as e:
    logger.error(f"Error writing main JSON file to {args.output_file}: {e}")
    output_write_failures += 1
except TypeError as e:
     logger.error(f"Error serializing full data to JSON (check data types): {e}")
     output_write_failures += 1


# --- Generate Latest Releases JSON Output File (Minified) ---
logger.info("Generating JSON output file with only the latest release per repository...")
# Prepare the structure for the latest releases JSON
latest_releases_json_data = {
    "generation_timestamp_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(timespec='seconds') + 'Z',
    "source_organization": ORGANIZATION,
    "minimum_release_year": args.min_year,
    "release_data": {} # Structure: { repo_name: [list_with_one_latest_release] }
}

# Iterate through the release_data items (dict of lists)
for repo_name, releases_list in release_data.items():
    if releases_list: # Ensure list is not empty (already sorted)
        latest_entry = releases_list[0] # Get the first item, which is the most recent release
        # Store as a list containing only the latest release
        latest_releases_json_data["release_data"][repo_name] = [latest_entry]
    else:
         # Handle case where a repo might exist but have no releases passing the filter
         logger.debug(f"No valid releases found for {repo_name} (published >= {args.min_year}) to include in latest file.")

# Determine filename for the latest releases file based on the main output file name
latest_output_file = args.output_file
# Simple logic to replace or append '_latest' before the extension
if latest_output_file.lower().endswith('.json'):
    latest_output_file = latest_output_file[:-5] + '_latest.json' # Insert before .json
else:
    latest_output_file += "_latest.json" # Append if no .json extension

try:
    # Write the latest releases JSON data to the derived filename
    with open(latest_output_file, "w", encoding='utf-8') as latest_json_file:
        # Use separators=(',', ':') for minified output
        # default=json_default_serializer handles datetime objects, ensure_ascii=False for unicode
        json.dump(latest_releases_json_data, latest_json_file, separators=(',', ':'), default=json_default_serializer, ensure_ascii=False)
    logger.info(f"JSON file with the latest releases created successfully: {latest_output_file}")
except IOError as e:
    logger.error(f"Error writing latest releases JSON file to {latest_output_file}: {e}")
    output_write_failures += 1
except TypeError as e:
     logger.error(f"Error serializing latest data to JSON: {e}")
     output_write_failures += 1


# --- Generate Descriptions JSON File (Human-Readable) ---
logger.info("Generating JSON file with repository descriptions...")
# Determine filename for the descriptions file
desc_output_file = args.output_file
if desc_output_file.lower().endswith('.json'):
    desc_output_file = desc_output_file[:-5] + '_descriptions.json'
else:
    desc_output_file += "_descriptions.json"

# Prepare the data payload for the descriptions file
descriptions_json_data = {
    "generation_timestamp_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(timespec='seconds') + 'Z',
    "source_organization": ORGANIZATION,
    "descriptions": repo_descriptions # Use the dictionary populated earlier
}

try:
    # Write the descriptions JSON data to its file
    with open(desc_output_file, "w", encoding='utf-8') as desc_json_file:
        # Use human-readable format (indent=2) for descriptions file
        # default=json_default_serializer just in case, though unlikely needed here
        json.dump(descriptions_json_data, desc_json_file, indent=2, ensure_ascii=False, default=json_default_serializer)
    logger.info(f"JSON file with repository descriptions created successfully: {desc_output_file}")
except IOError as e:
    logger.error(f"Error writing descriptions JSON file to {desc_output_file}: {e}")
    output_write_failures += 1
except TypeError as e:
     logger.error(f"Error serializing descriptions data to JSON: {e}")
     output_write_failures += 1


# --- Final Summary Output & Exit Condition ---
is_fatal_failure = False
if output_write_failures > 0:
    logger.error(f"Fatal: {output_write_failures} output file write failures occurred.")
    is_fatal_failure = True
if repo_release_fetch_failures > 0:
    logger.error(f"Fatal: {repo_release_fetch_failures} repository release listing failures occurred.")
    is_fatal_failure = True

if skipped_failed_futures > 0:
    if args.single_repo:
        logger.error(f"Fatal: Targeted mode encountered {skipped_failed_futures} failed release processing tasks for {args.single_repo}.")
        is_fatal_failure = True
    else:
        # In full rebuild mode, tolerate minor release task failures if error rate is low (< 5%)
        # and valid releases were successfully included.
        total_tasks = len(release_futures)
        failure_rate = (skipped_failed_futures / total_tasks * 100) if total_tasks > 0 else 0
        if failure_rate > 5.0 or total_releases_included == 0:
            logger.error(f"Fatal: Release failure rate {failure_rate:.1f}% ({skipped_failed_futures}/{total_tasks}) exceeded 5% threshold.")
            is_fatal_failure = True
        else:
            logger.warning(f"Tolerating {skipped_failed_futures} failed release tasks ({failure_rate:.2f}% of {total_tasks}) in full rebuild mode.")

if not is_fatal_failure:
    logger.info("Script finished successfully.")
else:
    logger.error("Script completed with failures.")

# Always print basic summary stats to INFO level
logger.info(f"--- Summary ---")
logger.info(f"Processed {total_repos_processed} '{REPO_SUFFIX_FILTER}' repositories from '{ORGANIZATION}'.")
logger.info(f"Included {total_releases_included} releases (published >= {args.min_year}).")
logger.info(f"Skipped {skipped_old_releases} releases (published < {args.min_year}).")
if repo_release_fetch_failures > 0:
    logger.warning(f"Encountered {repo_release_fetch_failures} repository-level release listing failures.")
if skipped_failed_futures > 0:
    # Log failures as warning if any occurred
    logger.warning(f"Encountered {skipped_failed_futures} failed release processing tasks.")
if output_write_failures > 0:
    logger.warning(f"Encountered {output_write_failures} output file write/serialization failures.")
logger.info(f"Main releases file: {args.output_file}")
logger.info(f"Latest releases file: {latest_output_file}")
logger.info(f"Descriptions file: {desc_output_file}") # Mention descriptions file

# Log final rate limit status if possible
try:
    # Check current time to ensure we don't make this call too close to the actual reset
    current_time_utc = datetime.datetime.now(datetime.timezone.utc)
    limits = g.get_rate_limit().core
    reset_time_utc = limits.reset.replace(tzinfo=datetime.timezone.utc)
    # Only log if not immediately near reset, to avoid potential timing issues/extra waits
    if (reset_time_utc - current_time_utc).total_seconds() > 15:
        logger.info(f"Final primary rate limit: {limits.remaining}/{limits.limit} requests remaining.")
    else:
        logger.info(f"Final primary rate limit check skipped (too close to reset time: {reset_time_utc.isoformat()}).")
except Exception as e:
    logger.warning(f"Could not retrieve final rate limit status: {e}")

sys.exit(1 if is_fatal_failure else 0)
