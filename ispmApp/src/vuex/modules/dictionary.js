import DictUtil from 'src/config/dictionary.js'
export default {
  state: {
    dicts: {},
  },
  mutations: {
    setDicts(state, dicts) {
      Object.keys(dicts).forEach((key) => {
        state.dicts[key] = dicts[key]
      })
    }
  },
  actions: {
    setDicts({
      commit
    }, vue) {
      return vue.$axios.get('/DictionaryService/query').then((response) => {
        commit('setDicts', DictUtil.dictFormatter(response.data))
      })
    }
  },
  getters: {
    getDicts: state => {
      return state.dicts
    }
  }
}
