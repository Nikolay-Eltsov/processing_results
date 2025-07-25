CREATE TRIGGER TG_insert_view_steps
INSTEAD OF insert ON view_lt_steps
FOR EACH ROW EXECUTE FUNCTION insert_view_steps();

CREATE TRIGGER TG_update_end_date_view_step
INSTEAD OF update ON view_lt_steps
FOR EACH ROW EXECUTE FUNCTION update_end_date_view_step();