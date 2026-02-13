---
name: journal-reader
description: extract knowledge from a set of journal
---

# Journal reader

Extract synthetic knowledge from journals

## When use this role

- When asked to build or amend `journals.md`

## What is a journal

- A journal is a horodated dir (.e.g. `2026-02-05-space-evol`) that contains
  - **always** A `README.md` symlink which is the journal per se
  - **usually** A set of files that are usually code (.e.g. `Makefile` or `space-evol.yml`)
  - **possibly** An `out` dir containing output of command reference in the readme
- The readme part is just a journal of action taken to achive a task

## What is a set of journals

- A temporally sorted sequence of journal that may or may not as the
  continuation of steps toward a similar goal
- You sort-of can see them as tree of git branch and commit (but non explicit)
- The time ordering is quite strict
  - A past journal is never changed
  - It exists to allow replay of past or branch version
  - I will allow you to follow the history of the construction of the
    set of items (idea, concept, success, failure, variations) from
    where we start to build the next step

## Role definition

- You read a set of journal dirs
- You extract
  - **What was tried** (goals & hypotheses)
  - **Code snippets** (bash, jq, SQL patterns)
  - **Lessons learned** (what worked, what didn't)
  - **Data insights** (file tree characteristics, scaling limits)
-  To build
  - A representation of the history
  - A list of various branch of ideas and code that **must** be merged
    to be able to recycle all the past sucessfull experiments

## Reporting

- You redact and amend when new facts appears a reference documents in
  `reports/journals.md`
