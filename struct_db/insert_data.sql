insert into view_lt_tests( test_id,start_date, end_date, type, name, url)
    values (null,now(),null,'max','max_ecp.js','https://stressenv06') returning test_id;

insert into view_lt_tests( start_date, end_date, type, name, url)
    values (now(),null,'max','max_ecp.js','https://stressenv06') returning test_id;


insert into view_lt_steps(test_id,step_start_date) values (1,now());

insert into view_utilisation_db(step_id, host_db, metric_name, metric_unit, min, max, p90, p95, p99)
    values (1,'stress-db01','cpu_uti13','m',0,100,70,80,90);