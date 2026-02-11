<!-- m4_changequote(«,»)m4_changecom() -->

<!--
echo '$table-of-contents$' > tmp/toc.md
< log-file-stat.md pandoc -f gfm -t gfm --toc --toc-depth=6 --template tmp/toc.md --columns=196 | grep -v Table.of.Contents
-->

<details><summary>Expand</summary>

-   [Intro](#intro)
-   [raw header](#raw-header)
-   [Helpers](#helpers)
    -   [id use](#id-use)
-   [Collect file stat(2) of all file of dir](#collect-file-stat2-of-all-file-of-dir)
    -   [id files-stat](#id-files-stat)
    -   [Example](#example)
-   [macro](#macro)
-   [Remotely collect](#remotely-collect)
    -   [id get-files-stat](#id-get-files-stat)
    -   [Example](#example-1)
-   [Convert `json` to `duckdb`](#convert-json-to-duckdb)
    -   [id DB-files-stat](#id-db-files-stat)
    -   [id latest-files-stat](#id-latest-files-stat)
        -   [Example](#example-2)
    -   [id ingest-stat](#id-ingest-stat)
        -   [Example](#example-3)
-   [Loop to augment DB](#loop-to-augment-db)
    -   [id next-files-stat](#id-next-files-stat)
    -   [id loop-next-files-stat](#id-loop-next-files-stat)
    -   [Example](#example-4)
-   [Clean up first tests](#clean-up-first-tests)
    -   [id purge-before](#id-purge-before)
    -   [Example](#example-5)
-   [Make firsts simple query](#make-firsts-simple-query)
    -   [id run-sql](#id-run-sql)
    -   [id db-growth](#id-db-growth)
        -   [Example](#example-6)
    -   [id db-activity](#id-db-activity)
        -   [Example](#example-7)
    -   [id db-growth-pivot](#id-db-growth-pivot)
        -   [Example](#example-8)

</details>

# Intro

- This piece is a kind of MD notebook for `baj` code
- The *code only* version is in [out/log-file-stat.yml][] (well, the
  real `bash` src is in [out/log-file-stat.sh][], see [Makefile][] and
  [baj][])
- This a crossover of comments, kind of doc and code
- But this also blend
  - The code itself as a lib in the making
  - The progress toward a real task this lib try to solve
- Thus it appears also as a «journal» of things done

[out/log-file-stat.yml]: out/log-file-stat.yml 'sibling file'
[out/log-file-stat.sh]: out/log-file-stat.sh 'sibling file'
[Makefile]: Makefile 'sibling file'

[baj]:
    https://github.com/thydel/baj
    "github.com repo"

# raw header

```m4
m4_define(ME,fsl)
```

```yml
- { id: null, ns: ME }
```

# Helpers

## id use

- Allow eval of generated `bash` in current workspace
- Usesul for `jq` generated invocation

```bash
source <(eval "$@")
```

# Collect file stat(2) of all file of dir

- Use `perl(1)` because `stat(1)` give no way to garante a strange
  file name won't break the output

## id files-stat

- Get `time(2)` once at start of command
- Get `stat(3type)` `mtime` and `size` of file
- Format time, mtime, size and file name as a `json` array

```perl
BEGIN { $t = time; $j = JSON::PP->new->utf8 }
chomp;
@s = lstat($_);
next unless @s;
print $j->encode([$t, $s[9], $s[7], $_]), "\n"
```

```bash
(cd ${1:?} && find -type f -print0 | perl -MJSON::PP -0 -ne "$perl")
```

## Example

```bash
files-stat /usr/share/man/man1 | head
```

---

```json
[1768333548,1669829776,2132,"./speaker-test.1.gz"]
[1768333548,1681025659,4837,"./direnv-stdlib.1.gz"]
[1768333548,1676842348,1412,"./tificc.1.gz"]
[1768333548,1756637851,2559,"./run_erl.1.gz"]
[1768333548,1704528333,409,"./msd-datetime-mechanism.1.gz"]
[1768333548,1718226812,1495,"./sdptool.1.gz"]
[1768333548,1664222788,2733,"./lsb_release.1.gz"]
[1768333548,1675347321,650,"./mate-volume-control-status-icon.1.gz"]
[1768333548,1675359385,3273,"./dateutils.dgrep.1.gz"]
[1768333548,1672367467,3638,"./diffstat.1.gz"]
```

# macro

```m4
m4_define(SQL,jq -nr "\"$sql\"" "$«@»")
m4_define(FileName,«$ARGS.positional as [ $node, $path ] | $path / "/" | map(select(length > 0)) | join("-") as $tag»)
m4_define(FileNamePeriod,«$ARGS.positional as [ $period, $node, $path ] | $path / "/" | map(select(length > 0)) | join("-") as $tag»)
m4_define(GenBash,«: ${2:?}; self -nr --args "$«@»"»)
```

# Remotely collect

## id get-files-stat

```jq
FileName | "with-lib ME -- files-stat \($path) | ssh \($node) -l root bash | gzip > tmp/\($node)-\($tag)-\(now | round).js.gz"
```

```bash
GenBash
```

## Example

```bash
use get-files-stat prot3cbdde1 /data/mysql
```

---

```console
thy@tdews1-256g:2026-01-13-space-evol-tdep$ ls -l tmp
total 368
-rw-r--r-- 1 thy thy 373713 Jan 14 19:08 prot3cbdde1-data-mysql-1768414076.js.gz
```

# Convert `json` to `duckdb`

## id DB-files-stat

```jq
FileName | "tmp/\($node)-\($tag).db"
```

```bash
GenBash
```

## id latest-files-stat

```jq
FileName | "ls tmp/\($node)-\($tag)-[0-9]*.js.gz | tail -1"
```

```bash
GenBash
```

### Example

```bash
DB-files-stat prot3cbdde1 /data/mysql
use latest-files-stat prot3cbdde1 /data/mysql
```

## id ingest-stat

```sql
CREATE TABLE IF NOT EXISTS fsdb (
  date TIMESTAMP,
  mdate TIMESTAMP,
  size BIGINT,
  suf VARCHAR,
  path VARCHAR[]
);

INSERT INTO fsdb SELECT
  to_timestamp((js.json->0)::BIGINT),
  to_timestamp((js.json->1)::BIGINT),
  (js.json->2)::BIGINT,
  regexp_extract(js.json->>3, '\\.([^./]+)$', 1),
  list_filter(string_split(js.json->>3, '/'), x -> x != '.')
FROM read_json_auto('\($js)') js
```

```bash
local jsgz=$(use latest-files-stat "$@") db=$(DB-files-stat "$@")
SQL --arg js $jsgz | duckdb $db
```

### Example

```bash
use get-files-stat prot3cbdde1 /data/mysql
ingest-stat prot3cbdde1 /data/mysql
<<< 'select count(*) from fsdb; select * from fsdb order by size desc limit 4' duckdb tmp/prot3cbdde1-data-mysql.db -box
```

---

```txt
┌──────────────┐
│ count_star() │
├──────────────┤
│ 42776        │
└──────────────┘
┌────────────────────────┬────────────────────────┬─────────────┬─────┬─────────────────────────────────────────┐
│          date          │         mdate          │    size     │ suf │                  path                   │
├────────────────────────┼────────────────────────┼─────────────┼─────┼─────────────────────────────────────────┤
│ 2026-01-14 19:07:57+01 │ 2026-01-14 19:02:31+01 │ 41150316544 │     │ [ibdata1]                               │
│ 2026-01-14 19:07:57+01 │ 2026-01-14 19:02:31+01 │ 23035117568 │ ibd │ [esisbci, nbci_ident_data.ibd]          │
│ 2026-01-14 19:07:57+01 │ 2026-01-14 19:02:24+01 │ 17884512256 │ ibd │ [docr_naq, docr_varsetmonitor_data.ibd] │
│ 2026-01-14 19:07:57+01 │ 2026-01-14 19:02:20+01 │ 16361979904 │ ibd │ [docr_idf, docr_varsetmonitor_data.ibd] │
└────────────────────────┴────────────────────────┴─────────────┴─────┴─────────────────────────────────────────┘
```

- Wait some time

```bash
use get-files-stat prot3cbdde1 /data/mysql
ingest-stat prot3cbdde1 /data/mysql
<<< "select count(*) from fsdb; select * from fsdb where path[1] == 'ibdata1'" duckdb tmp/prot3cbdde1-data-mysql.db -box
```

---

```txt
┌──────────────┐
│ count_star() │
├──────────────┤
│ 85188        │
└──────────────┘
┌─────────────────────┬─────────────────────┬─────────────┬─────┬───────────┐
│        date         │        mdate        │    size     │ suf │   path    │
├─────────────────────┼─────────────────────┼─────────────┼─────┼───────────┤
│ 2026-01-14 19:07:57 │ 2026-01-14 19:02:31 │ 41150316544 │     │ [ibdata1] │
│ 2026-01-15 00:49:43 │ 2026-01-15 00:48:24 │ 41150316544 │     │ [ibdata1] │
└─────────────────────┴─────────────────────┴─────────────┴─────┴───────────┘
```

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

# Clean up first tests

- That were not hour align

## id purge-before

```sql
DELETE FROM fsdb WHERE date < '\($limit)'::TIMESTAMP
```

```bash
local limit="${1:?}"; shift
local db=$(DB-files-stat "$@")
SQL --arg limit "$limit" | duckdb "$db"
```

## Example

```bsh
purge-before '2026-01-15 02:00:01' prot3cbdde1 /data/mysql
```

# Make firsts simple query

## id run-sql

```bash
local db=$(DB-files-stat "${@:1:2}"); shift 2
SQL | duckdb "$db" "$@"
```

## id db-growth

```sql
SELECT
  date,
  path[1] AS db,
  SUM(size) AS size
FROM fsdb
WHERE len(path) = 2
GROUP BY date, db
ORDER BY date, size DESC
```

```bash
local db=$(DB-files-stat "${@:1:2}"); shift 2
SQL | duckdb "$db" "$@"
```

### Example

```bash
db-growth prot3cbdde1 /data/mysql
```

## id db-activity

```sql
WITH deltas AS (
  SELECT
    date,
    path[1] AS db,
    size - LAG(size) OVER (PARTITION BY path ORDER BY date) AS growth
  FROM fsdb
  WHERE len(path) = 2
)
SELECT
  date,
  db,
  sum(growth) AS growth
FROM deltas
WHERE growth > 0
GROUP BY date, db
ORDER BY date, growth DESC
```

```bash
run-sql "$@"
```

### Example

```bash
db-activity prot3cbdde1 /data/mysql
```

## id db-growth-pivot

```sql
PIVOT (
  WITH deltas AS (
    SELECT
      date,
      path[1] AS db,
      -- Handle NULL (Deleted) vs Value. 
      -- If Current is NULL, treat as 0. If Prev is NULL, treat as 0.
      COALESCE(size, 0) - COALESCE(LAG(size) OVER (PARTITION BY path ORDER BY date), 0) AS growth
    FROM fsdb
    WHERE len(path) = 2
  ),
  binned AS (
    SELECT
      time_bucket(INTERVAL '\($interval)', date) AS bucket,
      db,
      sum(growth) AS growth
    FROM deltas
    WHERE growth > 0  -- Remove this line to see Deletions (Negative growth)
    GROUP BY 1, 2
  ),
  source AS (
    SELECT strftime(bucket, '%m-%d %H:%M') AS time, db, growth FROM binned
    UNION ALL
    SELECT 'Total' AS time, db, sum(growth) FROM binned GROUP BY db
    UNION ALL
    SELECT strftime(bucket, '%m-%d %H:%M') AS time, ' Total' AS db, sum(growth) FROM binned GROUP BY 1
    UNION ALL
    SELECT 'Total' AS time, ' Total' AS db, sum(growth) FROM binned
  )
  SELECT * FROM source
)
ON time
USING round(sum(growth) / 1024 / 1024, 2)
ORDER BY Total DESC
```

```bash
local interval=${1:?}; shift;
local db=$(DB-files-stat "${@:1:2}"); shift 2
SQL --arg interval "$interval" | duckdb "$db" "$@"
```

### Example

```bash
db-growth-pivot 4h prot3cbdde1 /data/mysql -box -nullvalue ' '
```

## id db-growth-pivot-1

```sql
PIVOT (
  WITH deltas AS (
    SELECT
      date,
      path[1] AS db,
      size - LAG(size) OVER (PARTITION BY path ORDER BY date) AS growth
    FROM fsdb
    WHERE len(path) = 2
  ),
  binned AS (
    SELECT
      time_bucket(INTERVAL '\($interval)', date) AS bucket,
      db,
      sum(growth) AS growth
    FROM deltas
    WHERE growth > 0
    GROUP BY 1, 2
  ),
  source AS (
    -- 1. Normal Data (DB per Time)
    SELECT strftime(bucket, '%m-%d %H:%M') AS time, db, growth FROM binned
    UNION ALL
    -- 2. Total Column (Sum of Time per DB)
    SELECT 'Total' AS time, db, sum(growth) FROM binned GROUP BY db
    UNION ALL
    -- 3. Total Row (Sum of DBs per Time)
    SELECT strftime(bucket, '%m-%d %H:%M') AS time, ' Total' AS db, sum(growth) FROM binned GROUP BY 1
    UNION ALL
    -- 4. Grand Total (Corner Cell)
    SELECT 'Total' AS time, ' Total' AS db, sum(growth) FROM binned
  )
  SELECT * FROM source
)
ON time
USING round(sum(growth) / 1024 / 1024, 2)
ORDER BY Total DESC
```

```bash
local interval=${1:?}; shift;
local db=$(DB-files-stat "${@:1:2}"); shift 2
SQL --arg interval "$interval" | duckdb "$db" "$@"
```

### Example

```bash
db-growth-pivot 4h prot3cbdde1 /data/mysql -box -nullvalue ' '
```

```txt
┌─────────────────┬─────────────┬─────────────┬─────────────┬─────────────┬─────────────┬─────────────┬────────┐
│       db        │ 01-15 00:00 │ 01-15 04:00 │ 01-15 08:00 │ 01-15 12:00 │ 01-15 16:00 │ 01-15 20:00 │ Total  │
├─────────────────┼─────────────┼─────────────┼─────────────┼─────────────┼─────────────┼─────────────┼────────┤
│  Total          │ 4.0         │ 8.0         │ 242.13      │ 260.22      │ 227.14      │ 9.0         │ 750.48 │
│ docs_naq        │ 4.0         │             │ 78.03       │ 94.02       │ 96.0        │ 1.0         │ 273.05 │
│ docs_occ        │             │ 4.0         │ 80.0        │ 60.02       │ 64.0        │ 4.0         │ 212.02 │
│ docs_idf        │             │             │ 24.0        │ 32.0        │ 20.03       │             │ 76.03  │
│ docs_ges        │             │             │ 24.02       │ 20.06       │ 8.0         │             │ 52.08  │
│ docs_nor        │             │             │ 8.0         │ 17.02       │ 12.0        │             │ 37.02  │
│ voo4bcm         │             │             │ 8.0         │ 8.0         │ 8.0         │             │ 24.0   │
│ docs_guy        │             │             │             │ 4.02        │ 9.02        │ 4.0         │ 17.03  │
│ docr_occ        │             │ 4.0         │ 8.0         │ 0.02        │             │             │ 12.02  │
│ mailmerge       │             │             │ 4.0         │ 8.0         │             │             │ 12.0   │
│ esisbci         │             │             │             │ 8.0         │             │             │ 8.0    │
│ docu_occitanie  │             │             │ 4.02        │             │ 1.0         │             │ 5.02   │
│ docr_naq        │             │             │             │             │ 4.03        │             │ 4.03   │
│ docu_aquitaine  │             │             │ 4.02        │             │             │             │ 4.02   │
│ docu_idf        │             │             │ 0.02        │ 4.0         │             │             │ 4.02   │
│ docr_idf        │             │             │             │ 4.0         │             │             │ 4.0    │
│ disp_nor        │             │             │             │             │ 4.0         │             │ 4.0    │
│ docr_nor        │             │             │ 0.03        │ 0.05        │ 1.02        │             │ 1.09   │
│ disp_ges_docs   │             │             │             │ 1.0         │             │             │ 1.0    │
│ docu_guadeloupe │             │             │             │             │ 0.05        │             │ 0.05   │
│ docr_ges        │             │             │             │ 0.02        │             │             │ 0.02   │
│ docr_gua        │             │             │             │ 0.02        │             │             │ 0.02   │
└─────────────────┴─────────────┴─────────────┴─────────────┴─────────────┴─────────────┴─────────────┴────────┘
```

# The requested report

## id DB-files-stat-period

```jq
FileNamePeriod | "out/\($node)-\($tag)-\($period)"
```

```bash
GenBash
```

### Example

```bash
DB-files-stat-period 1d prot3cbdde1 /data/mysql
```

## id report-db-daily

```sql
COPY (
  WITH snapshot_dates AS (
    SELECT MAX(date) as snap_date
    FROM fsdb
    GROUP BY time_bucket(INTERVAL '\($interval)', date)
  )
  SELECT
    time_bucket(INTERVAL '\($interval)', date) AS report_date,
    path[1] AS db_name,
    SUM(size) AS total_bytes,
    ROUND(SUM(size) / 1024.0 / 1024.0, 2) AS total_mb
  FROM fsdb
  WHERE date IN (SELECT snap_date FROM snapshot_dates)
    AND len(path) >= 2
  GROUP BY 1, 2
  ORDER BY 1 DESC, 2 ASC
) TO '/dev/stdout' (HEADER, DELIMITER ',')
```

```bash
local csv=$(DB-files-stat-period "${@:1:3}")-$(date +%F).csv
local interval=${1:?}; shift;
local db=$(DB-files-stat "${@:1:2}"); shift 2
SQL --arg interval "$interval" | duckdb "$db" "$@" > $csv
```

## Example

```bash
report-db-daily 1w prot3cbdde1 /data/mysql
```

# The prune problem

## id prune-fsdb

```sql
DELETE FROM fsdb
WHERE date NOT IN (
    -- 1. Keep everything recent (younger than 2 days)
    SELECT date FROM fsdb
    WHERE date >= current_date - INTERVAL '\($h_age)'

    UNION ALL

    -- 2. Keep 1st of the Hour (between 2 days and 7 days old)
    SELECT min(date) FROM fsdb
    WHERE date < current_date - INTERVAL '\($h_age)'
      AND date >= current_date - INTERVAL '\($d_age)'
    GROUP BY date_trunc('hour', date)

    UNION ALL

    -- 3. Keep 1st of the Day (Midnight) (between 7 days and 1 month old)
    SELECT min(date) FROM fsdb
    WHERE date < current_date - INTERVAL '\($d_age)'
      AND date >= current_date - INTERVAL '\($w_age)'
    GROUP BY date_trunc('day', date)

    UNION ALL

    -- 4. Keep 1st of the Week (Monday) (older than 1 month)
    SELECT min(date) FROM fsdb
    WHERE date < current_date - INTERVAL '\($w_age)'
    GROUP BY date_trunc('week', date)
);
```

```bash
# Defaults: Keep all <2d. Hourly <7d. Daily <1m. Weekly >1m.
local h_age="${1:-2 days}"
local d_age="${2:-7 days}"
local w_age="${3:-1 month}"
local db=$(DB-files-stat "$@")

SQL --arg h_age "$h_age" --arg d_age "$d_age" --arg w_age "$w_age" | duckdb "$db"
```

## id prune-dedup

```sql
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

```bash
#local db=$(DB-files-stat "$@")
#SQL | duckdb "$db"
SQL | duckdb tmp/1.db
```

# The ghosts files problem

## id mark-deleted

* **Logic:**
1. Identifies `curr_t` (the very last timestamp in the DB) and
   `prev_t` (the snapshot immediately before it).
2. Finds all paths present at `prev_t` that are missing at `curr_t`
   using `EXCEPT`.
3. Inserts them into `fsdb` with the current timestamp and `size =
   NULL`.

* **Note:** We insert `NULL` for auxiliary columns (`mdate`, `suf`)
  since the file no longer exists.

```sql
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

```bash
#local db=$(DB-files-stat "$@")
#SQL | duckdb "$db"
SQL | duckdb tmp/2.db
```

## id list-deleted

```SQL
SELECT * from fsdb WHERE size = NULL
```

```bash
local db=$(DB-files-stat "$@")
SQL | duckdb "$db"
```

# Use snapshot

## id view-snapshot

* **Update:** Added `HAVING size IS NOT NULL`.
* **Behavior:** `arg_max` correctly picks up the latest entry (even if
  it is the `NULL` marker). The `HAVING` clause then cleanly filters
  those "ghosts" out of the final report.

```sql
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

```bash
local target="${1:-now}"
local db=$(DB-files-stat "$@")
SQL --arg target "$target" | duckdb -nullvalue ' ' "$db"
```

### Example

```bash
view-snapshot 2026-01-16 prot3cbdde1 /data/mysql
view-snapshot "2026-01-15 12:00:00" prot3cbdde1 /data/mysql
view-snapshot "$(date -d '3 days ago' +'%F %T')" prot3cbdde1 /data/mysql
```

## id view-snapshot-2

```sql
WITH boundary AS (SELECT MAX(date) as max_d FROM fsdb)
SELECT
  -- Cast input string to timestamp; clamp to DB end if future
  LEAST('\($target)'::TIMESTAMP, boundary.max_d) AS date,
  arg_max(mdate, date) AS mdate,
  arg_max(size, date) AS size,
  path
FROM fsdb, boundary
WHERE fsdb.date <= '\($target)'::TIMESTAMP
GROUP BY path, boundary.max_d
```

```bash
local target="${1:?}"; shift
#local db=$(DB-files-stat "$@")
#SQL --arg target "$target" | duckdb -nullvalue ' ' "$db"
SQL --arg target "$target" | duckdb tmp/2.db
```

## id view-snapshot-1

```sql
SELECT
  '\($target)'::TIMESTAMP AS date,
  arg_max(mdate, date) AS mdate,
  arg_max(size, date) AS size,
  path
FROM fsdb
WHERE date <= '\($target)'::TIMESTAMP
GROUP BY path
```

```bash
local target="${1:?}"; shift
#local db=$(DB-files-stat "$@")
#SQL --arg target "$target" | duckdb -nullvalue ' ' "$db"
SQL --arg target "$target" | duckdb -nullvalue ' ' tmp/2.db
```

[Local Variables:]::
[indent-tabs-mode: nil]::
[End:]::
