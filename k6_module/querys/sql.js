import sql from "k6/x/sql";
import driver from "k6/x/sql/driver/postgres"
import * as dataShared from '../exemple/sharedFile.js';
import * as vars from '../exemple/variables.js'

const credential = dataShared.UserDataPG[0];
const minimalCountValuesMetrics = 9 
function requestToDB(query) {
  const db = sql.open(
    driver,
    `postgres://${credential.username_pg}:${credential.password_pg}@${vars.pgHost}:${vars.pgPort}/${vars.pgDB}?sslmode=disable`
  );
  console.debug(query);
  const result = db.query(query);
  console.debug(result);
  db.close();
  return result;
}


function insertStepToDB(table, parameters) {
  const query = `insert into ${table}(test_id,step_start_date) values (${parameters.test_id},now()) returning step_id;`;
  const result = requestToDB(query);
  return result[0].step_id;
}

export function insertStartTestToDB(parameters) {
  const query = `insert into view_lt_tests(start_date, type, name, url)
  values (now(),'${parameters.type}','${parameters.scriptName}','${parameters.baseUrl}') returning test_id;`;
  const result = requestToDB(query);
  return result[0].test_id;
}

export function updateStopTestToDB( parameters) {
  const query = `update view_lt_tests set end_date = now() where test_id=${parameters.test_id};`;
  const result = requestToDB(query);
  return result
}

export function insertStartStepToDB(parameters) {
  return insertStepToDB('view_lt_steps', parameters);
}

export function updateStopStepToDB(parameters) {
  const query = `update view_lt_steps set step_end_data=now() where step_id=${parameters.stepId};`;
  requestToDB(query);
}

export function closeStopStepToDB(parameters) {
  const query = `call close_end_date_view_step(${parameters.test_id}::smallint);`;
  return requestToDB(query);
}

export function closeStopTestToDB(parameters) {
  const query = `call close_end_date_view_lt_test(${parameters.test_id}::smallint);`;
  requestToDB(query);
}

export function insertMetricsToDB(table, values) {
  values.forEach(element => {
    let tmpVal = []
    table.colums.forEach(el=>tmpVal.push(element[el]))
    let valuesToInsert = `${"'"+tmpVal.join("','")+"'"}`
    let query = `insert into ${table.name}(${table.colums.toString()})
      values (${valuesToInsert});`;
    if (Object.keys(element).length < minimalCountValuesMetrics || Object.values(element).some(x => x === null || x === '' || x === 'NaN')) {
      console.error(`Ошибка попытка записать пустое поле в БД: ${query}`);
      return;
    }
    requestToDB(query);
  });
}

export function insertResultMetricKube(values) {
  let table = {
    "name": "view_utilisation_kube",
    "colums": ["step_id","name_sapace","pod_name","metric_name", "metric_unit", "min", "max", "p90", "p95", "p99"]
  }
  table.name = "view_utilisation_kube"
  insertMetricsToDB(table, values);
}
export function insertMetricsDB(values) {
  let table = {
    "name": "view_utilisation_db",
    "colums": ["step_id","host_db", "metric_name", "metric_unit", "min", "max", "p90", "p95", "p99"]
  }
  insertMetricsToDB(table, values);
}

export function insertResultResponceGroup( values) {
  let table = {
    "name": "view_response_group",
    "colums": ["step_id","group_name", "metric_name", "metric_unit", "min", "max", "p90", "p95", "p99"]
  }
  insertMetricsToDB(table, values);
}

export function insertResultResponceRoute( values) {
  let table = {
    "name": "view_response_rout",
    "colums": ["step_id","rout_name", "metric_name", "metric_unit", "min", "max", "p90", "p95", "p99"]
  }
  insertMetricsToDB(table, values);
}

export function getTimeStartStopStep(parameters) {
  const query = `select  ROUND(EXTRACT(EPOCH FROM step_start_date+interval '0 hour'))::TEXT  as step_start_date, ROUND(EXTRACT(EPOCH FROM step_end_data+interval '0 hour'))::TEXT as step_end_data from view_lt_steps where step_id = ${parameters.stepId}`;
  const result = requestToDB(query);
  return result[0];
}

export function getLastStepIdForTestId(parameters) {
  const query = `select  get_last_step_id_for_test_id(${parameters.test_id}::smallint) as step_id;`;
  const result = requestToDB(query);
  return result[0].step_id;
}
