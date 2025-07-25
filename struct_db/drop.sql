drop table if exists utilisation_db cascade;

drop table if exists hosts_db cascade;

drop table if exists utilisation_kube cascade;

drop table if exists name_spaces cascade;

drop table if exists pods cascade;

drop table if exists response_routs cascade;

drop table if exists routs cascade;

drop table if exists response_groups cascade;

drop table if exists steps cascade;

drop table if exists lt_tests cascade;

drop table if exists scenarios cascade;

drop table if exists scenario_types cascade;

drop table if exists scenario_files cascade;

drop table if exists urls cascade;

drop table if exists date_tests cascade;

drop table if exists date_steps cascade;

drop table if exists groups cascade;

drop table if exists units_measurement cascade;

drop table if exists metrics cascade;

drop table if exists metrics_value cascade;

drop sequence if exists parent_metrics_id_seq cascade;

drop function if exists insert_view_lt_test() cascade;

drop function if exists update_view_lt_test_end_date() cascade;

drop procedure if exists close_end_date_view_lt_test(smallint) cascade;

drop function if exists insert_view_steps() cascade;

drop function if exists update_end_date_view_step() cascade;

drop procedure if exists close_end_date_view_step(smallint) cascade;

drop function if exists get_id_host_db(varchar, out smallint) cascade;

drop function if exists get_id_metric_unit(varchar, out smallint) cascade;

drop function if exists insert_view_utilisation_db() cascade;

drop function if exists get_diff_utilisation_db(integer, integer) cascade;

drop function if exists get_id_name_space(varchar, out smallint) cascade;

drop function if exists get_id_pod(varchar, out smallint) cascade;

drop function if exists insert_view_utilisation_kube() cascade;

drop function if exists get_id_group_name(varchar, out smallint) cascade;

drop function if exists insert_view_response_group() cascade;

drop function if exists get_id_rout(varchar, out smallint) cascade;

drop function if exists insert_view_response_rout() cascade;

drop function if exists delete_view_utilisation_db() cascade;

drop function if exists  delete_view_utilisation_kube() cascade;