/**
 * 字典相关工具类
 * add by jinan 2017-5-5
 */

function dictFormatter(source) {
    let dicts = {}
    if (source && source.length) {
      source.forEach((item) => {
        addDict(item, dicts)
      })
    }
    return dicts
  }
  
  function addDict(item, dicts) {
    if (item.children && item.children.length) {
      clearEmptyChildren(item)
      dicts[item.code] = item.children
      item.children.forEach(childItem => {
        if (childItem.children && childItem.children.length) {
          addDict(childItem, dicts)
        }
      })
    }
  }
  
  /**
   * 字典翻译方法
   * 未找到对应翻译，返回false
   */
function translate(params) {
    let options = Object.assign({
        key: '',
        value: '',
        code: 'id'
    }, params)
    if (options.key === '') {
        console.warn('translate: key is required')
        return false
    } else {
        let dicts = this.$store.state.bizDict

        let currentDict = dicts[options.key]

        if (currentDict) {
            let results = currentDict.filter(item => {
                return item[options.code] == options.value
            })
            if (results.length) {
                return results[0]
            }
            return {}
        }
        console.warn('translate: dist not found. key is:' + options.key)
        return false
    }
}

/**
 * 获取字典选项
 */
function getDictByKey(key) {
    let dicts = this.$store.state.bizDict
    return dicts[key]
}

/**
 * 清除字典中空的子集
 */
function clearEmptyChildren(dict) {
    if (dict.children) {
        if (dict.children.length === 0) {
            dict.children = undefined
        } else {
            dict.children.forEach(childDict => {
                clearEmptyChildren(childDict)
            })
        }
    }
}

function translateMulti(params) {
    if (!typeof (params.key) || !typeof (params.value)) {
        console.warn('translateMulti: key or value is required')
        return false
    }
    let options = Object.assign({
        key: '',
        value: '',
        code: 'id'
    }, params)

    let dicts =  this.$store.state.bizDict
    let dictResultSet = dicts[options.key]

    if (dictResultSet.length > 0) {
        let valueArr = options.value.split(',')
        let results = []
        valueArr.forEach(item => {
            let resultDict = dictResultSet.filter(element => {
                return element[options.code] === item
            })
            if (resultDict.length > 0) {
                results.push(resultDict[0])
            }
        });
        return results
    } else {
        console.warn('translateMulti: dictionary is not exist')
        return false
    }
}

function install(Vue) {
    Vue.prototype.$bizTranslate = translate
    Vue.prototype.$bizTranslateMulti = translateMulti
    Vue.prototype.$getBizDictByKey = getDictByKey
}

export default {
    dictFormatter,
    translate,
    clearEmptyChildren,
    install
}