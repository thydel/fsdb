# Plan: Rethink CTE operator library

## Context

The current `fsdb-cte.md` (737 lines) has ~20 working CTE operators
but uses a flat `["SQL1", "SQL2"]` array format with hardcoded column
names (`date`, `server`, `cnt,size`). The CLAUDE.md step "See CTE"
asks for a channel-based format `[{ args: {}, cte: SQL }]` that
propagates metadata (column aliases) through the pipeline, plus a
cleaner API (`span month` instead of `span --bucket=month`).

## Core design change: channel format

### Element schema

Each pipeline element becomes:

```json
{ "a": { "ts": "date", "file": "path", "tbl": "fsdb", "vals": "cnt,size", "part": "server" },
  "q": "SELECT * FROM {prev} WHERE ..." }
```

| Key | Default | Purpose |
|-----|---------|---------|
| `ts` | `date` | Timestamp column |
| `file` | `path` | File/path column |
| `tbl` | `fsdb` | Source table |
| `vals` | `cnt,size` | Default numeric columns for sum/span |
| `part` | `server` | Default partition column for window ops |

### How it works

- `start` creates the first element with args initialized from
  defaults or `--key=value` overrides
- `sql` helper wraps SQL in `{a: $_a, q: SQL}` and makes `$_a`
  available inside jq string templates
- Operators like `last`, `span`, `growth` use `\($_a.ts)` instead of
  hardcoded `date`
- Operators that don't need channel args (like `keep`, `where`) work
  unchanged
- `merge-cte` extracts `.q` from each element for SQL assembly

### Key mechanism: `sql` helper

```bash
# New:
jq '((.[-1].a) // {}) as $_a | . + [{a: $_a, q: '"\"$sql\""'}]' "$@"
```

Since `$_a` is a jq variable binding, SQL templates can optionally
reference `\($_a.ts)`, `\($_a.part)`, `\($_a.vals)`. Templates that
don't need channel args just ignore `$_a`.

## Operator set

### Source (1)

| Op | Syntax | Notes |
|----|--------|-------|
| `start` | `start [TBL] [--ts=COL] [--file=COL] [--vals=COLS] [--part=COL]` | Initializes channel |

### Filter (7)

| Op | Syntax | SQL pattern |
|----|--------|-------------|
| `where` | `where EXPR...` | `WHERE EXPR` |
| `is` | `is COL VAL` | via `where COL = 'VAL'` |
| `like` | `like COL PAT` | via `where COL LIKE 'PAT'` |
| `last` | `last N UNIT` | `WHERE $_a.ts >= now() - INTERVAL N UNIT` |
| `first` | `first N UNIT` | `WHERE $_a.ts <= MIN($_a.ts) + INTERVAL N UNIT` **NEW** |
| `since` | `since DATE` | `WHERE $_a.ts >= 'DATE'` **NEW** |
| `until` | `until DATE` | `WHERE $_a.ts < 'DATE'` **NEW** |

### Map (6)

| Op | Syntax | Notes |
|----|--------|-------|
| `keep` | `keep COL...` | Projection |
| `hide` | `hide COL...` | Exclusion (replaces `del`) |
| `rename` | `rename OLD NEW` | Column rename **NEW** |
| `human` | `human [--b=2\|10] COL...` | Human-readable sizes |
| `fmt` | `fmt COL...` | Thousand separators |
| `pct` | `pct COL...` | Ratio to percentage |

### Aggregate (5)

| Op | Syntax | Notes |
|----|--------|-------|
| `sum` | `sum GROUP [COLS]` | Uses `$_a.vals` as default for COLS |
| `count` | `count [EXPR]` | Scalar count |
| `grpcnt` | `grpcnt GROUP` | Grouped count |
| `distinct` | `distinct COL...` | Deduplication |
| `span` | `span [N] BUCKET` | Positional API: `span month`, `span 2 week` |

### Window (2)

| Op | Syntax | Notes |
|----|--------|-------|
| `growth` | `growth COL [PART]` | Uses `$_a.ts` for ORDER BY, `$_a.part` default |
| `acc` | `acc COL [PART]` | Running total, uses `$_a.ts`, `$_a.part` |

### Order/Limit (2)

| Op | Syntax | Notes |
|----|--------|-------|
| `order` | `order COL [DIR]` | Sort (default DESC) |
| `items` | `items [N]` | Renamed from `limit` |

### Meta (3)

| Op | Notes |
|----|-------|
| `sql` | Internal: append SQL to channel |
| `merge-cte` | Assemble channel into final SQL |
| `chain` | Apply command to list of args recursively |

### Post-process (1)

| Op | Notes |
|----|-------|
| `fmt-auto` | jq-based IEC formatting of JSON output |

## API cleanup

```bash
# Old
start | last 6 month | span --bucket=month | growth size | limit 20

# New
start | last 6 month | span month | growth size | items 20
```

`span` becomes positional: `span month` (1 arg = bucket), `span 2
week` (2 args = n + bucket). Overrides still available via
`--group=COL`, `--vals=COLS`.

## Removals and moves

- **Remove** `del` (duplicate of `hide`)
- **Remove** `limit` (replaced by `items`)
- **Move** `latest-growth` to `fsdb-pipes.md`

## File changes

### `fsdb-cte.md` — rewrite

Structure:
1. Header: m4 preamble, namespace, macros
2. Channel infrastructure: `sql`, `start`, `merge-cte`
3. Filter: `where`, `is`, `like`, `last`, `first`, `since`, `until`
4. Map: `keep`, `hide`, `rename`, `human`, `fmt`, `pct`
5. Aggregate: `sum`, `count`, `grpcnt`, `distinct`, `span`
6. Window: `growth`, `acc`
7. Order/Limit: `order`, `items`
8. Meta: `chain`, `fmt-auto`

### `fsdb-pipes.md` — populate

Structure:
1. Header (same `fsdb` namespace)
2. `latest-growth` (moved from fsdb-cte.md)

## Verification

1. Build with `make` (once Makefile exists) to confirm baj compilation
2. Test channel propagation: `start | merge-cte` should produce
   `WITH step0 AS (FROM fsdb) SELECT * FROM step0`
3. Test column override: `start --ts=uts | last 6 month | merge-cte`
   should produce SQL using `uts` not `date`
4. Test clean API: `start | span month | merge-cte` should produce
   valid `time_bucket` SQL

[Local Variables:]::
[indent-tabs-mode: nil]::
[End:]::
