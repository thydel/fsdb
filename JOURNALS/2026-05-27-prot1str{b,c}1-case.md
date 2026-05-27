<!--
echo '$table-of-contents$' > tmp/toc.md
< '2026-05-27-prot1str{b,c}1-case.md' pandoc -f gfm -t gfm --toc --toc-depth=6 --template ../tmp/toc.md --columns=196 | grep -v Table.of.Contents
-->

-   [Intro](#intro)
-   [Env](#env)
-   [Basic facts](#basic-facts)
    -   [Full DB](#full-db)
    -   [Small DB](#small-db)
-   [Find biggest dirs](#find-biggest-dirs)
    -   [Simplest form](#simplest-form)
    -   [Focus on top level dirs](#focus-on-top-level-dirs)
    -   [We can also work merged DB](#we-can-also-work-merged-db)
-   [Look by time](#look-by-time)
    -   [Focus on strange `ssp/upload/files_1731959368` occurring on both server](#focus-on-strange-sspuploadfiles_1731959368-occurring-on-both-server)
        -   [`prot1strb1` by year](#prot1strb1-by-year)
        -   [`prot1strc1` by year](#prot1strc1-by-year)
        -   [`prot1strb1` last year by month](#prot1strb1-last-year-by-month)
        -   [`prot1strc1` last year by month](#prot1strc1-last-year-by-month)
-   [Focus on biggest](#focus-on-biggest)
    -   [`ssp_ndf/upload/files_1731959368_by_group` on `prot1strb1` stop growing in 2024](#ssp_ndfuploadfiles_1731959368_by_group-on-prot1strb1-stop-growing-in-2024)
    -   [`ssp/upload/files_1731959368_by_group` on `prot1strc1` still growing](#sspuploadfiles_1731959368_by_group-on-prot1strc1-still-growing)
-   [Use minimal plot](#use-minimal-plot)
    -   [`prot1strb1` by year](#prot1strb1-by-year-1)
    -   [`prot1strc1` by year](#prot1strc1-by-year-1)
-   [Growth pipes](#growth-pipes)
    -   [`prot1strb1`, pivot 2025, unit 1M](#prot1strb1-pivot-2025-unit-1m)
    -   [`prot1strc1`, pivot 2025, unit 1G](#prot1strc1-pivot-2025-unit-1g)
    -   [`prot1strb1`, since 2025 pivot 2026, unit 1M](#prot1strb1-since-2025-pivot-2026-unit-1m)
    -   [`prot1strc1`, since 2025 pivot 2026, unit 1M](#prot1strc1-since-2025-pivot-2026-unit-1m)
    -   [Any server with apicrypt as level 4 dir, pivot 2026, unit 1M](#any-server-with-apicrypt-as-level-4-dir-pivot-2026-unit-1m)

# Intro

- Try to use `fsdb` on a specific situation
- See what we can tell on two quite full servers

# Env

```bash
allf=tmp/nfsdata.db
alls=tmp/nfsdata-small.db

b1f=tmp/prot1strb1-data-nfsdata.db
c1f=tmp/prot1strc1-data-nfsdata.db

b1s=tmp/prot1strb1-data-nfsdata-small.db
c1s=tmp/prot1strc1-data-nfsdata-small.db
```

# Basic facts

- Edit [fsdb-misc.md][] for [Allows use of basic-facts on by server DB][]

[Allows use of basic-facts on by server DB]:
    https://github.com/thydel/fsdb/commit/e942cee3d61534ffd7e4c11c5db991a47183ed86
    "github.com commit"

[fsdb-misc.md]:
    https://github.com/thydel/fsdb/blob/tmp/fsdb-misc.md
    "github.com file"

## Full DB

- With all files

```bash
table-info | duckdb $b1f -markdown
```

| column_name |       column_type        |
|-------------|--------------------------|
| inode       | BIGINT                   |
| uts         | TIMESTAMP WITH TIME ZONE |
| size        | BIGINT                   |
| path        | VARCHAR[]                |

```bash
full-db-basic-facts path[0:4] | duckdb $b1f -markdown
```

|   start    |    end     | path[0:4] |  files  |   size    |
|------------|------------|----------:|---------|-----------|
| 2010-01-31 | 2026-05-07 | 39        | 3.0 MiB | 639.9 GiB |

```bash
full-db-basic-facts path[0:4] | duckdb $c1f -markdown
```

|   start    |    end     | path[0:4] |  files  |   size    |
|------------|------------|----------:|---------|-----------|
| 2014-07-15 | 2026-05-07 | 20        | 2.0 MiB | 648.2 GiB |


## Small DB

- Reduced (sum and cnt) by dir (like jq `path[:-1]`)

```bash
table-info | duckdb $b1s -markdown
```

| column_name |       column_type        |
|-------------|--------------------------|
| date        | TIMESTAMP WITH TIME ZONE |
| path        | VARCHAR[]                |
| cnt         | BIGINT                   |
| size        | HUGEINT                  |
| min         | BIGINT                   |
| max         | BIGINT                   |
| mean        | DOUBLE                   |

```bash
small-db-basic-facts path[1:4] | duckdb $b1s -markdown
```

|   start    |    end     |   rows    | path[1:4] |   dirs   |  files  |   size    |
|------------|------------|-----------|----------:|----------|---------|-----------|
| 2010-01-31 | 2026-05-07 | 161.5 KiB | 29        | 25.1 KiB | 3.0 MiB | 639.9 GiB |


```bash
small-db-basic-facts path[1:4] | duckdb $c1s -box
```

|   start    |    end     |   rows    | path[1:4] |   dirs   |  files  |   size    |
|------------|------------|-----------|----------:|----------|---------|-----------|
| 2014-07-15 | 2026-05-07 | 262.2 KiB | 20        | 36.3 KiB | 2.0 MiB | 648.2 GiB |

# Find biggest dirs

## Simplest form

```bash
start | sum path | order size | items 10 | merge-cte | duckdb $b1s -markdown
```

|                              path                               |   cnt   |     size     |
|-----------------------------------------------------------------|--------:|-------------:|
| [profntr1, applisdata, ssp, upload, files_1731959368]           | 1100119 | 180271794019 |
| [profntr1, applisdata, ssp_ndf, upload, files_1731959368]       | 731269  | 144193234301 |
| [profntr1, applisdata, ssp_ndf_stats, upload, files_1731959368] | 475184  | 39025198788  |
| [profntr1, applisdata, ssp_ndf, upload_reprise_93, upload_prod] | 43839   | 26358831185  |
| [profntr1, applisdata, ssp_ndf, upload_reprise_93]              | 2       | 26278635747  |
| [profntr1, applisdata, ssp_ndf, apicrypt, 446, attachments]     | 28017   | 6450285596   |
| [profntr1, applisdata, ssp_ndf, apicrypt, 485, attachments]     | 29237   | 6350960904   |
| [profntr1, applisdata, ssp, apicrypt, 310, attachments]         | 39751   | 6216985486   |
| [profntr1, applisdata, ssp, apicrypt, 759, attachments]         | 57954   | 5869669904   |
| [profntr1, applisdata, ssp_ndf, apicrypt, 230, attachments]     | 9040    | 2478543517   |


```bash
start | sum path | order size | items 10 | merge-cte | duckdb $c1s -markdown
```

|                                     path                                      |  cnt   |     size     |
|-------------------------------------------------------------------------------|-------:|-------------:|
| [profnte1, applisdata, ssp, upload, files_1731959368]                         | 329951 | 156578371687 |
| [profnte1, applisdata, ssp, apicrypt, 201, attachments]                       | 73043  | 17543127701  |
| [profnte1, applisdata, ssp, upload, files_1731959368_by_group, 868, 2023, 11] | 206068 | 12558963198  |
| [profnte1, applisdata, ssp, upload, files_1731959368_by_group, 868, 2023, 05] | 205963 | 12493502557  |
| [profnte1, applisdata, ssp, apicrypt, 338, attachments]                       | 53360  | 10523007126  |
| [profnte1, applisdata, ssp, apicrypt, 338-SLM, attachments]                   | 22236  | 4362389424   |
| [profnte1, applisdata, ssp, apicrypt, 664, attachments]                       | 6388   | 4049285174   |
| [profnte1, applisdata, ssp, restitution, 523, 20251103174423_upload]          | 9529   | 3903354009   |
| [profnte1, applisdata, ssp, apicrypt, 923, attachments]                       | 11998  | 2882878963   |
| [profnte1, applisdata, ssp, upload, files_1731959368_by_group, 201, 2023, 05] | 2301   | 2103073558   |

## Focus on top level dirs

```bash
start | as path[3:5] dir | sum dir | order size | items 10 | human size | keep dir hsize | merge-cte | duckdb $b1s -markdown
```

|                     dir                      |   hsize   |
|----------------------------------------------|-----------|
| [ssp_ndf, upload, files_1731959368_by_group] | 215.2 GiB |
| [ssp, upload, files_1731959368]              | 167.8 GiB |
| [ssp_ndf, upload, files_1731959368]          | 134.2 GiB |
| [ssp_ndf_stats, upload, files_1731959368]    | 36.3 GiB  |
| [ssp_ndf, upload_reprise_93, upload_prod]    | 24.5 GiB  |
| [ssp_ndf, upload_reprise_93]                 | 24.4 GiB  |
| [ssp_ndf, apicrypt, 446]                     | 7.1 GiB   |
| [ssp, apicrypt, 310]                         | 5.9 GiB   |
| [ssp_ndf, apicrypt, 485]                     | 5.9 GiB   |
| [ssp, apicrypt, 759]                         | 5.5 GiB   |


```bash
start | as path[3:5] dir | sum dir | order size | items 10 | human size | keep dir hsize | merge-cte | duckdb $c1s -markdown
```

|                   dir                    |   hsize   |
|------------------------------------------|-----------|
| [ssp, upload, files_1731959368_by_group] | 444.6 GiB |
| [ssp, upload, files_1731959368]          | 145.8 GiB |
| [ssp, apicrypt, 201]                     | 17.1 GiB  |
| [ssp, apicrypt, 338]                     | 10.9 GiB  |
| [ssp, apicrypt, 338-SLM]                 | 4.5 GiB   |
| [ssp, apicrypt, 664]                     | 3.7 GiB   |
| [ssp, restitution, 523]                  | 3.6 GiB   |
| [ssp, apicrypt, 923]                     | 2.9 GiB   |
| [cupidon, upload, files_177041596]       | 1.7 GiB   |
| [ssp, ORU]                               | 1.6 GiB   |

## We can also work merged DB

```bash
start | regexp server 'prot1str[cb]1.*' | as path[1:5] dir | sum server,dir | order size | items 20 | human size | keep server dir hsize | merge-cte | ddb -markdown
```

|            server             |                                dir                                 |   hsize   |
|-------------------------------|--------------------------------------------------------------------|-----------|
| prot1strc1_data_nfsdata_small | [profnte1, applisdata, ssp, upload, files_1731959368_by_group]     | 444.6 GiB |
| prot1strb1_data_nfsdata_small | [profntr1, applisdata, ssp_ndf, upload, files_1731959368_by_group] | 215.2 GiB |
| prot1strb1_data_nfsdata_small | [profntr1, applisdata, ssp, upload, files_1731959368]              | 167.8 GiB |
| prot1strc1_data_nfsdata_small | [profnte1, applisdata, ssp, upload, files_1731959368]              | 145.8 GiB |
| prot1strb1_data_nfsdata_small | [profntr1, applisdata, ssp_ndf, upload, files_1731959368]          | 134.2 GiB |
| prot1strb1_data_nfsdata_small | [profntr1, applisdata, ssp_ndf_stats, upload, files_1731959368]    | 36.3 GiB  |
| prot1strb1_data_nfsdata_small | [profntr1, applisdata, ssp_ndf, upload_reprise_93, upload_prod]    | 24.5 GiB  |
| prot1strb1_data_nfsdata_small | [profntr1, applisdata, ssp_ndf, upload_reprise_93]                 | 24.4 GiB  |
| prot1strc1_data_nfsdata_small | [profnte1, applisdata, ssp, apicrypt, 201]                         | 17.1 GiB  |
| prot1strc1_data_nfsdata_small | [profnte1, applisdata, ssp, apicrypt, 338]                         | 10.9 GiB  |
| prot1strb1_data_nfsdata_small | [profntr1, applisdata, ssp_ndf, apicrypt, 446]                     | 7.1 GiB   |
| prot1strb1_data_nfsdata_small | [profntr1, applisdata, ssp, apicrypt, 310]                         | 5.9 GiB   |
| prot1strb1_data_nfsdata_small | [profntr1, applisdata, ssp_ndf, apicrypt, 485]                     | 5.9 GiB   |
| prot1strb1_data_nfsdata_small | [profntr1, applisdata, ssp, apicrypt, 759]                         | 5.5 GiB   |
| prot1strc1_data_nfsdata_small | [profnte1, applisdata, ssp, apicrypt, 338-SLM]                     | 4.5 GiB   |
| prot1strc1_data_nfsdata_small | [profnte1, applisdata, ssp, apicrypt, 664]                         | 3.7 GiB   |
| prot1strc1_data_nfsdata_small | [profnte1, applisdata, ssp, restitution, 523]                      | 3.6 GiB   |
| prot1strb1_data_nfsdata_small | [profntr1, applisdata, ssp_ndf, apicrypt, 230]                     | 3.1 GiB   |
| prot1strc1_data_nfsdata_small | [profnte1, applisdata, ssp, apicrypt, 923]                         | 2.9 GiB   |
| prot1strb1_data_nfsdata_small | [profntr1, applisdata, ssp_ndf, apicrypt, 772]                     | 2.7 GiB   |

# Look by time

## Focus on strange `ssp/upload/files_1731959368` occurring on both server

- But serving two differen front (`profnte1` and `profntr1`)
- And after looking by year and by last 12 months they seem both
  growing normally

> [!NOTE]
>
> - The `group` arg in `span` CTE is needed because it default to `server` col which is in merged DB only
> - That may need an architectural change

### `prot1strb1` by year

```bash
start | is path[3:5] '[ssp, upload, files_1731959368]' | span year --group path[1] | order date asc | human size | merge-cte | duckdb $b1s -markdown
```

|          date          | path[1]  |  cnt   |     size     |   hsize   |
|------------------------|----------|-------:|-------------:|-----------|
| 2017-01-01 01:00:00+01 | profntr1 | 31     | 26324216     | 25.1 MiB  |
| 2018-01-01 01:00:00+01 | profntr1 | 4164   | 1590590729   | 1.4 GiB   |
| 2019-01-01 01:00:00+01 | profntr1 | 20065  | 5688304109   | 5.2 GiB   |
| 2020-01-01 01:00:00+01 | profntr1 | 15403  | 4470011798   | 4.1 GiB   |
| 2021-01-01 01:00:00+01 | profntr1 | 16328  | 3767044874   | 3.5 GiB   |
| 2022-01-01 01:00:00+01 | profntr1 | 252187 | 11794197412  | 10.9 GiB  |
| 2023-01-01 01:00:00+01 | profntr1 | 656905 | 114744246101 | 106.8 GiB |
| 2024-01-01 01:00:00+01 | profntr1 | 72179  | 17061123824  | 15.8 GiB  |
| 2025-01-01 01:00:00+01 | profntr1 | 46463  | 15270519507  | 14.2 GiB  |
| 2026-01-01 01:00:00+01 | profntr1 | 16394  | 5859431449   | 5.4 GiB   |

### `prot1strc1` by year

```bash
start | is path[3:5] '[ssp, upload, files_1731959368]' | span year --group path[1] | order date asc | human size | merge-cte | duckdb $c1s -markdown
```

|          date          | path[1]  |  cnt   |    size     |   hsize   |
|------------------------|----------|-------:|------------:|-----------|
| 2014-01-01 01:00:00+01 | profnte1 | 56     | 53345924    | 50.8 MiB  |
| 2015-01-01 01:00:00+01 | profnte1 | 591    | 654187982   | 623.8 MiB |
| 2016-01-01 01:00:00+01 | profnte1 | 524    | 531011992   | 506.4 MiB |
| 2017-01-01 01:00:00+01 | profnte1 | 740    | 741463803   | 707.1 MiB |
| 2018-01-01 01:00:00+01 | profnte1 | 735    | 640364208   | 610.6 MiB |
| 2019-01-01 01:00:00+01 | profnte1 | 821    | 642088692   | 612.3 MiB |
| 2020-01-01 01:00:00+01 | profnte1 | 793    | 590751203   | 563.3 MiB |
| 2021-01-01 01:00:00+01 | profnte1 | 513    | 360665149   | 343.9 MiB |
| 2022-01-01 01:00:00+01 | profnte1 | 122    | 124021784   | 118.2 MiB |
| 2023-01-01 01:00:00+01 | profnte1 | 81     | 31231697    | 29.7 MiB  |
| 2024-01-01 01:00:00+01 | profnte1 | 113215 | 50968302832 | 47.4 GiB  |
| 2025-01-01 01:00:00+01 | profnte1 | 153445 | 72205285575 | 67.2 GiB  |
| 2026-01-01 01:00:00+01 | profnte1 | 58315  | 29035650846 | 27.0 GiB  |

### `prot1strb1` last year by month

```bash
start | is path[3:5] '[ssp, upload, files_1731959368]' | last 1 year | span month --group path[1] | order date asc | human size | merge-cte | duckdb $b1s -markdown
```

|          date          | path[1]  | cnt  |    size    |   hsize   |
|------------------------|----------|-----:|-----------:|-----------|
| 2025-05-01 02:00:00+02 | profntr1 | 155  | 97734920   | 93.2 MiB  |
| 2025-06-01 02:00:00+02 | profntr1 | 3495 | 1221453951 | 1.1 GiB   |
| 2025-07-01 02:00:00+02 | profntr1 | 3406 | 1152484660 | 1.0 GiB   |
| 2025-08-01 02:00:00+02 | profntr1 | 2902 | 849047845  | 809.7 MiB |
| 2025-09-01 02:00:00+02 | profntr1 | 3841 | 1181442217 | 1.0 GiB   |
| 2025-10-01 02:00:00+02 | profntr1 | 3953 | 1421439629 | 1.3 GiB   |
| 2025-11-01 01:00:00+01 | profntr1 | 3233 | 1235856865 | 1.1 GiB   |
| 2025-12-01 01:00:00+01 | profntr1 | 3349 | 1362422597 | 1.2 GiB   |
| 2026-01-01 01:00:00+01 | profntr1 | 3576 | 1414576527 | 1.3 GiB   |
| 2026-02-01 01:00:00+01 | profntr1 | 3762 | 1227502721 | 1.1 GiB   |
| 2026-03-01 01:00:00+01 | profntr1 | 3797 | 1607401601 | 1.4 GiB   |
| 2026-04-01 02:00:00+02 | profntr1 | 4604 | 1398090540 | 1.3 GiB   |
| 2026-05-01 02:00:00+02 | profntr1 | 655  | 211860060  | 202.0 MiB |


### `prot1strc1` last year by month

```bash
start | is path[3:5] '[ssp, upload, files_1731959368]' | last 1 year | span month --group path[1] | order date asc | human size | merge-cte | duckdb $c1s -markdown
```

|          date          | path[1]  |  cnt  |    size    |   hsize   |
|------------------------|----------|------:|-----------:|-----------|
| 2025-05-01 02:00:00+02 | profnte1 | 704   | 329449650  | 314.1 MiB |
| 2025-06-01 02:00:00+02 | profnte1 | 12602 | 6016952842 | 5.6 GiB   |
| 2025-07-01 02:00:00+02 | profnte1 | 12911 | 6092330654 | 5.6 GiB   |
| 2025-08-01 02:00:00+02 | profnte1 | 10343 | 5759257202 | 5.3 GiB   |
| 2025-09-01 02:00:00+02 | profnte1 | 16069 | 7388773850 | 6.8 GiB   |
| 2025-10-01 02:00:00+02 | profnte1 | 16823 | 7708288255 | 7.1 GiB   |
| 2025-11-01 01:00:00+01 | profnte1 | 12676 | 6421241302 | 5.9 GiB   |
| 2025-12-01 01:00:00+01 | profnte1 | 12340 | 6007383417 | 5.5 GiB   |
| 2026-01-01 01:00:00+01 | profnte1 | 14114 | 7030682981 | 6.5 GiB   |
| 2026-02-01 01:00:00+01 | profnte1 | 12901 | 6370310614 | 5.9 GiB   |
| 2026-03-01 01:00:00+01 | profnte1 | 15165 | 7802532756 | 7.2 GiB   |
| 2026-04-01 02:00:00+02 | profnte1 | 13639 | 6668921813 | 6.2 GiB   |
| 2026-05-01 02:00:00+02 | profnte1 | 2496  | 1163202682 | 1.0 GiB   |

# Focus on biggest

## `ssp_ndf/upload/files_1731959368_by_group` on `prot1strb1` stop growing in 2024

```bash
start | is path[5] files_1731959368_by_group | span year --group path[1] | order date asc | human size | merge-cte | duckdb $b1s -markdown
```

|          date          | path[1]  |  cnt  |    size     |  hsize   |
|------------------------|----------|------:|------------:|----------|
| 2014-01-01 01:00:00+01 | profntr1 | 8982  | 3583669656  | 3.3 GiB  |
| 2015-01-01 01:00:00+01 | profntr1 | 22317 | 11843534661 | 11.0 GiB |
| 2016-01-01 01:00:00+01 | profntr1 | 19050 | 10389315924 | 9.6 GiB  |
| 2017-01-01 01:00:00+01 | profntr1 | 23244 | 14724068386 | 13.7 GiB |
| 2018-01-01 01:00:00+01 | profntr1 | 25482 | 14930794371 | 13.9 GiB |
| 2019-01-01 01:00:00+01 | profntr1 | 40669 | 20787252358 | 19.3 GiB |
| 2020-01-01 01:00:00+01 | profntr1 | 54648 | 25681387046 | 23.9 GiB |
| 2021-01-01 01:00:00+01 | profntr1 | 49852 | 24129864558 | 22.4 GiB |
| 2022-01-01 01:00:00+01 | profntr1 | 55490 | 29430622841 | 27.4 GiB |
| 2023-01-01 01:00:00+01 | profntr1 | 70038 | 35675481830 | 33.2 GiB |
| 2024-01-01 01:00:00+01 | profntr1 | 88691 | 39965654891 | 37.2 GiB |

## `ssp/upload/files_1731959368_by_group` on `prot1strc1` still growing

```bash
start | is path[5] files_1731959368_by_group | span year --group path[1] | order date asc | human size | merge-cte | duckdb $c1s -markdown
```

|          date          | path[1]  |  cnt   |     size     |   hsize   |
|------------------------|----------|-------:|-------------:|-----------|
| 2014-01-01 01:00:00+01 | profnte1 | 9582   | 4149304688   | 3.8 GiB   |
| 2015-01-01 01:00:00+01 | profnte1 | 25491  | 13485230093  | 12.5 GiB  |
| 2016-01-01 01:00:00+01 | profnte1 | 26716  | 13118330360  | 12.2 GiB  |
| 2017-01-01 01:00:00+01 | profnte1 | 38688  | 20648478341  | 19.2 GiB  |
| 2018-01-01 01:00:00+01 | profnte1 | 61003  | 27954968123  | 26.0 GiB  |
| 2019-01-01 01:00:00+01 | profnte1 | 107844 | 45705457399  | 42.5 GiB  |
| 2020-01-01 01:00:00+01 | profnte1 | 121434 | 54269371820  | 50.5 GiB  |
| 2021-01-01 01:00:00+01 | profnte1 | 138644 | 52814334145  | 49.1 GiB  |
| 2022-01-01 01:00:00+01 | profnte1 | 137120 | 63173458885  | 58.8 GiB  |
| 2023-01-01 01:00:00+01 | profnte1 | 597214 | 115575300863 | 107.6 GiB |
| 2024-01-01 01:00:00+01 | profnte1 | 144179 | 64784670914  | 60.3 GiB  |
| 2025-01-01 01:00:00+01 | profnte1 | 799    | 148402535    | 141.5 MiB |
| 2026-01-01 01:00:00+01 | profnte1 | 8602   | 1564277472   | 1.4 GiB   |

```bash
start | is path[5] files_1731959368_by_group | last 1 year | span month --group path[1] | order date asc | human size | merge-cte | duckdb $c1s -markdown
```

|          date          | path[1]  | cnt  |   size    |   hsize   |
|------------------------|----------|-----:|----------:|-----------|
| 2025-12-01 01:00:00+01 | profnte1 | 799  | 148402535 | 141.5 MiB |
| 2026-01-01 01:00:00+01 | profnte1 | 1672 | 298680334 | 284.8 MiB |
| 2026-02-01 01:00:00+01 | profnte1 | 1905 | 349010768 | 332.8 MiB |
| 2026-03-01 01:00:00+01 | profnte1 | 2204 | 407289025 | 388.4 MiB |
| 2026-04-01 02:00:00+02 | profnte1 | 2327 | 425742977 | 406.0 MiB |
| 2026-05-01 02:00:00+02 | profnte1 | 494  | 83554368  | 79.6 MiB  |

# Use minimal plot

## `prot1strb1` by year

```bash
start | like server prot1strb1% | span year | cumul size | order date asc | merge-cte | ddb -json | plot-ddb ssize
```

```text
2010-01-01 01:00:00+01 ┤ 570
2014-01-01 01:00:00+01 ┤ 3583670226
2015-01-01 01:00:00+01 ┤█ 15427282343
2016-01-01 01:00:00+01 ┤█ 25816598267
2017-01-01 01:00:00+01 ┤██ 40566990869
2018-01-01 01:00:00+01 ┤██ 57091193182
2019-01-01 01:00:00+01 ┤████ 83807777729
2020-01-01 01:00:00+01 ┤█████ 114512935334
2021-01-01 01:00:00+01 ┤██████ 145933398143
2022-01-01 01:00:00+01 ┤████████ 190307995631
2023-01-01 01:00:00+01 ┤███████████████ 345132183662
2024-01-01 01:00:00+01 ┤███████████████████ 440732851768
2025-01-01 01:00:00+01 ┤███████████████████████ 523311158715
2026-01-01 01:00:00+01 ┤██████████████████████████████ 687118891995
```

## `prot1strc1` by year

```bash
start | like server prot1strc1% | span year | cumul size | order date asc | merge-cte | ddb -json | plot-ddb ssize
```

```text
2014-01-01 01:00:00+01 ┤ 4202655022
2015-01-01 01:00:00+01 ┤█ 18342086502
2016-01-01 01:00:00+01 ┤█ 32018633337
2017-01-01 01:00:00+01 ┤██ 53777645656
2018-01-01 01:00:00+01 ┤████ 83194090639
2019-01-01 01:00:00+01 ┤██████ 137224923613
2020-01-01 01:00:00+01 ┤████████ 196634123179
2021-01-01 01:00:00+01 ┤███████████ 253504721034
2022-01-01 01:00:00+01 ┤██████████████ 324412572271
2023-01-01 01:00:00+01 ┤███████████████████ 443684668881
2024-01-01 01:00:00+01 ┤████████████████████████ 568005988689
2025-01-01 01:00:00+01 ┤████████████████████████████ 656003384573
2026-01-01 01:00:00+01 ┤██████████████████████████████ 696102155041
```

# Growth pipes

```bash
unit () { local unit=${1:-2^30}; where size_start \> $unit and size_growth \> $unit and size_end \> $unit; }
```

## `prot1strb1`, pivot 2025, unit 1M

> [!NOTE]
>
> We could use a CTE to remove numbered dir

```bash
start | like server prot1strb1% | growth 2025-01-01 | unit 2^20 | order size_end desc | pct size_rate | items 30 | merge-cte | ddb -json | fmt-auto
```

|                            path                             | size_start | size_growth | size_end | size_rate |
|-------------------------------------------------------------|------------|-------------|----------|-----------|
| [profntr1, applisdata, ssp, upload, files_1731959368]       | 148G       | 19G         | 167G     | 13.28%    |
| [profntr1, applisdata, ssp_ndf, upload, files_1731959368]   | 28G        | 105G        | 134G     | 370.92%   |
| [profntr1, applisdata, ssp_ndf, apicrypt, 446, attachments] | 3G         | 2G          | 6G       | 72.42%    |
| [profntr1, applisdata, ssp_ndf, apicrypt, 485, attachments] | 4G         | 1G          | 5G       | 29.11%    |
| [profntr1, applisdata, ssp, apicrypt, 310, attachments]     | 4G         | 1G          | 5G       | 22.59%    |
| [profntr1, applisdata, ssp_ndf, apicrypt, 230, attachments] | 1G         | 1G          | 2G       | 81.38%    |
| [profntr1, applisdata, ssp_ndf, apicrypt, 772, attachments] | 1G         | 740M        | 2G       | 47.15%    |
| [profntr1, applisdata, ssp_ndf, apicrypt, 446, Clefs]       | 520M       | 336M        | 856M     | 64.62%    |
| [profntr1, applisdata, ssp_ndf, apicrypt, 230, Clefs]       | 520M       | 251M        | 771M     | 48.27%    |
| [profntr1, applisdata, ssp_ndf, HPV]                        | 180M       | 394M        | 574M     | 218.33%   |
| [profntr1, applisdata, ssp_ndf, apicrypt, 772, Clefs]       | 237M       | 204M        | 441M     | 86.08%    |
| [profntr1, applisdata, ssp, apicrypt, 310, archives]        | 101M       | 30M         | 131M     | 29.80%    |

## `prot1strc1`, pivot 2025, unit 1G

> [!NOTE]
>
> - Choose unit to avoid noisy `size_rate` (.e.g. from ~1M to ~15M give ~800%)

```bash
start | like server prot1strc1% | growth 2025-01-01 | unit | order size_end desc | pct size_rate | items 30 | merge-cte | ddb -json | fmt-auto
```

|                            path                             | size_start | size_growth | size_end | size_rate |
|-------------------------------------------------------------|------------|-------------|----------|-----------|
| [profnte1, applisdata, ssp, upload, files_1731959368]       | 51G        | 94G         | 145G     | 182.95%   |
| [profnte1, applisdata, ssp, apicrypt, 201, attachments]     | 15G        | 1G          | 16G      | 8.37%     |
| [profnte1, applisdata, ssp, apicrypt, 338, attachments]     | 7G         | 2G          | 9G       | 29.03%    |
| [profnte1, applisdata, ssp, apicrypt, 338-SLM, attachments] | 2G         | 1G          | 4G       | 38.51%    |


## `prot1strb1`, since 2025 pivot 2026, unit 1M

```bash
start | like server prot1strb1% | since 2025-01-01 | growth 2026-01-01 | unit 2^20 | order size_end desc | pct size_rate | items 30 | merge-cte | ddb -json | fmt-auto
```

|                            path                             | size_start | size_growth | size_end | size_rate |
|-------------------------------------------------------------|------------|-------------|----------|-----------|
| [profntr1, applisdata, ssp_ndf, upload, files_1731959368]   | 50G        | 55G         | 105G     | 110.62%   |
| [profntr1, applisdata, ssp, upload, files_1731959368]       | 14G        | 5G          | 19G      | 38.37%    |
| [profntr1, applisdata, ssp, apicrypt, 759, attachments]     | 3G         | 1G          | 5G       | 43.16%    |
| [profntr1, applisdata, ssp_ndf, apicrypt, 446, attachments] | 1G         | 659M        | 2G       | 34.25%    |
| [profntr1, applisdata, ssp_ndf, apicrypt, 485, attachments] | 1G         | 333M        | 1G       | 32.25%    |
| [profntr1, applisdata, ssp, apicrypt, 310, attachments]     | 787M       | 304M        | 1G       | 38.69%    |
| [profntr1, applisdata, ssp_ndf, apicrypt, 230, attachments] | 795M       | 264M        | 1G       | 33.25%    |
| [profntr1, applisdata, ssp_ndf, apicrypt, 994, attachments] | 453M       | 455M        | 909M     | 100.42%   |
| [profntr1, applisdata, ssp_ndf, apicrypt, 772, attachments] | 547M       | 193M        | 740M     | 35.36%    |
| [profntr1, applisdata, ssp_ndf, HPV]                        | 346M       | 47M         | 394M     | 13.85%    |
| [profntr1, applisdata, ssp_ndf, apicrypt, 726, attachments] | 60M        | 300M        | 360M     | 499.78%   |
| [profntr1, applisdata, ssp, apicrypt, 759, archives]        | 69M        | 30M         | 99M      | 43.09%    |
| [profntr1, applisdata, ssp_ndf, apicrypt, 376, attachments] | 18M        | 57M         | 75M      | 315.59%   |
| [profntr1, applisdata, ssp, apicrypt, 310, archives]        | 21M        | 8M          | 30M      | 38.73%    |
| [profntr1, applisdata, ssp_ndf, apicrypt, 994, inbox]       | 8M         | 16M         | 24M      | 212.20%   |
| [profntr1, applisdata, ssp, apicrypt, 759, inbox]           | 9M         | 2M          | 12M      | 25.60%    |

## `prot1strc1`, since 2025 pivot 2026, unit 1M

```bash
start | like server prot1strc1% | since 2025-01-01 | growth 2026-01-01 | unit 2^20 | order size_end desc | pct size_rate | items 30 | merge-cte | ddb -json | fmt-auto
```

|                                   path                                   | size_start | size_growth | size_end | size_rate |
|--------------------------------------------------------------------------|------------|-------------|----------|-----------|
| [profnte1, applisdata, ssp, upload, files_1731959368]                    | 67G        | 27G         | 94G      | 40.21%    |
| [profnte1, applisdata, ssp, apicrypt, 664, attachments]                  | 647M       | 3G          | 3G       | 496.74%   |
| [profnte1, applisdata, ssp, apicrypt, 923, attachments]                  | 1G         | 742M        | 2G       | 41.17%    |
| [profnte1, applisdata, ssp, apicrypt, 338, attachments]                  | 1G         | 464M        | 2G       | 25.88%    |
| [profnte1, applisdata, ssp, ORU]                                         | 144M       | 1G          | 1G       | 1093.06%  |
| [profnte1, applisdata, ssp, upload, files_1731959368_by_group, 891, ORU] | 141M       | 1G          | 1G       | 1054.08%  |
| [profnte1, applisdata, ssp, apicrypt, 201, attachments]                  | 976M       | 315M        | 1G       | 32.35%    |
| [profnte1, applisdata, ssp, apicrypt, 338-SLM, attachments]              | 878M       | 278M        | 1G       | 31.66%    |
| [profnte1, applisdata, ssp, apicrypt, 891, attachments]                  | 53M        | 670M        | 724M     | 1245.55%  |
| [profnte1, applisdata, ssp, HPV]                                         | 407M       | 6M          | 413M     | 1.50%     |
| [profnte1, applisdata, ssp, apicrypt, 338-kourou, attachments]           | 279M       | 119M        | 399M     | 42.87%    |
| [profnte1, applisdata, ssp, apicrypt, 917, attachments]                  | 20M        | 191M        | 212M     | 938.91%   |


## Any server with apicrypt as level 4 dir, pivot 2026, unit 1M

```bash
start | is path[4] apicrypt | growth 2026-01-01 -g server,path[1:4] | unit 2^20 | order size_end desc | pct size_rate | items 30 | merge-cte | ddb -json | fmt-auto
```

|            server             |                    path[1:4]                    | size_start | size_growth | size_end | size_rate |
|-------------------------------|-------------------------------------------------|------------|-------------|----------|-----------|
| prot1strc1_data_nfsdata_small | [profnte1, applisdata, ssp, apicrypt]           | 34G        | 6G          | 41G      | 18.95%    |
| prot1strb1_data_nfsdata_small | [profntr1, applisdata, ssp_ndf, apicrypt]       | 17G        | 2G          | 20G      | 15.21%    |
| prot1strb1_data_nfsdata_small | [profntr1, applisdata, ssp, apicrypt]           | 9G         | 1G          | 11G      | 20.90%    |
| prostra1_data_nfsdata_small   | [profnts1, applisdata, ssp-migration, apicrypt] | 7G         | 358M        | 8G       | 4.39%     |
