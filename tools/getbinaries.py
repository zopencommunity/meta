#!/usr/bin/env python3
from github import Github
import os
import sys
import argparse
import subprocess
import re

SupportedPorts = {
  "Perl": "perlport",
  "Make": "makeport",
  "M4": "m4port",
  "help2man": "help2manport",
  "xz": "xzport",
  "autoconf": "autoconfport",
  "bison": "bisonport", 
  "curl": "curlport", 
  "openssl": "opensslport", 
  "gettext": "gettextport", 
  "libtool": "libtoolport", 
  "makeinfo": "makeinfoport", 
  "zlib": "zlibport", 
  "gzip": "gzipport", 
}

# using an access token
g = Github("access_token")

if os.getenv('GITHUB_OAUTH_TOKEN') is None:
  print("error: environment variable GITHUB_OAUTH_TOKEN must be defined");
  sys.exit(1);

# Github Enterprise with custom hostname
g = Github(os.getenv('GITHUB_OAUTH_TOKEN'))

expanded_repo = "ZOSOpenTools";

print("# z/OS Open Tools Latest Packages");
print("| Package | Port Repo | Latest Binary | Releases Link | |")
print("|---|---|---|---|---|")

for r in g.get_user().get_repos(sort='desc'):
	if not re.search("port$", r.name):
		continue
	print("|" + r.name, end='')
	print("| [Repo Link](" + r.html_url + ")", end='')
	releases = r.get_releases()
	if (releases.totalCount):
		print("| [" + releases[0].title + "](" + releases[0].html_url + ")", end='')
	else:
		print("| None", end='')
	print("| [Releases Link](" + r.html_url + "/releases)|")
