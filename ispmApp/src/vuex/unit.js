/**
 * Created by xining.lao on 12/1/2016.
 */
import {
  mapState,
  mapGetters
} from "vuex"; //缓存数据源
let store = ''

function getStore(vue, getters) {
  let dataMap = {}
  const state = vue.$store.getters;
  var tempstate = {};
  if (getters instanceof Array) {
    getters.forEach(index) {
      dataMap[index] = ""
    }
  } else if (typeof getters == "string") {
    dataMap[getters] = ""
  } else {
    console.error("VueXnit:目前getters只支持array和string");
  }
  for (let getter in dataMap) {
    try {
      dataMap[getter] = state[getter]
    } catch (e) {
      console.error("VueXunit:" + e)
    }
  }

  return dataMap
}
let unit = {
  getValueByGetters(vue, module) {
    return getStore(vue, module)
  }
}
export default unit
