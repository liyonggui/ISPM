/**
* 权限指令
*/
let permission = {}

permission.install = function(Vue, store) {
  Vue.directive('permission', {
    inserted: function (el, binding, vnode) {
        let operationPermission = store.state.operationPermission
        if ('string' === typeof (binding.value)) {
            let filterPermission = operationPermission.filter(item => {
                return item.permission === binding.value
            })
            if (0 === filterPermission.length) {
                el.remove()
            }
        }
    }
})
}

export default permission
