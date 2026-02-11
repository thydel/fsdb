---
title: Space evol
date: 2025-11-03
tags: [ space, evolution ]
---

<!--
(delete-matching-lines "INFRADESK-nnnn")
(delete-matching-lines "INFRA-nnnn")
-->

```yml
nodes: [ profnte1, prostri1, prostrc1 ]
tickets: [ INFRA-2301 ]
repos: [ jqsh ]
```

[2025-11-03 Space-evol]:
    ../../2025/2025-11-03-space-evol/space-evol.md
    "sibling file"

<!-- Related -->

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


[INFRA-2301]: https://epiconcept.atlassian.net/browse/INFRA-2301 "epiconcept.atlassian.net"

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
-   [Per request INFRA-2301](#per-request-infra-2301)
-   [Env](#env)
-   [Tools](#tools)
    -   [Install `jqsh`](#install-jqsh)
        -   [Clone a specified `jqsh` tag](#clone-a-specified-jqsh-tag)
        -   [Add cloned repo `cmd` dir to `PATH`](#add-cloned-repo-cmd-dir-to-path)
        -   [Source `jqsh` from cloned repo](#source-jqsh-from-cloned-repo)
-   [Use `ejq`](#use-ejq)
-   [Add lib](#add-lib)
-   [Install `duckdb`](#install-duckdb)

</details>

# See also

<details><summary>Expand</summary>

- [2025-10-22 Space-evol][]
- [2025-10-16 Space-evol][]
- [2025-08-01 Prostrc1-space][]

</details>

# Per request INFRA-2301

- [INFRA-2301][] Evolution espace disque

- **Priority** Medium
- **Description**

    - evaluation de l’esapce disque SSP prod  : 
    - serveur front : profnte1
    - dossier : /space/applisdata/ssp

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

# Add lib

- Start back [FS-db.yml][] from [../2025-10-22-space-evol/FS-db.yml][]
- And [data.yml][] from [../2025-10-22-space-evol/data.yml][]

```bash
load FS-db.yml
```

[../2025-10-22-space-evol/FS-db.yml]: ../2025-10-22-space-evol/FS-db.yml "sibling file"
[../2025-10-22-space-evol/data.yml]: ../2025-10-22-space-evol/data.yml "sibling file"

# Install `duckdb`

> [!NOTE]
>
> - Once only

```bash
install-duckdb
```

# Evolve

```bash
git diff efbd9ee8 HEAD -- FS-db.yml > out/FS-db.yml.diff
```

- [out/FS-db.yml.diff][]

# Use

## Show the metadata

```bash
metadata
```

---

```yaml
data:
  ssp:
    path: applisdata/ssp
    sets: [apicrypt, upload]
    client:
      node: profnte1
      base: /space
    server:
      node: prostri1
      base: /space/nfsdata
  mailmerge:
    path: applisdata/mailmerge/storage/mailmerge
    client:
      node: proepifiles1
      base: /space
    server:
      node: prostrc1
      base: /space2/nfsdata
  profntr1-ssp:
    path: applisdata
    client:
      node: profntr1
      base: /space
    server:
      node: prostrg1
      base: /space/nfsdata
```

## And the resulting data

> [!NOTE]
>
> - Result of using [lib/ejq.yml][] from  [jqsh][] on [data.yml][]

```bash
data
```

---

```json
{
  "mailmerge": {
    "what": "proepifiles1:/space/applisdata/mailmerge/storage/mailmerge",
    "node": "prostrc1",
    "path": "/space2/nfsdata/proepifiles1/applisdata/mailmerge/storage/mailmerge"
  },
  "ssp": {
    "apicrypt": {
      "what": "profnte1:/space/applisdata/ssp/apicrypt",
      "node": "prostri1",
      "path": "/space/nfsdata/profnte1/applisdata/ssp/apicrypt"
    },
    "upload": {
      "what": "profnte1:/space/applisdata/ssp/upload",
      "node": "prostri1",
      "path": "/space/nfsdata/profnte1/applisdata/ssp/upload"
    }
  },
  "profntr1-ssp": {
    "what": "profntr1:/space/applisdata",
    "node": "prostrg1",
    "path": "/space/nfsdata/profntr1/applisdata"
  }
}
```

[lib/ejq.yml]:
    https://github.com/Epiconcept-Paris/jqsh/blob/dev/lib/ejq.yml
    "github.com file"

## List our sets

```console
thy@tdews1-256g:2025-11-03-space-evol$ fs
mailmerge
ssp.apicrypt
ssp.upload
profntr1-ssp
```

## Install `libfile-libmagic-perl` on all NFS server of sets

```bash
install-libmagic-on-all-servers
```

## Get all data for all sets

### Ideally

```bash
fs | map get-all-data
```

### Pratically

```bash
get-all-data ssp.apicrypt
get-all-data ssp.upload
get-all-data mailmerge
get-all-data profntr1-ssp
```

### Example

- Even more detail

```console
thy@tdews1-256g:2025-11-03-space-evol$ time get-files-stat profntr1-ssp Ysi

real	1m21.114s
user	0m11.435s
sys	0m1.471s
thy@tdews1-256g:2025-11-03-space-evol$ time get-files-stat profntr1-ssp ihug

real	0m57.412s
user	0m3.014s
sys	0m1.068s
thy@tdews1-256g:2025-11-03-space-evol$ time get-files-stat profntr1-ssp imn

real	3m49.217s
user	0m14.606s
sys	0m4.184s

thy@tdews1-256g:2025-11-03-space-evol$ time get-files-type profntr1-ssp

real	349m27.974s
user	1m25.866s
sys	1m57.640s
```

<!--
bin=$INFRA/infra-lib-2023/bin
. <(echo ${nodes[@]} | sort | $bin/fmt-nodes.jq)

find -maxdepth 1 -type f | cut -c 3- | grep -v \~ | jq -Rr '"[\(.)]: \(.) \u0027sibling file\u0027", "- [\(.)][]"' | env LANG=C sort
find out -type f | grep -v \~ | jq -Rr '"[\(.)]: \(.) \u0027sibling file\u0027", "- [\(.)][]"' | env LANG=C sort
-->

[FS-db.yml]: FS-db.yml 'sibling file'
[data.yml]: data.yml 'sibling file'

[out/FS-db.yml.diff]: out/FS-db.yml.diff 'sibling file'

[Local Variables:]::
[indent-tabs-mode: nil]::
[End:]::
