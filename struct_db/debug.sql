CREATE TYPE lt_test_row AS (
    test_id smallint,
    start_date   date,
    end_date    date,
    type varchar(20),
    name varchar(20),
    url varchar(30)
);

CREATE TYPE step_row AS (
    test_id smallint,
    start_date   date,
    end_date    date,
    type varchar(20),
    name varchar(20),
    url varchar(30),
    step_id smallint,
    step_start_date date,
    step_end_data date
);

drop function update_view_lt_test_end_date cascade ;
drop function insert_view_lt_test cascade ;





drop trigger TG_update_view_lt_test_end_date;
drop function public.get_id_scenario_type;
insert into view_lt_tests( test_id,start_date, end_date, type, name, url)
    values (null,now(),null,'max','max_ecp.js','https://stressenv06') returning test_id;

update view_lt_tests set end_date = now() where test_id=9;
select get_id_scenario((11,12));
select * from view_lt_tests;
select * from urls;
select * from   scenario_types;
select * from scenarios;
select * from scenarios   full outer join scenario_types st on st.id = scenarios.id_scenario_type;

select * from view_lt_steps;



select 12 as test,33 ;