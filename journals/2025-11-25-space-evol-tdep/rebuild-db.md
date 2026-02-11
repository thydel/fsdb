# Add lib build DB

- Start back from [2025-11-05 Space-evol-tdep][]
- Add [tdep.yml][]

```bash
load tdep.yml
```

# Use lib

## Extract data from links

```bash
mk-links
```

- [out/appli-split.js][]

## Get stat from data

```bash
mk-stats
```

---

```console
thy@tdews1-256g:2025-11-25-space-evol-tdep$ time mk-stats -j8
with-lib tdep -- stats $(< out/appli-split.js var budi.path)/budi | ssh $(< out/appli-split.js var budi.node) -l root bash | gzip > tmp/budi.gz
with-lib tdep -- stats $(< out/appli-split.js var cedric.path)/cedric | ssh $(< out/appli-split.js var cedric.node) -l root bash | gzip > tmp/cedric.gz
...
with-lib tdep -- stats $(< out/appli-split.js var voo4bcm-copy.path)/voo4bcm-copy | ssh $(< out/appli-split.js var voo4bcm-copy.node) -l root bash | gzip > tmp/voo4bcm-copy.gz
with-lib tdep -- stats $(< out/appli-split.js var voo4bcm-copy-bfc.path)/voo4bcm-copy-bfc | ssh $(< out/appli-split.js var voo4bcm-copy-bfc.node) -l root bash | gzip > tmp/voo4bcm-copy-bfc.gz

real	5m35.275s
user	1m43.134s
sys	0m9.227s
```

## Make one DB per appli from stat

```bash
mk-tables table=stat
```

## Adds `clienr`, `appli`, `split`, `node`, and `path` to all DB

```bash
add-cols-to-all-dbs
```

## Backup previous DB

```bash
backup-db | dash
```

## Merge all DB

```bash
merge-all-dbs
```

## Make hours DB

```bash
backup-db out/tdep-hours.db | dash
hourly-db | duckdb tmp/tdep.db
```

## Make a CSV dump

```bash
duckdb out/tdep-hours.db --csv -c 'select * from hours' | gzip > out/tdep-hours.csv.gz
```

## Copy latest vserion on `work1`

```bash
rsync -a tmp/tdep.db out/tdep-hours.db work1:
ssh work1 -l root install -o www-data -g www-data -m 644 -p /home/thy/tdep{,-hours}.db /space2/duckdb 
```
