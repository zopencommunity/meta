import os
import sys
from github import Github

# create a Github instance
if os.getenv('GITHUB_OAUTH_TOKEN') is None:
  print("error: environment variable GITHUB_OAUTH_TOKEN must be defined");
  sys.exit(1);

# Github Enterprise with custom hostname
g = Github(os.getenv('GITHUB_OAUTH_TOKEN'))

# get the organization by name
org = g.get_organization("ZOSOpenTools")

# get the team by name
# get the team by name (passed as argument)
team_name = sys.argv[1]
team = org.get_team_by_slug(team_name)

# get all the repositories in the organization
repos = org.get_repos()

# add the team to each repository
for repo in repos:
    team.add_to_repos(repo)
