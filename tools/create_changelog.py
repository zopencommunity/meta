# /// script
# requires-python = ">=3.8"
# dependencies = [
#     "dulwich>=0.21.0",
#     "typing-extensions>=4.0.0",
# ]
# ///

import re
from collections import defaultdict
from datetime import datetime
import argparse
from dulwich.repo import Repo
import sys
from typing import Dict, List, Optional, Any

# Configuration
EXCLUDED_AUTHORS = {
    b'zosopentools@ibm.com', b'ZOS Open Tools', b'zosopentools@gmail.com',
    b'noreply@github.com', b'github-actions[bot]', b'actions@github.com'
}

# Repository configuration
REPO_OWNER = "zopencommunity"
REPO_URL = None  # Will be set after getting repo name

EXCLUDED_PATTERNS = [
    r'^Updating docs/apis/reference',
    r'^Update CHANGELOG\.md',
    r'^Update version',
    r'^Automated commit',
    r'^Generated changelog',
    r'^Build:',
    r'^Merge branch',
    r'^Merge remote-tracking branch',
    r'^Merge tag',
    r'^Merge commit',
    r'^Updating Latest\.md',
    r'^Updating docs page',
    r'^Updating docs/',
    r'^Update Latest\.md'
]

CATEGORY_MAP = {
    'feat': '✨ Features',
    'fix': '🐛 Bug Fixes',
    'docs': '📚 Documentation',
    'doc': '📚 Documentation',  # Normalize 'doc' to same as 'docs'
    'chore': '🔧 Maintenance',
    'style': '💄 Style',
    'refactor': '♻️ Refactoring',
    'perf': '⚡️ Performance',
    'test': '🧪 Testing',
    'ci': '🔄 CI/CD'
}

def get_repo_name(repo: Repo) -> tuple[str, str]:
    """Get organization and repository name from git config."""
    try:
        config = repo.get_config()
        section = (b'remote', b'origin')

        if config.has_section(section):
            url = config.get(section, b'url')
            if url:
                url = url.decode('utf-8')
                print(f"Debug: Git URL from config: {url}", file=sys.stderr)
                # Handle both HTTPS and SSH URLs
                if 'github.com' in url:
                    # Only strip .git if it exists as a complete suffix
                    if url.endswith('.git'):
                        url = url[:-4]

                    if url.startswith('git@'):
                        # Handle SSH URL format (git@github.com:org/repo)
                        path = url.split('github.com:')[1]
                    else:
                        # Handle HTTPS URL format (https://github.com/org/repo)
                        path = url.split('github.com/')[1]

                    print(f"Debug: Extracted path: {path}", file=sys.stderr)
                    # Split into org and repo, handling potential subpaths
                    parts = path.split('/')
                    print(f"Debug: Split parts: {parts}", file=sys.stderr)
                    if len(parts) >= 2:
                        return parts[0], parts[1]

        raise ValueError("Could not find valid GitHub remote URL")
    except Exception as e:
        print(f"Warning: Could not get repo info from git config: {e}", file=sys.stderr)
        raise

def get_commits() -> List[str]:
    """Get filtered list of commits from the repository."""
    try:
        repo = Repo('.')
    except Exception as e:
        print(f"Error opening repository: {e}", file=sys.stderr)
        return []

    # Set repository URL based on repo name
    global REPO_URL
    try:
        org, repo_name = get_repo_name(repo)
        REPO_URL = f"https://github.com/{org}/{repo_name}"
        print(f"Using repository: {REPO_URL}", file=sys.stderr)
    except Exception as e:
        print(f"Error getting repo info: {e}. Using default values.", file=sys.stderr)
        REPO_URL = f"https://github.com/{REPO_OWNER}/zopen"

    print("Processing commits...", file=sys.stderr)

    # Get PR commits first
    pr_commits = set()
    for entry in repo.get_walker():
        commit = entry.commit
        if len(commit.parents) > 1:  # merge commit
            for parent in commit.parents[1:]:
                for c in repo.get_walker(include=[parent], exclude=[commit.parents[0]]):
                    pr_commits.add(c.commit.id)

    # Process all commits
    commits = []
    for entry in repo.get_walker():
        commit = entry.commit
        if commit.author in EXCLUDED_AUTHORS:
            continue

        message = commit.message.decode('utf-8')
        if any(re.match(pattern, message.split('\n')[0].strip()) for pattern in EXCLUDED_PATTERNS):
            continue
        if commit.id in pr_commits and len(commit.parents) <= 1:
            continue

        date_str = datetime.fromtimestamp(commit.author_time).strftime('%Y-%m-%d %H:%M:%S')
        is_merge = len(commit.parents) > 1
        commits.append(f"{commit.id.decode('ascii')}|{message.split('\n')[0]}|{date_str}|{message}|{'merge' if is_merge else 'direct'}")

    print(f"Processed {len(commits)} commits", file=sys.stderr)
    return commits

def categorize_pr(title: str) -> str:
    """Categorize a PR or commit based on its title."""
    title_lower = title.lower()

    # First check for conventional commit format
    conv_match = re.match(r'^(feat|fix|docs?|chore|style|refactor|perf|test|ci)(\(.*?\))?\s*:\s*', title_lower)
    if conv_match:
        tag = conv_match.group(1)
        return CATEGORY_MAP.get(tag, '🔍 Other Changes')

    # For non-conventional commits, try to infer the category
    # Order matters: more common categories are checked first to maximize the chance of
    # gathering enough related commits (>= 3) to avoid being scattered into "Other Changes"
    if any(p in title_lower for p in ['doc', 'docs', 'documentation', 'guide', 'readme', 'md']):
        return '📚 Documentation'
    if any(p in title_lower for p in ['fix', 'bug', 'issue', 'error', 'typo']):
        return '🐛 Bug Fixes'
    if any(p in title_lower for p in ['feat', 'feature', 'add', 'support', 'implement']):
        return '✨ Features'
    if any(p in title_lower for p in ['ci', 'pipeline', 'jenkins', 'github actions', 'workflow']):
        return '🔄 CI/CD'
    if any(p in title_lower for p in ['test', 'testing', 'coverage']):
        return '🧪 Testing'
    if any(p in title_lower for p in ['refactor', 'cleanup', 'clean up', 'reorganize']):
        return '♻️ Refactoring'
    if any(p in title_lower for p in ['style', 'format', 'lint']):
        return '💄 Style'
    if any(p in title_lower for p in ['perf', 'performance', 'optimize', 'speed']):
        return '⚡️ Performance'
    if any(p in title_lower.split() for p in ['update', 'upgrade', 'maintenance', 'chore']):
        return '🔧 Maintenance'

    # Default case
    return '🔍 Other Changes'

def parse_commit(commit_info: str) -> Optional[Dict[str, Any]]:
    """Parse a commit string into a structured format."""
    try:
        parts = commit_info.split('|')
        if len(parts) < 5:
            print(f"Warning: Malformed commit info: {commit_info}", file=sys.stderr)
            return None

        commit_hash, subject, date, full_message, commit_type = parts[:5]
        title = None
        pr_number = None

        if commit_type == 'merge':
            pr_match = re.search(r'Merge pull request #(\d+)[^\n]*\n+([^\n]+)', full_message)
            if pr_match:
                pr_number = pr_match.group(1)
                title = pr_match.group(2).strip()
            else:
                pr_match = re.search(r'#(\d+)', subject)
                if pr_match:
                    pr_number = pr_match.group(1)
                    title = full_message.split('\n')[1].strip() if len(full_message.split('\n')) > 1 else subject.strip()

        title = title or subject.strip()
        date_obj = datetime.strptime(date, '%Y-%m-%d %H:%M:%S')

        return {
            'hash': commit_hash,
            'title': title,
            'pr_number': pr_number,
            'date': date_obj,
            'month_year': date_obj.strftime('%B %Y'),
            'type': commit_type
        }
    except Exception as e:
        print(f"Error parsing commit: {e}", file=sys.stderr)
        return None

def format_commit_entry(commit: Dict[str, Any]) -> str:
    """Format a commit entry for the changelog."""
    if commit['pr_number'] and REPO_URL:
        return f"{commit['title']} ([#{commit['pr_number']}]({REPO_URL.rstrip('/')}/pull/{commit['pr_number']}))"
    elif REPO_URL:
        return f"{commit['title']} ([{commit['hash'][:7]}]({REPO_URL.rstrip('/')}/commit/{commit['hash']}))"
    return commit['title']

def generate_changelog(prs_by_month: Dict) -> str:
    """Generate the changelog content."""
    content = ["# Changelog\n"]
    current_month = datetime.now().replace(day=1, hour=0, minute=0, second=0, microsecond=0)

    for month_date, prs_by_category in sorted(prs_by_month.items(), reverse=True):
        month_header = month_date.strftime('%B %Y')
        if month_date == current_month:
            month_header += " 🚧"

        content.append(f"## {month_header}\n")

        # First, collect all commits by category
        merged_categories = defaultdict(list)
        other_changes = []

        # Process all commits, keeping "Other Changes" separate
        for category, commits in prs_by_category.items():
            if category == '🔍 Other Changes':
                other_changes.extend(commits)
            else:
                merged_categories[category].extend(commits)

        # Move small categories (< 3 commits) to other_changes
        for category, commits in list(merged_categories.items()):
            if len(commits) < 3:
                other_changes.extend(commits)
                del merged_categories[category]

        # Output regular categories first (sorted alphabetically)
        for category in sorted(merged_categories.keys()):
            commits = merged_categories[category]
            content.append(f"### {category}\n")
            for pr in sorted(commits, key=lambda x: (x['date'], int(x['pr_number'] or 0)), reverse=True):
                content.append(f"- {format_commit_entry(pr)}\n")
            content.append("\n")

        # Output Other Changes section last if there are any
        if other_changes:
            content.append("### 🔍 Other Changes\n")
            for pr in sorted(other_changes, key=lambda x: (x['date'], int(x['pr_number'] or 0)), reverse=True):
                content.append(f"- {format_commit_entry(pr)}\n")
            content.append("\n")

    return "".join(content)

def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(description='Generate CHANGELOG.md from git merge commits and direct pushes')
    parser.add_argument('--output', '-o', default='CHANGELOG.md', help='Output changelog file path')
    args = parser.parse_args()

    commits = get_commits()
    if not commits:
        print("No commits found or error occurred", file=sys.stderr)
        sys.exit(1)

    prs_by_month = defaultdict(lambda: defaultdict(list))

    for commit_info in commits:
        commit = parse_commit(commit_info)
        if commit:
            month = commit['date'].replace(day=1, hour=0, minute=0, second=0, microsecond=0)
            category = categorize_pr(commit['title'])
            prs_by_month[month][category].append(commit)

    try:
        with open(args.output, 'w') as f:
            f.write(generate_changelog(prs_by_month))
        print(f"Successfully generated changelog at {args.output}", file=sys.stderr)
    except IOError as e:
        print(f"Error writing changelog: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main()
