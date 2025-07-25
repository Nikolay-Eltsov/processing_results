create function insert_view_steps() returns trigger
as $fucntion$
declare
    date_step_id smallint;
    begin
        insert into date_steps(start_date, end_date)
        values (new.step_start_date,new.step_end_data) returning id into date_step_id ;
        insert into steps(id_test, id_date_step) values (new.test_id,date_step_id) returning id into new.step_id ;
        return new;
    end;
$fucntion$ LANGUAGE plpgsql;

create function update_end_date_view_step() returns trigger
    language plpgsql
as
$fucntion$
declare
    date_step_id smallint;
	BEGIN
        select s.id_date_step into date_step_id from steps s where id=old.step_id;
        update  date_steps set end_date = new.step_end_data where date_steps.id=date_step_id;
        return new;
	END;
$fucntion$;

CREATE procedure close_end_date_view_step(test_id_in smallint)
AS $function$
declare
	BEGIN
        update date_steps set end_date=now()
            where id in (select id_date_step from steps join date_steps ds on ds.id=steps.id_date_step
                            where steps.id_test=test_id_in and ds.end_date is null);
	END;
$function$
LANGUAGE plpgsql;

CREATE OR replace function get_last_step_id_for_test_id(test_id_in smallint) returns smallint
    language plpgsql
as
$fucntion$
declare
    step_id smallint;
	BEGIN
        select steps.id into step_id  from steps join date_steps ds on ds.id=steps.id_date_step
                            where steps.id_test=test_id_in order by steps.id desc limit 1 ;
        return step_id;
	END;
