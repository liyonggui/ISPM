import _ from 'lodash'

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
        code: 'value',
        label: 'label'
    }, params)
    if (options.key === '') {
        console.warn('translate: key is required')
        return false
    } else {
        let dicts = this.$store.state.sysDict

        let currentDict = dicts.filter(element => {
            return element.type == options.key
        })

        if (currentDict) {
            let results
            if (typeof options.value != 'number') {
                results = currentDict.filter(item => {
                    return item[options.code] == options.value
                })
            } else {
                results = currentDict.filter(item => {
                    return item[options.code] == options.value
                })
            }
            if (results.length) {
                let returnVal = []
                results.forEach((item) => {
                    returnVal.push(item[options.label])
                })
                return returnVal.join(',')
            }
            return ''
        }
        console.warn('translate: dist not found. key is:' + options.key)
        return false
    }
}

/**
 * 获取字典选项
 */
function getDictByKey(key) {
    let dicts = this.$store.state.sysDict
    return dicts.filter(element => {
        return element.type == key
    })
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

function install(Vue) {
  Vue.prototype.$translate = translate
  Vue.prototype.$getDictByKey = getDictByKey
}

export default {
  dictFormatter,
  translate,
  clearEmptyChildren,
  install
}
