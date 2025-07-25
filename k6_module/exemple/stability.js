import * as vars from './variables.js';

import { UC_01 } from './uc_01.js'

import { textSummary } from 'https://jslib.k6.io/k6-summary/0.0.2/index.js';

import * as setupScript from '../result/setup.js'
import * as aggregateResultat from '../result/scenarioResultat.js'

const timeUnit = vars.timeUnit;  //default '1m'
// rate of iterations started per `timeUnit`
const startScriptRate1 = vars.startScriptRateUC01;  //default 10

const multiplierStepMaxPerf = vars.manualMultiplierStepMaxPerf; //default 10

const minUser = vars.startVus;  //default 10
const maxUser = vars.limitVus;  //default 100
const rampUpStep = vars.rampDuration;  //default '10s'
const durationStep = vars.duration;   //default '5m'


export const options = {
  scenarios: {
    scriptUC_01: {
      executor: 'ramping-arrival-rate',
      startRate: startScriptRate1,
      timeUnit: timeUnit,
      preAllocatedVUs: minUser,
      maxVUs: maxUser,
      stages: [
        { target: startScriptRate1 * multiplierStepMaxPerf, duration: rampUpStep },
        { target: startScriptRate1 * multiplierStepMaxPerf, duration: durationStep },
      ],
      exec: 'scriptUC_01',
      tags: { scenario: 'scriptUC_01' },
    },
    insertDataToBD: {
      executor: 'ramping-arrival-rate',
      startRate: 1,
      timeUnit: '1s',
      preAllocatedVUs: 1,
      maxVUs: 1,
      stages: [
        { target: 1, duration: rampUpStep },
        { target: 1, duration: durationStep },
      ],
      exec: 'insertDataToBD',
      tags: { scenario: 'insertDataToBD' },
    },
  },//scenarios
  thresholds: {
    http_req_failed: ['rate<0.1'], // http errors should be less than 1%
  },
  tags: {
    simulation_type: 'stability'
  },
}


export function setup() {
  const test_id = setupScript.start()
  return { "test_id": test_id }
}

export function insertDataToBD(data) {
  aggregateResultat.insertStageToBD(data)
}

export function scriptUC_01() {
  UC_01()
}

export function teardown(data) {
  console.log("тест teardown");
  aggregateResultat.close_last_step(data);
}

export function handleSummary(data) {
  return {
    'stdout': textSummary(data, { indent: ' ', enableColors: true }), // Show the text summary to stdout...
    'summary.json': JSON.stringify(data), //the default data object
  };
}