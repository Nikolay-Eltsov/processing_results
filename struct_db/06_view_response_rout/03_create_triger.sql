CREATE TRIGGER insert_view_response_rout
INSTEAD OF insert ON view_response_rout
FOR EACH ROW EXECUTE FUNCTION insert_view_response_rout();