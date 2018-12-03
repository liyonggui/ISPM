import page from '../components/page.vue';
import header from '../components/header.vue';
  
import uploader from '../components/uploader.vue'
import uploaderIDCard from '../components/uploaderIDCard.vue'
 
import noData from '../components/noData.vue';
import smsTimer from '../components/smsTimer.vue';
import navbar from '../components/navbar.vue';
 
export default function (Vue) {
  Vue.component('tms-page', page);
  Vue.component('tms-header', header);
  
  Vue.component('uploader', uploader);
  Vue.component('uploader-idCard', uploaderIDCard);
 
  Vue.component('no-data', noData);
  Vue.component('sms-timer', smsTimer);
  Vue.component('nav-bar', navbar);
 
}
