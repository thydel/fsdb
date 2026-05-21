- Next step is to offer better integrated *fsdb pipe* (adding new *fsdb CTE* if needed) to the target audience.
- The main goal is to undertand current disk ressource usage, historical trend and anticipate time of future "disk full" problems.
- To that I see some missing tools
  - Graphical display (either via DDB) or external ligth and simple tool
  - Determine if a subset of file (by space (node, path) and time) is monotically growing (no files deletion) or not
  - Determine the slope of a growth and then (given a added capacity of the disk space of the subset) the date of out-of-space

Analyze and comment. No code yet.

```text
 Evaluating Tool Integration
  ### 1. Graphical Display
  
  • Terminal-based ( youplot ): Since /usr/local/bin/youplot is
    already installed on your workstation, we can define
    terminal-level formatting pipes (e.g., plot-bar , plot-line ) that
    pipe DuckDB CSV outputs directly to youplot bar or youplot line .

  • SQL-native ASCII bars: We can add a map operator (e.g., bar )
    inside fsdb-cte.md using DuckDB's repeat() function: repeat('█',
    ((size / max_size) * 20)::int) This offers zero-dependency, inline
    visualization directly inside the terminal box output.
  
  ### 2. Monotonicity & Deletion Tracking
  
  • Leveraging Ghost Rows: Since the ingestion pipeline inserts ghost
    rows ( size IS NULL ) via mark-deleted when files are removed, we
    can easily track deletion events.

  • CTE Operator ( check-monotonic ): We can introduce an operator
    that scans the selected subset (path, node, time range) and
    aggregates:
      • Deletion counts:  COUNT(*) FILTER (WHERE size IS NULL) 
      • Negative size deltas between snapshots.
      • An output flag is_monotonic (true if deletions = 0 and size
        growth rate is always $\ge 0$).

  ### 3. Growth Slope & Out-of-Space Forecasting
  
  • Mathematical Approach: We can use DuckDB's built-in linear
    regression functions regr_slope(size, epoch(date)) and
    regr_intercept(size, epoch(date)) calculated over a defined
    historical window (e.g., last 3 months).
  • Forecasting Operator ( forecast <capacity> ):
      • Daily Growth Rate ($m$): Derived from  regr_slope  (converted to bytes/day).
      • Remaining Capacity ($R$): Target capacity $C$ minus current size $S_{curr}$.
      • Days to Full ($D$): $R / m$.
      • Estimated Full Date:  now() + INTERVAL (R / m) DAY .
      • The operator will output the current usage, estimated daily
        slope (in human-readable bytes/day), and the forecasted
        exhaustion timestamp.
```

- There is a confusion here
  - Some files in `journals/` refer to an alternative implementation
    dedicated to file set with changing file size (.e.g. /var/mysql)
  - The current work is upon `fsdb-*.md` (the source as MD -> YML ->
    .sh (via baj) implementation for essentially only add never
    changing files (rarely delete on some subsets) for which we want
    to reconstruct history (and slope) from the DB of mainly size and
    posix mtime

```text
  Clarifying the Core Model

  Acknowledged. Under the single-snapshot reconstruction model, we
  rely purely on the mdate (POSIX mtime) of currently existing files
  as a proxy for their birth date, rather than tracking state
  transitions over multiple database snapshots.
  
  ### 1. Reconstructing History from mtime
  
  • Cumulative History: Historical growth is reconstructed by grouping
  existing files by mdate (e.g., bucketed by month) and calculating a
  cumulative sum ( sum(size) over (order by mdate_bucket) ).
  
  ### 2. Identifying Monotonicity (Detecting Deletions Heuristically)
  
  Because deleted files are absent from a single snapshot, we cannot
  directly measure deletions. However, we can infer deletion/rotation
  behavior:
  
  • Retention Window Truncation: If a system/directory is known to be
   old, but the oldest mdate in the database is recent (e.g., exactly
   30 or 90 days old), we can infer a deletion or rotation policy
   (like log rotation or cache pruning).

  • Artificial Growth Curve: In a subset with active deletions (like a
    rolling buffer), the reconstructed cumulative curve will show a
    false "recent growth spike" starting from the oldest remaining
    file's mdate to the present. In a truly monotonic subset, the
    curve will span the entire lifetime of the path with continuous,
    non-truncated distribution.
  
  ### 3. Slope & Forecasting on Reconstructed Curves
  
  • Slope Calculation: For monotonic subsets (where the reconstructed
    curve represents the true history), we compute the daily slope of
    the cumulative size over time using linear regression (
    regr_slope(cumulative_size, epoch(mdate)) ).

  • Forecasting: Given current size $S_{curr}$ and limit $C$,
    remaining space $R = C - S_{curr}$ is projected using the daily
    slope to forecast the "disk full" date.
```

- Add a `fsdb-cte-agy.md` nodelled on `fsdb-cte.md` with a func to plot size or cnt

- I think you must examine baj/parsarg.md more carefully
- Also look at start CTE
- The point of parsarg is to allow use of opts without a-la getopt spec
- But using it to treat 3 args with default value is useless (.i.e you
  can't change default values of more than one arg but you can change
  default value of named arg (aka opt)


- Without ordering plot is not very useful, and be careful not to output too many data lines
- Also, this is not very better than pure DDB implementation
- Add an alternative pure DDB version (same vertical plot)
- Propose a simple (ideally apt available) more capabel plotter (horizontal plot)
- Examine available CTE to provide more usesul example

```text
thy@tdews1-256g:~/usr/hub/work/ext/fsdb$ start | last 1 year | like server prot3stra1% | span month | order date asc | plot
                                            size
                          ┌                                        ┐ 
   2025-05-01 02:00:00+02 ┤■■■■■ 33270029563.0                       
   2025-06-01 02:00:00+02 ┤■■■■■■■■■■■■■■■■■■ 121890686954.0         
   2025-07-01 02:00:00+02 ┤■■■■■■■■■■■■■■ 99147900346.0              
   2025-08-01 02:00:00+02 ┤■■■■■■■■■■■ 78615698409.0                 
   2025-09-01 02:00:00+02 ┤■■■■■■■■■■■■■■■ 104086572257.0            
   2025-10-01 02:00:00+02 ┤■■■■■■■■■■■■■■■■■■ 125195486145.0         
   2025-11-01 01:00:00+01 ┤■■■■■■■■■■■■■■■■ 113238107060.0           
   2025-12-01 01:00:00+01 ┤■■■■■■■■■■■■■■■■■ 117502743011.0          
   2026-01-01 01:00:00+01 ┤■■■■■■■■■■■■■■■■■■ 122626437237.0         
   2026-02-01 01:00:00+01 ┤■■■■■■■■■■■■■■■■■■■ 131879225527.0        
   2026-03-01 01:00:00+01 ┤■■■■■■■■■■■■■■■■■■■■■■■■ 166800288584.0   
   2026-04-01 02:00:00+02 ┤■■■■■■■■■■■■■■■■■■■■■■ 153209242748.0     
   2026-05-01 02:00:00+02 ┤■■■■ 29070492771.0                        
   └                                        ┘
```
