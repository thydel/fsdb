# Some SQL CTE pipeline

```bash
load tdep-sql.yml
```

## sum-size

```bash
sum-size | run -markdown > md/sum-size.md
```
- [out/sum-size.md][]

```bash
sum-size | limit-cumul --col=size --cpt=.99 | human | run -markdown
```

|     appli     |   size    |
|---------------|-----------|
|  TOTAL        | 2.7 TiB   |
| mailmerge     | 493.9 GiB |
| esisdocs-naq  | 464.4 GiB |
| esisdocs-idf  | 432.5 GiB |
| esisdocs-occ  | 262.7 GiB |
| esisdoccr-idf | 261.5 GiB |
| esisdoccu     | 232.7 GiB |
| esisdoccr-naq | 177.4 GiB |

```bash
sum-size node | order --col=size | human node | run -markdown
```

|   node   |   size    |
|----------|-----------|
|  TOTAL   | 2.7 TiB   |
| prostrq1 | 1.0 TiB   |
| prostrk1 | 493.9 GiB |
| prostro1 | 464.4 GiB |
| prostrm1 | 327.1 GiB |
| prostrj1 | 232.7 GiB |
| prostrl1 | 177.4 GiB |
| prostrc1 | 26.3 GiB  |

## Reports

```yaml
- id: report
  sh: |
    local -A opts; local args cont; args "$@"
    start | used | span ${opts[span]:-%Y} | since ${opts[since]:-2020-01-01} | group-sum |
    add-total | pivot appli total | limit-cumul --pct=${opts[pct]:-.95} | order | add-sum-row | human
```

```bash
report > out/report.js
report | merge-cte > out/report.sql
report | run --markdown
```
- [out/report.js][]
- [out/report.sql][]

|     appli     |   total   |   2020   |   2021   |   2022   |   2023    |   2024    |   2025    |
|---------------|-----------|----------|----------|----------|-----------|-----------|-----------|
| mailmerge     | 482.3 GiB | 1.6 GiB  | 10.8 GiB | 13.2 GiB | 136.7 GiB | 319.7 GiB | 74.2 MiB  |
| esisdocs-naq  | 464.4 GiB | NULL     | NULL     | 3.2 GiB  | 96.4 GiB  | 170.7 GiB | 194.0 GiB |
| esisdocs-idf  | 432.5 GiB | NULL     | NULL     | NULL     | NULL      | 118.4 GiB | 314.0 GiB |
| esisdocs-occ  | 262.7 GiB | NULL     | NULL     | NULL     | 245.9 MiB | 154.4 GiB | 108.1 GiB |
| esisdoccr-idf | 261.5 GiB | NULL     | NULL     | NULL     | NULL      | 93.8 GiB  | 167.6 GiB |
| esisdoccu     | 228.5 GiB | 19.5 GiB | 49.0 GiB | 49.7 GiB | 54.5 GiB  | 28.3 GiB  | 27.3 GiB  |
| esisdoccr-naq | 177.4 GiB | NULL     | NULL     | 4.0 GiB  | 30.6 GiB  | 99.8 GiB  | 42.7 GiB  |
| esisdoccr-occ | 105.7 GiB | NULL     | NULL     | NULL     | 249.3 MiB | 68.5 GiB  | 36.9 GiB  |
| esisdocs-ara  | 97.5 GiB  | NULL     | NULL     | NULL     | 47.9 GiB  | 49.5 GiB  | 38.5 MiB  |
| esisdoccr-ara | 57.9 GiB  | NULL     | NULL     | NULL     | 17.4 GiB  | 39.8 GiB  | 712.1 MiB |
| esisdocs-guy  | 53.7 GiB  | NULL     | NULL     | NULL     | 7.9 GiB   | 38.6 GiB  | 7.0 GiB   |
| esisfiles     | 30.9 GiB  | NULL     | NULL     | NULL     | 53.9 MiB  | 140.8 MiB | 30.7 GiB  |
| esisdocs-ges  | 27.4 GiB  | NULL     | NULL     | NULL     | NULL      | NULL      | 27.4 GiB  |
|  TOTAL        | 2.6 TiB   | 21.1 GiB | 59.9 GiB | 70.4 GiB | 392.3 GiB | 1.1 TiB   | 957.1 GiB |

```bash
report --since=2024-01-01 | run --markdown
```

|     appli     |   total   |   2024    |   2025    |
|---------------|-----------|-----------|-----------|
| esisdocs-idf  | 432.5 GiB | 118.4 GiB | 314.0 GiB |
| esisdocs-naq  | 364.7 GiB | 170.7 GiB | 194.0 GiB |
| mailmerge     | 319.8 GiB | 319.7 GiB | 74.2 MiB  |
| esisdocs-occ  | 262.5 GiB | 154.4 GiB | 108.1 GiB |
| esisdoccr-idf | 261.5 GiB | 93.8 GiB  | 167.6 GiB |
| esisdoccr-naq | 142.6 GiB | 99.8 GiB  | 42.7 GiB  |
| esisdoccr-occ | 105.5 GiB | 68.5 GiB  | 36.9 GiB  |
| esisdoccu     | 55.6 GiB  | 28.3 GiB  | 27.3 GiB  |
| esisdocs-ara  | 49.5 GiB  | 49.5 GiB  | 38.5 MiB  |
| esisdocs-guy  | 45.7 GiB  | 38.6 GiB  | 7.0 GiB   |
| esisdoccr-ara | 40.5 GiB  | 39.8 GiB  | 712.1 MiB |
| esisfiles     | 30.9 GiB  | 140.8 MiB | 30.7 GiB  |
|  TOTAL        | 2.0 TiB   | 1.1 TiB   | 929.6 GiB |

```bash
report --since=2025-01-01 --span=%Y-%m | run --csv > out/report-2025-monthly.csv
report --since=2025-01-01 --span=%Y-%m | run --box
```

- [out/report-2025-monthly.csv][]

```
┌───────────────┬───────────┬──────────┬───────────┬──────────┬───────────┬──────────┬──────────┬──────────┬──────────┬──────────┬──────────┬──────────┐
│     appli     │   total   │ 2025-01  │  2025-02  │ 2025-03  │  2025-04  │ 2025-05  │ 2025-06  │ 2025-07  │ 2025-08  │ 2025-09  │ 2025-10  │ 2025-11  │
├───────────────┼───────────┼──────────┼───────────┼──────────┼───────────┼──────────┼──────────┼──────────┼──────────┼──────────┼──────────┼──────────┤
│ esisdocs-idf  │ 314.0 GiB │ 14.4 GiB │ 174.2 GiB │ 13.1 GiB │ 13.0 GiB  │ 15.3 GiB │ 15.0 GiB │ 18.6 GiB │ 14.4 GiB │ 13.2 GiB │ 15.1 GiB │ 7.2 GiB  │
│ esisdocs-naq  │ 194.0 GiB │ 12.6 GiB │ 12.3 GiB  │ 13.3 GiB │ 66.8 GiB  │ 10.4 GiB │ 14.3 GiB │ 16.2 GiB │ 10.9 GiB │ 16.6 GiB │ 15.7 GiB │ 4.3 GiB  │
│ esisdoccr-idf │ 167.6 GiB │ 4.9 GiB  │ 76.0 GiB  │ 5.1 GiB  │ 24.2 GiB  │ 7.0 GiB  │ 26.1 GiB │ 4.6 GiB  │ 4.6 GiB  │ 5.6 GiB  │ 6.8 GiB  │ 2.2 GiB  │
│ esisdocs-occ  │ 108.1 GiB │ 8.0 GiB  │ 9.1 GiB   │ 9.7 GiB  │ 6.7 GiB   │ 12.3 GiB │ 11.7 GiB │ 9.6 GiB  │ 6.4 GiB  │ 13.3 GiB │ 16.6 GiB │ 4.1 GiB  │
│ esisdoccr-naq │ 42.7 GiB  │ 3.4 GiB  │ 3.1 GiB   │ 5.2 GiB  │ 11.9 GiB  │ 4.4 GiB  │ 2.8 GiB  │ 2.2 GiB  │ 1.9 GiB  │ 2.5 GiB  │ 3.5 GiB  │ 1.3 GiB  │
│ esisdoccr-occ │ 36.9 GiB  │ 3.2 GiB  │ 2.8 GiB   │ 3.6 GiB  │ 5.2 GiB   │ 4.5 GiB  │ 4.0 GiB  │ 2.9 GiB  │ 2.4 GiB  │ 2.9 GiB  │ 3.7 GiB  │ 1.3 GiB  │
│ esisfiles     │ 30.7 GiB  │ NULL     │ NULL      │ NULL     │ 418.4 KiB │ 5.1 MiB  │ NULL     │ 2.2 KiB  │ 4.9 KiB  │ 7.7 GiB  │ 12.3 GiB │ 10.6 GiB │
│ esisdocs-ges  │ 27.4 GiB  │ 4.1 MiB  │ 1.3 GiB   │ 2.0 GiB  │ 2.2 GiB   │ 2.4 GiB  │ 3.8 GiB  │ 3.8 GiB  │ 2.2 GiB  │ 3.3 GiB  │ 4.4 GiB  │ 1.7 GiB  │
│ esisdoccu     │ 27.3 GiB  │ 1.2 GiB  │ 1.0 GiB   │ 3.1 GiB  │ 1.9 GiB   │ 3.1 GiB  │ 2.4 GiB  │ 3.0 GiB  │ 2.8 GiB  │ 2.5 GiB  │ 4.7 GiB  │ 1.1 GiB  │
│  TOTAL        │ 949.1 GiB │ 48.0 GiB │ 280.2 GiB │ 55.3 GiB │ 132.2 GiB │ 59.6 GiB │ 80.6 GiB │ 61.4 GiB │ 46.0 GiB │ 68.0 GiB │ 83.1 GiB │ 34.2 GiB │
└───────────────┴───────────┴──────────┴───────────┴──────────┴───────────┴──────────┴──────────┴──────────┴──────────┴──────────┴──────────┴──────────┘
```

```bash
report --since=2025-09-01 --span=%W | run --box
```

```
┌───────────────┬───────────┬───────────┬───────────┬───────────┬───────────┬───────────┬───────────┬────────────┬───────────┬───────────┬───────────┬───────────┐
│     appli     │   total   │    35     │    36     │    37     │    38     │    39     │    40     │     41     │    42     │    43     │    44     │    45     │
├───────────────┼───────────┼───────────┼───────────┼───────────┼───────────┼───────────┼───────────┼────────────┼───────────┼───────────┼───────────┼───────────┤
│ esisdocs-naq  │ 36.7 GiB  │ 3.4 GiB   │ 3.8 GiB   │ 3.5 GiB   │ 4.2 GiB   │ 3.9 GiB   │ 3.8 GiB   │ 4.2 GiB    │ 3.0 GiB   │ 2.2 GiB   │ 3.1 GiB   │ 1.2 GiB   │
│ esisdocs-idf  │ 35.6 GiB  │ 2.2 GiB   │ 2.2 GiB   │ 2.8 GiB   │ 3.0 GiB   │ 4.6 GiB   │ 3.3 GiB   │ 2.8 GiB    │ 3.5 GiB   │ 3.9 GiB   │ 4.9 GiB   │ 2.1 GiB   │
│ esisdocs-occ  │ 34.1 GiB  │ 2.2 GiB   │ 3.1 GiB   │ 4.3 GiB   │ 2.5 GiB   │ 4.0 GiB   │ 5.5 GiB   │ 2.8 GiB    │ 2.7 GiB   │ 2.5 GiB   │ 2.7 GiB   │ 1.2 GiB   │
│ esisfiles     │ 30.7 GiB  │ NULL      │ 14.1 MiB  │ 1.9 GiB   │ 3.3 GiB   │ 4.7 GiB   │ 1.6 GiB   │ 2.7 GiB    │ 2.7 GiB   │ 2.9 GiB   │ 3.5 GiB   │ 7.0 GiB   │
│ esisdoccr-idf │ 14.8 GiB  │ 1.9 GiB   │ 1.5 GiB   │ 1.0 GiB   │ 987.1 MiB │ 1.1 GiB   │ 1.7 GiB   │ 1.3 GiB    │ 1.4 GiB   │ 1.5 GiB   │ 1.5 GiB   │ 603.2 MiB │
│ esisdocs-ges  │ 9.5 GiB   │ 764.5 MiB │ 418.2 MiB │ 697.3 MiB │ 1.1 GiB   │ 1.0 GiB   │ 899.7 MiB │ 655.6 MiB  │ 912.9 MiB │ 1.3 GiB   │ 1.4 GiB   │ 299.4 MiB │
│ esisdoccu     │ 8.4 GiB   │ 456.7 MiB │ 382.2 MiB │ 432.3 MiB │ 671.6 MiB │ 1.0 GiB   │ 1.5 GiB   │ 573.1 MiB  │ 1.3 GiB   │ 818.5 MiB │ 843.1 MiB │ 332.8 MiB │
│ esisdoccr-occ │ 8.0 GiB   │ 510.7 MiB │ 557.4 MiB │ 860.7 MiB │ 623.9 MiB │ 927.5 MiB │ 692.2 MiB │ 1021.9 MiB │ 902.9 MiB │ 840.9 MiB │ 1.0 GiB   │ 261.8 MiB │
│ esisdoccr-naq │ 7.3 GiB   │ 783.5 MiB │ 391.5 MiB │ 429.0 MiB │ 841.8 MiB │ 469.1 MiB │ 1.0 GiB   │ 673.3 MiB  │ 695.5 MiB │ 946.7 MiB │ 829.0 MiB │ 401.0 MiB │
│ esisdocs-nor  │ 5.1 GiB   │ 95.0 MiB  │ 642.3 MiB │ 198.9 MiB │ 426.8 MiB │ 317.0 MiB │ 583.9 MiB │ 430.5 MiB  │ 823.1 MiB │ 1.0 GiB   │ 598.3 MiB │ 110.8 MiB │
│ esisdoccr-ges │ 3.3 GiB   │ 19.6 MiB  │ 353.4 MiB │ 301.6 MiB │ 265.6 MiB │ 248.4 MiB │ 362.5 MiB │ 486.9 MiB  │ 311.9 MiB │ 266.6 MiB │ 660.1 MiB │ 161.4 MiB │
│  TOTAL        │ 194.0 GiB │ 12.4 GiB  │ 13.4 GiB  │ 16.5 GiB  │ 18.2 GiB  │ 22.4 GiB  │ 21.2 GiB  │ 17.8 GiB   │ 18.4 GiB  │ 18.3 GiB  │ 21.3 GiB  │ 13.8 GiB  │
└───────────────┴───────────┴───────────┴───────────┴───────────┴───────────┴───────────┴───────────┴────────────┴───────────┴───────────┴───────────┴───────────┘
```

```bash
report --since=2025-10-01 --span=%W --pct=1 | run --box
```

```
┌───────────────┬────────────┬───────────┬───────────┬────────────┬───────────┬───────────┬───────────┬───────────┐
│     appli     │   total    │    39     │    40     │     41     │    42     │    43     │    44     │    45     │
├───────────────┼────────────┼───────────┼───────────┼────────────┼───────────┼───────────┼───────────┼───────────┤
│ esisfiles     │ 23.0 GiB   │ 2.2 GiB   │ 1.6 GiB   │ 2.7 GiB    │ 2.7 GiB   │ 2.9 GiB   │ 3.5 GiB   │ 7.0 GiB   │
│ esisdocs-idf  │ 22.3 GiB   │ 1.6 GiB   │ 3.3 GiB   │ 2.8 GiB    │ 3.5 GiB   │ 3.9 GiB   │ 4.9 GiB   │ 2.1 GiB   │
│ esisdocs-occ  │ 20.7 GiB   │ 3.0 GiB   │ 5.5 GiB   │ 2.8 GiB    │ 2.7 GiB   │ 2.5 GiB   │ 2.7 GiB   │ 1.2 GiB   │
│ esisdocs-naq  │ 20.1 GiB   │ 2.3 GiB   │ 3.8 GiB   │ 4.2 GiB    │ 3.0 GiB   │ 2.2 GiB   │ 3.1 GiB   │ 1.2 GiB   │
│ esisdoccr-idf │ 9.1 GiB    │ 936.6 MiB │ 1.7 GiB   │ 1.3 GiB    │ 1.4 GiB   │ 1.5 GiB   │ 1.5 GiB   │ 603.2 MiB │
│ esisdocs-ges  │ 6.1 GiB    │ 718.5 MiB │ 899.7 MiB │ 655.6 MiB  │ 912.9 MiB │ 1.3 GiB   │ 1.4 GiB   │ 299.4 MiB │
│ esisdoccu     │ 5.9 GiB    │ 459.1 MiB │ 1.5 GiB   │ 573.1 MiB  │ 1.3 GiB   │ 818.5 MiB │ 843.1 MiB │ 332.8 MiB │
│ esisdoccr-occ │ 5.0 GiB    │ 392.3 MiB │ 692.2 MiB │ 1021.9 MiB │ 902.9 MiB │ 840.9 MiB │ 1.0 GiB   │ 261.8 MiB │
│ esisdoccr-naq │ 4.7 GiB    │ 243.2 MiB │ 1.0 GiB   │ 673.3 MiB  │ 695.5 MiB │ 946.7 MiB │ 829.0 MiB │ 401.0 MiB │
│ esisdocs-nor  │ 3.7 GiB    │ 230.6 MiB │ 583.9 MiB │ 430.5 MiB  │ 823.1 MiB │ 1.0 GiB   │ 598.3 MiB │ 110.8 MiB │
│ esisdoccr-ges │ 2.3 GiB    │ 112.4 MiB │ 362.5 MiB │ 486.9 MiB  │ 311.9 MiB │ 266.6 MiB │ 660.1 MiB │ 161.4 MiB │
│ esisdoccr-nor │ 2.0 GiB    │ 172.5 MiB │ 361.9 MiB │ 267.9 MiB  │ 383.1 MiB │ 347.5 MiB │ 556.5 MiB │ 45.0 MiB  │
│ esisdoccr-gua │ 1.5 GiB    │ NULL      │ NULL      │ NULL       │ NULL      │ 4.1 KiB   │ NULL      │ 1.5 GiB   │
│ esis3d-idf    │ 1021.7 MiB │ 162.6 MiB │ 161.6 MiB │ 203.1 MiB  │ 167.3 MiB │ 116.5 MiB │ 155.9 MiB │ 54.5 MiB  │
│ esisdocs-guy  │ 689.7 MiB  │ 205.5 MiB │ 141.2 MiB │ 49.9 MiB   │ 51.5 MiB  │ 103.7 MiB │ 99.9 MiB  │ 37.8 MiB  │
│ esisdoccu-bfc │ 488.4 MiB  │ NULL      │ 19.6 MiB  │ NULL       │ 366.5 MiB │ 38.5 MiB  │ NULL      │ 63.7 MiB  │
│ esis3d-ges    │ 320.9 MiB  │ 89.1 MiB  │ 10.6 MiB  │ 16.1 MiB   │ 8.1 MiB   │ NULL      │ 96.2 MiB  │ 100.6 MiB │
│ esisdoccr-mtq │ 268.1 MiB  │ 21.8 MiB  │ 66.7 MiB  │ 42.5 MiB   │ 23.7 MiB  │ 56.1 MiB  │ 51.7 MiB  │ 5.5 MiB   │
│ esisbci       │ 205.8 MiB  │ 18.2 KiB  │ NULL      │ 4.4 KiB    │ 3.6 KiB   │ NULL      │ 19.8 KiB  │ 205.8 MiB │
│ esisdocs      │ 141.1 MiB  │ 1.4 KiB   │ 278.9 KiB │ 206.3 KiB  │ 1.5 KiB   │ 8.0 KiB   │ 140.6 MiB │ 6.3 KiB   │
│ esis3d-naq    │ 61.8 MiB   │ NULL      │ NULL      │ NULL       │ 45.0 KiB  │ 3.5 MiB   │ 44.5 MiB  │ 13.6 MiB  │
│ mailmerge     │ 36.8 MiB   │ 1.1 MiB   │ 235.3 KiB │ 687.7 KiB  │ 134.7 KiB │ 202.4 KiB │ 1.1 MiB   │ 33.2 MiB  │
│ esisdoccr-guy │ 8.6 MiB    │ 260.2 KiB │ 836.2 KiB │ 389.9 KiB  │ NULL      │ NULL      │ 1.1 MiB   │ 5.9 MiB   │
│ esisdoccr-ara │ 4.0 MiB    │ NULL      │ NULL      │ NULL       │ NULL      │ NULL      │ NULL      │ 4.0 MiB   │
│ esisdocs-ara  │ 2.5 MiB    │ NULL      │ NULL      │ NULL       │ NULL      │ NULL      │ NULL      │ 2.5 MiB   │
│ esis3d-occ    │ 317.9 KiB  │ NULL      │ NULL      │ NULL       │ 260.9 KiB │ 57.0 KiB  │ NULL      │ NULL      │
│ e-depistage   │ 257.6 KiB  │ NULL      │ NULL      │ 699 bytes  │ NULL      │ 5.9 KiB   │ 211.1 KiB │ 39.9 KiB  │
│ neoesis       │ 164.1 KiB  │ 58.3 KiB  │ NULL      │ 284 bytes  │ NULL      │ NULL      │ 397 bytes │ 105.2 KiB │
│ voo4bcm       │ 120.5 KiB  │ NULL      │ 120.5 KiB │ NULL       │ NULL      │ NULL      │ NULL      │ NULL      │
│ esisdocs-can  │ 87.0 KiB   │ 87.0 KiB  │ NULL      │ NULL       │ NULL      │ NULL      │ NULL      │ NULL      │
│ esisdoccr     │ 60.2 KiB   │ 20.8 KiB  │ 18.5 KiB  │ 508 bytes  │ 1.2 KiB   │ 802 bytes │ 5.8 KiB   │ 12.6 KiB  │
│ esisdoccu3d   │ 49.7 KiB   │ 46.2 KiB  │ 760 bytes │ 287 bytes  │ 758 bytes │ 292 bytes │ 845 bytes │ 632 bytes │
│ neobci        │ 1.0 KiB    │ NULL      │ NULL      │ NULL       │ NULL      │ NULL      │ NULL      │ 1.0 KiB   │
│  TOTAL        │ 130.1 GiB  │ 13.0 GiB  │ 21.9 GiB  │ 18.4 GiB   │ 19.3 GiB  │ 19.0 GiB  │ 22.4 GiB  │ 15.8 GiB  │
└───────────────┴────────────┴───────────┴───────────┴────────────┴───────────┴───────────┴───────────┴───────────┘
```

<!--
find out -type f | grep -v \~ | jq -Rr '"[\(.)]: \(.) \u0027sibling file\u0027", "- [\(.)][]"' | env LANG=C sort
-->

[Local Variables:]::
[indent-tabs-mode: nil]::
[End:]::

[out/report-2025-monthly.csv]: out/report-2025-monthly.csv 'sibling file'
[out/report.js]: out/report.js 'sibling file'
[out/report.sql]: out/report.sql 'sibling file'
[out/sum-size.md]: out/sum-size.md 'sibling file'

