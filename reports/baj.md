# Baj expert rules

Rules inferred from the baj codebase for building baj libraries.

## Source format choice

- Default to **Markdown** source files
- YAML is simpler for pure-function libraries with no prose
- Markdown when the lib doubles as a literate notebook (code + docs +
  examples interleaved)

## Markdown source structure

A Markdown baj source follows a strict convention parsed by
`baj-boot.sh` / `md2js`:

1. **m4 preamble** as an HTML comment on the very first line:

   ```html
   <!-- m4_changequote(«,»)m4_changecom() -->
   ```

2. **`raw header`** section — defines namespace via `m4_define` +
   YAML code block:

   ```markdown
   # raw header

   ~~~m4
   m4_define(ME,myns)
   ~~~

   ~~~yml
   - { id: null, ns: ME }
   ~~~
   ```

   - `ME` is the conventional m4 macro for the namespace name
   - `id: null` makes this a **root** object (distributed to all subs)

3. **Function sections** — each headed `# id <name>`:

   ```markdown
   # id my-func

   Optional prose...

   ~~~bash
   echo hello "$@"
   ~~~
   ```

   - The header text after `id ` becomes the function's `id` field
   - Code blocks are keyed by their language tag: `bash` -> `sh`,
     `jq` -> `jq`, `sql` -> `sql`, `perl` -> `perl`, `json` -> `js`,
     `yml` -> `yml`
   - Multiple code blocks in one section accumulate into the same
     object

## YAML source structure

A YAML source is a flat array of objects. The pipeline reads it with
`yq -oj`.

### Namespace declaration

```yaml
- id:
  ns: myns
```

An object with empty `id` and a `ns` key sets the namespace. This is
also a **root** object — its keys are inherited by all `sub` objects.

### Root objects (defaults)

```yaml
- id:
  sh: ': ${1:?}; PATH=$(jq "$jq" -nr --args "$@")'
```

An object with `id: null` / `id:` (empty) / `id: []` is a root. Its
fields are distributed to every `sub` via deep merge.

### Sub objects (concrete functions)

```yaml
- id: addp
  jq: 'EP | ($ARGS.positional - $p) + $p | join(":")'
```

A scalar `id` makes a **sub** — a concrete function that will be
emitted.

### Sup objects (inherited fragments)

```yaml
- id: [addp, delp]
  is: [fa]
```

An array `id` makes a **sup** — its fields are merged into the listed
subs. Use this to share metadata across a subset of functions.

### Alien objects (pass-through)

```yaml
- m4:
    EP: '(env.PATH / ":") as $p'
```

Objects without an `id` field are **alien**. They pass through
distribution unchanged. The `m4:` key object is the canonical alien —
it defines m4 macros.

### Compact notation

Use inline YAML for short definitions:

```yaml
- { id: fail, sh: 'unset -v fail; : "${fail:?${FUNCNAME[1]} $@}"' }
- { id: loop, sh: 'local i; for i in "${@:2}"; do $1 "$i"; done' }
```

## Key fields

| Field | Emitted as | Purpose |
|-------|-----------|---------|
| `id`  | function name | scalar = sub, array = sup, null/empty = root |
| `ns`  | namespace prefix | `ns:id` is the qualified function name |
| `sh`  | function body | raw bash code |
| `jq`  | `local jq='...'` | jq program carried as data |
| `sql` | `local sql='...'` | SQL template carried as data |
| `perl`| `local perl='...'` | perl program carried as data |
| `js`  | `local js=<json>` | JSON data (uses `@json` quoting, not `@sh`) |
| `is`  | metadata tags | array of role tags (e.g. `[fa]`, `[na]`, `[nv]`) |
| `ky`  | metadata tags | array of key names that form tag combinations with `is` |
| `lv`  | `local -v` scope | array of keys promoted to local vars |
| `tt`  | (not emitted) | example / test text shown in docs |
| `m4`  | (consumed by m4 stage) | macro definitions |

## The `is` tag system

Tags in the `is` array control emission behavior:

| Tag | Meaning |
|-----|---------|
| `fa` | **funarg** — alias ends with a space (makes it a macro-like alias that swallows the next word) |
| `na` | **no-alias** — alias is emitted then immediately `unalias`-ed after sourcing (internal helper, not user-facing) |
| `nv` | **no-var** — listed `ky` keys are not emitted as `local` variables |

Tags are declared on sup objects to apply to multiple subs:

```yaml
- id: [loop, args, map]
  is: [fa]
```

## m4 macros

### Declaration

```yaml
- m4:
    EP: '(env.PATH / ":") as $p'
```

Or in Markdown:

```markdown
~~~m4
m4_define(ME,fsdb)
~~~
```

### Rules

- m4 runs **before** inheritance — expanded text participates in
  distribution naturally
- Use French guillemets `« »` as m4 quotes (set in preamble)
- Comments are disabled (`m4_changecom()`)
- Prefix macros with `-P` flag (m4 builtins need `m4_` prefix)
- Keep macro names short and uppercase by convention (e.g. `EP`,
  `ME`, `SQL`, `SELF`, `NS`, `ID`, `OPTS`)
- `ME` is the standard namespace macro

### Common macro patterns

From `baj-lib.yml`:

```yaml
- m4:
    NS: '${FUNCNAME%%:*}'          # current namespace at runtime
    ID: '${FUNCNAME#*:}'           # current function name at runtime
    SELF: 'jq "$jq" $@'           # call own jq program
    OPTS: 'local -A opts; local args cont; opts "$«@»"'  # parse opts
```

From libraries using jq-in-sql patterns:

```yaml
- m4:
    SQL: 'jq -nr "\"$sql\"" "$«@»"'   # interpolate jq args into sql
```

Note: `«@»` is `@` inside m4 guillemets to avoid m4 interpreting `$@`.

## Inheritance rules

Distribution (stage 3) merges fields from root/sup into sub:

- **Scalars**: sub value wins (overrides sup)
- **Arrays**: concatenation + deduplication
- **Objects**: recursive deep merge
- Order is deterministic
- All m4 expansion is already done before merge

### Typical inheritance pattern

```yaml
# Root — shared body template
- id:
  sh: ': ${1:?}; PATH=$(jq "$jq" -nr --args "$@")'

# Subs — only supply the varying jq program
- id: addp
  jq: 'EP | ($ARGS.positional - $p) + $p | join(":")'
- id: delp
  jq: 'EP | $p - $ARGS.positional | join(":")'
```

Both `addp` and `delp` inherit the `sh:` body. Each provides its own
`jq:` expression.

## The `self` pattern

The standard library provides `self`:

```yaml
- { id: self, sh: jq "$jq" "$@" }
```

Functions that carry a `jq:` program can call `self` to run it:

```yaml
- id: path-to-name
  jq: '. / "/" | map(select(length > 0)) | join("-")'
  sh: '<<< ${1:?} self -Rr'
```

This is the idiomatic way to write jq-centric functions. The `jq:`
becomes `local jq='...'` and `self` calls `jq "$jq"`.

Similarly, `SQL` macro pattern for SQL-centric functions:

```yaml
- id: query-stat
  sql: 'SELECT ... FROM fsdb ...'
  sh: 'SQL --arg depth "$depth" --arg time "$time" | duckdb DB'
```

## The `js` field (JSON data)

The `js` field is emitted as `local js=<json>` (using `@json`
quoting, not `@sh`). Use it to embed structured data:

```yaml
- id: md2yml-v1
  js:
    bash: sh
    json: js
    txt: tt
  jq: '... $map ...'
  sh: 'mdq -o json ... | JQ(--argjson map "$js")'
```

## Function body patterns

### Minimal jq wrapper

```yaml
- id: nss1
  jq: '.[].ns // empty'
  sh: '< ${1:?} yq -oj | self -r'
```

### Pipeline composition (calling other functions)

```yaml
- id: git-repo-to-md
  sh: git-repo-to-url | git-url-to-md repo
```

Functions call other functions by short alias. Aliases are resolved at
parse time to qualified names.

### Short alias definition

```yaml
- { id: gr2md, sh: git-repo-to-md "$@" }
```

A one-liner function that delegates — creates a convenience alias.

### Guard patterns

```yaml
sh: ': ${1:?}'              # require at least one arg
sh: ': ${2:?}'              # require at least two args
sh: 'check-tty; ...'       # validate stdin is not a terminal
```

### Multi-language functions

A function can carry multiple code blocks:

```yaml
- id: files-stat
  perl: |
    BEGIN { $t = time; $j = JSON::PP->new->utf8 }
    chomp; @s = lstat($_); next unless @s;
    print $j->encode([$t, $s[9], $s[7], $_]), "\n"
  sh: |
    (cd ${1:?} && find -type f -print0 | perl -MJSON::PP -0 -ne "$perl")
```

The `perl:` becomes `local perl='...'` and the bash body references
`"$perl"`.

## Build pipeline (Makefile)

### For YAML source

```makefile
out/%.sh: lib/%.yml
	source baj.sh
	load $<
	nss $< | args as-cmd | install /dev/stdin $@
```

### For Markdown source

```makefile
out/%.yml: %.md $(mdq) | out
	< $< m4 -P | $(lastword $^) md2yml | install /dev/stdin $@

out/%.sh: out/%.yml
	source baj.sh
	load $<
	nss $< | args as-cmd | install /dev/stdin $@
```

Markdown goes through an extra step: `m4 -P` expansion + `md2yml`
conversion to YAML, then the same YAML-to-bash path.

## Dual execution

Every generated file ends with `eval "$@"`:

- **Library mode**: `source out/mylib.sh` — loads functions + aliases
- **Command mode**: `./out/mylib.sh ns:func arg...` — runs one
  function

## Zero-copy remote execution

```bash
with-lib fsdb -- ingest-stat /data/mysql /space/var | ssh host -l root bash
```

`with-lib` serializes selected functions via `declare -f` and streams
them. Nothing is installed on the remote.

## Naming conventions

- Namespace names: short, lowercase (e.g. `path`, `fsdb`, `git2md`,
  `bajl`, `pa`, `llmfs`)
- Function names: lowercase, hyphen-separated (e.g. `files-stat`,
  `add-snapshot`, `git-repo-to-url`)
- m4 macros: UPPERCASE, short (e.g. `ME`, `EP`, `SQL`, `NS`, `ID`)
- Qualified form: `ns:func` (e.g. `fsdb:files-stat`)
- Short aliases: same as `id` (e.g. `files-stat` without prefix)

## Checklist for building a new baj library

1. Choose source format (Markdown default, YAML for pure libs)
2. Pick a short namespace name
3. Write the header (m4 preamble + raw header with `ME` macro)
4. Identify the composable primitive set of functions
5. Factor shared behavior into root objects (common `sh:` body, common
   args)
6. Define m4 macros for repeated jq/sql/bash fragments
7. Write sub objects — one per function, carrying their `jq:`/`sql:`
   data
8. Use `is:` tags for special emission behavior (`fa`, `na`, `nv`)
9. Add `tt:` blocks for usage examples (not emitted)
10. Test with `source baj.sh && load out/mylib.yml`
11. Build with `make`

[Local Variables:]::
[indent-tabs-mode: nil]::
[End:]::
