insert into view_response_rout(step_id, rout_name, metric_name, metric_unit, min, max, p90, p95, p99)
    values (1,'/api/test','response','ms',0,100,60,80,90);

select * from view_response_rout;