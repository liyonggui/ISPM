<style lang="less" scoped>
.content-overlay {
  width: 100%;
  height: 100%;
  box-sizing: border-box;
  background: whitesmoke;
  //   padding: 10px;
  .content {
    overflow: auto;
  }
}
.block__title {
  margin: 0;
  font-weight: 400;
  font-size: 14px;
  color: rgba(69, 90, 100, 0.6);
  padding: 5px 15px;
}

.complete-content-overlay {
  height: 80%;
  width: 100%;
  box-sizing: border-box;
  background: whitesmoke;

  .complete-content {
    overflow: auto;
  }
  .img-con {
    padding: 5px;
    flex-wrap: wrap;
    .img-item {
      position: relative;
      //   padding: 5px;
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
<template>
    <van-popup v-model="value" class="content-overlay c_flex c_direction_v" position="right">
        <nav-bar left-arrow :left-text="$t('public.back')" @click-left="cancel"></nav-bar>
        <div class="content c_flex_1" ref="safeDisclosureInfo">
            <h2 class="block__title">{{$t('safeDisclosure.detailTitle')}}</h2>
            <van-cell-group>
                <van-cell :title="$t('safeDisclosure.code')" :value="formModel.code" />
                <van-cell :title="$t('safeDisclosure.subProjectName')" :value="formModel.subProjectName" />
                <van-cell :title="$t('safeDisclosure.educationLevel')" :value="$translate({key: 'education_level', value: formModel.educationLevel})" />
                <van-cell :title="$t('safeDisclosure.disclosureDegree')" :value="$translate({key: 'disclosure_degree', value: formModel.disclosureDegree})" />
                <van-cell :title="$t('safeDisclosure.status')">
                    <van-tag plain v-text="$translate({key: 'disclousure_status', value: formModel.status})" :type="calcStatusType(item.status)"></van-tag>
                </van-cell>
            </van-cell-group>

            <h2 class="block__title">{{$t('safeDisclosure.contentTitle')}}</h2>
            <van-cell-group>
                <div class="van-cell van-hairline van-field">
                    <div class="van-cell__value van-cell__value--alone">
                        <div class="van-field__body">
                            <span style="white-space: pre-line;">
                                {{formModel.content}}
                            </span>
                        </div>
                    </div>
                </div>

                <van-cell :title="$t('safeDisclosureContent.industry')" :value="$translate({key: 'industry', value: formModel.safeDisclosureContent.industry})" />
                <van-cell :title="$t('safeDisclosureContent.major')" :value="$translate({key: 'major', value: formModel.safeDisclosureContent.major})" />
                <van-cell :title="$t('safeDisclosureContent.worksType')" :value="$translate({key: 'works_type', value: formModel.safeDisclosureContent.worksType})" />

            </van-cell-group>
            <h2 class="block__title">{{$t('safeDisclosure.attachmentTitle')}}</h2>
            <van-cell-group>
                <van-cell v-for="(item, index) in formModel.safeDisclosureFileList" :key="index" :title="`${item.attachment.name}.${item.attachment.extType}`" v-if="item.type === 'disclousure_file_type_1'">
                </van-cell>
            </van-cell-group>

            <!-- <h2 class="block__title">{{$t('safeDisclosure.liveTitle')}}</h2>
            <van-cell-group>
                <van-cell :value="$t('public_button.view')" :title="$t('safeDisclosure.livePhoto')" is-link @click="showCompletePanel = true"> </van-cell>
            </van-cell-group> -->

            <div v-if="item.status === 'disclosure_user_1'">
                <h2 class="block__title">{{$t('safeDisclosure.selfSignTitle')}}</h2>

                <div style="width: 33%; height: 100px; margin: 0 0 5px 5px; border-radis: 5px;" @click="showSignImage">
                    <img :src="fastBaseUrl + selfSignUrl" style="width: 100%; height: 100%;" alt="" srcset="">
                </div>
            </div>

            <div v-if="formModel.status === 'disclousure_status_3'">
                <h2 class="block__title">{{$t('safeDisclosure.signTitle')}}</h2>

                <div style="width: 33%; height: 100px; margin: 0 0 5px 5px; border-radis: 5px;" @click="showSubmitSignImage">
                    <img :src="fastBaseUrl + signUrl" style="width: 100%; height: 100%;" alt="" srcset="">
                </div>
            </div>
        </div>

        <!-- <van-popup v-model="showCompletePanel" class="complete-content-overlay" position="bottom" :close-on-click-overlay="false">
            <div class="van-hairline--top-bottom van-picker__toolbar" style="background: #FFF;">
                <div class="van-picker__cancel" @click="showCompletePanel = false">关闭</div>
            </div>

            <div class="complete-content">
                <div class="img-con c_flex">
                    <div class="img-item" v-for="(item, index) in safeDisclosureImages" @click="showPreviewImage(item, index)" :key="index">
                        <img :src="item.__src" style="width: 100%; height: 100%;" alt="" srcset="">
                    </div>
                </div>
            </div>
        </van-popup> -->

        <signature :show.sync="showSignatureFlag" @onSubmit="signatureSubmitHandler"></signature>

        <van-submit-bar v-if="'disclosure_user_0' === item.status" button-text="完成" @submit="showSignatureFlag = true"></van-submit-bar>
    </van-popup>
</template>
<script>
import { Toast, ImagePreview } from 'vant'

import config from 'src/config/devconfig'
import signature from 'src/components/signature-box'

const uri = {
    get: "/activiti/safeDisclosure/get",
    update: "/activiti/safeDisclosure/update",
    submit: '/activiti/safeDisclosure/sign',
    /**文件操作-批量获取 */
    getBatchFastUrl: '/sys/attachment/urlList',
    /**文件操作 */
    getFastUrl: '/sys/attachment/getFastUrl'
}
export default {
    data() {
        return {
            showCompletePanel: false,
            imagesEditMode: false,
            formModel: { safeDisclosureContent: {} },

            fastBaseUrl: config.fastURL,
            imgBaseUrl: `${config.baseURL}/sys/attachment/fastdfs/download/fileId?param=`,
            imgUploadUrl: `${config.baseURL}/sys/attachment/fastdfs/upload`,

            safeDisclosureImages: [],
            /**签名 */
            showSignatureFlag: false,

            /**签名路径 */
            selfSignUrl: '',
            signUrl: ''
        }
    },
    props: {
        value: { type: Boolean, default: false, required: true },
        item: { type: Object, required: true }
    },

    watch: {
        value(val) {
            if (val) {
                this.addEventBackButtonBack()
                this.getData()
                if (this.item.attachment) {
                    this.getSignImg(this.item.attachment.id, (respImgUrl) => {
                        this.selfSignUrl = respImgUrl
                    })
                }

                if (this.item.safeDisclosure.attachment) {
                    this.getSignImg(this.item.safeDisclosure.attachment.id, (respImgUrl) => {
                        this.signUrl = respImgUrl
                    })
                }
            } else {
                this.formModel = { safeDisclosureContent: {} }
            }
        },

        showCompletePanel(val) {
            if (val) {
                this.$nextTick(() => {
                    this.calculateCompleteContentHeight()
                })
            }
        }
    },

    components: { signature },

    methods: {
        cancel() {
            this.formModel = { safeDisclosureContent: {} }
            this.$emit('input', false)
        },

        /**getData 获取安全交底信息 */
        getData() {
            this.$nextTick(() => {
                Toast.loading({ mask: true, duration: 0, loadingType: 'spinner' })
                this.$axios.post(uri.get, { id: this.item.safeDisclosure.id })
                    .then(resp => {
                        if (!resp.safeDisclosureContent) { resp.safeDisclosureContent = {} }
                        this.formModel = resp
                        /**数据结构修改 */
                        this.safeDisclosureImages = resp.safeDisclosureFileList.filter(item => {
                            return item.type === 'disclousure_file_type_2'
                        })

                        let imgPreviewUrl = []
                        this.safeDisclosureImages.forEach(item => {
                            imgPreviewUrl.push(item.attachment)
                        })

                        /**获取安全交底现场图片列表 */
                        if (imgPreviewUrl.length > 0) {
                            this.$axios.post(uri.getBatchFastUrl, imgPreviewUrl)
                                .then(resp => {
                                    this.safeDisclosureImages.forEach(item => {
                                        let result = resp.filter(resultItem => {
                                            return resultItem.id === item.attachment.id
                                        })
                                        item.__src = config.fastURL + result[0].fileResponseData.httpPreviewUrl
                                    })
                                })
                        }

                        this.calculateContentHeight()
                    })
                    .catch(err => { this.formModel = { safeDisclosureContent: {} } })
                    .finally(() => {
                        Toast.clear()
                    })
            })
        },

        /**showPreviewImage 显示预览图片 */
        showPreviewImage(item, idx) {
            let imageArr = []
            this.safeDisclosureImages.forEach(element => {
                imageArr.push(element.__src)
            });
            const instance = ImagePreview({
                images: imageArr,
                startPosition: idx,
                onClose: () => {
                    plus.key.addEventListener("backbutton", () => {
                        if (this.showCompletePanel) this.showCompletePanel = false
                        else if (this.showSignatureFlag) this.showSignatureFlag = false
                        else this.cancel()
                    });
                }
            })

            plus.key.removeEventListener("backbutton", () => {
                if (this.showCompletePanel) this.showCompletePanel = false
                else if (this.showSignatureFlag) this.showSignatureFlag = false
                else this.cancel()
            });
            plus.key.addEventListener("backbutton", () => {
                instance.close()
            });
        },

        /**showSignImage 显示签名预览照片 */
        showSignImage() {
            const instance = ImagePreview({
                images: [this.fastBaseUrl + this.selfSignUrl],
                onClose: () => {
                    plus.key.addEventListener("backbutton", () => {
                        if (this.showCompletePanel) this.showCompletePanel = false
                        else if (this.showSignatureFlag) this.showSignatureFlag = false
                        else this.cancel()
                    });
                }
            })

            plus.key.removeEventListener("backbutton", () => {
                if (this.showCompletePanel) this.showCompletePanel = false
                else if (this.showSignatureFlag) this.showSignatureFlag = false
                else this.cancel()
            });
            plus.key.addEventListener("backbutton", () => {
                instance.close()
            });
        },
        showSubmitSignImage() {
            const instance = ImagePreview({
                images: [this.fastBaseUrl + this.signUrl],
                onClose: () => {
                    plus.key.addEventListener("backbutton", () => {
                        if (this.showCompletePanel) this.showCompletePanel = false
                        else if (this.showSignatureFlag) this.showSignatureFlag = false
                        else this.cancel()
                    });
                }
            })
            plus.key.removeEventListener("backbutton", () => {
                if (this.showCompletePanel) this.showCompletePanel = false
                else if (this.showSignatureFlag) this.showSignatureFlag = false
                else this.cancel()
            });
            plus.key.addEventListener("backbutton", () => {
                instance.close()
            });
        },

        signatureSubmitHandler(val) {
            let submitData = {
                id: this.item.id,
                safeDisclosure: { id: this.formModel.id },
                attachment: { id: val.id }
            }

            Toast.loading({ mask: true, duration: 0, loadingType: 'spinner' })
            this.$axios.post(uri.submit, submitData)
                .then(resp => {
                    this.item.status = resp.status
                    this.getData()
                    this.getSignImg(resp.attachment.id, (respImgUrl) => {
                        this.selfSignUrl = respImgUrl
                    })
                    this.showSignatureFlag = false

                    this.$emit('reload-list')
                })
                .catch(err => { })
                .finally(() => {
                    Toast.clear()
                })
        },

        getSignImg(signAttachmentId, callback) {
            this.$axios.post(uri.getFastUrl, { id: signAttachmentId })
                .then(resp => {
                    let respImgUrl = resp.fileResponseData.httpPreviewUrl

                    if (callback && typeof (callback) === 'function') {
                        callback(respImgUrl)
                    }
                })
                .finally(() => {

                })
        },

        calcStatusType(status) {
            switch (status) {
                case 'disclousure_status_5':
                    return 'danger';
                case 'disclousure_status_4':
                    return 'success';
                default:
                    return 'primary';
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
                    if (this.showCompletePanel) this.showCompletePanel = false
                    else if (this.showSignatureFlag) this.showSignatureFlag = false
                    else this.cancel()
                });
            }
        },

        /**calculateContentHeight 计算高度 */
        calculateContentHeight() {

            // 移除 navbar 的高度 和 审核的高度
            this.$nextTick(() => {
                console.log(this.formModel)
                let navbarHeight = this.item.status === 'disclosure_user_0' ? 50 : 0
                // TODO: 状态判断，是否显示审核按键
                this.$refs['safeDisclosureInfo'].style.height = window.innerHeight - 46 - navbarHeight + 'px'
                this.$refs['safeDisclosureInfo'].style.marginBottom = navbarHeight + 'px'
            })
        },

        /**calculateCompleteContentHeight 计算高度 */
        calculateCompleteContentHeight() {
            document.querySelector('.complete-content').style.height = document.querySelector('.complete-content-overlay').clientHeight - 40 + 'px'
        }
    }
}
</script>

