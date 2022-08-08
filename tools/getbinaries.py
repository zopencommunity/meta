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
print("# z/OS Open Tools - Packages\n")
print("Note: to download the latest packages, use the `zopen download` script from the [utils repo](https://github.com/ZOSOpenTools/utils)\n")
print("| Package | Port Repo | All Releases | Latest Release | Description | |")
print("|---|---|---|---|---|---|")

for r in g.get_user().get_repos():
	if not re.search("port$", r.name):
		continue
	print("|" + r.name, end='')
	print("| [Repo](" + r.html_url + ")", end='')
	releases = r.get_releases()
	print("| [Releases](" + r.html_url + "/releases)", end='')
	if (releases.totalCount):
		print("| [" + releases[0].tag_name + "](" + releases[0].html_url + ")", end='')
		print("| " + releases[0].body)
	else:
		print("| None | |")
