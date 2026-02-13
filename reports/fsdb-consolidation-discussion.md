# File Inventory System Consolidation - Discussion Report

## Overview

Discussion on consolidating multiple POC versions of a file inventory system
built on DuckDB for tracking legacy application file storage (millions of files,
primarily write-once patterns).

## Problem Context

### Use Case

-   Legacy applications store tens of millions of files (e.g., 40k files in
    MySQL directories)
-   Files are referenced in databases (e.g., MySQL) but never modified after
    creation
-   POSIX mtime allows reconstruction of volume creation history for
    provisioning planning
-   Need to track file growth over time for chargeback and capacity planning

### Key Challenge

Files are never (or rarely) touched after creation, so mtime becomes a proxy for
when data was added. This enables historical analysis without keeping all
intermediate snapshots.

## Current System Design

### Collection Pipeline

``` bash
# stat-args - Generate JSON-compatible stat format
# Extract inode and metadata as JSON, handle arbitrary filenames
stat-args YsifhUG

# files-stat - Collect file statistics using find + stat/Perl
(cd ${source} && find -type f -print0 |
  if [[ "$2" == imn ]]; then 
    perl -MJSON::PP -0 -ne "$perl"
  else 
    xargs -0r stat -c "$(stat-args $2)"
  fi)

# ingest-stat - Load into DuckDB with schema transformation
ingest-stat /data/mysql /space/var
```

### Single-Snapshot Schema

``` sql
CREATE TABLE IF NOT EXISTS fsdb (
  date TIMESTAMP,
  mdate TIMESTAMP,
  size BIGINT,
  suf VARCHAR,
  path VARCHAR[]
);
```

**Logic:**

-   `date`: collection timestamp (when fsdb was built)
-   `mdate`: file modification time
-   `size`: file size in bytes
-   `suf`: file extension (extracted via regex)
-   `path`: path components as array for hierarchical queries

**Ingest SQL:**

``` sql
INSERT INTO fsdb SELECT
  to_timestamp((js.json->0)::BIGINT),
  to_timestamp((js.json->1)::BIGINT),
  (js.json->2)::BIGINT,
  regexp_extract(js.json->>3, '\.([^./]+)$', 1),
  list_filter(string_split(js.json->>3, '/'), x -> x != '.')
FROM read_json_auto('/dev/stdin') js
```

## Multi-Snapshot Extension

### Motivation

Some users want to track evolution of growing datasets (e.g., MySQL dir growing
daily). Single-snapshot doesn't capture this history. Multi-snapshot allows:

-   Time-series of storage growth
-   Identification of when files were added
-   Detection and tracking of file deletions
-   Reconstruction of filesystem state at arbitrary past timestamps

### The Prune Problem: `prune-dedup`

**Goal:** Only keep traces of changes; delete rows where file size hasn't
changed between consecutive snapshots.

**Logic:** Remove unchanged files but always preserve the most recent snapshot
intact.

``` sql
DELETE FROM fsdb
WHERE rowid IN (
    SELECT rowid FROM (
        SELECT
            rowid,
            date,
            size,
            LAG(size) OVER (PARTITION BY path ORDER BY date) AS prev_size
        FROM fsdb
    )
    WHERE size = prev_size
      -- CRITICAL: Protect the most recent snapshot regardless of duplication
      AND date < (SELECT MAX(date) FROM fsdb)
)
```

**Usage:**

``` bash
duckdb $db_path -c "$prune_sql"
```

**Note:** Only considers `size` for deduplication (via `PARTITION BY path`).
Suffix is in path, so it's implicitly considered.

### The Ghost Files Problem: `mark-deleted`

**Goal:** Keep trace of deleted files to avoid misattributing size changes.

**Problem:** When files are deleted between snapshots, the new snapshot's total
size appears smaller. Without marking deletions, this looks like negative
growth, which is misleading.

**Solution:** Insert "ghost" rows (with `size=NULL`) for files that disappeared.

**Logic:**

1.  Identify `curr_t` (latest timestamp) and `prev_t` (previous timestamp)
2.  Find paths present at `prev_t` but missing at `curr_t` using `EXCEPT`
3.  Insert them with `size=NULL` as deletion markers

``` sql
INSERT INTO fsdb
WITH meta AS (
  SELECT
    MAX(date) as curr_t,
    MAX(date) FILTER (WHERE date < (SELECT MAX(date) FROM fsdb)) as prev_t
  FROM fsdb
),
deleted_paths AS (
  -- Files present in Previous but missing in Current
  SELECT path FROM fsdb, meta WHERE date = meta.prev_t
  EXCEPT
  SELECT path FROM fsdb, meta WHERE date = meta.curr_t
)
SELECT
  meta.curr_t AS date,
  NULL AS mdate,
  NULL AS size,  -- The Deletion Marker
  NULL AS suf,
  path
FROM deleted_paths, meta
```

**Usage:**

``` bash
duckdb $db_path -c "$mark_deleted_sql"
```

### The Workflow: `add-snapshot`

Chain the operations in order:

``` bash
add-snapshot() {
  ingest-stat "$@"
  prune-dedup "$@"
  mark-deleted "$@"
}
```

**Example usage:**

``` bash
sudo bash out/fsdb.sh add-snapshot /var/log tmp
duckdb tmp/var-log.db -readonly -c 'select * from fsdb'
```

### Reconstructing State at Arbitrary Timestamp: `view-snapshot`

**Goal:** Query the filesystem state at any point in time, reconstructing from
snapshots and deltas.

**Logic:**

1.  Capture the latest timestamp in DB as a boundary
2.  Filter to snapshots up to target time
3.  Group by path and take the most recent entry (via `arg_max`)
4.  Exclude ghosts (`HAVING size IS NOT NULL`)

``` sql
WITH boundary AS (SELECT MAX(date) as max_d FROM fsdb)
SELECT
  LEAST('\($target)'::TIMESTAMP, boundary.max_d) AS date,
  arg_max(mdate, date) AS mdate,
  arg_max(size, date) AS size,
  path
FROM fsdb, boundary
WHERE fsdb.date <= '\($target)'::TIMESTAMP
GROUP BY path, boundary.max_d
HAVING size IS NOT NULL
```

**Usage:**

``` bash
local target="${1:-now}"
local db=$(DB-files-stat "$@")
SQL --arg target "$target" | duckdb -nullvalue ' ' "$db"
```

**Notes:**

-   `arg_max(size, date)` correctly picks the latest entry even if it's a NULL
    marker
-   `HAVING size IS NOT NULL` filters out ghosts in final report
-   Can query at any timestamp to get state at that point in time

## Consolidation Strategy

### Three Decisions Needed

1.  **Collection mode unification**

    -   Remote mode: `ssh remote "collect $source" | ingest $target`
    -   Local mode: `collect $source | ingest $target` (cron)
    -   Tension: Where does filesystem live? Deployment constraints?

2.  **Single vs Multi-Snapshot schema**

    -   Single-snapshot: Simpler, but only answers "what does filesystem look
        like now based on file mtimes?"
    -   Multi-snapshot: More complex, but answers "how did filesystem evolve
        over time?"
    -   Multi-snapshot is a superset that can answer both questions (if
        validated)

3.  **Query library (CTEs)**

    -   Single-snapshot queries pivot on `mdate` (file modification time)
    -   Multi-snapshot queries pivot on `date` (collection/snapshot time)
    -   These are fundamentally different question sets

### Key Insight: The Query Difference

**Single-Snapshot Logic:**

-   Ignore `date` (collection time)
-   All queries use `mdate` (file modification time)
-   Example: "Files untouched for 6 months" =
    `WHERE mdate < now - INTERVAL '6 months'`
-   Example: "Growth by month" = `GROUP BY DATE_TRUNC('month', mdate)`

**Multi-Snapshot Logic:**

-   Keep and use `date` (collection time)
-   Also use `mdate` (file modification time)
-   Example: "Files untouched as of 2025-02-01" =
    `WHERE date = '2025-02-01' AND mdate < date - INTERVAL '6 months'`
-   Example: "Growth trajectory over time" = pivot on `date`, GROUP BY `date`
    and suffix

### Proposed Unified Approach

**Two separate collection paths:**

-   `collect-simple`: For creation-only datasets (dump current state, one
    snapshot)
-   `collect-evolving`: For datasets with history (append, prune, mark-deleted)

**One shared reporting layer:**

-   Both write to same `fsdb` schema
-   Reporting CTEs parameterized by timestamp
-   `view-snapshot` as foundation (works on both single and multiple snapshots)

**Why this works:**

-   A single-snapshot database is isomorphic to a multi-snapshot database with
    only one snapshot
-   `view-snapshot` works on both cases
-   Time-parameterized queries work on both (single returns that one snapshot,
    multiple returns state at that time)
-   Only `prune-dedup` and `mark-deleted` are no-ops on single-snapshot

## Validation Required

### Current Status

-   Real data: MySQL directory (40k files) with hourly snapshots for 2 weeks
-   No deletions yet, so ghost logic unvalidated
-   Previous POC reports had schema issues (used INT instead of TIMESTAMP)

### Before Consolidation: Validate Multi-Snapshot Correctness

Must confirm with test data:

1.  Does `mark-deleted` correctly identify deleted files?
2.  Does `view-snapshot` correctly reconstruct state at past timestamps?
3.  Does file recreation (delete then re-add) work as expected?
4.  Do time-series queries produce intuitive results?

Once MS is validated as correct, unification becomes viable.

## Decision Tree

**Current data patterns:**

-   MySQL dir: evolving (needs MS)
-   Write-once datasets: creation-only (don't need MS)

**Solution:**

-   MS is a superset; if validated, can handle both with one tool
-   But only after validation is it safe to consolidate
-   Alternative: keep two separate tools if MS validation reveals problems

## Next Steps

1.  Build test harness with synthetic deletions/recreations
2.  Validate `mark-deleted` and `view-snapshot` logic
3.  If valid: design unified `collect-append` + shared reporting CTEs
4.  If problems found: fix or maintain separate tools
