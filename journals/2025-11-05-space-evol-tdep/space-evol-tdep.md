---
title: Space evol tdep
date: 2025-11-05
tags: [ space, evolution ]
---

<!--
(delete-matching-lines "INFRADESK-nnnn")
(delete-matching-lines "INFRA-nnnn")`
-->

```yml
nodes: [ prostrq1, prostrk1, prostro1, prostrm1, prostrj1, prostrl1, prostrc1 ]
tickets: [ INFRADESK-3466 ]
```

[2025-11-05 Space-evol-tdep]:
    ../../2025/2025-11-05-space-evol-tdep/space-evol-tdep.md
    "sibling file"

<!-- Related -->

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

# TL;DR

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
-   [Per request INFRADESK-3466](#per-request-infradesk-3466)
-   [Env](#env)
-   [Tools](#tools)
    -   [Install `jqsh`](#install-jqsh)
        -   [Clone a specified `jqsh` tag](#clone-a-specified-jqsh-tag)
        -   [Add cloned repo `cmd` dir to `PATH`](#add-cloned-repo-cmd-dir-to-path)
        -   [Source `jqsh` from cloned repo](#source-jqsh-from-cloned-repo)
-   [Use `ejq`](#use-ejq)
-   [Add lib build DB](#add-lib-build-db)
-   [Install `duckdb`](#install-duckdb)
-   [Use lib](#use-lib)
    -   [Extract data from links](#extract-data-from-links)
    -   [Get stat from data](#get-stat-from-data)
    -   [Make DB from stat](#make-db-from-stat)
-   [Add lib to request DB](#add-lib-to-request-db)
    -   [List appli without any files](#list-appli-without-any-files)
    -   [Count empty files](#count-empty-files)
        -   [We have CTE funcs](#we-have-cte-funcs)
        -   [We have pipeline of CTE funcs](#we-have-pipeline-of-cte-funcs)
        -   [That generate sequence of CTE](#that-generate-sequence-of-cte)
        -   [Then merged as SQL](#then-merged-as-sql)
        -   [That can be used on DB](#that-can-be-used-on-db)
    -   [We can build more complex pipelines](#we-can-build-more-complex-pipelines)
        -   [Plot top 25 applis](#plot-top-25-applis)
            -   [By file size](#by-file-size)
            -   [By file cnt](#by-file-cnt)
        -   [Plot file size by node](#plot-file-size-by-node)
        -   [Plaot file cnt by split](#plaot-file-cnt-by-split)
    -   [Or use direct SQL request](#or-use-direct-sql-request)
    -   [We can combine CTE](#we-can-combine-cte)
    -   [Look space evoltion](#look-space-evoltion)
        -   [By time slot size and cnt](#by-time-slot-size-and-cnt)
        -   [By cumulated time slot size and time slot average](#by-cumulated-time-slot-size-and-time-slot-average)
    -   [And finally answer the TDEP ticket](#and-finally-answer-the-tdep-ticket)
        -   [About by split evolution](#about-by-split-evolution)
        -   [Or even by appli](#or-even-by-appli)

</details>

# See also

<details><summary>Expand</summary>

- [2025-11-03 Space-evol][]
- [2025-10-22 Space-evol][]
- [2025-10-16 Space-evol][]
- [2025-08-01 Prostrc1-space][]

</details>

# Per request INFRADESK-3466

- [INFRADESK-3466][] suivi de la conso disque régulière pour l'équipe dépistage

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

# Env

```bash
declare -p INFRA
```

# Tools

## Install `jqsh`

- [jqsh][]

### Clone a specified `jqsh` tag

- Last known working tags (default to last)

```bash
last=$(git -C $INFRA/jqsh tag | sort | tail -1)
```

---

```bash
if [[ $USER == thy ]] then export GIT_SSH_COMMAND='ssh -i ~/.ssh/t.delamare@epiconcept.fr -F /dev/null'; fi
repo=git@github.com:Epiconcept-Paris/jqsh.git
tag=$last jqsh=tmp/jqsh-$tag; mkdir -p $jqsh
git clone -b $tag --depth 1 $repo $jqsh
ln -nsf jqsh-$tag tmp/jqsh
```

### Add cloned repo `cmd` dir to `PATH`

```bash
source $jqsh/cmd/addpath.sh $jqsh/cmd
```

### Source `jqsh` from cloned repo

```bash
source jqsh.sh
```

# Use `ejq`

```bash
source ejq.sh
```

# Add lib build DB

<!--
- Start back [FS-db.yml][] from [../2025-11-03-space-evol/FS-db.yml][]
- And [data.yml][] from [../2025-11-03-space-evol/data.yml][]
-->
- Add [tdep.yml][]

```bash
load tdep.yml
```

[../2025-11-03-space-evol/FS-db.yml]: ../2025-11-03-space-evol/FS-db.yml "sibling file"
[../2025-11-03-space-evol/data.yml]: ../2025-11-03-space-evol/data.yml "sibling file"

# Install `duckdb`

> [!NOTE]
>
> - Once only

```bash
install-duckdb
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

## Make DB from stat

```bash
mk-tables table=stat
```

# Add lib to request DB

- Add [stat-sql.yml][] and [sql-cte.yml][]

```bash
load stat-sql.yml
load sql-cte.yml
```

## List appli without any files

```bash
fmt=list head=no use empty-applis | fmt
```

---

esis3d-can esis3d-gua esis3d-mtq esis3d-occa esisbci-copy
esisbci-copy-can esisdoccr-copy-ara esisdoccr-copy-ges
esisdoccr-copy-gua esisdoccr-copy-guy esisdoccr-copy-mtq
esisdoccr-copy-naq esisdoccr-copy-nor esisdoccu-aura esisdoccu-copy
esisdoccu-copy-ara esisdoccu-copy-bfc esisdoccu-copy-can
esisdoccu-copy-demo esisdoccu-copy-gua esisdoccu-copy-idf
esisdoccu-copy-mtq esisdoccu-copy-naq esisdoccu-copy-occ
esisdoccu-guyane esisdoccu-normandie esisdoccu-recette-martinique
esisdoccu-recette-occitanie esisdocs-copy-can esisdocs-copy-ges
esisdocs-copy-guy esisdocs-copy-idf esisdocs-copy-naq
esisdocs-copy-nor esisdocs-copy-occ esisstats esisstats-ara
esisstats-bfc esisstats-can esisstats-gf esisstats-gua esisstats-idf
esisstats-mtq esisstats-naq esisstats-occ neobci-copy-bfc neobci-demo
neobci-recette neonatstats portailneo stat-doccu stat-doccu-ara
stat-doccu-demo stat-doccu-gua stat-doccu-guf stat-doccu-idf
stat-doccu-mtq stat-doccu-naq stat-doccu-nor stat-doccu-occ
stat-docs-naq stats voo4bcm-copy-bfc

## Count empty files

- And give a glimpse of the common table expressions (CTE) lib

### We have CTE funcs

- .e.g

```bash
for id in start cnt plot; do < sql-cte.yml yq ".[] | select(.id == \"$id\")"; done
```

---

```yaml
id: start
type: start
sql: |
  FROM \($table)
sh: |
  sql -n --arg table ${1:-stat}

id: cnt
type: aggregate
sql: |
  SELECT \($group), COUNT(*) AS cnt FROM {prev} GROUP BY \($group)
sh: |
  sql --arg group ${1:?}

id: plot
type: output
sql: |
  SELECT *, REPEAT('\u2588', (\($col) * \($width) / MAX(\($col)) OVER ())::INTEGER) AS \($col)_bar FROM {prev}
sh: |
  sql --arg col ${1:?} --arg width ${2:-40}
```

### We have pipeline of CTE funcs

- .e.g

```bash
< stat-sql.yml yq '.[] | select(.id == "empty-files")'
```

---

```yaml
id: empty-files
doc: number of empty files by appli
sh: where uts != 0 and size == 0 | cnt appli | order cnt
tt: |
  show-cte empty-files
  show-sql empty-files
  use empty-files
  fmt=csv use empty-files
```

### That generate sequence of CTE

```bash
show-cte empty-files
```

---

```
FROM stat
SELECT * FROM {prev} WHERE uts != 0 and size == 0
SELECT appli, COUNT(*) AS cnt FROM {prev} GROUP BY appli
SELECT * FROM {prev} ORDER BY cnt DESC
```

### Then merged as SQL

```bash
show-sql empty-files
```

---


```sql
WITH step0 AS (FROM stat),
step1 AS (SELECT * FROM step0 WHERE uts != 0 and size == 0),
step2 AS (SELECT appli, COUNT(*) AS cnt FROM step1 GROUP BY appli),
step3 AS (SELECT * FROM step2 ORDER BY cnt DESC)
SELECT * FROM step3
```

### That can be used on DB

```bash
fmt=markdown use empty-files
```

|       appli       | cnt |
|-------------------|----:|
| esisdoccu         | 429 |
| esis3d-ara        | 150 |
| neoesis           | 87  |
| esis3d-naq        | 81  |
| esisdoccu-idf     | 33  |
| esisdocs-ara      | 11  |
| esis3d-idf        | 8   |
| esisdoccu-alpes   | 6   |
| esisdocs-occ      | 3   |
| esisfiles         | 2   |
| esisdoccr-ara     | 2   |
| esisdocs-naq      | 2   |
| esisdoccu-recette | 2   |
| esisdoccr-naq     | 1   |
| neobci            | 1   |
| mailmerge         | 1   |
| esisbci           | 1   |
| cedric            | 1   |


> [!NOTE]
>
> - Just found youplot

```console
thy@tdews1-256g:2025-11-05-space-evol-tdep$ fmt=csv use empty-files | youplot bar -d, -H

                                        cnt
                     ┌                                        ┐ 
           esisdoccu ┤■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ 429.0   
          esis3d-ara ┤■■■■■■■■■■■■ 150.0                        
             neoesis ┤■■■■■■■ 87.0                              
          esis3d-naq ┤■■■■■■ 81.0                               
       esisdoccu-idf ┤■■■ 33.0                                  
        esisdocs-ara ┤■ 11.0                                    
          esis3d-idf ┤■ 8.0                                     
     esisdoccu-alpes ┤ 6.0                                      
        esisdocs-occ ┤ 3.0                                      
   esisdoccu-recette ┤ 2.0                                      
           esisfiles ┤ 2.0                                      
        esisdocs-naq ┤ 2.0                                      
       esisdoccr-ara ┤ 2.0                                      
             esisbci ┤ 1.0                                      
       esisdoccr-naq ┤ 1.0                                      
           mailmerge ┤ 1.0                                      
              cedric ┤ 1.0                                      
              neobci ┤ 1.0                                      
```

## We can build more complex pipelines

### Plot top 25 applis

#### By file size

```bash
fmt=markdown use plot-col -n 25 | fix-md-tbl
```

|            appli            |     size     |                 size_bar                 |
|-----------------------------|-------------:|------------------------------------------|
| mailmerge                   | 530381808487 | ████████████████████████████████████████ |
| esisdocs‑naq                | 498706176537 | ██████████████████████████████████████   |
| esisdocs‑idf                | 464429039992 | ███████████████████████████████████      |
| esisdocs‑occ                | 282125142697 | █████████████████████                    |
| esisdoccr‑idf               | 280823954741 | █████████████████████                    |
| esisdoccu                   | 249863691250 | ███████████████████                      |
| esisdoccr‑naq               | 190498871596 | ██████████████                           |
| esisdoccr‑occ               | 113563296738 | █████████                                |
| esisdocs‑ara                | 104746896615 | ████████                                 |
| esisdoccr‑ara               | 62233688856  | █████                                    |
| esisdocs‑guy                | 57689864348  | ████                                     |
| esisfiles                   | 33272742444  | ███                                      |
| neoesis                     | 30541332261  | ██                                       |
| esisdocs‑ges                | 29507910915  | ██                                       |
| e‑depistage                 | 28283897534  | ██                                       |
| esisdoccr‑guy               | 21018194745  | ██                                       |
| esisdoccr‑mtq               | 13741217644  | █                                        |
| esisdoccr‑ges               | 13589639135  | █                                        |
| esis3d‑idf                  | 7526057888   | █                                        |
| esisdocs‑nor                | 5886409829   |                                          |
| esisdoccr‑nor               | 3860921345   |                                          |
| esisdoccu‑recette           | 3633938789   |                                          |
| esisdoccu‑bfc               | 2955545646   |                                          |
| esisdoccr‑gua               | 2888748720   |                                          |
| esisdoccu‑recette‑aquitaine | 1246460274   |                                          |

#### By file cnt

```bash
fmt=markdown use plot-col -n 25 -w 50 -what cnt | fix-md-tbl
```

|     appli     |   cnt   |                      cnt_bar                       |
|---------------|--------:|----------------------------------------------------|
| mailmerge     | 4678314 | ██████████████████████████████████████████████████ |
| esisdocs‑naq  | 2232251 | ████████████████████████                           |
| esisdoccr‑idf | 1786497 | ███████████████████                                |
| esisdocs‑occ  | 1722590 | ██████████████████                                 |
| esisdocs‑idf  | 1504166 | ████████████████                                   |
| esisdoccr‑naq | 1187931 | █████████████                                      |
| esisdoccr‑occ | 730550  | ████████                                           |
| esisdocs‑ara  | 687767  | ███████                                            |
| esisdoccu     | 591954  | ██████                                             |
| neoesis       | 510824  | █████                                              |
| esisdoccr‑ara | 321425  | ███                                                |
| esisdocs‑guy  | 260940  | ███                                                |
| esisdocs‑ges  | 159516  | ██                                                 |
| e‑depistage   | 105255  | █                                                  |
| esisdoccr‑ges | 93318   | █                                                  |
| esisdocs‑nor  | 77701   | █                                                  |
| esisdoccr‑guy | 67746   | █                                                  |
| esis3d‑idf    | 65482   | █                                                  |
| esisdoccr‑mtq | 44596   |                                                    |
| esisdoccr‑gua | 32085   |                                                    |
| esisdoccr‑nor | 31715   |                                                    |
| esisfiles     | 12154   |                                                    |
| esisdoccu‑bfc | 5849    |                                                    |
| esis3d‑ara    | 5506    |                                                    |
| esis3d‑ges    | 2537    |                                                    |

### Plot file size by node

```bash
fmt=markdown use plot-col node
```
|   node   |     size      |                 size_bar                 |
|----------|--------------:|------------------------------------------|
| prostrq1 | 1187627806928 | ████████████████████████████████████████ |
| prostrk1 | 530381808487  | ██████████████████                       |
| prostro1 | 498706176537  | █████████████████                        |
| prostrm1 | 351246817340  | ████████████                             |
| prostrj1 | 249863691250  | ████████                                 |
| prostrl1 | 190498871596  | ██████                                   |
| prostrc1 | 28283897534   | █                                        |

### Plaot file cnt by split

```bash
fmt=markdown use plot-col split -what cnt
```

|  split  |   cnt   |                 cnt_bar                  |
|---------|--------:|------------------------------------------|
| split6  | 6031263 | ████████████████████████████████████████ |
| split4  | 4678314 | ███████████████████████████████          |
| split5  | 2232251 | ███████████████                          |
| split2  | 2094575 | ██████████████                           |
| split1  | 1187931 | ████████                                 |
| split3  | 591954  | ████                                     |
| split99 | 105255  | █                                        |


## Or use direct SQL request

- To show the split/node mapping

```bash
duckdb out/tdep.db  -markdown -c 'select node, split, round(sum(size) / 1e9, 2) AS size_gb from stat group by node, split order by node'
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

```bash
duckdb -markdown out/tdep.db -c "select round(count(*) / 2**20, 2) as 'cnt M', round(sum(size) / 2**40, 2) as 'size T', strftime(to_timestamp(MIN(uts)), '%Y-%m-%d') as start, strftime(to_timestamp(MAX(uts)), '%Y-%m-%d') as end from stat where uts != 0"
```

| cnt M | size T |   start    |    end     |
|------:|-------:|------------|------------|
| 16.14 | 2.76   | 2014-08-21 | 2025-11-12 |

## We can combine CTE

- Without using predefine pipeline

```bash
start | span | n-ts-bucket 20 | stats ts_bucket bucket_time | order ts_bucket asc | merge-cte | run
```

| ts_bucket  | bucket_time |     size     | hsize  |   cnt   |  hcnt  |    avg    | min  |    max     |
|-----------:|-------------|-------------:|--------|--------:|--------|----------:|-----:|-----------:|
| 1399727609 | 2014-05-10  | 2130         | 2.1K   | 2       | 2      | 1065.0    | 451  | 1679       |
| 1435163751 | 2015-06-24  | 57066801     | 57.1M  | 165     | 165    | 345859.4  | 5    | 7463196    |
| 1452881822 | 2016-01-15  | 315904059    | 315.9M | 3474    | 3.5K   | 90933.81  | 6962 | 396273     |
| 1470599893 | 2016-08-07  | 427392845    | 427.4M | 7438    | 7.4K   | 57460.72  | 5151 | 425576     |
| 1488317964 | 2017-02-28  | 339253174    | 339.3M | 5035    | 5.0K   | 67378.98  | 174  | 4737894    |
| 1506036035 | 2017-09-22  | 1460354926   | 1.5G   | 5538    | 5.5K   | 263697.17 | 10   | 8051810    |
| 1523754106 | 2018-04-15  | 4890471245   | 4.9G   | 32547   | 32.5K  | 150258.74 | 100  | 528386517  |
| 1541472177 | 2018-11-06  | 9625079768   | 9.6G   | 30587   | 30.6K  | 314678.78 | 5    | 178796964  |
| 1559190248 | 2019-05-30  | 6886007419   | 6.9G   | 25680   | 25.7K  | 268146.71 | 0    | 149862873  |
| 1576908319 | 2019-12-21  | 11432629145  | 11.4G  | 32564   | 32.6K  | 351081.84 | 0    | 509502787  |
| 1594626390 | 2020-07-13  | 25951677778  | 26.0G  | 69292   | 69.3K  | 374526.32 | 38   | 241648272  |
| 1612344461 | 2021-02-03  | 40504499809  | 40.5G  | 161584  | 161.6K | 250671.48 | 0    | 802171772  |
| 1630062532 | 2021-08-27  | 62458949723  | 62.5G  | 196400  | 196.4K | 318019.09 | 0    | 381047977  |
| 1647780603 | 2022-03-20  | 38268474257  | 38.3G  | 151905  | 151.9K | 251923.73 | 0    | 326316608  |
| 1665498674 | 2022-10-11  | 123969244935 | 124.0G | 956070  | 956.1K | 129665.45 | 0    | 2344760764 |
| 1683216745 | 2023-05-04  | 277158217998 | 277.2G | 1875037 | 1.9M   | 147814.8  | 0    | 703401241  |
| 1700934816 | 2023-11-25  | 554573787078 | 554.6G | 2995450 | 3.0M   | 185138.72 | 0    | 440898463  |
| 1718652887 | 2024-06-17  | 825368508919 | 825.4G | 3974259 | 4.0M   | 207678.59 | 0    | 995645054  |
| 1736370958 | 2025-01-08  | 784955034193 | 785.0G | 4316902 | 4.3M   | 181832.95 | 0    | 1743722204 |
| 1754089029 | 2025-08-02  | 267966513470 | 268.0G | 2081614 | 2.1M   | 128730.16 | 0    | 1807735004 |


## Look space evoltion

### By time slot size and cnt

```bash
file=$(<<< 'By time slot size and cnt' tr ' ' -)
cmd='use hist -span 2 years -n 30 -cols size cnt'
eval fmt=markdown $cmd | fix-md-tbl > md/$file.md
eval fmt=html $cmd | html-tbl-to-jpeg 10 > jpg/$file.jpg
```

- [md By-time-slot-size-and-cnt][]

![jpg By-time-slot-size-and-cnt][]


### By cumulated time slot size and time slot average

```bash
file=$(<<< 'By cumulated time slot size and time slot average' tr ' ' -)
cmd='use hist -span 2 years -n 30 -cols cumsize avg'
eval fmt=markdown $cmd | fix-md-tbl > md/$file.md
eval fmt=html $cmd | html-tbl-to-jpeg 10 > jpg/$file.jpg
```

- [md By-cumulated-time-slot-size-and-time-slot-average][]

![jpg By-cumulated-time-slot-size-and-time-slot-average][]

## And finally answer the TDEP ticket

### About by split evolution

```bash
fmt=markdown use hist -is split split1 -span 3 months -n 30 -cols cumsize | fix-md-tbl
```

|    date    |  cumsize   |               cumsize_bar                |
|------------|-----------:|------------------------------------------|
| 2025‑08‑13 | 314502429  | █                                        |
| 2025‑08‑16 | 453216214  | ██                                       |
| 2025‑08‑19 | 574949781  | ███                                      |
| 2025‑08‑22 | 614632497  | ███                                      |
| 2025‑08‑25 | 931850247  | ████                                     |
| 2025‑08‑28 | 1055650284 | █████                                    |
| 2025‑08‑31 | 1473146660 | ███████                                  |
| 2025‑09‑03 | 1877221951 | ████████                                 |
| 2025‑09‑06 | 2034122589 | █████████                                |
| 2025‑09‑09 | 2217483091 | ██████████                               |
| 2025‑09‑12 | 2297062852 | ██████████                               |
| 2025‑09‑15 | 2617183857 | ████████████                             |
| 2025‑09‑18 | 2737690979 | ████████████                             |
| 2025‑09‑21 | 3438360648 | ███████████████                          |
| 2025‑09‑24 | 3620404556 | ████████████████                         |
| 2025‑09‑27 | 3746695047 | █████████████████                        |
| 2025‑09‑30 | 4067722578 | ██████████████████                       |
| 2025‑10‑03 | 4389602340 | ████████████████████                     |
| 2025‑10‑06 | 5007607582 | ██████████████████████                   |
| 2025‑10‑10 | 5228290256 | ███████████████████████                  |
| 2025‑10‑13 | 5697969111 | █████████████████████████                |
| 2025‑10‑16 | 5934310871 | ███████████████████████████              |
| 2025‑10‑19 | 6385637684 | █████████████████████████████            |
| 2025‑10‑22 | 6663645060 | ██████████████████████████████           |
| 2025‑10‑25 | 7004483976 | ███████████████████████████████          |
| 2025‑10‑28 | 7509469531 | ██████████████████████████████████       |
| 2025‑10‑31 | 7656333516 | ██████████████████████████████████       |
| 2025‑11‑03 | 8183296211 | █████████████████████████████████████    |
| 2025‑11‑06 | 8525663556 | ██████████████████████████████████████   |
| 2025‑11‑09 | 8831705865 | ███████████████████████████████████████  |
| 2025‑11‑12 | 8946203950 | ████████████████████████████████████████ |

```bash
fmt=markdown use hist -is split split2 -span 3 months -n 30 -cols cumsize | fix-md-tbl
```

|    date    |   cumsize   |               cumsize_bar                |
|------------|------------:|------------------------------------------|
| 2025‑08‑13 | 136869705   |                                          |
| 2025‑08‑16 | 224299780   |                                          |
| 2025‑08‑19 | 505163365   |                                          |
| 2025‑08‑22 | 620063013   | █                                        |
| 2025‑08‑25 | 892918619   | █                                        |
| 2025‑08‑28 | 1052539028  | █                                        |
| 2025‑08‑31 | 1276282274  | █                                        |
| 2025‑09‑03 | 1573336780  | █                                        |
| 2025‑09‑06 | 2151460092  | ██                                       |
| 2025‑09‑09 | 2672588374  | ██                                       |
| 2025‑09‑12 | 3437264941  | ███                                      |
| 2025‑09‑15 | 5167318888  | ████                                     |
| 2025‑09‑18 | 5710564323  | █████                                    |
| 2025‑09‑21 | 8116211582  | ███████                                  |
| 2025‑09‑24 | 10487915490 | █████████                                |
| 2025‑09‑27 | 13529850984 | ███████████                              |
| 2025‑09‑30 | 16647391577 | ██████████████                           |
| 2025‑10‑03 | 17785822068 | ███████████████                          |
| 2025‑10‑06 | 19413490262 | ████████████████                         |
| 2025‑10‑10 | 20068820160 | █████████████████                        |
| 2025‑10‑13 | 22767580669 | ███████████████████                      |
| 2025‑10‑16 | 24040245917 | ████████████████████                     |
| 2025‑10‑19 | 26988944948 | ███████████████████████                  |
| 2025‑10‑22 | 28860088951 | ████████████████████████                 |
| 2025‑10‑25 | 30590027288 | ██████████████████████████               |
| 2025‑10‑28 | 32563135260 | ███████████████████████████              |
| 2025‑10‑31 | 34463864349 | █████████████████████████████            |
| 2025‑11‑03 | 38027041134 | ████████████████████████████████         |
| 2025‑11‑06 | 39411427632 | █████████████████████████████████        |
| 2025‑11‑09 | 47131038761 | ████████████████████████████████████████ |
| 2025‑11‑12 | 47563892343 | ████████████████████████████████████████ |

```bash
fmt=markdown use hist -is split split3 -span 3 months -n 30 -cols cumsize | fix-md-tbl
```

|    date    |   cumsize   |               cumsize_bar                |
|------------|------------:|------------------------------------------|
| 2025‑08‑13 | 214856584   | █                                        |
| 2025‑08‑16 | 251195147   | █                                        |
| 2025‑08‑19 | 1043153376  | ████                                     |
| 2025‑08‑22 | 1426532483  | █████                                    |
| 2025‑08‑25 | 1918731866  | ███████                                  |
| 2025‑08‑28 | 2027575492  | ███████                                  |
| 2025‑08‑31 | 2207474596  | ████████                                 |
| 2025‑09‑03 | 2506381737  | █████████                                |
| 2025‑09‑06 | 2586377353  | █████████                                |
| 2025‑09‑09 | 2868556093  | ██████████                               |
| 2025‑09‑12 | 2947621977  | ███████████                              |
| 2025‑09‑15 | 3309107987  | ████████████                             |
| 2025‑09‑18 | 3360647350  | ████████████                             |
| 2025‑09‑21 | 3713705275  | █████████████                            |
| 2025‑09‑24 | 4064717532  | ███████████████                          |
| 2025‑09‑27 | 4724580881  | █████████████████                        |
| 2025‑09‑30 | 5205155384  | ███████████████████                      |
| 2025‑10‑03 | 5650157396  | ████████████████████                     |
| 2025‑10‑06 | 6795651819  | █████████████████████████                |
| 2025‑10‑10 | 6910429164  | █████████████████████████                |
| 2025‑10‑13 | 7296468130  | ██████████████████████████               |
| 2025‑10‑16 | 7511403167  | ███████████████████████████              |
| 2025‑10‑19 | 8841589466  | ████████████████████████████████         |
| 2025‑10‑22 | 8989998000  | ████████████████████████████████         |
| 2025‑10‑25 | 9212369087  | █████████████████████████████████        |
| 2025‑10‑28 | 9690487369  | ███████████████████████████████████      |
| 2025‑10‑31 | 9867507664  | ████████████████████████████████████     |
| 2025‑11‑03 | 10354061401 | █████████████████████████████████████    |
| 2025‑11‑06 | 10732468991 | ███████████████████████████████████████  |
| 2025‑11‑09 | 11014300706 | ████████████████████████████████████████ |
| 2025‑11‑12 | 11081499235 | ████████████████████████████████████████ |

### Or even by appli

```bash
fmt=markdown use hist -is appli esisdoccu -span 5 years -n 30 -cols cumsize | fix-md-tbl
```

|    date    |   cumsize    |               cumsize_bar                |
|------------|-------------:|------------------------------------------|
| 2020‑10‑19 | 5625104229   | █                                        |
| 2020‑12‑19 | 14551780931  | ███                                      |
| 2021‑02‑17 | 25151182099  | ████                                     |
| 2021‑04‑19 | 33438426914  | ██████                                   |
| 2021‑06‑19 | 39158776702  | ███████                                  |
| 2021‑08‑19 | 45816039379  | ████████                                 |
| 2021‑10‑19 | 58264134757  | ██████████                               |
| 2021‑12‑19 | 65278535636  | ███████████                              |
| 2022‑02‑17 | 78116868530  | ██████████████                           |
| 2022‑04‑19 | 85224607392  | ███████████████                          |
| 2022‑06‑19 | 93078339509  | ████████████████                         |
| 2022‑08‑19 | 101042119904 | █████████████████                        |
| 2022‑10‑19 | 111787765040 | ███████████████████                      |
| 2022‑12‑19 | 120909343609 | █████████████████████                    |
| 2023‑02‑17 | 134838381301 | ███████████████████████                  |
| 2023‑04‑19 | 142244096144 | █████████████████████████                |
| 2023‑06‑19 | 152375760316 | ██████████████████████████               |
| 2023‑08‑19 | 160840309433 | ████████████████████████████             |
| 2023‑10‑19 | 169646989458 | █████████████████████████████            |
| 2023‑12‑19 | 178205788222 | ███████████████████████████████          |
| 2024‑02‑17 | 186244088156 | ████████████████████████████████         |
| 2024‑04‑18 | 190540805091 | █████████████████████████████████        |
| 2024‑06‑18 | 195757080074 | ██████████████████████████████████       |
| 2024‑08‑18 | 198246139272 | ██████████████████████████████████       |
| 2024‑10‑18 | 201359467944 | ███████████████████████████████████      |
| 2024‑12‑18 | 203579914529 | ███████████████████████████████████      |
| 2025‑02‑16 | 208596362477 | ████████████████████████████████████     |
| 2025‑04‑18 | 214757351030 | █████████████████████████████████████    |
| 2025‑06‑18 | 220343372256 | ██████████████████████████████████████   |
| 2025‑08‑18 | 227636724183 | ███████████████████████████████████████  |
| 2025‑10‑18 | 231206841344 | ████████████████████████████████████████ |

```bash
fmt=markdown use hist -is appli esisdocs-idf -span 2 years -n 30 -cols cumsize | fix-md-tbl
```

|    date    |   cumsize    |               cumsize_bar                |
|------------|-------------:|------------------------------------------|
| 2024-03-25 | 1020976413   |                                          |
| 2024-04-18 | 3334785251   |                                          |
| 2024-05-13 | 14373829358  | █                                        |
| 2024-06-06 | 24826012735  | ██                                       |
| 2024-06-30 | 36190914831  | ███                                      |
| 2024-07-25 | 53104645838  | █████                                    |
| 2024-08-18 | 71343534682  | ██████                                   |
| 2024-09-11 | 84528744213  | ███████                                  |
| 2024-10-06 | 98715675090  | █████████                                |
| 2024-10-30 | 109685361638 | █████████                                |
| 2024-11-23 | 121809287991 | ██████████                               |
| 2024-12-18 | 132069996028 | ███████████                              |
| 2025-01-11 | 178851029003 | ███████████████                          |
| 2025-02-04 | 329802504471 | ████████████████████████████             |
| 2025-03-01 | 340701517334 | █████████████████████████████            |
| 2025-03-25 | 353672310222 | ██████████████████████████████           |
| 2025-04-18 | 361376570344 | ███████████████████████████████          |
| 2025-05-13 | 377027656871 | ████████████████████████████████         |
| 2025-06-06 | 390320910998 | ██████████████████████████████████       |
| 2025-06-30 | 405645982540 | ███████████████████████████████████      |
| 2025-07-25 | 419215119617 | ████████████████████████████████████     |
| 2025-08-18 | 430388179656 | █████████████████████████████████████    |
| 2025-09-11 | 442216338907 | ██████████████████████████████████████   |
| 2025-10-06 | 455247045192 | ███████████████████████████████████████  |
| 2025-10-30 | 464429039992 | ████████████████████████████████████████ |

```bash
fmt=markdown use hist -is appli esisdocs-naq -span 2 years -n 30 -cols cumsize
```

|    date    |   cumsize    |               cumsize_bar                |
|------------|-------------:|------------------------------------------|
| 2023-10-31 | 7915683159   | █                                        |
| 2023-11-24 | 17880475714  | ██                                       |
| 2023-12-19 | 27221578152  | ███                                      |
| 2024-01-12 | 37927536679  | ████                                     |
| 2024-02-05 | 50137735123  | █████                                    |
| 2024-03-01 | 60552518459  | ██████                                   |
| 2024-03-25 | 74893731323  | ███████                                  |
| 2024-04-18 | 84133322366  | ████████                                 |
| 2024-05-13 | 99915391770  | ██████████                               |
| 2024-06-06 | 118791633001 | ███████████                              |
| 2024-06-30 | 134124842842 | █████████████                            |
| 2024-07-25 | 145144127211 | ██████████████                           |
| 2024-08-18 | 157896027132 | ███████████████                          |
| 2024-09-11 | 169472399554 | ████████████████                         |
| 2024-10-06 | 180592479718 | █████████████████                        |
| 2024-10-30 | 190932438986 | ██████████████████                       |
| 2024-11-23 | 201408412415 | ███████████████████                      |
| 2024-12-18 | 209343387812 | ████████████████████                     |
| 2025-01-11 | 220503035277 | █████████████████████                    |
| 2025-02-04 | 232652306091 | ██████████████████████                   |
| 2025-03-01 | 243177558734 | ███████████████████████                  |
| 2025-03-25 | 315743908656 | ██████████████████████████████           |
| 2025-04-18 | 321727480644 | ███████████████████████████████          |
| 2025-05-13 | 333504913746 | ████████████████████████████████         |
| 2025-06-06 | 345355233883 | █████████████████████████████████        |
| 2025-06-30 | 358276115420 | ███████████████████████████████████      |
| 2025-07-25 | 369003643082 | ████████████████████████████████████     |
| 2025-08-18 | 381562447549 | █████████████████████████████████████    |
| 2025-09-11 | 395043875209 | ██████████████████████████████████████   |
| 2025-10-06 | 408447702288 | ███████████████████████████████████████  |
| 2025-10-30 | 414134771200 | ████████████████████████████████████████ |

```bash
file=$(<<< 'Appli mailmerge time slot size and cumulated size' tr ' ' -)
cmd='use hist -is appli mailmerge -span 3 years -n 30 -cols size cumsize'
eval fmt=markdown $cmd | fix-md-tbl > md/$file.md
eval fmt=html $cmd | html-tbl-to-jpeg 10 > jpg/$file.jpg
```

- [md Appli-mailmerge-time-slot-size-and-cumulated-size][]

![jpg Appli-mailmerge-time-slot-size-and-cumulated-size][]

<!--
bin=$INFRA/infra-lib-2023/bin
. <(echo ${nodes[@]} | sort | $bin/fmt-nodes.jq)

find -maxdepth 1 -type f | cut -c 3- | grep -v \~ | jq -Rr '"[\(.)]: \(.) \u0027sibling file\u0027", "- [\(.)][]"' | env LANG=C sort
find out -type f | grep -v \~ | jq -Rr '"[\(.)]: \(.) \u0027sibling file\u0027", "- [\(.)][]"' | env LANG=C sort
find jpg -type f | grep -v \~ | jq -Rr '"[jpg \(. | [splits("[./]")][1])]: \(.) \u0027sibling file\u0027", "- [\(.)][]"' | env LANG=C sort
find md -type f | grep -v \~ | jq -Rr '"[md \(. | [splits("[./]")][1])]: \(.) \u0027sibling file\u0027", "- [\(.)][]"' | env LANG=C sort
-->

[.gitignore]: .gitignore 'sibling file'
[FS-db.yml]: FS-db.yml 'sibling file'
[data.yml]: data.yml 'sibling file'
[ddb.yml]: ddb.yml 'sibling file'
[sql-cte.yml]: sql-cte.yml 'sibling file'
[stat-sql.yml]: stat-sql.yml 'sibling file'
[tdep.yml]: tdep.yml 'sibling file'

[out/appli-split.js]: out/appli-split.js 'sibling file'

[jpg Appli-mailmerge-time-slot-size-and-cumulated-size]: jpg/Appli-mailmerge-time-slot-size-and-cumulated-size.jpg 'sibling file'
[jpg By-cumulated-time-slot-size-and-time-slot-average]: jpg/By-cumulated-time-slot-size-and-time-slot-average.jpg 'sibling file'
[jpg By-time-slot-size-and-cnt]: jpg/By-time-slot-size-and-cnt.jpg 'sibling file'

[md Appli-mailmerge-time-slot-size-and-cumulated-size]: md/Appli-mailmerge-time-slot-size-and-cumulated-size.md 'sibling file'
[md By-cumulated-time-slot-size-and-time-slot-average]: md/By-cumulated-time-slot-size-and-time-slot-average.md 'sibling file'
[md By-time-slot-size-and-cnt]: md/By-time-slot-size-and-cnt.md 'sibling file'

[Local Variables:]::
[indent-tabs-mode: nil]::
[End:]::
