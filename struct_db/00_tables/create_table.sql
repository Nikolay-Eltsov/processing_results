
-- создаем таблицу scenario_type

CREATE TABLE scenario_types (
     id smallint generated always as identity not null
        constraint scenario_types_pk
            primary key,
        type_name varchar(40)                                                not null UNIQUE
);

CREATE TABLE scenario_files (
     id smallint generated always as identity not null
        constraint scenario_files_pk
            primary key,
        file_name varchar(80)                                                not null UNIQUE
);

--

create table scenarios
(
    id smallint generated always as identity not null
        constraint scenarios_pk
            primary key,
    id_scenario_type smallint    not null
        constraint scenarios_scenario_types_id_fk
            references scenario_types
            on update cascade on delete cascade,
    id_scenario_file smallint    not null
        constraint scenarios_scenario_files_id_fk
            references scenario_files
            on update cascade on delete cascade
);



create table urls
(
    id smallint generated always as identity not null
        constraint urls_pk
            primary key,
    url varchar(60) not null UNIQUE
);



create table date_tests
(
    id smallint generated always as identity not null
        constraint date_tests_pk
            primary key,
    start_date timestamptz not null,
    end_date timestamptz 
);



create table lt_tests
(
    id smallint generated always as identity not null
        constraint lt_tests_pk
            primary key,
    id_scenario smallint    not null 
        constraint lt_tests_scenarios_id_fk
            references scenarios
            on update cascade on delete cascade,
    id_date_test smallint    not null
        constraint lt_tests_date_tests_id_fk
            references date_tests
            on update cascade on delete cascade,
    id_url smallint    not null
        constraint lt_tests_urls_id_fk
            references urls
            on update cascade on delete cascade
);



create table date_steps
(
    id smallint generated always as identity not null
        constraint date_steps_pk
            primary key,
    start_date timestamptz not null,
    end_date timestamptz 
);



create table steps
(
    id smallint generated always as identity not null
        constraint steps_pk
            primary key,
    id_test smallint    not null
     constraint steps_lt_tests_id_fk
        references lt_tests
        on update cascade on delete cascade,
    id_date_step smallint    not null
     constraint steps_date_steps_id_fk
        references date_steps
        on update cascade on delete cascade
);




create table hosts_db
(
    id smallint generated always as identity not null
        constraint hosts_db_pk
            primary key,
    host varchar(60) not null UNIQUE
);



create table name_spaces
(
    id smallint generated always as identity not null
        constraint name_spaces_pk
            primary key,
    space_name varchar(40) not null UNIQUE
);




create table routs
(
    id smallint generated always as identity not null
        constraint routs_pk
            primary key,
    rout varchar(200) not null UNIQUE
);



create table groups
(
    id smallint generated always as identity not null
        constraint groups_pk
            primary key,
    group_name varchar(120) not null UNIQUE
);



create table units_measurement
(
    id smallint generated always as identity not null
        constraint units_measurement_pk
            primary key,
    unit varchar(10) not null UNIQUE
);

create table metrics
(
    id smallint generated always as identity not null
        constraint metrics_pk
            primary key,
    name varchar(20) not null UNIQUE
);

create table metrics_value
(
    id integer generated always as identity not null
        constraint metrics_value_pk
            primary key,
    min integer not null,
    max integer not null,
    p90 integer not null,
    p95 integer not null,
    p99 integer not null
);





CREATE SEQUENCE parent_metrics_id_seq AS integer;
create table utilisation_db
(
    id integer not null default nextval('parent_metrics_id_seq'::regclass)
        constraint utilisation_db_pk
            primary key,
    id_server smallint    not null
     constraint utilisation_db_hosts_db_id_fk
        references hosts_db
        on update cascade on delete cascade,
    id_step smallint    not null
     constraint utilisation_db_steps_id_fk
        references steps
        on update cascade on delete cascade,
    id_metric smallint    not null
     constraint utilisation_db_metrics_fk
        references metrics
        on update cascade on delete cascade,
    id_metrics_value integer    not null
     constraint utilisation_db_metrics_value_fk
        references metrics_value
        on update cascade on delete cascade,
    id_metric_unit smallint not null
      constraint utilisation_db_units_measurement_id_fk
        references units_measurement
        on update cascade on delete cascade
);

create table pods
(
    id smallint generated always as identity not null
        constraint pods_pk
            primary key,
    pod_name varchar(80) not null UNIQUE
);

create table utilisation_kube
(
    id integer not null default nextval('parent_metrics_id_seq'::regclass)
        constraint utilisation_kube_pk
            primary key,
    id_name_space smallint    not null
     constraint utilisation_kube_name_spaces_id_fk
        references name_spaces
        on update cascade on delete cascade,
    id_step smallint    not null
     constraint utilisation_kube_space_steps_id_fk
        references steps
        on update cascade on delete cascade,
    id_metric smallint    not null
     constraint utilisation_kube_metrics_fk
        references metrics
        on update cascade on delete cascade,
    id_metrics_value integer    not null
     constraint utilisation_kube_metrics_value_fk
        references metrics_value
        on update cascade on delete cascade,
    id_metric_unit smallint not null
      constraint utilisation_kube_units_measurement_id_fk
        references units_measurement
        on update cascade on delete cascade,
    id_pod smallint not null
      constraint utilisation_kube_pods_id_fk
        references pods
        on update cascade on delete cascade
);


create table response_routs
(
    id integer not null default nextval('parent_metrics_id_seq'::regclass)
        constraint response_routs_pk
            primary key,
    id_step smallint    not null
     constraint response_steps_id_fk
        references steps
        on update cascade on delete cascade,
    id_rout smallint    not null
     constraint response_routs_routs_fk
        references routs
        on update cascade on delete cascade,
    id_metric smallint    not null
     constraint response_routs_metrics_fk
        references metrics
        on update cascade on delete cascade,
    id_metrics_value integer    not null
     constraint response_routs_metrics_value_fk
        references metrics_value
        on update cascade on delete cascade,
    id_metric_unit smallint not null
      constraint response_routs_units_measurement_id_fk
        references units_measurement
        on update cascade on delete cascade
);

create table response_groups
(
    id integer not null default nextval('parent_metrics_id_seq'::regclass)
        constraint response_groups_pk
            primary key,
    id_step smallint    not null
     constraint response_steps_id_fk
        references steps
        on update cascade on delete cascade,
    id_group smallint    not null
     constraint response_groups_groups_fk
        references groups
        on update cascade on delete cascade,
    id_metric smallint    not null
     constraint response_groups_metrics_fk
        references metrics
        on update cascade on delete cascade,
    id_metrics_value integer    not null
     constraint response_groups_metrics_value_fk
        references metrics_value
        on update cascade on delete cascade,
    id_metric_unit smallint not null
      constraint response_groups_units_measurement_id_fk
        references units_measurement
        on update cascade on delete cascade
);
