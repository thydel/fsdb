# id server-path

- Convert NFS client path to NFS server path

```bash
readlink ${1:-/space/applisdata} | xargs readlink
```

```sh
with ssp:server-path | fn-ansible -l profnt[epr]1
```

# id server-path-simple

- Convert NFS client path to NFS server path

```bash
readlink ${1:-/space/applisdata}
```

```sh
with mailmerge:server-path-simple | fn-ansible -l promailmerge1
```

# id mk-conf

- Make a usable conf from server path

```jq
def item: (.stdout_lines[0] / "/") as $path | { client: .node, server: $path[2], path: ([""] + $path[3:] | join("/")) };
INDEX(map(item)[]; .client)
```

```sh
with ssp:server-path | fn-ansible -l profnt[epr]1 | mk-conf > out/conf.js
with mailmerge:server-path-simple | fn-ansible -l promailmerge1 | mk-conf > out/conf.js
```
