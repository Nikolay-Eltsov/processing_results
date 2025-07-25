cat 00_tables/create_table.sql > ./all.sql && for i in `ls |grep view`
do
        for j in `ls $i|grep 0`;
        do
            cat $i/$j>>./all.sql;
        done
done