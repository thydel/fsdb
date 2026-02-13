# Journals synthesis

Synthetic knowledge extracted from the `journals/` directory.

## History overview

Ten journals spanning 2025-10-16 to 2026-02-05, forming two main
branches that converge toward a unified file tree analyzer.

```
2025-10-16  space-evol ──────────── POC: duckdb on ssp/upload + apicrypt
     │
2025-10-22  space-evol ──────────── Extends to mailmerge + profntr1-ssp, cumulative plots
     │
2025-11-03  space-evol ──────────── Adds file-type collection, multi-set orchestration
     │
     ├── 2025-11-05  space-evol-tdep ─── New branch: TDEP ticket, CTE pipe invention
     │       │
     │   2025-11-25  space-evol-tdep ─── Hour-bucketed DB, staticx DuckDB, pivot reports
     │       │
     │   2026-01-13  space-evol-tdep ─── MySQL /data hourly tracking, prune-dedup, mark-deleted
     │       │
     │   2026-01-25  space-evol-tdep ─── Production cron, fsdb-core.md baj lib, remote install
     │
     ├── 2025-12-23  space-evol-ssp ──── Switches jqsh→baj, CTE operator classes, path arrays
     │       │
     │   2026-01-29  prostrc1-space2 ─── Applies framework to mailmerge, growth/acc operators
     │
     └── 2026-02-05  space-evol ──────── Consolidation: 18 servers, 7.4 TiB, merged mega-DB
```

## Branch 1: SSP space evolution (space-evol)

### 2025-10-16 — First POC

- **Goal**: Evaluate disk usage for SSP prod (INFRA-2301)
- **Approach**: Collect `[timestamp, size, path]` via SSH, ingest
  into DuckDB, query by year/hour
- **Tools**: `jqsh` (predecessor to baj), `duckdb`, `youplot`
- **Worked**: DuckDB ingestion fast (3.9s for 1.6M files), queries
  sub-second, plots generated
- **Data**: ssp/upload 547 GB across 1.6M files (2014-2025),
  ssp/apicrypt 34 GB across 157K files

### 2025-10-22 — Multi-dataset extension

- **Goal**: Add mailmerge and profntr1-ssp datasets, cumulative views
- **Approach**: Data-driven config in YAML, `ejq` for metadata
  expansion, cumulative sum queries
- **Worked**: Four datasets collected and plotted (ssp-upload,
  ssp-apicrypt, mailmerge, profntr1-ssp)
- **Data**: mailmerge 363 GB / 3.8M files, profntr1-ssp 473 GB /
  2.0M files

### 2025-11-03 — File type collection

- **Goal**: Add file-type metadata alongside size/timestamp
- **Approach**: `libfile-libmagic-perl` on NFS servers, `get-all-data`
  orchestration
- **Lesson**: File-type collection is slow (350 min for profntr1-ssp
  vs 4 min for stat)

## Branch 2: TDEP ticket (space-evol-tdep)

### 2025-11-05 — CTE pipe invention

- **Goal**: Answer INFRADESK-3466 (weekly disk usage reports for
  depistage team)
- **Approach**: Built `sql-cte.yml` library — composable CTE
  operators piped together:
  ```
  start | where ... | cnt appli | order cnt
  ```
  Generates:
  ```sql
  WITH step0 AS (FROM stat),
  step1 AS (SELECT * FROM step0 WHERE ...),
  step2 AS (SELECT appli, COUNT(*) AS cnt FROM step1 GROUP BY appli),
  step3 AS (SELECT * FROM step2 ORDER BY cnt DESC)
  SELECT * FROM step3
  ```
- **Key patterns**:
  - CTE operators: `start`, `where`, `cnt`, `sum`, `order`, `plot`,
    `n-ts-bucket`, `span`, `stats`, `hist`
  - `{prev}` replacement in SQL templates
  - `merge-cte` to assemble pipeline into valid SQL
  - Predefined pipelines in `stat-sql.yml` (e.g. `empty-files`,
    `plot-col`, `hist`)
- **Worked**: Full reporting by split/node/appli with bar charts
- **Data**: 16.1M files, 2.76 TiB, 7 storage nodes, 2014-2025

### 2025-11-25 — Hour-bucketed database

- **Goal**: Create distributable DB small enough for repo inclusion
- **Approach**: Aggregate raw stat into hourly buckets
  (`time_bucket(INTERVAL '1 hour', ...)`), reducing 119 MB to 3.3 MB
- **Key patterns**:
  - Docker for remote DuckDB: `docker run ... duckdb`
  - `staticx` for static binary on work1
  - Pivot tables by node/appli/time period
- **Worked**: Hour-aggregated DB fits in repo, sufficient for trend
  analysis
- **Data**: Top apps by size — esisdocs-idf 4.6 TiB, esisdocs-naq
  3.3 TiB

### 2026-01-13 — Hourly MySQL tracking

- **Goal**: Track `/data/mysql` on prot3cbdde1 with hourly snapshots
- **Approach**: `perl` for `lstat()` → JSON, remote DuckDB, loop
  collection, deduplication
- **Key inventions**:
  - `prune-dedup`: DELETE rows where size unchanged between
    consecutive snapshots (keep latest)
  - `mark-deleted`: INSERT NULL-size ghost rows for disappeared files
  - `add-snapshot`: chain of ingest → prune → mark-deleted
  - `view-snapshot`: reconstruct state at arbitrary timestamp via
    `arg_max(size, date)` + `HAVING size IS NOT NULL`
- **Worked**: Growth visible at 6h granularity (750 MB over 4
  snapshots)
- **Lesson**: Dedup essential — without it, DB grows unbounded

### 2026-01-25 — Production deployment

- **Goal**: Install fsdb-core as production cron job on prot3cbdde1
- **Approach**: Baj-compiled `fsdb-core.md` → `out/fsdb-core.sh`,
  cron entry via SSH
- **Key patterns**:
  - Markdown literate baj source (`# raw header`, `# id func-name`)
  - Perl stat collector with JSON::PP
  - DuckDB schema: `fsdb(date, mdate, size, suf, path VARCHAR[])`
  - `path-to-name`: converts `/data/mysql` → `data-mysql` for DB
    filename
  - `with-lib fsdb -- func args | ssh host bash` for zero-copy
    execution
- **Companion**: `parsarg.md` — DFA-based argument parser for bash

## Branch 3: SSP with baj (space-evol-ssp)

### 2025-12-23 — Switch to baj, CTE classes

- **Goal**: Redo SSP analysis with baj instead of jqsh, formalize CTE
  operators
- **Approach**: `ssp.md` as baj Markdown source, CTE operator
  classification
- **Key inventions**:
  - Operator classes: `source`, `map`, `filter`, `aggregate`,
    `order_limit`
  - `path VARCHAR[]` with `path[1:N]` for hierarchical depth queries
  - Full + small (time-bucketed) database pattern
  - `ddb` helper: wraps DuckDB invocation with standard flags
- **Key patterns**:
  - `SQL` m4 macro: `jq -nr "\"$sql\"" "$«@»"` for jq→SQL
    interpolation
  - Config-driven server/path resolution via NFS readlink chain
  - Separate `get-files-stat` (remote) and `ingest-stat` (local)
  - `reduce-stat` for hour-bucketed aggregation
  - `merge-db` for combining per-server databases

### 2026-01-29 — Mailmerge application

- **Goal**: Apply framework to prostrc1 mailmerge storage
- **Approach**: Reuse ssp.md + fsdb-cte.md with minimal adaptation
- **Key inventions**:
  - `growth` CTE: `(size - prev) / NULLIF(prev, 0)` for rate
  - `chain acc col val` for running accumulation
  - `latest-growth` combining last → span → growth → chain → acc
  - Multi-timespan analysis (year/month/week/day/hour)
- **Worked**: Framework highly reusable (minimal code for new dataset)
- **Data**: mailmerge 2016 (8G) → 2024 (58G), monthly ~4-7G growth

## Branch convergence: 2026-02-05

### 2026-02-05 — 18-server mega-DB

- **Goal**: Consolidate all infrastructure into single database
- **Approach**: Loop over all `/data` mount nodes, collect + ingest +
  reduce + merge
- **Result**: Full DB 1.7G (39.7M entries), reduced DB 289M (12M
  entries), 7.4 TiB total, 18 servers, 1999-2026

## Successful patterns to carry forward

### Collection pipeline

```
find -type f -print0
  | perl -MJSON::PP -0 -ne '...'   # [timestamp, mtime, size, path]
  → duckdb ingest (read_json_auto)
  → prune-dedup (remove unchanged)
  → mark-deleted (ghost rows)
```

### Database schema

```sql
CREATE TABLE fsdb (
  date TIMESTAMP,      -- collection time
  mdate TIMESTAMP,     -- file modification time
  size BIGINT,         -- NULL = deleted marker
  suf VARCHAR,         -- file extension
  path VARCHAR[]       -- path components as array
);
```

### Two-level DB strategy

- **Full DB**: per-file granularity, large, for detailed analysis
- **Small DB**: hour-bucketed aggregation (count, sum, min, max,
  avg), 30x smaller, distributable

### CTE pipe pattern

Composable operators chained with `|`, each producing a CTE step:

```bash
start | where 'size > 0' | sum path | order size desc | limit 25
```

Operators by class:

| Class | Operators |
|-------|-----------|
| source | `start` |
| filter | `where`, `span`, `since`, `last` |
| map | `keep`, `hide`, `distinct`, `human`, `fmt` |
| aggregate | `sum`, `cnt`, `grpcnt`, `growth`, `chain`, `acc` |
| order/limit | `order`, `limit`, `plot` |

### Multi-snapshot state reconstruction

```sql
-- view-snapshot: filesystem state at arbitrary time
SELECT
  arg_max(size, date) AS size,
  path
FROM fsdb
WHERE date <= $target
GROUP BY path
HAVING size IS NOT NULL  -- exclude ghosts
```

### Remote execution

```bash
# Zero-copy: stream functions, run remotely, nothing installed
with-lib fsdb -- add-snapshot /data/mysql /space/var | ssh host -l root bash
```

### Config-driven multi-server

```bash
# Loop all configured servers
for i in $(conf-names); do
  get-files-stat $i
  ingest-stat $i
  reduce-stat $i
done
merge-db $(conf-names)
```

## Failed or abandoned approaches

- **File-type collection** (2025-11-03): 350 min vs 4 min for stat
  alone — not worth the cost for space evolution use case
- **Docker for remote DuckDB** (2025-11-25): cumbersome, replaced by
  `staticx` static binary
- **jqsh** (pre-2025-12-23): replaced by baj for better macro
  composition and code generation
- **Full-resolution DB in repo** (2025-11-25): 119 MB too large;
  hour-bucketing solves it

## Open questions (from consolidation discussion)

1. **Multi-snapshot validation**: ghost logic (`mark-deleted`) needs
   testing with real deletions and file recreation
2. **Single vs multi-snapshot unification**: multi-snapshot is
   superset, but not yet fully validated
3. **Collection mode**: remote (SSH) vs local (cron) — both needed,
   needs clean abstraction
4. **CTE library consolidation**: operators scattered across
   `sql-cte.yml`, `stat-sql.yml`, `fsdb-cte.md` — needs single
   canonical source

## Data landscape

| Dataset | Servers | Files | Size | Period |
|---------|--------:|------:|------|--------|
| ssp-upload | 1 | 1.6M | 548 GB | 2014-2025 |
| ssp-apicrypt | 1 | 157K | 34 GB | 2019-2025 |
| mailmerge | 1 | 3.8M | 363 GB | 2014-2025 |
| profntr1-ssp | 1 | 2.0M | 473 GB | 2014-2025 |
| tdep (6 splits) | 7 | 16.1M | 2.76 TiB | 2014-2025 |
| prot3cbdde1 mysql | 1 | ~40K | ~750 GB | 2026+ (hourly) |
| all nfsdata | 18 | 39.7M | 7.4 TiB | 1999-2026 |

[Local Variables:]::
[indent-tabs-mode: nil]::
[End:]::
