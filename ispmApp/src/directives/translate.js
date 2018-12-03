/**
* 字典翻译 指令
*/
import _ from 'lodash'

let translate = {}

translate.install = function(Vue, store) {
  Vue.directive('translate', {
    inserted: function (el, binding, vnode, oldVnode) {
      let vue = vnode.context;
      let item = binding.value;
      let Dicts = vue.$store.getters.getDict
      let needRequest = []
      if (!Dicts[item['category']]) {
        needRequest.push(item['category'])
      }
      let setDictionData = vue.$store._actions.setDict[0]
      if (needRequest.length > 0) {
        vue.$axios.get('/DictionaryService/queryByCode', {data: [{where: {and: [{code: {in: needRequest}}]}}]}).then(function (resp) {
          let responsedata = []
          _.forIn(resp.data, function (value, key) {
            responsedata.push({
              key: key,
              value: value
            })
          })
          setDictionData(responsedata)
          translate(resp.data)
        })
      } else {
        translate(Dicts)
      }

      function translate(data) {
        _.forEach(data[item['category']], function(i) {
          if(item.value == i.code) {
            el.innerText = i.label
          }
        })
      }
    }
  })
}

export default translate
