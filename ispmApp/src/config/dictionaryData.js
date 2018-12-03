/**
 * Created by xining.lao on 3/14/2017.
 */
import _ from 'lodash'
let dictionary = {}
dictionary.install = function (Vue) {
  Vue.prototype.$dict = function (transformarr) {
    let Dicts = this.$store.getters.getDict,
      needRequest = [],
      me = this
    _.forEach(transformarr, function (item) {
      if (!Dicts[item['category']]) {
        needRequest.push(item['category'])
        Dicts[item['category']]=[]
      }
    })
    let setDictionData = this.$store._actions.setDict[0]
    if (needRequest.length > 0) {
      this.$axios.get('/DictionaryService/queryByCode', {data: [{where: {and: [{code: {in: needRequest}}]}}]}).then(function (resp) {
        let responsedata = []
        _.forIn(resp.data, function (value, key) {
          responsedata.push({
            key: key,
            value: value
          })
        })
        setDictionData(responsedata)
        transform(me, transformarr, this.$store.getters.getDict)
      }.bind(this))
    } else {
      transform(me, transformarr, this.$store.getters.getDict)
    }
  }
};

function transform(target, transformarr, data) {
  let _this = target
  _.forEach(transformarr, function (item) {
    if (item['code']) {
      let tempdata = {}
      _.forEach(data[item['category']], function (item) {
        tempdata[item['code']] = item
      })
      _this[item['currentkey']] = tempdata[item['code']]['label']
    } else {
      _this[item['currentkey']] = data[item['category']]
    }
  })
}

export default dictionary
