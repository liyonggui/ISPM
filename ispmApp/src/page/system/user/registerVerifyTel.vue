<template>
    <div class="register">
        <div class="head-panel">
            <nav-bar  title= "注册" left-arrow left-text="返回"  @click-left="toBack"/>  
    </div>
    <div  class="form">
        <div @click="showNumberKeyboard=true">
            <van-field label="手机号码" disabled required v-model="tel" type="tel" :error-message="telErrorMsg" placeholder="请输入手机号码" />
        </div>
        <van-field label="验证码" required v-model="sms"  placeholder="请输入短信验证码" :error-message="smsErrorMsg">
             <sms-timer slot="button" :disabled ="disabledSmsTimer" @run="getSms(tel)"/>
       </van-field>
        <van-number-keyboard :show="showNumberKeyboard" theme="custom" close-button-text="完成" @blur="showNumberKeyboard = false" @input="onInput" @delete="onDelete" />
    
    </div>
    <div class="btn-footer">
        <van-button class="register-btn" type="primary" :loading="submitButtonLoading" :disabled="submitButtonDisable" @click="handleSubmit" size="large">{{registerBtnText}}</van-button>
    </div>
</div>
</template>

<script>
import {
getVerifySms
} from '../../../config/login.js'
export default {
    data() {

        return {
 
            sms:"",
            tel: "",
 
            passwordErrorMsg: "",
            telErrorMsg: "",
            smsErrorMsg: "",
            disabledSmsTimer : true,
            submitButtonDisable: false,       
            showNumberKeyboard: false,
 
            validate: false,
            registerBtnText: '下一步',
            submitButtonLoading: false        
        };
    },
    computed: {},
    methods: {
        //返回上一页
        toBack(e) {
            this.$router.go(-1)
        },
 
        /*数字键盘*/
        onInput(value) {
            this.tel = this.tel + value;
        },
        onDelete() {
            this.tel = this.tel.slice(0, -1);
        },
       //获取短信
       getSms(tel)
       { 
           if(!this.disabledSmsTimer)
           {
             getVerifySms(this,tel).then(msg => {
                console.log('短信返回数据');
                console.log(msg);
            })
           };  
       },
        ////////////////////////////////////
        handleSubmit() {

            this.validate = true;
            let url = "/sms/check";
             //验证码校验
            if ( !this.sms) {
                this.$message({
                    message: "请输入验证码",
                    type: 'error'
                });
                this.validate = false;
            }
            //手机号校验
            if (this.telErrorMsg || !this.tel) {
                this.$message({
                    message: "请输入手机号",
                    type: 'error'
                });
                this.validate = false;
            }
 
            //校验数据通过后提交数据
            if (this.validate) {
                    this.submitButtonLoading = true;
                    let params = {
                        phone: this.tel,
                        code: this.sms 
                    };
                    this.$axios.post(url,  params).then((resp) => {
                        if (resp.success && resp.data && resp.code == "200") {
                            this.$router.push("/register?tel="+this.tel);
                        } else {
                            this.$message({
                                message: resp.message,
                                type: 'error'
                            })
                        }
                        this.submitButtonLoading = false;
                    }).catch((err) => {
                        this.$message.error({
                            message: '请求错误,请重新尝试'
                        })
                        this.submitButtonLoading = false;
                    })
               
            }
        },
        //监听返回按钮_按返回键后返回
        addEventBackButtonBack() {
            //监听返回按钮
            if (sessionStorage.plusready === "done") {
                plus.key.removeEventListener("backbutton", () => {
                    plus.runtime.quit();
                });
                plus.key.addEventListener("backbutton", () => {
                    this.toBack();
                });
            }
        }
    },
    watch: {       
     
        //手机号校验
        "tel": function (val) {
            var pattern = /(^1[3|4|5|7|8]\d{9}$)|(^09\d{8}$)/;
            if (!pattern.test(val)) {
                this.telErrorMsg = "手机号为空或格式不正确";
                this.disabledSmsTimer = true;
            } else {
                this.telErrorMsg = "";
                this.disabledSmsTimer = false;
            }
        },
    },

    mounted() {
        this.addEventBackButtonBack();
    }
}
</script>

<style lang="less" scoped>
 
.error {
    color: red;
    font-size: 0.1rem;
    position: absolute;
    left: 0;
    top: 100%;
    padding-left: 10px;
}

.register {
    height: 100%;
 
    .form {
        margin: 0.3rem auto;
        width: 95%;
        }
    }
   
    .btn-footer {
        width: 95%;
        margin: 0.1rem auto;
    }
 
</style>
<style lang="less">
   .register
   {
     .head-panel {
           background: white;
         .van-nav-bar  {
                &__title {
                        color: black ;
                    };
                &__text {
                        color: black;
                    }
               .van-icon {
                        color: black;
                    }

            }
          .van-hairline--bottom{
                &::after {
                        border-bottom-width: 0px;
                }
         }
 
         }
   }
</style>

