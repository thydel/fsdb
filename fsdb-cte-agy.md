<!-- m4_changequote(«,»)m4_changecom() -->

# What is this file

- Plotting operators for *file system data base* (FSDB) query pipelines.

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
m4_define(PARSARG,«local -A opts; local args cont; parsarg "$«@»"»)
```

# Operators

## id plot

- Plot size or cnt using youplot
- Args: column (default size), type (default bar), db (default DB)

```yml
class: meta
```

```sql
SELECT \($_a.ts) AS date, \($col) AS \($col) FROM {prev}
```

```bash
PARSARG
local col=${opts[c]:-${args[0]:-size}}
local type=${opts[t]:-${args[1]:-bar}}
local db=${opts[d]:-${args[2]:-DB}}

sql --arg col "$col" | merge-cte | duckdb "$db" -csv | youplot "$type" -d, -H
```

### Example

```bash
start | span month | plot -t line
```
