import areaData from 'area-data/pcaa';

let util = {};
util.getFormmaterByDateType = (datetype) => {
    let formatter = 'yyyy-MM-dd';
    if (datetype === 'date' || datetype === 'daterange') {
        formatter = 'yyyy-MM-dd';
    } else if (datetype === 'datetime' || datetype === 'datetimerange') {
        formatter = 'yyyy-MM-dd hh:mm:ss';
    } else if (datetype === 'year') {
        formatter = 'yyyy';
    } else if (datetype === 'month') {
        formatter = 'yyyy-MM';
    }
    return formatter;
};
util.areaTranslate = (arr, dataType) => {
    let i = 0;
    let res = [];
    while (arr[i]) {
        // 移动端数据最多到区。。。迷
        if (i > 2) {
            break;
        }
        let name = '';
        if (i === 0) {
            name = areaData['86'][arr[i]];
        } else {
            name = areaData[arr[i - 1]][arr[i]];
        }
        let item;
        if (dataType === 'all') {
            item = {
                code: arr[i],
                name: name
            };
        } else if (dataType === 'name') {
            item = name;
        } else {
            item = arr[i];
        }
        res.push(item);
        i++;
    }
    return res;
};
export default util;