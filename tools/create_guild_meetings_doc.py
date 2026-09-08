"""
Script to generate markdown file for Tools Guild Meeting Links.
Reads from json data source and generates ToolsGuildMeetingLinks.md
"""

import json
import os
import argparse

def format_links(items):
    if not items:
        return "Not Available"
    formatted = []
    for item in items:
        label = item.get("label", "")
        url = item.get("url", "")
        password = item.get("pass", "")
        s = f"[{label}]({url})"
        if password:
            s += f" pass: {password}"
        formatted.append(s)
    return ", ".join(formatted)

def generate_markdown(data, output_file):
    with open(output_file, 'w') as md:
        md.write("# Guild Meeting Topics\n\n")
        md.write("## Introduction and General Topics\n\n")
        md.write("| Topic   | Guild Meeting Recording | Presentation | Guild Discussion |\n")
        md.write("| --- | --- | --- | --- |\n")
        for item in data.get("general_topics", []):
            topic = item.get("topic", "")
            recs = format_links(item.get("recordings", []))
            pres = format_links(item.get("presentations", []))
            disc = format_links(item.get("discussions", []))
            md.write(f"| {topic} | {recs} | {pres} | {disc} |\n")
        
        md.write("\n\n## Tools Discussion\n\n")
        md.write("| Tool   | Guild Meeting Recording | Presentation | Guild Discussion |\n")
        md.write("| -----  | ----- | ----- | ----- |\n")
        for item in data.get("tools_topics", []):
            tool = item.get("tool", "")
            recs = format_links(item.get("recordings", []))
            pres = format_links(item.get("presentations", []))
            disc = format_links(item.get("discussions", []))
            md.write(f"| {tool} | {recs} | {pres} | {disc} |\n")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Generate Guild Meeting Links markdown page.')
    parser.add_argument('--input', '-i', default='', help='Input json data file')
    parser.add_argument('--output', '-o', default='', help='Output markdown file path')
    args = parser.parse_args()

    input_file = args.input
    if not input_file:
        if os.path.exists('meta/docs/api/guild_meetings.json'):
            input_file = 'meta/docs/api/guild_meetings.json'
        elif os.path.exists('docs/api/guild_meetings.json'):
            input_file = 'docs/api/guild_meetings.json'
        else:
            input_file = 'meta/docs/api/guild_meetings.json'

    output_file = args.output
    if not output_file:
        if os.path.exists('meta/docs/Guides'):
            output_file = 'meta/docs/Guides/ToolsGuildMeetingLinks.md'
        elif os.path.exists('docs/Guides'):
            output_file = 'docs/Guides/ToolsGuildMeetingLinks.md'
        else:
            output_file = 'meta/docs/Guides/ToolsGuildMeetingLinks.md'

    with open(input_file, 'r') as f:
        data = json.load(f)

    generate_markdown(data, output_file)
