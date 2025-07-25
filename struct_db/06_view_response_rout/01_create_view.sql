create or replace view view_response_rout as
 select lts.*,r.rout as rout_name, m.name as metric_name,um.unit as metric_unit,
       mv.min as min,mv.max as max,mv.p90 as p90,mv.p95 as p95,mv.p99 as p99
    from view_lt_steps lts
        inner join response_routs rr on rr.id_step = lts.step_id
        inner join routs r on rr.id_rout = r.id
        inner join metrics m on m.id = rr.id_metric
        inner join units_measurement um on um.id=rr.id_metric_unit
        inner join metrics_value mv on mv.id = rr.id_metrics_value;