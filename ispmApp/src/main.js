import Vue from 'vue'

import VueRouter from 'vue-router'
import Vuex from 'vuex'
//ElementUI+I18N
import VueI18N from 'vue-i18n';
import elLangEN from 'element-ui/lib/locale/lang/en';
import elLangZH from 'element-ui/lib/locale/lang/zh-CN';
import localLangEN from './i18n/EN';
import localLangZH from './i18n/ZH';
import ElementUI from 'element-ui'

import Vant from 'vant';
import 'vant/lib/index.css';
import  'src/assets/fonts/Iconfont/iconfont.css';

import VueTouch from 'vue-touch'
import {router} from './router/router.js'
import storeConfig from './vuex/store.js'
import {install} from './config/axios'
import ComponentsRegister from './config/componentsRegister.js'
import directives from './directives'
import {initPermission} from './config/permissionConfig'
import App from './App.vue'

import {listenPlusReady} from './config/plusReady';
 
import VueClipboard from 'vue-clipboard2';

import dictionary from './config/dictionary'
import bizDictionary from './config/biz-dictionary'

import 'src/page/svg/styles/index.less';
import VueDND from 'awe-dnd'
import VueEvents from 'vue-event-handler'
import touch from 'vue-directive-touch';
import tile from 'src/page/formdesigner/components/tile';

Vue.use(touch);
Vue.use(VueDND)
Vue.use(VueEvents)

Vue.component('tile', tile)

// install vue plugin
Vue.use(VueI18N);
Vue.use(VueTouch, {name: 'v-touch'})
Vue.use(VueClipboard)
 
const messages = {
  en: Object.assign(elLangEN, localLangEN),
  zh: Object.assign(elLangZH, localLangZH)
};
const i18n = new VueI18N({
  locale: localStorage.language ? localStorage.language : 'zh',
  fallbackLocale: 'zh',
  messages
});
Vue.use(ElementUI, {
  i18n: (key, value) => i18n.t(key, value)
});

Vue.use(Vant);
Vue.use(Vuex)
// 创建store之前必须执行 Vue.use(Vuex)，故在主文件中声明store，文件只导出配置
const store = new Vuex.Store(storeConfig)
router.onReady(function () {
  Vue.use(install, router)
  Vue.use(dictionary)
  Vue.use(bizDictionary)
})

Vue.use(VueRouter);


//自定义指令
Vue.use(directives, store)
//权限配置文件
Vue.use(initPermission, store)
 
ComponentsRegister(Vue)
listenPlusReady(Vue, router);

Vue.config.productionTip = false //disabled console productionTip
Vue.config.errorHandler = function (err, vm, info) {
  console.log("异常:"+err)
}
let app = new Vue({
  el: '#app',
  store,
  i18n,
  router,
  template: '<App/>',
  components: {App}
})



