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

# Add lib build DB

- Start back from [2025-11-05 Space-evol-tdep][]
- Add [tdep.yml][]

```bash
load tdep.yml
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
