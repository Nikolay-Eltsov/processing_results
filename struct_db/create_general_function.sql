
create or replace function result_procent(in list integer[] , out result_procent float4)
 language plpgsql
as
$function$
declare
    begin
    RAISE NOTICE 'list=%, list[1]=%, list[2]=%', list, list[1], list[2];
        result_procent:= round((list[2] - list[1])*100/list[1])::integer;
    end;
$function$;