import Axios from 'axios'
import config from './devconfig.js'
import {clearSession, isLogin, loginReload} from './login.js'
import base64 from 'src/utils/base64'
import {logout} from "../config/login";
import moment from 'moment';
import {Toast} from 'vant'

/**
 * vue 安装 axios 配置方法
 * 调用Vue.use 可执行该方法
 * 目的是将axios 挂载到全局的实例中
 */
function install(Vue, router) {
    const axios = Axios.create({
        baseURL: config.baseURL
    })

    const opsaxios = Axios.create({
        baseURL: config.opsbaseURL
    })
    const weatheraxios = Axios.create({
        baseURL: config.weatherURL
    })

    //设置超时时间10s
    axios.defaults.timeout = 60000;
    Vue.prototype.$axios = axios
    Vue.prototype.$opsaxios = opsaxios;
    Vue.prototype.$weatheraxios = weatheraxios;
    interceptors(axios, Vue, router)
}

/**
 * 全局返回数据拦截
 */
function interceptors(axios, Vue, router) {
    let v = new Vue();
    axios.interceptors.request.use(function (config) {
        // 每次请求都在header中添加token，token来源于sessionStorage
        if (sessionStorage.getItem('token')) {
            config.headers["token"] = sessionStorage.getItem('token')
        }
        if (config.data) {
            if (config.method === 'get' || config.method === 'delete') {
                for (let i = 0; i < config.data.length; i++) {
                    if (typeof config.data[i] == "object" && !(config.data[i] instanceof Array))
                        config.data[i] = JSON.stringify(config.data[i])
                }
                config.url += "?param=" + encodeURIComponent(JSON.stringify(config.data))
                // config.url += '&_d=' + new Date().getTime()
            }
        }
        return config;
    }, function (error) {
        // Do something with request error
        return Promise.reject(error);
    });

    // 截获返回数据，对请求状态进行统一处理
    axios.interceptors.response.use(resp => {
        let respData = resp.data
        if ('string' === typeof (respData)) {
            return respData
        } else {
            if (respData.ok && '0' === respData.code) {
                if (resp.config._cache) {
                    let key = resp.config.url.replace(resp.config.baseURL, '') + resp.config.data;
                    let caches = localStorage.cache ? JSON.parse(localStorage.cache) : {};
                    let cache = caches[resp.config._cache] ? caches[resp.config._cache] : {};
                    cache[key] = respData.data;
                    caches[resp.config._cache] = cache;

                    localStorage.cache = JSON.stringify(caches)
                }
                return respData.data
            } else if ('999' === respData.code) {
                // v.$message.error(respData.message)
                // logout(router)
                    v.$message.warning("长期未连接，将重新加载页面")
                    let param = JSON.parse( localStorage.getItem("userInfo" ))
                    loginReload(v,param)
                     
            } else {
                v.$message.error(respData.message)
                return Promise.reject(respData.data)
            }
        }
    }, err => {
         
        //离线状态切当前请求已开启缓存，则返回缓存里的内容
        if (sessionStorage.offLine && (err.config._cache || err.config._queue)) {
            if (err.config._cache) {
                let key = err.config.url.replace(err.config.baseURL, '') + err.config.data;
                let caches = localStorage.cache ? JSON.parse(localStorage.cache) : {};
                let cache = caches[err.config._cache] ? caches[err.config._cache] : {};

                if (cache[key]) {
                    return cache[key];
                } else {
                    let resp = err.response

                    if (!resp) {
                        v.$message.error(err.message)
                        console.warn(err.stack)
                    } else {
                        if (resp.data && resp.data.error) {
                            v.$message.error(resp.data.error)
                            // store.commit('setShowLoginModalFlag', true)
                            console.warn(resp.data.error.stack)
                        }
                    }
                    return Promise.reject(resp)
                }
            }
            if (err.config._queue) {
                let queue = localStorage.queue ? JSON.parse(localStorage.queue) : [];
                queue.push({
                    page: err.config._queueConfig.page,
                    action: err.config._queueConfig.action,
                    url: err.config.url.replace(err.config.baseURL, ''),
                    data: err.config.data,
                    updateDate: moment().format('YYYY-MM-DD HH:mm:ss')
                });
                localStorage.queue = JSON.stringify(queue);
                setTimeout(() => {
                    Toast.success('已加入到离线队列');
                }, 1000);
                return null
            }
        } else {
            let resp = err.response
            if (!resp) {
                if(err.message == "Network Error")
                {
                    v.$message({
                        message: "当前网络不可用，请检查!",
                        center: true,
                        duration: 3000,
                        showClose: true,
                        type: "error"
                    });
                }
                else
                {
                    Toast.fail(err.message)
                }
                console.warn(err.stack)
            } else {
                if (resp.data && resp.data.error) {
                    v.$message.error(resp.data.error)
                    // store.commit('setShowLoginModalFlag', true)
                    console.warn(resp.data.error.stack)
                }
            }
            return Promise.reject(resp)
        }
    })
}

export {
    install,
    interceptors
}
