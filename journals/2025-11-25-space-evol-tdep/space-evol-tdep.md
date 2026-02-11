---
title: Space evol tdep
date: 2025-11-25
tags: [ space, evolution ]
---

<!--
(delete-matching-lines "INFRADESK-nnnn")
(delete-matching-lines "INFRA-nnnn")
-->

```yml
nodes: [ prostrq1, prostrk1, prostro1, prostrm1, prostrj1, prostrl1, prostrc1 ]
tickets: [ INFRADESK-3466 ]
```

[2025-11-25 Space-evol-tdep]:
    ../../2025/2025-11-25-space-evol-tdep/space-evol-tdep.md
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

[INFRADESK-3466]: https://epiconcept.atlassian.net/browse/INFRADESK-3466 "epiconcept.atlassian.net"

# Latest news

## 2025-12-05 found a way to use `duckdb` without `docker` on `work1`

```bash
what="'esisdocs-%'"
asum () { echo "format_bytes(sum($1)::bigint)"; }
sql="select $what as applis, $(asum sum) as sum, $(asum cnt) as cnt from hours where appli like $what"
<<< "$sql" ssh work1 duckdb-static -readonly -markdown /space2/duckdb/tdep-hours.db
```
|   applis   |   sum   |   cnt   |
|------------|---------|---------|
| esisdocs-% | 1.3 TiB | 6.7 MiB |

- We only need `-readonly` because `tdep-hours.db` belong to `www-data` mode 664
- See [Use `staticx` instead of `docker` to run `duckdb` on `work1`](#use-staticx-instead-of-docker-to-run-duckdb-on-work1) for details about `staticx`

## 2025-12-03

- See infra for info about the `tdep.db` and `tdep-hours.db` on `work1`
- And how you can use `duckdb` on `work1` (or your WS)

### Top .99% summed applis size by last 6 day in MiB 2025-12-02

|     appli     |  11-26  |  11-27  |  11-28  | 11-29  | 11-30  | 12-01  | 12-02  |  total   |
|---------------|---------|---------|---------|--------|--------|--------|--------|----------|
| esisdocs-idf  | 702.96  | 907.17  | 1014.83 | 210.85 | 173.62 | 907.11 | 761.93 | 4678.46  |
| esisdocs-naq  | 615.51  | 697.51  | 672.15  | 12.0   | 0.0    | 723.35 | 653.29 | 3373.81  |
| esisdocs-occ  | 394.79  | 527.91  | 545.71  | 8.34   | 77.55  | 594.81 | 428.23 | 2577.34  |
| esisfiles     | 25.61   | 543.9   | 485.27  |        |        | 931.36 | 586.85 | 2572.98  |
| esisdoccr-idf | 357.4   | 400.98  | 404.1   | 170.78 |        | 190.19 | 302.97 | 1826.43  |
| esisdoccu     | 233.88  | 1076.97 | 119.04  |        | 3.07   | 73.71  | 42.29  | 1548.96  |
| esisdocs-ges  | 533.32  | 161.4   | 302.71  | 0.07   | 0.01   | 92.13  | 178.43 | 1268.05  |
| esisdoccr-naq | 39.31   | 138.9   | 175.45  | 69.86  |        | 246.71 | 363.01 | 1033.24  |
| esisdoccr-occ | 20.85   | 247.03  | 78.39   | 134.58 |        | 51.44  | 301.95 | 834.24   |
| esisdocs-nor  | 91.21   | 233.53  | 75.3    | 0.43   |        | 44.93  | 81.28  | 526.68   |
| esisdoccr-nor | 0.82    | 54.3    | 71.93   | 98.33  |        | 2.99   | 70.4   | 298.78   |
| esis3d-idf    | 20.85   | 36.77   | 17.65   | 29.56  |        | 133.05 | 21.02  | 258.92   |
| esisdoccr-ges | 18.66   | 39.7    | 63.63   | 19.73  |        | 9.59   | 82.32  | 233.62   |
| esisbci       |         |         |         |        |        | 3.56   | 226.82 | 230.38   |
| esisdocs      |         |         |         | 140.57 |        | 0.08   | 0.71   | 141.35   |
| esis3d-ges    |         | 23.61   | 0.25    |        |        | 61.62  | 39.03  | 124.5    |
| esisdocs-guy  | 18.3    | 11.06   | 26.97   | 0.79   | 0.0    | 34.63  | 32.09  | 123.86   |
| esis3d-naq    |         | 35.45   | 13.96   |        |        | 4.65   | 40.49  | 94.55    |
|  TOTAL        | 3073.46 | 5136.2  | 4067.35 | 895.9  | 254.25 | 4105.9 | 4213.1 | 21746.15 |

### Summed node size last 6 hours

|   node   |    05     |    06     |    07    |    08     |    09     |    10     |    11     |   total   |
|----------|-----------|-----------|----------|-----------|-----------|-----------|-----------|-----------|
| prostrq1 | 183.8 MiB | 138.3 MiB | 9.1 MiB  | 144.8 MiB | 412.0 MiB | 324.4 MiB | 485.2 MiB | 1.6 GiB   |
| prostrm1 | 4.2 MiB   | 12.7 MiB  | 6.0 MiB  | 226.1 MiB | 361.6 MiB | 59.0 MiB  | 91.4 MiB  | 761.4 MiB |
| prostro1 | 82.0 MiB  |           | 13.0 KiB | 40.9 MiB  | 43.4 MiB  | 353.8 MiB | 122.8 MiB | 643.1 MiB |
| prostrl1 | 117.8 MiB |           |          | 75.1 MiB  |           | 1.4 MiB   |           | 194.4 MiB |
| prostrj1 |           |           |          | 5.1 MiB   | 3.6 MiB   | 18.8 MiB  | 14.6 MiB  | 42.2 MiB  |
|  TOTAL   | 388.0 MiB | 151.0 MiB | 15.2 MiB | 492.3 MiB | 820.7 MiB | 757.5 MiB | 714.3 MiB | 3.2 GiB   |

# TL;DR

## DONE

### Use `duckdb` on `work1` via `docker`

- See [duckdb-on-work1.md][]
- Use `duckdb` on `tdep.db` from 2025-11-12 on `work1` via `debian:12` docker

```bash
run () { declare -f $1; echo "$@"; }
with () { declare -p $1; run ${@:2}; }
duck () { docker run --rm -v /usr/local/bin/duckdb:/usr/bin/duckdb -v /space2/duckdb:/data -w /data debian:12 duckdb tdep.db -markdown "$sql"; }
sql='select node, split, round(sum(size) / 1e9, 2) AS size_gb from stat group by node, split order by node'
with sql duck | ssh work1 bash
```

|   node   |  split  | size_gb |
|----------|---------|--------:|
| prostrc1 | split99 | 28.28   |
| prostrj1 | split3  | 249.86  |
| prostrk1 | split4  | 530.38  |
| prostrl1 | split1  | 190.5   |
| prostrm1 | split2  | 351.25  |
| prostro1 | split5  | 498.71  |
| prostrq1 | split6  | 1187.63 |

### Make a better smaller DB

- Aggregate by hours
- Use `timestamp` instead `unit64` for UTS
- Keep only appli, node and aggregated stat over size by hour
- The new DB is small enough to be included in repo

```console
thy@tdews1-256g:2025-11-25-space-evol-tdep$ ls -lsh tmp/tdep.db out/tdep-hours.{db,csv}
9.4M -rw-r--r-- 1 thy thy 9.4M Nov 29 14:58 out/tdep-hours.csv
3.3M -rw-r--r-- 1 thy thy 3.3M Nov 29 14:57 out/tdep-hours.db
119M -rw-r--r-- 1 thy thy 119M Nov 12 21:58 tmp/tdep.db
```
- [out/tdep-hours.db][]
- [out/tdep-hours.csv][]

### Use new DB to make table report

- See [tdep-hours-sql.md][]

- Choose either node or appli as first axis of reduction
- Choose start end and unit of time as second axis of reduction

####  Summed node size last 5 year

|   node   |   2020    |   2021   |   2022   |   2023    |   2024    |   2025    |   total   |
|----------|-----------|----------|----------|-----------|-----------|-----------|-----------|
| prostrq1 |           |          |          | 495.3 MiB | 436.0 GiB | 669.5 GiB | 1.0 TiB   |
| prostrk1 | 198.5 MiB | 10.8 GiB | 13.2 GiB | 136.7 GiB | 319.7 GiB | 74.2 MiB  | 480.9 GiB |
| prostro1 |           |          | 3.2 GiB  | 96.4 GiB  | 170.7 GiB | 194.0 GiB | 464.4 GiB |
| prostrm1 | 373.5 MiB | 3.3 GiB  | 3.7 GiB  | 85.3 GiB  | 162.5 GiB | 57.1 GiB  | 312.4 GiB |
| prostrj1 | 6.4 GiB   | 49.0 GiB | 49.7 GiB | 54.5 GiB  | 28.3 GiB  | 27.3 GiB  | 215.4 GiB |
| prostrl1 |           |          | 4.0 GiB  | 30.6 GiB  | 99.8 GiB  | 42.7 GiB  | 177.4 GiB |
|  TOTAL   | 7.0 GiB   | 63.2 GiB | 74.1 GiB | 404.3 GiB | 1.1 TiB   | 990.8 GiB | 2.6 TiB   |

#### Top .99% summed applis size by last 6 months and weeks in GiB

|     appli     | 25-05 | 25-06 | 25-07 | 25-08 | 25-09 | 25-10 | 25-11 | total  |
|---------------|-------|-------|-------|-------|-------|-------|-------|--------|
| esisdocs-idf  | 12.11 | 15.07 | 18.66 | 14.48 | 13.29 | 15.11 | 7.25  | 95.98  |
| esisdocs-naq  | 7.72  | 14.33 | 16.3  | 10.95 | 16.63 | 15.76 | 4.36  | 86.06  |
| esisdocs-occ  | 8.75  | 11.79 | 9.65  | 6.5   | 13.38 | 16.61 | 4.19  | 70.86  |
| esisdoccr-idf | 5.14  | 26.1  | 4.69  | 4.61  | 5.67  | 6.86  | 2.27  | 55.35  |
| esisfiles     | 0.01  |       | 0.0   | 0.0   | 7.79  | 12.35 | 10.65 | 30.8   |
| esisdocs-ges  | 1.46  | 3.87  | 3.82  | 2.21  | 3.32  | 4.48  | 1.72  | 20.88  |
| esisdoccr-occ | 2.98  | 4.08  | 2.98  | 2.46  | 2.99  | 3.72  | 1.36  | 20.57  |
| esisdoccu     | 2.26  | 2.5   | 3.05  | 2.88  | 2.51  | 4.77  | 1.15  | 19.13  |
| esisdoccr-naq | 2.99  | 2.88  | 2.26  | 1.98  | 2.51  | 3.52  | 1.33  | 17.47  |
| esisdoccr-ges | 0.66  | 0.97  | 0.51  | 0.65  | 1.01  | 1.54  | 0.81  | 6.15   |
| esisdocs-nor  |       |       | 0.03  | 0.31  | 1.42  | 3.04  | 0.69  | 5.48   |
| esisdocs-guy  | 0.39  | 0.58  | 0.71  | 0.82  | 0.76  | 0.53  | 0.14  | 3.94   |
| esisdoccr-nor |       |       |       | 0.62  | 0.86  | 1.45  | 0.66  | 3.6    |
| esis3d-idf    | 0.28  | 0.47  | 0.53  | 0.21  | 0.62  | 0.76  | 0.23  | 3.12   |
| esisdoccr-gua |       | 0.0   |       | 0.0   |       | 0.0   | 1.5   | 1.5    |
|  TOTAL        | 44.76 | 82.64 | 63.2  | 48.69 | 72.77 | 90.52 | 38.32 | 440.89 |

### Rebuild full and reduced DB date 2025-12-02

- And copy them on `work1`
- See [rebuild-db.md][]

## TODO

- Add a script on `work1`
- More pipeline, report and plot

## TODO MAYBE

- Generate trends (how much space next year)

<!-- markdown-toc-generate-toc -->
<!-- https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1036359 -->
<!--
mkdir -p tmp; pandoc README.md -t jira > tmp/README.jira
< README.md pandoc -f gfm -t gfm --toc --toc-depth=6 --template ../toc.md --columns=196 | grep -v Table.of.Contents
-->

# Table of Contents

<details><summary>Expand</summary>

-   [Latest news](#latest-news)
    -   [2025-12-05 found a way to use `duckdb` without `docker` on `work1`](#2025-12-05-found-a-way-to-use-duckdb-without-docker-on-work1)
    -   [2025-12-03](#2025-12-03)
        -   [Top .99% summed applis size by last 6 day in MiB 2025-12-02](#top-99-summed-applis-size-by-last-6-day-in-mib-2025-12-02)
        -   [Summed node size last 6 hours](#summed-node-size-last-6-hours)
-   [TL;DR](#tldr)
    -   [DONE](#done)
        -   [Use `duckdb` on `work1` via `docker`](#use-duckdb-on-work1-via-docker)
        -   [Make a better smaller DB](#make-a-better-smaller-db)
        -   [Use new DB to make table report](#use-new-db-to-make-table-report)
            -   [Summed node size last 5 year](#summed-node-size-last-5-year)
            -   [Top .99% summed applis size by last 6 months and weeks in GiB](#top-99-summed-applis-size-by-last-6-months-and-weeks-in-gib)
        -   [Rebuild full and reduced DB date 2025-12-02](#rebuild-full-and-reduced-db-date-2025-12-02)
    -   [TODO](#todo)
    -   [TODO MAYBE](#todo-maybe)
-   [See also](#see-also)
-   [Per request INFRADESK-3466](#per-request-infradesk-3466)
-   [Env and tools used](#env-and-tools-used)
-   [Try duckdb on `work1`](#try-duckdb-on-work1)
-   [First try CTE lib on full DB](#first-try-cte-lib-on-full-db)
-   [Then make hour reduced DB](#then-make-hour-reduced-db)
-   [Rebuild full and reduced DB date 2025-12-02](#rebuild-full-and-reduced-db-date-2025-12-02-1)
-   [Use `staticx` instead of `docker` to run `duckdb` on `work1`](#use-staticx-instead-of-docker-to-run-duckdb-on-work1)

</details>

# See also

<details><summary>Expand</summary>

- [2025-11-05 Space-evol-tdep][]
- [2025-11-03 Space-evol][]
- [2025-10-22 Space-evol][]
- [2025-10-16 Space-evol][]
- [2025-08-01 Prostrc1-space][]

</details>

# Per request INFRADESK-3466

- [INFRADESK-3466][] suivi de la conso disque régulière pour l'équipe dépistage

<details><summary>Expand</summary>

- **Priority** Medium
- **Description**

    Bonjour, 

    J’aimerais avoir le résultat des commandes suivantes 1 fois par
    semaine, via 2 mail (le dimanche soir), sous forme de fichier
    joint (analyse_tdep.csv, proposition de nom, s’il est différent ce
    n’est pas un souci)

    Le premier, correspondant sur profntd1 à : 

    ```bash
    du --max-depth=1 /space/applisdata.store/split1 | grep -v '\./\.'|awk -F "./" {'print $2" "$1'}|awk -F " " {'print $1";"$2'}|grep -v "\;\." > analyse_tdep.csv
    du --max-depth=1 /space/applisdata.store/split2 | grep -v '\./\.'|awk -F "./" {'print $2" "$1'}|awk -F " " {'print $1";"$2'}|grep -v "\;\." >> analyse_tdep.csv
    du --max-depth=1 /space/applisdata.store/split3 | grep -v '\./\.'|awk -F "./" {'print $2" "$1'}|awk -F " " {'print $1";"$2'}|grep -v "\;\.">> analyse_tdep.csv
    du --max-depth=1 /space/applisdata.store/split4 | grep -v '\./\.'|awk -F "./" {'print $2" "$1'}|awk -F " " {'print $1";"$2'}|grep -v "\;\.">> analyse_tdep.csv
    du --max-depth=1 /space/applisdata.store/split5 | grep -v '\./\.'|awk -F "./" {'print $2" "$1'}|awk -F " " {'print $1";"$2'}|grep -v "\;\.">> analyse_tdep.csv
    du --max-depth=1 /space/applisdata.store/split6 | grep -v '\./\.'|awk -F "./" {'print $2" "$1'}|awk -F " " {'print $1";"$2'}|grep -v "\;\.">> analyse_tdep.csv
    ```

    Le second, correspondant sur prot3cbdde1 à :

    ```du --max-depth=1 /data/mysql | grep -v '\./\.'|awk -F "./" {'print $2" "$1'}|awk -F " " {'print $1";"$2'}|grep -v "\;\." > analyse_prot3.csv```

    ainsi que la taille du fichier ibdata1
 
- **Environment**

    L’objectif est de doter l'équipe dépistage d’un outil permettant
    de mesurer la croissance de l’espace disque occupé par les
    applications dépistage

    - Appli par appli
    - Région par région

    A la fois en termes de pièces jointes (profntd1/applisdata) et en
    terme d’occupation bdd (prot3cbdd)

</details>

# Env and tools used

- See [env-and-tool.md][]

# Try duckdb on `work1`

- See [duckdb-on-work1.md][]

# First try CTE lib on full DB

- See [tdep-sql.md][]

# Then make hour reduced DB

- And use it to make report of size by time and appli or node
- See [tdep-hours-sql.md][]

# Rebuild full and reduced DB date 2025-12-02

- And copy them on `work1`
- See [rebuild-db.md][]

# Use `staticx` instead of `docker` to run `duckdb` on `work1`

```bash
sudo apt update && sudo apt install -y build-essential scons patchelf python3-pip
pipx install staticx
staticx /usr/local/bin/duckdb duckdb-static
rsync -av duckdb-static work1:
ssh work1 -l root install /home/$USER/duckdb-static /usr/local/bin
```

<!--
bin=$INFRA/infra-lib-2023/bin
. <(echo ${nodes[@]} | sort | $bin/fmt-nodes.jq)

find -maxdepth 1 -type f | cut -c 3- | grep -v \~ | jq -Rr '"[\(.)]: \(.) \u0027sibling file\u0027", "- [\(.)][]"' | env LANG=C sort
find out -type f | grep -v \~ | jq -Rr '"[\(.)]: \(.) \u0027sibling file\u0027", "- [\(.)][]"' | env LANG=C sort
-->

[Local Variables:]::
[indent-tabs-mode: nil]::
[End:]::

[duckdb-on-work1.md]: duckdb-on-work1.md 'sibling file'
[env-and-tool.md]: env-and-tool.md 'sibling file'
[rebuild-db.md]: rebuild-db.md 'sibling file'
[space-evol-tdep.md]: space-evol-tdep.md 'sibling file'
[tdep-hours-sql.md]: tdep-hours-sql.md 'sibling file'
[tdep-hours-sql.yml]: tdep-hours-sql.yml 'sibling file'
[tdep-sql.md]: tdep-sql.md 'sibling file'
[tdep-sql.yml]: tdep-sql.yml 'sibling file'
[tdep.yml]: tdep.yml 'sibling file'

[out/report-2025-monthly.csv]: out/report-2025-monthly.csv 'sibling file'
[out/report.js]: out/report.js 'sibling file'
[out/report.sql]: out/report.sql 'sibling file'
[out/sum-size.md]: out/sum-size.md 'sibling file'
[out/tdep-hours.csv]: out/tdep-hours.csv 'sibling file'
[out/tdep-hours.db]: out/tdep-hours.db 'sibling file'
