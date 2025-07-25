CREATE TRIGGER insert_view_utilisation_db
INSTEAD OF insert ON view_utilisation_db
FOR EACH ROW EXECUTE FUNCTION insert_view_utilisation_db();

create trigger delete_view_utilisation_db_trg 
instead of delete on view_utilisation_db 
for each row execute function delete_view_utilisation_db();
