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

# Pipes

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

[Local Variables:]::
[indent-tabs-mode: nil]::
[End:]::
