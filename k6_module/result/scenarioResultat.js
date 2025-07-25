import * as sqlx from '../querys/sql.js'
import { getCurrentStageIndex } from 'https://jslib.k6.io/k6-utils/1.4.0/index.js';
import * as vars from '../exemple/variables.js';


import { loadResultStep } from '../querys/loadResult.js'


let prevStage = 0
let currentStep = 0
let stepId = 0

function stepCheck(stageIndex, test_id) {
    if (prevStage != stageIndex) {
        prevStage = stageIndex
        if (stageIndex % 2 == 1) {
            currentStep += 1
            console.log(`началась новая ступень ${currentStep}`)
            sqlx.closeStopStepToDB({"test_id":test_id})
            let tmp = stepId
            stepId = sqlx.insertStartStepToDB({"test_id":test_id})
            loadResultStep({"stepId":tmp})
        }else{
            console.log(`Закончалась ступень ${currentStep}`)
            sqlx.closeStopStepToDB({"test_id":test_id})
        }

    }
}


export function insertStageToBD(data) {
    let stage = getCurrentStageIndex();
    stepCheck(stage, data.test_id);
}


export function close_last_step(data){
    sqlx.closeStopStepToDB({"test_id":data.test_id})
    sqlx.closeStopTestToDB({"test_id":data.test_id})
    loadResultStep({"test_id":data.test_id}) 
}

