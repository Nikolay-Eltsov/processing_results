create or replace view view_response_group as
  select lts.*,g.group_name as group_name, m.name as metric_name,um.unit as metric_unit,
       mv.min as min,mv.max as max,mv.p90 as p90,mv.p95 as p95,mv.p99 as p99
    from view_lt_steps lts
        inner join response_groups rg on rg.id_step = lts.step_id
        inner join groups g on rg.id_group = g.id
        inner join metrics m on m.id = rg.id_metric
        inner join units_measurement um on um.id=rg.id_metric_unit
        inner join metrics_value mv on mv.id = rg.id_metrics_value;