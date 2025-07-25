create function get_id_group_name(group_name_in varchar, OUT group_name_id smallint) returns smallint
    language plpgsql
as
$function$
declare
	BEGIN
    select id into group_name_id from groups where group_name=group_name_in;
    IF NOT FOUND THEN
        insert into groups(group_name) values (group_name_in) returning id into group_name_id;
    end if;
	END;
$function$;


create function insert_view_response_group() returns trigger
as $fucntion$
declare
    metric_id smallint;
    metric_value_id integer;
    group_name_id smallint;
    utilisation_kube_id smallint;
    metric_unit_id smallint;
    begin
        select 1::smallint into metric_id from view_response_group
        where 1=1
        and  step_id = new.step_id
        and  group_name = new.group_name
        and  metric_name = new.metric_name
        and  metric_unit =new.metric_unit;
        IF NOT FOUND THEN
            metric_id = get_id_metric(new.metric_name);
            metric_unit_id = get_id_metric_unit(new.metric_unit);
            insert into metrics_value(min, max, p90, p95, p99)
                values (ceil(new.min)::integer,
                        ceil(new.max)::integer,
                        ceil(new.p90)::integer,
                        ceil(new.p95)::integer,
                        ceil(new.p99)::integer) returning id into metric_value_id;
            group_name_id = get_id_group_name(new.group_name);
            insert into response_groups(id_group, id_step, id_metric, id_metrics_value, id_metric_unit)
                values (group_name_id,new.step_id,metric_id,metric_value_id,metric_unit_id) returning id into utilisation_kube_id;
        end if;
        return new;
    end;
$fucntion$ LANGUAGE plpgsql;
