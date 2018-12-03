<!--detail-->
<!--@author Lisa-->
<!--@date 2018/9/7-->
<template>
    <div class="safeDisclosureContent_detail c_flex c_direction_v" v-touch:right="rightSlip">
        <nav-bar left-arrow :left-text="$t('public.back')" @click-left="toBack" :title="$store.state.offLine ? $t('safeDisclosureContent.offLineDetailTitle') : $t('safeDisclosureContent.detailTitle')">
        </nav-bar>
        <div class="content c_flex_1" ref="content">
            <custom-form :data="formModel" :config="formConfig" ref="form">
                <template slot-scope="scope" slot="content">
                    <van-field v-model="scope.data.content" type="textarea" placeholder="" readonly autosize />
                </template>
            </custom-form>
        </div>
    </div>
</template>

<script>
import cloneDeep from 'lodash/cloneDeep'
import customForm from 'src/components/custom-form.vue'

import { Toast } from 'vant'

const uri = {
    get: "/safe/safeDisclosureContent/get"
};
export default {
    props: {
        itemData: { type: Object },
        detailType: { type: String }
    },
    data() {
        return {
            formModel: {approver: {}}
        }
    },

    methods: {
        //返回上一页
        toBack(e) {
            this.$router.go(-1)
        },

        getData() {
            let itemDataId = this.$route.query.id;
            if (itemDataId) {

                Toast.loading({ mask: true, duration: 0, loadingType: 'spinner' })

                this.$axios.post(uri.get, { id: itemDataId }, { _cache: 'safeDisclosureContent' })
                    .then(resp => {
                        if(!resp.approver) resp.approver = {}

                        this.formModel = resp
                        this.formModel.educationLevel = this.$translate({ key: 'education_level', value: resp.educationLevel })
                        if (resp.attachment && resp.attachment.name) {
                            this.formModel.attachmentName = resp.attachment.name
                        }
                        this.formModel.industry = this.$translate({ key: 'industry', value: resp.industry })
                        this.formModel.major = this.$translate({ key: 'major', value: resp.major })
                        this.formModel.worksType = this.$translate({ key: 'works_type', value: resp.worksType })

                        this.formModel.content = '交底模板内容：\r\n' + this.formModel.content
                    })
                    .finally(() => {
                        Toast.clear()
                    })
            }
        },

        //侧边滑动返回上一页
        rightSlip(event, start, end) {
            if (start.X < 20) {
                this.toBack()
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
    computed: {
        formConfig() {
            return [
                {
                    componentType: 'label',
                    prop: 'code',
                    label: this.$t('safeDisclosureContent.code')
                },
                {
                    componentType: 'label',
                    prop: 'name',
                    label: this.$t('safeDisclosureContent.name')
                },
                {
                    componentType: 'label',
                    prop: 'documentNo',
                    label: this.$t('safeDisclosureContent.documentNo')
                },
                {
                    componentType: 'label',
                    prop: 'versionNo',
                    label: this.$t('safeDisclosureContent.versionNo')
                },
                {
                    componentType: 'label',
                    prop: 'educationLevel',
                    label: this.$t('safeDisclosureContent.educationLevel')
                },
                {
                    componentType: 'label',
                    prop: 'industry',
                    label: this.$t('safeDisclosureContent.industry')
                },
                {
                    componentType: 'label',
                    prop: 'major',
                    label: this.$t('safeDisclosureContent.major')
                },
                {
                    componentType: 'label',
                    prop: 'worksType',
                    label: this.$t('safeDisclosureContent.worksType')
                },
                {
                    componentType: "label",
                    prop: "attachmentName",
                    label: this.$t("safeDisclosureContent.attachmentName")
                },

                { componentType: 'label', prop: "approver.name", label: this.$t('safeDisclosureContent.approver') },
                { componentType: 'label', prop: 'approvalTime', label: this.$t('safeDisclosureContent.approvalTime') },
                { componentType: 'label', prop: 'approvalOpinion', label: this.$t('safeDisclosureContent.approvalOpinion') },

                {
                    label: this.$t("safeDisclosureContent.content"),
                    slotName: 'content',
                },
            ]
        }
    },

    components: { customForm },

    mounted() {
        this.addEventBackButtonBack();
        this.getData();
    }
};
</script>

<style lang="less" scoped type="text/less">
.safeDisclosureContent_detail {
  height: 100%;
  width: 100%;
  background-color: whitesmoke;
  .content {
    overflow: auto;
    -webkit-overflow-scrolling: touch;
  }

  .customForm {
    margin-bottom: 0;
  }

  .content-section {
    background: #fff;
    padding: 0 16px;
  }

  pre {
    margin: 0;
    font-family: sans-serif, PingFang SC, Hiragino Sans GB, Microsoft YaHei,
      Arial;
    color: #333;
  }
}
</style>
