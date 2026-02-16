# Minimize tokens

```bash
pandoc -f gfm -t gfm --lua-filter=simple_ragged.lua --wrap=none
```

# Human format

```bash
pandoc -t gfm -f gfm --column=80
```
