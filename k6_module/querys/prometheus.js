import {Granularity,NameSpace,stressEnvHost,PrometheusUrl} from "../exemple/variables.js";
import * as helpers from "../result/helpers.js";
import { URL } from "https://jslib.k6.io/url/1.0.0/index.js";
import http from "k6/http";
import { group, check } from "k6";
import { FormData } from 'https://jslib.k6.io/formdata/0.0.2/index.js';

function request_for_prom(param) {
  return group("request_for_prom", function () {
    let url = new URL(
      `${PrometheusUrl}/api/v1/query_range`
    );
    const fd = new FormData();
    fd.append("query", param.query);
    fd.append("start", param.startTime);
    fd.append("end", param.stopTime);
    fd.append("step", Granularity);
    let response = http.post(url.toString(), fd.body(), {
      tags: { name: "/api/v1/query_range" },
      headers: {
        "Content-Type": "multipart/form-data; boundary=" + fd.boundary,
      },
    });
    check(response, {
      "response /api/v1/query_range is 200": (response) =>
        response.status === 200,
    });
    return response.json();
  });
}

function get_metric_for_prom(param) {
  return group("get_metric_for_prom", function () {
    let responseJson = request_for_prom(param);
    let row = helpers.gen_row(responseJson);
    console.debug(param)
    console.debug(row)
    return row;
  });
}

function get_kube_metrics_for_prom(param) {
  return group("get_kube_metrics_for_prom", function () {
    let responseJson = request_for_prom(param);
    let rows = helpers.gen_rows(responseJson, param.metricName);
    return rows;
  });
}

export function get_db_cpu_for_prom(param) {
  return group("get_db_cpu_for_prom", function () {
    param.query = `(1-avg(irate(node_cpu_seconds_total{instance="${stressEnvHost}:9100",mode="idle"}[${Granularity}])))*100`;
    let row = get_metric_for_prom(param);
    row.metric_name = "cpu_use";
    row.metric_unit = "%";
    return row;
  });
}

export function get_db_mem_usage_for_prom(param) {
  return group("get_db_mem_usage_for_prom", function () {
    param.query = `node_memory_MemTotal_bytes{instance="${stressEnvHost}:9100",job="databases"}
            - node_memory_MemFree_bytes{instance="${stressEnvHost}:9100",job="databases"} 
            - (node_memory_Cached_bytes{instance="${stressEnvHost}:9100",job="databases"} 
            + node_memory_Buffers_bytes{instance="${stressEnvHost}:9100",job="databases"} 
            + node_memory_SReclaimable_bytes{instance="${stressEnvHost}:9100",job="databases"})`;
    let row = get_metric_for_prom(param);
    row.metric_name = "mem_usage";
    row.metric_unit = "bytes";
    return row;
  });
}

export function get_db_mem_free_for_prom(param) {
  return group("get_db_mem_free_for_prom", function () {
    param.query = `node_memory_MemFree_bytes{instance="${stressEnvHost}:9100",job="databases"}`;
    let row = get_metric_for_prom(param);
    row.metric_name = "mem_free";
    row.metric_unit = "bytes";
    return row;
  });
}

export function get_db_mem_cache_for_prom(param) {
  return group("get_db_mem_cache_for_prom", function () {
    param.query = `node_memory_Cached_bytes{instance="${stressEnvHost}:9100",job="databases"} 
        + node_memory_Buffers_bytes{instance="${stressEnvHost}:9100",job="databases"} 
        + node_memory_SReclaimable_bytes{instance="${stressEnvHost}:9100",job="databases"}`;
    let row = get_metric_for_prom(param);
    row.metric_name = "mem_cache";
    row.metric_unit = "bytes";
    return row;
  });
}

export function get_db_receive_bytes_for_prom(param) {
  return group("get_db_receive_bytes_for_prom", function () {
    param.query = `irate(node_network_receive_bytes_total{instance="${stressEnvHost}:9100",job="databases",device="ens192"}[${Granularity}])*8`;
    let row = get_metric_for_prom(param);
    row.metric_name = "receive_bytes";
    row.metric_unit = "bytes";
    return row;
  });
}

export function get_db_transmit_bytes_for_prom(param) {
  return group("get_db_transmit_bytes_for_prom", function () {
    param.query = `irate(node_network_transmit_bytes_total{instance="${stressEnvHost}:9100",job="databases",device="ens192"}[${Granularity}])*8`;
    let row = get_metric_for_prom(param);
    row.metric_name = "transmit_bytes";
    row.metric_unit = "bytes";
    return row;
  });
}

export function get_db_io_util_sda_for_prom(param) {
  return group("get_db_io_util_sda_for_prom", function () {
    param.query = `irate(node_disk_io_time_seconds_total{instance="${stressEnvHost}:9100",job="databases",device="sda"}[${Granularity}])`;
    let row = get_metric_for_prom(param);
    row.metric_name = "io_util_sda";
    row.metric_unit = "%";
    return row;
  });
}

export function get_db_io_util_sdb_for_prom(param) {
  return group("get_db_io_util_sdb_for_prom", function () {
    param.query = `irate(node_disk_io_time_seconds_total{instance="${stressEnvHost}:9100",job="databases",device="sdb"}[${Granularity}])`;
    let row = get_metric_for_prom(param);
    row.metric_name = "io_util_sdb";
    row.metric_unit = "%";
    return row;
  });
}

export function get_kube_restart_pod_count_for_prom(param) {
  return group("get_kube_restart_pod_count_for_prom", function () {
    param.query = `sum(kube_pod_container_status_restarts_total{namespace=~"${NameSpace}", k8s_cluster_name=~"K8S-STRESS"})`;
    let row = get_metric_for_prom(param);
    row.metric_name = "restart_pod";
    row.metric_unit = "count";
    row.pod_name = "all"
    return row;
  });
}

export function get_kube_cpu_usage_for_prom(param) {
  return group("get_kube_cpu_usage_for_prom", function () {
    param.query = `sum(label_replace(rate(container_cpu_usage_seconds_total{namespace="${NameSpace}", image!=""}[${Granularity}]), 
            "pod_set", "$1", "pod", "podname-(([A-z57]+-){1,3}).*"))by (pod_set)`;
    param.metricName = "pod_set";
    let rows = get_kube_metrics_for_prom(param);
    rows.forEach(element => {
      element.metric_name = "cpu_usage"
      element.metric_unit = "m%"
      element.min =  (element.min*1000).toFixed(0)
      element.max = (element.max*1000).toFixed(0)
      element.mean =  (element.mean*1000).toFixed(0)
      element.p90 = (element.p90*1000).toFixed(0)
      element.p95 =(element.p95*1000).toFixed(0)
      element.p99 =(element.p99*1000).toFixed(0)
    });
    return rows;
  });
}

export function get_kube_mem_usage_for_prom(param) {
  return group("get_kube_mem_usage_for_prom", function () {
    param.query = `sum(label_replace(container_memory_working_set_bytes{namespace=~"${NameSpace}",service="prometheus-kube-prometheus-kubelet", image!=""}, 
        "pod_set", "$1", "pod", "podname-(([A-z57]+-){1,3}).*")) by (pod_set)`;
    param.metricName = "pod_set";
    let rows = get_kube_metrics_for_prom(param);
    rows.forEach(element => {
      element.metric_name = "mem_usage";
      element.metric_unit = "bytes";
      element.min =  (element.min/1024/1024).toFixed(0)
      element.max = (element.max/1024/1024).toFixed(0)
      element.mean =  (element.mean/1024/1024).toFixed(0)
      element.p90 = (element.p90/1024/1024).toFixed(0)
      element.p95 =(element.p95/1024/1024).toFixed(0)
      element.p99 =(element.p99/1024/1024).toFixed(0)
      element.metric_unit = "MB";
    });
    return rows;
  });
}
