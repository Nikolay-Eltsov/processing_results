docker run -d \-p 5432:5432 --name demo_postgres \
    -e POSTGRES_PASSWORD=mysecretpassword \
    -e PGDATA=/var/lib/postgresql/data/pgdata \
    -v ./pgdb:/var/lib/postgresql/data \
    postgres