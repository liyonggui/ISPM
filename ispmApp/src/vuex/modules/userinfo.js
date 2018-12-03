import base64 from 'src/utils/base64'

export default {
  state: {
    userInfo: {},
    users: []
  },
  mutations: {
    setUserInfo(state, userInfo) {
      state.userInfo = userInfo
    },
    setUsers(state, users) {
      state.users = users
      sessionStorage.setItem('users', base64.encode(JSON.stringify(users)))
    }
  },
  actions: {
    setUserInfo({
                  commit
                }, vue) {
      return vue.$axios.get('/UserService/getCurrentUser').then((resp) => {
        commit('setUserInfo', resp.data)
      })
    },
    setUsers({
               commit
             }, vue) {
      return vue.$axios.get('/UserService/query').then((resp) => {
        commit('setUsers', resp.data)
      })
    }
  },
  getters: {
    getUserInfo: state => {
      if (state.userInfo && state.userInfo.id) {
        return state.userInfo
      } else {
        return JSON.parse(sessionStorage.getItem('userInfo'))
      }
    },
    getUserName: state => {
      return (state.userInfo || {}).userName
    },
    getUsers: state => {
      return state.users
    }
  }
}
