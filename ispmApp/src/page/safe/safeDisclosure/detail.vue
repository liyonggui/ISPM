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

    textarea {
      -webkit-user-select: auto;
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
<style lang="less">
  .logoutTitle {
    color: rgba(69, 90, 100, 0.6);
    font-size: 14px;
  }
  .logoutText {
    color: red;
  }
</style>
<template>
  <van-popup v-model="value" class="content-overlay c_flex c_direction_v" position="right">
    <nav-bar left-arrow :left-text="$t('public.back')" @click-left="cancel" :title="$t('safeDisclosure.detailTitle')">
      <div slot="right" class="van-nav-bar__text">
        <van-icon style="font-size: .2rem; margin-right: .1rem" name="delete" v-if="formModel.status === 'disclousure_status_1'" @click="deleteHandler" />
        <van-icon style="font-size: .2rem; margin-right: .1rem" name="edit" v-if="formModel.status === 'disclousure_status_1'" @click="editHandler" />
      </div>
    </nav-bar>
    <div class="content c_flex_1" ref="safeDisclosureInfo">
      <h2 class="block__title">{{$t('safeDisclosure.detailTitle')}}</h2>
      <van-cell-group>
        <van-cell :title="$t('safeDisclosure.code')" :value="formModel.code" />
        <van-cell :title="$t('safeDisclosure.subProjectName')" :value="formModel.subProjectName" />
        <van-cell :title="$t('safeDisclosure.educationLevel')" :value="$translate({key: 'education_level', value: formModel.educationLevel})" />
        <van-cell :title="$t('safeDisclosure.disclosureDegree')" :value="$translate({key: 'disclosure_degree', value: formModel.disclosureDegree})" />
        <van-cell v-if="formModel.status === 'disclousure_status_3'" :title="$t('safeDisclosure.endDate')" :value="formModel.endDate" />
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

      <h2 class="block__title">班组信息</h2>
      <van-cell-group>
        <van-cell title="班组类型" :value="$translate({key: 'works_type', value: formModel.teamType})" />
        <van-cell title="班组名称" :value="formModel.teamName" />
        <van-cell title="班组编码" :value="formModel.teamCode" />
      </van-cell-group>

      <h2 class="block__title">{{$t('safeDisclosure.attachmentTitle')}}</h2>
      <van-cell-group>
        <van-cell v-for="(item, index) in formModel.safeDisclosureFileList" :key="index" :title="`${item.attachment.name}.${item.attachment.extType}`" v-if="item.type === 'disclousure_file_type_1'">
        </van-cell>
      </van-cell-group>

      <h2 class="block__title">{{$t('safeDisclosure.persionTitle')}}</h2>
      <van-cell-group>
        <van-cell v-for="(item, index) in formModel.safeDisclosureUserList" :key="index" center @click="userClickHandler(item)">
          <span slot="title">{{ item.user.name }}</span>
          <!-- <van-button type="primary" size="mini" v-if="item.status === 'disclosure_user_0'" @click="signatureByOther(item)">代签</van-button> -->
          <van-tag plain v-text="$translate({key: 'disclosure_user', value: item.status})" :type="calcUserStatusType(item.status)"></van-tag>
        </van-cell>
      </van-cell-group>

      <h2 class="block__title">{{$t('safeDisclosure.liveTitle')}}</h2>
      <van-cell-group>
        <van-cell :value="$t('public_button.view')" :title="$t('safeDisclosure.livePhoto')" is-link @click="showCompletePanel = true"> </van-cell>
      </van-cell-group>

      <div v-if="formModel.status === 'disclousure_status_3'">
        <h2 class="block__title">{{$t('safeDisclosure.signTitle')}}</h2>

        <div style="width: 33%; height: 100px; margin: 0 0 5px 5px; border-radis: 5px;" @click="showSignImage">
          <img :src="signatureImg" style="width: 100%; height: 100%;" alt="" srcset="">
        </div>
      </div>
    </div>

    <van-popup v-model="showCompletePanel" class="complete-content-overlay" position="bottom" :close-on-click-overlay="false">
      <div class="van-hairline--top-bottom van-picker__toolbar" style="background: #FFF;">

        <template v-if="formModel.status === 'disclousure_status_2' || formModel.status === 'disclousure_status_1'">
          <div class="van-picker__cancel" v-show="!imagesEditMode" @click="showCompletePanel = false">{{$t('public_button.cancel')}}</div>

          <div v-show="!imagesEditMode" class="c_flex">
            <div class="van-picker__confirm" @click="submitDisclosureImgsHandler">{{$t('public_button.confirm')}}</div>
            <div class="van-picker__confirm" @click="editCompleteImgsHandler">{{$t('public_button.edit')}}</div>
          </div>

          <div class="van-picker__cancel" style="color: red;" v-show="imagesEditMode" @click="delCompleteImgsHandler">{{$t('public_button.delete')}}</div>
          <div class="van-picker__confirm" v-show="imagesEditMode" @click="submitCompleteImgsHandler">{{$t('public_button.save')}}</div>
        </template>

        <template v-else>
          <div class="van-picker__cancel" @click="showCompletePanel = false">关闭</div>
        </template>
      </div>

      <div class="complete-content">
        <div class="img-con c_flex">
          <div class="img-item" v-for="(item, index) in safeDisclosureImages" @click="showPreviewImage(item, index)" :key="index">
            <img :src="item.__src" style="width: 100%; height: 100%;" alt="" srcset="">
            <div class="c_flex c_a_center c_j_center item-overlay" v-if="item.__checked">
              <van-checkbox v-model="item.__checked"></van-checkbox>
            </div>
          </div>
          <div class="c_flex c_j_around c_a_center img-item" @click="imgClickHandler" v-if="(formModel.status === 'disclousure_status_2' || formModel.status === 'disclousure_status_1') && !imagesEditMode">
            <van-icon name="photograph"></van-icon>
          </div>
        </div>
      </div>
    </van-popup>

    <signature :show.sync="showSignatureFlag" @onSubmit="signatureSubmitHandler"></signature>

    <signature :show.sync="showSignOtherFlag" @onSubmit="signOtherCallbackHandler"></signature>

    <van-submit-bar v-if="'disclousure_status_2' === formModel.status" button-text="完成" @submit="showSignatureFlag = true"></van-submit-bar>

    <van-actionsheet v-model="showDeleteFlag" :actions="deleteAction" :cancel-text="$t('public_button.cancel')" @select="handleDeleteSelect"> </van-actionsheet>

  </van-popup>
</template>
<script>
import { Toast, ImagePreview } from "vant";
import {
  showActionSheet,
  uploadFile,
  getFileEntity
} from "src/utils/camera-sdk";
import moment from "moment";
import cloneDeep from "lodash/cloneDeep";
import config from "src/config/devconfig";
import signature from "src/components/signature-box";

const uri = {
  get: "/activiti/safeDisclosure/get",
  update: "/activiti/safeDisclosure/update",
  submit: "/activiti/safeDisclosure/submit",
  /**文件操作-批量获取 */
  getBatchFastUrl: "/sys/attachment/urlList",
  getFastUrl: "/sys/attachment/getFastUrl",

  sign: "/activiti/safeDisclosure/sign",

  delete: "/activiti/safeDisclosure/delete"
};
export default {
  data() {
    return {
      /**删除安全交底Flag */
      showDeleteFlag: false,
      deleteAction: [
        { name: "是否确认删除当前交底", className: "logoutTitle" },
        { name: "删除", key: "delete", className: "logoutText" }
      ],

      showCompletePanel: false,
      imagesEditMode: false,
      formModel: { safeDisclosureContent: {} },

      imgUploadUrl: `${config.baseURL}/sys/attachment/fastdfs/upload`,

      signatureImg: "",
      currentUser: null,

      safeDisclosureImages: [],
      /**签名 */
      showSignatureFlag: false,
      showSignOtherFlag: false
    };
  },
  props: {
    value: { type: Boolean, default: false, required: true },
    item: { type: Object, required: true }
  },

  watch: {
    value(val) {
      if (val) {
        this.addEventBackButtonBack();
        this.getData();
      } else {
        this.formModel = { safeDisclosureContent: {} };
      }
    },

    showCompletePanel(val) {
      if (!val) {
        this.safeDisclosureImages.splice(0);
      } else {
        this.$nextTick(() => {
          /**数据结构修改 */
          this.safeDisclosureImages = this.formModel.safeDisclosureFileList.filter(
            item => {
              return item.type === "disclousure_file_type_2";
            }
          );

          let imgPreviewUrl = [];
          this.safeDisclosureImages.forEach(item => {
            imgPreviewUrl.push(item.attachment);
          });

          /**获取安全交底现场图片列表 */
          if (imgPreviewUrl.length > 0) {
            this.$axios.post(uri.getBatchFastUrl, imgPreviewUrl).then(resp => {
              this.safeDisclosureImages.forEach((item, index) => {
                let result = resp.filter(resultItem => {
                  return resultItem.id === item.attachment.id;
                });
                item.__src =
                  config.fastURL + result[0].fileResponseData.httpPreviewUrl;

                this.safeDisclosureImages.splice(
                  index,
                  1,
                  Object.assign(item, { __checked: false })
                );
                // item.__checked = false
              });
            });
          }
        });
      }

      this.$nextTick(() => {
        this.calculateCompleteContentHeight();
      });
    }
  },
  components: { signature },

  methods: {
    cancel() {
      this.formModel = {};
      this.$emit("input", false);
    },

    /**getData 获取安全交底信息 */
    getData() {
      Toast.loading({ mask: true, duration: 0, loadingType: "spinner" });
      this.$axios
        .post(uri.get, { id: this.item.id })
        .then(resp => {
          if (!resp.safeDisclosureContent) resp.safeDisclosureContent = {};
          this.formModel = resp;

          /**数据结构修改 */
          this.safeDisclosureImages = resp.safeDisclosureFileList.filter(
            item => {
              return item.type === "disclousure_file_type_2";
            }
          );

          let imgPreviewUrl = [];
          this.safeDisclosureImages.forEach(item => {
            imgPreviewUrl.push(item.attachment);
          });

          /**获取安全交底现场图片列表 */
          if (imgPreviewUrl.length > 0) {
            this.$axios.post(uri.getBatchFastUrl, imgPreviewUrl).then(resp => {
              this.safeDisclosureImages.forEach(item => {
                let result = resp.filter(resultItem => {
                  return resultItem.id === item.attachment.id;
                });
                item.__src =
                  config.fastURL + result[0].fileResponseData.httpPreviewUrl;
              });
            });
          }

          /**
           * 获取发起人签名图片
           * 交底完成时才需要请求
           */
          if (this.formModel.status === "disclousure_status_3") {
            this.$axios
              .post(uri.getFastUrl, this.formModel.attachment)
              .then(resp => {
                this.signatureImg =
                  config.fastURL + resp.fileResponseData.httpPreviewUrl;
              });
          }

          this.calculateContentHeight();
        })
        .catch(err => {
          this.formModel = {};
        })
        .finally(() => {
          Toast.clear();
        });
    },

    /**编辑操作 */
    editHandler() {
      this.$emit("input", false);
      this.$nextTick(() => {
        this.$router.push({
          name: "safe_disclosure_create",
          query: { id: this.item.id }
        });
      });
    },

    /**imgClickHandler  */
    imgClickHandler() {
      showActionSheet(
        (resp, fileName) => {
          uploadFile(this.imgUploadUrl, resp.target, fileName, (t, status) => {
            /**上传成功 */
            if (200 === status && t.state == 4) {
              let respData = JSON.parse(t.responseText);
              // let id = respData.data.id
              // TODO: 对 response 进行业务校验
              if (respData.ok && "0" === respData.code) {
                let id = respData.data.id;
                this.safeDisclosureImages.push({
                  attachment: { id: id },
                  type: "disclousure_file_type_2",
                  __src: resp.target
                });
              } else {
              }
            } else {
            }
          });
        },
        0,
        9,
        moment(new Date()).format("YYYY-MM-DD HH:mm:ss")
      );
    },

    /**showPreviewImage 显示预览图片 */
    showPreviewImage(item, idx) {
      if (this.imagesEditMode) {
        this.safeDisclosureImages.splice(
          idx,
          1,
          Object.assign(item, { __checked: !item.__checked })
        );
      } else {
        let imageArr = [];
        this.safeDisclosureImages.forEach(element => {
          imageArr.push(element.__src);
        });
        const instance = ImagePreview({
          images: imageArr,
          startPosition: idx,
          onClose: () => {
            plus.key.addEventListener("backbutton", () => {
              if (this.showCompletePanel) this.showCompletePanel = false;
              else if (this.showSignatureFlag) this.showSignatureFlag = false;
              else if (this.showSignOtherFlag) this.showSignOtherFlag = false;
              else this.cancel();
            });
          }
        });
        plus.key.removeEventListener("backbutton", () => {
          if (this.showCompletePanel) this.showCompletePanel = false;
          else if (this.showSignatureFlag) this.showSignatureFlag = false;
          else if (this.showSignOtherFlag) this.showSignOtherFlag = false;
          else this.cancel();
        });
        plus.key.addEventListener("backbutton", () => {
          instance.close();
        });
      }
    },

    /**showSignImage 显示签名预览照片 */
    showSignImage() {
      const instance = ImagePreview({
        images: [this.signatureImg],
        onClose: () => {
          plus.key.addEventListener("backbutton", () => {
            if (this.showCompletePanel) this.showCompletePanel = false;
            else if (this.showSignatureFlag) this.showSignatureFlag = false;
            else if (this.showSignOtherFlag) this.showSignOtherFlag = false;
            else this.cancel();
          });
        }
      });

      plus.key.removeEventListener("backbutton", () => {
        if (this.showCompletePanel) this.showCompletePanel = false;
        else if (this.showSignatureFlag) this.showSignatureFlag = false;
        else if (this.showSignOtherFlag) this.showSignOtherFlag = false;
        else this.cancel();
      });
      plus.key.addEventListener("backbutton", () => {
        instance.close();
      });
    },

    /**editCompleteImgsHandler 编辑安全交底照片*/
    editCompleteImgsHandler() {
      this.imagesEditMode = true;
    },

    submitCompleteImgsHandler() {
      this.safeDisclosureImages.forEach((element, index) => {
        this.safeDisclosureImages.splice(
          index,
          1,
          Object.assign(element, { __checked: false })
        );
      });

      this.imagesEditMode = false;
    },

    submitDisclosureImgsHandler() {
      let attachmentFileList = this.formModel.safeDisclosureFileList.filter(
        item => {
          return item.type === "disclousure_file_type_1";
        }
      );

      this.formModel.safeDisclosureFileList = attachmentFileList.concat(
        this.safeDisclosureImages
      );

      Toast.loading({ mask: true, duration: 0, loadingType: "spinner" });
      this.$axios
        .post(uri.update, this.formModel)
        .then(resp => {
          this.showCompletePanel = false;
          this.getData();
        })
        .catch(err => {})
        .finally(() => {
          Toast.clear();
        });
    },

    delCompleteImgsHandler() {
      this.safeDisclosureImages = this.safeDisclosureImages.filter(item => {
        return !item.__checked;
      });
    },

    signatureSubmitHandler(resp) {
      this.formModel.attachment = { id: resp.id };

      Toast.loading({ mask: true, duration: 0, loadingType: "spinner" });

      let submitModel = cloneDeep(this.formModel);
      submitModel.endDate = moment(new Date()).format("YYYY-MM-DD HH:mm:ss");

      this.$axios
        .post(uri.submit, submitModel)
        .then(resp => {
          this.getData();
          this.showSignatureFlag = false;
        })
        .catch(err => {})
        .finally(() => {
          Toast.clear();
        });
    },

    calcStatusType(status) {
      switch (status) {
        case "disclousure_status_5":
          return "danger";
        case "disclousure_status_4":
          return "success";
        default:
          return "primary";
      }
    },

    calcUserStatusType(status) {
      switch (status) {
        case "disclosure_user_0":
          return "primary";
        case "disclosure_user_1":
          return "success";
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
          if (this.showCompletePanel) this.showCompletePanel = false;
          else if (this.showSignatureFlag) this.showSignatureFlag = false;
          else if (this.showSignOtherFlag) this.showSignOtherFlag = false;
          else this.cancel();
        });
      }
    },

    /**calculateContentHeight 计算高度 */
    calculateContentHeight() {
      // 移除 navbar 的高度 和 审核的高度
      this.$nextTick(() => {
        console.log(this.formModel);
        let navbarHeight =
          this.formModel.status === "disclousure_status_2" ? 50 : 0;
        // TODO: 状态判断，是否显示审核按键
        this.$refs["safeDisclosureInfo"].style.height =
          window.innerHeight - 46 - navbarHeight + "px";
        this.$refs["safeDisclosureInfo"].style.marginBottom =
          navbarHeight + "px";
      });
    },

    /**calculateCompleteContentHeight 计算高度 */
    calculateCompleteContentHeight() {
      document.querySelector(".complete-content").style.height =
        document.querySelector(".complete-content-overlay").clientHeight -
        40 +
        "px";
    },

    /**替代别人签名 */
    signatureByOther(item) {
      this.currentUser = item;
      this.showSignOtherFlag = true;
    },

    signOtherCallbackHandler(resp) {
      let submitModel = {
        attachment: { id: resp.id },
        id: this.currentUser.id,
        safeDisclosure: { id: this.formModel.id }
      };

      Toast.loading({ mask: true, duration: 0, loadingType: "spinner" });
      this.$axios
        .post(uri.sign, submitModel)
        .then(resp => {
          this.getData();
          this.showSignatureFlag = false;
        })
        .catch(err => {})
        .finally(() => {
          Toast.clear();
        });
    },
    /**详情页删除安全交底 */
    deleteHandler() {
      this.showDeleteFlag = true;
    },
    handleDeleteSelect(item) {
      if ("delete" === item.key) {
        this.$axios
          .post(uri.delete, { id: this.formModel.id })
          .then(resp => {
            this.$toast({
              iconClass: "van-icon van-icon-success",
              message: this.$t("operationTips.deleteSuccess")
            });
            this.cancel();
            this.$emit("reloadList");
          })
          .finally(resp => {
            this.showDeleteFlag = false;
          });
      }
    },

    userClickHandler(item) {
      if (item.attachment) {
        Toast.loading({ mask: true, duration: 0, loadingType: "spinner" });
        this.$axios
          .post(uri.getFastUrl, item.attachment)
          .then(resp => {
            let signUrl = config.fastURL + resp.fileResponseData.httpPreviewUrl;

            const instance = ImagePreview({
              images: [signUrl],
              onClose: () => {
                plus.key.addEventListener("backbutton", () => {
                  if (this.showCompletePanel) this.showCompletePanel = false;
                  else if (this.showSignatureFlag)
                    this.showSignatureFlag = false;
                  else if (this.showSignOtherFlag)
                    this.showSignOtherFlag = false;
                  else this.cancel();
                });
              }
            });
            plus.key.removeEventListener("backbutton", () => {
              if (this.showCompletePanel) this.showCompletePanel = false;
              else if (this.showSignatureFlag) this.showSignatureFlag = false;
              else if (this.showSignOtherFlag) this.showSignOtherFlag = false;
              else this.cancel();
            });
            plus.key.addEventListener("backbutton", () => {
              instance.close();
            });
          })
          .finally(() => {
            Toast.clear();
          });
      } else {
        this.currentUser = item;
        this.showSignOtherFlag = true;
      }
    }
  }
};
</script>

