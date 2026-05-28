# FSDB Architecture

FSDB (File System Data Base) is a lightweight, DuckDB-backed file system metadata analyzer. It ingests file system states, indexes metadata into a relational schema, and enables declarative pipeline queries using parameterized SQL Common Table Expressions (CTEs) compiled via `baj`.

## System Overview

```mermaid
graph TD
    A[File System] -->|find & stat/perl| B[Metadata Extraction: *.js.gz]
    B -->|ingest-stat| C[Raw DuckDB: *.db]
    C -->|reduce-stat| D[Hourly Reduced DB: *-small.db]
    D -->|merge-db| E[Merged Multi-Server DB]
    E -->|Exploration Pipeline: start | growth | ddb| F[Analysis Output]
```

## Schema Definitions

### 1. Raw Schema (`ingest-stat`)
The raw table contains file-level metadata records.

| Column | Type | Description |
| :--- | :--- | :--- |
| `inode` | `BIGINT` | Inode number (primary join key) |
| `uts` | `TIMESTAMP` | File modification time |
| `size` | `BIGINT` | File size in bytes |
| `path` | `VARCHAR[]` | Tokenized file path split by `/` with `.` excluded |

### 2. Hourly Reduced Schema (`reduce-stat`)
To make visualization and historical querying scalable, file-level records are aggregated into hourly buckets and grouped by their parent directory path.

| Column | Type | Description |
| :--- | :--- | :--- |
| `date` | `TIMESTAMP WITH TIME ZONE` | Hourly time-bucket of `uts` |
| `path` | `VARCHAR[]` | Tokenized parent directory path (`path[1 : len(path)-1]`) |
| `cnt` | `BIGINT` | Count of files modified during the hour under the path |
| `size` | `INT128` | Total size of files modified during the hour |
| `min` | `BIGINT` | Minimum file size seen during the hour |
| `max` | `BIGINT` | Maximum file size seen during the hour |
| `mean` | `DOUBLE` | Average file size during the hour |

### 3. Merged Schema (`merge-db`)
Unions multiple reduced databases to facilitate cross-server analysis.

| Column | Type | Description |
| :--- | :--- | :--- |
| `date` | `TIMESTAMP WITH TIME ZONE` | Hourly timestamp |
| `path` | `VARCHAR[]` | Parent directory path segments |
| `cnt` | `BIGINT` | File count |
| `size` | `INT128` | Combined size |
| `min` | `BIGINT` | Minimum size |
| `max` | `BIGINT` | Maximum size |
| `mean` | `DOUBLE` | Mean size |
| `server` | `VARCHAR` | Identifier of the originating database / server (e.g. `profnt_small_e1`) |

---

## Processing Pipeline & Compilation Model

### Extraction Phase
Metadata extraction splits target gathering into two compressed files to prevent escaping and quoting bugs with special characters (spaces, tabs, newlines) in filenames:
- **`imn` (`[inode, mode, path]` in JSON array)**: Handled by a perl helper using `lstat` for robust unicode and path preservation.
- **`Ysi` (`[uts, size, inode]` in JSON array)**: Standard fast GNU `stat` output.

### Ingestion & Reduction
1. **`ingest-stat`**: Reads compressed JSON arrays, joins records on `inode`, and creates the raw `fsdb` table.
2. **`reduce-stat`**: Groups files by parent directory path and rolls timestamps into hourly time buckets.
3. **`merge-db`**: Chains multiple DuckDB files together via `UNION ALL` and injects a `server` column identifier.

### pipeline Execution
Pipelines are defined as chained bash commands compiling into a single query via `merge-cte`.
- The compilation uses a **channel format** where each step produces a JSON block containing `{a: ARGS, q: SQL}`.
- Arguments like timestamp alias (`ts`), path alias (`file`), aggregation metrics (`vals`), and partition identifiers (`part`) propagate sequentially.
- Steps translate into chained CTE steps (`step0`, `step1`, etc.), replacing `{prev}` placeholders dynamically.

[Local Variables:]: :
[indent-tabs-mode: nil]: :
[End:]: :
