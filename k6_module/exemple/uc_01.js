import * as vars from './variables.js';
import { group, check } from 'k6'
import http from 'k6/http'
import { randomString } from 'https://jslib.k6.io/k6-utils/1.2.0/index.js';


export function UC_01() {
    let token = randomString(16); // random is working now
    group('open_main', function () {
        let response = http.get(`${vars.baseUrl}/`,
            { tags: { name: '/' }});
        check(response, {
            'response code /  is 200': (response) => response.status === 200,
        });
        response = http.get(`${vars.baseUrl}/api/config`,
            { tags: { name: '/api/config' } });
        check(response, {
            'response code /api/config is 200': (response) => response.status === 200,
        });
        response = http.get(`${vars.baseUrl}/api/quotes`,
            { tags: { name: '/api/quotes' } });
        check(response, {
            'response code /api/quotes is 200': (response) => response.status === 200,
        });
        response = http.get(`${vars.baseUrl}/api/tools`,
            { tags: { name: '/api/tools' }, headers:{authorization: `Token ${token}`} });
        check(response, {
            'response code /api/tools is 200': (response) => response.status === 200,
        });
    });
    group('click_pizza_please', function () {
        let payload = {
            "maxCaloriesPerSlice": 1000,
            "mustBeVegetarian": false,
            "excludedIngredients": [],
            "excludedTools": [],
            "maxNumberOfToppings": 5,
            "minNumberOfToppings": 2,
            "customName": ""
        }
        let response = http.post(`${vars.baseUrl}/api/pizza`, JSON.stringify(payload),
            { tags: { name: '/api/pizza' },headers:{authorization: `Token ${token}`}});
        check(response, {
            'response code /api/pizza is 200': (response) => response.status === 200,
        });
    });
}

export default function () {
        group('UC_01', function () {
            UC_01();
        });
}