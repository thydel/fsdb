---
name: fsdb-cte
description: Use when writing or modifying FSDB CTE operators and exploring database pipelines
---

# FSDB CTE Expert

This skill guides the composition, refactoring, and execution of DuckDB-backed SQL CTE pipeline operators in `fsdb`.

## Core Concepts & Channel Pattern

Every pipeline operator operates on a JSON channel structure formatted as:
`{a: ARGS, q: SQL}`

- **`a` (Arguments Map)**: Carries column name configurations through the pipeline steps. Inside `jq` templates, standard variables include:
  - `$_a.ts` (timestamp column name, e.g., `date` or `uts`)
  - `$_a.file` (file path array column name, e.g., `path`)
  - `$_a.tbl` (table name being queried, e.g., `fsdb`)
  - `$_a.vals` (comma-separated metric columns, e.g., `cnt,size`)
  - `$_a.part` (default partitioning column, e.g., `server`)
- **`q` (SQL Template)**: The raw SQL template string. Standard placeholders like `{prev}` are resolved dynamically into the previous CTE table step name (e.g. `step0`, `step1`).

---

## Design Directives for Writing CTEs

1. **No Defaults for Boundary Arguments**: Avoid implicit default boundaries for `start` or `pivot` timestamps (e.g., in `growth` or `since`). Force the user to specify dates explicitly to prevent silent or misleading query matches.
2. **DuckDB Specific Optimization**:
   - Prefer native array slicing (e.g., `path[1 : len(path)-1]`) and list functions over string concatenation for directory operations.
   - Utilize `time_bucket(INTERVAL, timestamp)` for time bucketing.
   - Use window functions (e.g., `SUM() OVER (PARTITION BY ... ORDER BY ...)`) selectively. For period comparisons (like `growth`), aggregate metrics natively with `CASE WHEN` conditions instead of window functions to allow single-pass grouping.
3. **Pipeline Composability**:
   - Ensure operators propagate the `a` metadata channel unchanged unless they modify the columns (e.g., projection operations like `keep` or `hide`).

---

## Example Composition Workflow

### Designing a new CTE Operator
When drafting a new operator, define it inside `fsdb-cte.md` using the standard `baj` macro rules:

```sql
## id your_op

# Describe target output and parameter signature

SELECT
  \($_a.file),
  \($_a.ts),
  SUM(size) AS size
FROM {prev}
GROUP BY all
```

[Local Variables:]: :
[indent-tabs-mode: nil]: :
[End:]: :
