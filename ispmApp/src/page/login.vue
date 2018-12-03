<template>
<div class="login c_flex c_direction_v" @keyup.enter="handleSubmit">
    <div class="logo c_flex c_direction_v c_j_center c_a_center ">
        <!-- <img src="../assets/login/loginbg.png"> -->
        <van-row style="font-size:0.3rem">智慧项目管理平台</van-row>
    </div>
    <div class="form">
        <div class="form-item c_flex c_j_center c_a_center">

            <van-field clearable left-icon="contact" placeholder="请输入用户名" v-model="loginForm.account">
            </van-field>
        </div>
        <!-- <van-number-keyboard :show="showNumberKeyboard" theme="custom" close-button-text="完成" @blur="showNumberKeyboard = false" @input="onInput" @delete="onDelete" /> -->
        <div class="form-item c_flex c_j_center c_a_center">

            <van-field left-icon="icon-suo" clearable :placeholder="passwordPlaceHolder" :type="passwordFieldType" v-model="loginForm.pwd" @click-icon="onShowPassword">
                <van-icon slot="icon" :name="passwordIcon" />
            </van-field>
            <!-- <div class="getSms" v-if="smsLoginFlag">
                    <sms-timer :disabled="disabledSmsTimer" @run="getSms(loginForm.account)" />
                </div> -->
        </div>
        <!-- <div class="smsLogin c_flex_1 c_flex c_a_center c_j_center" @click="smsLogin">
                {{smsLoginText}}
            </div> -->

        <van-button class="login-btn" :disabled="loginStatus" type="primary" @click="handleSubmit" size="large">
            {{loginBtnText}}
        </van-button>

    </div>
    <!-- <div class="register c_flex_1 c_flex c_a_center c_j_center">
        <router-link to="/registerVerifyTel">立即注册 <van-icon  style="font-size: 11px;" name="arrow"/></router-link>
    </div> -->
</div>
</div>
</template>

<script>
import {
    login,
    getVerifySms
} from "../config/login.js";
import md5 from "md5";
// import { mapActions } from "vuex";
import moment from "moment";

const set = localStorage.setItem.bind(localStorage);
const del = localStorage.removeItem.bind(localStorage);

// 存放服务器返回的错误消息
let serverMessage = "";

export default {
    data() {
        return {
            sessionId: "",
            loginForm: {
                account: "superadmin",
                pwd: "admin1"
            },
            loginBtnText: "登录",
            loginBtnDisabled: false,
            // loginStatus: false,
            saveLg: false,
            sessionId: "",
            codeSrc: "",
            checked: true,

            passwordFieldType: "password",
            passwordIcon: "password-not-view",
            passwordPlaceHolder: "请输入密码",

            //   smsLoginText: "短信验证码登录",
            //   smsLoginFlag: false,
            //   disabledSmsTimer: true,
            //   getSmsText: "获取",
            //   showNumberKeyboard: false
        };
    },
    computed: {
        // 切换登录按钮状态
        loginStatus: {
            get() {
                return this.loginBtnDisabled;
            },
            set(status) {
                this.loginBtnDisabled = status;
                this.loginBtnText = status ? "登录中……" : "登录";
            }
        }
    },
    methods: {
        onShowPassword() {
            if (this.passwordFieldType == "password") {
                this.passwordFieldType = "text"
                this.passwordIcon = "password-view"
            } else {
                this.passwordFieldType = "password"
                this.passwordIcon = "password-not-view"
            }

        },
        handleSubmit() {
            let loginType;
            let password;
            serverMessage = "";
            this.loginStatus = !this.loginStatus;

            password = this.loginForm.pwd;
            //登录类型
            //   if (this.smsLoginFlag) {
            //     //验证码登录
            //     loginType = "2";
            //     password = this.loginForm.pwd;
            //   } else {
            //     //密码登陆
            //     loginType = "1";
            //     password = this.loginForm.pwd;
            //   }
            let params = {
                // "type": loginType,
                loginName: this.loginForm.account,
                password: password
            };

            if (sessionStorage.plusready === 'done') {
                setTimeout(() => {
                    /**
                     * 获取推送服务所需要的clientid
                     * 并在登录app端时将cid存储到用户信息中
                     *  */
                    params.cid = plus.push.getClientInfo().clientid
                    params.token = plus.push.getClientInfo().token

                    login(this, params).then(msg => {

                        localStorage.setItem("userInfo", JSON.stringify(params))
                        console.log("登录返回数据");
                        // console.log(msg);
                        // if (msg != null && (msg.data == 3 || msg.data == null)) {

                        // }
                        // if (serverMessage = msg) {
                        //     localStorage.removeItem('loginName');
                        // } else {
                        //     //向后台发送当前登录人的设备信息。
                        //     //   this.sendUserMsg();
                        // }

                    }).finally(resp => {
                        this.loginStatus = false
                    });
                }, 500);
            } else {
                login(this, params).then(msg => {
                    localStorage.setItem("userInfo", JSON.stringify(params))
                    console.log("登录返回数据");
                }).finally(resp => {
                    this.loginStatus = false
                });
            }
        },

        // //向后台发送设备信息方法。
        // sendUserMsg: function() {
        //   if (sessionStorage.plusready === "done") {
        //     console.log("发送");
        //     console.log(plus.device);
        //     console.log(plus.device.imei);
        //     console.log(plus.os.language);
        //     console.log(plus.os.version);
        //     console.log(plus.os.name);
        //     console.log(plus.os.vendor);
        //     let url = "/ClientService/terminalLog";
        //     let param = {};
        //     let browser = {}; //用来存储机型对象
        //     browser["language"] = plus.os.language;
        //     browser["version"] = plus.os.version;
        //     browser["name"] = plus.os.name;
        //     browser["vendor"] = plus.os.vendor;

        //     param["msg"] = plus.device.model;
        //     param["imei"] = plus.device.imei; //设备的IMEI
        //     param["browser"] = JSON.stringify(browser);
        //     param["app"] = plus.os.name.toLocaleUpperCase();
        //     (param["logTime"] = moment(new Date())
        //       .add("2", "h")
        //       .format("YYYY-MM-DD HH:mm:ss")),
        //       console.log(param);
        //     this.$axios
        //       .post(url, [param])
        //       .then(resp => {
        //         console.log(resp);
        //       })
        //       .catch(e => {
        //         console.log("向后台发送机型异常");
        //       });
        //   }
        // },

        //短信验证码登录
        // smsLogin() {
        //   if (!this.smsLoginFlag) {
        //     this.smsLoginFlag = true;
        //     this.passwordIcon = "duanxin";
        //     this.passwordPlaceHolder = "请输入短信验证码";
        //     this.smsLoginText = "使用密码登录";
        //     this.passwordFieldType = "text";
        //   } else {
        //     this.smsLoginFlag = false;
        //     this.passwordIcon = "suo";
        //     this.passwordPlaceHolder = "请输入密码";
        //     this.smsLoginText = "使用短信验证码登录";
        //     this.passwordFieldType = "password";
        //   }
        // },
        //获取短信
        // getSms(tel) {
        //   if (!this.disabledSmsTimer) {
        //     getVerifySms(this, tel).then(msg => {
        //       console.log("短信返回数据");
        //       console.log(msg);
        //     });
        //   }
        // },
        /**/
        /*数字键盘*/
        // onInput(value) {
        //   this.loginForm.account = this.loginForm.account + value;
        // },
        // onDelete() {
        //   this.loginForm.account = this.loginForm.account.slice(0, -1);
        // },

        //监听返回按钮_按返回键后关闭
        addEventBackButtonClose() {
            if (sessionStorage.plusready === "done") {
                //监听返回按钮
                plus.key.removeEventListener("backbutton", () => {
                    this.toBack();
                });
                plus.key.addEventListener("backbutton", () => {
                    if (this.showNoticeMsgDetail) {
                        this.showNoticeMsgDetail = !this.showNoticeMsgDetail;
                    } else {
                        plus.runtime.quit();
                    }
                });
            }
        }
    },
    //   watch: {
    //     "loginForm.account"(val) {
    //       var pattern = /(^1[3|4|5|7|8]\d{9}$)|(^09\d{8}$)/;
    //       if (!pattern.test(val)) {
    //         this.disabledSmsTimer = true;
    //       } else {
    //         this.disabledSmsTimer = false;
    //       }
    //     }
    //   },
    mounted() {
        this.addEventBackButtonClose();
        if (JSON.parse(localStorage.getItem("userInfo"))) {
            let userInfo = JSON.parse(localStorage.getItem("userInfo"))
            let params = {
                loginName: userInfo.loginName,
                password: userInfo.password
            };
            login(this, params).then(msg => {
                console.log("登录返回数据");
            }).catch(err => {

            }).finally(resp => {
                this.loginStatus = false
            });
        }
    },
    created() {
        {
            if (this.$store.state.sysDict.length > 0) { // 判断是否已经刷新
                return window.location.reload()
            }
        }

    },
};
</script>

<style lang="less">
.login {
    height: 100%;
    background-color: rgb(36, 36, 36);
    background-image: url("../assets/login/loginbg.png");
    background-repeat: no-repeat;
    background-size: 160% 100%;

    .logo {
        margin-top: 1rem;
        height: 2rem;
        color: white;

        img {
            width: 1.5rem;
        }

        h2 {
            margin: 0;
            text-align: center;
            color: #fff;
        }
    }

    .form {
        width: 90%;
        margin: 0 auto;

        // .mint-field-core {
        //   background: none;
        // }
        // .mint-cell-wrapper {
        //   background: none;
        // }
        // .img-icon {
        //   margin-left: 0.1rem;
        //   height: 0.2rem;
        // }
        .login-btn {
            border-radius: 0.02rem;
            margin-top: 0.1rem;
        }
    }

    .van-button--primary {
        background: linear-gradient(rgb(76, 150, 255), #3388ff);
        border: 1px solid #3388ff;
    }

    //     .smsLogin {
    //       opacity: 0.9;
    //       font-size: 0.15rem;
    //       float: right;
    //       margin-top: 0.15rem;
    //       margin-bottom: 0.15rem;
    //       color: #3e9fe1;
    //     }
    //   }
    //   .register {
    //     opacity: 0.9;
    //     color: black;
    //     font-size: 0.15rem;
    //     a {
    //       margin-top: 0.4rem;
    //       text-decoration: none;
    //       color: black;
    //     }
    //   }
    //   .img {
    //     width: 40%;
    //     height: 100%;
    //   }
    //   .getSms {
    //     margin-right: 0.2rem;
    //     color: orangered;
    //     font-size: 0.15rem;
}
</style>
