<!--
echo '$table-of-contents$' > tmp/toc.md
< '2026-05-28-frozen-data-set.md' pandoc -f gfm -t gfm --toc --toc-depth=6 --template ../tmp/toc.md --columns=196 | grep -v Table.of.Contents
-->

-   [Into](#into)
-   [Tools](#tools)
-   [Use well known github repo](#use-well-known-github-repo)
    -   [From scratch](#from-scratch)
    -   [From exinsting huge repo](#from-exinsting-huge-repo)
-   [Make DB](#make-db)
-   [Now we could start to make test](#now-we-could-start-to-make-test)

# Into

- Choose *frozen* data set to be use as test

# Tools

```bash
sudo aptitude install git-restore-mtime
```

# Use well known github repo

## From scratch

```bash
git -C spl clone --branch v3.14.5 https://github.com/python/cpython.git cpython-v3.14.5
git -C spl/cpython-v3.14.5 restore-mtime
```

## From exinsting huge repo

```bash
git -C ~/usr/extern/linux fetch
git -C ~/usr/extern/linux switch --detach v7.0
git -C ~/usr/extern/linux restore-mtime
```

# Make DB

```bash
db=cpython-v3.14.5
mk-files-stat spl $db
ingest-stat $db
reduce-stat $db

db=linux
mk-files-stat ~/usr/extern $db
ingest-stat $db
reduce-stat $db
```

# Now we could start to make test

- As if we rebuild `spl/cpython-v3.14.5` the same request

```bash
start | sum path[1:1] | order size | items 20 | human size | hide size | merge-cte | duckdb -markdown tmp/cpython-v3.14.5-small.db
```

- Should give the same result
- And we'll be able to ask agent to build a set of test and a test routine

|   path[1:1]    | cnt  |   hsize   |
|----------------|-----:|-----------|
| [.git]         | 24   | 834.2 MiB |
| [Lib]          | 2408 | 45.5 MiB  |
| [Doc]          | 634  | 16.8 MiB  |
| [Modules]      | 605  | 15.9 MiB  |
| [Misc]         | 160  | 8.6 MiB   |
| [Python]       | 130  | 5.3 MiB   |
| [Objects]      | 138  | 4.6 MiB   |
| [Tools]        | 398  | 3.7 MiB   |
| [PC]           | 91   | 2.6 MiB   |
| [Include]      | 284  | 1.8 MiB   |
| [Mac]          | 73   | 1.7 MiB   |
| [Parser]       | 26   | 1.6 MiB   |
| []             | 18   | 1.5 MiB   |
| [PCbuild]      | 139  | 784.4 KiB |
| [InternalDocs] | 18   | 189.0 KiB |
| [Platforms]    | 21   | 143.7 KiB |
| [Apple]        | 41   | 114.1 KiB |
| [.github]      | 39   | 103.2 KiB |
| [Programs]     | 9    | 83.3 KiB  |
| [Android]      | 19   | 78.8 KiB  |

```bash
start --part=date | span year | sum date | cumul size -p none | order date asc | human ssize | merge-cte | duckdb -markdown tmp/linux-small.db 
```

|          date          |  cnt  |    size    |   ssize    |  hssize   |
|------------------------|------:|-----------:|-----------:|-----------|
| 2005-01-01 01:00:00+01 | 55    | 1105390    | 1105390    | 1.0 MiB   |
| 2006-01-01 01:00:00+01 | 55    | 472413     | 1577803    | 1.5 MiB   |
| 2007-01-01 01:00:00+01 | 29    | 645130     | 2222933    | 2.1 MiB   |
| 2008-01-01 01:00:00+01 | 58    | 200076     | 2423009    | 2.3 MiB   |
| 2009-01-01 01:00:00+01 | 276   | 246601     | 2669610    | 2.5 MiB   |
| 2010-01-01 01:00:00+01 | 58    | 294430     | 2964040    | 2.8 MiB   |
| 2011-01-01 01:00:00+01 | 109   | 643888     | 3607928    | 3.4 MiB   |
| 2012-01-01 01:00:00+01 | 162   | 575562     | 4183490    | 3.9 MiB   |
| 2013-01-01 01:00:00+01 | 174   | 1048432    | 5231922    | 4.9 MiB   |
| 2014-01-01 01:00:00+01 | 282   | 1864465    | 7096387    | 6.7 MiB   |
| 2015-01-01 01:00:00+01 | 403   | 13948820   | 21045207   | 20.0 MiB  |
| 2016-01-01 01:00:00+01 | 365   | 8697290    | 29742497   | 28.3 MiB  |
| 2017-01-01 01:00:00+01 | 2858  | 17509340   | 47251837   | 45.0 MiB  |
| 2018-01-01 01:00:00+01 | 1489  | 25157301   | 72409138   | 69.0 MiB  |
| 2019-01-01 01:00:00+01 | 5995  | 73343022   | 145752160  | 139.0 MiB |
| 2020-01-01 01:00:00+01 | 4472  | 55852708   | 201604868  | 192.2 MiB |
| 2021-01-01 01:00:00+01 | 3699  | 48071586   | 249676454  | 238.1 MiB |
| 2022-01-01 01:00:00+01 | 6656  | 165894217  | 415570671  | 396.3 MiB |
| 2023-01-01 01:00:00+01 | 10085 | 408045910  | 823616581  | 785.4 MiB |
| 2024-01-01 01:00:00+01 | 14343 | 897396407  | 1721012988 | 1.6 GiB   |
| 2025-01-01 01:00:00+01 | 27598 | 402431095  | 2123444083 | 1.9 GiB   |
| 2026-01-01 01:00:00+01 | 14996 | 6515761523 | 8639205606 | 8.0 GiB   |

<!--
find -maxdepth 1 -type f | cut -c 3- | grep -v \~ | jq -Rr '"[\(.)]: \(.) \u0027sibling file\u0027", "- [\(.)][]"' | env LANG=C sort
find out -type f | grep -v \~ | jq -Rr '"[\(.)]: \(.) \u0027sibling file\u0027", "- [\(.)][]"' | env LANG=C sort
-->

[Local Variables:]::
[indent-tabs-mode: nil]::
[End:]::
