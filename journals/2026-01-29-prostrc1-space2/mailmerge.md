<!-- m4_changequote(«,»)m4_changecom() -->

# TOC

<!--
echo '$table-of-contents$' > tmp/toc.md
< ssp.md pandoc -f gfm -t gfm --toc --toc-depth=6 --template tmp/toc.md --columns=196 | grep -v Table.of.Contents
-->

-   [TOC](#toc)
-   [raw](#raw)
-   [Macros](#macros)
-   [id server-path](#id-server-path)
-   [id mk-conf](#id-mk-conf)
-   [id stat-args](#id-stat-args)
-   [id files-stat](#id-files-stat)
-   [macro](#macro)
-   [id var](#id-var)
-   [id get-files-stat](#id-get-files-stat)
-   [id ingest-stat](#id-ingest-stat)
-   [id reduce-stat](#id-reduce-stat)
-   [id merge-db](#id-merge-db)
-   [id table-info](#id-table-info)
-   [id full-db-basic-facts](#id-full-db-basic-facts)
-   [id small-db-basic-facts](#id-small-db-basic-facts)
-   [id query-stat](#id-query-stat)


# raw header

```m4
m4_define(ME,mailmerge)
m4_define(DB,out/mailmerge-small.db)
```

```yml
- { id: null, ns: ME }
- { ky: [ tt ], is: [ nv ] }
```

# id server-path

- Convert NFS client path to NFS server path

```bash
readlink ${1:-/space/applisdata} | xargs readlink
```

```sh
with ssp:server-path | fn-ansible -l profnt[epr]1
```

# id server-path-simple

- Convert NFS client path to NFS server path

```bash
readlink ${1:-/space/applisdata}
```

```sh
with mailmerge:server-path-simple | fn-ansible -l promailmerge1
```

# id mk-conf

- Make a usable conf from server path

```jq
def item: (.stdout_lines[0] / "/") as $path | { client: .node, server: $path[2], path: ([""] + $path[3:] | join("/")) };
INDEX(map(item)[]; .client)
```

```sh
with ssp:server-path | fn-ansible -l profnt[epr]1 | mk-conf > out/conf.js
with mailmerge:server-path-simple | fn-ansible -l promailmerge1 | mk-conf > out/conf.js
```

# id stat-args

- Generate json version of `stat(1)` args

```json
{ "Y": uts, s: size, f: mode, h: nlinks, u: uid, g: gid, U: uname, G: gname }
```

```jq
. / "" | map("%" + . | if . | test("[fUG]") then @json else . end) | join(",") | "[\(.)]"
```

```bash
<<< ${1:-Ysi} self -Rr --argjson js "$js"
```

```sh
stat-args YsifhUG
```

# id files-stat

- No way to get `stat(1)` outputing a correct `json` with arbitrary file names

```perl
BEGIN { $j = JSON::PP->new->utf8 }
chomp;
@s = lstat($_);
next unless @s;
print $j->encode([$s[1], $s[2], $_]), "\n"
```

- But still use it for everythin except path
- Use inode as join key

```bash
(cd ${1:?} && find -type f -print0 |
if [[ "$2" == imn ]]; then perl -MJSON::PP -0 -ne "$perl"; else xargs -0r stat -c "$(stat-args $2)"; fi)
```

```sh
files-stat /usr/share Ysfihug
files-stat /usr/share imn
files-stat /usr/share
```

# macro

```m4
m4_define(JQ,jq "$jq" $@)
m4_define(CONF,out/conf.js)
m4_define(SQL,jq -nr "\"$sql\"" "$«@»")
```

# id var

```jq
getpath($var / ".")
```

```bash
< CONF JQ(-r --arg var ${1:?})
```

# id get-files-stat

```bash
: ${1:?}; local a=${2:-Ysi}; with-lib ME -- files-stat $(var $1.path) $a |
ssh $(var $1.server) bash | gzip > tmp/$1-$a-stat.js.gz
```

```sh
for i in profnt{e,r,p}1; do get-files-stat $i; get-files-stat $i imn; done
```

# id ingest-stat

```sql
CREATE TABLE fsdb AS 
SELECT 
    (imn.json->0)::BIGINT inode,
    to_timestamp((ysi.json->0)::BIGINT) uts,
    (ysi.json->1)::BIGINT size,
    list_filter(string_split(imn.json->>2, '/'), x -> x != '.') path
FROM read_json_auto('\($what)-imn-stat.js.gz') imn
JOIN read_json_auto('\($what)-Ysi-stat.js.gz') ysi 
  ON (imn.json->0)::BIGINT = (ysi.json->2)::BIGINT
```

```bash
(cd tmp; SQL --arg what ${1:?} | duckdb $1.db)
```

```sh
for i in profnt{e,r,p}1; do ingest-stat $i; done
```

# id reduce-stat

```sql
ATTACH '\($src).db' AS src;
CREATE TABLE fsdb AS
SELECT 
    time_bucket(INTERVAL '1 hour', uts) date,
    path[1 : len(path)-1] path,
    count(*) cnt,
    sum(size) size,
    min(size) min,
    max(size) max,
    avg(size) mean
FROM src.fsdb
GROUP BY all ORDER BY date
```

```bash
local ddb=$1-small.db
(cd tmp; rm -f $ddb; SQL --arg src ${1:?} | duckdb $ddb)
```

```sh
for i in profnt{e,r,p}1; do reduce-stat $i; done
reduce-stat profnte1
```

# id merge-db

```jq
def tbl: (. / "-")[0];
$ARGS.positional as $dbs
| ($dbs[] | "ATTACH '\(.).db' AS \(tbl);")
, "CREATE TABLE fsdb AS " + ($dbs | map("SELECT *, '\(tbl)' AS server FROM \(tbl).fsdb") | join(" UNION ALL "))
```

```bash
self -nr --args "$@"
```

```sh
(cd tmp; merge-db profnt{e,p,r}1 | duckdb ssp.db)
(cd out; merge-db profnt-small{e,p,r}1 | duckdb ssp-small.db)
```

# id table-info

```sql
SELECT name AS column_name, type AS column_type FROM pragma_table_info('\($table)')
```

```bash
SQL --arg table ${1:-fsdb}
```

```sh
table-info | duckdb tmp/ssp.db --box
```

# id full-db-basic-facts

```sql
SELECT
  STRFTIME(min(uts), '%Y-%m-%d') AS start,
  STRFTIME(max(uts), '%Y-%m-%d') AS end,
  count(DISTINCT server) AS servers,
  format_bytes(count(*)::BIGINT) AS files,
  format_bytes(sum(size)::BIGINT) AS size
FROM fsdb;

```

```bash
SQL
```

```sh
full-db-basic-facts | duckdb tmp/ssp.db --box
```

# id small-db-basic-facts

```sql
SELECT
  STRFTIME(min(date), '%Y-%m-%d') AS start,
  STRFTIME(max(date), '%Y-%m-%d') AS end,
  format_bytes(count(*)::BIGINT) AS rows,
  count(DISTINCT server) AS servers,
  format_bytes(count(DISTINCT path)) AS dirs,
  format_bytes(sum(cnt)::BIGINT) AS files,
  format_bytes(sum(size)::BIGINT) AS size
FROM fsdb;
```

```bash
SQL
```

```sh
small-db-basic-facts | duckdb out/ssp-small.db --box
```

# id query-stat

```sql
SELECT 
    \($time) as time,
    path[1:\($depth)] as depth,
    sum(cnt) as files,
    sum(size) as bytes,
    min(min) as min_size,
    max(max) as max_size,
    sum(size) / sum(cnt) as avg_size
FROM fsdb
GROUP BY all
ORDER BY time, depth
```

```bash
local depth="${2:-99}"       # Default to deep path
local time="${3:-date}" # Default to existing hourly timestamp

SQL --arg depth "$depth" --arg time "$time" | duckdb DB
```

```sh
day="time_bucket(INTERVAL '1 day', date)"
year="time_bucket(INTERVAL '1 year', date)"
hour='hour(date)'
dow='dayofweek(date)'
query-stat profnte1 2 "$day"
query-stat profnte1 3 "$year"
query-stat profnte1 1 "$hour"
query-stat profnte1 1 "$dow"
```
