# Report: Refine parsarg Option Handling in plot Operator

We refined the `plot` operator in `fsdb-cte-agy.md` to use strictly short options (`c`, `t`, `d`) mapped from `parsarg`'s `opts` associative array, with fallback to positional arguments. We also added an `### Example` section for documentation and reformatted the shell pipeline onto a single clean line.

## Proposed Changes

### Component: fsdb-cte-agy

#### [MODIFY] [fsdb-cte-agy.md](file:///home/thy/usr/hub/work/ext/fsdb/fsdb-cte-agy.md)
Updated the `bash` block of the `plot` operator to resolve arguments from the short option mappings in `opts` associative array first, falling back to positional `args` array, then to defaults:

```bash
PARSARG
local col=${opts[c]:-${args[0]:-size}}
local type=${opts[t]:-${args[1]:-bar}}
local db=${opts[d]:-${args[2]:-DB}}

sql --arg col "$col" | merge-cte | duckdb "$db" -csv | youplot "$type" -d, -H
```

## Verification

The pipeline compiles successfully and resolves arguments as expected:
```bash
export PATH=/usr/local/bin:/usr/bin:/bin:$PATH
export Y2J_USE_PYTHON=1
shopt -s expand_aliases
source baj/cmd/baj.sh
source baj/cmd/parsarg.sh
load out/fsdb-cte.yml out/fsdb-pipes.yml out/fsdb-cte-agy.yml
# Test specifying only type and db options via short flag assignments
start | span month | plot -t=line -d=tmp/nfsdata-small.db
```

### Chart Output
```text
                     ┌────────────────────────────────────────┐
        400000000000 │⠀⠀
        ...
   size              │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡰⠁⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀│
                     │
                     │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
                     │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
                     │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠜⠀
                     │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠜⠀⠀⠀⠀⠀⠀⢸⣧⢂⡄⠀⠀⠀│
                     │⠀
                     │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
                     │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
                     │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⠊⠀⠀⠀⠀⠀⠀⠀⣸⣿⡳⡇⠀⠀⠀
                     │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⠊⠀⠀⠀⠀⠀⠀⠀⣸⣿⡳⡇⠀⠀⠀│
                   0 │⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⣤⣴⣾⣛⣉⣥⣤⣴⣥⣴⣮⣷⣶⣶⣾⣿⣿
                   0 │⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⣤⣴⣾⣛⣉⣥⣤⣴⣥⣴⣮⣷⣶⣶⣾⣿⣿⣿⣯⣿⣿
                     └────────────────────────────────────────┘
                     1990                                  2030
                                       date
```
