# Plan: Separate Plotting Operators

To align with `baj` design principles (small, composable, single-responsibility functions), we will implement three distinct plotting operators in `fsdb-cte-agy.md` instead of a single multi-mode function:

1. `plot-yp`: Vertical terminal plot using `youplot`.
2. `plot-ddb`: Vertical terminal ASCII plot generated purely inside DuckDB (zero external dependencies).
3. `plot-gnu`: Horizontal datetime line plot generated via `gnuplot` in text mode.

## Proposed Changes

### Component: fsdb-cte-agy

#### [MODIFY] [fsdb-cte-agy.md](file:///home/thy/usr/hub/work/ext/fsdb/fsdb-cte-agy.md)
Update the file to contain three separate operators:

##### `plot-yp`
* **SQL:**
  ```sql
  SELECT \($_a.ts) AS date, \($col) AS \($col) FROM {prev} ORDER BY \($_a.ts) ASC
  ```
* **Bash:**
  ```bash
  PARSARG
  local col=${opts[c]:-${args[0]:-size}}
  local type=${opts[t]:-${args[1]:-bar}}
  local db=${opts[d]:-${args[2]:-DB}}
  sql --arg col "$col" | merge-cte | duckdb "$db" -csv | youplot "$type" -d, -H
  ```

##### `plot-ddb`
* **SQL:**
  ```sql
  SELECT \($_a.ts) AS date, repeat('█', ((\($col) * 30) / nullif(MAX(\($col)) OVER (), 0))::int) AS bar, \($col) AS \($col) FROM {prev} ORDER BY \($_a.ts) ASC
  ```
* **Bash:**
  ```bash
  PARSARG
  local col=${opts[c]:-${args[0]:-size}}
  local db=${opts[d]:-${args[1]:-DB}}
  sql --arg col "$col" | merge-cte | duckdb "$db" -box
  ```

##### `plot-gnu`
* **SQL:**
  ```sql
  SELECT strftime(\($_a.ts), '%Y-%m-%d %H:%M:%S') AS date, \($col) AS \($col) FROM {prev} ORDER BY \($_a.ts) ASC
  ```
* **Bash:**
  ```bash
  PARSARG
  local col=${opts[c]:-${args[0]:-size}}
  local db=${opts[d]:-${args[1]:-DB}}
  sql --arg col "$col" | merge-cte | duckdb "$db" -csv | gnuplot -e 'set datafile separator ","; set xdata time; set timefmt "%Y-%m-%d %H:%M:%S"; set term dumb size 100 30; plot "-" using 1:2 with lines'
  ```

Add `### Example` sections for all three operators.

## Verification Plan

### Automated Tests
Run the following verification pipelines on the workstation:
```bash
export PATH=/usr/local/bin:/usr/bin:/bin:$PATH
export Y2J_USE_PYTHON=1
shopt -s expand_aliases
source baj/cmd/baj.sh
source baj/cmd/parsarg.sh
load out/fsdb-cte.yml out/fsdb-pipes.yml out/fsdb-cte-agy.yml

# Test 1: youplot
start | span month | plot-yp

# Test 2: Pure DuckDB plot
start | span month | plot-ddb

# Test 3: Gnuplot line graph
start | span month | plot-gnu
```
Confirm all execute cleanly and output plots.
