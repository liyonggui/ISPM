<style lang="less" scoped>
.content-overlay {
  width: 100%;
  height: 100%;
  box-sizing: border-box;
  background: whitesmoke;
  //   padding: 10px;
  .content {
    overflow: auto;
    margin-bottom: 50px; // 预留bottom
  }
}
.block__title {
  margin: 0;
  font-weight: 400;
  font-size: 14px;
  color: rgba(69, 90, 100, 0.6);
  padding: 5px 15px;
}
</style>
<template>
    <van-popup v-model="value" class="content-overlay" position="right">
        <nav-bar left-arrow :left-text="$t('public.back')" @click-left="cancel" :right-text="$t('public_button.edit')" @click-right="editHandler" :title="$t('safeDisclosure.detailTitle')"></nav-bar>
        <div class="content c_flex_1" ref="safeDisclosureInfo">
            <h2 class="block__title">安全交底信息</h2>
            <van-cell-group>
                <van-cell :title="$t('safeDisclosure.disclosureNo')" :value="formModel.disclosureNo" />
                <van-cell :title="$t('safeDisclosure.subProjectName')" :value="formModel.subProjectName" />
                <van-cell :title="$t('safeDisclosure.planDate')" :value="formModel.planDate" />
                <van-cell :title="$t('safeDisclosure.status')">
                    <van-tag plain v-text="$translate({key: 'disclousure_status', value: formModel.status})" :type="calcStatusType(item.status)"></van-tag>
                </van-cell>
            </van-cell-group>

            <h2 class="block__title">安全交底内容</h2>
            <van-cell-group>
                <van-field v-model="formModel.content" disabled type="textarea" @blur="formModel.content=formModel.content.trim()" placeholder="安全交底内容" rows="5" autosize />
            </van-cell-group>
            <h2 class="block__title">附件列表</h2>
            <van-cell-group>
                <van-cell v-for="(item, index) in formModel.safeDisclosureFileList" :key="index" :title="`${item.attachment.name}.${item.attachment.extType}`" v-if="item.type === 'disclousure_file_type_1'">
                </van-cell>
            </van-cell-group>

            <h2 class="block__title">人员列表</h2>
            <van-cell-group>
                <van-cell v-for="(item, index) in formModel.safeDisclosureUserList" :key="index">
                    <span slot="title">{{ item.user.name }}</span>
                </van-cell>
            </van-cell-group>
        </div>
        <van-submit-bar button-text="完成"></van-submit-bar>
    </van-popup>
</template>
<script>
import { Toast } from 'vant'
const uri = {
    get: "/activiti/safeDisclosure/get"
}
export default {
    data() {
        return {
            formModel: {},
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
                this.calculateContentHeight()
                this.getData()
            }
        }
    },

    methods: {
        cancel() {
            this.formModel = {}
            this.$emit('input', false)
        },

        /**getData 获取安全交底信息 */
        getData() {
            // console.log(this.$route)
            console.log(this.item.id)

            Toast.loading({ mask: true, duration: 0, loadingType: 'spinner' })
            this.$axios.post(uri.get, { id: this.item.id })
                .then(resp => {
                    this.formModel = resp
                })
                .catch(err => { this.formModel = {} })
                .finally(() => {
                    Toast.clear()
                })
        },

        /**编辑操作 */
        editHandler() {
            this.$emit('input', false)
            this.$nextTick(() => {
                this.$router.push({ name: 'safe_disclosure_create', query: { id: this.item.id } })
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
                    this.cancel()
                });
            }
        },

        /**calculateContentHeight 计算高度 */
        calculateContentHeight() {
            // 移除 navbar 的高度 和 审核的高度
            this.$nextTick(() => {
                // TODO: 状态判断，是否显示审核按键
                this.$refs['safeDisclosureInfo'].style.height = window.innerHeight - 46 - 50 + 'px'
            })
        }
    }
}
</script>

