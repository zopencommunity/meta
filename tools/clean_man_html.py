#!/usr/bin/env python3
import sys
import re

def clean_man_html(content):
    # 1. Extract body content
    body_match = re.search(r'<body>(.*)</body>', content, re.DOTALL | re.IGNORECASE)
    if body_match:
        content = body_match.group(1)
    
    # 2. Basic cleanup
    content = re.sub(r'<a href="#[^"]*">.*?</a><br>', '', content)
    content = re.sub(r'<a name="[^"]*"></a>', '', content)
    content = re.sub(r'<hr>', '', content)
    
    # 3. Fix headers
    content = re.sub(r'<(h[1-6])>\s*(.*?)\s*</\1>', r'<\1>\2</\1>', content, flags=re.DOTALL)
    
    # 4. Strip <p> tags inside <td> tags
    for _ in range(3):
        content = re.sub(r'<td([^>]*)>\s*<p[^>]*>(.*?)</p>\s*</td>', r'<td\1>\2</td>', content, flags=re.DOTALL)
    
    # 5. Clean up groff-generated 5-column tables
    def simplify_groff_table(match):
        term = match.group(1).strip()
        desc = match.group(2).strip()
        term = re.sub(r'</?p[^>]*>', '', term)
        desc = re.sub(r'</?p[^>]*>', '', desc)
        # Bold term if not already bold
        if not (term.startswith('<b>') or term.startswith('<strong>')):
            term = f'<b>{term}</b>'
        return f'<tr><td style="width: 25%; vertical-align: top;">{term}</td><td style="vertical-align: top;">{desc}</td></tr>'

    groff_tr = r'<tr[^>]*>\s*<td width="[0-9]+%">.*?</td>\s*<td width="[0-9]+%">(.*?)</td>\s*<td width="[0-9]+%">.*?</td>\s*<td width="[0-9]+%">(.*?)</td>\s*<td width="[0-9]+%">.*?</td>\s*</tr>'
    content = re.sub(groff_tr, simplify_groff_table, content, flags=re.DOTALL)

    # 6. Consolidate margin-left:9% and 18% paragraphs into tables
    def consolidate_paragraphs(match):
        term = match.group(1).strip()
        desc = match.group(2).strip()
        term = re.sub(r'</?p[^>]*>', '', term)
        desc = re.sub(r'</?p[^>]*>', '', desc)
        # Bold term if not already bold
        if not (term.startswith('<b>') or term.startswith('<strong>')):
            term = f'<b>{term}</b>'
        return f'<table><tr><td style="width: 25%; vertical-align: top;">{term}</td><td style="vertical-align: top;">{desc}</td></tr></table>'

    p_9 = r'<p style="margin-left:9%[^"]*">(.*?)</p>'
    p_18 = r'\s*<p style="margin-left:18%[^"]*">(.*?)</p>'
    content = re.sub(p_9 + p_18, consolidate_paragraphs, content, flags=re.DOTALL)

    # 7. Merge adjacent tables
    for _ in range(5):
        content = re.sub(r'</table>\s*<table[^>]*>', '', content)
    
    # 8. Clean up redundant table wrappers and attributes
    content = re.sub(r'<table width="100%" border="0" rules="none" frame="void"\s+cellspacing="0" cellpadding="0">', '<table>', content)
    
    # 9. Handle URLs and links
    content = re.sub(r'&lt;(https?://.*?)&gt;', r'<a href="\1">\1</a>', content)
    content = re.sub(r'&lt;(ftp://.*?)&gt;', r'<a href="\1">\1</a>', content)
    
    def add_target_blank(match):
        tag = match.group(0)
        if 'target=' not in tag.lower():
            return tag[:-1] + ' target="_blank">'
        return tag
    content = re.sub(r'<a\s+[^>]+>', add_target_blank, content)
    
    # 10. Wrap non-HTML tags in code blocks
    content = re.sub(r'&lt;([a-zA-Z0-9_| /:-]+)&gt;', r'<code>&lt;\1&gt;</code>', content)
    
    # 11. Normalize entities
    replacements = {
        "&minus;": "-",
        "&rsquo;": "'",
        "&lsquo;": "'",
        "&rdquo;": '"',
        "&ldquo;": '"',
        "&nbsp;": " ",
    }
    for entity, replacement in replacements.items():
        content = content.replace(entity, replacement)
        
    # 12. Final cleanup of double bolds and broken table structures
    content = re.sub(r'<b>\s*<b>', '<b>', content)
    content = re.sub(r'</b>\s*</b>', '</b>', content)
    
    # Ensure diagnostics and others are in <tr> if they are orphans
    # diagnostics matched p_9+p_18 but if it was merged incorrectly:
    # We look for orphaned <b>TERM</b></td>...
    content = re.sub(r'</table>\s*<b>(.*?)</b></td>', r'<tr><td style="width: 25%; vertical-align: top;"><b>\1</b></td>', content)
    
    return content.strip()

if __name__ == "__main__":
    if len(sys.argv) > 1:
        with open(sys.argv[1], 'r') as f:
            print(clean_man_html(f.read()))
    else:
        print(clean_man_html(sys.stdin.read()))
