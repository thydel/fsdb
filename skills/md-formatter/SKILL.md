---
name: md-formatter
description: Auto-format markdown to 80-char lines with autofill using pandoc
---

# Format Markdown Files

Wraps markdown paragraphs to 80 characters using pandoc while
preserving code blocks, tables, and other formatting.

# When to activate

- After Generating or editing project markdown files
- Before committing the files

# When NOT to activate

- When MD files are meta files like files in `skills` dir

## Usage

Run the formatter on one or more markdown files

```bash
scripts/fmt-md.sh file1.md file2.md
```

## Input

- **File argument**: Path to markdown file(s) to format (required)
- Files are processed in-place

## Output

- Formatted markdown file(s) with paragraphs wrapped to 80 characters
- Non-paragraph content (code blocks, tables, lists) preserved as-is
