[
  "FROM stat",
  "select * from {prev} where uts != 0",
  "select strftime(to_timestamp(uts), '%Y') as span, * from {prev}",
  "select * from {prev} where uts >= epoch('2020-01-01'::TIMESTAMP)",
  "select appli, span, sum(size) as size from {prev} group by appli, span",
  "select *, sum(size) over (partition by appli) as total from {prev}",
  "pivot {prev} on span using sum(size) group by appli, total",
  "select * from {prev} \nqualify (sum(total) over (order by total desc) - total) / sum(total) over () < .95",
  "select * from {prev} order by total desc",
  "select * from {prev} union all\nselect ' TOTAL' as appli, sum(columns(* exclude(appli))) from {prev}",
  "select appli, format_bytes(columns(* EXCLUDE (appli))::bigint) from {prev}"
]
