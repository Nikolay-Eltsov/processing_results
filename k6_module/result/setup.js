import * as vars from '../exemple/variables.js';
import * as sql from '../querys/sql.js'

export function start(){
    const param = {
        "type": `${vars.K6Product}`,
        "scriptName": `${vars.K6TestScript}`,
        "baseUrl": `${vars.baseUrl}`,
    }
    let test_id = sql.insertStartTestToDB(param)
    console.log(`Начался тест нагрузки!
    Сценарий:${param.scriptName}
    Тип:${param.type}
    Урла:${param.baseUrl}
    Ид теста:${test_id}`)
    return(test_id)
}
