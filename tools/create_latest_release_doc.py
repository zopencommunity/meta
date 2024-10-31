"""
Script to generate a markdown file listing newly released tools.
The resulting markdown will be added to the zopen community docs
"""

import json
import requests
from datetime import datetime, timedelta
import argparse
from collections import defaultdict

def generate_markdown(data, output_file):
    release_info = defaultdict(lambda: defaultdict(list))

    for tool, releases in data.items():
        for release in releases:
            release_date = datetime.strptime(release['date'], "%Y-%m-%d %H:%M:%S%z")
            # Calculate the start of the week for the release date (Monday as the first day of the week)
            week_start = release_date - timedelta(days=release_date.weekday())
            week_start_str = week_start.strftime('%Y-%m-%d')
            pax_name = release['assets'][0]['name']
            pax_url = release['assets'][0]['url'].replace('download', 'tag').rsplit('/', 1)[0]
            categories = release['assets'][0]['categories']
            if categories == "":
                categories = "Uncategorized"
            release_info[week_start_str][tool].append({'name': pax_name, 'url': pax_url, 'categories': categories})

    sorted_releases = sorted(release_info.items(), key=lambda x: datetime.strptime(x[0], '%Y-%m-%d'), reverse=True)

    with open(output_file, 'w') as md_file:
        md_file.write("# Newly Released Tools\n\n")
        first_week = True  # Initialize a flag for the first week
        for week_start, tools in sorted_releases:
            week_end = (datetime.strptime(week_start, '%Y-%m-%d') + timedelta(days=6)).strftime('%Y-%m-%d')
            if first_week:
                md_file.write(f"<details open>\n<summary>Week of {week_start} to {week_end}</summary>\n\n")
                first_week = False  # Update the flag after the first week
            else:
                md_file.write(f"<details>\n<summary>Week of {week_start} to {week_end}</summary>\n\n")
            for tool, releases in tools.items():
                for release in releases:
                    md_file.write(f"- **{tool}**: [{release['name']}]({release['url']}) - (category: {release['categories']})\n")
            md_file.write("\n</details>\n")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Generate markdown file for newly released tools.')
    parser.add_argument('--output', '-o', default='Newly_released_tools.md', help='Output markdown file path')
    args = parser.parse_args()

    url = 'https://raw.githubusercontent.com/zopencommunity/meta/main/docs/api/zopen_releases.json'
    response = requests.get(url)
    data = response.json()['release_data']

    generate_markdown(data, args.output)

