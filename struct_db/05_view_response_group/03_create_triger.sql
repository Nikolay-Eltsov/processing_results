CREATE TRIGGER insert_view_response_group
INSTEAD OF insert ON view_response_group
FOR EACH ROW EXECUTE FUNCTION insert_view_response_group();