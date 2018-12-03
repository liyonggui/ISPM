<template>
    <tms-page class="register">
    <nav-bar title="实名认证" slot="tms-header" left-text="返回" left-arrow  @click-left="toBack" />
    <div class="child" slot="tms-content">
        <div class="c_flex c_direction_v" style="height:100%;">
            <div class="c_flex_1" style="overflow:auto;">
                <div style="height: 100%;overflow-y: scroll;-webkit-overflow-scrolling : touch;">
                      <van-field  label="姓名"  maxlength="8" required :value="userInfo.name" v-model="accountInfo.userName" placeholder="请输入姓名" :error-message="nameErrorMsg" />
                        <van-field  label="身份证" maxlength="24" required :value="userInfo.identificationNo" v-model="accountInfo.identificationNo" type="idCard" placeholder="请输入身份证号" :error-message="idCardErrorMsg" />
                        <!--照片-->
                        <div class="van-cell van-cell--required" id="noBorder">
                            <div class="van-cell__title">
                                <span class="van-cell__text">身份证照片</span>
                            </div>
                        </div>
                        <uploader-idCard  ref="uploaderpic"  @show='showpic' @toBack="toPicBack" @outside='outside'></uploader-idCard>
                        
                </div>
            </div>   
        </div>
    </div>
    <!--底部-->
     <div class="c_flex"  slot="dms-footer"  > 
          <van-button    class="register-btn" type="primary"  :loading="submitButtonLoading" :disabled="submitButtonDisable" @click="handleSubmit" size="large">{{saveBtnText}}</van-button>
     </div>
    </tms-page>
 
</template>

<script>
 
import devconfig from '../../../config/devconfig'

export default {
    data() {
        return {
            idCard: "",
            // email: "",
            idNoSecret: "",
  
            idCardErrorMsg: "",
            nameErrorMsg: "",

            popupimage: '',
            popupimagesval: [],
            popupimagesindexval: null,
            popupshow: false,
            submitButtonDisable: false,
            uploadForm: new FormData(),
            imageList: [],
            sessionId: '',
            codeSrc: '',
            validate: false,
            saveBtnText: '保存',
            registerBtnDisabled: false,
            submitButtonLoading: false,

 
            userInfo:{},
            accountInfo: {},
 
            imagesData: [],

            loading:false,
            finished:true,
        };
    },
 
    methods: {
        //返回上一页
        toBack(e) {
            this.$router.go(-1)
        },
        /*上传图片*/
        removepic() {
            if (this.popupimagesindexval != null) {
                this.$refs.uploaderpic.$options.methods.remove.bind(this.$refs.uploaderpic)(this.popupimagesindexval);
            } else {
                this.$messagebox.alert('图片不能删除！')
            }
        },
        toPicBack() {
            this.popupimage = '';
            this.popupshow = false;
            this.popupimagesindexval = null;
        },
        showpic(url, images, index) {
            this.popupimage = url;
            this.popupshow = true;
            this.popupimagesval = images;
            this.popupimagesindexval = index;
        },
        /*获取图片信息*/
        outside(val) {
            this.imageList = val;
        },
        //更新localStorage
        updateLocalStorge()
        {
            this.userInfo.name =  this.accountInfo.userName;
            this.userInfo.identificationNo =   this.accountInfo.identificationNo;
            this.userInfo.status =  9;
            localStorage.setItem('userInfo', JSON.stringify( this.userInfo));
        },
        handleSubmit() {
            this.validate = true;
            this.accountInfo.userName  =   this.accountInfo.userName.replace(/\s+/g,""); 
            
            //姓名校验
            var pattern =  /^[\u0391-\uFFE5A-Za-z]+$/ ; 
            if (!this.accountInfo.userName ||  this.nameErrorMsg || !pattern.test(this.accountInfo.userName)|| this.accountInfo.userName.match(/\ud83c[\udf00-\udfff]|\ud83d[\udc00-\ude4f]|\ud83d[\ude80-\udeff]/g) != null) {
               this.$message({
                    message: "请输入正确的姓名",
                    type: 'error'
                }); 
 
                this.validate = false;
            }
            //身份证校验
             var pattern = /(^[1-9]\d{5}(18|19|([23]\d))\d{2}((0[1-9])|(10|11|12))(([0-2][1-9])|10|20|30|31)\d{3}[0-9Xx]$)|(^[1-9]\d{5}\d{2}((0[1-9])|(10|11|12))(([0-2][1-9])|10|20|30|31)\d{2}$)/;
            if (!this.accountInfo.identificationNo ||  !pattern.test(this.accountInfo.identificationNo)) {
               this.$message({
                    message: "请输入正确的身份证号",
                    type: 'error'
                }); 
                this.validate = false;
            }
            
            //身份证照片校验           
            if ((this.imageList.length < 2) && (this.imagesData.length < 2)) {
                this.$message({
                    message: "请上传身份证照片",
                    type: 'error'
                });
                this.validate = false;
            }

            //校验数据通过后提交数据
            if (this.validate) {
                let msg = '你的信息已经提交，请等待审核'
                this.submitButtonLoading = true;
                let url = '/user/auth'
                //手机端
                if (sessionStorage.plusready === 'done') {
                    var wt = plus.nativeUI.showWaiting();
                    var task = plus.uploader.createUpload(devconfig.baseURL + url, {
                            method: "POST"
                        },
                        (t, status) => { //上传完成
                            var jsonStr = {};
                            if (!t.responseText == "") {
                                jsonStr = JSON.parse(t.responseText);
                            }
                            console.log(t.responseText);
                            if (jsonStr.data) {
                           
                                this.$message({
                                    message: msg,
                                    type: 'success'
                                }) ;
                                this.updateLocalStorge();
                            } else {
                                let msg = '图片上传失败';
                                this.$message({
                                    message: msg,
                                    type: 'error'
                                })
                            }

                            if (status == 200) {
                                wt.close();
                            } else {
                                console.log("上传失败：" + status);
                                wt.close();
                            }
                            this.submitButtonLoading = false;
                                  //三秒后自动跳转   
                            setTimeout(  this.$router.go('-1') ,3000);
                        }
                    );
                    let token = this.userInfo.token;
                    task.setRequestHeader("X-Access-Token", token);

                    var data = this.accountInfo;
                    for (var i in data) {  
                        task.addData(i+"", data[i]);
                    }

 
                     // task.addData("email", this.email);
                    if (this.imageList[0]) {
                        task.addFile(this.imageList[0], {
                            key: "idCardPhotoFront"
                        });
                    }
                    if (this.imageList[1]) {
                        task.addFile(this.imageList[1], {
                            key: "idCardPhotoBack"
                        });
                    }
                    task.start();
                }
                //Web端
                else {
                    var data = this.accountInfo;
                    for (var i in data){  
                        this.uploadForm.set(i+"", data[i]);
                    }
 
                    this.uploadForm.set("idCardPhotoFront", this.imageList[0]);
                    this.uploadForm.set("idCardPhotoBack", this.imageList[1]);

                    let config = {
                        headers: {
                            "Content-Type": "multipart/form-data"
                        }
                    };
                    this.$axios.post(url, this.uploadForm, config).then((resp) => {
                        if (resp.success && resp.data && resp.code == "200") {
                            this.$message({
                                message: msg,
                                type: 'success'
                            })
                        this.updateLocalStorge();
                        //三秒后自动跳转   
                        setTimeout(  this.$router.go('-1') ,3000);
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
 
        //身份证校验
        "accountInfo.identificationNo": function (val) {
            var pattern = /(^[1-9]\d{5}(18|19|([23]\d))\d{2}((0[1-9])|(10|11|12))(([0-2][1-9])|10|20|30|31)\d{3}[0-9Xx]$)|(^[1-9]\d{5}\d{2}((0[1-9])|(10|11|12))(([0-2][1-9])|10|20|30|31)\d{2}$)/;
            if (!pattern.test(val)) {
                this.idCardErrorMsg = "身份证号错误";
            } else {
                this.idCardErrorMsg = "";
            }
        },
    },
     mounted() {
        this.addEventBackButtonBack(); 
        this.userInfo = JSON.parse( localStorage.getItem("userInfo"));
        this.accountInfo.userName = this.userInfo.name;
        this.accountInfo.identificationNo = this.userInfo.identificationNo;
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
    background-repeat: no-repeat;
    background-size: cover;
    .form {
         height: 78%;
        overflow-y: scroll;
        -webkit-overflow-scrolling: touch;
        width: 95%;
        margin: 0.1rem auto;
        .form-item {
            height: .4rem;
            margin-bottom: .2rem;
            border-radius: .05rem;
            position: relative;
            img {
                margin-left: .2rem;
                width: .28rem;
                height: .28rem;
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
 
    }
      .head-panel {
 
        background-image: url("../../../assets/vehicle/head.png");
        background-repeat: no-repeat;
        background-size: 100% 100%;
 
    }
}
</style>
<style lang="less">
 .register
 {
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
 }
 </style>