import _ from 'lodash'

function hasClass(element, className) {
  return element.className.match(new RegExp('(\\s|^)' + className + '(\\s|$)'))
}

function addClass(element, className) {
  if (!hasClass(element, className)) {
    element.className += ' ' + className
  }
}

function removeClass(element, className) {
  if (hasClass(element, className)) {
    let reg = new RegExp('(\\s|^)' + className + '(\\s|$)')
    element.className = element.className.replace(reg, '')
  }
}

function toggleClass(element, className) {
  if (hasClass(element, className)) {
    removeClass(element, className)
  } else {
    addClass(element, className)
  }
}

function setContentHeight(selector, fixHeight) {
  function autoContentHeight(selector, fixHeight) {
    const contentWrapper = document.querySelector(selector)
    if (contentWrapper) {
      contentWrapper.style.minHeight = (window.innerHeight - fixHeight) + 'px'
    }
  }

  window.onresize = _.debounce(() => {
    autoContentHeight(selector, fixHeight)
  }, 300)
}

//获取当前用户的机构
function getUserCompanyInfo() {
  return JSON.parse(sessionStorage.companyInfo)
}

//获取当前用户的组织
function getUserOrgInfo() {
  return JSON.parse(sessionStorage.orgInfo)
}

//根据机构id获取组织选项
function getOrganizationOpt(vue, companyId, callback) {
  let filter = {
    where: {
      and: [
        {
          'orgParent.id': companyId
        }
      ]
    }
  };
  vue.$axios.get('/OrganizationService/query', {data: [filter]})
    .then((resp) => {
      callback(resp.data)
    })
}

//根据机构id获取车辆选项
function getVehicleOpt(vue, companyId, callback) {
  let filter = {
    where: {
      and: [
        {
          'company.id': companyId
        }
      ]
    }
  };
  vue.$axios.get('/VehicleService/query', {data: [filter]})
    .then((resp) => {
      callback(resp.data)
    })
}

//GeoLocation handle
let wid = null;
let shipments = [];
const distanceValue = 1000;
const arrivalStatus1 = 'arrive_status1_2';//按时到达
const arrivalStatus2 = 'arrive_status1_3';//未按时到达
import moment from 'moment';
let PathItems = [];
let intervalId = null;
function GeoListener(vue) {
  if (!wid && sessionStorage.plusready === 'done') {
    let index = 0;
    console.log('start');
    wid = navigator.geolocation.watchPosition((p) => {
      console.log(index++);
      listenerShipments(p.coords.latitude + ',' + p.coords.longitude, vue);
      console.log('Geolocation\nLatitude:' + p.coords.latitude + '\nLongitude:' + p.coords.longitude + '\nAltitude:' + p.coords.altitude);
    }, (e) => {
    }, {provider: 'system', enableHighAccuracy: 'true', maximumAge: 0});
    console.log(JSON.stringify(wid))
    console.log('Geolocation error: ' + e.message);
  }
}
function getCurrentPosition(vue) {
  if (sessionStorage.plusready === 'done') {
    wid = plus.geolocation.getCurrentPosition((p) => {
      console.log(index++);
      listenerShipments(p.coords.latitude + ',' + p.coords.longitude, vue);
      console.log('Geolocation\nLatitude:' + p.coords.latitude + '\nLongitude:' + p.coords.longitude + '\nAltitude:' + p.coords.altitude);
    }, (e) => {
      console.log('Geolocation error: ' + e.message);
    }, {maximumAge: 1000, enableHighAccuracy: true});
  }
}
function listenerShipments(point, vue) {
  //判断是否需要监听位置信息
  shipments.forEach((shipment) => {
    if (shipment.status === 'trans_status1_3') {
      setPointValueInfo(point, shipment, vue);
    }
  });
}
function addListenerShipment(shipment, vue) {

  let flg = false;
  shipments.forEach((item) => {
    if (shipment.id === item.id) {
      flg = true;
    }
  });
  if (!flg) {
    shipments.push(shipment);
    // if (!intervalId) {
    //   if (sessionStorage.plusready === 'done') {
    //     intervalId = window.setInterval(onPlusReady, 5000, vue);
    //   }
    //   //document.addEventListener('plusready', onPlusReady(vue), false);
    // }
    GeoListener(vue);
  }
}
function onPlusReady(vue) {
  // 使用百度地图地位模块获取位置信息
  console.log(new Date()+1);
  plus.geolocation.getCurrentPosition(function (p) {
    listenerShipments(p.coords.latitude + ',' + p.coords.longitude, vue);
    console.log(new Date()+2);
  }, function (e) {
    alert('Geolocation error: ' + e.message);
  }, {maximumAge: 1000, enableHighAccuracy: true});
}

function removeAllListenerShipment() {
  shipments = [];
  cancelGeo();
}
function removeListenerShipment(shipment) {
  shipments.forEach((item) => {
    if (shipment.id === item.id) {
      shipments.pop(shipment);
      if (!shipments.length) {
        removeAllListenerShipment();
      }
    }
  });
}
function batchAddListener(shipments, vue) {
  shipments.forEach((item) => {
    addListenerShipment(item, vue);
  });
}
function setPointValueInfo(point, listData, vue) {

  if (!PathItems.length) {
    vue.$axios.get('/SQLService/queryPathItems', {data: [{shipmentId: listData.id}]})
      .then((resp) => {
        PathItems = resp.data;
        saveTracingPointInfo(point, listData, resp.data, vue);
      });
  } else {
    saveTracingPointInfo(point, listData, PathItems, vue);
  }
}
function saveTracingPointInfo(point, listData, resp, vue) {
  if (resp.length) {
    let currentPoint = point.split(',');
    let pointData = {};
    let date = new Date();
    pointData.time = moment(date).format('YYYY-MM-DD HH:mm:ss');
    pointData.realCoordinate = point;
    pointData.shipmentHead = {id: listData.id};
    resp.forEach((item) => {
      let itemPoint = item.coordinate.split(',');
      let distance = Math.abs(getFlatternDistance(parseFloat(itemPoint[1]), parseFloat(itemPoint[0]), parseFloat(currentPoint[0]), parseFloat(currentPoint[1])));
      if (distance < distanceValue) {
        pointData.headGuid = item.guid;
        pointData.coordinate = item.coordinate;
        pointData.type1 = item.type1;
        let distanceDate = 0;
        if (listData.deliveryTime) {
          let deliveryTime = new Date(Date.parse((listData.deliveryTime).replace(/-/g, "/")));
          pointData.cost = moment(new Date(deliveryTime.getTime() + (item.costTime ? parseInt(item.costTime) : 0))).format('YYYY-MM-DD HH:mm:ss');
          distanceDate = Math.abs(date.getTime() - deliveryTime.getTime());
        } else {
          distanceDate = 0;
        }
        if (distanceDate < item.costTime) {
          pointData.status = arrivalStatus1;
        } else {
          pointData.status = arrivalStatus2;
        }
        PathItems.pop(item);
      }
    });
    vue.$axios.post('/TracingService/cascadeSave', [pointData]).then(() => {
    });
  }
}
function cancelGeo() {
  if (wid) {
    plus.geolocation.clearWatch(wid);
    wid = null;
  }
}
let EARTH_RADIUS = 6378137.0;    //单位M

let PI = Math.PI;

function getRad(d) {
  return d * PI / 180.0;
}
/**
 * approx distance between two points on earth ellipsoid
 * @param {Object} lat1
 * @param {Object} lng1
 * @param {Object} lat2
 * @param {Object} lng2
 */
function getFlatternDistance(lat1, lng1, lat2, lng2) {

  if (lat1 === lat2 && lng1 === lng2) {
    return 0;
  }
  let f = getRad((lat1 + lat2) / 2);
  let g = getRad((lat1 - lat2) / 2);
  let l = getRad((lng1 - lng2) / 2);
  let sg = Math.sin(g);
  let sl = Math.sin(l);
  let sf = Math.sin(f);

  let s, c, w, r, d, h1, h2;
  let a = EARTH_RADIUS;
  let fl = 1 / 298.257;

  sg = sg * sg;
  sl = sl * sl;
  sf = sf * sf;

  s = sg * (1 - sl) + (1 - sf) * sl;
  c = (1 - sg) * (1 - sl) + sf * sl;

  w = Math.atan(Math.sqrt(s / c));
  r = Math.sqrt(s * c) / w;
  d = 2 * w * a;
  h1 = (3 * r - 1) / 2 / c;
  h2 = (3 * r + 1) / 2 / s;

  return d * (1 + fl * (h1 * sf * (1 - sg) - h2 * (1 - sf) * sg));
}

function dealUnexpect(o,unexpNum,unexpStr){
  dealUnexpectLoop(o,o,'',unexpNum,unexpStr);
}

function dealUnexpectLoop(o,o1,s,unexpNum,unexpStr){
  //debugger;
  if(_.isObject(o)){
    _.forEach(o, function(value,key) {
      if(_.isObject(value)){
        if(_.isNumber(key)){
          dealUnexpectLoop(value,o1,s+'['+key+']',unexpNum,unexpStr);
        }else{
          dealUnexpectLoop(value,o1,s+'[\''+key+'\']',unexpNum,unexpStr);
        }
      }
      if(_.findIndex(unexpNum, function(o) { return o == key; })>=0){
        if(_.isNaN(value)||_.isNull(value)||_.isUndefined(value)||_.isNil(value)||value ==""){
          try{
            if(_.isNumber(key)){
              eval('o1'+s+'['+key+'] = 0;')
            }else{
              eval('o1'+s+'[\''+key+'\'] = 0;')
            }
          }catch(e){
          }
          
        }
      }

      if(_.findIndex(unexpStr, function(o) { return o == key; })>=0){
        if(_.isNaN(value)||_.isNull(value)||_.isUndefined(value)||_.isNil(value)){
          try{
            if(_.isNumber(key)){
              eval('o1'+s+'['+key+'] = \'\';')
            }else{
              eval('o1'+s+'[\''+key+'\'] = \'\';')
            }
          }catch(e){
          }
          
        }
      }
    });
  }
}

export {
  hasClass,
  addClass,
  removeClass,
  toggleClass,
  setContentHeight,
  getUserCompanyInfo,
  getOrganizationOpt,
  getVehicleOpt,
  GeoListener,
  cancelGeo,
  getFlatternDistance,
  removeListenerShipment,
  batchAddListener,
  removeAllListenerShipment,
  dealUnexpect
}
