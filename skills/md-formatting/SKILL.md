---
name: md-formatting
description: How to format Markdown files
---

# Markdown formatting

## When use this skill

Use this skill when the user ask for any Markdown document related to
project to be made or edited

## When no to use this skill

Writing Markdown documents for LLM that may expect slightly different
convention (like editing a skill file)

## How to format Markdown

- Filenames are implicit document root
- Use H1 (#) for top-level sections
- No artificial single-root wrapper
- Flat hierarchy preferred for easy reorganization, that is do not
  number section except to emphasis a set a section denoting a ordered
  sequence of actions
- Section titles are sentence case not "American Title Case"
  convention (capitalize major words)

## Markdown tags

### The tags

- `[WIP]` Work in progress, not yet reviewed/finalized (.e.g. a
  template/example LLM generated section not yet edited).
- `[HUMAN]` Text section not intended for LLM (.e.g human notes about
  things to revamp in LLM directive)

### How LLM should interpret tags

**Paired tags (applies only to enclosed content):**

```
Some text here.

[START WIP]
This section only is work in progress.
[END WIP]

More text here (not WIP).
```

**Single tag (must only appear in an otherwise empty section):**

```
# Only the title is chosen
[WIP]
```

### How to work with tags

- `[HUMAN]` LLM must completely ignore the content
- `[WIP]` LLM must not infer any knowledge, intention, directive or
  action from [WIP] parts but they can suggest modifications to the
  [WIP] part itself

## Emacs tags

- The following `txt` block is for emacs not for LLM

```txt
[Local Variables:]::
[indent-tabs-mode: nil]::
[End:]::
```
