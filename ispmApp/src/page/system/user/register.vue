<template>
<div class="register">
        <div class="head-panel">
          <nav-bar  title= "注册" left-arrow left-text="返回"  @click-left="toBack"/>  
 
    </div>
    <div class="form">
        <van-field label="手机号码" disabled required v-model="tel" type="tel" :error-message="telErrorMsg" placeholder="请输入手机号码" />
        <van-field  label="密码" required v-model="password" :type="passwordFieldType" placeholder="请输入密码" :error-message="passwordErrorMsg">
         <van-icon slot="button" :name = "passwordIcon" @click="passwordView"/> 
        </van-field> 
         <van-field label="邀请码(选填)"  v-model="inviteCode"  placeholder="请输入邀请码" /> 
    </div>
    <div class="btn-footer">
        <van-button class="register-btn"  type="primary" :loading="submitButtonLoading" :disabled="submitButtonDisable" @click="handleSubmit" size="large">{{registerBtnText}}</van-button>
    </div>
</div>
</template>

<script>
import md5 from 'md5'
import {
    login,getVerifySms
} from '../../../config/login.js'
export default {
    data() {

        return {
            password: "",
            tel: "",
            inviteCode:"",
            passwordErrorMsg: "",
            telErrorMsg: "",
            submitButtonDisable: false,       
            validate: false,
            registerBtnText: '注册',
            submitButtonLoading: false   ,
            passwordIcon:"password-not-view" ,
            passwordFieldType :"password",
        };
    },
    computed: {},
    methods: {
        //返回上一页
        toBack(e) {
            this.$router.go(-1)
        },
        passwordView()
        {
            if(this.passwordFieldType=="password")
            {
                this.passwordIcon = "password-view";
                this.passwordFieldType = "text";
            }
            else
            {
                this.passwordIcon = "password-not-view";
                this.passwordFieldType = "password";
            }
        },
        handleSubmit() {

            this.validate = true;
            let url = "/register"
            //密码校验
            if (this.passwordErrorMsg || !this.password) {
                this.$message({
                    message: "请输入密码",
                    type: 'error'
                });
                this.validate = false;
            }
           
            //校验数据通过后提交数据
            if (this.validate) {
                   this.submitButtonLoading = true;
                    let params = {
                        phone: this.tel,
                        password:md5(md5(this.password)),
                        invitecode: this.inviteCode 
                    };
                    this.$axios.post(url,  params).then((resp) => {
                        if (resp.success && resp.data && resp.code == "200") {
                            let msg = '注册成功'
                            this.$message({
                                message: msg,
                                type: 'success'
                            })
                            let loginParam = 
                            { "type": "1",
                              'username':params.phone,
                              'password':params.password}
                            //登录
                             login(this, loginParam).then(msg => {
                            })
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
        },
 
    },
    watch: {
       
        //密码校验
        "password": function (val) {
            if (val.length < 6 || val.length > 30) {
                this.passwordErrorMsg = "密码长度不能少于6位或大于30位";
            } else {
                this.passwordErrorMsg = "";
            }
        },

  
    },

    mounted() {
        this.addEventBackButtonBack();
       if (this.$route.query.tel) {
            this.tel = this.$route.query.tel;
        }
     
 
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
