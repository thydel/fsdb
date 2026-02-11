# merge and use list

- I have these two files as a model of the first pass for the construction of filesysyem data base (FSDB)
- The first is `[ inode, mode, path ]` json
- The second is `[ UTS, size, inode ]` json

- Ignore the mode for now
- I want a duckdb (DDB) file with an inner join on inode and path as list col

- I guess I must first split the path using `jq`
- I can also join using `jq` but probably using DDB is faster and more memory efficient
- I can't probably use a CSV fmt to get scalar and array cols
  together, but can I give a `[ inode, UTS, size, [ path_part, ... ]]` instead of a object

What do you recommand to get that done ?

```console
thy@tdews1-256g:tmp$ < profnte1-imn-stat.js.gz zcat | head
[8659381,33188,"./ssp_stats/logs/prdvl/20250805_prdvl_events.log"]
[8659675,33188,"./ssp_stats/logs/prdvl/20250820_prdvl_events.log"]
[8659269,33188,"./ssp_stats/logs/prdvl/20250804_prdvl_events.log"]
[7212333,33188,"./201911xx_ssp_version_validation/upload/files_1731959368/54393982ebe560bc48201ada03cc2ba1"]
[7079716,33188,"./201911xx_ssp_version_validation/apicrypt/427/attachments/resu0318_19719.pdf"]
[7079702,33188,"./201911xx_ssp_version_validation/apicrypt/427/attachments/resu0303_19524.pdf"]
[7079638,33188,"./201911xx_ssp_version_validation/apicrypt/427/attachments/resu0236_19027.pdf"]
[7079632,33188,"./201911xx_ssp_version_validation/apicrypt/427/attachments/resu0230_18976.pdf"]
[7079617,33188,"./201911xx_ssp_version_validation/apicrypt/427/attachments/resu0215_18759.pdf"]
[7079667,33188,"./201911xx_ssp_version_validation/apicrypt/427/attachments/resu0265_19270.pdf"]
thy@tdews1-256g:tmp$ < profnte1-Ysi-stat.js.gz zcat | head
[1754389942,68,8659381]
[1755698378,612,8659675]
[1754323893,952,8659269]
[1558022414,81470,7212333]
[1574269274,121549,7079716]
[1574096441,125706,7079702]
[1573599639,144036,7079638]
[1573556445,143561,7079632]
[1573167699,143727,7079617]
[1573772484,125189,7079667]
```

# reduce size and use TS

## first try

- Fine
- Now as uts stand for unix time stamp, so we'll be able reduce the DB
  by hour later
- Also we won't need the inode after merge and we can also drop the
  file part of the path because we'll first want to make grouping and
  stats on size, cnt and path start by time

- First change the request to use a time stamp type for uts (we'll use
  that DB later to join in with `file(1)` type later)
- Then make a request to create a smaller DB without inode and
  filename from the first one

## correct

I mean still generate the full DB (just correcting for timestamp) then
give the request to derive the smaller one from the full one

# reduce more

- Now I want to make various selection and aggregation
- First, how do I group by parts of path (1, 2, 3, ... first parts)
- Then coarser time bucket and non consecutive time group (hour of day, day of week, ...)
- All as a parametric sql query in my framework
- Try to keep a minimal number of query for now
- Later we will embark on recyclyng a CTE pipeline approach previouly used
