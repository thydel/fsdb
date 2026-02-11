<!-- m4_changequote(«,»)m4_changecom() -->

<!--
echo '$table-of-contents$' > tmp/toc.md
< fsdb-more.md pandoc -f gfm -t gfm --toc --toc-depth=6 --template tmp/toc.md --columns=196 | grep -v Table.of.Contents
-->

<details><summary>Expand</summary>


</details>

# More tools for `fsdb`

- See [fsdb.md][]

[fsdb.md]: fsdb.md 'sibling file'

# raw header

```m4
m4_define(ME,fsdb)
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

# macro

```m4
m4_define(SQL,jq -nr "\"$sql\"" "$«@»")
```

## id list-deleted

```SQL
SELECT * from fsdb WHERE size = NULL
```

```bash
duckdb $2/$(path-to-name $1).db -c "$sql" "${@:3}"
```

# Clean up first tests

- That were not hour align

## id purge-before

```sql
DELETE FROM fsdb WHERE date < '\($limit)'::TIMESTAMP
```

```bash
: ${2:?}; duckdb $2/$(path-to-name $1).db -c "$sql"
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
