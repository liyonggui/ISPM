import Permission from './permission'
import Scroll from './scroll'
import Translate from './translate'

let directives = {}

directives.install = function(vue, store) {
  Permission.install(vue, store)
  Scroll.install(vue, store)
  Translate.install(vue, store)
}

export default directives;
