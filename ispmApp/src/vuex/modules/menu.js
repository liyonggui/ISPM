export default {
  state: {
    menu: []
  },
  mutations: {
    setMenu (state, menu) {
      state.menu = menu
    }
  },
  actions: {
    setMenu ({commit}, menu) {
      commit('setMenu', menu)
    }
  },
  getters: {
    getMenu: state => {
      return state.menu
    }
  }
}
