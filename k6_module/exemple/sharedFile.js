import { SharedArray } from 'k6/data';

export const UserDataPG = new SharedArray('get Users PG', function () {
    const file = JSON.parse(open('./users.json'));
    return file.users_pg;
});