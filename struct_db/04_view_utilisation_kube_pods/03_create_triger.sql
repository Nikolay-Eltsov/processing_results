CREATE TRIGGER insert_view_utilisation_kube
INSTEAD OF insert ON view_utilisation_kube
FOR EACH ROW EXECUTE FUNCTION insert_view_utilisation_kube();

create trigger delete_view_utilisation_kube_tgr 
instead of delete on view_utilisation_kube 
for each row execute function delete_view_utilisation_kube();
