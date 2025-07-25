create function get_id_name_space(name_space_in varchar , OUT name_space_id smallint) returns smallint
    language plpgsql
as
$function$
declare
	BEGIN
    select id into name_space_id from name_spaces where space_name=name_space_in;
    IF NOT FOUND THEN
        insert into name_spaces(space_name) values (name_space_in) returning id into name_space_id;
    end if;
	END;
$function$;


create function get_id_pod(name_pod_in varchar , OUT pod_id smallint) returns smallint
    language plpgsql
as
$function$
declare
	BEGIN
    select id into pod_id from pods where pod_name=name_pod_in;
    IF NOT FOUND THEN
        insert into pods(pod_name) values (name_pod_in) returning id into pod_id;
    end if;
	END;
$function$;

create function insert_view_utilisation_kube() returns trigger
as $fucntion$
declare
    metric_id smallint;
    metric_value_id integer;
    name_space_id smallint;
    utilisation_kube_id smallint;
    metric_unit_id smallint;
    pod_id SMALLINT;
    begin
        select 1::smallint into metric_id from view_utilisation_kube
        where 1=1
        and  step_id = new.step_id
        and  name_sapace = new.name_sapace
        and  metric_name = new.metric_name
        and  metric_unit =new.metric_unit
        and  pod_name = new.pod_name;
        IF NOT FOUND THEN
            metric_id = get_id_metric(new.metric_name);
            metric_unit_id = get_id_metric_unit(new.metric_unit);
            pod_id = get_id_pod(new.pod_name);
            insert into metrics_value(min, max, p90, p95, p99)
                values (ceil(new.min)::integer,
                        ceil(new.max)::integer,
                        ceil(new.p90)::integer,
                        ceil(new.p95)::integer,
                        ceil(new.p99)::integer) returning id into metric_value_id;
            name_space_id = get_id_name_space(new.name_sapace);
            insert into utilisation_kube(id_name_space, id_step,id_pod, id_metric, id_metrics_value, id_metric_unit)
                values (name_space_id,new.step_id,pod_id,metric_id,metric_value_id,metric_unit_id) returning id into utilisation_kube_id;
        end if;
        return new;
    end;
$fucntion$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION public.delete_view_utilisation_kube()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare
    metric_id smallint;
    metric_value_id integer;
    name_space_id smallint;
    utilisation_kube_id integer;
    metric_unit_id smallint;
    pod_id SMALLINT;
    begin
	    metric_id = get_id_metric(old.metric_name);
        metric_unit_id = get_id_metric_unit(old.metric_unit);
        pod_id = get_id_pod(old.pod_name);
        name_space_id = get_id_name_space(old.name_sapace);
        select id_metrics_value into metric_value_id from utilisation_kube
        where 1=1
        and  id_step = old.step_id
        and  id_name_space = name_space_id
        and  id_pod = pod_id
        and  id_metric = metric_id
        and  id_metric_unit = metric_unit_id;
       	delete from utilisation_kube where id_metrics_value=metric_value_id;
        IF NOT FOUND THEN RETURN NULL; END IF;
       	delete from metrics_value where id = metric_value_id;
        IF NOT FOUND THEN RETURN NULL; END IF;
        return old;
    end;
$function$;