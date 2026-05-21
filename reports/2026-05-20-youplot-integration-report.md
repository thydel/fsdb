# Report: youplot Integration inside fsdb-cte

**Date:** 2026-05-20  
**Author:** Antigravity  
**Topic:** Implementation of plotting capability for file tree databases (FSDB).

---

## Context

To provide better integrated pipeline capabilities for capacity planning and disk usage analysis, we implemented a dedicated plotting operator. The tool pipes compiled CTE query outputs to the `youplot` command-line utility.

## Implementation Details

1. **Makefile Integration:** Updated `main` target in [Makefile](file:///home/thy/usr/hub/work/ext/fsdb/Makefile) to compile the new Markdown file.
2. **Literate MD Source:** Created [fsdb-cte-agy.md](file:///home/thy/usr/hub/work/ext/fsdb/fsdb-cte-agy.md).
3. **`plot` Operator Design:**
   - Appends a projection step to the JSON query channel that selects the X-axis (`$_a.ts` aliased to `date`) and the target column (`\($col)` aliased to its name).
   - Generates SQL using the standard `merge-cte` operator.
   - Executes the query against DuckDB and outputs CSV.
   - Pipes the output to `youplot <type> -d, -H`.

## Verification Command

To run the pipeline and generate the plot locally on the workstation:
```bash
export PATH=/usr/local/bin:/usr/bin:/bin:$PATH
export Y2J_USE_PYTHON=1
shopt -s expand_aliases
source baj/cmd/baj.sh
source baj/cmd/parsarg.sh
load out/fsdb-cte.yml out/fsdb-pipes.yml out/fsdb-cte-agy.yml
start | span month | plot size bar tmp/nfsdata-small.db
```

## Sample Output Chart
```text
   2019-12-01 01:00:00+01 ┤ 178824283.0
   2021-03-01 01:00:00+01 ┤ 1814863267.0
   2021-06-01 02:00:00+02 ┤ 4104973591.0
   2023-03-01 01:00:00+01 ┤■ 12623323841.0
   2025-04-01 02:00:00+02 ┤■ 15892115180.0
   2023-08-01 02:00:00+02 ┤■■ 36040140934.0
   ...
```
