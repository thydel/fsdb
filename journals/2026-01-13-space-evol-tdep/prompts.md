# SPL

- I think we can do better
- If we want to keep 

- Then modify view-snapshot to use this info (I let you propose a way
  to do it)

**Wed Jan 21 11:57:21 AM CET 2026**

# On the ghosts files problem - First pass

## Human

- Concerning the ghosts files problem
- If I understand well the view-snapshot semantic
  - We keep all entries with max date <= requested date
  - That means the ghosts files will always be added to chosen
    snapshot
  - And consequently size of deleted files added to the summed size of
    a dir
- Please confirm the interpretation
- NO code gen

## Model

Yes, your interpretation is entirely correct.

Here is the breakdown of why this happens:

- The "Last Known" Logic: The query WHERE date <= requested_date looks
  backward into history. If you deleted a file on the file system but
  did not record a specific "deletion marker" (like a row with size=0
  or size=NULL) in the database, the query keeps looking back until it
  finds the last valid entry (e.g., from yesterday).

- The Resurrection: The arg_max function picks that last valid
  entry. It has no way of knowing the file is currently gone; it only
  knows that "as of yesterday, this file existed with size X."

- The Resulting Sum: Consequently, deleted files stick around forever
  in your reporting. If you delete a 50GB file today, your
  view-snapshot for next week will still count that 50GB, because the
  last record it sees is the one from today.

Conclusion: This strategy turns your metric from "Current Disk Usage"
into "Cumulative Peak Usage of All Files Ever Seen." To fix this, you
would strictly need to detect deletions during ingestion and insert a
size=NULL record to "close" the file's history.

# On the ghosts files problem - Second pass

## Human

- Read and comment, no code gen

- I think its better to do that at prune time as a second prune stage
- Something like (a proposal)
  - Compute difference of previous snapshot paths set and last one
    (the removed files)
  - Add them to last spashot as deleted (size = NULL)

## Model

### Verdict: Strong Proposal (The "Soft Delete" Pattern)

Your proposal is **conceptually correct** and effectively solves the
"Ghost File" problem. By explicitly recording a `size = NULL` entry,
you "close" the history for that file.

Here is the detailed commentary on the mechanics and timing:

### 1. The Logic (Set Difference)

The logic is sound. You are treating the absence of a file as a data point in itself.

* **Current State:** You only record "Presence".
* **Proposed State:** You record "State Change" (Presence  Absence).
* **Mechanism:**
1. Get the list of unique paths in the **current** batch ().
2. Get the list of unique paths in the **immediately preceding** batch ().
3. Calculate  (Set difference).
4. Insert rows for  with timestamp  and `size = NULL`.

### 2. Timing Refinement: Ingestion vs. Pruning

While you proposed doing this at **Prune Time**, I strongly recommend
moving this step to **Ingestion Time** (immediately after the fresh
data load).

* **If done at Prune Time:** Your "Head" (the most recent state of the
  DB) is technically corrupt (contains ghosts) until the maintenance
  script runs. If you ingest hourly but prune weekly, your daily
  reports are wrong for 6 days.
* **If done at Ingestion Time:** The database is always accurate. You
  can run your "Loop" logic, and immediately after `ingest-stat`, you
  run this `close-deleted-files` logic.

### 3. Impact on `view-snapshot`

This makes the view logic **simpler and more robust**.

* **Current Behavior:** `arg_max(size, date)` finds the last known
  size (e.g., 50GB from yesterday) and reports it.
* **New Behavior:** `arg_max(size, date)` will find your new entry
  (`NULL` from today).
* **The Fix:** You simply add a standard SQL filter: `HAVING size IS
  NOT NULL`.

### Summary

This approach completes your transition from a "Filesystem Log" to a
"Slowly Changing Dimension" table. It allows you to use the heavy
reduction/pruning strategy without losing the accuracy of deletions.

# On the ghosts files problem - third pass

## Human

- The ingestion being a sequence of insert from a `json` stream we
  need different SQL statement anyway
- So the choice of sequence is just calling bash funcs and keeping
  them distinct is better for comprehension (documentation), debug and
  maintenance IMHO
- And the idea was always to do something like `snap () { ingest; prune; mark-deleted; }` anyway
- Please write the `mark-deleted` step

**Tue Jan 20 11:30:24 PM CET 2026**

# First pass

## Human

- There is another way to prune
- But it may require a change in the logic of quering for report
- Take seriously my idea of mapping DFSDB on SFSDB
  - We have many files that never or seldom change
  - So we keep only the items whose size change from previous to next
    row

## Model

This approach effectively turns your database into a Change Data
Capture (CDC) system or a Slowly Changing Dimension (Type 2) table.

You are correct: this saves massive amounts of space (especially for
static .frm files or log archives), but it breaks standard reporting
queries. If you delete the row for 2026-01-20 10:00 because it was
identical to 09:00, a simple WHERE date = '...10:00' returns nothing.

Here is the implementation for this "Differential/Deduplicated" FSDB.

### The Differential Pruner (Deduplication)

This pruner deletes any snapshot row where the file size is identical
to the immediately preceding version of that same file.

### The Logic Change: Reconstruction Query

Since "unchanged" rows are now missing, you can no longer filter by an
exact date. You must ask: "What was the last known state of this file
on or before my target date?"

The most efficient function for this in DuckDB is arg_max.

### Critical Warning: The "Ghost File" Problem

There is one hidden risk with this "Mapping DFSDB on SFSDB" strategy:
Deletions.

- Scenario: File A exists at T1. You prune T2, T3 (because size is
  constant).
- Event: At T4, File A is deleted from the disk. The collector runs
  but produces no row for A.
- Query: You ask for the state at T5.
- Result: The "Reconstruction Query" looks back, finds the T1 record,
  and reports File A as still existing (because it sees no "deletion
  record").

Mitigation: If precise tracking of deleted files is required, you must
not use simple deduplication. You would need the collector to
explicitly insert a size: NULL or size: 0 record when a file
disappears, which complicates the bash collector significantly.

For a database directory (where files rarely disappear without the DB
itself being dropped), this is usually an acceptable trade-off.

# Second pass

## Human

Except if we always keep all files from the last fetch

## Model

This is a robust strategy often called "Head + Tail" Retention.

- The Head (Last Fetch): You keep the latest snapshot strictly
  intact. This guarantees that "Current State" queries are fast,
  accurate, and require no complex logic.

- The Tail (History): You deduplicate the past. This compresses
  storage massively (.frm files never change, .ibd only change when
  written to).

The Trade-off (The "Flatline" Artifact): Because we don't record
explicit "deletions," a file deleted in the past will effectively
"disappear" from the Head (correct) but might appear as a static,
non-zero line in historical graphs (the "Ghost File" effect) until the
lookback window passes. For database storage analysis, this is usually
acceptable.

Here is the implementation of your "Dynamic FSDB" pretending to be a
"Static FSDB".

### The Safe Pruner (Head + Tail)

- Compare current size vs. previous size (LAG).
- Delete if identical AND the row is not from the very last collection
  (MAX(date)).

### The Bridge: Dynamic to Static

This query generates a virtual fsdb table for any specific point in
time. The output schema matches your original table perfectly, so all
your existing SFSDB tools will work unchanged on this output.

- Reconstructs the state of every file known at target_date.
- Returns date (the requested target), mdate (from the record), size
  (from the record), and path.

**Tue Jan 20 07:20:20 PM CET 2026**

# Read the description and comment before generating any code

# Current DB state

- After running `loop-next-files-stat` for some days

```bash
duckdb tmp/prot3cbdde1-data-mysql.db 'show fsdb; summarize fsdb; select * from fsdb limit 10' -box
db-growth-pivot 1d prot3cbdde1 /data/mysql -box -nullvalue ' '
```

```txt
┌─────────────┬─────────────┬─────────┬─────────┬─────────┬─────────┐
│ column_name │ column_type │  null   │   key   │ default │  extra  │
│   varchar   │   varchar   │ varchar │ varchar │ varchar │ varchar │
├─────────────┼─────────────┼─────────┼─────────┼─────────┼─────────┤
│ date        │ TIMESTAMP   │ YES     │ NULL    │ NULL    │ NULL    │
│ mdate       │ TIMESTAMP   │ YES     │ NULL    │ NULL    │ NULL    │
│ size        │ BIGINT      │ YES     │ NULL    │ NULL    │ NULL    │
│ suf         │ VARCHAR     │ YES     │ NULL    │ NULL    │ NULL    │
│ path        │ VARCHAR[]   │ YES     │ NULL    │ NULL    │ NULL    │
└─────────────┴─────────────┴─────────┴─────────┴─────────┴─────────┘
┌─────────────┬─────────────┬─────────────────────┬──────────────────────┬───────────────┬───┬──────────────────────┬──────────────────────┬─────────┬─────────────────┐
│ column_name │ column_type │         min         │         max          │ approx_unique │ … │         q50          │         q75          │  count  │ null_percentage │
│   varchar   │   varchar   │       varchar       │       varchar        │     int64     │   │       varchar        │       varchar        │  int64  │  decimal(9,2)   │
├─────────────┼─────────────┼─────────────────────┼──────────────────────┼───────────────┼───┼──────────────────────┼──────────────────────┼─────────┼─────────────────┤
│ date        │ TIMESTAMP   │ 2026-01-15 02:00:01 │ 2026-01-20 19:00:00  │           115 │ … │ 2026-01-17 02:37:4…  │ 2026-01-19 18:56:2…  │ 4183908 │            0.00 │
│ mdate       │ TIMESTAMP   │ 2024-03-22 14:26:13 │ 2026-01-20 19:00:00  │         30063 │ … │ 2024-03-30 18:20:5…  │ 2025-03-26 12:58:5…  │ 4183908 │            0.00 │
│ size        │ BIGINT      │ 0                   │ 41150316544          │          2532 │ … │ 34173                │ 81920                │ 4183908 │            0.00 │
│ suf         │ VARCHAR     │                     │ stonecopy            │            17 │ … │ NULL                 │ NULL                 │ 4183908 │            0.00 │
│ path        │ VARCHAR[]   │ [.stonecopy]        │ [voo4bcm_pf, sys_u…  │         41722 │ … │ NULL                 │ NULL                 │ 4183908 │            0.00 │
├─────────────┴─────────────┴─────────────────────┴──────────────────────┴───────────────┴───┴──────────────────────┴──────────────────────┴─────────┴─────────────────┤
│ 5 rows                                                                                                                                          12 columns (9 shown) │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
┌─────────────────────┬─────────────────────┬────────┬─────┬─────────────────────────────────────────────────────────┐
│        date         │        mdate        │  size  │ suf │                          path                           │
├─────────────────────┼─────────────────────┼────────┼─────┼─────────────────────────────────────────────────────────┤
│ 2026-01-15 02:00:01 │ 2024-03-26 23:41:18 │ 2121   │ frm │ [docs_ara, ndmt_05_dico_echoconduite_sd_data.frm]       │
│ 2026-01-15 02:00:01 │ 2024-03-26 23:41:25 │ 1523   │ frm │ [docs_ara, ndmt_06_data_group_mode.frm]                 │
│ 2026-01-15 02:00:01 │ 2025-03-06 19:04:31 │ 98304  │ ibd │ [docs_ara, ndmt_studyhl7_data.ibd]                      │
│ 2026-01-15 02:00:01 │ 2024-03-27 00:10:17 │ 65536  │ ibd │ [docs_ara, ndmt_querycache_data.ibd]                    │
│ 2026-01-15 02:00:01 │ 2024-11-28 12:25:31 │ 8497   │ frm │ [docs_ara, temp_data_mailing_500127434.frm]             │
│ 2026-01-15 02:00:01 │ 2024-03-27 00:15:01 │ 81920  │ ibd │ [docs_ara, ndmt_rdv_file_data_group_mode.ibd]           │
│ 2026-01-15 02:00:01 │ 2024-03-26 23:32:36 │ 131072 │ ibd │ [docs_ara, ndmt_02_deleted.ibd]                         │
│ 2026-01-15 02:00:01 │ 2024-03-27 00:09:44 │ 65536  │ ibd │ [docs_ara, ndmt_medecin_bcm_data.ibd]                   │
│ 2026-01-15 02:00:01 │ 2025-12-18 18:07:53 │ 1523   │ frm │ [docs_ara, ndmt_reporting_csv_file_data_group_mode.frm] │
│ 2026-01-15 02:00:01 │ 2024-03-26 23:45:54 │ 98304  │ ibd │ [docs_ara, ndmt_bdiff_dico_bilan_motif_deleted.ibd]     │
└─────────────────────┴─────────────────────┴────────┴─────┴─────────────────────────────────────────────────────────┘
┌─────────────────┬─────────────┬─────────────┬─────────────┬─────────────┬─────────────┬─────────┐
│       db        │ 01-15 00:00 │ 01-16 00:00 │ 01-17 00:00 │ 01-19 00:00 │ 01-20 00:00 │  Total  │
├─────────────────┼─────────────┼─────────────┼─────────────┼─────────────┼─────────────┼─────────┤
│  Total          │ 750.52      │ 673.14      │ 882.7       │ 779.55      │ 754.45      │ 3840.36 │
│ docs_naq        │ 273.05      │ 240.03      │ 21.0        │ 236.02      │ 241.0       │ 1011.09 │
│ docs_occ        │ 212.02      │ 172.03      │ 20.0        │ 225.05      │ 229.02      │ 858.11  │
│ docu_occitanie  │ 5.02        │ 8.0         │ 691.5       │ 5.0         │             │ 709.52  │
│ docs_idf        │ 76.03       │ 52.02       │             │ 80.06       │ 56.03       │ 264.14  │
│ docs_ges        │ 52.09       │ 46.05       │ 4.0         │ 52.14       │ 44.06       │ 198.34  │
│ docs_nor        │ 37.02       │ 37.0        │             │ 37.0        │ 53.08       │ 164.09  │
│ docs_guy        │ 17.05       │ 31.0        │ 21.0        │ 50.02       │ 24.05       │ 143.11  │
│ voo4bcm         │ 24.0        │ 16.0        │ 4.0         │ 24.03       │ 24.0        │ 92.03   │
│ mailmerge       │ 12.0        │ 16.0        │             │ 16.05       │ 12.0        │ 56.05   │
│ docr_naq        │ 4.03        │             │ 41.0        │ 4.0         │             │ 49.03   │
│ esisbci         │ 8.0         │ 12.0        │ 8.0         │ 12.08       │ 8.0         │ 48.08   │
│ docr_occ        │ 12.02       │ 4.0         │ 21.13       │             │ 8.0         │ 45.14   │
│ docr_idf        │ 4.0         │ 14.0        │ 12.09       │ 4.0         │             │ 34.09   │
│ edepistage      │             │ 4.0         │             │ 8.0         │ 12.0        │ 24.0    │
│ docu_guyane     │             │             │ 20.78       │             │             │ 20.78   │
│ docr_ges        │ 0.02        │             │ 12.06       │             │ 8.0         │ 20.08   │
│ docu_aquitaine  │ 4.02        │ 5.0         │             │ 4.03        │ 5.0         │ 18.05   │
│ disp_occ        │             │ 4.0         │             │ 4.0         │ 9.0         │ 17.0    │
│ disp_nor        │ 4.0         │             │             │ 5.0         │ 5.0         │ 14.0    │
│ docr_nor        │ 1.09        │ 4.0         │ 6.05        │ 0.05        │ 0.05        │ 11.23   │
│ disp_ges_docs   │ 1.0         │ 4.0         │             │             │ 4.0         │ 9.0     │
│ docu_bfc        │             │             │             │             │ 8.17        │ 8.17    │
│ EPIFILES_VOO4   │             │             │             │ 8.0         │             │ 8.0     │
│ docu_idf        │ 4.02        │             │ 0.09        │ 0.03        │             │ 4.14    │
│ docr_guy        │             │             │             │             │ 4.0         │ 4.0     │
│ docu_rh_alpes   │             │             │             │ 4.0         │             │ 4.0     │
│ disp_idf        │             │ 4.0         │             │             │             │ 4.0     │
│ docu_normandie  │             │             │             │ 1.0         │             │ 1.0     │
│ docu_guadeloupe │ 0.05        │ 0.02        │             │             │             │ 0.06    │
│ docr_gua        │ 0.02        │             │             │             │             │ 0.02    │
└─────────────────┴─────────────┴─────────────┴─────────────┴─────────────┴─────────────┴─────────┘
```

# The real requested target

- Give team a daily or weekly CSV with date, db, size

# A preexisting problem/tool we want to start from: static FSDB

- We already have a set of `bash` func and composable DDB CTE that try
  to solve a different but related problem
- The problem is to reconstruct a fictive `du(1)` history of a set of
  files given that files are created once and never written after
  creation (the `mdate` of all files is their creation data)
- By doing `find | stat | DDB` (data, path, size)
- Then apply various reductions etc on the DB
- Note that the DB can and will always be reconstructed to get an up
  to date version

# The current problem/tool we want to make: dymamic FSDB

- We want a generalisation of the static FSDB
- We have the *fetch* data part
- We can't keep all the fetched data
  - We could if we decided to fetch daily or weekly
  - But we want the tool to be flexible enough to get used for
    something else than `mysql` dir
- We need a way to reduce data by
  - Keeping only some chosen value (.e.g. last hour of a day)
  - Apply the reduction on different time span (last day of week)
  - Doing that in a idempotent way
- Maybe we can find way make all existing tools for static FSDB
  (SFSDB) usable for a dynamic FSDB (DFSDB) that somehow pretend to be
  a SFSDB)

# Questions about an implementation for DFSDB

- Can we do it safely keeping the current schema or do we need to use
  another table
- Do you have any reference for theoretical principle we may use
- So you know any tools that work in same problem space

**Thu Jan 15 06:54:49 PM CET 2026**

- We start with the generic file size evolution
- But, I want to kown how the various DB grow

# First query

- Keep path with 2 parts, group by date, sum size

# Second query

- Hum... that is not very useful
- Maybe we need to first add a growth col (t[0] - t[-1])
- Then we can keep only files that do grow between to collect
- And the only group by base and sum
- Or maybe there is a better way to express this

# Request pivot

- OK, now we need to pivot so that we have rows of DB and cols time
  with growth as value

# Request time merging

- Great! but we also want to compress time, that is to say take a
  number of period (here hour) to sum merge after pivot to control the
  width (number) of cols
- And we also want a last col summing all time slot growth

# And more

- Super, I chose to sort by size
- Is there a way to ask for space instead of NULL (cosmetic)
- Adding a row that sum growth over DB would also be nice

**Thu Jan 15 10:47:23 AM CET 2026 purge-before**

- I've started to collect, here my new notebook parts
- How to I formulate the SQL to delete all entries before `2026-01-15 02:00:01`
- try to make it a dropable `## id purge-before` notebook entry
  (taking arg dare and using SQL macro)

# Loop to augment DB

## id next-files-stat

```bash
use get-files-stat "$@"; ingest-stat "$@"
```

## id loop-next-files-stat

```bash
while true; do sleep $((3600 - $(date +%s) % 3600)); next-files-stat "$@"; done
```

## Example

- On one term

```bash
loop-next-files-stat prot3cbdde1 /data/mysql
```

- On another one after some houres

```bash
<<< "select count(*) from fsdb; select * from fsdb where path[1] == 'ibdata1'" duckdb tmp/prot3cbdde1-data-mysql.db -box
```

---

```txt
┌──────────────┐
│ count_star() │
├──────────────┤
│ 467046       │
└──────────────┘
┌─────────────────────┬─────────────────────┬─────────────┬─────┬───────────┐
│        date         │        mdate        │    size     │ suf │   path    │
├─────────────────────┼─────────────────────┼─────────────┼─────┼───────────┤
│ 2026-01-14 19:07:57 │ 2026-01-14 19:02:31 │ 41150316544 │     │ [ibdata1] │
│ 2026-01-15 00:49:43 │ 2026-01-15 00:48:24 │ 41150316544 │     │ [ibdata1] │
│ 2026-01-15 02:00:01 │ 2026-01-15 01:56:53 │ 41150316544 │     │ [ibdata1] │
│ 2026-01-15 03:00:01 │ 2026-01-15 02:58:29 │ 41150316544 │     │ [ibdata1] │
│ 2026-01-15 04:00:01 │ 2026-01-15 03:30:07 │ 41150316544 │     │ [ibdata1] │
│ 2026-01-15 05:00:01 │ 2026-01-15 04:08:56 │ 41150316544 │     │ [ibdata1] │
│ 2026-01-15 06:00:01 │ 2026-01-15 05:31:37 │ 41150316544 │     │ [ibdata1] │
│ 2026-01-15 07:00:01 │ 2026-01-15 06:30:41 │ 41150316544 │     │ [ibdata1] │
│ 2026-01-15 08:00:02 │ 2026-01-15 07:58:53 │ 41150316544 │     │ [ibdata1] │
│ 2026-01-15 09:00:01 │ 2026-01-15 09:00:01 │ 41150316544 │     │ [ibdata1] │
│ 2026-01-15 10:00:02 │ 2026-01-15 09:58:18 │ 41150316544 │     │ [ibdata1] │
└─────────────────────┴─────────────────────┴─────────────┴─────┴───────────┘
```

[Local Variables:]::
[indent-tabs-mode: nil]::
[End:]::

