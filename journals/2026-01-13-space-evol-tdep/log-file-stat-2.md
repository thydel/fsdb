<!-- m4_changequote(«,»)m4_changecom() -->

<!--
echo '$table-of-contents$' > tmp/toc.md
< log-file-stat.md pandoc -f gfm -t gfm --toc --toc-depth=6 --template tmp/toc.md --columns=196 | grep -v Table.of.Contents
-->

<details><summary>Expand</summary>


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
m4_define(ME,fsl2)
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
```

# Collect

## id path-to-name

- Make a file name from a path
- .e.g. `tmp` -> `tmp`, `/data/mysl` -> `data-mysql`

```jq
. / "/" | map(select(length > 0)) | join("-")
```

```bash
<<< ${1:?} self -Rr
```

## id ingest-stat-direct

- `ingest-stat-direct /data/mysql /space/var`
- Will collect file stats (mdate, size, suffix, path (as an array of
  dirent)) of all files in `/data/mysql` and store then with a prefix
  timestamp of collect in `/space/var/data-mysql.db`

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
  regexp_extract(js.json->>3, '\.([^./]+)$', 1),
  list_filter(string_split(js.json->>3, '/'), x -> x != '.')
FROM read_json_auto('/dev/stdin') js
```

```bash
: ${2:?}; files-stat $1 | duckdb $2/$(path-to-name $1).db -c "$sql"
```

### Example

```bash
ingest-stat-direct /usr/share/man/man1 tmp
ingest-stat-direct /data/mysql /space/var/
with-lib fsl2 -- ingest-stat-direct /data/mysql /space/var | ssh prot3cbdde1 -l root bash
<<< 'select * from fsdb' ssh prot3cbdde1 duckdb /space/var/data-mysql.db -readonly
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

# The prune problem

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
duckdb $2/$(path-to-name $1).db -c "$sql"
```

### Example

```bash
sudo bash out/log-file-stat-2.sh ingest-stat-direct /var/log tmp
duckdb tmp/var-log.db -readonly -c 'select * from fsdb'
sudo bash out/log-file-stat-2.sh ingest-stat-direct /var/log tmp
sudo bash out/log-file-stat-2.sh ingest-stat-direct /var/log tmp
duckdb tmp/var-log.db -readonly -c 'select * from fsdb'
sudo bash out/log-file-stat-2.sh prune-dedup /var/log tmp
duckdb tmp/var-log.db -readonly -c 'select * from fsdb'

with-lib fsl2 -- prune-dedup /data/mysql /space/var | ssh prot3cbdde1 -l root bash
<<< 'select * from fsdb' ssh prot3cbdde1 duckdb /space/var/data-mysql.db -readonly
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
duckdb $2/$(path-to-name $1).db -c "$sql"
```

## id list-deleted

```SQL
SELECT * from fsdb WHERE size = NULL
```

```bash
duckdb $2/$(path-to-name $1).db -c "$sql" "${@:3}"
```

## id add-snapshot

```bash
ingest-stat-direct "$@"
prune-dedup "$@"
mark-deleted "$@"
```

### Example

```bash
sudo bash out/log-file-stat-2.sh add-snapshot /var/log tmp
duckdb tmp/var-log.db -readonly -c 'select * from fsdb'
list-deleted /var/log tmp -readonly
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
