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
	"Skipped": 0,
	"Not built": 0
}

statusPerPort = {}

# using an access token
g = Github("access_token")

if os.getenv('GITHUB_OAUTH_TOKEN') is None:
  print("error: environment variable GITHUB_OAUTH_TOKEN must be defined");
  sys.exit(1);

# Github Enterprise with custom hostname
g = Github(os.getenv('GITHUB_OAUTH_TOKEN'))

with open('docs/Latest.md', 'w') as f:
	sys.stdout = f # Change the standard output to the file we created.
	print("# z/OS Open Tools - Packages\n")
	print("Note: to download the latest packages, use the `zopen download` script from the [utils repo](https://github.com/ZOSOpenTools/utils)\n")
	print("| Package | Status | Test Success Rate | Latest Release | Description |")
	print("|---|---|---|---|---|")

	for r in g.get_user("ZOSOpenTools").get_repos():
		if not re.search("port$", r.name):
			continue
		print("| [" + r.name + "](" + r.html_url + ")", end='')
		releases = r.get_releases()
		if (releases.totalCount):
			status = releases[0].body
			m = re.search(".*Test Status:</b>[ ]+([^ ]+)[ ]+\(([^)]*)", status)
			if m:
				progressPerStatus[m.group(1)] += 1;
				successRate = re.search("(\d+\.?\d+?)% success rate", m.group(2));
				print("|" + m.group(1), end='')
				if successRate:
					print("|" + successRate.group(1) + "%", end='')
					statusPerPort[r.name] = int(successRate.group(1).split(".", 1)[0]);
				else:
					print("| N/A", end='');
					statusPerPort[r.name] = -1;
			else:
				progressPerStatus["Skipped"] += 1;
				statusPerPort[r.name] = -1;
				print("| No status", end='');
				print("| N/A", end='');
		else:
			progressPerStatus["Not built"] += 1;
			statusPerPort[r.name] = -2;
			print("| No status", end='');
			print("| N/A", end='');
		#print("| [Releases](" + r.html_url + "/releases)", end='')
		
		if (releases.totalCount):
			print("| [" + releases[0].tag_name + "](" + releases[0].html_url + ")", end='')
			print("| " + releases[0].body)
		else:
			print("| None | |")

# Data to plot
labels = []
sizes = []

# Pie chart for overall status
for x, y in progressPerStatus.items():
    labels.append(x)
    sizes.append(y)
colors = ['#00FF00','#0000FF','#FFFF00','#AAAAAA','#FF0000']
plt.title("Current Porting Status")
p, tx, autotexts = plt.pie(sizes, labels=labels, colors=colors, autopct="", shadow=True)
for i, a in enumerate(autotexts):
    a.set_text("{}".format(sizes[i]))
plt.axis('equal')
plt.savefig('docs/images/progress.png')
plt.close();

# Bar chart for each project
labels = []
sizes = []
for x, y in sorted(statusPerPort.items(), key=lambda x: x[1]):
	if y >= 0:
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

with open('docs/Progress.md', 'w') as f:
	sys.stdout = f # Change the standard output to the file we created.
	print("""
# Overall Status
* Green: All tests passing
* Blue: Most tests passing
* Yellow: Some tests passing
* Red: No tests passing
* Skipped: Tests are not run

![image info](./images/progress.png)

## Breakdown of Status
![image info](./images/quality.png)

## Projects with tests not enabled
	""");
	for x, y in sorted(statusPerPort.items(), key=lambda x: x[1]):
		if y == -1:
			print("* [" + x + "](https://github.com/ZOSOpenTools/" + x + ")\n");

	print("## Projects that do not have builds\n");
	for x, y in sorted(statusPerPort.items(), key=lambda x: x[1]):
		if y == -2:
			print("* [" + x + "](https://github.com/ZOSOpenTools/" + x + ")\n");

