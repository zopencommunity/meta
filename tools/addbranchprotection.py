import os
import sys
from github import Github, GithubException
from optparse import OptionParser

# create a Github instance
if os.getenv('GITHUB_OAUTH_TOKEN') is None:
  print("error: environment variable GITHUB_OAUTH_TOKEN must be defined");
  sys.exit(1)

g = Github(os.getenv('GITHUB_OAUTH_TOKEN'))

# get the organization by name
parser = OptionParser(description="Enable branch protection for repositories in an organization.")
parser.add_option("-o", "--org", dest="org", default="zopencommunity", help="organization name (default: zopencommunity)")
parser.add_option("-r", "--repo", dest="repo", default=None, help="comma separated list of repos to include")
parser.add_option("-a", "--all", action="store_true", dest="all", default=False, help="include all repos")
parser.add_option("-v", "--verbose", action="store_true", dest="verbose", default=False, help="print verbose output")

(options, args) = parser.parse_args()

org_name = options.org
include_repos = options.repo
all_repos = options.all
verbose = options.verbose

# get the organization by name
org = g.get_organization(org_name)

if all_repos:
    repos = org.get_repos()
else:
    if include_repos:
        repo_names = include_repos.split(',')
        repos = [org.get_repo(repo_name) for repo_name in repo_names]
    else:
        repos = [org.get_repo(repo.full_name) for repo in org.get_repos()]

for repo in repos:
    if verbose:
        print(f'Checking branch protection on {repo.name}...')

    try:
        branch = repo.get_branch(repo.default_branch)
        existing_protection = branch.get_protection()
        print(existing_protection)
    except GithubException as e:
        if e.status == 404:
            # There is no branch protection on this branch
            existing_protection = None
        else:
            # There was another error when getting branch protection
            raise e

    if existing_protection is None:
        try:
            branch.edit_protection(
                require_code_owner_reviews=True,
                required_approving_review_count=1
            )
            if verbose:
                print(f'Enabled branch protection on {repo.name}...')
        except GithubException as e:
            print(f'Could not enable branch protection on {repo.name}. {str(e)}')
    else:
        if verbose:
            print(f'Branch protection already enabled on {repo.name}...')

if verbose:
    print("Done.")
