# Nightly Build Script Documentation

## Overview

The nightly build script (`cicd/on_nightly.sh`) automates the generation of zopen documentation, including:
- API reference documentation (man pages → Markdown)
- Status pages (upstream/vulnerability reports)
- Contributor lists
- GitHub workflow updates

## Architecture

The script is organized into clear functional sections:

### 1. **Configuration & Logging** (Lines 14–28)
Centralized configuration variables and logging utilities:
- `SCRIPT_DIR`: Script location
- `REPO_URL`: GitHub repository URL
- `WORK_DIR`: Temporary work directory
- `log()`: Timestamped logging
- `error()` / `die()`: Error handling with exit codes

### 2. **Main Entry Points** (Lines 31–32, 612–621)
- `UpdateGithub()`: Updates GitHub workflows
- `UpdateDocs()`: Orchestrates all documentation generation
- `main()`: Entry point that calls both

### 3. **Documentation Generation** (Lines 49–146)

#### `GenerateStatusDocs()`
- Generates currency status page
- Creates upstream patch report
- Generates zopen files list
- Updates status page

#### `GenerateVulnerabilityDocs()`
- Queries osv.dev for CVE data
- Generates vulnerability documentation

#### `GenerateContributorsList()`
- Updates team.md with GitHub contributors graph

#### `GenerateApiReference()`
- Creates man pages from source
- Initializes API reference index

### 4. **Man Page Conversion** (Lines 152–208)

#### `ConvertManPagesToMarkdown()`
Main loop that processes all man pages.

#### `ConvertSingleManPage()`
Processes a single man page through the entire cleaning pipeline:
1. Extract HTML body from groff output
2. Remove inline formatting tags
3. Collapse multi-line table tags
4. Collapse heading tags
5. Strip trailing whitespace
6. Convert margin-left paragraphs to tables
7. Convert groff layout tables to bordered tables
8. Linkify URLs
9. Remove orphaned tags
10. Write markdown file
11. Validate HTML structure

### 5. **HTML Cleaning Pipeline** (Lines 213–506)

Each function handles one specific cleaning task:

| Function | Purpose | Input/Output |
|----------|---------|--------------|
| `ExtractHtmlBody()` | Extract body from groff HTML, remove nav links | HTML file → text |
| `RemoveInlineFormatting()` | Strip `<i>`, `<em>`, `<b>`, `<strong>` | text → text |
| `CollapseTableTags()` | Join multi-line table opening tags | text → text |
| `CollapseHeadingTags()` | Join split h1/h2 tags | text → text |
| `StripTrailingWhitespace()` | Remove line-end whitespace | text → text |
| `ConvertMarginParagraphsToTables()` | Convert groff 11%/22% pairs to tables | text → HTML |
| `ConvertGroffTablesToBordered()` | Convert layout tables to styled bordered | HTML → HTML |
| `LinkifyUrls()` | Convert URLs to `<a href="">` | HTML → HTML |
| `RemoveOrphanedTags()` | Remove unmatched closing tags | HTML → HTML |

### 6. **File Output & Validation** (Lines 511–551)

#### `WriteMarkdownFile()`
Wraps cleaned content in Vue-compatible `<div v-pre>` container.

#### `ValidateMarkdownFile()`
Checks tag balance (opening count = closing count) for each HTML tag.

## Adding New Cleaning Passes

To add a new HTML cleaning pass:

```bash
AddNewFix() {
  # Add clear comments about what this fixes
  echo "$1" | python3 - <<'PYEOF'
import sys, re
content = sys.stdin.read()

# Your fix here
# Example: remove all <span> tags
content = re.sub(r'</?span[^>]*>', '', content)

print(content, end='')
PYEOF
}

# In ConvertSingleManPage(), add:
body_content=$(AddNewFix "$body_content")
```

Then in the pipeline (around line 197):
```bash
body_content=$(LinkifyUrls "$body_content")
body_content=$(AddNewFix "$body_content")  # Add here
body_content=$(RemoveOrphanedTags "$body_content" "$md")
```

## Build Issue Fixes

The script automatically handles:

### Missing Tags
✓ Detects and reports unclosed/orphaned tags  
✓ Removes surplus closing tags intelligently  
✓ Validates tag balance after generation

### Bad Nesting
✓ Collapses multi-line table/heading tags (Vue compatibility)  
✓ Ensures proper HTML structure  
✓ Validates post-generation

### Special Characters
✓ Handles groff HTML entities (`&lt;`, `&gt;`, `&rsquo;`, `&minus;`)  
✓ Linkifies URLs with entities and bare URLs  
✓ Preserves special characters in option names

### Whitespace Issues
✓ Strips trailing whitespace (prevents Vue confusion)  
✓ Normalizes multi-line table attributes  
✓ Handles whitespace-only lines in tables

### Groff Artifacts
✓ Removes navigation links (`<a href="#"...>`)  
✓ Removes anchor tags (`<a name="..."...>`)  
✓ Removes page breaks (`<hr>`, `<br>`)  
✓ Removes inline formatting tags

### Table Conversion
✓ Converts groff margin-left paragraph pairs to HTML tables  
✓ Handles "split-table" pattern (long option names pushing description to next row)  
✓ Absorbs orphaned description paragraphs  
✓ Converts layout tables to styled bordered tables with headers

## Error Handling

The script uses bash `set -e` for immediate exit on errors, with specific handling:

```bash
# Creates temp file with auto-cleanup
temp_html=$(mktemp) || die "Failed to create temp file"
trap "rm -f '$temp_html'" RETURN

# Safe directory change
cd "$WORK_DIR" || die "Failed to enter work directory"

# Logging all major operations
log "Converting man pages to Markdown..."
```

## Testing

Validate script syntax:
```bash
bash -n cicd/on_nightly.sh
```

Run a single man page conversion (manual):
```bash
cd meta_update
source cicd/on_nightly.sh
ConvertSingleManPage "man/man1/zopen-init.1"
```

## Future Enhancements

Suggested improvements:

1. **Parallelization**: Convert multiple man pages concurrently
2. **Progress Tracking**: Add percentage indicators for long runs
3. **Detailed Diff Reports**: Show what changed in generated files
4. **Dry-Run Mode**: Preview changes without committing
5. **Specific File Processing**: Allow targeting specific man pages
6. **Recovery Mode**: Ability to restart failed conversions

## Maintenance Notes

- Order of cleaning passes matters (see line ~194 comments)
- Always validate with `ValidateMarkdownFile()` after adding new passes
- Keep HTML entities consistent in Python passes
- Use `re.DOTALL` flag when matching across multiple lines in Python regex
- Test new passes on a single file first before running full pipeline

## Related Files

- `docs/reference/*.md` — Generated markdown files
- `man/man1/*.1` — Source man pages
- `docs/reference/zopen-reference.md` — Generated index
- `.env` — Project environment variables
