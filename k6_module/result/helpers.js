
export const  asc = arr => arr.sort((a, b) => a - b);
export const sum = arr => arr.reduce((a, b) => a + b, 0);
export const mean = arr => sum(arr) / arr.length;
export const quantile = (arr, q) => {
    const sorted = asc(arr);
    const pos = (sorted.length - 1) * q;
    const base = Math.floor(pos);
    const rest = pos - base;

  return sorted[base + 1] !== undefined ? sorted[base] + rest * (sorted[base + 1] - sorted[base]): sorted[base];
};

export function bytesToMB(row){
  row = convert_metric_value(row,"MB",(float_in)=>float_in/1024/1024)
  return row
}
  

export function gen_row(prometheusObject){
  let results = prometheusObject.data.result
  let row = {}
  if (results.length>1){
      console.warn("Обнаружено несколько метрик, неточный запрос или нужно использовать функцию gen_rows() вместо gen_row()");
  }
  if (results.length<1){
    return row
  }
  let values=[]
  results[0].values.forEach(element=>values.push(parseFloat(element[1])))
  row.min = asc(values)[0].toFixed(0)
  row.max = asc(values)[values.length-1].toFixed(0)
  row.mean = mean(values).toFixed(0)
  row.p90 = quantile(values, .90).toFixed(0)
  row.p95 = quantile(values, .95).toFixed(0)
  row.p99 = quantile(values, .99).toFixed(0)
  return row
}

export function gen_rows(prometheusObject,metricName){
  let results = prometheusObject.data.result
  let rows = []
  let rows_group = []
  if (results.length == 1){
      console.warn("Обнаружена только 1 метрика, невозможна фильтрация. Проверте запрос или используйте функцию gen_row() вместо gen_rows()");
      return rows
  }
  results.forEach(el=>{
    rows[`${el.metric[metricName]}`] =[] ; 
    el.values.forEach(element=>rows[`${el.metric[metricName]}`].push(parseFloat(element[1])));
    let metric_name = el.metric[metricName]
    rows_group.push({
      "pod_name":metric_name,
      "min":asc(rows[metric_name])[0],
      "max":asc(rows[metric_name])[rows[metric_name].length-1],
      "mean":mean(rows[metric_name]).toFixed(0),
      "p90":quantile(rows[metric_name],.90),
      "p95":quantile(rows[metric_name],.95),
      "p99":quantile(rows[metric_name],.99)
    })
  })
  return rows_group
}


export function convert_metric_value(row,unit,mathFunction){
  row.min=mathFunction(row.min).toFixed(0);
  row.max=mathFunction(row.max).toFixed(0);
  row.mean=mathFunction(row.mean).toFixed(0);
  row.p90=mathFunction(row.p90).toFixed(0);
  row.p95=mathFunction(row.p95).toFixed(0);
  row.p99=mathFunction(row.p99).toFixed(0);
  row.unit = unit
  return row
}

export function onlyUnique(value, index, array) {
  return array.indexOf(value) === index;
}


export function getCurrentDate() {
  const date = new Date();
  let currentDay= String(date.getDate()).padStart(2, '0');
  let currentMonth = String(date.getMonth()+1).padStart(2,"0");
  let currentYear = date.getFullYear();
  const currentDate = `${currentYear}-${currentMonth}-${currentDay}`;
  return currentDate
}

export function getDateInFormat(date) {
  let day = String(date.getDate()).padStart(2, '0');
  let month = String(date.getMonth()+1).padStart(2,"0");
  let year = date.getFullYear();
  const resultDate = `${year}-${month}-${day}`;
  return resultDate;
}

export function getOffsetDate(date, dayOffset) {
  let resultDate = new Date;
  resultDate.setDate((date.getDate() + dayOffset));
  return getDateInFormat(resultDate);
}