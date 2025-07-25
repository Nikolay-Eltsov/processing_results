insert into view_lt_steps(test_id,step_start_date) values (10,now());
select * from view_lt_steps ;
call close_end_date_view_step(10::smallint);
update view_lt_steps set step_end_data=now() where step_id='4';