create function get_id_host_db(host_name varchar, OUT host_db_id smallint) returns smallint
    language plpgsql
as
$function$
declare
	BEGIN
    select id into host_db_id from hosts_db where host=host_name;
    IF NOT FOUND THEN
        insert into hosts_db(host) values (host_name) returning id into host_db_id;
    end if;
	END;
$function$;

create function get_id_metric(metric_name varchar, OUT metric_id smallint) returns smallint
    language plpgsql
as
$function$
declare
	BEGIN
    select id into metric_id from metrics
        where name = metric_name;
    IF NOT FOUND THEN
        insert into metrics(name)
        values (metric_name) returning id into metric_id;
    end if;
	END;
$function$;


create function get_id_metric_unit(metric_unit varchar, OUT metric_unit_id smallint) returns smallint
    language plpgsql
as
$function$
declare
	BEGIN
    select um.id into metric_unit_id from units_measurement  um where um.unit = metric_unit;
    IF NOT FOUND THEN
        insert into units_measurement(unit) values (metric_unit) returning id into metric_unit_id;
    end if;
	END;
$function$;


create function insert_view_utilisation_db() returns trigger
as $fucntion$
declare
    metric_id smallint;
    metric_value_id integer;
    host_db_id smallint;
    utilisation_db_id smallint;
    metric_unit_id smallint;
    begin
        select 1::smallint into metric_id from view_utilisation_db
        where 1=1
        and  step_id = new.step_id
        and  host_db = new.host_db
        and metric_name = new.metric_name
        and metric_unit =new.metric_unit;
        IF NOT FOUND THEN
            metric_id = get_id_metric(new.metric_name);
            metric_unit_id = get_id_metric_unit(new.metric_unit);
            insert into metrics_value(min, max, p90, p95, p99)
                values (ceil(new.min)::integer,
                        ceil(new.max)::integer,
                        ceil(new.p90)::integer,
                        ceil(new.p95)::integer,
                        ceil(new.p99)::integer) returning id into metric_value_id;
            host_db_id = get_id_host_db(new.host_db);
            insert into utilisation_db(id_server, id_step, id_metric, id_metrics_value, id_metric_unit)
                values (host_db_id,new.step_id,metric_id,metric_value_id,metric_unit_id) returning id into utilisation_db_id;
        end if;
        return new;
    end;
$fucntion$ LANGUAGE plpgsql;

create or replace function get_diff_utilisation_db(first_step_id integer,second_step_id integer)
    returns table (
        metric_id varchar(20),
        diff_proc integer,
        first_step_id_out  smallint,
        second_step_id_out smallint)
     language plpgsql
as
$function$
declare
    begin
    return query  with t as (
           select  step_id,metric_name,p90 from view_utilisation_db where step_id=first_step_id
           union
           select  step_id,metric_name,p90 from view_utilisation_db where step_id=second_step_id  order by step_id,metric_name desc
        )  select metric_name,result_procent(array_agg(p90) )::integer, (array_agg(step_id))[1] , second_step_id::smallint from t group by metric_name;
    end;
$function$;

CREATE OR REPLACE FUNCTION delete_view_utilisation_db()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare
    metric_id smallint;
    metric_value_id integer;
    host_db_id smallint;
    utilisation_db_id integer;
    metric_unit_id smallint;
    begin
	    metric_id = get_id_metric(old.metric_name);
	    metric_unit_id = get_id_metric_unit(old.metric_unit);
		host_db_id = get_id_host_db(old.host_db);
	    select id_metrics_value into metric_value_id from utilisation_db 
	    WHERE 1=1
	    and id_step = OLD.step_id
	    and id_server = host_db_id
	    and id_metric = metric_id
	    and id_metric_unit = metric_unit_id;
	    delete from utilisation_db where id_metrics_value = metric_value_id;
	 	IF NOT FOUND THEN RETURN NULL; END IF;
	   	delete from metrics_value where id = metric_value_id;
	    IF NOT FOUND THEN RETURN NULL; END IF;
	   	RETURN OLD;
    end;
$function$;