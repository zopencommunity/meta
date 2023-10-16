#!/usr/bin/env python3
from github import Github
from datetime import datetime
from itertools import chain
import shutil
import os
import sys
import argparse
import subprocess
import re
import numpy as np
import requests
import matplotlib.pyplot as plt
from matplotlib import rcParams
import matplotlib as mpl
import matplotlib.cm as cm
from matplotlib.colors import LinearSegmentedColormap
rcParams.update({'figure.autolayout': True})

todaysDate = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

progressPerStatus = {
  "Green": 0,
  "Blue": 0,
  "Yellow": 0,
  "Red": 0,
  "Not built": 0,
  "Skipped": 0,
}

statusPerPort = {}
dependentOn = {}
patchesPerPort = {}
totalPatchLinesPerPort = {}

# using an access token
g = Github("access_token")

if os.getenv('ZOPEN_GITHUB_OAUTH_TOKEN') is None:
  print("error: environment variable ZOPEN_GITHUB_OAUTH_TOKEN must be defined");
  sys.exit(1);

# Github Enterprise with custom hostname
g = Github(os.getenv('ZOPEN_GITHUB_OAUTH_TOKEN'))

with open('docs/Latest.md', 'w') as f:
  sys.stdout = f # Change the standard output to the file we created.
  print("# z/OS Open Tools - Packages\n")
  print("Note: to download the latest packages, use the `zopen install` script from the [meta repo](https://github.com/ZOSOpenTools/meta)\n")
  print("| Package | Status | Test Success Rate | Latest Release | Description |")
  print("|---|---|---|---|---|")

  for r in g.get_user("ZOSOpenTools").get_repos():
    if not re.search("port$", r.name):
      continue
    print("| [" + r.name + "](" + r.html_url + ")", end='')
    dependentOn[r.name] = []
    releases = r.get_releases()
    if (releases.totalCount):
      latestRelease = r.get_latest_release()
      status = latestRelease.body
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
      latestRelease = r.get_latest_release()
      print("| [" + latestRelease.tag_name + "](" + latestRelease.html_url + ")", end='')
      print("| " + latestRelease.body)
    else:
      print("| None | |")

    if os.path.exists(r.name):
        # If the directory exists, delete it recursively
        shutil.rmtree(r.name);

    subprocess.run(['git', 'clone', r.clone_url, r.name])

    # Count the number of .patch files and total lines in patches directory
    num_patches = 0
    total_lines = 0
    paths = ('patches', 'tarballpatches', 'gitpatches')
    for root, dirs, files in chain.from_iterable(os.walk(r.name + "/" + path) for path in paths):
        for filename in files:
            if filename.endswith('.patch'):
                num_patches += 1
                with open(os.path.join(root, filename), 'r') as patch_file:
                    total_lines += len(patch_file.readlines())
    patchesPerPort[r.name] = num_patches
    totalPatchLinesPerPort[r.name] = total_lines

    if os.path.exists(r.name):
        # If the directory exists, delete it recursively
        shutil.rmtree(r.name);

  print("Last updated: ", todaysDate);

for rname, y in dependentOn.items():
  response = requests.get("https://raw.githubusercontent.com/ZOSOpenTools/" + rname + "/main/buildenv")
  if response.status_code == 200:
    name=re.sub('port$', '', rname)
    matches = re.findall('export\s+ZOPEN.*DEPS\s*=\s*"([^"]*)"', response.text)
    dependencies = []
    for match in matches:
      dependencies += match.split();
    dependencies = list(set(dependencies))
    for x in dependencies:  
      if x + "port" in dependentOn:
        dependentOn[x + "port"] += [name]
# Data to plot
labels = []
sizes = []

# Pie chart for overall status
for x, y in progressPerStatus.items():
    labels.append(x)
    sizes.append(y)
colors = ['#00FF00','#0000FF','#FFFF00','#FF0000','#AAAAAA','#FF8888']
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
fig.set_size_inches(30, 25)
ax = fig.add_axes([0,0,1,1])
cmap = cm.get_cmap('Greens')
color_norm = mpl.colors.Normalize(vmin=min(sizes), vmax=max(sizes))
colors = cmap(color_norm(sizes))
ax.set_xlabel('Success Rate (%)', fontsize=18)
ax.set_title("Project Test Quality", fontsize=24)
ax.tick_params(axis='both', labelsize=18)
col = []
for val in sizes:
    if val == 100:
        col.append('green')
    elif val >= 50:
        col.append('blue')
    else:
        col.append('#FFEF00')

bars = ax.barh(labels, sizes, color = col, height = 0.8, align='edge');
ax.bar_label(bars)
plt.savefig('docs/images/quality.png',  bbox_inches="tight")

with open('docs/Progress.md', 'w') as f:
  sys.stdout = f # Change the standard output to the file we created.
  print("""
## Overall Status
* <span style="color:green">Green</a>: All tests passing
* <span style="color:blue">Blue</a>: Most tests passing
* <span style="color:#fee12b">Yellow</a>: Some tests passing
* <span style="color:red">Red</a>: No tests passing
* <span style="color:grey">Grey</a>: Skipped or Tests are not enabled

![image info](./images/progress.png)

## Breakdown of Status
![image info](./images/quality.png)

## Projects with skipped or no tests (grey)
  """);
  for x, y in sorted(statusPerPort.items(), key=lambda x: x[1]):
    if y == -1:
      print("* [" + x + "](https://github.com/ZOSOpenTools/" + x + ")");

  print("## Projects that do not have builds\n");
  for x, y in sorted(statusPerPort.items(), key=lambda x: x[1]):
    if y == -2:
      print("* [" + x + "](https://github.com/ZOSOpenTools/" + x + ")");

  print("""
## Projects with the most dependencies
""");
  print("| Package | # of Dependent Projects | Test Success Rate | Dependent projects");
  print("|---|---|---|--|");
  for x,y in sorted(dependentOn.items(), reverse=True, key=lambda x: len(x[1])):
    status = statusPerPort[x]  
    if status == -1:
      status = "Skipped"
    elif status == -2:
      status = "No builds"
    else:
      status = str(status) + "%"
    print("| [" + x + "](https://github.com/ZOSOpenTools/" + x + ") | " + str(len(y)) + " | " + status + " |"  + ", ".join(str(e) for e in y));

  print("""
## Projects with the most patches
""");
  print("| Package | # of Patched Lines | # of Patches");
  print("|---|---|--|");
  for x,y in sorted(totalPatchLinesPerPort.items(), reverse=True, key=lambda x: x[1]):
    patches = patchesPerPort[x]
    patchLines = totalPatchLinesPerPort[x]
    checkMark = ""
    if patches == 0:
        checkMark = "&#10003;"
    print("| " + checkMark + " [" + x + "](https://github.com/ZOSOpenTools/" + x + ") | " + str(patchLines) + " | " + str(patches));

  print("\nLast updated: ", todaysDate);

