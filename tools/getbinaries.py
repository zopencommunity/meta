#!/usr/bin/env python3
from github import Github
import os
import sys
import argparse
import subprocess
import re
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import rcParams
rcParams.update({'figure.autolayout': True})

progressPerStatus = {
	"Green": 0,
	"Blue": 0,
	"Yellow": 0,
	"Red": 0,
	"Skipped": 0
}

statusPerPort = {}

# using an access token
g = Github("access_token")

if os.getenv('GITHUB_OAUTH_TOKEN') is None:
  print("error: environment variable GITHUB_OAUTH_TOKEN must be defined");
  sys.exit(1);

# Github Enterprise with custom hostname
g = Github(os.getenv('GITHUB_OAUTH_TOKEN'))

print("# z/OS Open Tools - Packages\n")
print("Note: to download the latest packages, use the `zopen download` script from the [utils repo](https://github.com/ZOSOpenTools/utils)\n")
print("| Package | Port Repo | Status | Quality | All Releases | Latest Release | Description | |")
print("|---|---|---|---|---|---|---|")

for r in g.get_user("ZOSOpenTools").get_repos():
	if not re.search("port$", r.name):
		continue
	print("|" + r.name, end='')
	print("| [Repo](" + r.html_url + ")", end='')
	releases = r.get_releases()
	if (releases.totalCount):
		status = releases[0].body
		m = re.search(".*Test Status:</b>[ ]+([^ ]+)[ ]+\(([^)]*)", status)
		if m:
			progressPerStatus[m.group(1)] += 1;
			successRate = re.search("(\d+\.?\d+?)% success rate", m.group(2));
			print("|" + m.group(1))
			if successRate:
				print("|" + successRate.group(1) + "%")
				statusPerPort[r.name] = int(successRate.group(1).split(".", 1)[0]);
			else:
				print("| No status");
				statusPerPort[r.name] = 0;
		else:
			progressPerStatus["Skipped"] += 1;
			statusPerPort[r.name] = 0;
			print("| No status");
			print("| No status");
	else:
		print("| No status");
		print("| N/A");
	print("| [Releases](" + r.html_url + "/releases)", end='')
	
	if (releases.totalCount):
		print("| [" + releases[0].tag_name + "](" + releases[0].html_url + ")", end='')
		print("| " + releases[0].body)
	else:
		print("| None | |")

# Data to plot
labels = []
sizes = []

for x, y in progressPerStatus.items():
    labels.append(x)
    sizes.append(y)
colors = ['#00FF00','#0000FF','#FFFF00','#FF0000', '#999999']
plt.title("Current Porting Status")
p, tx, autotexts = plt.pie(sizes, labels=labels, colors=colors, autopct="", shadow=True)
for i, a in enumerate(autotexts):
    a.set_text("{}".format(sizes[i]))
plt.axis('equal')
plt.savefig('docs/images/progress.png')
plt.close();

labels = []
sizes = []
for x, y in sorted(statusPerPort.items(), key=lambda x: x[1]):
	labels.append(x)
	sizes.append(y)
fig = plt.figure()
ax = fig.add_axes([0,0,1,1])
ax.set_ylabel('Success Rate (%)')
ax.set_title("Project Test Quality")
col = []
for val in sizes:
    if val == 100:
        col.append('green')
    elif val >= 50:
        col.append('blue')
    else:
        col.append('#FFEF00')

bars = ax.barh(labels, sizes, color = col);
ax.bar_label(bars)

plt.savefig('docs/images/quality.png',  bbox_inches="tight")
