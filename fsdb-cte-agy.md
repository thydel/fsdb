<!-- m4_changequote(«,»)m4_changecom() -->

# What is this file

-   Plotting operators for *file system data base* (FSDB) query pipelines.

# raw header

``` m4
m4_define(ME,fsdb)
m4_define(DB,tmp/nfsdata-small.db)
```

``` yml
- { id: null, ns: ME }
```

# Macros

``` m4
m4_define(PARSARG,«local -A opts; local args cont; parsarg "$«@»"»)
```

# Operators

## id plot-yp

-   Plot size or cnt using youplot (vertical terminal plot)

``` yml
class: meta
```

``` sql
SELECT \($_a.ts) AS date, \($col) AS \($col) FROM {prev} ORDER BY \($_a.ts) ASC
```

``` bash
PARSARG
local col=${opts[c]:-${args[0]:-size}}
local type=${opts[t]:-${args[1]:-bar}}
local db=${opts[d]:-${args[2]:-DB}}
sql --arg col "$col" | merge-cte | duckdb "$db" -csv | youplot "$type" -d, -H
```

### Example

``` bash
start | span month | plot-yp -t line
```

## id plot-ddb

-   Vertical terminal ASCII bar chart generated purely inside DuckDB (zero
    external dependencies)

``` yml
class: meta
```

``` sql
SELECT \($_a.ts) AS date,
  repeat('█', ((\($col) * 30) / nullif(MAX(\($col)) OVER (), 0))::int) AS bar,
  \($col) AS \($col)
FROM {prev} ORDER BY \($_a.ts) ASC
```

``` bash
PARSARG
local col=${opts[c]:-${args[0]:-size}}
local db=${opts[d]:-${args[1]:-DB}}
sql --arg col "$col" | merge-cte | duckdb "$db" -box
```

### Example

``` bash
start | span month | plot-ddb
```

## id plot-gnu

-   Horizontal datetime line plot generated via gnuplot in text mode

``` yml
class: meta
```

``` sql
SELECT strftime(\($_a.ts), '%Y-%m-%d %H:%M:%S') AS date, \($col) AS \($col)
FROM {prev} ORDER BY \($_a.ts) ASC
```

``` bash
PARSARG
local col=${opts[c]:-${args[0]:-size}}
local db=${opts[d]:-${args[1]:-DB}}
local gnu_opts='set datafile separator ","; set xdata time; set timefmt "%Y-%m-%d %H:%M:%S"; set term dumb size 100 30; plot "-" using 1:2 with lines'
sql --arg col "$col" | merge-cte | duckdb "$db" -csv | gnuplot -e "$gnu_opts"
```

### Example

``` bash
start | span month | plot-gnu
```

## id cumul

-   Accumulate (running total) of size and count dynamically

``` yml
class: window
```

``` sql
SELECT *,
  SUM(size) OVER (\(if $part == "default" then (if $_a.part != "" then "PARTITION BY " + $_a.part else "" end) elif $part != "" and $part != "none" then "PARTITION BY " + $part else "" end) ORDER BY \($_a.ts)) AS ssize,
  SUM(cnt) OVER (\(if $part == "default" then (if $_a.part != "" then "PARTITION BY " + $_a.part else "" end) elif $part != "" and $part != "none" then "PARTITION BY " + $part else "" end) ORDER BY \($_a.ts)) AS scnt
FROM {prev}
```

``` bash
PARSARG
local part=${opts[p]:-default}
sql --arg part "$part"
```

### Example

``` bash
start | cumul | order date asc
```
