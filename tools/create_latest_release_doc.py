"""
Script to generate a markdown file listing newly released tools.
The resulting markdown will be added to the zopen community docs
"""

import json
import os
import requests
from datetime import datetime, timedelta
import argparse
from collections import defaultdict

def generate_markdown(data, output_file):
    release_info = defaultdict(lambda: defaultdict(list))

    for tool, releases in data.items():
        for release in releases:
            # Correct format string for "YYYY-MM-DDTHH:MM:SSZ"
            release_date = datetime.strptime(release['date'], "%Y-%m-%dT%H:%M:%SZ")
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

    out_dir = os.path.dirname(output_file)
    if out_dir:
        os.makedirs(out_dir, exist_ok=True)

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
    parser.add_argument('--input', '-i', default='https://github.com/zopencommunity/meta/releases/download/api-cache/zopen_releases.json', help='Input JSON file path or URL (default: api-cache release URL)')
    parser.add_argument('--output', '-o', default='docs/newly_released.md', help='Output markdown file path (default: docs/newly_released.md)')
    args = parser.parse_args()

    if args.input.startswith(('http://', 'https://')):
        response = requests.get(args.input)
        response.raise_for_status()
        data = response.json()['release_data']
    else:
        with open(args.input, 'r', encoding='utf-8') as f:
            data = json.load(f)['release_data']

    generate_markdown(data, args.output)

