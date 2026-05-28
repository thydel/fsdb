# Ingestion & Testing Guide

This guide details the ingestion pipeline architecture and the strategy for automated verification of database queries and CTE operations.

---

## 1. Ingestion Pipelines

### Current Ingestion Flow
Raw directory crawl results are collected in two parts:
1. **`imn-stat`**: Outputs `[inode, octal_mode, path]` for each file to ensure safe Unicode path handling without quotes/spaces breakages.
2. **`Ysi-stat`**: Outputs standard file attributes `[uts, size, inode]`.

These two streams are joined on `inode` by DuckDB using the JSON extension during the `ingest-stat` step.

### Revamped JSON Ingestion (Proposed)
To simplify the process and reduce dependency on raw shell parsing and intermediate joins:
1. A Python script (`scripts/stat-to-json.py`) crawls directories recursively and extracts file stat metadata directly using standard OS system libraries.
2. It outputs structured JSON Lines (JSONL) with the unified schema:
   ```json
   {"inode": 123456, "uts": 1780000000, "size": 1024, "path": ["usr", "share", "doc"]}
   ```
3. DuckDB loads this file directly using `read_json_auto`:
   ```sql
   CREATE TABLE fsdb AS SELECT * FROM read_json_auto('file_stats.json');
   ```

---

## 2. Testing Framework

To ensure that both the compilation engine (`baj`) and individual SQL CTE operators (such as `growth` or `span`) are 100% correct, a local test suite is established.

### Static Test DB Setup
The test suite operates on a static snapshot of the `cpython-v3.14.5` repository, generating a reproducible DuckDB file tree database.

1. **Test Fixtures Directory**: `test/fixtures/cpython-v3.14.5`
2. **Database Generation**:
   ```bash
   # Generates test/fixtures/cpython.db
   make test-db
   ```

### Running Test Assertions
Assertions evaluate pipeline outputs against static target snapshots. Tests are located in the `test/` directory.

- **Check CTE Pipelines**: Compare output datasets (e.g., outputs of `start | growth '2025-01-01'`) against predefined CSV baseline outputs.
- **Run the Suite**:
   ```bash
   ./test/run.sh
   ```

### Adding a Test Case
To verify a new CTE, add a corresponding script under `test/`:
1. Define the test query using standard CTE syntax (e.g., `start | your-cte | merge-cte`).
2. Run the query and save the expected output to `test/expected/<test_name>.csv`.
3. The runner will execute your query against `test/fixtures/cpython.db` and assert no diff exists between runtime results and the expected CSV.

[Local Variables:]: :
[indent-tabs-mode: nil]: :
[End:]: :
