create or replace view view_utilisation_db as
    select lts.*, hd.host as host_db,m.name as metric_name,um.unit as metric_unit,
       mv.min as min,mv.max as max,mv.p90 as p90,mv.p95 as p95,mv.p99 as p99
    from view_lt_steps lts
        inner join utilisation_db udb on udb.id_step =lts.step_id
        inner join hosts_db hd on udb.id_server = hd.id
        inner join metrics m on m.id = udb.id_metric
        inner join metrics_value mv on mv.id = udb.id_metrics_value
        inner join units_measurement um on um.id = udb.id_metric_unit;



create view view_utilisation_db_for_calculate as (
    select udb.id_metric,udb.id_metric_unit,udb.id_step, min, max, p90, p95, p99 from utilisation_db udb join metrics_value  mv on udb.id_metrics_value = mv.id
    );
