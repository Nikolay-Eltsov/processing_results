CREATE TRIGGER TG_insert_view_lt_test
INSTEAD OF insert ON view_lt_tests
FOR EACH ROW EXECUTE FUNCTION insert_view_lt_test();

CREATE TRIGGER TG_update_view_lt_test_end_date
INSTEAD OF update ON view_lt_tests
FOR EACH ROW EXECUTE FUNCTION update_view_lt_test_end_date();