<!--
echo '$table-of-contents$' > tmp/toc.md
< CLAUDE.md pandoc -f gfm -t gfm --toc --toc-depth=6 --template tmp/toc.md --columns=196 | grep -v Table.of.Contents
-->

-   [FSDB project configuration](#fsdb-project-configuration)
    -   [Project overview](#project-overview)
    -   [Project steps](#project-steps)
    -   [Used skills](#used-skills)
    -   [Key tools & technologies](#key-tools--technologies)
        -   [Internal references](#internal-references)
        -   [External references](#external-references)
    -   [Project structure](#project-structure)
        -   [File conventions](#file-conventions)

# FSDB project configuration

## Project overview

Building a DuckDB-based file tree analyzer that generates SQL CTEs for
bash-based exploration pipelines, informed by experimental POCs in the
`baj` macro system.

## Project steps

- [X] Use `baj-expert` skill to build [baj.md][]
- [X] Use `journal-reader` skill to build [journals.md][]
- [X] See CTE

## Steps

### Rethink CTE list

- Starting [journals.md][] propose a set of primitive CTE component
  designed to help analysis of FSDB DB
- Focus on composability and expressivity
- Allow various DB col name via argument passing (.e.g timestamp is
  `date` or `TS`, file is `path` or `file`)
- Use a channel to propagate arguments (a CTE is `[{ args: {}, cte: SQL_CTE }]` instead of `[SQL_CTE]`

- Example
  - last/first year, 2 week, day, ...
  - start/end 2025-01, 2025-01-15, ...
  - span day, 4 hour, ...
  - items 100

## Howto test

```bash
source baj/cmd/baj.sh
source baj/cmd/parsarg.sh
load out/fsdb-cte.yml
```

```console
thy@tdews1-256g:~/usr/hub/work/claude/fsdb$ ids fsdb | fmt
ddb sql start merge-cte where is like last first since until keep hide
rename human sep pct sum count grpcnt distinct span growth acc order
items chain fmt-auto
```

## Available DB to test

```console
thy@tdews1-256g:~/usr/hub/work/claude/fsdb$ duckdb tmp/prostrc1-space-nfsdata-small.db "select * from fsdb limit 4"
┌──────────────────────────┬──────────────────────────────────────────────────────────────────────────┬───────┬─────────┬─────────┬─────────┬────────────────────┐
│           date           │                                   path                                   │  cnt  │  size   │   min   │   max   │        mean        │
│ timestamp with time zone │                                varchar[]                                 │ int64 │ int128  │  int64  │  int64  │       double       │
├──────────────────────────┼──────────────────────────────────────────────────────────────────────────┼───────┼─────────┼─────────┼─────────┼────────────────────┤
│ 2014-07-15 09:00:00+02   │ [profnt2, ssl.damoc-tb.net, data, htdocs, code, files, files_1731959368] │     2 │ 3305169 │ 1650466 │ 1654703 │          1652584.5 │
│ 2014-07-15 10:00:00+02   │ [profnt2, ssl.damoc-tb.net, data, htdocs, code, files, files_1731959368] │     3 │  365008 │   44544 │  247760 │ 121669.33333333333 │
│ 2014-07-15 11:00:00+02   │ [profnt2, ssl.damoc-tb.net, data, htdocs, code, files, files_1731959368] │     5 │ 5243931 │   44544 │ 1650557 │          1048786.2 │
│ 2014-07-15 12:00:00+02   │ [profnt2, ssl.damoc-tb.net, data, htdocs, code, files, files_1731959368] │     1 │ 1650657 │ 1650657 │ 1650657 │          1650657.0 │
└──────────────────────────┴──────────────────────────────────────────────────────────────────────────┴───────┴─────────┴─────────┴─────────┴────────────────────┘
```

## Used skills

<!--
ls skills/*/*.md | jq -Rr '(./"/")[1] as $n | ["- [\($n)][]", "[\($n)]: \(.)"]' | jq -sr transpose[][]
-->

- [baj-expert][]
- [journal-reader][]
- [md-formatter][]
- [md-formatting][]

[baj-expert]: skills/baj-expert/SKILL.md
[journal-reader]: skills/journal-reader/SKILL.md
[md-formatter]: skills/md-formatter/SKILL.md
[md-formatting]: skills/md-formatting/SKILL.md

## Key tools & technologies

- **DuckDB (DD)**: Store the file tree DB
- **baj**: Macro generator; `docs/baj-overview.md` will be the main code driver
- **bash/jq/SQL**: Primary languages for extraction & transformation

### Internal references

- [baj.md][] to be edited by `baj-expert` skill
- [journals.md][] to be edited by `journal-reader` skill
- [FSDB consolidation discussion.md][] a previous dicussion with an
  LLM with no full access to discussed material, maybe useful

[baj.md]: reports/baj.md
[journals.md]: reports/journals.md
[FSDB consolidation discussion.md]: reports/fsdb-consolidation-discussion.md

### External references

- [jq 1.7 Manual][]
- [DuckDB stable Documentation][]
- [GNU Bash manual][]

[jq 1.7 Manual]:
    https://jqlang.org/manual/v1.7/
    "jqlang.org"

[DuckDB stable Documentation]:
    https://duckdb.org/docs/stable/
    "duckdb.org"

[GNU Bash manual]:
	https://www.gnu.org/software/bash/manual/html_node/index.html
    "gnu.org"

## Project structure

```
repo/
├── cmd/               # The baj generated bash files [LLM-CONTEXT]
├── docs/              # All non src MD files, mainly for humans [SRC]
├── fsdb-build.md      # MD baj src for DB build [SRC]
├── fsdb-cte.md        # MD baj src for CTE constructor func [SRC]
├── fsdb-main.md       # MD baj src to include baj parts [SRC]
├── fsdb-pipes.md      # MD baj src for useful predefined CTE pipes [SRC]
├── journals/          # Historical POCs & experiments [LLM-CONTEXT]
├── Makefile           # run baj
├── reports/           # Reports made by LLM [LLM-OUTPUT]
├── out/               # generated files that can be committed [LLM-IGNORE]
└── tmp/               # generated files (.e.g. DB) that won't be committed [LLM-IGNORE]
```

### File conventions

- Files tagged with `[SRC]` are primary working material (read and modify by user and LLM)
- Files tagged with `[LLM-CONTEXT]` are reference/background/generated (read only)
- Files tagged with `[LLM-OUTPUT]` are generated and amend by LLM
- Files tagged with `[LLM-IGNORE]` should not be processed

[Local Variables:]::
[indent-tabs-mode: nil]::
[End:]::
