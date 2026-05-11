<!-- m4_changequote(«,»)m4_changecom() -->

<!--
echo '$table-of-contents$' > tmp/toc.md
< fsdb-cte.md pandoc -f gfm -t gfm --toc --toc-depth=6 --template tmp/toc.md --columns=196 | grep -v Table.of.Contents
-->

-   [What is this file](#what-is-this-file)
-   [raw header](#raw-header)
-   [Macros](#macros)
-   [Helpers](#helpers)
    -   [id ddb](#id-ddb)
-   [Channel infrastructure](#channel-infrastructure)
    -   [id sql](#id-sql)
    -   [id start](#id-start)
    -   [id merge-cte](#id-merge-cte)
        -   [Example](#example)
-   [Filter operators](#filter-operators)
    -   [id where](#id-where)
        -   [Example](#example-1)
    -   [id is](#id-is)
        -   [Example](#example-2)
    -   [id like](#id-like)
        -   [Example](#example-3)
    -   [id last](#id-last)
        -   [Example](#example-4)
    -   [id first](#id-first)
        -   [Example](#example-5)
    -   [id since](#id-since)
        -   [Example](#example-6)
    -   [id Until](#id-until)
        -   [Example](#example-7)
-   [Map operators](#map-operators)
    -   [id keep](#id-keep)
    -   [id as](#id-as)
        -   [Example](#example-8)
    -   [id hide](#id-hide)
        -   [Example](#example-9)
    -   [id rename](#id-rename)
        -   [Example](#example-10)
    -   [id human](#id-human)
        -   [Example](#example-11)
    -   [id sep](#id-sep)
        -   [Example](#example-12)
    -   [id pct](#id-pct)
        -   [Example](#example-13)
-   [Aggregate operators](#aggregate-operators)
    -   [id sum](#id-sum)
        -   [Example](#example-14)
    -   [id count](#id-count)
        -   [Example](#example-15)
    -   [id grpcnt](#id-grpcnt)
        -   [Example](#example-16)
    -   [id distinct](#id-distinct)
    -   [id span](#id-span)
        -   [Example](#example-17)
-   [Window operators](#window-operators)
    -   [id growth](#id-growth)
        -   [Example](#example-18)
    -   [id acc](#id-acc)
        -   [Example](#example-19)
-   [Order / Limit operators](#order--limit-operators)
    -   [id order](#id-order)
    -   [id items](#id-items)
        -   [Example](#example-20)
-   [Meta operators](#meta-operators)
    -   [id chain](#id-chain)
    -   [id fmt-auto](#id-fmt-auto)
        -   [Example](#example-21)

# What is this file

- A CTE operator library for building *file system data base* (FSDB)
  SQL queries using pipeline of *common table expression* (CTE)
- Uses a **channel format** where each element carries both args and
  SQL: `{a: {ts, file, tbl, vals, part}, q: SQL}`
- See [Hierarchical and recursive queries in SQL][]

[Hierarchical and recursive queries in SQL]:
    https://en.wikipedia.org/wiki/Hierarchical_and_recursive_queries_in_SQL
    "wikipedia.org"

# raw header

```m4
m4_define(ME,fsdb)
m4_define(DB,tmp/nfsdata-small.db)
```

```yml
- { id: null, ns: ME }
```

# Macros

```m4
m4_define(DB,out/mailmerge-small.db)
m4_define(TBL,fsdb)
m4_define(PARSARG,«local -A opts; local args cont; parsarg "$«@»"»)
```

# Helpers

## id ddb

- Call `duckdb` on default database with SQL on STDIN

```bash
duckdb DB "$@"
```

# Channel infrastructure

- Each pipeline element is `{a: ARGS, q: SQL}` where `a` propagates
  column name aliases through the pipe

## id sql

- Core helper: wraps SQL string into a channel element, propagating
  args from the previous element
- Inside jq string templates, `$_a.ts`, `$_a.file`, `$_a.vals`,
  `$_a.part` are available for column name interpolation

```bash
jq '((.[-1].a) // {}) as $_a | . + [{a: $_a, q: '"\"$sql\""'}]' "$@"
```

## id start

- First element of a CTE pipe, initializes channel args
- Defaults: `ts=date`, `file=path`, `tbl=fsdb`, `vals=cnt,size`,
  `part=server`

```yml
class: source
```

```jq
{ ts: ($ts // "date"), file: ($file // "path"), tbl: ($tbl // "fsdb"),
  vals: ($vals // "cnt,size"), part: ($part // "server") } as $a
| [{ a: $a, q: "FROM \($a.tbl)" }]
```

```bash
PARSARG
self -n \
  --arg ts "${opts[ts]:-date}" \
  --arg file "${opts[file]:-path}" \
  --arg tbl "${args[0]:-TBL}" \
  --arg vals "${opts[vals]:-cnt,size}" \
  --arg part "${opts[part]:-server}"
```

## id merge-cte

- Assembles a channel array into final SQL
- Extracts `.q` from each element, chains as WITH ... CTE

```jq
def cte($i; $cte): "step\($i) AS (\($cte))" | sub("{prev}"; "step\($i - 1)"; "g");
def ctes: [keys, .] | transpose | map(cte(first; last))[1:];
map(.q)
| [ "WITH step0 AS (\(first))" ] + ctes | join(",\n") + "\nSELECT * FROM step\(length - 1)"
```

```bash
self -r
```

### Example

```bash
start | merge-cte
```

- Will produce

```sql
WITH step0 AS (FROM fsdb)
SELECT * FROM step0
```

# Filter operators

## id where

- Generic SQL WHERE clause

```sql
SELECT * FROM {prev} WHERE \($ARGS.positional | join(" "))
```

```bash
sql --args "$@"
```

### Example

```bash
start | where size == 0 | count | merge-cte | ddb -line
```

## id is

- Equality filter shorthand

```bash
: ${2:?}; where $1 = "'$2'"
```

### Example

```bash
start | is server profntr1 | sum path[1] | order size | merge-cte | ddb -box
```

## id like

- LIKE pattern filter

```bash
: ${2:?}; where $1 like "'$2'"
```

### Example

```bash
start | like path[1] %pf% | sum server,path[1] | order size | merge-cte | ddb -box
```

## id last

- Filter rows relative to now (most recent N units)

```yml
class: filter
```

```sql
SELECT * FROM {prev} WHERE \($_a.ts) >= now() - INTERVAL \($n) \($unit)
```

```bash
sql --arg n ${1:?} --arg unit ${2:-days}
```

### Example

```bash
start | last 6 month | merge-cte
```

## id first

- Filter rows from the earliest N units

```yml
class: filter
```

```sql
SELECT * FROM {prev} WHERE \($_a.ts) <= (SELECT MIN(\($_a.ts)) FROM {prev}) + INTERVAL \($n) \($unit)
```

```bash
sql --arg n ${1:?} --arg unit ${2:-days}
```

### Example

```bash
start | first 30 day | merge-cte
```

## id since

- Filter rows from a given date onward

```yml
class: filter
```

```sql
SELECT * FROM {prev} WHERE \($_a.ts) >= '\($date)'
```

```bash
sql --arg date ${1:?}
```

### Example

```bash
start | since 2025-01-01 | merge-cte
```

## id Until

- Filter rows before a given date

```yml
class: filter
```

```sql
SELECT * FROM {prev} WHERE \($_a.ts) < '\($date)'
```

```bash
sql --arg date ${1:?}
```

### Example

```bash
start | until 2025-07-01 | merge-cte
```

# Map operators

## id keep

- Projection: keep only selected columns

```yml
class: map
```

```sql
SELECT \($ARGS.positional | join(", ")) FROM {prev}
```

```bash
sql --args "$@"
```

## id as

- Alias an expression as a new column
- Use before `span`/`growth` when grouping or partitioning by
  expressions (e.g. `path[1]`) that won't survive as column names
  across CTE boundaries

```yml
class: map
```

```sql
SELECT *, \($ARGS.positional[0]) AS \($ARGS.positional[1]) FROM {prev}
```

```bash
: ${2:?}; sql --args "$@"
```

### Example

```bash
start | as path[1] site | span --group=site month | growth size site | merge-cte
```

## id hide

- Exclusion: remove selected columns

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

```bash
start | sum server size,cnt | human size | hide size cnt | merge-cte | ddb -box
```

## id rename

- Rename a column

```yml
class: map
```

```sql
SELECT * REPLACE (\($old) AS \($new)) FROM {prev}
```

```bash
: ${2:?}; sql --arg old $1 --arg new $2
```

### Example

```bash
start | rename date ts | merge-cte
```

## id human

- Human-readable sizes using DuckDB text functions
- `format_bytes` (base 2) or `formatReadableDecimalSize` (base 10)
- Adds a new column prefixed with `h`

[DuckDB Text Functions]:
    https://duckdb.org/docs/stable/sql/functions/text
    "duckdb.org"

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

## id sep

- Format integer columns with thousand separators (`1,000,000`)
- Converts numbers to strings, use as final step after `order`

```yml
class: map
```

```jq
def fmt: "printf('%,d', \"\(.)\") AS \"\(.)\"";
((.[-1].a) // {}) as $_a | . + [{a: $_a, q: "SELECT * REPLACE (\($ARGS.positional | map(fmt) | join(", "))) FROM {prev}"}]
```

```bash
self --args "$@"
```

### Example

```bash
start | span month | sep size | merge-cte | ddb -box
```

## id pct

- Converts a ratio (0.18) to a percentage string ("18.00%")
- Multiplies by 100 and adds the `%` symbol
- Changes column type to String, preventing further numeric formatting

```yml
class: map
```

```jq
# %% escapes the percent sign in printf
def fmt: "printf('%.2f%%', \"\(.)\" * 100) AS \"\(.)\"";
((.[-1].a) // {}) as $_a | . + [{a: $_a, q: "SELECT * REPLACE (\($ARGS.positional | map(fmt) | join(", "))) FROM {prev}"}]
```

```bash
self --args "$@"
```

### Example

```bash
start | span month | growth size | pct size_rate | merge-cte | ddb -box
```

# Aggregate operators

## id sum

- Sum over grouped columns
- Uses `$_a.vals` as default for columns to sum

```yml
class: aggregate
```

```sql
SELECT \($group), \((if $sum != "" then $sum else $_a.vals end) / "," | map("SUM(\(.)) AS \(.)") | join(", ")) FROM {prev} GROUP BY \($group)
```

```bash
sql --arg group ${1:?} --arg sum "${2:-}"
```

### Example

```bash
start | sum server | merge-cte | ddb -box
```

## id count

- Scalar count

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

## id grpcnt

- Grouped count

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

```bash
start | grpcnt server | order cnt | items 10 | merge-cte | ddb -box
```

## id distinct

- Deduplication

```yml
class: aggregate
```

```sql
SELECT DISTINCT \($ARGS.positional | join(", ")) FROM {prev}
```

```bash
sql --args "$@"
```

## id span

- Sum over time bucket with positional API
- `span month` = 1 month bucket
- `span 2 week` = 2 week bucket
- Overrides via `--group=COL`, `--vals=COLS`

```yml
class: aggregate
```

```sql
SELECT time_bucket(INTERVAL '\($n) \($bucket)', \($_a.ts)) \($_a.ts),
\(if $group != "" then $group else $_a.part end), \((if $sum != "" then $sum else $_a.vals end) / "," | map("SUM(\(.)) AS \(.)") | join(", ")),
FROM {prev} GROUP BY all
```

```bash
PARSARG
local n bucket
if [[ ${#args[@]} -ge 2 ]]; then
  n=${args[0]}; bucket=${args[1]}
elif [[ ${#args[@]} -eq 1 ]]; then
  n=1; bucket=${args[0]}
else
  n=1; bucket=year
fi
sql --argjson n "$n" --arg bucket "$bucket" \
  --arg group "${opts[group]:-}" --arg sum "${opts[vals]:-}"
```

### Example

```bash
start | span month | order date asc | merge-cte | ddb -box
start | span 2 week | merge-cte | ddb -box
```

# Window operators

## id growth

- Calculate evolution of a column (diff and rate) vs previous time slot
- Adds `_diff` and `_rate` columns
- Uses `$_a.ts` for ORDER BY, `$_a.part` for PARTITION BY

```yml
class: window
```

```sql
SELECT *,
  \($col) - prev AS \($col)_diff,
  round((\($col) - prev)::DOUBLE / nullif(prev, 0), 4) AS \($col)_rate
FROM (
  SELECT *, LAG(\($col)) OVER (PARTITION BY \(if $part != "" then $part else $_a.part end) ORDER BY \($_a.ts)) AS prev
  FROM {prev}
)
```

```bash
sql --arg col ${1:?} --arg part "${2:-}"
```

### Example

```bash
start | last 6 month | span month | growth size | order date asc | merge-cte | ddb -box
```

## id acc

- Accumulate (running total) of a column
- Adds `_cumul` suffix to the new column name
- Uses `$_a.ts` for ORDER BY, `$_a.part` for PARTITION BY

```yml
class: window
```

```sql
SELECT *, SUM(\($col)) OVER (PARTITION BY \(if $part != "" then $part else $_a.part end) ORDER BY \($_a.ts)) AS \($col)_cumul FROM {prev}
```

```bash
sql --arg col ${1:?} --arg part "${2:-}"
```

### Example

```bash
start | last 6 month | span month | growth size | chain acc size size_diff | order date asc | merge-cte | ddb -box
```

# Order / Limit operators

## id order

- Sort results

```yml
class: order_limit
```

```sql
SELECT * FROM {prev} ORDER BY \($order) \($dir)
```

```bash
sql --arg order ${1:?} --arg dir ${2:-DESC}
```

## id items

- Limit the number of results

```yml
class: order_limit
```

```sql
SELECT * FROM {prev} LIMIT \($limit)
```

```bash
sql --arg limit ${1:-40}
```

### Example

```bash
start | order size | items 10 | merge-cte | ddb -box
```

# Meta operators

## id chain

- Apply a command to a list of arguments recursively, piping the
  result of each step to the next

```jq
$ARGS.positional | map("\($cmd) \(.)") | join(" | ")
```

```bash
source <(self -nr --arg cmd "${1:?}" --args "${@:2}")
```

## id fmt-auto

- Post process SQL JSON output with IEC formatting

```jq
def iec(d):
  if . < 0 then "-" + ((-.) | iec(d))
  else
    def n(n): pow(10; n) as $p | . * $p | floor / $p;
    1024 as $k | ([ while(. >= $k; . / $k) ] | length) as $l
    | (. / pow($k; $l) | n(d) | tostring) + ["", "K", "M", "G", "T"][$l]
  end;
.[] | map_values(try iec($n) // .)
```

```bash
#self -c | sqlite-utils memory stdin:nl "select * from stdin" --fmt github
self -c --argjson n ${1:-0} | duckdb  --markdown -c "SELECT * FROM read_json_auto('/dev/stdin')"
```

### Example

```bash
start | span month | growth size | merge-cte | ddb -json | fmt-auto
```

[Local Variables:]::
[indent-tabs-mode: nil]::
[End:]::
