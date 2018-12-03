import _ from 'lodash'
import base64 from 'src/utils/base64'
import {
  resourceFormat
} from 'src/utils/dataFormat'

export default {
  state: {
    resource: [],
    operation: {}
  },
  mutations: {
    setResource(state, resource) {
      state.resource = resource
    },
    setOperation(state, operation) {
      state.operation = operation
    }
  },
  actions: {
    setResource({
      commit
    }, vue) {
      return vue.$axios.get('/AuthorityService/getAcountResource', {
        data: [{
          order: {
            'sort': '1'
          }
        }]
      }).then(function (response) {
        commit('setResource', response.data || [])
      })
    },
    setOperation({
      commit
    }, operation) {
      commit('setOperation', operation)
    }
  },
  getters: {
    getResource: state => {
      return state.resource
    },
    getOperation: state => {
      let operation = state.operation
      if (!_.isEmpty(operation))
        return operation
      else
        return (state.operation = resourceFormat(state.resource))
    }
  }
}
