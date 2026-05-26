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
-   Reads CSV from STDIN

``` bash
PARSARG
local type=${opts[t]:-${args[0]:-bar}}
youplot "$type" -d, -H
```

### Example

``` bash
start | span month | sum date | merge-cte | ddb -csv | plot-yp -t line
```

## id plot-ddb

-   Vertical terminal ASCII bar chart (zero external dependencies)
-   Reads JSON from STDIN

``` bash
PARSARG
local col=${opts[c]:-${args[0]:-size}}
local ts=${opts[t]:-${opts[ts]:-date}}
jq -r --arg col "$col" --arg ts "$ts" '
  . as $root | map(.[$col] // 0) | max as $max
  | $root[] | (.[$col] // 0) as $val
  | (($val * 30) / (if $max == 0 then 1 else $max end) | round) as $bars
  | ([range($bars)] | map("█") | join("")) as $bar
  | "\(.[$ts]) ┤\($bar) \($val)"
'
```

### Example

``` bash
start | span month | sum date | merge-cte | ddb -json | plot-ddb size
```

## id plot-gnu

-   Horizontal datetime line plot generated via gnuplot in text mode
-   Reads CSV from STDIN

``` bash
PARSARG
local gnu_opts='set datafile separator ","; set xdata time; set timefmt "%Y-%m-%d %H:%M:%S"; set term dumb size 100 30; plot "-" using 1:2 with lines'
gnuplot -e "$gnu_opts"
```

### Example

``` bash
start | span month | sum date | merge-cte | ddb -csv | plot-gnu
```
