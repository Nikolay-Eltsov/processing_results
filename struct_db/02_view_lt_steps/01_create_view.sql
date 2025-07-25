create or replace view view_lt_steps as
    select lt.*,steps.id as step_id,ds.start_date as step_start_date,ds.end_date as step_end_data
    from view_lt_tests as lt
        join steps on lt.test_id = steps.id_test
        join date_steps ds on steps.id_date_step = ds.id;