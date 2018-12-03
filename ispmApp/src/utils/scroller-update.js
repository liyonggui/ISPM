import Ps from 'perfect-scrollbar'

export default function (el, time) {
  setTimeout(() => {
    Ps.update(el)
  }, time || 300)
}
