<!-- m4_changequote(«,»)m4_changecom() -->

# What is this file

- A minimal starting point for the refactoring of `fsdb`
- Come from journal, to be revamped
- Just here to test Makefile

# raw header

```m4
m4_define(ME,fsdb)
m4_define(DB,tmp/nfsdata-small.db)
```

```yml
- { id: null, ns: ME }
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
m4_define(SQL,jq -nr "\"$sql\"" "$«@»")
```

# id conf-names

- List all conf unique names

```bash
< out/conf.json jq -r .name
```

# id var

- Get var from conf

```bash
< out/conf-by-name.json jq -r --arg var ${1:?} 'getpath($var / ".")'
```

# id get-files-stat

```bash
: ${1:?}; local a=${2:-Ysi}; with-lib ME -- files-stat $(var $1.dir) $a |
ssh $(var $1.node) -l root bash | gzip > tmp/$(var $1.name)-$a-stat.js.gz
```

```sh
get-files-stat prestr1-data-nfsdata; get-files-stat prestr1-data-nfsdata imn
for i in $(conf-names); do get-files-stat $i; get-files-stat $i imn; done
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
ingest-stat prestr1-data-nfsdata
for i in $(conf-names); do ingest-stat $i; done
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
reduce-stat prestr1-data-nfsdata
for i in $(conf-names); do reduce-stat $i; done
```

# id merge-db

```jq
def tbl: . / "-" | join("_");
$ARGS.positional as $dbs
| ($dbs[] | "ATTACH '\(.).db' AS \(tbl);")
, "CREATE TABLE fsdb AS " + ($dbs | map("SELECT *, '\(tbl)' AS server FROM \(tbl).fsdb") | join(" UNION ALL "))
```

```bash
self -nr --args "$@"
```

```sh
(names=($(conf-names)); cd tmp; merge-db ${names[@]} | duckdb nfsdata.db)
(names=($(conf-names)); cd tmp; merge-db ${names[@]/%/-small} | duckdb nfsdata-small.db)
(cd out; merge-db profnt-small{e,p,r}1 | duckdb ssp-small.db)
```

[Local Variables:]::
[indent-tabs-mode: nil]::
[End:]::
