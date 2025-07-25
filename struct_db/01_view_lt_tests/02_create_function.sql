CREATE or replace FUNCTION get_id_scenario_type(in row_in view_lt_tests, out id_type smallint)
AS $function$
declare
	BEGIN
    select scenario_types.id into id_type from scenario_types where scenario_types.type_name =row_in.type;
    IF NOT FOUND THEN
     insert into scenario_types(type_name) values (row_in.type) returning scenario_types.id into id_type;
    end if;
	END;
$function$
LANGUAGE plpgsql
;

CREATE or replace FUNCTION get_id_scenario_file(in row_in view_lt_tests, out id_file smallint)
AS $function$
declare
	BEGIN
    select scenario_files.id into id_file from scenario_files where scenario_files.file_name =row_in.name;
    IF NOT FOUND THEN
     insert into scenario_files(file_name) values (row_in.name) returning scenario_files.id into id_file;
    end if;
	END;
$function$
LANGUAGE plpgsql
;

CREATE or replace FUNCTION get_id_scenario(in row_in view_lt_tests, out scenario_id smallint)
AS $function$
declare
	BEGIN
    select scenarios.id into scenario_id from scenarios
        join scenario_types st on st.id = scenarios.id_scenario_type
        join scenario_files sf on sf.id = scenarios.id_scenario_file
            where sf.file_name=row_in.name and
            st.type_name=row_in.type;
    IF NOT FOUND THEN
     insert into scenarios(id_scenario_file,id_scenario_type)
     values (get_id_scenario_file(row_in),get_id_scenario_type(row_in))
     returning scenarios.id into scenario_id;
    end if;
	END;

$function$
LANGUAGE plpgsql
;

CREATE or replace FUNCTION get_id_url(in row_in view_lt_tests, out url_id smallint)
AS $function$
declare
	BEGIN
        select urls.id into url_id from urls where urls.url =row_in.url;
    IF NOT FOUND THEN
        insert into urls(url) values (row_in.url) returning urls.id into url_id;
    end if;
	END;
$function$
LANGUAGE plpgsql
;

CREATE or replace FUNCTION insert_date_test(in row_in view_lt_tests, out date_test_id smallint)
AS $function$
declare
	BEGIN
        insert into date_tests(start_date, end_date) values (row_in.start_date,row_in.end_date) returning date_tests.id into date_test_id;
	END;
$function$
LANGUAGE plpgsql
;

CREATE or replace FUNCTION update_stop_date_test(in row_in view_lt_tests, out date_test_id smallint)
AS $function$
declare
	BEGIN
        select lt_tests.id_date_test into date_test_id from lt_tests where id=row_in.test_id;
        update  date_tests set end_date = row_in.end_date where date_tests.id=date_test_id;
	END;
$function$
LANGUAGE plpgsql
;


create function insert_view_lt_test() returns trigger
as $fucntion$
declare
    code  char(3);
    id_scenario smallint;
    id_url smallint;
    id_date smallint;
    begin
        id_scenario =   get_id_scenario(new);
        id_url =  get_id_url(new);
        id_date =  insert_date_test(new);
        insert into lt_tests(id_scenario, id_date_test, id_url)
        values (id_scenario,id_date,id_url) returning id into new.test_id ;
        return new;
    end;
$fucntion$ LANGUAGE plpgsql
;

create function update_view_lt_test_end_date() returns trigger
as $fucntion$
declare
    id_date smallint;
    begin
        select id_date_test into id_date from lt_tests where id = old.test_id;
        update date_tests set end_date=new.end_date where id = id_date;
        return new;
    end;
$fucntion$ LANGUAGE plpgsql
;

create procedure close_end_date_view_lt_test(IN test_id_in smallint)
    language plpgsql
as
$function$
declare
	BEGIN
        update date_tests set end_date=now()
            where id in (select id_date_test from lt_tests 
                            where lt_tests.id=test_id_in and date_tests.end_date is null);
	END;
$function$;
