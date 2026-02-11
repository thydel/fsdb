---
title: Prostrc1 space2
date: 2026-01-29
tags: [ space, evolution ]
---

<!--
(delete-matching-lines "INFRADESK-nnnn")
(delete-matching-lines "INFRA-nnnn")
-->

```yml
nodes: [ promailmerge1, prostrc1]
repos: [ baj ]
```

[2026-01-29 Prostrc1-space2]:
    ../../2026/2026-01-29-prostrc1-space2/prostrc1-space2.md
    "sibling file"

<!-- Related -->

[2025-12-23 Space-evol-ssp]:
    ../../2025/2025-12-23-space-evol-ssp/space-evol-ssp.md
    "sibling file"

<!-- Repos -->

[baj]:
    https://github.com/thydel/baj
    "github.com repo"

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

[INFRA-nnnn]: https://epiconcept.atlassian.net/browse/INFRA-nnnn "epiconcept.atlassian.net"
[INFRADESK-nnnn]: https://epiconcept.atlassian.net/browse/INFRADESK-nnnn "epiconcept.atlassian.net"

# TL;DR

```bash
latest-growth 10 year | merge-cte | ddb -json | fmt-auto
latest-growth 12 month | merge-cte | ddb -json | fmt-auto
latest-growth 12 week | merge-cte | ddb -json | fmt-auto
latest-growth 14 day | merge-cte | ddb -json | fmt-auto
latest-growth 12 hour | merge-cte | ddb -json | fmt-auto
latest-growth 48 hour | merge-cte | ddb -json | fmt-auto
```

```txt
| date                   | cnt   | size   | size_diff   | size_rate   | size_cumul   | size_diff_cumul   |
|------------------------|-------|--------|-------------|-------------|--------------|-------------------|
| 2016-01-01 01:00:00+01 | 55K   | 8G     |             |             | 8G           |                   |
| 2017-01-01 01:00:00+01 | 67K   | 12G    | 4G          | 50.70%      | 20G          | 4G                |
| 2018-01-01 01:00:00+01 | 116K  | 20G    | 8G          | 66.89%      | 41G          | 12G               |
| 2019-01-01 01:00:00+01 | 184K  | 17G    | -3G         | -15.42%     | 59G          | 9G                |
| 2020-01-01 01:00:00+01 | 183K  | 14G    | -2G         | -15.91%     | 74G          | 6G                |
| 2021-01-01 01:00:00+01 | 779K  | 75G    | 60G         | 410.74%     | 150G         | 67G               |
| 2022-01-01 01:00:00+01 | 758K  | 66G    | -9G         | -12.19%     | 216G         | 58G               |
| 2023-01-01 01:00:00+01 | 485K  | 41G    | -24G        | -36.94%     | 258G         | 33G               |
| 2024-01-01 01:00:00+01 | 579K  | 58G    | 16G         | 39.98%      | 317G         | 50G               |
| 2025-01-01 01:00:00+01 | 601K  | 55G    | -3G         | -6.33%      | 372G         | 46G               |
| 2026-01-01 01:00:00+01 | 54K   | 6G     | -48G        | -87.49%     | 379G         | -1G               |

| date                   | cnt   | size   | size_diff   | size_rate   | size_cumul   | size_diff_cumul   |
|------------------------|-------|--------|-------------|-------------|--------------|-------------------|
| 2025-01-01 01:00:00+01 | 4K    | 368M   |             |             | 368M         |                   |
| 2025-02-01 01:00:00+01 | 45K   | 3G     | 3G          | 959.22%     | 4G           | 3G                |
| 2025-03-01 01:00:00+01 | 48K   | 4G     | 725M        | 18.59%      | 8G           | 4G                |
| 2025-04-01 02:00:00+02 | 46K   | 4G     | -382M       | -8.26%      | 12G          | 3G                |
| 2025-05-01 02:00:00+02 | 43K   | 3G     | -431M       | -10.17%     | 16G          | 3G                |
| 2025-06-01 02:00:00+02 | 46K   | 4G     | 667M        | 17.49%      | 20G          | 4G                |
| 2025-07-01 02:00:00+02 | 53K   | 4G     | 477M        | 10.64%      | 25G          | 4G                |
| 2025-08-01 02:00:00+02 | 39K   | 3G     | -1G         | -22.00%     | 29G          | 3G                |
| 2025-09-01 02:00:00+02 | 63K   | 5G     | 1G          | 51.99%      | 35G          | 5G                |
| 2025-10-01 02:00:00+02 | 60K   | 5G     | -45M        | -0.77%      | 41G          | 5G                |
| 2025-11-01 01:00:00+01 | 47K   | 4G     | -1G         | -20.96%     | 45G          | 4G                |
| 2025-12-01 01:00:00+01 | 54K   | 5G     | 1G          | 27.56%      | 51G          | 5G                |
| 2026-01-01 01:00:00+01 | 54K   | 6G     | 1G          | 19.96%      | 58G          | 6G                |

| date                   | cnt   | size   | size_diff   | size_rate   | size_cumul   | size_diff_cumul   |
|------------------------|-------|--------|-------------|-------------|--------------|-------------------|
| 2025-11-03 01:00:00+01 | 2K    | 195M   |             |             | 195M         |                   |
| 2025-11-10 01:00:00+01 | 9K    | 951M   | 755M        | 386.69%     | 1G           | 755M              |
| 2025-11-17 01:00:00+01 | 13K   | 1G     | 225M        | 23.66%      | 2G           | 980M              |
| 2025-11-24 01:00:00+01 | 12K   | 1G     | 105M        | 8.96%       | 3G           | 1G                |
| 2025-12-01 01:00:00+01 | 13K   | 1G     | 31M         | 2.46%       | 4G           | 1G                |
| 2025-12-08 01:00:00+01 | 14K   | 1G     | 190M        | 14.47%      | 6G           | 1G                |
| 2025-12-15 01:00:00+01 | 13K   | 1G     | 100M        | 6.70%       | 7G           | 1G                |
| 2025-12-22 01:00:00+01 | 7K    | 886M   | -717M       | -44.71%     | 8G           | 691M              |
| 2025-12-29 01:00:00+01 | 7K    | 806M   | -79M        | -9.01%      | 9G           | 611M              |
| 2026-01-05 01:00:00+01 | 13K   | 1G     | 796M        | 98.77%      | 11G          | 1G                |
| 2026-01-12 01:00:00+01 | 15K   | 2G     | 819M        | 51.11%      | 13G          | 2G                |
| 2026-01-19 01:00:00+01 | 14K   | 1G     | -713M       | -29.46%     | 15G          | 1G                |
| 2026-01-26 01:00:00+01 | 9K    | 1G     | -618M       | -36.19%     | 16G          | 895M              |

| date                   | cnt   | size   | size_diff   | size_rate   | size_cumul   | size_diff_cumul   |
|------------------------|-------|--------|-------------|-------------|--------------|-------------------|
| 2026-01-16 01:00:00+01 | 2K    | 277M   |             |             | 277M         |                   |
| 2026-01-17 01:00:00+01 | 248   | 31M    | -245M       | -88.65%     | 308M         | -245M             |
| 2026-01-18 01:00:00+01 | 193   | 28M    | -2M         | -8.42%      | 337M         | -248M             |
| 2026-01-19 01:00:00+01 | 3K    | 385M   | 356M        | 1236.05%    | 722M         | 107M              |
| 2026-01-20 01:00:00+01 | 2K    | 362M   | -22M        | -5.93%      | 1G           | 84M               |
| 2026-01-21 01:00:00+01 | 2K    | 327M   | -34M        | -9.63%      | 1G           | 50M               |
| 2026-01-22 01:00:00+01 | 2K    | 303M   | -23M        | -7.23%      | 1G           | 26M               |
| 2026-01-23 01:00:00+01 | 2K    | 275M   | -28M        | -9.41%      | 1G           | -2M               |
| 2026-01-24 01:00:00+01 | 296   | 34M    | -241M       | -87.62%     | 1G           | -243M             |
| 2026-01-25 01:00:00+01 | 150   | 21M    | -12M        | -37.43%     | 1G           | -256M             |
| 2026-01-26 01:00:00+01 | 3K    | 350M   | 328M        | 1541.84%    | 2G           | 72M               |
| 2026-01-27 01:00:00+01 | 2K    | 313M   | -36M        | -10.37%     | 2G           | 36M               |
| 2026-01-28 01:00:00+01 | 3K    | 351M   | 37M         | 12.05%      | 2G           | 74M               |
| 2026-01-29 01:00:00+01 | 754   | 75M    | -276M       | -78.60%     | 3G           | -202M             |

| date                   |   cnt | size   | size_diff   | size_rate   | size_cumul   | size_diff_cumul   |
|------------------------|-------|--------|-------------|-------------|--------------|-------------------|
| 2026-01-28 05:00:00+01 |     3 | 323K   |             |             | 323K         |                   |
| 2026-01-28 06:00:00+01 |     2 | 145K   | -177K       | -54.84%     | 469K         | -177K             |
| 2026-01-28 07:00:00+01 |    24 | 2M     | 2M          | 1963.43%    | 3M           | 2M                |
| 2026-01-28 08:00:00+01 |    77 | 8M     | 5M          | 194.45%     | 12M          | 8M                |
| 2026-01-28 09:00:00+01 |   282 | 35M    | 27M         | 314.50%     | 47M          | 35M               |
| 2026-01-28 10:00:00+01 |   411 | 46M    | 10M         | 28.78%      | 94M          | 45M               |
| 2026-01-28 11:00:00+01 |   399 | 42M    | -3M         | -8.41%      | 136M         | 42M               |
| 2026-01-28 12:00:00+01 |   216 | 27M    | -15M        | -35.46%     | 163M         | 27M               |
| 2026-01-28 13:00:00+01 |   190 | 16M    | -10M        | -40.19%     | 180M         | 16M               |
| 2026-01-28 14:00:00+01 |   453 | 42M    | 26M         | 161.58%     | 222M         | 42M               |
| 2026-01-28 15:00:00+01 |   435 | 41M    | -1M         | -3.76%      | 264M         | 40M               |
| 2026-01-28 16:00:00+01 |   304 | 28M    | -12M        | -31.49%     | 292M         | 27M               |
| 2026-01-28 17:00:00+01 |   196 | 29M    | 1M          | 3.73%       | 321M         | 28M               |
| 2026-01-28 18:00:00+01 |    63 | 12M    | -17M        | -58.48%     | 333M         | 11M               |
| 2026-01-28 19:00:00+01 |    41 | 10M    | -1M         | -12.51%     | 344M         | 10M               |
| 2026-01-28 20:00:00+01 |     7 | 561K   | -10M        | -94.84%     | 344M         | 238K              |
| 2026-01-28 21:00:00+01 |    11 | 2M     | 1M          | 331.83%     | 347M         | 2M                |
| 2026-01-28 22:00:00+01 |    11 | 3M     | 1M          | 51.05%      | 350M         | 3M                |
| 2026-01-28 23:00:00+01 |     7 | 621K   | -2M         | -83.03%     | 351M         | 298K              |
| 2026-01-29 00:00:00+01 |     3 | 160K   | -461K       | -74.21%     | 351M         | -162K             |
| 2026-01-29 01:00:00+01 |     6 | 210K   | 50K         | 31.59%      | 351M         | -112K             |
| 2026-01-29 02:00:00+01 |     4 | 141K   | -69K        | -32.78%     | 351M         | -181K             |
| 2026-01-29 06:00:00+01 |     8 | 528K   | 386K        | 272.85%     | 352M         | 205K              |
| 2026-01-29 07:00:00+01 |     8 | 1M     | 575K        | 108.91%     | 353M         | 781K              |
| 2026-01-29 08:00:00+01 |    66 | 6M     | 5M          | 493.54%     | 359M         | 6M                |
| 2026-01-29 09:00:00+01 |   375 | 33M    | 26M         | 421.26%     | 393M         | 33M               |
| 2026-01-29 10:00:00+01 |   287 | 33M    | 151K        | 0.44%       | 426M         | 33M               |
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
-   [See also](#see-also)
-   [Use baj](#use-baj)
-   [Start back from 2025-12-23 Space-evol-ssp](#start-back-from-2025-12-23-space-evol-ssp)
-   [Make the DB](#make-the-db)
    -   [Generate conf](#generate-conf)
    -   [Get FS data](#get-fs-data)
    -   [Make full DB from data](#make-full-db-from-data)
    -   [Merge DBs](#merge-dbs)
    -   [Make a small version of the DB](#make-a-small-version-of-the-db)
    -   [Make queries on DB](#make-queries-on-db)
-   [Use CTE lib](#use-cte-lib)
    -   [Root of file tree is deep](#root-of-file-tree-is-deep)
    -   [Show size and cnt sum since 2024-01](#show-size-and-cnt-sum-since-2024-01)
-   [Add new CTE](#add-new-cte)
    -   [Show growth](#show-growth)

</details>

# See also

<details><summary>Expand</summary>

- [2025-12-23 Space-evol-ssp][]

</details>

<!--

# Per request INFRA-nnnn
# Per request INFRADESK-nnnn

- [INFRA-nnnn][] do something
- [INFRADESK-nnnn][] do something

- **Priority** High
- **Description**

-->

# Use [baj][]

```bash
source baj.sh
```

# Start back from [2025-12-23 Space-evol-ssp][]

- Import
  [2025/2025-12-23-space-evol-ssp/fsdb-cte.md][], 
  [2025/2025-12-23-space-evol-ssp/ssp.md][] (as [mailmerge.md][]),
  [2025/2025-12-23-space-evol-ssp/mdq.yml][] and
  [2025/2025-12-23-space-evol-ssp/Makefile][] from
  [2025-12-23 Space-evol-ssp][]

- Edit [mailmerge.md][] for [Minimally adapts for mailmerge][]
- Edit [Makefile][] for [Adpats Makefile too][]

```bash
make; load out/mailmerge.yml
```

[Adpats Makefile too]:
    https://github.com/Epiconcept-Paris/tde-log.git/commit/ada15d7231e3390ee6f4a99692baf27d2a179326
    "github.com commit"

[Minimally adapts for mailmerge]:
    https://github.com/Epiconcept-Paris/tde-log.git/commit/6f407b2ad85eca0ef6406d1177ae4ff62fdecb1e
    "github.com commit"

[2025/2025-12-23-space-evol-ssp/fsdb-cte.md]:
    https://github.com/Epiconcept-Paris/tde-log.git/blob/main/2025/2025-12-23-space-evol-ssp/fsdb-cte.md
    "github.com file"

[2025/2025-12-23-space-evol-ssp/ssp.md]:
    https://github.com/Epiconcept-Paris/tde-log.git/blob/main/2025/2025-12-23-space-evol-ssp/ssp.md
    "github.com file"

[2025/2025-12-23-space-evol-ssp/mdq.yml]:
    https://github.com/Epiconcept-Paris/tde-log.git/blob/main/2025/2025-12-23-space-evol-ssp/mdq.yml
    "github.com file"

[2025/2025-12-23-space-evol-ssp/Makefile]:
    https://github.com/Epiconcept-Paris/tde-log.git/blob/main/2025/2025-12-23-space-evol-ssp/Makefile
    "github.com file"

# Make the DB

## Generate conf

- That is, get NFS server and path from NFS client and path

```bash
source with.sh
source baj-ansible.sh
with mailmerge:server-path-simple | fn-ansible -l promailmerge1 | mk-conf > out/conf.js
```

- [out/conf.js][]

## Get FS data

```bash
mkdir -p tmp; for i in promailmerge1; do get-files-stat $i; get-files-stat $i imn; done
```

## Make full DB from data

```bash
for i in promailmerge1; do ingest-stat $i; done
```

## Merge DBs

> [!NOTE]
>
> - We only have one server but the lib was made to work on a DB with server col

```bash
(cd tmp; merge-db promailmerge1 | duckdb mailmerge.db)
(cd out; merge-db promailmerge1-small | duckdb mailmerge-small.db)
```

## Make a small version of the DB

```bash
for i in promailmerge1; do reduce-stat $i; done
cp tmp/*-small.db out
```

## Make queries on DB


```bash
day="time_bucket(INTERVAL '1 day', date)"
year="time_bucket(INTERVAL '1 year', date)"
hour='hour(date)'
dow='dayofweek(date)'
query-stat promailmerge1 1 "$year"
```

```txt
┌──────────────────────────┬─────────────┬────────┬─────────────┬──────────┬────────────┬────────────────────┐
│           time           │    depth    │ files  │    bytes    │ min_size │  max_size  │      avg_size      │
│ timestamp with time zone │  varchar[]  │ int128 │   int128    │  int64   │   int64    │       double       │
├──────────────────────────┼─────────────┼────────┼─────────────┼──────────┼────────────┼────────────────────┤
│ 2014-01-01 01:00:00+01   │ [mailmerge] │  17849 │  1085750052 │        0 │  167720083 │ 60829.741274020955 │
│ 2015-01-01 01:00:00+01   │ [mailmerge] │  12152 │   792052548 │       59 │   81030855 │  65178.78110599078 │
│ 2016-01-01 01:00:00+01   │ [mailmerge] │  60366 │  9411281175 │       59 │  104639857 │ 155903.67383957858 │
│ 2017-01-01 01:00:00+01   │ [mailmerge] │  69379 │ 13432962313 │        0 │   14129477 │ 193617.12208305107 │
│ 2018-01-01 01:00:00+01   │ [mailmerge] │ 119303 │ 22418672555 │        0 │ 1005886136 │   187913.736913573 │
│ 2019-01-01 01:00:00+01   │ [mailmerge] │ 189113 │ 18960852365 │        0 │  581520938 │ 100262.02516484853 │
│ 2020-01-01 01:00:00+01   │ [mailmerge] │ 187709 │ 15944748594 │        0 │  203625696 │  84943.97495058841 │
│ 2021-01-01 01:00:00+01   │ [mailmerge] │ 797980 │ 81435519225 │       59 │  492526869 │ 102052.08053459987 │
│ 2022-01-01 01:00:00+01   │ [mailmerge] │ 776242 │ 71512336284 │       36 │ 1036613468 │  92126.34240868183 │
│ 2023-01-01 01:00:00+01   │ [mailmerge] │ 497556 │ 45096483350 │       11 │   37299299 │  90635.99544573876 │
│ 2024-01-01 01:00:00+01   │ [mailmerge] │ 593391 │ 63127405373 │       10 │  101310728 │ 106384.16385317607 │
│ 2025-01-01 01:00:00+01   │ [mailmerge] │ 616135 │ 59133231450 │       10 │   46139273 │  95974.47223416946 │
│ 2026-01-01 01:00:00+01   │ [mailmerge] │  56319 │  7400168826 │       18 │    4415184 │  131397.3761252863 │
├──────────────────────────┴─────────────┴────────┴─────────────┴──────────┴────────────┴────────────────────┤
│ 13 rows                                                                                          7 columns │
└────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

# Use CTE lib

```bash
load out/fsdb-cte.yml
```

## Root of file tree is deep

```bash
start | grpcnt path[4] | order cnt | limit 20 | merge-cte | duckdb tmp/mailmerge.db -box
```

```txt
┌─────────┬────────┐
│ path[4] │  cnt   │
├─────────┼────────┤
│ 2021    │ 797540 │
│ 2022    │ 775981 │
│ 2025    │ 614544 │
│ 2024    │ 592694 │
│ 2023    │ 496254 │
│ 2019    │ 188757 │
│ 2020    │ 187470 │
│ 2018    │ 119057 │
│ 2017    │ 69276  │
│ 2016    │ 60239  │
│ 2026    │ 55998  │
│ 2014    │ 17766  │
│ 2015    │ 11998  │
│ a8      │ 39     │
│ b0      │ 35     │
│ 35      │ 35     │
│ 69      │ 34     │
│ c0      │ 34     │
│ 41      │ 32     │
│ 87      │ 32     │
└─────────┴────────┘
```

## Show size and cnt sum since 2024-01

```bash
start | where 'length(path[4])' == 4 and path[4]::int \> 2023 | sum path[4:5] size,cnt | order 1 asc | merge-cte | ddb -box
```

```txt
┌────────────┬────────────┬───────┐
│ path[4:5]  │    size    │  cnt  │
├────────────┼────────────┼───────┤
│ [2024, 01] │ 5575848192 │ 52030 │
│ [2024, 02] │ 5292358325 │ 48292 │
│ [2024, 03] │ 5136464474 │ 49012 │
│ [2024, 04] │ 5099309643 │ 65240 │
│ [2024, 05] │ 4474360527 │ 45204 │
│ [2024, 06] │ 4687519704 │ 45930 │
│ [2024, 07] │ 5593561194 │ 51410 │
│ [2024, 08] │ 4668584877 │ 41583 │
│ [2024, 09] │ 7197671100 │ 53937 │
│ [2024, 10] │ 5918701898 │ 51283 │
│ [2024, 11] │ 4826111236 │ 44348 │
│ [2024, 12] │ 4537729880 │ 44425 │
│ [2025, 01] │ 4460246757 │ 53532 │
│ [2025, 02] │ 4067631580 │ 45957 │
│ [2025, 03] │ 4805567769 │ 49787 │
│ [2025, 04] │ 4425873909 │ 47665 │
│ [2025, 05] │ 3994968852 │ 44318 │
│ [2025, 06] │ 4674537529 │ 47205 │
│ [2025, 07] │ 5180357637 │ 54399 │
│ [2025, 08] │ 4032062664 │ 40788 │
│ [2025, 09] │ 6149680170 │ 64520 │
│ [2025, 10] │ 6091519530 │ 61888 │
│ [2025, 11] │ 4762155638 │ 48670 │
│ [2025, 12] │ 6161739375 │ 55815 │
│ [2026, 01] │ 7352463934 │ 55998 │
└────────────┴────────────┴───────┘
```

# Add new CTE

- Edit [fsdb-cte.md][] for [Adds new CTE][]

[Adds new CTE]:
    https://github.com/Epiconcept-Paris/tde-log.git/commit/47ac56021a0c5dbb574d612b11d56b7b71e37159
    "github.com commit"

## Show growth

```bash
start | last 6 month | span --bucket=month | growth size | chain acc size size_diff | order date asc | merge-cte | ddb -box
start | last 3 month | span --bucket=week | growth size | chain acc size size_diff | order date asc | merge-cte | ddb -box
```

```txt
┌────────────────────────┬───────────────┬───────┬────────────┬────────────┬─────────────┬───────────┬─────────────┬─────────────────┐
│          date          │    server     │  cnt  │    size    │    prev    │  size_diff  │ size_rate │ size_cumul  │ size_diff_cumul │
├────────────────────────┼───────────────┼───────┼────────────┼────────────┼─────────────┼───────────┼─────────────┼─────────────────┤
│ 2025-07-01 02:00:00+02 │ promailmerge1 │ 4413  │ 388060186  │ NULL       │ NULL        │ NULL      │ 388060186   │ NULL            │
│ 2025-08-01 02:00:00+02 │ promailmerge1 │ 40894 │ 4057150407 │ 388060186  │ 3669090221  │ 9.455     │ 4445210593  │ 3669090221      │
│ 2025-09-01 02:00:00+02 │ promailmerge1 │ 64700 │ 6166359327 │ 4057150407 │ 2109208920  │ 0.5199    │ 10611569920 │ 5778299141      │
│ 2025-10-01 02:00:00+02 │ promailmerge1 │ 62056 │ 6118914045 │ 6166359327 │ -47445282   │ -0.0077   │ 16730483965 │ 5730853859      │
│ 2025-11-01 01:00:00+01 │ promailmerge1 │ 48962 │ 4836166833 │ 6118914045 │ -1282747212 │ -0.2096   │ 21566650798 │ 4448106647      │
│ 2025-12-01 01:00:00+01 │ promailmerge1 │ 55901 │ 6168999302 │ 4836166833 │ 1332832469  │ 0.2756    │ 27735650100 │ 5780939116      │
│ 2026-01-01 01:00:00+01 │ promailmerge1 │ 56319 │ 7400168826 │ 6168999302 │ 1231169524  │ 0.1996    │ 35135818926 │ 7012108640      │
└────────────────────────┴───────────────┴───────┴────────────┴────────────┴─────────────┴───────────┴─────────────┴─────────────────┘
┌────────────────────────┬───────────────┬───────┬────────────┬────────────┬────────────┬───────────┬─────────────┬─────────────────┐
│          date          │    server     │  cnt  │    size    │    prev    │ size_diff  │ size_rate │ size_cumul  │ size_diff_cumul │
├────────────────────────┼───────────────┼───────┼────────────┼────────────┼────────────┼───────────┼─────────────┼─────────────────┤
│ 2025-10-27 01:00:00+01 │ promailmerge1 │ 4615  │ 434150413  │ NULL       │ NULL       │ NULL      │ 434150413   │ NULL            │
│ 2025-11-03 01:00:00+01 │ promailmerge1 │ 12973 │ 1237054386 │ 434150413  │ 802903973  │ 1.8494    │ 1671204799  │ 802903973       │
│ 2025-11-10 01:00:00+01 │ promailmerge1 │ 9308  │ 997420706  │ 1237054386 │ -239633680 │ -0.1937   │ 2668625505  │ 563270293       │
│ 2025-11-17 01:00:00+01 │ promailmerge1 │ 13453 │ 1233409569 │ 997420706  │ 235988863  │ 0.2366    │ 3902035074  │ 799259156       │
│ 2025-11-24 01:00:00+01 │ promailmerge1 │ 12992 │ 1343873673 │ 1233409569 │ 110464104  │ 0.0896    │ 5245908747  │ 909723260       │
│ 2025-12-01 01:00:00+01 │ promailmerge1 │ 13988 │ 1376896307 │ 1343873673 │ 33022634   │ 0.0246    │ 6622805054  │ 942745894       │
│ 2025-12-08 01:00:00+01 │ promailmerge1 │ 14449 │ 1576139433 │ 1376896307 │ 199243126  │ 0.1447    │ 8198944487  │ 1141989020      │
│ 2025-12-15 01:00:00+01 │ promailmerge1 │ 14329 │ 1681713339 │ 1576139433 │ 105573906  │ 0.067     │ 9880657826  │ 1247562926      │
│ 2025-12-22 01:00:00+01 │ promailmerge1 │ 7430  │ 929753676  │ 1681713339 │ -751959663 │ -0.4471   │ 10810411502 │ 495603263       │
│ 2025-12-29 01:00:00+01 │ promailmerge1 │ 7624  │ 846004878  │ 929753676  │ -83748798  │ -0.0901   │ 11656416380 │ 411854465       │
│ 2026-01-05 01:00:00+01 │ promailmerge1 │ 14217 │ 1681576601 │ 846004878  │ 835571723  │ 0.9877    │ 13337992981 │ 1247426188      │
│ 2026-01-12 01:00:00+01 │ promailmerge1 │ 15799 │ 2540952069 │ 1681576601 │ 859375468  │ 0.5111    │ 15878945050 │ 2106801656      │
│ 2026-01-19 01:00:00+01 │ promailmerge1 │ 14676 │ 1792359695 │ 2540952069 │ -748592374 │ -0.2946   │ 17671304745 │ 1358209282      │
│ 2026-01-26 01:00:00+01 │ promailmerge1 │ 9708  │ 1143772130 │ 1792359695 │ -648587565 │ -0.3619   │ 18815076875 │ 709621717       │
└────────────────────────┴───────────────┴───────┴────────────┴────────────┴────────────┴───────────┴─────────────┴─────────────────┘
```

<!--
bin=$INFRA/infra-lib-2023/bin
. <(echo ${nodes[@]} | sort | $bin/fmt-nodes.jq)

find -maxdepth 1 -type f | cut -c 3- | grep -v \~ | jq -Rr '"[\(.)]: \(.) \u0027sibling file\u0027", "- [\(.)][]"' | env LANG=C sort
find out -type f | grep -v \~ | jq -Rr '"[\(.)]: \(.) \u0027sibling file\u0027", "- [\(.)][]"' | env LANG=C sort
-->

[Makefile]: Makefile 'sibling file'
[fsdb-cte.md]: fsdb-cte.md 'sibling file'
[mailmerge.md]: mailmerge.md 'sibling file'
[mdq.yml]: mdq.yml 'sibling file'
[prostrc1-space2.md]: prostrc1-space2.md 'sibling file'

[out/conf.js]: out/conf.js 'sibling file'
[out/fsdb-cte.yml]: out/fsdb-cte.yml 'sibling file'
[out/mailmerge.yml]: out/mailmerge.yml 'sibling file'

[Local Variables:]::
[indent-tabs-mode: nil]::
[End:]::
