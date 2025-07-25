CREATE TYPE lt_test_row AS (
    test_id smallint,
    start_date   date,
    end_date    date,
    type varchar(20),
    name varchar(20),
    url varchar(30)
);

CREATE TYPE step_row AS (
    test_id smallint,
    start_date   date,
    end_date    date,
    type varchar(20),
    name varchar(20),
    url varchar(30),
    step_id smallint,
    step_start_date date,
    step_end_data date
);