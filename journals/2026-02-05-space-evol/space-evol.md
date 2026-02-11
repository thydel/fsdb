---
title: Space evol
date: 2026-02-05
tags: [ space, evolution ]
---

<!--
(delete-matching-lines "INFRADESK-nnnn")
(delete-matching-lines "INFRA-nnnn")
-->

```yml
nodes: [ prestr1, prostra1, prostrb1, prostrb2, prostrc1, prostrc1, prostrd1,
         prostrd1, prostre1, prostrf1, prostrg1, prostrh1, prostri1, prostrp1,
         prot1stra1, prot3stra1, protpstra1, protpstrb1, protpstrc1, protpstrd1 ]
repos: [ baj ]
```

[2026-02-05 Space-evol]:
    ../../2026/2026-02-05-space-evol/space-evol.md
    "sibling file"

<!-- Related -->

[2026-01-29 Prostrc1-space2]:
    ../../2026/2026-01-29-prostrc1-space2/prostrc1-space2.md
    "sibling file"

[2026-01-25 Space-evol-tdep]:
    ../../2026/2026-01-25-space-evol-tdep/space-evol-tdep.md
    "sibling file"

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

[INFRA-nnnn]: https://epiconcept.atlassian.net/browse/INFRA-nnnn "epiconcept.atlassian.net"
[INFRADESK-nnnn]: https://epiconcept.atlassian.net/browse/INFRADESK-nnnn "epiconcept.atlassian.net"

# TL;DR

```txt
┌────────────┬────────────┬──────────┬─────────┬─────────┬──────────┬─────────┐
│   start    │    end     │   rows   │ servers │  dirs   │  files   │  size   │
├────────────┼────────────┼──────────┼─────────┼─────────┼──────────┼─────────┤
│ 1999-04-15 │ 2026-02-08 │ 11.4 MiB │ 18      │ 2.1 MiB │ 37.8 MiB │ 7.4 TiB │
└────────────┴────────────┴──────────┴─────────┴─────────┴──────────┴─────────┘
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
-   [Import for previous context](#import-for-previous-context)
-   [Get list of node with a `/data`](#get-list-of-node-with-a-data)
-   [Get files stat for all `nfsdata`](#get-files-stat-for-all-nfsdata)
-   [Ingest stat](#ingest-stat)
-   [Make a reduced version of all DB](#make-a-reduced-version-of-all-db)
-   [And concatenate all DB](#and-concatenate-all-db)
-   [Keep it `tmp` (don't commit)](#keep-it-tmp-dont-commit)
-   [Show minimal facts](#show-minimal-facts)

</details>

# See also

<details><summary>Expand</summary>

- [2026-01-29 Prostrc1-space2][]
- [2026-01-25 Space-evol-tdep][]
- [2026-01-13 Space-evol-tdep][]
- [2025-12-23 Space-evol-ssp][]
- [2025-11-05 Space-evol-tdep][]
- [2025-11-03 Space-evol][]
- [2025-10-22 Space-evol][]
- [2025-10-16 Space-evol][]
- [2025-08-01 Prostrc1-space][]

</details>

<!--
# Per request INFRA-nnnn
# Per request INFRADESK-nnnn

- [INFRA-nnnn][] do something
- [INFRADESK-nnnn][] do something

- **Priority** High
- **Description**
-->

# Import for previous context

- [2026-01-29 Prostrc1-space2][]

```bash
d=../../2026/2026-01-29-prostrc1-space2
cp $d/mailmerge.md fsdb-build.md
cp $d/Makefile .
git add .; git ci -m INIT
```

- [2026-01-25 Space-evol-tdep][]

```bash
d=..../2026/2026-01-25-space-evol-tdep
cp $d/fsdb-core.md .
```

# Get list of node with a `/data`

```bash
f () { ls -d /*/nfsdata; }
r () { declare -f $1; echo $@; }
source baj-ansible.sh
jq='.[] | select(.rc == 0) | .stdout_lines[] as $dir'
jq+=' | ((.node + $dir) / "/" | join("-")) as $name | { node, $dir, $name }'
r f | fn-ansible -l g_data | jq "$jq" -c > out/conf.json
< out/conf.json jq -s 'INDEX(.[]; .name)' > out/conf-by-name.json
```

- [out/conf.json][]
- [out/conf-by-name.json][]

# Get files stat for all `nfsdata`

```bash
for i in $(conf-names); do get-files-stat $i; get-files-stat $i imn; done
```

# Ingest stat

```bash
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
thy@tdews1-256g:2026-02-05-space-evol$ ls -lsh tmp/nfsdata{,-small}.db
1.7G -rw-r--r-- 1 thy thy 1.7G Feb  8 04:25 tmp/nfsdata.db
289M -rw-r--r-- 1 thy thy 289M Feb  9 20:09 tmp/nfsdata-small.db
thy@tdews1-256g:2026-02-05-space-evol$ <<< "select count(*) from fsdb" duckdb tmp/nfsdata.db -line
count_star() = 39718845
thy@tdews1-256g:2026-02-05-space-evol$ <<< "select count(*) from fsdb" duckdb tmp/nfsdata-small.db -line
count_star() = 12025294
```

# Show minimal facts

```bash
small-db-basic-facts | duckdb tmp/nfsdata-small.db --box
```

```txt
┌────────────┬────────────┬──────────┬─────────┬─────────┬──────────┬─────────┐
│   start    │    end     │   rows   │ servers │  dirs   │  files   │  size   │
├────────────┼────────────┼──────────┼─────────┼─────────┼──────────┼─────────┤
│ 1999-04-15 │ 2026-02-08 │ 11.4 MiB │ 18      │ 2.1 MiB │ 37.8 MiB │ 7.4 TiB │
└────────────┴────────────┴──────────┴─────────┴─────────┴──────────┴─────────┘
```

<!--
bin=$INFRA/infra-lib-2023/bin
. <(echo ${nodes[@]} | sort | $bin/fmt-nodes.jq)

find -maxdepth 1 -type f | cut -c 3- | grep -v \~ | jq -Rr '"[\(.)]: \(.) \u0027sibling file\u0027", "- [\(.)][]"' | env LANG=C sort
find out -type f | grep -v \~ | jq -Rr '"[\(.)]: \(.) \u0027sibling file\u0027", "- [\(.)][]"' | env LANG=C sort
-->

[out/conf-by-name.json]: out/conf-by-name.json 'sibling file'
[out/conf.json]: out/conf.json 'sibling file'
[out/fsdb-build.yml]: out/fsdb-build.yml 'sibling file'

[Local Variables:]::
[indent-tabs-mode: nil]::
[End:]::
