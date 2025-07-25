create or replace view view_lt_tests as
select lt.id as test_id,dt.start_date as start_date,dt.end_date as end_date,st.type_name as type,sf.file_name as name,u.url as url
  from lt_tests lt
    join date_tests dt on lt.id_date_test = dt.id
    join scenarios s on lt.id_scenario = s.id
    join scenario_types st on s.id_scenario_type = st.id
    join scenario_files sf on s.id_scenario_file = sf.id
    join urls u on lt.id_url = u.id;
