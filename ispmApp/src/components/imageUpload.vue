<!--imageUpload-->
<!--@author LiFanLingJue-->
<!--@date 2018/8/24-->
<template lang="html">
    <van-popup v-model="show" lock-scroll class="imageUpload c_flex c_direction_v" position="bottom"
               :close-on-click-overlay="false">
        <div class="van-hairline--top-bottom van-picker__toolbar">
            <div class="van-picker__cancel" v-show="!imagesEditMode" @click="show = false">取消</div>

            <div v-show="!imagesEditMode" class="c_flex">
                <div class="van-picker__confirm" @click="submit">提交</div>
                <div class="van-picker__confirm" @click="imagesEditMode = true">编辑</div>
            </div>

            <div class="van-picker__cancel" style="color: red;" v-show="imagesEditMode" @click="deleteImg">删除</div>
            <div class="van-picker__confirm" v-show="imagesEditMode" @click="editDone">完成</div>
        </div>

        <div class="c_flex_1">
            <div class="img-con c_flex">
                <div class="img-item" v-for="(item, index) in imagesArr"
                     @click="showPreviewImage(item, index)" :key="index">
                    <img :src="item.src" style="width: 100%; height: 100%;" alt="" srcset="">
                    <div class="c_flex c_a_center c_j_center item-overlay" v-show="item.__checked">
                        <van-checkbox v-model="item.__checked"></van-checkbox>
                    </div>
                </div>
                <div class="c_flex c_j_around c_a_center img-item" @click="imgClickHandler" v-if="!imagesEditMode && uploadBtnShowFlag">
                    <van-icon name="photograph"></van-icon>
                </div>
            </div>
        </div>
    </van-popup>
</template>

<script>
    import moment from 'moment'
    import config from 'src/config/devconfig'
    import {showActionSheet, uploadFile, getFileEntity} from 'src/utils/camera-sdk'
    import {ImagePreview, Toast} from 'vant'


    export default {
        props: {
            data: {type: Array, default: () => []},
            maxNumber: {type: Number, default: 9},
            watermarkType:{type: String },
            watermarkText:{type: String },
        },
        data() {
            return {
                imgUploadUrl: `${config.baseURL}/sys/attachment/fastdfs/upload`,
                show: false,
                imagesEditMode: false,
                imagesArr: [],
                uploadBtnShowFlag: true,
                imgInstance: {}
            }
        },
        methods: {
            submit() {
                this.$emit('callback', this.imagesArr.map(item => {
                    return item.id
                }));
                this.show = false
            },
            deleteImg() {
                this.imagesArr = this.imagesArr.filter(item => {
                    return !item.__checked
                })
            },
            editDone() {
                this.imagesArr.forEach(item => {
                    this.$set(item, '__checked', false)
                });
                this.imagesEditMode = false;
            },
            imgClickHandler() {
                if (sessionStorage.plusready === "done") {
                    //水印
                    let watermarkString = ""
                    if(this.watermarkType == "datetime")
                    {
                        watermarkString = moment(new Date()).format('YYYY-MM-DD HH:mm:ss');
                    }
                    else if(this.watermarkType == "date")
                    {
                        watermarkString = moment(new Date()).format('YYYY-MM-DD');
                    }
                    else if(this.watermarkType == "text")
                    {
                        watermarkString = this.watermarkText
                    }
                    let num = this.imagesArr.length,
                    maxNumber = this.maxNumber
                    console.log("num", num)
                    showActionSheet((resp, fileName) => {
                        Toast.loading({mask: true, duration: 0, loadingType: 'spinner'});
                        uploadFile(this.imgUploadUrl, resp.target, fileName, (t, status) => {
                            /**上传成功 */
                            if (200 === status && t.state == 4) {


                                let resp = JSON.parse(t.responseText)
                                let id = resp.data.id
                                // TODO: 对 response 进行业务校验
                                if (resp.ok && '0' === resp.code) {
                                    this.$axios.post('/sys/attachment/urlList', [{id: resp.data.id}])
                                        .then(response => {
                                            response.forEach(item => {
                                                this.imagesArr.push(
                                                    {
                                                        id: item.id,
                                                        src: config.fastURL + item.fileResponseData.httpPreviewUrl,
                                                        detailSrc: config.fastURL + item.fileResponseData.httpUrl,
                                                        info: item.name
                                                    }
                                                )
                                            })
                                        })
                                } else {

                                }

                               if (this.imagesArr.length > 8) {
                                this.uploadBtnShowFlag = false
                               }
                            } else {

                            }
                            Toast.clear()
                        })
                    },
                    num,
                    maxNumber,
                    watermarkString
                    )
                }
            },
            showPreviewImage(item, idx) {
                if (this.imagesEditMode) {
                    this.$set(item, '__checked', !item.__checked)
                } else {
                    this.addEventBackButtonBack()
                    this.imgInstance = ImagePreview({
                        images: this.imagesArr.map(item => {
                            return item.detailSrc
                        }),
                        startPosition: idx
                    })
                    
                }
            },
            toBack() {
                if (this.imgInstance) this.imgInstance.close()
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
        mounted () {
            this.addEventBackButtonBack()
        },
        watch: {
            data(val) {
                if (val.length) {
                    if (!this.$store.state.offLine) {
                        this.imagesArr = [];
                        let attachments = val.map(item => {
                            return {id: item}
                        });
                        this.$axios.post('/sys/attachment/urlList', attachments)
                            .then(resp => {
                                resp.forEach(item => {
                                    this.imagesArr.push(
                                        {
                                            id: item.id,
                                            src: config.fastURL + item.fileResponseData.httpPreviewUrl,
                                            detailSrc: config.fastURL + item.fileResponseData.httpUrl,
                                            info: item.name
                                        }
                                    )
                                })
                            })
                    }
                } else {
                    this.imagesArr = []
                }
            }
        }
    }
</script>

<style scoped lang="less" type="text/less">
    .imageUpload {
        height: 80%;
        background: whitesmoke;
        .img-con {
            padding: 5px;
            flex-wrap: wrap;
            .img-item {
                position: relative;
                margin: 1%;
                width: 31.3%;
                height: 100px;
                border: 1px dotted #999;
                border-radius: 5px;
            }
        }
        .item-overlay {
            position: absolute;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.4);
        }
    }
</style>
