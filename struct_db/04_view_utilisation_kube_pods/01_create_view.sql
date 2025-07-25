create or replace view view_utilisation_kube as
    select lts.*,ns.space_name as name_sapace, m.name as metric_name,um.unit as metric_unit,p.pod_name,
       mv.min as min,mv.max as max,mv.p90 as p90,mv.p95 as p95,mv.p99 as p99
    from view_lt_steps lts
        inner join utilisation_kube ukp on ukp.id_step=lts.step_id
        inner join name_spaces ns on ukp.id_name_space = ns.id
        inner join metrics m on m.id = ukp.id_metric
        inner join units_measurement um on um.id=ukp.id_metric_unit
        inner join metrics_value mv on mv.id = ukp.id_metrics_value
        inner join pods p on p.id = ukp.id_pod;
