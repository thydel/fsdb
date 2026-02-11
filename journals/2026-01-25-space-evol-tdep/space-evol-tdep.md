---
title: Space evol tdep
date: 2026-01-25
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

[2026-01-25 Space-evol-tdep]:
    ../../2026/2026-01-25-space-evol-tdep/space-evol-tdep.md
    "sibling file"

<!-- Related -->

[2026-01-13 Space-evol-tdep]:
    ../../2026/2026-01-13-space-evol-tdep/space-evol-tdep.md
    "sibling file"

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
-   [Use baj](#use-baj)
-   [Start back from previous journal](#start-back-from-previous-journal)
-   [Generate rename lib](#generate-rename-lib)
-   [Copy renamed lib on remote](#copy-renamed-lib-on-remote)
-   [Add a cron on remote](#add-a-cron-on-remote)

</details>

# See also

<details><summary>Expand</summary>

- [2026-01-13 Space-evol-tdep][]
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

# Start back from previous journal

- Copy [parsarg.md][] from [2026-01-13 Space-evol-tdep][]
- Copy `log-file-stat-2.md` from [2026-01-13 Space-evol-tdep][] as [fsdb-core.md][]

# Generate rename lib

```bash
make
```

# Copy renamed lib on remote

```bash
rsync -av out/fsdb-core.sh root@prot3cbdde1:/usr/local/bin
```

# Add a cron on remote

```bash
< prot3cbdde1.cron ssh prot3cbdde1 -l root tee /etc/cron.d/fsdb-core
```

- [prot3cbdde1.cron][]


<!--
bin=$INFRA/infra-lib-2023/bin
. <(echo ${nodes[@]} | sort | $bin/fmt-nodes.jq)

find -maxdepth 1 -type f | cut -c 3- | grep -v \~ | jq -Rr '"[\(.)]: \(.) \u0027sibling file\u0027", "- [\(.)][]"' | env LANG=C sort
find out -type f | grep -v \~ | jq -Rr '"[\(.)]: \(.) \u0027sibling file\u0027", "- [\(.)][]"' | env LANG=C sort
-->

[Makefile]: Makefile 'sibling file'
[duckdb-docs.md]: duckdb-docs.md 'sibling file'
[fsdb-core.md]: fsdb-core.md 'sibling file'
[fsdb-more.md]: fsdb-more.md 'sibling file'
[parsarg.md]: parsarg.md 'sibling file'
[parsarg.mk]: parsarg.mk 'sibling file'
[prot3cbdde1.cron]: prot3cbdde1.cron 'sibling file'
[space-evol-tdep.md]: space-evol-tdep.md 'sibling file'

[Local Variables:]::
[indent-tabs-mode: nil]::
[End:]::
