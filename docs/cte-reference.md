# FSDB CTE Operator Reference

This document provides a complete reference for all Common Table Expression (CTE) pipeline operators in `fsdb`.

---

## 1. Source & Control Operators

### `start`
Initializes a new `fsdb` pipeline with the metadata channel structure. Sets default column names and metadata states.
- **Parameters**: 
  - `[tbl]` (Positional): The name of the table to read from (default: `fsdb`).
  - `--ts=COL`: Column to treat as the timestamp (default: `date`).
  - `--file=COL`: Column to treat as the file path (default: `path`).
  - `--vals=COLS`: Comma-separated list of value columns to aggregate (default: `cnt,size`).
  - `--part=COL`: Partition column for window functions (default: `server`).
- **Example**:
  ```bash
  start --ts=uts --part=host
  ```

### `merge-cte`
Compiles the JSON array of pipeline steps into standard SQL WITH CTE syntax. This must always be the final step of a query generator before pipe execution.
- **Example**:
  ```bash
  start | where size > 1024 | merge-cte
  ```

---

## 2. Filter Operators

### `where`
Applies a generic SQL `WHERE` clause.
- **Parameters**: Raw SQL conditional expression.
- **Example**:
  ```bash
  start | where "size > 1000000 AND server = 'profntr1'"
  ```

### `is`
Shorthand equality filter.
- **Parameters**: `is <column> <value>`
- **Example**:
  ```bash
  start | is server profntr1
  ```

### `like`
Shorthand for a standard SQL `LIKE` query.
- **Parameters**: `like <column> <pattern>`
- **Example**:
  ```bash
  start | like path[1] %cache%
  ```

### `regexp`
DuckDB regular expression regex filter.
- **Parameters**: `regexp <column> <pattern>`
- **Example**:
  ```bash
  start | regexp server "prot1str[bc]1"
  ```

### `last`
Filters rows to those modified within the last N time units relative to the current timestamp.
- **Parameters**: `last <n> [unit]` (default unit: `days`).
- **Example**:
  ```bash
  start | last 6 month
  ```

### `first`
Filters rows to those modified in the earliest N time units relative to the min timestamp in the dataset.
- **Parameters**: `first <n> [unit]` (default unit: `days`).
- **Example**:
  ```bash
  start | first 30 day
  ```

### `since`
Filters rows starting from a specific date.
- **Parameters**: `since <date>`
- **Example**:
  ```bash
  start | since 2025-01-01
  ```

### `until`
Filters rows up to (but not including) a specific date.
- **Parameters**: `until <date>`
- **Example**:
  ```bash
  start | until 2025-07-01
  ```

---

## 3. Map Operators

### `keep`
Projection operator: keeps only the specified columns and discards the rest.
- **Parameters**: Comma-separated column list.
- **Example**:
  ```bash
  start | keep date, path, size
  ```

### `as`
Computes an expression and aliases it as a new column. Crucial before grouping or windowing on expressions (e.g. array slices).
- **Parameters**: `as <expression> <alias>`
- **Example**:
  ```bash
  start | as path[1] site
  ```

### `hide`
Exclusion operator: discards the specified columns.
- **Parameters**: Comma-separated column list to exclude.
- **Example**:
  ```bash
  start | hide min, max, mean
  ```

### `rename`
Renames an existing column.
- **Parameters**: `rename <old_name> <new_name>`
- **Example**:
  ```bash
  start | rename date ts
  ```

### `human`
Appends a human-readable column of formatted bytes or counts prefixed with `h` (e.g., `hsize`, `hcnt`).
- **Parameters**:
  - `[col]` (Positional): The column to format.
  - `-b=BASE`: Binary Base-2 (`-b=2`, standard `format_bytes`) or Decimal Base-10 (`-b=10`, `formatReadableDecimalSize`).
- **Example**:
  ```bash
  start | human size | human --b=10 cnt
  ```

### `sep`
Formats integer columns with thousands separators (`printf('%,d', col)`). Converts the column to a text type.
- **Parameters**: Column names to format.
- **Example**:
  ```bash
  start | sep size, cnt
  ```

### `pct`
Formats a numeric ratio (e.g. 0.1873) into a percentage string (e.g. `18.73%`). Converts the column to a text type.
- **Parameters**: Column names to format.
- **Example**:
  ```bash
  start | pct size_rate
  ```

---

## 4. Aggregate Operators

### `sum`
Sums specified columns grouped by one or more keys.
- **Parameters**: `sum <group_by_col> [col_to_sum]` (defaults to `$_a.vals` list).
- **Example**:
  ```bash
  start | sum server
  ```

### `count`
Performs a scalar row count query.
- **Example**:
  ```bash
  start | count
  ```

### `grpcnt`
Groups by specified columns and yields a row count (`cnt`) for each group.
- **Parameters**: Column names to group by.
- **Example**:
  ```bash
  start | grpcnt server
  ```

### `distinct`
Deduplicates records based on a list of unique columns.
- **Parameters**: Column list.
- **Example**:
  ```bash
  start | distinct server, path
  ```

### `span`
Aggregates metric values into time buckets using DuckDB's `time_bucket(INTERVAL, ts)`.
- **Parameters**: `span [n] <bucket_unit>` (e.g. `month`, `2 week`, `1 hour`).
- **Options**:
  - `--group=COL`: Override default group column.
  - `--vals=COLS`: Override default metrics to sum.
- **Example**:
  ```bash
  start | span 2 week
  ```

---

## 5. Window Operators

### `growth`
Calculates growth metrics of a column across a pivot date boundary. Returns:
- `<col>_start`: Total value before the pivot date.
- `<col>_growth`: Absolute change on or after the pivot date.
- `<col>_end`: Sum total of start and growth values.
- `<col>_rate`: Relative growth rate (`growth / start`).
- **Parameters**: `growth <pivot_date> [col_name] [group_by_col]`
- **Example**:
  ```bash
  start | growth '2025-01-01' size path
  ```

### `acc`
Appends a column representing the running cumulative total of the specified column.
- **Parameters**: `acc <column> [partition_by]`
- **Example**:
  ```bash
  start | span month | acc size server
  ```

### `cumul`
Modernized cumulative running total tracking.
- **Parameters**: `cumul [col]` (defaults to `size`).
- **Options**:
  - `-p PARTITION`: Override partition strategy (`default` propagates current, `none`, or custom).
- **Example**:
  ```bash
  start | span month | cumul size -p server
  ```

---

## 6. Order & Limit Operators

### `order`
Sorts the output rows.
- **Parameters**: `order <column> [direction]` (direction: `ASC` or `DESC`, default `DESC`).
- **Example**:
  ```bash
  start | order size DESC
  ```

### `items`
Limits the number of returned rows.
- **Parameters**: `items <limit>` (default: `40`).
- **Example**:
  ```bash
  start | items 10
  ```

---

## 7. Meta Operators

### `chain`
Recursively applies an operator to a list of arguments, chaining pipes together.
- **Example**:
  ```bash
  # Translates to: ... | acc size | acc cnt
  start | chain acc size cnt
  ```

### `fmt-auto`
Applies format converters (like IEC metric prefix suffix conversions) to JSON outputs on the command line.
- **Example**:
  ```bash
  start | span month | merge-cte | ddb -json | fmt-auto
  ```

[Local Variables:]: :
[indent-tabs-mode: nil]: :
[End:]: :
