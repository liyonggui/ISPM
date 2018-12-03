import config from './devconfig.js'
import base64 from 'src/utils/base64'
import {
    resourceFormat
} from 'src/utils/dataFormat'
/**
 * 系统登录
 */
function login(vue, params) {
    return vue.$axios.post('/login', params).then(function (response) {
        let token = response.token;
        localStorage.setItem('token', token);
        sessionStorage.setItem('token', token);
        vue.$router.push('/')
    })
}

function loginReload(vue, params) {
    return vue.$axios.post('/login', params).then(function (response) {
        let token = response.token;
        localStorage.setItem('token', token);
        sessionStorage.setItem('token', token);
        location.reload();
        vue.$router.push('/');
    })
}

/**
 * 系统登出
 */
function logout(vue,router) {

    return   vue.$axios.post('/logout', {}).then(function (response) {
        clearSession()
        sessionStorage.path = ''
        window.location.reload()
        router.replace('/login')
    })
}

/**
 * 清除 session 中的信息
 */
function clearSession() {
    localStorage.removeItem('token');
    sessionStorage.removeItem('token');

    localStorage.removeItem('userInfo');
    sessionStorage.removeItem('userInfo');
}

/**
 * 判断是否是登录状态
 * @return {Boolean} true false
 */
function isLogin() {
    return localStorage.getItem('token') ? true : false
}

/**
 * sso 登录
 */
function ssoLogin() {
    console.log('sso login');
}


/**
 * 获取短信验证码
 */
function getVerifySms(vue, tel) {
    let params = {
        'phone': tel
    }
    return vue.$axios.post('/sms', params).then(function (response) {
        if (response.data && response.code == "200") {
            return response.data
        } else {
            vue.$message.error({
                title: "错误",
                message: response.message
            })

        }
    }).catch(function (error) {
        console.log('error');
        console.log(error);
        if (_.isEmpty(error)) {
            vue.$message.error({
                title: "错误",
                message: "请求错误，请重新尝试!"
            })
        } else {
            vue.$message.error({
                title: "错误",
                message: error.exceptionMessage
            })
        }
        return error
    })
}

export {
    login,
    loginReload,
    logout,
    isLogin,
    ssoLogin,
    getCaptchaImage,
    clearSession,
    getVerifySms
}
