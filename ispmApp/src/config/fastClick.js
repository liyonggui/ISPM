/**
 * fastClick
 *
 * @author xiang.li
 * @date 2017/11/15
 */
import Fastclick from 'tiger-fastclick';
function fastClick() {
  document.addEventListener('DOMContentLoaded', function(){
    Fastclick.attach(document.body);
  },false)
}

export {
  fastClick
}
