---
title: Space evol ssp
date: 2025-12-23
tags: [ space, evolution ]
---

<!--
(delete-matching-lines "INFRADESK-nnnn")
(delete-matching-lines "INFRA-nnnn")
-->

```yml
nodes: [ profnte1, profntr1, profntp1 ]
tickets: [ INFRA-2338 ]
```

[2025-12-23 Space-evol-ssp]:
    ../../2025/2025-12-23-space-evol-ssp/space-evol-ssp.md
    "sibling file"

<!-- Related -->

[2025-11-05 Space-evol-tdep]:
    ../../2025/2025-11-05-space-evol-tdep/space-evol-tdep.md
    "sibling file"

[2025-11-03 Space-evol]:
    ../../2025/2025-11-03-space-evol/space-evol.md
    "sibling file"

[2025-10-22 Space-evol]:
    ../../2025/2025-10-22-space-evol/space-evol.md
    "sibling file"

[2025-10-16 Space-evol]:
    ../../2025/2025-10-16-space-evol/space-evol.md
    "sibling file"

[2025-08-01 Prostrc1-space]:
    ../../2025/2025-08-01-prostrc1-space/prostrc1-space.md
    "sibling file"

<!-- Repos -->

[jqsh]:
    https://github.com/Epiconcept-Paris/jqsh
    "github.com repo"

[infra-lib-2023]:
    https://github.com/Epiconcept-Paris/infra-lib-2023
    "github.com repo"

[infra-fact-2023]:
    https://github.com/Epiconcept-Paris/infra-fact-2023
    "github.com repo"

[infra-node-groups-data-2025]:
    https://github.com/Epiconcept-Paris/infra-node-groups-data-2025
    "github.com repo"

[infra-data-ips-2025]:
    https://github.com/Epiconcept-Paris/infra-data-ips-2025
    "github.com repo"

[infra-data-2023]:
    https://github.com/Epiconcept-Paris/infra-data-2023
    "github.com repo"

[infra-play-2025]:
    https://github.com/Epiconcept-Paris/infra-play-2025
    "github.com repo"

[infra-play-2023]:
    https://github.com/Epiconcept-Paris/infra-play-2023
    "github.com repo"

<!-- Tickets -->

[INFRA-2338]: https://epiconcept.atlassian.net/browse/INFRA-2338 "epiconcept.atlassian.net"

# TL;DR

## TODO/DONE

- [X] Use `baj` instead of `jqsh` (now just one file to source)
- [X] Use `LIST(VARCHAR)` type for path (dynamic choice of path prefix level)
- [X] Get FS data and build full DB (timestamp, inode, mode, size, full path)
- [X] Make a small DB version grouped by hour time bucket and keep dir part of path only
- [X] Fisrt simple parametrize query func
- [X] Merge add DB as a single one with a client column
- [X] Show some basics facts about the DB
- [X] (WIP) Revamp previous TCE based query generator
- [ ] Choose a simple graph generator
- [ ] Install a cron to build DB on server

> [!NOTE]
>
> - The small version of `profnt{e,p,r}1.db` are in the the repo
> - So is the new merge `out/ssp-small.db`

## Show me basic facts

### The full DB

```console
thy@tdews1-256g:2025-12-23-space-evol-ssp$ table-info | duckdb tmp/ssp.db --box
┌─────────────┬──────────────────────────┐
│ column_name │       column_type        │
├─────────────┼──────────────────────────┤
│ inode       │ BIGINT                   │
│ uts         │ TIMESTAMP WITH TIME ZONE │
│ size        │ BIGINT                   │
│ path        │ VARCHAR[]                │
│ server      │ VARCHAR                  │
└─────────────┴──────────────────────────┘
thy@tdews1-256g:2025-12-23-space-evol-ssp$ full-db-basic-facts | duckdb tmp/ssp.db --box
┌────────────┬────────────┬─────────┬─────────┬─────────┐
│   start    │    end     │ servers │  files  │  size   │
├────────────┼────────────┼─────────┼─────────┼─────────┤
│ 2014-07-15 │ 2025-12-24 │ 3       │ 4.6 MiB │ 1.1 TiB │
└────────────┴────────────┴─────────┴─────────┴─────────┘
thy@tdews1-256g:2025-12-23-space-evol-ssp$ ls -lsh tmp/ssp.db 
174M -rw-r--r-- 1 thy thy 174M Dec 30 12:29 tmp/ssp.db
```

### The small DB

```console
thy@tdews1-256g:2025-12-23-space-evol-ssp$ table-info | duckdb out/ssp-small.db --box
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
thy@tdews1-256g:2025-12-23-space-evol-ssp$ small-db-basic-facts | duckdb out/ssp-small.db --box
┌────────────┬────────────┬───────────┬─────────┬──────────┬─────────┬─────────┐
│   start    │    end     │   rows    │ servers │   dirs   │  files  │  size   │
├────────────┼────────────┼───────────┼─────────┼──────────┼─────────┼─────────┤
│ 2014-07-15 │ 2025-12-24 │ 417.8 KiB │ 3       │ 52.1 KiB │ 4.6 MiB │ 1.1 TiB │
└────────────┴────────────┴───────────┴─────────┴──────────┴─────────┴─────────┘
thy@tdews1-256g:2025-12-23-space-evol-ssp$ ls -lsh out/ssp-small.db
20M -rw-r--r-- 1 thy thy 20M Dec 30 12:50 out/ssp-small.db
```

## Show me CTE pipe

### Show SQL

- `span` default to year (add %Y column)
- `since` default to one year (all entries not older that one year)

```bash
start | span | since | where cnt \> 1 | sum span,server,path[1:2] cnt,size | order span,size | human cnt size | merge-cte
```

---

```sql
WITH step0 AS (FROM fsdb),
step1 AS (SELECT *, STRFTIME(date, '%Y') AS span from step0),
step2 AS (WITH max_date AS (SELECT MAX(date) AS max_date FROM step1)
SELECT * FROM step1, max_date
WHERE date >= (SELECT max_date - INTERVAL 1 year FROM max_date)
  AND date <= (SELECT max_date FROM max_date)),
step3 AS (SELECT * FROM step2 WHERE cnt > 1),
step4 AS (SELECT span,server,path[1:2], SUM(cnt) AS cnt, SUM(size) AS size FROM step3 GROUP BY span,server,path[1:2]),
step5 AS (SELECT * FROM step4 ORDER BY span,size DESC),
step6 AS (SELECT *, format_bytes(cnt::BIGINT) AS hcnt, format_bytes(size::BIGINT) AS hsize FROM step5)
SELECT * FROM step6
```

### Show results

- All aggregated year, server and depth 2 paths not older than 1 year with more than 1 file

```bash
start | span | since | where cnt \> 1 | sum span,server,path[1:2] cnt,size | order span,size | human size | ddb
```

```
┌─────────┬──────────┬────────────────────────────┬────────┬─────────────┬───────────┐
│  span   │  server  │         path[1:2]          │  cnt   │    size     │   hsize   │
├─────────┼──────────┼────────────────────────────┼────────┼─────────────┼───────────┤
│ 2024    │ profnte1 │ [ssp, upload]              │   1396 │   631777389 │ 602.5 MiB │
│ 2024    │ profntr1 │ [ssp_ndf, upload]          │   1250 │   514333723 │ 490.5 MiB │
│ 2024    │ profntr1 │ [ssp, upload]              │    821 │   196659142 │ 187.5 MiB │
│ 2024    │ profnte1 │ [ssp, apicrypt]            │    772 │   157675976 │ 150.3 MiB │
│ 2024    │ profntr1 │ [ssp_ndf, apicrypt]        │    266 │    55223605 │ 52.6 MiB  │
│ 2024    │ profntr1 │ [ssp, apicrypt]            │    150 │    11571793 │ 11.0 MiB  │
│ 2024    │ profntp1 │ [ssp, upload]              │     24 │     8976486 │ 8.5 MiB   │
│ 2024    │ profnte1 │ [ssp, HPV]                 │      2 │     1149562 │ 1.0 MiB   │
│ 2024    │ profntp1 │ [ssp_pf_bio_covid, logs]   │     14 │        1582 │ 1.5 KiB   │
│ 2024    │ profntp1 │ [ssp, logs]                │     14 │        1582 │ 1.5 KiB   │
│ 2025    │ profnte1 │ [ssp, upload]              │ 152161 │ 71306640948 │ 66.4 GiB  │
│ 2025    │ profntr1 │ [ssp_ndf, upload]          │ 131052 │ 53295081598 │ 49.6 GiB  │
│ 2025    │ profntr1 │ [ssp, upload]              │  45912 │ 15042959887 │ 14.0 GiB  │
│ 2025    │ profnte1 │ [ssp, apicrypt]            │  42159 │  8229064719 │ 7.6 GiB   │
│ 2025    │ profntp1 │ [ssp, upload]              │  10425 │  7059355194 │ 6.5 GiB   │
│ 2025    │ profntr1 │ [ssp_ndf, apicrypt]        │  27454 │  5906930893 │ 5.5 GiB   │
│ 2025    │ profntr1 │ [ssp, apicrypt]            │ 114032 │  4866490656 │ 4.5 GiB   │
│ 2025    │ profnte1 │ [ssp, restitution]         │  10727 │  4315471052 │ 4.0 GiB   │
│ 2025    │ profnte1 │ [ssp, HPV]                 │   1500 │   419271541 │ 399.8 MiB │
│ 2025    │ profntr1 │ [ssp_ndf, HPV]             │    542 │   322223363 │ 307.2 MiB │
│ 2025    │ profntp1 │ [mailmerge, storage]       │    797 │    92374399 │ 88.0 MiB  │
│ 2025    │ profnte1 │ [ssp, ORU]                 │    510 │    91557994 │ 87.3 MiB  │
│ 2025    │ profnte1 │ [ssp, recodings]           │     32 │    48972055 │ 46.7 MiB  │
│ 2025    │ profnte1 │ [ssp, hl7]                 │ 100663 │    28425320 │ 27.1 MiB  │
│ 2025    │ profntr1 │ [ssp_ndf_stats, upload]    │      3 │     7480836 │ 7.1 MiB   │
│ 2025    │ profntr1 │ [ssp_ndf, recodings]       │     20 │     2972561 │ 2.8 MiB   │
│ 2025    │ profntp1 │ [esisdoccu-pf, storage]    │     12 │     2772286 │ 2.6 MiB   │
│ 2025    │ profntr1 │ [ssp_ndf, hl7]             │   1551 │     1151391 │ 1.0 MiB   │
│ 2025    │ profntr1 │ [ssp, recodings]           │     20 │      217030 │ 211.9 KiB │
│ 2025    │ profntp1 │ [ssp, recodings]           │     18 │      164922 │ 161.0 KiB │
│ 2025    │ profntr1 │ [ssp_ndf_stats, recodings] │      4 │      164918 │ 161.0 KiB │
│ 2025    │ profntp1 │ [ssp, logs]                │    714 │       80682 │ 78.7 KiB  │
│ 2025    │ profntp1 │ [ssp_pf_bio_covid, logs]   │    700 │       79100 │ 77.2 KiB  │
│ 2025    │ profntp1 │ [esisdocs-pf, storage]     │      2 │         251 │ 251 bytes │
├─────────┴──────────┴────────────────────────────┴────────┴─────────────┴───────────┤
│ 34 rows                                                                  6 columns │
└────────────────────────────────────────────────────────────────────────────────────┘
```

- All aggregated year, server and depth 2 paths before 2025 with more than 5G size

```bash
start | span | end 2025-01-01 | sum span,server,path[1:2] cnt,size | order span,size | bigger G 5 | human size | ddb
```

```
┌─────────┬──────────┬────────────────────────────┬────────┬──────────────┬───────────┐
│  span   │  server  │         path[1:2]          │  cnt   │     size     │   hsize   │
├─────────┼──────────┼────────────────────────────┼────────┼──────────────┼───────────┤
│ 2015    │ profnte1 │ [ssp, upload]              │  26082 │  14139418075 │ 13.1 GiB  │
│ 2015    │ profntr1 │ [ssp_ndf, upload]          │  22317 │  11843534661 │ 11.0 GiB  │
│ 2016    │ profnte1 │ [ssp, upload]              │  27240 │  13649342352 │ 12.7 GiB  │
│ 2016    │ profntr1 │ [ssp_ndf, upload]          │  19050 │  10389315924 │ 9.6 GiB   │
│ 2017    │ profnte1 │ [ssp, upload]              │  39428 │  21389942144 │ 19.9 GiB  │
│ 2017    │ profntr1 │ [ssp_ndf, upload]          │  23244 │  14724068386 │ 13.7 GiB  │
│ 2018    │ profnte1 │ [ssp, upload]              │  61738 │  28595332331 │ 26.6 GiB  │
│ 2018    │ profntr1 │ [ssp_ndf, upload]          │  25482 │  14930794371 │ 13.9 GiB  │
│ 2019    │ profnte1 │ [ssp, upload]              │ 108665 │  46347546091 │ 43.1 GiB  │
│ 2019    │ profntr1 │ [ssp_ndf, upload]          │  40669 │  20787252358 │ 19.3 GiB  │
│ 2019    │ profntr1 │ [ssp, upload]              │  20065 │   5688304109 │ 5.2 GiB   │
│ 2019    │ profnte1 │ [ssp, apicrypt]            │   7398 │   5583845619 │ 5.2 GiB   │
│ 2020    │ profnte1 │ [ssp, upload]              │ 122227 │  54860123023 │ 51.0 GiB  │
│ 2020    │ profntr1 │ [ssp_ndf, upload]          │  54648 │  25681387046 │ 23.9 GiB  │
│ 2021    │ profnte1 │ [ssp, upload]              │ 139157 │  53174999294 │ 49.5 GiB  │
│ 2021    │ profntp1 │ [ssp, upload]              │ 380114 │  35092839255 │ 32.6 GiB  │
│ 2021    │ profntr1 │ [ssp_ndf, upload]          │  49852 │  24129864558 │ 22.4 GiB  │
│ 2021    │ profntp1 │ [ssp, healthpasscovid19]   │     85 │  20056001010 │ 18.6 GiB  │
│ 2022    │ profnte1 │ [ssp, upload]              │ 137242 │  63297480669 │ 58.9 GiB  │
│ 2022    │ profntr1 │ [ssp_ndf, upload]          │  55490 │  29430622841 │ 27.4 GiB  │
│ 2022    │ profntp1 │ [ssp, upload]              │ 177859 │  20078532439 │ 18.6 GiB  │
│ 2022    │ profntp1 │ [ssp_pf_bio_covid, upload] │ 139300 │  12278115402 │ 11.4 GiB  │
│ 2022    │ profntr1 │ [ssp, upload]              │ 252187 │  11794197412 │ 10.9 GiB  │
│ 2022    │ profntp1 │ [ssp, healthpasscovid19]   │    289 │   7408987727 │ 6.8 GiB   │
│ 2022    │ profnte1 │ [ssp, apicrypt]            │  29026 │   7402269534 │ 6.8 GiB   │
│ 2023    │ profnte1 │ [ssp, upload]              │ 597295 │ 115606532560 │ 107.6 GiB │
│ 2023    │ profntr1 │ [ssp, upload]              │ 656905 │ 114744246101 │ 106.8 GiB │
│ 2023    │ profntr1 │ [ssp_ndf, upload]          │  70038 │  35675481830 │ 33.2 GiB  │
│ 2023    │ profntp1 │ [ssp, upload]              │  20072 │   7567552106 │ 7.0 GiB   │
│ 2024    │ profnte1 │ [ssp, upload]              │ 257394 │ 115752973746 │ 107.8 GiB │
│ 2024    │ profntr1 │ [ssp_ndf, upload]          │ 160183 │  70585347517 │ 65.7 GiB  │
│ 2024    │ profntr1 │ [ssp, upload]              │  72178 │  17060880518 │ 15.8 GiB  │
│ 2024    │ profntp1 │ [ssp, upload]              │  20569 │  16806822369 │ 15.6 GiB  │
│ 2024    │ profnte1 │ [ssp, apicrypt]            │  28221 │   5572759480 │ 5.1 GiB   │
│ 2024    │ profntr1 │ [ssp_ndf, apicrypt]        │  22019 │   5435180680 │ 5.0 GiB   │
├─────────┴──────────┴────────────────────────────┴────────┴──────────────┴───────────┤
│ 35 rows                                                                   6 columns │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

<!-- markdown-toc-generate-toc -->
<!-- https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1036359 -->
<!--
mkdir -p tmp; pandoc README.md -t jira > tmp/README.jira
< README.md pandoc -f gfm -t gfm --toc --toc-depth=6 --template ../toc.md --columns=196 | grep -v Table.of.Contents
-->

# Table of Contents

<details><summary>Expand</summary>

-   [TL;DR](#tldr)
    -   [TODO/DONE](#tododone)
    -   [Show me basic facts](#show-me-basic-facts)
        -   [The full DB](#the-full-db)
        -   [The small DB](#the-small-db)
    -   [Show me CTE pipe](#show-me-cte-pipe)
        -   [Show SQL](#show-sql)
        -   [Show results](#show-results)
-   [See also](#see-also)
-   [Per request INFRA-2338](#per-request-infra-2338)
-   [Use new `baj`](#use-new-baj)
-   [Add new tool](#add-new-tool)
-   [Use new tool](#use-new-tool)
    -   [Generate conf](#generate-conf)
    -   [Get FS data](#get-fs-data)
    -   [Make full DB from data](#make-full-db-from-data)
    -   [Make a small version of the DB](#make-a-small-version-of-the-db)
    -   [Make queries on DB](#make-queries-on-db)

</details>

# See also

<details><summary>Expand</summary>

- [2025-11-05 Space-evol-tdep][]
- [2025-11-03 Space-evol][]
- [2025-10-22 Space-evol][]
- [2025-10-16 Space-evol][]
- [2025-08-01 Prostrc1-space][]

</details>

# Per request INFRA-2338

- [INFRA-2338][] evolution des disques pour la SSP

- **Priority** High
- **Description**

    refaire pour la SSP l'étude faite pour la TDEP
    - frontaux : profnte1, profntr1, profntp1
    - dossiers : /space/applisdata
    - profondeur d’aggragation souhaitée : 2 niveaux

# Use new `baj`

```bash
url=https://raw.githubusercontent.com/thydel/baj/2025-12-24-a/cmd/baj.sh
source <(curl -fsSL $url)
```

# Add new tool

- [mdq.yml][] better use `mardown` as source code
- [ssp.md][] produce the requested `duckdb` (ddb) DB
- [Makefile][] generate [cmd/mdq.sh][] [mdq.yml][] and use
  [cmd/mdq.sh][] to generate [out/ssp.yml][] from [ssp.md][]
- [prompt.md][] partial track of LLM interaction use to generate ddb SQL in [ssp.md][]

```bash
make; load out/ssp.yml
```

# Use new tool

## Generate conf

- That is, get NFS server and path from NFS client and path

```bash
with ssp:server-path | fn-ansible -l profnt[epr]1 | mk-conf > out/conf.js
```

- [out/conf.js][]

## Get FS data

```bash
for i in profnt{e,r,p}1; do get-files-stat $i; get-files-stat $i imn; done
```

## Make full DB from data

```bash
for i in profnt{e,r,p}1; do ingest-stat $i; done
```

## Make a small version of the DB

```bash
for i in profnt{e,r,p}1; do reduce-stat $i; done
reduce-stat profnte1
cp tmp/*-small.db out
```

> [!WARNING]
>
> - Can go on repo, but download the raw file to use with `duckdb`

```console
thy@tdews1-256g:2025-12-23-space-evol-ssp$ ls -lsh out/*-small.db
8.6M -rw-r--r-- 1 thy thy 8.6M Dec 24 19:06 out/profnte1-small.db
1.1M -rw-r--r-- 1 thy thy 1.1M Dec 24 19:06 out/profntp1-small.db
4.8M -rw-r--r-- 1 thy thy 4.8M Dec 24 19:06 out/profntr1-small.db
```

- [out/profnte1-small.db][]
- [out/profntp1-small.db][]
- [out/profntr1-small.db][]

## Make queries on DB

```console
thy@tdews1-256g:2025-12-23-space-evol-ssp$ query-stat profnte1 1 "$year"
┌──────────────────────────┬───────────────────────────────────┬────────┬──────────────┬──────────┬───────────┬────────────────────┐
│         time_key         │             path_part             │ files  │    bytes     │ min_size │ max_size  │      avg_size      │
│ timestamp with time zone │             varchar[]             │ int128 │    int128    │  int64   │   int64   │       double       │
├──────────────────────────┼───────────────────────────────────┼────────┼──────────────┼──────────┼───────────┼────────────────────┤
│ 2014-01-01 01:00:00+01   │ [ssp]                             │   9641 │   4202655022 │      220 │   3805753 │ 435914.84514054557 │
│ 2015-01-01 01:00:00+01   │ [cupidon]                         │      1 │        13405 │    13405 │     13405 │            13405.0 │
│ 2015-01-01 01:00:00+01   │ [ssp]                             │  26082 │  14139418075 │        0 │   9121811 │  542114.0278736294 │
│ 2016-01-01 01:00:00+01   │ [cupidon]                         │    316 │     27196081 │     4208 │   2964607 │  86063.54746835443 │
│ 2016-01-01 01:00:00+01   │ [ssp]                             │  27243 │  13649350754 │       80 │   9136348 │ 501022.30862973974 │
│ 2017-01-01 01:00:00+01   │ [cupidon]                         │   1473 │    369070095 │        0 │   4249952 │  250556.7515274949 │
│ 2017-01-01 01:00:00+01   │ [ssp]                             │  39429 │  21389942224 │       80 │  11955284 │  542492.6380075578 │
│ 2018-01-01 01:00:00+01   │ [201911xx_ssp_version_validation] │      4 │     29364828 │     2126 │  20971744 │          7341207.0 │
│ 2018-01-01 01:00:00+01   │ [cupidon]                         │   3657 │    788923104 │        3 │   9725847 │ 215729.58818703855 │
│ 2018-01-01 01:00:00+01   │ [ssp]                             │  67367 │  28598157051 │        0 │  10372414 │ 424512.84829367494 │
│ 2019-01-01 01:00:00+01   │ [201911xx_ssp_version_validation] │   5164 │   1430069299 │       41 │  20971744 │  276930.5381487219 │
│ 2019-01-01 01:00:00+01   │ [cupidon]                         │   2227 │    645393186 │     1233 │  12549334 │  289803.8554108666 │
│ 2019-01-01 01:00:00+01   │ [ssp]                             │ 123101 │  51955370489 │        0 │  15045472 │   422054.820748816 │
│ 2020-01-01 01:00:00+01   │ [ssp]                             │ 141584 │  59409199566 │        0 │  20886534 │  419603.9069810148 │
│ 2021-01-01 01:00:00+01   │ [ssp]                             │ 161215 │  56870597855 │        0 │ 239388505 │ 352762.44676363864 │
│ 2022-01-01 01:00:00+01   │ [ssp]                             │ 167666 │  70907851237 │        0 │ 246425290 │ 422911.33108083927 │
│ 2023-01-01 01:00:00+01   │ [ssp]                             │ 626980 │ 119272098892 │        0 │  68337386 │ 190232.70103033588 │
│ 2024-01-01 01:00:00+01   │ [ssp]                             │ 293886 │ 124321319808 │        0 │ 524288224 │  423025.6623588739 │
│ 2025-01-01 01:00:00+01   │ [ssp]                             │ 325778 │  87721734509 │        0 │ 327155712 │ 269268.44203414593 │
│ 2025-01-01 01:00:00+01   │ [ssp_stats]                       │      3 │         1632 │       68 │       952 │              544.0 │
├──────────────────────────┴───────────────────────────────────┴────────┴──────────────┴──────────┴───────────┴────────────────────┤
│ 20 rows                                                                                                                7 columns │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

<!--
bin=$INFRA/infra-lib-2023/bin
. <(echo ${nodes[@]} | sort | $bin/fmt-nodes.jq)

find -maxdepth 1 -type f | cut -c 3- | grep -v \~ | jq -Rr '"[\(.)]: \(.) \u0027sibling file\u0027", "- [\(.)][]"' | env LANG=C sort
find out -type f | grep -v \~ | jq -Rr '"[\(.)]: \(.) \u0027sibling file\u0027", "- [\(.)][]"' | env LANG=C sort
find cmd -type f | grep -v \~ | jq -Rr '"[\(.)]: \(.) \u0027sibling file\u0027", "- [\(.)][]"' | env LANG=C sort
-->

[Makefile]: Makefile 'sibling file'
[mdq.yml]: mdq.yml 'sibling file'
[prompt.md]: prompt.md 'sibling file'
[space-evol-ssp.md]: space-evol-ssp.md 'sibling file'
[ssp.md]: ssp.md 'sibling file'

[out/conf.js]: out/conf.js 'sibling file'
[out/ssp.yml]: out/ssp.yml 'sibling file'

[out/profnte1-small.db]: out/profnte1-small.db 'sibling file'
[out/profntp1-small.db]: out/profntp1-small.db 'sibling file'
[out/profntr1-small.db]: out/profntr1-small.db 'sibling file'

[cmd/mdq.sh]: cmd/mdq.sh 'sibling file'

[Local Variables:]::
[indent-tabs-mode: nil]::
[End:]::
