export default {
    state: {
        orgInfo: {}
    },
    mutations: {
        setOrgInfo(state, orgInfo) {
          state.orgInfo = orgInfo
        }
    },
    actions: {
        setOrgInfo({commit},{vue ,clientId}) {
          return vue.$axios.get('/OrganizationService/get',{
              data:[clientId]
          }).then((resp) => {
            commit('setOrgInfo', resp.data)
          })
        }
    },
    getters: {
        getOrgInfo: state => {
          if (state.orgInfo) {
            return state.orgInfo
          }
        }
    }
}