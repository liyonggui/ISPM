<!--info-->
<!--@author LiFanLingJue-->
<!--@date 2018/9/3-->
<template>
<div class="safeRectify_info c_flex c_direction_v">
    <nav-bar ref="navBar" left-arrow :left-text="$t('public.back')" @click-left="toBack" :title="$t('safeRectify.infoTitle')">
    </nav-bar>
    <div class="content c_flex_1" ref="content">
        <van-tabs v-model="active" sticky @click="tabClick" :offset-top="navBarHeight">
            <van-tab title="整改信息">
                <custom-form :data="formModel_1" :config="formConfig_1" :viewFlag="true"></custom-form>
                <van-panel  >
                    <image-preview :data="attachmentIds_1"></image-preview>
                </van-panel>
            </van-tab>
            <van-tab title="整改结果">
                <custom-form :data="formModel_2" :config="formConfig_2" :viewFlag="true"></custom-form>
                <van-panel  >
                    <image-preview :data="attachmentIds_2"></image-preview>
                </van-panel>
            </van-tab>
            <van-tab title="整改复查">
                <custom-form :data="formModel_3" :config="formConfig_3" :viewFlag="true"></custom-form>
                <van-panel  >
                    <image-preview :data="attachmentIds_3"></image-preview>
                </van-panel>
            </van-tab>
            <van-tab v-if="formModel_1.procInsId" title="审批历史">
                    <task-histoicflow :procInsId="formModel_1.procInsId"> </task-histoicflow>
            </van-tab>
        </van-tabs>
    </div>
</div>
</template>

<script>
import cloneDeep from 'lodash/cloneDeep'
import customForm from 'src/components/custom-form.vue'

import {
    Toast
} from 'vant'
import imagePreview from 'src/components/imagePreview.vue'
import moment from 'moment'
import taskHistoicflow from 'src/components/taskHistoicflow.vue'

const uri = {
    tab1: '/safe/safeRectify/get',
    tab2: '/activiti/safeRectify/detail/result',
    tab3: '/activiti/safeRectify/detail/check'
};
export default {
    components: {
        customForm,
        imagePreview,
        taskHistoicflow
    },
    data() {
        return {
            active: 0,

            formModel_1: {
                office: {},
                rectifyMan: {},
                checkMan: {},
                reviewMan: {}
            },
            attachmentIds_1: [],

            formModel_2: {},
            attachmentIds_2: [],

            formModel_3: {},
            attachmentIds_3: [],
            navBarHeight: 0
        };
    },

    methods: {
        //返回上一页
        toBack() {
            this.$router.go(-1)
        },
        tabClick(index) {
            eval(`this.getData_${index + 1}()`);
        },

        getData_1() {
            let itemDataId = this.$route.query.id;
            if (itemDataId) {
                Toast.loading({
                    mask: true,
                    duration: 0,
                    loadingType: 'spinner'
                });
                this.$axios.post(uri.tab1, {
                        id: itemDataId
                    }, {
                        _cache: 'safeRectify'
                    })
                    .then(resp => {
                        if (resp) {
                            this.formModel_1 = resp
                            if (this.formModel_1.rectifyDate) {
                                this.formModel_1.rectifyDate = resp.rectifyDate.substring(0, 10)
                            }
                            if (resp.items && resp.items.length > 0) {
                                this.attachmentIds_1 = resp.items.map(item => {
                                    return item.attachment.id
                                })
                            }
                        }
                    })
                    .finally(() => {
                        Toast.clear();
                    })
            }
        },
        getData_2() { // 获取整改结果信息
            Toast.loading({
                mask: true,
                duration: 0,
                loadingType: 'spinner'
            });
            let itemDataId = this.$route.query.id;
            this.$axios.post(uri.tab2 + "?id=" + itemDataId)
                .then(resp => {
                    if (resp) {
                        this.formModel_2 = resp;
                        if (resp.items && resp.items.length > 0) {
                            this.attachmentIds_2 = resp.items.map(item => {
                                return item.attachment.id
                            })
                        }
                    }
                })
                .finally(() => {
                    Toast.clear();
                })
        },
        getData_3() { // 获取整改结果复查信息
            Toast.loading({
                mask: true,
                duration: 0,
                loadingType: 'spinner'
            });
            let itemDataId = this.$route.query.id;
            this.$axios.post(uri.tab3 + "?id=" + itemDataId)
                .then(resp => {
                    if (resp) {
                        this.formModel_3 = resp;
                        if (resp.items && resp.items.length > 0) {
                            this.attachmentIds_3 = resp.items.map(item => {
                                return item.attachment.id
                            })
                        }
                    }
                })
                .finally(() => {
                    Toast.clear();
                })
        },
        getData_4() {},

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
        formConfig_1() {
            return [{
                    componentType: 'bizDictPicker',
                    prop: 'region',
                    label: this.$t('drawing.region'), //区域
                    dictName: 'region',
                    selectCode: 'id',
                    displayCode: 'name',
                    required: true,
                    disabled: true
                },
                {
                    componentType: 'bizDictPicker',
                    prop: 'building',
                    label: this.$t('drawing.building'), //楼宇
                    dictName: 'building',
                    selectCode: 'id',
                    displayCode: 'name',
                },
                {
                    componentType: 'dictPicker',
                    prop: 'subdivision',
                    label: this.$t('drawing.subdivision'), //分部分项
                    dictName: 'subdivision',
                },
                {
                    componentType: 'bizDictPicker',
                    prop: 'layer',
                    label: this.$t('drawing.layer'), //楼层
                    dictName: 'layer',
                    selectCode: 'id',
                    displayCode: 'name',
                },
                {
                    componentType: "dictPicker",
                    prop: "type",
                    dictName: 'rectify_type',
                    label: this.$t("safeRectify.rectifyType"), // 整改单分类
                    required: true
                },
                {
                    componentType: "input",
                    prop: "issuePosition",
                    label: this.$t("safeRectify.issuePosition"), // 标记点名称
                },
                {
                    componentType: 'label',
                    prop: 'drawingPoint.code',
                    label: this.$t('safeRectify.pointCode'), //标记点编号
                },
                {
                    componentType: "input",
                    prop: "issuePositionRemarks",
                    componentProp: {
                        type: "textarea",
                        maxlength: 1000
                    },
                    label: this.$t("safeRectify.issuePositionRemarks"), // 问题位置描述
                },
                {
                    componentType: "input",
                    prop: "issueRemarks",
                    componentProp: {
                        type: "textarea",
                        maxlength: 1000
                    },
                    label: this.$t("safeRectify.issueRemarks"), // 存在问题
                },
                {
                    componentType: 'dictPicker',
                    prop: 'seriousLevel',
                    label: this.$t('safeRectify.seriousLevel'), //严重程度
                    dictName: 'serious_level',
                    required: true,
                },
                {
                    componentType: 'label',
                    prop: 'rectifyMan.name',
                    label: this.$t('safeRectify.rectifyMan'), //整改责任人

                },
                {
                    componentType: 'DatetimePicker',
                    prop: 'rectifyLaunchDate',
                    viewFormat: (data) => {
                        return data.rectifyLaunchDate ? data.rectifyLaunchDate.slice(0, 10) : null
                    },
                    label: this.$t('safeRectify.rectifyLaunchDate'), //整改发起日期
                    componentProp: {
                        type: 'date'
                    },
                    required: true
                },
                {
                    componentType: 'DatetimePicker',
                    prop: 'rectifyDate',
                    viewFormat: (data) => {
                        return data.rectifyDate ? data.rectifyDate.slice(0, 10) : null
                    },
                    label: this.$t('safeRectify.rectifyDate'), //要求完成整改时限
                    componentProp: {
                        type: 'date'
                    },
                    required: true
                },
                {
                    componentType: "input",
                    prop: "rectifyListName",
                    label: this.$t("safeRectify.rectifyListName"), // 整改单名称
                },
                {
                    componentType: "input",
                    prop: "rectifyListCode",
                    label: this.$t("safeRectify.rectifyListCode"), // 整改单编号
                },
                {
                    componentType: 'label',
                    prop: "checkMan.name",
                    label: this.$t('safeRectify.checkMan') //检查人
                },
                {
                    componentType: 'label',
                    prop: "office.name",
                    label: this.$t('safeRectify.office') //责任单位
                },
                {
                    componentType: 'DatetimePicker',
                    prop: 'createDate',
                    viewFormat: (data) => {
                        return data.createDate ? data.createDate.slice(0, 10) : null
                    },
                    label: this.$t('safeRectify.createDate'), //检查时间
                    componentProp: {
                        type: 'date'
                    },
                    required: true
                },
                {
                    componentType: 'label',
                    prop: "reviewMan.name",
                    label: this.$t('safeRectify.reviewMan') //复查人
                },
                {
                    componentType: "input",
                    prop: "rectifyOpinions",
                    label: this.$t("safeRectify.rectifyOpinions"), // 整改意见
                    componentProp: {
                        type: "textarea",
                        maxlength: 1000
                    },
                    required: true
                }
            ]
        },
        formConfig_2() {
            return [{
                    componentType: 'label',
                    prop: 'rectifyDate',
                    label: this.$t('safeRectify.rectifyTime'), // 整改时间
                    viewFormat: (data) => {
                        return data.rectifyDate ? moment(data.rectifyDate).format('YYYY-MM-DD HH:mm:ss') : data.rectifyDate;
                    }
                },
                {
                    componentType: 'label',
                    prop: 'rectifyResult',
                    label: this.$t('safeRectify.rectifyResult') // 整改结果
                }
            ]
        },
        formConfig_3() {
            return [{
                componentType: 'label',
                prop: 'remarks',
                label: this.$t('safeRectify.remarks') // 备注
            }]
        }
    },

    mounted() {
        this.addEventBackButtonBack();
        this.getData_1();
        this.navBarHeight = this.$refs.navBar.$el.clientHeight
    }
};
</script>

<style lang="less">
.safeRectify_info {
    height: 100%;
    width: 100%;
    background-color: whitesmoke;

    .content {
        overflow: auto;
        -webkit-overflow-scrolling: touch;

        .van-cell:not(:last-child):after {
            border-bottom-width: 0;
        }
    }
}
</style>
