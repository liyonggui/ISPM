let util = {};
util.parse = (dateString, formatter) => {
    if (formatter === 'yyyy-MM-dd') {
        return new Date(dateString.replace('/-/g', '/'));
    } else if (formatter === 'yyyy-MM-dd hh:mm:ss') {
        let arr = dateString.split(' ');
        let ymd = arr[0].split('-');
        let hms = arr[1].split(':');
        return new Date(ymd[0], ymd[1]-1, ymd[2], hms[0], hms[1], hms[2]);
    } else if (formatter === 'yyyy') {
        return new Date(dateString, 0, 1);
    } else if (formatter === 'yyyy-MM') {
        let ym = dateString.split('-');
        return new Date(ymd[0], ymd[1]-1, 1);
    } else if (formatter === 'HH:mm:ss') {
        let hms = dateString.split(':');
        let d = new Date();
        d.setHours(hms[0]);
        d.setMinutes(hms[1]);
        d.setSeconds(hms[2]);
        return d;
    }
};
util.format = (strDate, formatter) => {
    let o = {   
        'M+': strDate.getMonth()+1,                 //月份   
        'd+': strDate.getDate(),                    //日   
        'h+': strDate.getHours(),                   //小时   
        'm+': strDate.getMinutes(),                 //分   
        's+': strDate.getSeconds(),                 //秒   
        'S': strDate.getMilliseconds()             //毫秒   
    };
    if (/(y+)/.test(formatter)) {   
        formatter=formatter.replace(RegExp.$1, (strDate.getFullYear()+"").substr(4 - RegExp.$1.length));
    }   
    for (var k in o) {   
        if (new RegExp("("+ k +")").test(formatter)) {   
            formatter = formatter.replace(RegExp.$1, (RegExp.$1.length==1) ? (o[k]) : (("00"+ o[k]).substr((""+ o[k]).length)));
        }
    }
    return formatter;   
};
export default util;