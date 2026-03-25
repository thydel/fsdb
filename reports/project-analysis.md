# FSDB: Project Analysis Report

## 1. Project Overview

`fsdb` (File System Data Base) is a highly optimized, DuckDB-based file tree analyzer. Its primary goal is to efficiently ingest, store, and query massive amounts of filesystem metadata (timestamps, sizes, paths) across multiple servers.

Historically, tracking filesystem growth (especially on massive NFS arrays or upload directories) is a slow and cumbersome process involving slow `find` or `du` commands. `fsdb` solves this by:
1. Emitting raw `stat` data rapidly using Perl (`lstat()` to JSON) or `find`.
2. Ingesting this data into **DuckDB** for blazingly fast analytics.
3. Providing a highly composable **bash-based exploration pipeline** powered by SQL Common Table Expressions (CTEs).

A key architectural feature of `fsdb` is that it is built entirely using **`baj`**, a macro compiler that turns declarative Markdown and YAML into self-contained Bash functions.

---

## 2. Architecture & Technical Stack

The technical stack is minimalist but extremely powerful, relying on standard UNIX tools augmented by a modern analytical database:

- **Data Collection:** `find` and `perl` (`JSON::PP`) to quickly walk file trees and emit structured JSON arrays (`[timestamp, mtime, size, path]`).
- **Storage Engine:** **DuckDB**. It reads JSON rapidly (`read_json_auto`) and provides advanced SQL features like time bucketing, array manipulation, and window functions.
- **Query Generation:** **jq** is used extensively as a transformation engine to parse arguments and construct SQL queries dynamically.
- **Compilation Engine:** **baj** compiles the source files (`fsdb-*.md`) into sourceable, streamable bash scripts.
- **Execution Environment:** Bash. Generated functions can be streamed over SSH (`with-lib ... | ssh host bash`) for zero-copy remote execution without installing agents on target servers.

### 2.1 The Two-Tier Database Strategy
To handle massive scale (e.g., 39.7M entries, 7.4 TiB across 18 servers), `fsdb` employs a dual-database approach:
1. **Full DB:** High-resolution database containing every file. Useful for deep, localized analysis.
2. **Small/Reduced DB:** Hour-bucketed aggregations (count, sum, min, max, avg). By using `time_bucket(INTERVAL '1 hour', uts)` and dropping the filename leaf node (`path[1 : len(path)-1]`), the database size shrinks drastically (e.g., 30x smaller), making it distributable and easy to store in git or share.

---

## 3. The `baj` Macro Integration

The entire `fsdb` toolset is written as declarative Markdown files (`[SRC]` files like `fsdb-build.md`, `fsdb-cte.md`). `baj` treats these files as literate notebooks.

### How `fsdb` uses `baj`
- **m4 Macros:** `fsdb` uses `m4` within Markdown to define reusable snippets. For example, the `SQL` macro is heavily used to interpolate `jq` arguments into SQL strings safely:
  ```m4
  m4_define(SQL,jq -nr "\"$sql\"" "$«@»")
  ```
- **Code Generation:** Functions are defined with `# id my-func` headers. Code blocks (`jq`, `sql`, `bash`) under these headers are compiled by `baj`.
  - An `sql` block becomes a `local sql='...'` string.
  - A `jq` block becomes a `local jq='...'` string.
  - The `bash` block executes the logic using the generated `sql` or `jq` variables.
- **Streaming over SSH:** By compiling everything into discrete Bash functions, `fsdb` can select a specific data collection function (like `files-stat`) and pipe it via SSH to a remote server. The remote server evaluates the function in-memory and returns the data, avoiding any installation footprint.

---

## 4. The CTE Pipeline System

The most innovative component of `fsdb` is its **CTE (Common Table Expression) Pipe Engine** defined in `fsdb-cte.md` and `fsdb-pipes.md`.

Writing complex analytical SQL queries manually is tedious. `fsdb` implements a functional, pipeline-based DSL (Domain Specific Language) in bash that compiles down to a single DuckDB SQL query.

### 4.1 The Channel Architecture
Each step in the pipeline is a Bash function that outputs JSON to `stdout` and reads from `stdin`. The data passed between pipes is not the actual database rows, but a **query AST (Abstract Syntax Tree)** in a channel format:
```json
[
  { "a": {"ts": "date", "file": "path", "tbl": "fsdb", "vals": "cnt,size", "part": "server"}, "q": "FROM fsdb" },
  { "a": {...}, "q": "SELECT * FROM {prev} WHERE size == 0" }
]
```
- `.a` (Args): Propagates column name aliases and state down the pipeline.
- `.q` (Query): The SQL string for this specific step. It uses the `{prev}` token as a placeholder for the CTE alias of the previous step.

### 4.2 Operator Classes
The pipeline elements mimic functional programming paradigms:

| Class | Operators | Purpose |
|-------|-----------|---------|
| **Source** | `start` | Initializes the channel, setting default column names (`ts`, `file`, `tbl`). |
| **Filter** | `where`, `is`, `like`, `last`, `first`, `since`, `until` | Generates `WHERE` clauses (e.g., `last 6 month`). |
| **Map** | `keep`, `as`, `hide`, `rename`, `human`, `sep`, `pct` | Column projection and formatting (e.g., formatting bytes to MB). |
| **Aggregate** | `sum`, `count`, `grpcnt`, `distinct`, `span` | Grouping and aggregation. `span` is a powerful time-bucketing tool. |
| **Window** | `growth`, `acc` | Advanced analytics using window functions (e.g., calculating day-over-day growth rates). |
| **Order/Limit** | `order`, `items` | Sorting and limiting results. |
| **Meta/Terminal** | `chain`, `merge-cte`, `fmt-auto` | `merge-cte` is the terminal step that compiles the accumulated JSON channel into a final, valid `WITH step0 AS (...), step1 AS (...) SELECT * FROM stepN` SQL string. |

### 4.3 Pipeline Example
A user can write a simple bash command:
```bash
start | last 6 month | span month | growth size | order date asc | merge-cte | ddb -box
```
This is dynamically compiled by the `merge-cte` step into a complex, multi-stage SQL query and immediately executed by DuckDB (`ddb`), returning beautifully formatted text boxes.

---

## 5. Historical Evolution & Lessons Learned

Based on the synthesis in `journals.md`, the project evolved through iterative experimentation from late 2025 to early 2026:

1. **Initial Proof of Concept (Oct 2025):** Proved that DuckDB could ingest 1.6M files in 3.9 seconds and query them instantly.
2. **CTE Pipe Invention (Nov 2025):** The realization that writing raw SQL for time-series disk analysis was repetitive led to the creation of the `sql-cte.yml` (later `fsdb-cte.md`) composable operators.
3. **The Size Problem (Nov 2025):** Full-resolution databases were too large to store in git (119MB). The hour-bucketed approach was invented, shrinking data to 3.3MB.
4. **Deduplication & Ghost Rows (Jan 2026):** To track growing directories over time, the system was updated to take hourly snapshots. To prevent unbounded DB growth, a brilliant `prune-dedup` (delete unchanged sizes) and `mark-deleted` (insert NULL sizes for deleted files) strategy was implemented.
5. **Switch to `baj` (Dec 2025 - Jan 2026):** The project fully embraced the `baj` compiler, moving away from older tools (`jqsh`), formalizing operator classes, and enabling zero-copy remote execution.
6. **Consolidation (Feb 2026):** The framework was successfully applied to 18 servers processing 7.4 TiB and 39.7M entries into a unified mega-database.

### Failed Experiments
- **File-type collection:** Attempting to run `libfile-libmagic-perl` against network filesystems was abandoned because it took 350 minutes vs 4 minutes for standard `stat`. Speed and scale are prioritized.

---

## 6. Conclusion

`fsdb` is a masterclass in composing standard UNIX primitives with modern tools. By combining the serialization power of `bash` functions (via `baj`), the JSON-munging capabilities of `jq`, and the analytical speed of `DuckDB`, it provides a system capable of tracking petabytes of storage growth efficiently. Its CTE pipeline compiler represents a highly innovative approach to making complex SQL analysis accessible directly from the command line.