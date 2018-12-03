/**
* scroll 指令
*/
import Ps from 'perfect-scrollbar'

let scroll = {}

scroll.install = function(Vue, store) {
  Vue.directive('scroll', {
    inserted: function (el, binding, vnode, oldVnode) {
      let option = undefined
      if(binding.value) {
        option = binding.value
      }
      let node = el
      if(option && option.class) {
        node = el.querySelector("." + option.class)
      }
      node.style.position = "relative"
      Ps.initialize(node, option);
    },
    update: function (el, binding) {
      let option = undefined
      if(binding.value) {
        option = binding.value
      }
      let node = el
      if(option && option.class) {
        node = el.querySelector("." + option.class)
      }
      // node.scrollTop = 0
      Ps.update(node);
    },
    componentUpdated: function (el, binding) {
      let option = undefined
      if(binding.value) {
        option = binding.value
      }
      let node = el
      if(option && option.class) {
        node = el.querySelector("." + option.class)
      }
      // node.scrollTop = 0
      Ps.update(node);
    },
    unbind: function (el, binding, vnode, oldVnode) {
      let option = undefined
      if(binding.value) {
        option = binding.value
      }
      let node = el
      if(option && option.class) {
        node = el.querySelector("." + option.class)
      }
      if(node) {
        Ps.destroy(node);
      }
    }
  })
}

export default scroll;
