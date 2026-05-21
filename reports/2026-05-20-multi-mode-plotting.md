# Plan: Multi-Mode Plotting Operator

We will expand the `plot` operator in `fsdb-cte-agy.md` to support multiple terminal rendering modes:
1. `youplot` (default): Vertical terminal plot using `youplot` (bar/line).
2. `ddb` (pure DuckDB): Vertical ASCII bar chart using DuckDB's `repeat` string function (zero external dependencies).
3. `gnuplot` (horizontal plot): Horizontal datetime line chart using `gnuplot`'s `set term dumb` terminal rendering.

We will use the short option `-m` to specify the mode: `-m youplot`, `-m ddb`, or `-m gnuplot`.

## Proposed Changes

### Component: fsdb-cte-agy

#### [MODIFY] [fsdb-cte-agy.md](file:///home/thy/usr/hub/work/ext/fsdb/fsdb-cte-agy.md)
Update the `plot` operator to:
1. Parse `-m` for plotting mode (options: `youplot`, `ddb`, `gnuplot`).
2. Implement a dynamic JQ condition in the `sql` block to generate different projection logic based on the selected mode:
   - For `ddb`: Computes vertical bars using `repeat('█', ...)` scaled against the maximum size.
   - For `gnuplot`: Formats `\($_a.ts)` using `strftime` to strip timezones, preparing clean datetime strings for `gnuplot`.
   - For `youplot`: Formats raw date and column selection.
3. Update the `bash` block of the `plot` operator to execute the appropriate terminal pipeline based on the mode:
   - `ddb`: Outputs `-box` representation.
   - `gnuplot`: Uses `set xdata time` and parses datetime CSV format.
   - `youplot`: Pipes CSV data to `youplot`.
4. Document all modes with detailed examples.

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

# Test 1: Pure DuckDB plot
start | last 1 year | like server prot3stra1% | span month | plot -m ddb -d tmp/nfsdata-small.db

# Test 2: Gnuplot line graph
start | last 1 year | like server prot3stra1% | span month | plot -m gnuplot -d tmp/nfsdata-small.db
```
Confirm both print correctly formatted text plots.
