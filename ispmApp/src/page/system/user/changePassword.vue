<template>
    <div class="userInfo">
        <nav-bar left-arrow @click-left="toBack" :title="$t('myInfo.changePassword')" />
        <div class="form">
            <van-panel>
                <van-field :label="$t('myInfo.userName')" disabled :value="accountInfo.loginName" />
                <van-field :label="$t('changePassword.oldPassword')" required v-model="oldPassword" type="password" :placeholder="$t('changePassword.oldPasswordPlaceholder')" :error-message="oldPasswordErrorMsg">
                </van-field>
                <van-field :label="$t('changePassword.newPassword')" required v-model="newPassword" type="password" :placeholder="$t('changePassword.newPasswordPlaceholder')" :error-message="newPasswordErrorMsg">
                </van-field>
                <van-field :label="$t('changePassword.confirmPassword')" required v-model="confirmPassword" type="password" :placeholder="$t('changePassword.confirmPasswordPlaceholder')" :error-message="confirmPasswordErrorMsg">
                </van-field>
            </van-panel>
        </div>
        <div class="btn-footer">
            <van-button class="handle-btn" :loading="submitButtonLoading" :disabled="submitButtonDisable" @click="handleSubmit" size="large">{{registerBtnText}}</van-button>
        </div>
    </div>
</template>

<script>
import md5 from "md5";
import { login, getVerifySms } from "../../../config/login.js";
export default {
    data() {
        return {

            submitButtonDisable: false,
            validate: false,
            registerBtnText: "保存",
            submitButtonLoading: false,

            disabledSmsTimer: false,
            sms: "",
            smsErrorMsg: "",

            newPasswordErrorMsg: '',
            oldPasswordErrorMsg: '',
            confirmPasswordErrorMsg: '',

            confirmPassword: '',
            newPassword: '',
            oldPassword: '',
        };
    },
    computed: {
        accountInfo() {
            return this.$store.state.accountInfo;
        }
    },
    methods: {
        //返回上一页
        toBack(e) {
            this.$router.push('/index?active=2')
        },
        //显示密码
        passwordView() {
            if (this.passwordFieldType == "password") {
                this.passwordIcon = "password-view";
                this.passwordFieldType = "text";
            } else {
                this.passwordIcon = "password-not-view";
                this.passwordFieldType = "password";
            }
        },

        handleSubmit() {
            this.validate = true;
            let url = "/sys/user/modifyPwd";
            //密码校验
            if (this.newPasswordErrorMsg || !this.newPassword) {
                this.$message({
                    message: this.newPasswordErrorMsg,
                    type: "error"
                });
                this.validate = false;
            }
            //密码校验
            if (this.oldPasswordErrorMsg || !this.oldPassword) {
                this.$message({
                    message: this.oldPasswordErrorMsg,
                    type: "error"
                });
                this.validate = false;
            }
            //密码校验
            if (this.confirmPasswordErrorMsg) {
                this.$message({
                    message: this.confirmPasswordErrorMsg,
                    type: "error"
                });
                this.validate = false;
            }
            //校验数据通过后提交数据
            if (this.validate) {
                this.submitButtonLoading = true;
                let params = {
                    newPassword: this.newPassword,
                    oldPassword: this.oldPassword,
                };
                this.$axios
                    .post(url, params)
                    .then(resp => {
                        this.$message.success(this.$t("changePassword.changeSuccess"));
                        this.$router.go(-1)
                        // console.log(resp)
                        // if (resp) {
                        //     let msg = this.$t("changePassword.changeSuccess");
                        //     this.$message.success(msg);
                        //     //三秒后自动跳转
                        //     // setTimeout(this.$router.go(-1), 3000);
                        //     this.$router.go(-1)
                        // } else {
                        //     this.$message.error(resp.message);
                        // }
                        this.submitButtonLoading = false;
                    })
                    .catch(err => {
                        this.submitButtonLoading = false;
                    });
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
        //密码校验
        newPassword: function (val) {
            if (val.length < 6 || val.length > 30) {
                this.newPasswordErrorMsg = this.$t("changePassword.passwordLengthCheckTip")
            } else {
                this.newPasswordErrorMsg = "";
            }
        },
        //密码校验
        oldPassword: function (val) {
            if (val.length < 6 || val.length > 30) {
                this.oldPasswordErrorMsg = this.$t("changePassword.passwordLengthCheckTip")
            } else {
                this.oldPasswordErrorMsg = "";
            }
        },
        //密码校验
        confirmPassword: function (val) {
            if (val != this.newPassword) {
                this.confirmPasswordErrorMsg = this.$t("changePassword.confirmPasswordCheckTip")
            } else {
                this.confirmPasswordErrorMsg = "";
            }
        }

    },
    created() {
        this.addEventBackButtonBack();
    },
};
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

.userInfo {
  height: 100%;
  background-repeat: no-repeat;
  background-size: cover;
  background-color: whitesmoke;
  .form {
    width: 95%;
    margin: 0.1rem auto;
    .form-item {
      height: 0.4rem;
      margin-bottom: 0.2rem;
      border-radius: 0.05rem;
      position: relative;
      img {
        margin-left: 0.2rem;
        width: 0.28rem;
        height: 0.28rem;
      }
      .mint-cell {
        background: none;
        input {
          background: none;
        }
      }
    }
  }
  .btn-footer {
    width: 95%;
    margin: 0.1rem auto;
    // .handle-btn {
    //     background-color: @base-element-color;
    // }
  }
  .head-panel {
    text-align: center;
    background-image: url("../../../assets/vehicle/head.png");
    background-repeat: no-repeat;
    background-size: 100% 100%;
    font-size: 0.18rem;
    color: white;
    height: 120px;
    .desc-content {
      font-size: 0.14rem;
      padding-top: 0.1rem;
    }
    .van-nav-bar {
      background: transparent;
    }
    .van-hairline--bottom {
      &::after {
        border-bottom-width: 0px;
      }
    }
  }
}
</style>
