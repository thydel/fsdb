<!-- m4_changequote(«,»)m4_changecom() -->

# TOC

<!--
echo '$table-of-contents$' > tmp/toc.md
< fsdb-cte.md pandoc -f gfm -t gfm --toc --toc-depth=6 --template tmp/toc.md --columns=196 | grep -v Table.of.Contents
-->

-   [TOC](#toc)
-   [raw header](#raw-header)
-   [Macros for some default values](#macros-for-some-default-values)
-   [Helpers](#helpers)
    -   [id ddb](#id-ddb)
-   [A CTE lib for FSDB query](#a-cte-lib-for-fsdb-query)
    -   [Use `jq` string template for SQL CTE components](#use-jq-string-template-for-sql-cte-components)
        -   [id sql](#id-sql)
        -   [Alternative macro](#alternative-macro)
    -   [id start](#id-start)
    -   [id merge-cte](#id-merge-cte)
-   [Basics CTE](#basics-cte)
    -   [Limit the number of entries](#limit-the-number-of-entries)
        -   [id limit](#id-limit)
        -   [Example](#example)
    -   [Sort entries](#sort-entries)
        -   [id order](#id-order)
    -   [Sum over grouped cols](#sum-over-grouped-cols)
        -   [id sum](#id-sum)
        -   [Example](#example-1)
    -   [Keep selected cols only](#keep-selected-cols-only)
        -   [id keep](#id-keep)
    -   [Use distinct](#use-distinct)
        -   [id distinct](#id-distinct)
    -   [Use count](#use-count)
        -   [id count](#id-count)
    -   [Count over a grouped col](#count-over-a-grouped-col)
        -   [id grpcnt](#id-grpcnt)
        -   [Example](#example-2)
    -   [Format integer values of a list of cols for human](#format-integer-values-of-a-list-of-cols-for-human)
        -   [id human](#id-human)
        -   [Example](#example-3)
        -   [TODO](#todo)
    -   [hide cols](#hide-cols)
        -   [id hide](#id-hide)
        -   [Example](#example-4)

# raw header

```m4
m4_define(ME,fsdb-stat)
```

```yml
- { id: null, ns: ME }
- { ky: [ tt ], is: [ nv ] }
```

# Macros for some default values

```m4
m4_define(DB,out/ssp-small.db)
m4_define(TBL,fsdb)
```

# Helpers

## id ddb

- Call `duckdb` on default database with SQL on STDIN

```bash
duckdb DB "$@"
```

# A CTE lib for FSDB query

- A lib to build *file system data base* (FSDB) SQL queries using
  pipeline of *common table expression* (CTE) pipeline (See
  [Hierarchical and recursive queries in SQL][])

- See [cte-class.md][] for the meaning of `class` field of CTE

[Hierarchical and recursive queries in SQL]:
    https://en.wikipedia.org/wiki/Hierarchical_and_recursive_queries_in_SQL
    "wikipedia.org"

[cte-class.md]: cte-class.md "sibling file"

## Use `jq` string template for SQL CTE components

- A CTE is a `jq` string template that can use interpolation to inject
  CTE parameter

- A CTE pipe will construct an array of SQL parts that will be chained
  as CTE using `{prev}` as a pattern to be replaced by the ref of the
  previoux CTE in the pipe.

### id sql

```bash
jq ". + [\"$sql\""] "$@"
```

### Alternative macro

```m4
m4_define(SQL,jq -nr "\"$sql\"" "$«@»")
```

## id start

- First part of CTE pipe

```yml
class: source
```

```sql
FROM \($tbl)
```

```bash
sql -n --arg tbl ${1:-TBL}
```

## id merge-cte

- Merge an array of CTE replacing `{prev}` string with `step` + index
  of previous CTE

```jq
def cte($i; $cte): "step\($i) AS (\($cte))" | sub("{prev}"; "step\($i - 1)"; "g");
def ctes: [keys, .] | transpose | map(cte(first; last))[1:];
[ "WITH step0 AS (\(first))" ] + ctes | join(",\n") + "\nSELECT * FROM step\(length - 1)"
```

```bash
self -r
```

# Basics CTE

> [!NOTE]
>
> - All CTE will apply their action on the result of previous CTE
> - All CTE pipe starts with a special `start` CTE

## Limit the number of entries

### id limit

```yml
class: order_limit
```

```sql
SELECT * from {prev} LIMIT \($limit)
```

```bash
sql --arg limit ${1:-40}
```

### Example

```bash
start | limit | merge-cte
```

- Will produce

```sql
WITH step0 AS (FROM fsdb),
step1 AS (SELECT * from step0 LIMIT 40)
SELECT * FROM step1
```

## Sort entries

### id order

```yml
class: order_limit
```

```sql
SELECT * FROM {prev} ORDER BY \($order) \($dir)
```

```bash
sql --arg order ${1:?} --arg dir ${2:-DESC}
```

## Sum over grouped cols

### id sum

```yml
class: aggregate
```

```sql
SELECT \($group), \($sum / "," | map("SUM(\(.)) AS \(.)") | join(", ")) FROM {prev} GROUP BY \($group)
```

```bash
sql --arg group ${1:?} --arg sum ${2:-cnt,size}
```

### Example

```bash
start | sum server size,cnt | merge-cte | ddb -box
```

```txt
┌──────────┬──────────────┬─────────┐
│  server  │     size     │   cnt   │
├──────────┼──────────────┼─────────┤
│ profntp1 │ 131249243554 │ 797486  │
│ profntr1 │ 523076872829 │ 2062966 │
│ profnte1 │ 655727727112 │ 2022817 │
└──────────┴──────────────┴─────────┘
```

## Keep selected cols only

### id keep

```yml
class: map
```

```sql
SELECT \($ARGS.positional | join(", ")) FROM {prev}
```

```bash
sql --args "$@"
```

## Use distinct

### id distinct

```yml
class: aggregate
```

```sql
SELECT DISTINCT \($ARGS.positional | join(", ")) FROM {prev}
```

```bash
sql --args "$@"
```

## Use count

### id count

```yml
class: aggregate
```

```sql
SELECT COUNT(\($count)) FROM {prev}
```

```bash
sql --arg count "$1"
```

### Example

```bash
start | distinct server,path | count | merge-cte | ddb -box
```

```txt
┌──────────────┐
│ count_star() │
├──────────────┤
│ 54062        │
└──────────────┘
```

## Count over a grouped col

### id grpcnt

```yml
class: aggregate
```

```sql
SELECT \($group), COUNT(*) AS cnt FROM {prev} GROUP BY \($group)
```

```bash
sql --arg group ${1:?}
```

### Example

> [!NOTE]
> As the default DB is a reduced one (group by hour on dir part of
> path with sum over cnt and size) we'll use the full DB here

- Count by server and file name

```bash
start | grpcnt server,path[-1] | order cnt | limit 10 | merge-cte | duckdb tmp/ssp.db -box
```

```txt
┌──────────┬────────────────┬───────┐
│  server  │    path[-1]    │  cnt  │
├──────────┼────────────────┼───────┤
│ profnte1 │ data.zip       │ 30014 │
│ profntr1 │ data.zip       │ 16418 │
│ profntp1 │ data.zip       │ 110   │
│ profnte1 │ pop.txt        │ 12    │
│ profntp1 │ recoding.sql   │ 8     │
│ profntp1 │ files_list.php │ 8     │
│ profntp1 │ revert.sql     │ 8     │
│ profnte1 │ Apicem.111.pem │ 6     │
│ profnte1 │ Master.119     │ 6     │
│ profnte1 │ Master.125     │ 6     │
└──────────┴────────────────┴───────┘
```

- Count by server and file dir

```bash
start | grpcnt server,path[:-2] | order cnt | limit 10 | merge-cte | duckdb tmp/ssp.db -box
```

```txt
┌──────────┬─────────────────────────────────────────────────────────┬─────────┐
│  server  │                        path[:-2]                        │   cnt   │
├──────────┼─────────────────────────────────────────────────────────┼─────────┤
│ profntr1 │ [ssp, upload, files_1731959368]                         │ 1083387 │
│ profntp1 │ [ssp, upload, files_1731959368]                         │ 609414  │
│ profnte1 │ [ssp, upload, files_1731959368]                         │ 269990  │
│ profnte1 │ [ssp, upload, files_1731959368_by_group, 868, 2023, 11] │ 206068  │
│ profnte1 │ [ssp, upload, files_1731959368_by_group, 868, 2023, 05] │ 205963  │
│ profntr1 │ [ssp_ndf, upload, files_1731959368]                     │ 202718  │
│ profntp1 │ [ssp_pf_bio_covid, upload, files_1731959368]            │ 181905  │
│ profnte1 │ [ssp, hl7, 891-Nantes, archives, ADT]                   │ 86082   │
│ profnte1 │ [ssp, apicrypt, 201, attachments]                       │ 68560   │
│ profnte1 │ [ssp, apicrypt, 338, attachments]                       │ 51510   │
└──────────┴─────────────────────────────────────────────────────────┴─────────┘
```

## Format integer values of a list of cols for human

- Use `format_bytes` or `formatReadableDecimalSize`
  [DuckDB Text Functions][] to converts integer to a human-readable
  representation using units based on powers of either 2 (KiB, MiB,
  GiB, etc.) or 10 (KB, MB, GB, etc.)
- Add a new col with the converted value with col name prefixed by `h`

[DuckDB Text Functions]:
    https://duckdb.org/docs/stable/sql/functions/text
    "duckdb.org"

### id human

```yml
class: map
```

```sql
SELECT *, \($ARGS.positional | map("\($func)(\(.)::BIGINT) AS h\(.)") | join(", ")) FROM {prev}
```

```jq
{ "2": "format_bytes", "10": "formatReadableDecimalSize" }[$base] // halt_error(1)
```

```bash
local -A opts; local args cont; opts "$@"
: ${1:?}; sql --arg func $(self -n --arg base ${opts[b]:-2}) --args "${args[@]}"
```

### Example

```bash
start | human size | human --b=10 cnt | merge-cte
```

- Will produce

```sql
WITH step0 AS (FROM fsdb),
step1 AS (SELECT *, "format_bytes"(size::BIGINT) AS hsize FROM step0),
step2 AS (SELECT *, "formatReadableDecimalSize"(cnt::BIGINT) AS hcnt FROM step1)
SELECT * FROM step2
```

- And

```bash
start | sum server size,cnt | human size | human --b=10 cnt | merge-cte | ddb -box
```

```txt
┌──────────┬──────────────┬─────────┬───────────┬──────────┐
│  server  │     size     │   cnt   │   hsize   │   hcnt   │
├──────────┼──────────────┼─────────┼───────────┼──────────┤
│ profntr1 │ 523076872829 │ 2062966 │ 487.1 GiB │ 2.0 MB   │
│ profntp1 │ 131249243554 │ 797486  │ 122.2 GiB │ 797.4 kB │
│ profnte1 │ 655727727112 │ 2022817 │ 610.6 GiB │ 2.0 MB   │
└──────────┴──────────────┴─────────┴───────────┴──────────┘
```

### TODO

- Allow better arg parsing (.e.g. `human size cnt:d`)

## hide cols

### id hide

```yml
class: map
```

```sql
SELECT * EXCLUDE (\($ARGS.positional | join(", "))) FROM {prev}
```

```bash
sql --args "$@"
```

### Example

- Hide cols also presented with a special format

```bash
start | sum server size,cnt | human size | human --b=10 cnt | hide size cnt | merge-cte | ddb -box
```

```txt
┌──────────┬───────────┬──────────┐
│  server  │   hsize   │   hcnt   │
├──────────┼───────────┼──────────┤
│ profntp1 │ 122.2 GiB │ 797.4 kB │
│ profntr1 │ 487.1 GiB │ 2.0 MB   │
│ profnte1 │ 610.6 GiB │ 2.0 MB   │
└──────────┴───────────┴──────────┘
```

## Filter on col value

### id where

```sql
SELECT * FROM {prev} WHERE \($ARGS.positional | join(" "))
```

```bash
sql --args "$@"
```

### Example

```bash
start | where size == 0 | count | merge-cte | duckdb tmp/ssp.db -line
```

`count_star() = 2864`

### id is

```bash
: ${2:?}; where $1 == "'$2'"
```

### Example

```bash
start | is server profntr1 | sum path[1] | order size | merge-cte | ddb -box
```

```txt
┌───────────────┬─────────┬──────────────┐
│    path[1]    │   cnt   │     size     │
├───────────────┼─────────┼──────────────┤
│ ssp_ndf       │ 776718  │ 337280962161 │
│ ssp           │ 1285902 │ 185716649410 │
│ ssp_ndf_stats │ 343     │ 79256468     │
│ ssp-ndf       │ 1       │ 4450         │
│ ssp_stats     │ 2       │ 340          │
└───────────────┴─────────┴──────────────┘
```

### id like

```bash
: ${2:?}; where $1 like "'$2'"
```

### Example

```bash
start | like path[1] %pf% | sum server,path[1] | order size | merge-cte | ddb -box
```

```txt
┌──────────┬──────────────────┬────────┬─────────────┐
│  server  │     path[1]      │  cnt   │    size     │
├──────────┼──────────────────┼────────┼─────────────┤
│ profntp1 │ ssp_pf_bio_covid │ 183471 │ 16115312864 │
│ profntp1 │ esisdocs-pf      │ 806    │ 296389282   │
│ profntp1 │ esisdoccu-pf     │ 112    │ 43766559    │
│ profntp1 │ ssp_pf_stats     │ 22     │ 32427314    │
│ profntp1 │ portail-sante-pf │ 14     │ 178995      │
└──────────┴──────────────────┴────────┴─────────────┘
```

## Sum over time bucket

### id span

```sql
SELECT time_bucket(INTERVAL '\($n) \($bucket)', date) date,
\($group), \($sum / "," | map("SUM(\(.)) AS \(.)") | join(", ")), 
FROM {prev} GROUP BY all
```

```bash
local -A opts; local args cont; opts "$@"
sql --argjson n ${opts[n]:-1} --arg bucket ${opts[bucket]:-year} --arg group ${opts[group]:-server} --arg sum ${opts[sum]:-cnt,size}
```

### Example

```bash
start | span | order date asc | merge-cte | ddb
start | where server is profntr1 | span --bucket=month --group=
```


[Local Variables:]::
[indent-tabs-mode: nil]::
[End:]::
