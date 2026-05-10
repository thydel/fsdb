<!-- m4_changequote(«,»)m4_changecom() -->

<!--
echo '$table-of-contents$' > tmp/toc.md
< fsdb-misc.md pandoc -f gfm -t gfm --toc --toc-depth=6 --template tmp/toc.md --columns=196 | grep -v Table.of.Contents
-->

-   [raw header](#raw-header)
-   [id table-info](#id-table-info)
-   [id full-db-basic-facts](#id-full-db-basic-facts)
-   [id small-db-basic-facts](#id-small-db-basic-facts)
-   [id query-stat](#id-query-stat)

# raw header

```m4
m4_define(ME,fsdb)
m4_define(DB,tmp/nfsdata-small.db)
```

```yml
- { id: null, ns: ME }
```

# macro

```m4
m4_define(SQL,jq -nr "\"$sql\"" "$«@»")
```

# id table-info

```sql
SELECT name AS column_name, type AS column_type FROM pragma_table_info('\($table)')
```

```bash
SQL --arg table ${1:-fsdb}
```

```sh
table-info | duckdb tmp/ssp.db --box
```

# id full-db-basic-facts

```sql
SELECT
  STRFTIME(min(uts), '%Y-%m-%d') AS start,
  STRFTIME(max(uts), '%Y-%m-%d') AS end,
  count(DISTINCT server) AS servers,
  format_bytes(count(*)::BIGINT) AS files,
  format_bytes(sum(size)::BIGINT) AS size
FROM fsdb;

```

```bash
SQL
```

```sh
full-db-basic-facts | duckdb tmp/ssp.db --box
```

# id small-db-basic-facts

```sql
SELECT
  STRFTIME(min(date), '%Y-%m-%d') AS start,
  STRFTIME(max(date), '%Y-%m-%d') AS end,
  format_bytes(count(*)::BIGINT) AS rows,
  count(DISTINCT server) AS servers,
  format_bytes(count(DISTINCT path)) AS dirs,
  format_bytes(sum(cnt)::BIGINT) AS files,
  format_bytes(sum(size)::BIGINT) AS size
FROM fsdb;
```

```bash
SQL
```

```sh
small-db-basic-facts | duckdb out/ssp-small.db --box
```

# id query-stat

```sql
SELECT 
    \($time) as time,
    path[1:\($depth)] as depth,
    sum(cnt) as files,
    sum(size) as bytes,
    min(min) as min_size,
    max(max) as max_size,
    sum(size) / sum(cnt) as avg_size
FROM fsdb
GROUP BY all
ORDER BY time, depth
```

```bash
local time="${1:-date}" # Default to existing hourly timestamp
local depth="${2:-99}"	# Default to deep path

SQL --arg depth "$depth" --arg time "$time" | duckdb DB
```

```sh
day="time_bucket(INTERVAL '1 day', date)"
year="time_bucket(INTERVAL '1 year', date)"
hour='hour(date)'
dow='dayofweek(date)'

query-stat "time_bucket(INTERVAL '5 year', date)" 1
query-stat "$year" 1
```

[Local Variables:]::
[indent-tabs-mode: nil]::
[End:]::
