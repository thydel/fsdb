WITH step0 AS (FROM stat),
step1 AS (select * from step0 where uts != 0),
step2 AS (select strftime(to_timestamp(uts), '%Y') as span, * from step1),
step3 AS (select * from step2 where uts >= epoch('2020-01-01'::TIMESTAMP)),
step4 AS (select appli, span, sum(size) as size from step3 group by appli, span),
step5 AS (select *, sum(size) over (partition by appli) as total from step4),
step6 AS (pivot step5 on span using sum(size) group by appli, total),
step7 AS (select * from step6 
qualify (sum(total) over (order by total desc) - total) / sum(total) over () < .95),
step8 AS (select * from step7 order by total desc),
step9 AS (select * from step8 union all
select ' TOTAL' as appli, sum(columns(* exclude(appli))) from step8),
step10 AS (select appli, format_bytes(columns(* EXCLUDE (appli))::bigint) from step9)
SELECT * FROM step10
