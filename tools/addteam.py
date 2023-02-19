import os
import sys
from optparse import OptionParser
from github import Github
from github import GithubException

# create a Github instance
if os.getenv('GITHUB_OAUTH_TOKEN') is None:
    print("error: environment variable GITHUB_OAUTH_TOKEN must be defined")
    sys.exit(1)

# Github Enterprise with custom hostname
g = Github(os.getenv('GITHUB_OAUTH_TOKEN'))

# get the organization by name
org = g.get_organization("ZOSOpenTools")

# create an OptionParser instance
parser = OptionParser(description="Add a team to one or more repositories with a given permission level in the ZOSOpenTools organization on GitHub Enterprise.", usage="%prog [options]")
parser.add_option("-t", "--team", dest="team_name", help="team name (required)", metavar="TEAM")
parser.add_option("-p", "--permission", dest="permission", help="permission to give (default: read). Valid permissions are read, write, and admin.", metavar="PERMISSION", default="read")
parser.add_option("-a", "--all", action="store_true", dest="all_repos", help="add team to all repositories")
parser.add_option("-i", "--include", dest="include_repos", help="comma-delimited list of repositories to include", metavar="REPOS")

# parse the command line options
(options, args) = parser.parse_args()

# check if help was requested or no option was specified
if len(sys.argv) == 1 or '-h' in sys.argv or '--help' in sys.argv:
    parser.print_help()
    sys.exit(0)

# get the team by name
if not options.team_name:
    print("error: team name required")
    sys.exit(1)
try:
    team = org.get_team_by_slug(options.team_name)
except GithubException as e:
    print(f"error: {e.data['message']}")
    sys.exit(1)

# add the team to each repository with the given permission, if the repository is in the include list or --all is specified
repos = org.get_repos()
if options.include_repos:
    include_list = options.include_repos.split(',')
    repos = [repo for repo in repos if repo.full_name in include_list]
elif options.all_repos:
    pass
else:
    print("error: must specify either an include list or --all")
    sys.exit(1)

for repo in repos:
    # check if the team is already a collaborator on the repo
    try:
        repo_collaborators = repo.get_collaborators()
    except GithubException as e:
        print(f"error: {e.data['message']}")
        continue
    team_already_exists = False
    for collaborator in repo_collaborators:
        if collaborator.id == team.id:
            team_already_exists = True
            break
    # add the team as a collaborator if necessary
    if not team_already_exists:
        try:
            repo.add_to_collaborators(team)
            print(f"Added {options.team_name} as a collaborator to {repo.full_name}")
        except GithubException as e:
            print(f"error: {e.data['message']}")
            continue
    # set the repository permission for the team
    try:
        valid_permissions = ['read', 'write', 'admin']
        if options.permission not in valid_permissions:
            print(f"error: {options.permission} is not a valid permission")
            sys.exit(1)
        team.set_repo_permission(repo, options.permission)
        print(f"Set {options.team_name} with {options.permission} permission on {repo.full_name}")
    except GithubException as e:
        print(f"error: {e.data['message']}")
