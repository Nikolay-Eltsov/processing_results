import {InfluxUrl,InfluxDB} from "../exemple/variables.js";
import { URL } from "https://jslib.k6.io/url/1.0.0/index.js";
import http from "k6/http";
import { group, check } from "k6";
import { FormData } from 'https://jslib.k6.io/formdata/0.0.2/index.js';

export function request_from_influx(query) {
  return group("request_from_influx", function () {
    const fd = new FormData();
    fd.append("q", query);
    fd.append("db", `${InfluxDB}`);

    let url = new URL(`${InfluxUrl}/query`);
    let response = http.post(url.toString(),fd.body(), {
      tags: { name: "/query?db=${influxdb}&q=${select}" },
      headers: {
        "Content-Type": "multipart/form-data; boundary=" + fd.boundary,
      },

    });
    check(response, {
      "response code /query?db=${influxdb}&q=${select} is 200": (response) =>
        response.status === 200,
    });
    return response
  });
}

export function get_response_groups(param){
    return group('get_response_groups', function () {
    const query = `SELECT 
            min(value) as min,
            max(value) as max,
            percentile(value, 90 ) as p90,
            percentile(value, 95 ) as p95,
            percentile(value, 99 ) as p99
        FROM "group_duration"
        WHERE time >= ${param.startTime}s
        AND time <= ${param.stopTime}s
        GROUP BY  "group" fill(null)`;
    console.debug(query);
    let response  = request_from_influx(query);
    let rows = format_result(response.json(),param.grouping)
    rows.forEach(element => {
      element.metric_name = "response"
      element.mem_usage = "ms"
      element.group_name = element.group
    });
    return rows
    });
}

export function get_response_route(param){
    return group('get_response_groups', function () {
    const query = `SELECT 
            min(value) as min,
            max(value) as max,
            percentile(value, 90 ) as p90,
            percentile(value, 95 ) as p95,
            percentile(value, 99 ) as p99
        FROM "http_req_duration"
        WHERE time >= ${param.startTime}s
        AND time <= ${param.stopTime}s
        GROUP BY  "name" fill(null)`;
    console.debug(query);
    let response  = request_from_influx(query);
    let rows = format_result(response.json(),param.grouping)
    rows.forEach(element => {
      element.rout_name = element.name
      element.mem_usage = "ms"
      element.metric_name = "response"
    });
    return rows
    });
}

function format_result(responseJson,key){
    console.debug(key);
    if (responseJson.results[0].series==undefined){
      console.error("Инфлюкс вернул пустые данные");
      return []
    }
    const transformedData = responseJson.results[0].series.map(item => {
        const group = item.tags[key].trim();
        return { [key]: group, 
        "min": parseInt(item.values[0][1].toFixed(0)),
        "max": parseInt(item.values[0][2].toFixed(0)),
        "p90": parseInt(item.values[0][3].toFixed(0)),
        "p95": parseInt(item.values[0][4].toFixed(0)),
        "p99": parseInt(item.values[0][5].toFixed(0))};
      });
      return transformedData
}