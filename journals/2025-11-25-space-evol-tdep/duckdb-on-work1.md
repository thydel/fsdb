<!-- markdown-toc-generate-toc -->
<!-- https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1036359 -->
<!--
mkdir -p tmp; pandoc README.md -t jira > tmp/README.jira
< duckdb-on-work1.md pandoc -f gfm -t gfm --toc --toc-depth=6 --template ../toc.md --columns=196 | grep -v Table.of.Contents
-->

# TOC

-   [Try duckdb on `work1`](#try-duckdb-on-work1)
    -   [Install docker](#install-docker)
    -   [Configure it](#configure-it)
    -   [Copy `duckdb`](#copy-duckdb)
    -   [Copy a small DB](#copy-a-small-db)
    -   [Run it via docker](#run-it-via-docker)
-   [Work, copy the target DB](#work-copy-the-target-db)
-   [Try `tdep` DB on work1](#try-tdep-db-on-work1)

# Try duckdb on `work1`

## Install docker

```bash
ssh work1 -l root apt-get install apt-transport-https ca-certificates curl gnupg2 software-properties-common
f () { https_proxy="http://proxy.admin2.oxa.tld:3128/" curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor > /etc/apt/trusted.gpg.d/docker.gpg; }
r () { declare -f $1; echo $@; }
r f | ssh work1 -l root bash
echo "deb [arch=amd64] https://download.docker.com/linux/debian stretch stable" | ssh work1 -l root tee /etc/apt/sources.list.d/docker.list
ssh work1 -l root aptitude update
ssh work1 -l root aptitude install docker-ce docker-ce-cli containerd.io
```

## Configure it

```bash
ssh work1 -l root addgroup thy docker
ssh work1 -l root mkdir -p /etc/systemd/system/docker.service.d
ssh work1 -l root tee /etc/systemd/system/docker.service.d/http-proxy.conf > /dev/null <<EOF
[Service]
Environment="HTTP_PROXY=http://proxy.admin2.oxa.tld:3128/"
Environment="HTTPS_PROXY=http://proxy.admin2.oxa.tld:3128/"
Environment="NO_PROXY=localhost,127.0.0.1,.oxa.tld"
EOF
ssh work1 -l root systemctl daemon-reload
ssh work1 -l root systemctl restart docker
```

## Copy `duckdb`

```bash
rsync -a /usr/local/bin/duckdb work1:
ssh work1 -l root mv /home/thy/duckdb /usr/local/bin
```

## Copy a small DB

```bash
rsync ../2025-11-05-space-evol-tdep/tmp/neoesis.db work1:
```

## Run it via docker

```bash
f () { docker run --rm -v /usr/local/bin/duckdb:/usr/bin/duckdb -v "$PWD":/data -w /data debian:12 duckdb neoesis.db -c 'select count(*) from stat'; }
```

---

```console
thy@tdews1-256g:2025-11-25-space-evol-tdep$ r f | ssh work1 bash
┌──────────────┐
│ count_star() │
│    int64     │
├──────────────┤
│       510825 │
└──────────────┘
```

# Work, copy the target DB

```bash
rsync -a ../2025-11-05-space-evol-tdep/out/tdep.db work1:
ssh work1 -l root mkdir /space2/duckdb
ssh work1 -l root chmod 755 /space2/duckdb
ssh work1 -l root mv /home/thy/tdep.db /space2/duckdb
ssh work1 -l root chown www-data:dev /space2/duckdb/tdep.db
ssh work1 -l root chmod 644 /space2/duckdb/tdep.db
```

# Try `tdep` DB on work1

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

<!--
bin=$INFRA/infra-lib-2023/bin
. <(echo ${nodes[@]} | sort | $bin/fmt-nodes.jq)

find -maxdepth 1 -type f | cut -c 3- | grep -v \~ | jq -Rr '"[\(.)]: \(.) \u0027sibling file\u0027", "- [\(.)][]"' | env LANG=C sort
find out -type f | grep -v \~ | jq -Rr '"[\(.)]: \(.) \u0027sibling file\u0027", "- [\(.)][]"' | env LANG=C sort
-->

[Local Variables:]::
[indent-tabs-mode: nil]::
[End:]::
