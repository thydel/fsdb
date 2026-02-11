---
title: Space evol tdep
date: 2026-01-13
tags: [ space, evolution ]
---

<!--
(delete-matching-lines "INFRADESK-nnnn")
(delete-matching-lines "INFRA-nnnn")
-->

```yml
nodes: [ prot3cbdde1 ]
tickets: [ INFRADESK-3466 ]
```

[2026-01-13 Space-evol-tdep]:
    ../../2026/2026-01-13-space-evol-tdep/space-evol-tdep.md
    "sibling file"

<!-- Related next -->

[2026-01-25 Space-evol-tdep]:
    ../../2026/2026-01-25-space-evol-tdep/space-evol-tdep.md
    "sibling file"

<!-- Related previous -->

[2025-12-23 Space-evol-ssp]:
    ../../2025/2025-12-23-space-evol-ssp/space-evol-ssp.md
    "sibling file"

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

[INFRADESK-3466]: https://epiconcept.atlassian.net/browse/INFRADESK-3466 "epiconcept.atlassian.net"

# TL;DR

- First working demo tracking of size evolution for a `mysql` file tree
- Collect all file size for `prot3cbdde1:/data/mysql` as `json` every hour
- Then add collected `json` to a `duckdb`
- Show growth in MB for 2026-01-15 from 02:00 to 20:00 by 6h period
  (only DB that changed in size are shown)
- Obviously this is a poc and won't need such an short collect period (the DB is 35M)
- We'll also need some way to accumulate a reduced form on another
  table and purge the collect table
  
- See the [log-file-stat.md][] notebook

```bash
loop-next-files-stat prot3cbdde1 /data/mysql &
# hours later
db-growth-pivot 6h prot3cbdde1 /data/mysql -box -nullvalue ' '
```

```txt
┌─────────────────┬─────────────┬─────────────┬─────────────┬─────────────┬────────┐
│       db        │ 01-15 00:00 │ 01-15 06:00 │ 01-15 12:00 │ 01-15 18:00 │ Total  │
├─────────────────┼─────────────┼─────────────┼─────────────┼─────────────┼────────┤
│  Total          │ 4.0         │ 250.13      │ 434.36      │ 62.0        │ 750.48 │
│ docs_naq        │ 4.0         │ 78.03       │ 170.02      │ 21.0        │ 273.05 │
│ docs_occ        │             │ 84.0        │ 100.02      │ 28.0        │ 212.02 │
│ docs_idf        │             │ 24.0        │ 52.03       │             │ 76.03  │
│ docs_ges        │             │ 24.02       │ 28.06       │             │ 52.08  │
│ docs_nor        │             │ 8.0         │ 29.02       │             │ 37.02  │
│ voo4bcm         │             │ 8.0         │ 12.0        │ 4.0         │ 24.0   │
│ docs_guy        │             │             │ 12.03       │ 5.0         │ 17.03  │
│ docr_occ        │             │ 12.0        │ 0.02        │             │ 12.02  │
│ mailmerge       │             │ 4.0         │ 8.0         │             │ 12.0   │
│ esisbci         │             │             │ 8.0         │             │ 8.0    │
│ docu_occitanie  │             │ 4.02        │ 1.0         │             │ 5.02   │
│ docr_naq        │             │             │ 0.03        │ 4.0         │ 4.03   │
│ docu_aquitaine  │             │ 4.02        │             │             │ 4.02   │
│ docu_idf        │             │ 0.02        │ 4.0         │             │ 4.02   │
│ docr_idf        │             │             │ 4.0         │             │ 4.0    │
│ disp_nor        │             │             │ 4.0         │             │ 4.0    │
│ docr_nor        │             │ 0.03        │ 1.06        │             │ 1.09   │
│ disp_ges_docs   │             │             │ 1.0         │             │ 1.0    │
│ docu_guadeloupe │             │             │ 0.05        │             │ 0.05   │
│ docr_ges        │             │             │ 0.02        │             │ 0.02   │
│ docr_gua        │             │             │ 0.02        │             │ 0.02   │
└─────────────────┴─────────────┴─────────────┴─────────────┴─────────────┴────────┘
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
    -   [Next](#next)
    -   [Previous](#previous)
-   [Per request INFRADESK-3466](#per-request-infradesk-3466)
-   [Use baj](#use-baj)
-   [Add log-file-stat.md](#add-log-file-statmd)
-   [Start to collect files stat](#start-to-collect-files-stat)
-   [Install DDB on remote node](#install-ddb-on-remote-node)
-   [Install test version of lib on remote node](#install-test-version-of-lib-on-remote-node)
-   [Transfert accumulated snapshot to remote node](#transfert-accumulated-snapshot-to-remote-node)
    -   [Copy to node db name](#copy-to-node-db-name)
    -   [Use `prune-dedup` and `mark-deleted` on kept snapshot](#use-prune-dedup-and-mark-deleted-on-kept-snapshot)
    -   [Free space by export import](#free-space-by-export-import)
    -   [Copy to remote node](#copy-to-remote-node)
-   [Continue work on nex journal](#continue-work-on-nex-journal)

</details>

# See also

## Next

- [2026-01-25 Space-evol-tdep][]

## Previous

<details><summary>Expand</summary>

- [2025-12-23 Space-evol-ssp][]
- [2025-11-05 Space-evol-tdep][]
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
    du --max-depth=1 /space/applisdata.store/split3 | grep -v '\./\.'|awk -F "./" {'print $2" "$1'}|awk -F " " {'print $1";"$2'}|grep -v "\;\." >> analyse_tdep.csv
    du --max-depth=1 /space/applisdata.store/split4 | grep -v '\./\.'|awk -F "./" {'print $2" "$1'}|awk -F " " {'print $1";"$2'}|grep -v "\;\." >> analyse_tdep.csv
    du --max-depth=1 /space/applisdata.store/split5 | grep -v '\./\.'|awk -F "./" {'print $2" "$1'}|awk -F " " {'print $1";"$2'}|grep -v "\;\." >> analyse_tdep.csv
    du --max-depth=1 /space/applisdata.store/split6 | grep -v '\./\.'|awk -F "./" {'print $2" "$1'}|awk -F " " {'print $1";"$2'}|grep -v "\;\." >> analyse_tdep.csv
    ```

    Le second, correspondant sur prot3cbdde1 à :

    ```bash
    du --max-depth=1 /data/mysql | grep -v '\./\.' | awk -F "./" {'print $2" "$1'} | awk -F " " {'print $1";"$2'} | grep -v "\;\." > analyse_prot3.csv
    ```
    
    ainsi que la taille du fichier ibdata1

# Use [baj][]

> [!NOTE]
> - Assume `baj` installed

```bash
source baj.sh
source mdq.sh
```

# Add [log-file-stat.md][]

- Add [Makefile][] to produce [out/log-file-stat.yml][] from
  [log-file-stat.md][]

```bash
make; load out/log-file-stat.yml
```

# Start to collect files stat

```bash
loop-next-files-stat prot3cbdde1 /data/mysql
```

# Install DDB on remote node

```bash
rsync -av /usr/local/bin/duckdb root@prot3cbdde1:/usr/local/bin
```

# Install test version of lib on remote node

```bash
rsync -avn out/log-file-stat-2.sh root@prot3cbdde1:/usr/local/bin
```

# Transfert accumulated snapshot to remote node

> [!WARNING]
>
> - between to round hour

## Copy to node db name

```bash
cp -p tmp/prot3cbdde1-data-mysql.db tmp/data-mysql.db
```

## Use `prune-dedup` and `mark-deleted` on kept snapshot

```bash
prune-dedup /data/mysql tmp
mark-deleted /data/mysql tmp
```

## Free space by export import

```bash
mv tmp/{,old-}data-mysql.db
duckdb tmp/old-data-mysql.db -c ".dump" | duckdb tmp/data-mysql.db
```

## Copy to remote node

```
rsync -avn tmp/data-mysql.db root@prot3cbdde1:/space/var
```

# Continue work on nex journal

- [2026-01-25 Space-evol-tdep][]

<!--
bin=$INFRA/infra-lib-2023/bin
. <(echo ${nodes[@]} | sort | $bin/fmt-nodes.jq)

find -maxdepth 1 -type f | cut -c 3- | grep -v \~ | jq -Rr '"[\(.)]: \(.) \u0027sibling file\u0027", "- [\(.)][]"' | env LANG=C sort
find out -type f | grep -v \~ | jq -Rr '"[\(.)]: \(.) \u0027sibling file\u0027", "- [\(.)][]"' | env LANG=C sort
-->

[.gitignore]: .gitignore 'sibling file'
[Makefile]: Makefile 'sibling file'
[log-file-stat.md]: log-file-stat.md 'sibling file'
[space-evol-tdep.md]: space-evol-tdep.md 'sibling file'

[out/log-file-stat.yml]: out/log-file-stat.yml 'sibling file'

[Local Variables:]::
[indent-tabs-mode: nil]::
[End:]::
