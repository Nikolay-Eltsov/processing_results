insert into view_lt_tests( test_id,start_date, end_date, type, name, url)
    values (null,now(),null,'max','max_ecp.js','https://stressenv06') returning test_id;

insert into view_lt_tests( start_date, end_date, type, name, url)
    values (now(),null,'max','max_ecp.js','https://stressenv06') returning test_id;

select * from view_lt_tests;

update view_lt_tests set end_date = now() where test_id=9;

select * from view_lt_tests;

