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
