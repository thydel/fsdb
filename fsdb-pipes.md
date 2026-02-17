<!-- m4_changequote(«,»)m4_changecom() -->

# What is this file

- Predefined CTE pipes combining operators from `fsdb-cte.md`
- Each pipe is a reusable command composing multiple CTE steps

# raw header

```m4
m4_define(ME,fsdb)
```

```yml
- { id: null, ns: ME }
```

# Macros

```m4
m4_define(PARSARG,«local -A opts; local args cont; parsarg "$«@»"»)
```

# Growth pipes

## id latest-growth

- Shows volume growth over last N time units
- Combines span, growth, pct, acc, hide, and order

```bash
PARSARG
local n=${args[0]:-6} unit=${args[1]:-month}; local bucket=${opts[b]:-$unit}
start | last $n $unit | span $bucket | growth size | pct size_rate | chain acc size size_diff | hide prev | order date asc
```

### Example

```bash
latest-growth | merge-cte | ddb -json | fmt-auto
latest-growth 12 month | merge-cte | ddb -box
latest-growth 3 week --b=week | merge-cte | ddb -box
```

## id site-growth

- Volume growth by site over time
- Uses `as` to alias `path[1]` into a plain `site` column
- Useful for DBs without a `server` column

```bash
PARSARG
local n=${args[0]:-12} unit=${args[1]:-month}; local bucket=${opts[b]:-$unit}
start --part=site | as path[1] site | last $n $unit | span --group=site $bucket | growth size site | pct size_rate | hide prev | order date asc
```

### Example

```bash
site-growth | merge-cte | duckdb tmp/prostrc1-space-nfsdata-small.db -box
site-growth 3 year --b=year | merge-cte | duckdb tmp/prostrc1-space-nfsdata-small.db -box
```

# Ranking pipes

## id top-dirs

- Top N directories by total size with human-readable output
- Args: depth (default 2), limit (default 10)

```bash
PARSARG
local depth=${args[0]:-2} n=${args[1]:-10}
local cols=$(seq -s, 1 $depth | sed 's/[0-9]*/path[&]/g')
start | sum $cols | order size | items $n | human size | hide size
```

### Example

```bash
top-dirs | merge-cte | duckdb tmp/prostrc1-space-nfsdata-small.db -box
top-dirs 3 5 | merge-cte | duckdb tmp/prostrc1-space-nfsdata-small.db -box
```

# Anomaly pipes

## id cnt-spikes

- Detect months with biggest file count jumps (possible bulk uploads)
- Uses rate of change to find outliers

```bash
PARSARG
local n=${args[0]:-10}
start | as path[1] site | span --group=site month | growth cnt site | where cnt_rate is not null | order cnt_rate | items $n | hide prev
```

### Example

```bash
cnt-spikes | merge-cte | duckdb tmp/prostrc1-space-nfsdata-small.db -box
cnt-spikes 5 | merge-cte | duckdb tmp/prostrc1-space-nfsdata-small.db -box
```

[Local Variables:]::
[indent-tabs-mode: nil]::
[End:]::
