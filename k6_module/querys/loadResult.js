import * as prometheus from "./prometheus.js";
import * as influx from "./influx.js";
import * as sql from "./sql.js"
import * as helpers from "../result/helpers.js"
import {stressEnvHost,NameSpace} from '../exemple/variables.js'

function metric_db(param){
  let  values = []
  console.debug("------метрики БД---------");
  values.push(prometheus.get_db_cpu_for_prom(param))
  values.push(helpers.bytesToMB(prometheus.get_db_mem_usage_for_prom(param)))
  values.push(helpers.bytesToMB(prometheus.get_db_mem_free_for_prom(param)))
  values.push(helpers.bytesToMB(prometheus.get_db_mem_cache_for_prom(param)))
  values.push(helpers.bytesToMB(prometheus.get_db_receive_bytes_for_prom(param)))
  values.push(prometheus.get_db_io_util_sda_for_prom(param))
  values.push(prometheus.get_db_io_util_sdb_for_prom(param))
  console.debug(`--------values-----------${values}`);
  if (values.length>0){
    values.forEach(element=>{
      element.step_id = param.stepId
      element.host_db = stressEnvHost
      console.debug(element);
    })
    sql.insertMetricsDB(values)
  }
  
}

function metric_kub(param){
  let  values = []
  console.debug("------метрики Куба---------");
  values.push(prometheus.get_kube_restart_pod_count_for_prom(param))
  values.push(...prometheus.get_kube_cpu_usage_for_prom(param))
  values.push(...prometheus.get_kube_mem_usage_for_prom(param))
  if (values.length>0){
    values.forEach(element=>{
      element.step_id = param.stepId
      element.name_sapace = NameSpace
      console.debug(element);
    })
    sql.insertResultMetricKube(values)
  }
}

function menric_group(param){
  let  values = []
  param.grouping = "group";
  console.debug("------метрики get_response_groups---------");
  values = influx.get_response_groups(param);
  if (values.length>0){
    values.forEach((element) => {
      element.step_id = param.stepId
      console.debug(element);
    });
    sql.insertResultResponceGroup(values)
  }
}
    
function menric_route(param){
  let  values = []
  param.grouping = "name";
  values = influx.get_response_route(param);
  console.debug("------метрики get_response_route---------");
  if (values.length>0){
    values.forEach((element) => {
      element.step_id = param.stepId
      console.debug(element);
    });
    sql.insertResultResponceRoute(values)
  }
}

export function loadResultStep(param) {
  if (param.test_id == 0||param.test_id==undefined){
        return
    }
    if (param.stepId == 0||param.stepId==undefined){
        param.stepId = sql.getLastStepIdForTestId(param);
    }
    let result = sql.getTimeStartStopStep(param)
    param.startTime = result.step_start_date
    param.stopTime = result.step_end_data
    // console.debug(param);
    // metric_db(param)
    // metric_kub(param)
    menric_group(param)
    menric_route(param)
  }
  