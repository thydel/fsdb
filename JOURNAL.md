<!--
echo '$table-of-contents$' > tmp/toc.md
< JOURNAL.md pandoc -f gfm -t gfm --toc --toc-depth=6 --template tmp/toc.md --columns=196 | grep -v Table.of.Contents
-->

-   [Make it like home](#make-it-like-home)
    -   [`/usr/local/bin`](#usrlocalbin)
    -   [`baj`](#baj)
    -   [`rust`](#rust)
    -   [`mdq`](#mdq)
    -   [`duckdb`](#duckdb)
    -   [`gnupg`](#gnupg)
-   [Generate yml from MD](#generate-yml-from-md)
-   [Load lib](#load-lib)
-   [Get list of node with a `/data`](#get-list-of-node-with-a-data)
-   [Use `/space`](#use-space)
-   [Get files stat for all `nfsdata`](#get-files-stat-for-all-nfsdata)
-   [Ingest stat](#ingest-stat)
-   [Make a reduced version of all DB](#make-a-reduced-version-of-all-db)
-   [Found a problem](#found-a-problem)
    -   [Kernel log](#kernel-log)
    -   [Broken DB](#broken-db)
-   [Fix it](#fix-it)
    -   [Install older `duckdb` version](#install-older-duckdb-version)
-   [Rebuild everything](#rebuild-everything)
    -   [Get files stat for all `nfsdata`](#get-files-stat-for-all-nfsdata-1)
-   [Ingest stat](#ingest-stat-1)
-   [Make a reduced version of all DB](#make-a-reduced-version-of-all-db-1)
-   [And concatenate all DB](#and-concatenate-all-db)
-   [Keep it `tmp` (don't commit)](#keep-it-tmp-dont-commit)
-   [Add misc funcs](#add-misc-funcs)
-   [Show minimal facts](#show-minimal-facts)
-   [Here is the previous state from 3 months ago](#here-is-the-previous-state-from-3-months-ago)
-   [More basic info and usage exemple](#more-basic-info-and-usage-exemple)
    -   [The big DB](#the-big-db)
    -   [The small one](#the-small-one)
-   [Try CTE](#try-cte)
    -   [First try](#first-try)
    -   [More tries](#more-tries)
-   [Try some exploration](#try-some-exploration)
    -   [Copy DB from `controla2`](#copy-db-from-controla2)
    -   [Look for recent `DF_HIGH_SPACE`](#look-for-recent-df_high_space)
        -   [`prot1strb1`](#prot1strb1)
            -   [Pseudo `df`](#pseudo-df)
            -   [On subdir on top dir](#on-subdir-on-top-dir)
            -   [By time span on a dir](#by-time-span-on-a-dir)
                -   [`ssp_ndf` By month since 2025](#ssp_ndf-by-month-since-2025)
                -   [`ssp` By year since 2018](#ssp-by-year-since-2018)
        -   [`prostrc1`](#prostrc1)
            -   [Pseudo `df`](#pseudo-df-1)
                -   [`ssp` By year since 2018](#ssp-by-year-since-2018-1)
                -   [`ssp` By month since 2025](#ssp-by-month-since-2025)

# Make it like home

## `/usr/local/bin`

```bash
d=/usr/local/bin
chgrp adm $d
chmod g+w $d
```

## `baj`

```bash
make -C ../baj install -n
```

## `rust`

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
. "$HOME/.cargo/env"
```

## `mdq`

```bash
cargo install --git https://github.com/yshavit/mdq
```

## `duckdb`

```bash
v=v1.5.2
u=https://github.com/duckdb/duckdb/releases/download/$v/duckdb_cli-linux-amd64.gz
curl -sL $u | zcat | install /dev/stdin /usr/local/bin/duckdb
```

## `gnupg`

```bash
ssh -a controla1:.gnupg .
sudo aptitude install pinentry-tty
```

# Generate yml from MD

```bash
make
```

# Load lib

```bash
source baj.sh
load out/fsdb-build.yml
```

# Get list of node with a `/data`

```bash
f () { ls -d /*/nfsdata; }
r () { declare -f $1; echo $@; }
source ../baj/cmd/baj-ansible.sh
jq='.[] | select(.rc == 0) | .stdout_lines[] as $dir'
jq+=' | ((.node + $dir) / "/" | join("-")) as $name | { node, $dir, $name }'
r f | fn-ansible -l g_data | jq "$jq" -c > out/conf.json
< out/conf.json jq -s 'INDEX(.[]; .name)' > out/conf-by-name.json
```

- [out/conf.json][]
- [out/conf-by-name.json][]

# Use `/space`

```bash
d=~/Work/fsdb/tmp
mkdir -p $d
ln -nfs $d
```

# Get files stat for all `nfsdata`

```bash
for i in $(conf-names); do get-files-stat $i; get-files-stat $i imn; done
```

# Ingest stat

- Edit [fsdb-build.md][] for [Fixes deprecation][]

```bash
for i in $(conf-names); do ingest-stat $i; done
```

[Fixes deprecation]:
    https://github.com/thydel/fsdb/commit/319b0e149ae2136095dc5bbdef2fe61c6a745da3
    "github.com commit"

[fsdb-build.md]:
    https://github.com/thydel/fsdb/blob/tmp/fsdb-build.md
    "github.com file"

# Make a reduced version of all DB

```bash
for i in $(conf-names); do reduce-stat $i; done
```

# Found a problem

## Kernel log

```console
thy@controla2:~/usr/fsdb$ grep duckdb /var/log/kern.log
May  7 20:34:05 controla2 kernel: traps: duckdb[1645608] trap divide error ip:894cc7 sp:7ffc02c8dd00 error:0 in duckdb[421000+235a000]
May  7 20:34:11 controla2 kernel: traps: duckdb[1645633] trap divide error ip:894cc7 sp:7ffe517cf6b0 error:0 in duckdb[421000+235a000]
May  7 20:34:17 controla2 kernel: traps: duckdb[1645658] trap divide error ip:894cc7 sp:7ffc6a4e6140 error:0 in duckdb[421000+235a000]
May  7 20:34:21 controla2 kernel: traps: duckdb[1645669] trap divide error ip:894cc7 sp:7ffd88615d30 error:0 in duckdb[421000+235a000]
May  7 20:34:25 controla2 kernel: traps: duckdb[1645681] trap divide error ip:894cc7 sp:7ffd58283710 error:0 in duckdb[421000+235a000]
May  7 20:34:29 controla2 kernel: traps: duckdb[1645695] trap divide error ip:894cc7 sp:7ffde297bfe0 error:0 in duckdb[421000+235a000]
May  7 20:34:35 controla2 kernel: traps: duckdb[1645729] trap divide error ip:894cc7 sp:7ffc68ffaa20 error:0 in duckdb[421000+235a000]
May  7 22:55:51 controla2 kernel: traps: duckdb[1676603] trap divide error ip:894cc7 sp:7ffed3332d90 error:0 in duckdb[421000+235a000]
May  7 22:56:54 controla2 kernel: traps: duckdb[1676671] trap divide error ip:894cc7 sp:7fff6cf34f70 error:0 in duckdb[421000+235a000]
```

## Broken DB

```console
thy@controla2:~/usr/fsdb/tmp$ sql="SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='main' AND table_name='fsdb')"
thy@controla2:~/usr/fsdb/tmp$ for i in *.db; do echo -n $i ''; duckdb -json $i "$sql"; done | cat
prestr1-data-nfsdata.db [{"EXISTS(SELECT 1 FROM information_schema.\"tables\" WHERE ((table_schema = 'main') AND (table_name = 'fsdb')))":"true"}]
profwkstra1-data-nfsdata.db [{"EXISTS(SELECT 1 FROM information_schema.\"tables\" WHERE ((table_schema = 'main') AND (table_name = 'fsdb')))":"true"}]
profwkstrb1-data-nfsdata.db [{"EXISTS(SELECT 1 FROM information_schema.\"tables\" WHERE ((table_schema = 'main') AND (table_name = 'fsdb')))":"false"}]
prostra1-data-nfsdata.db [{"EXISTS(SELECT 1 FROM information_schema.\"tables\" WHERE ((table_schema = 'main') AND (table_name = 'fsdb')))":"true"}]
prostrb2-data-nfsdata.db [{"EXISTS(SELECT 1 FROM information_schema.\"tables\" WHERE ((table_schema = 'main') AND (table_name = 'fsdb')))":"false"}]
prot1stra1-data-nfsdata.db [{"EXISTS(SELECT 1 FROM information_schema.\"tables\" WHERE ((table_schema = 'main') AND (table_name = 'fsdb')))":"true"}]
prot1strb1-data-nfsdata.db [{"EXISTS(SELECT 1 FROM information_schema.\"tables\" WHERE ((table_schema = 'main') AND (table_name = 'fsdb')))":"false"}]
prot1strc1-data-nfsdata.db [{"EXISTS(SELECT 1 FROM information_schema.\"tables\" WHERE ((table_schema = 'main') AND (table_name = 'fsdb')))":"false"}]
prot3stra1-data-nfsdata.db [{"EXISTS(SELECT 1 FROM information_schema.\"tables\" WHERE ((table_schema = 'main') AND (table_name = 'fsdb')))":"false"}]
protpstra1-data-nfsdata.db [{"EXISTS(SELECT 1 FROM information_schema.\"tables\" WHERE ((table_schema = 'main') AND (table_name = 'fsdb')))":"false"}]
protpstrb1-data-nfsdata.db [{"EXISTS(SELECT 1 FROM information_schema.\"tables\" WHERE ((table_schema = 'main') AND (table_name = 'fsdb')))":"true"}]
protpstrc1-data-nfsdata.db [{"EXISTS(SELECT 1 FROM information_schema.\"tables\" WHERE ((table_schema = 'main') AND (table_name = 'fsdb')))":"true"}]
protpstrd1-data-nfsdata.db [{"EXISTS(SELECT 1 FROM information_schema.\"tables\" WHERE ((table_schema = 'main') AND (table_name = 'fsdb')))":"false"}]
protpstre1-data-nfsdata.db [{"EXISTS(SELECT 1 FROM information_schema.\"tables\" WHERE ((table_schema = 'main') AND (table_name = 'fsdb')))":"true"}]
protpstrf1-data-nfsdata.db [{"EXISTS(SELECT 1 FROM information_schema.\"tables\" WHERE ((table_schema = 'main') AND (table_name = 'fsdb')))":"true"}]
```

# Fix it

## Install older `duckdb` version

- Same than the one thart worked on my WS

```bash
v=v1.5.2
mv /usr/local/bin/duckdb{,-$v}
v=v1.4.1
u=https://github.com/duckdb/duckdb/releases/download/$v/duckdb_cli-linux-amd64.gz
curl -sL $u | zcat | install /dev/stdin /usr/local/bin/duckdb-$v
proot -w /usr/local/bin ln -s duckdb{-$v,}
```

- No more `trap divide error`
- Use latest `1.4`

```bash
v=v1.4.4
u=https://github.com/duckdb/duckdb/releases/download/$v/duckdb_cli-linux-amd64.gz
curl -sL $u | zcat | install /dev/stdin /usr/local/bin/duckdb-$v
proot -w /usr/local/bin ln -nfs duckdb{-$v,}
```

# Rebuild everything

## Get files stat for all `nfsdata`

- Not this part, but keep all steps in section

```bash
for i in $(conf-names); do get-files-stat $i; get-files-stat $i imn; done
```

# Ingest stat

```bash
rm tmp/*.db
for i in $(conf-names); do ingest-stat $i; done
```

# Make a reduced version of all DB

```bash
for i in $(conf-names); do reduce-stat $i; done
```

# And concatenate all DB

```bash
(names=($(conf-names)); cd tmp; merge-db ${names[@]} | duckdb nfsdata.db)
(names=($(conf-names)); cd tmp; merge-db ${names[@]/%/-small} | duckdb nfsdata-small.db)
```

# Keep it `tmp` (don't commit)

```console
thy@controla2:~/usr/fsdb$ ls -lsh tmp/nfsdata{,-small}.db
1.9G -rw-r--r-- 1 thy thy 1.9G May 10 18:21 tmp/nfsdata.db
268M -rw-r--r-- 1 thy thy 268M May 10 18:21 tmp/nfsdata-small.db
thy@controla2:~/usr/fsdb$ <<< "select count(*) from fsdb" duckdb tmp/nfsdata.db -line
count_star() = 44209960
thy@controla2:~/usr/fsdb$ <<< "select count(*) from fsdb" duckdb tmp/nfsdata-small.db -line
count_star() = 11438727
```

# Add misc funcs


- Adds [fsdb-misc.md][] and edit [Makefile][]
- (Come from `fsdb-build.md` of [2026-02-05 Space-evol][]) 

```bash
make
load out/fsdb-misc.yml
```

- [out/fsdb-misc.yml][]

[out/fsdb-misc.yml]: out/fsdb-misc.yml 'sibling file'
[Makefile]: Makefile 'sibling file'
[fsdb-misc.md]: fsdb-misc.md 'sibling file'

[2026-02-05 Space-evol]:
    ../../2026/2026-02-05-space-evol/space-evol.md
    "sibling file"

# Show minimal facts

```bash
small-db-basic-facts | duckdb tmp/nfsdata-small.db --box
```

```txt
┌────────────┬────────────┬──────────┬─────────┬─────────┬──────────┬─────────┐
│   start    │    end     │   rows   │ servers │  dirs   │  files   │  size   │
├────────────┼────────────┼──────────┼─────────┼─────────┼──────────┼─────────┤
│ 1999-04-15 │ 2026-05-07 │ 10.9 MiB │ 15      │ 1.6 MiB │ 42.1 MiB │ 7.5 TiB │
└────────────┴────────────┴──────────┴─────────┴─────────┴──────────┴─────────┘
```

# Here is the previous state from 3 months ago

```txt
┌────────────┬────────────┬──────────┬─────────┬─────────┬──────────┬─────────┐
│   start    │    end     │   rows   │ servers │  dirs   │  files   │  size   │
├────────────┼────────────┼──────────┼─────────┼─────────┼──────────┼─────────┤
│ 1999-04-15 │ 2026-02-08 │ 11.4 MiB │ 18      │ 2.1 MiB │ 37.8 MiB │ 7.4 TiB │
└────────────┴────────────┴──────────┴─────────┴─────────┴──────────┴─────────┘
```

# More basic info and usage exemple

## The big DB

```bash
table-info | duckdb tmp/nfsdata.db --box
```

---

```text
┌─────────────┬──────────────────────────┐
│ column_name │       column_type        │
├─────────────┼──────────────────────────┤
│ inode       │ BIGINT                   │
│ uts         │ TIMESTAMP WITH TIME ZONE │
│ size        │ BIGINT                   │
│ path        │ VARCHAR[]                │
│ server      │ VARCHAR                  │
└─────────────┴──────────────────────────┘
```

```bash
<<< 'select * from fsdb order by uts desc limit 10' duckdb tmp/nfsdata.db
```

---

```text
┌──────────┬──────────────────────┬───────┬───────────────────────────────────────────────────────────────────────────────────────────┬─────────────────────────┐
│  inode   │         uts          │ size  │                                           path                                            │         server          │
│  int64   │ timestamp with tim…  │ int64 │                                         varchar[]                                         │         varchar         │
├──────────┼──────────────────────┼───────┼───────────────────────────────────────────────────────────────────────────────────────────┼─────────────────────────┤
│  7767690 │ 2026-05-07 18:40:3…  │  2715 │ [profnt2, applisdata, homere-controlpanel, storage, epimob, data_files, panel_user_json…  │ protpstrd1_data_nfsdata │
│ 10269567 │ 2026-05-07 18:40:1…  │   435 │ [profnt2, applisdata, neonatfiles, storage, epifiles, e1, df, e1dff91e24fc85723ba04efc3…  │ protpstrd1_data_nfsdata │
│ 10007006 │ 2026-05-07 18:40:1…  │   415 │ [profnt2, applisdata, neonatfiles, storage, epifiles, 94, 73, 94737e40d1f7037b6dea12c3f…  │ protpstrd1_data_nfsdata │
│ 10143343 │ 2026-05-07 18:40:1…  │   415 │ [profnt2, applisdata, neonatfiles, storage, epifiles, a3, 63, a36360d8434c1276b1d60a02d…  │ protpstrd1_data_nfsdata │
│  9745311 │ 2026-05-07 18:40:1…  │   417 │ [profnt2, applisdata, neonatfiles, storage, epifiles, 53, d5, 53d50a8456a17ce4d21e14213…  │ protpstrd1_data_nfsdata │
│ 10143342 │ 2026-05-07 18:40:1…  │   443 │ [profnt2, applisdata, neonatfiles, storage, epifiles, af, 6b, af6b5992df30ca066d297b0f0…  │ protpstrd1_data_nfsdata │
│  9612826 │ 2026-05-07 18:40:1…  │   427 │ [profnt2, applisdata, neonatfiles, storage, epifiles, 1e, 2e, 1e2eb5c5e32aa9b4a6eb6a1c5…  │ protpstrd1_data_nfsdata │
│ 10007005 │ 2026-05-07 18:40:1…  │   416 │ [profnt2, applisdata, neonatfiles, storage, epifiles, 7d, 65, 7d65c7660e8ff154693c8d4e7…  │ protpstrd1_data_nfsdata │
│ 10007004 │ 2026-05-07 18:40:1…  │   417 │ [profnt2, applisdata, neonatfiles, storage, epifiles, 8b, 45, 8b457bdf2525df620e1f5cb6d…  │ protpstrd1_data_nfsdata │
│  9612825 │ 2026-05-07 18:40:1…  │   434 │ [profnt2, applisdata, neonatfiles, storage, epifiles, 14, 8a, 148a4be3fd4eec7963e4e6e6a…  │ protpstrd1_data_nfsdata │
├──────────┴──────────────────────┴───────┴───────────────────────────────────────────────────────────────────────────────────────────┴─────────────────────────┤
│ 10 rows                                                                                                                                             5 columns │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

## The small one

```bash
table-info | duckdb tmp/nfsdata-small.db --box
```

---

```text
┌─────────────┬──────────────────────────┐
│ column_name │       column_type        │
├─────────────┼──────────────────────────┤
│ date        │ TIMESTAMP WITH TIME ZONE │
│ path        │ VARCHAR[]                │
│ cnt         │ BIGINT                   │
│ size        │ HUGEINT                  │
│ min         │ BIGINT                   │
│ max         │ BIGINT                   │
│ mean        │ DOUBLE                   │
│ server      │ VARCHAR                  │
└─────────────┴──────────────────────────┘
```

```bash
<<< "select * from fsdb where server == 'protpstrd1_data_nfsdata_small' and cnt > 1 order by date desc limit 10" duckdb tmp/nfsdata-small.db
```

---


```text
┌──────────────────────┬──────────────────────────────────────────────────┬───────┬────────┬───────┬───────┬────────────────────┬───────────────────────────────┐
│         date         │                       path                       │  cnt  │  size  │  min  │  max  │        mean        │            server             │
│ timestamp with tim…  │                    varchar[]                     │ int64 │ int128 │ int64 │ int64 │       double       │            varchar            │
├──────────────────────┼──────────────────────────────────────────────────┼───────┼────────┼───────┼───────┼────────────────────┼───────────────────────────────┤
│ 2026-05-07 18:00:0…  │ [profnt2, applisdata, homere-controlpanel, sto…  │    20 │  52834 │  2430 │  2836 │             2641.7 │ protpstrd1_data_nfsdata_small │
│ 2026-05-07 18:00:0…  │ [profnt2, applisdata, ngo-controlpanel, storag…  │    14 │  36620 │  2546 │  2684 │  2615.714285714286 │ protpstrd1_data_nfsdata_small │
│ 2026-05-07 17:00:0…  │ [profnt2, applisdata, homere-controlpanel, sto…  │    37 │  96541 │  2408 │  2919 │ 2609.2162162162163 │ protpstrd1_data_nfsdata_small │
│ 2026-05-07 17:00:0…  │ [profnt2, applisdata, ngo-controlpanel, storag…  │    41 │ 106680 │  2419 │  2678 │  2601.951219512195 │ protpstrd1_data_nfsdata_small │
│ 2026-05-07 16:00:0…  │ [profnt2, applisdata, ngo-controlpanel, storag…  │    50 │ 129459 │  2334 │  2689 │            2589.18 │ protpstrd1_data_nfsdata_small │
│ 2026-05-07 16:00:0…  │ [profnt2, applisdata, homere-controlpanel, sto…  │    54 │ 138608 │  2382 │  2893 │  2566.814814814815 │ protpstrd1_data_nfsdata_small │
│ 2026-05-07 15:00:0…  │ [profnt2, applisdata, ngo-controlpanel, storag…  │    43 │ 111308 │  2384 │  2730 │ 2588.5581395348836 │ protpstrd1_data_nfsdata_small │
│ 2026-05-07 15:00:0…  │ [profnt2, applisdata, homere-controlpanel, sto…  │    60 │ 155181 │  2396 │  3031 │            2586.35 │ protpstrd1_data_nfsdata_small │
│ 2026-05-07 14:00:0…  │ [profnt2, applisdata, ngo-controlpanel, storag…  │    76 │ 197313 │  2417 │  2676 │ 2596.2236842105262 │ protpstrd1_data_nfsdata_small │
│ 2026-05-07 14:00:0…  │ [profnt2, applisdata, homere-controlpanel, sto…  │    46 │ 120789 │  2375 │  2880 │ 2625.8478260869565 │ protpstrd1_data_nfsdata_small │
├──────────────────────┴──────────────────────────────────────────────────┴───────┴────────┴───────┴───────┴────────────────────┴───────────────────────────────┤
│ 10 rows                                                                                                                                             8 columns │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

# Try CTE

- Edit [fsdb-cte.md][] to fix [Dammit! until is a bash keyword][]

```bash
make
```

[Dammit! until is a bash keyword]:
    https://github.com/thydel/fsdb/commit/eb1ec68092182363ba3572a89cf3595e636389e0
    "github.com commit"

> [!NOTE]
>
> - [fsdb-cte.md][] use `parsarg` from [baj][] which is not yet auto install

```bash
source ../baj/cmd/parsarg.sh
load out/fsdb-cte.yml
```

## First try

```console
thy@controla2:~/usr/fsdb$ start | where size == 0 | count | merge-cte | ddb -line
count_star() = 2780
```

## More tries

```bash
start | is server prostrb2_data_nfsdata_small | sum path[1:3] | order size | merge-cte | ddb -box
```

---

```text
┌────────────────────────────────────────┬────────┬──────────────┐
│               path[1:3]                │  cnt   │     size     │
├────────────────────────────────────────┼────────┼──────────────┤
│ [profntu1, applisdata, centralisateur] │ 734790 │ 174762341933 │
│ [profntu1, applisdata, neonatweb]      │ 253968 │ 70739935868  │
│ [profntu1, applisdata, neonatlabo]     │ 830220 │ 44036538325  │
│ [profntu1, applisdata, surditeinvs]    │ 458    │ 4107061938   │
│ [shared, pentao, surditeinvs]          │ 136    │ 1113633297   │
│ [profntu1, applisdata, neonatfiles]    │ 45774  │ 1105024761   │
│ [profntu1, applisdata, 2rm_02122024]   │ 94     │ 4640060      │
│ [profntu1, applisdata, epifiles]       │ 24     │ 405979       │
└────────────────────────────────────────┴────────┴──────────────┘
```

```bash
start | like path[2] %neo% | sum server,path[2] | order size | merge-cte | ddb -box
```

---

```text
┌───────────────────────────────┬──────────────────┬──────┬────────────┐
│            server             │     path[2]      │ cnt  │    size    │
├───────────────────────────────┼──────────────────┼──────┼────────────┤
│ protpstrf1_data_nfsdata_small │ neonet-862       │ 4669 │ 4496297965 │
│ prestr1_data_nfsdata_small    │ neoesis          │ 4744 │ 887103035  │
│ prestr1_data_nfsdata_small    │ neonatlabo226    │ 3967 │ 482817845  │
│ prestr1_data_nfsdata_small    │ neonatlabo-alpha │ 1126 │ 279495455  │
│ prestr1_data_nfsdata_small    │ neoesis-alpha    │ 1373 │ 131321219  │
│ prestr1_data_nfsdata_small    │ portailneo       │ 270  │ 25354892   │
│ prestr1_data_nfsdata_small    │ neoesis-recette  │ 49   │ 5565478    │
│ prestr1_data_nfsdata_small    │ neobci           │ 8    │ 3228202    │
│ prestr1_data_nfsdata_small    │ neonatweb        │ 60   │ 1513909    │
│ prestr1_data_nfsdata_small    │ neodemat         │ 20   │ 824369     │
└───────────────────────────────┴──────────────────┴──────┴────────────┘
```

# Try some exploration

## Copy DB from `controla2`

- On my WS

```bash
rsync -e ssh -av controla2:usr/fsdb/tmp/nfsdata-small.db .
rsync -e ssh -av controla2:usr/fsdb/tmp/nfsdata.db .
```

## Look for recent `DF_HIGH_SPACE`

```text
Liste des anormalités fatales
Anormalités fatales
Date	Serveur	Gravité	Anormalité	Commentaire
2026-05-11 11:23:58 	prot1strb1 	FATAL 	DF_HIGH_SPACE 	93%§/data (limit: 90)
2026-05-11 11:24:56 	prot1strc1 	FATAL 	DF_HIGH_SPACE 	91%§/data (limit: 90)
```

### `prot1strb1`

#### Pseudo `df`

```bash
start | like server prot1strb1% | as path[3] set | sum set | where cnt \> 10 | order size | merge-cte | ddb -json | fmt-auto
```

---

|      set      | cnt  | size |
|---------------|------|------|
| ssp_ndf       | 1M   | 422G |
| ssp           | 1M   | 181G |
| ssp_ndf_stats | 464K | 36G  |


#### On subdir on top dir

```bash
start | like server prot1strb1% | is path[3] ssp_ndf | as path[4] set | sum set | order size | merge-cte | ddb -json | fmt-auto
```

---

|        set        | cnt  | size |
|-------------------|------|------|
| upload            | 1M   | 349G |
| upload_reprise_93 | 42K  | 49G  |
| apicrypt          | 113K | 20G  |
| stats             | 16K  | 1G   |
| recodings         | 148  | 766M |
| HPV               | 989  | 574M |
| logs              | 278  | 18M  |
| hl7               | 1K   | 1M   |


#### By time span on a dir

```bash
dir: () { : ${2:?}; like server $1% | is path[3] $2; }
since: () { : ${2:?}; since $1 | span $2 | as date::DATE start | order start asc | keep start cnt size; }
```

##### `ssp_ndf` By month since 2025

```bash
start | dir: prot1strb1 ssp_ndf | since: 2025-01-01 month | merge-cte | ddb -json | fmt-auto
```

---

|   start    | cnt  | size |
|------------|------|------|
| 2025-01-01 | 15K  | 5G   |
| 2025-02-01 | 13K  | 4G   |
| 2025-03-01 | 13K  | 4G   |
| 2025-04-01 | 13K  | 4G   |
| 2025-05-01 | 12K  | 4G   |
| 2025-06-01 | 13K  | 4G   |
| 2025-07-01 | 13K  | 4G   |
| 2025-08-01 | 11K  | 3G   |
| 2025-09-01 | 15K  | 5G   |
| 2025-10-01 | 15K  | 5G   |
| 2025-11-01 | 12K  | 4G   |
| 2025-12-01 | 14K  | 5G   |
| 2026-01-01 | 15K  | 4G   |
| 2026-02-01 | 16K  | 5G   |
| 2026-03-01 | 524K | 90G  |
| 2026-04-01 | 20K  | 5G   |
| 2026-05-01 | 4K   | 1G   |

##### `ssp` By year since 2018

```bash
start | dir: prot1strb1 ssp | since: 2018-01-01 year | merge-cte | ddb -json | fmt-auto
```

---

|   start    | cnt  | size |
|------------|------|------|
| 2018-01-01 | 9K   | 1G   |
| 2019-01-01 | 25K  | 5G   |
| 2020-01-01 | 18K  | 4G   |
| 2021-01-01 | 43K  | 5G   |
| 2022-01-01 | 258K | 11G  |
| 2023-01-01 | 655K | 108G |
| 2024-01-01 | 84K  | 17G  |
| 2025-01-01 | 162K | 19G  |
| 2026-01-01 | 72K  | 8G   |

### `prostrc1`

#### Pseudo `df`

```bash
start | like server prot1strc1% | as path[3] set | sum set | where size \> 1e9 | order size | merge-cte | ddb -json | fmt-auto
```

---

|               set               | cnt | size |
|---------------------------------|-----|------|
| ssp                             | 2M  | 645G |
| cupidon                         | 7K  | 1G   |
| 201911xx_ssp_version_validation | 5K  | 1G   |


```bash
start | like server prot1strc1% | as path[3:4] set | sum set | where size \> 1e9 | order size | merge-cte | ddb -json | fmt-auto
```

---

|                     set                     | cnt  | size |
|---------------------------------------------|------|------|
| [ssp, upload]                               | 1M   | 590G |
| [ssp, apicrypt]                             | 190K | 41G  |
| [ssp, stats]                                | 31K  | 4G   |
| [ssp, restitution]                          | 10K  | 4G   |
| [cupidon, upload]                           | 7K   | 1G   |
| [ssp, ORU]                                  | 9K   | 1G   |
| [201911xx_ssp_version_validation, apicrypt] | 2K   | 1G   |
| [ssp, recodings]                            | 262  | 1G   |
| [ssp, HPV]                                  | 3K   | 1G   |


```bash
start | like server prot1strc1% | as path[3:5] set | sum set | where size \> 1e9 | order size | merge-cte | ddb -json | fmt-auto
```

---

|                   set                    | cnt  | size |
|------------------------------------------|------|------|
| [ssp, upload, files_1731959368_by_group] | 1M   | 444G |
| [ssp, upload, files_1731959368]          | 322K | 145G |
| [ssp, apicrypt, 201]                     | 72K  | 17G  |
| [ssp, apicrypt, 338]                     | 52K  | 10G  |
| [ssp, apicrypt, 338-SLM]                 | 22K  | 4G   |
| [ssp, apicrypt, 664]                     | 7K   | 3G   |
| [ssp, restitution, 523]                  | 9K   | 3G   |
| [ssp, apicrypt, 923]                     | 12K  | 2G   |
| [cupidon, upload, files_177041596]       | 7K   | 1G   |
| [ssp, ORU]                               | 9K   | 1G   |
| [ssp, HPV]                               | 3K   | 1G   |
| [ssp, apicrypt, 338-kourou]              | 7K   | 998M |

##### `ssp` By year since 2018

```bash
start | dir: prot1strc1 ssp | since: 2015-01-01 year | merge-cte | ddb -json | fmt-auto
```

---

|   start    | cnt  | size |
|------------|------|------|
| 2015-01-01 | 25K  | 13G  |
| 2016-01-01 | 26K  | 12G  |
| 2017-01-01 | 38K  | 19G  |
| 2018-01-01 | 65K  | 26G  |
| 2019-01-01 | 120K | 48G  |
| 2020-01-01 | 138K | 55G  |
| 2021-01-01 | 157K | 52G  |
| 2022-01-01 | 163K | 66G  |
| 2023-01-01 | 612K | 111G |
| 2024-01-01 | 286K | 115G |
| 2025-01-01 | 217K | 81G  |
| 2026-01-01 | 223K | 37G  |

##### `ssp` By month since 2025

```bash
start | dir: prot1strc1 ssp | since: 2025-01-01 month | merge-cte | ddb -json | fmt-auto
```

---

|   start    | cnt | size |
|------------|-----|------|
| 2024-12-01 | 19  | 1M   |
| 2025-01-01 | 18K | 6G   |
| 2025-02-01 | 16K | 5G   |
| 2025-03-01 | 16K | 5G   |
| 2025-04-01 | 16K | 5G   |
| 2025-05-01 | 15K | 5G   |
| 2025-06-01 | 16K | 6G   |
| 2025-07-01 | 16K | 6G   |
| 2025-08-01 | 13K | 5G   |
| 2025-09-01 | 20K | 7G   |
| 2025-10-01 | 21K | 8G   |
| 2025-11-01 | 26K | 10G  |
| 2025-12-01 | 19K | 8G   |
| 2026-01-01 | 25K | 8G   |
| 2026-02-01 | 22K | 8G   |
| 2026-03-01 | 41K | 9G   |
| 2026-04-01 | 96K | 8G   |
| 2026-05-01 | 37K | 1G   |

<!--
bin=$INFRA/infra-lib-2023/bin
. <(echo ${nodes[@]} | sort | $bin/fmt-nodes.jq)

find -maxdepth 1 -type f | cut -c 3- | grep -v \~ | jq -Rr '"[\(.)]: \(.) \u0027sibling file\u0027", "- [\(.)][]"' | env LANG=C sort
find out -type f | grep -v \~ | jq -Rr '"[\(.)]: \(.) \u0027sibling file\u0027", "- [\(.)][]"' | env LANG=C sort
-->

[baj]:
    https://github.com/thydel/baj
    "github.com repo"

[.gitignore]: .gitignore 'sibling file'
[CLAUDE.md]: CLAUDE.md 'sibling file'
[JOURNAL.md]: JOURNAL.md 'sibling file'
[Makefile]: Makefile 'sibling file'
[NOTES.md]: NOTES.md 'sibling file'
[README.md]: README.md 'sibling file'
[fsdb-build.md]: fsdb-build.md 'sibling file'
[fsdb-cte.md]: fsdb-cte.md 'sibling file'
[fsdb-main.md]: fsdb-main.md 'sibling file'
[fsdb-misc.md]: fsdb-misc.md 'sibling file'
[fsdb-pipes.md]: fsdb-pipes.md 'sibling file'

[out/conf-by-name.json]: out/conf-by-name.json 'sibling file'
[out/conf.json]: out/conf.json 'sibling file'
[out/fsdb-build.yml]: out/fsdb-build.yml 'sibling file'
[out/fsdb-cte.yml]: out/fsdb-cte.yml 'sibling file'
[out/fsdb-misc.yml]: out/fsdb-misc.yml 'sibling file'
[out/fsdb-pipes.yml]: out/fsdb-pipes.yml 'sibling file'

[Local Variables:]::
[indent-tabs-mode: nil]::
[End:]::
