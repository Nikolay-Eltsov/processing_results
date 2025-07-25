insert into view_response_group(step_id, group_name, metric_name, metric_unit, min, max, p90, p95, p99)
    values (1,'login','response','ms',0,100,60,80,90);

select * from view_response_group;