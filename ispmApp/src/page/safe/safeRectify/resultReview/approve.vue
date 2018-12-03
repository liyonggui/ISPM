<!--approve-->
<!--@author LiFanLingJue-->
<!--@date 2018/9/4-->
<template>
<div class="safeRectify_result c_flex c_direction_v" v-touch:right="rightSlip">
    <nav-bar left-arrow :left-text="$t('public.back')" @click-left="toBack" :title="$t('safeRectify.rectifyResultReview')">
    </nav-bar>
    <div class="content c_flex_1" ref="content">
        <custom-form :data="formModel" :config="formConfig_1" viewFlag></custom-form>
        <van-panel  style="margin-bottom: .1rem">
            <image-preview :data="attachmentIds"></image-preview>
        </van-panel>

        <custom-form :data="formModel" :config="formConfig_2" viewFlag></custom-form>
        <van-panel   style="margin-bottom: .1rem;">
            <image-preview :data="attachmentIds_1"></image-preview>
        </van-panel>

        <custom-form :data="formModel" :config="formConfig_3" ref="customForm"></custom-form>
        <van-cell-group v-if="!$store.state.offLine">
            <van-cell value="查看" title="整改照片" is-link @click="scenePopup"></van-cell>
            <image-upload :maxNumber=10 :data="attachmentIds_2" @callback="imageUploadCallback" ref="imageUpload"></image-upload>
        </van-cell-group>

        <van-row>
            <!--整改驳回-->
            <van-col span="12">
                <van-button size="large" type="danger" :block="true" @click="check('N')">{{$t('operation.dismiss')}}</van-button>
            </van-col>
            <!--整改通过-->
            <van-col span="12">
                <van-button size="large" :block="true" @click="check('Y')">{{$t('operation.pass')}}</van-button>
            </van-col>
        </van-row>

    </div>
</div>
</template>

<script>
import cloneDeep from 'lodash/cloneDeep'
import customForm from 'src/components/custom-form.vue'

import {
    Toast
} from 'vant'
import imageUpload from 'src/components/imageUpload.vue'
import imagePreview from 'src/components/imagePreview.vue'
import moment from 'moment'

const uri = {
    check: "/activiti/safeRectify/check",
    getRectify: "/activiti/safeRectify/getCheck"
};
export default {
    data() {
        return {
            formModel: {
                office: {},
                rectifyMan: {},
                checkMan: {},
                reviewMan: {},
            },

            attachmentIds: [],
            attachmentIds_1: [],
            attachmentIds_2: []
        };
    },

    methods: {
        //返回上一页
        toBack(e) {
            this.$router.go(-1)
        },
        getData() {
            /** 获取整改信息 */
            let itemDataId = this.$route.query.id
            Toast.loading({
                mask: true,
                duration: 0,
                loadingType: 'spinner'
            })
            this.$axios.post(uri.getRectify, {
                    id: itemDataId
                })
                .then(resp => {
                    this.formModel = resp
                    // if(resp.safeRectifyDeal.remarks)
                    // { this.formModel = Object.assign( {}, this.formModel,{remarks:resp.safeRectifyDeal.remarks})}
                    if (resp.safeRectifyDeal) {
                        this.formModel.rectifyTime = moment(resp.safeRectifyDeal.rectifyDate).format('YYYY-MM-DD HH:mm:ss')
                        this.formModel.rectifyResult = resp.safeRectifyDeal.rectifyResult
                        this.formModel.safeRectifyDeal.id = resp.safeRectifyDeal.id
                    }
                    if (!resp.office) {
                        this.formModel.office = {
                            name: null
                        }
                    }

                    // 获取新建整改时存的一堆图片
                    if (resp.items && resp.items.length > 0) {
                        this.attachmentIds = resp.items.map(item => {
                            return item.attachment.id
                        })
                    }

                    // 获取编辑整改结果时存的一堆图片
                    if (resp.safeRectifyDeal && resp.safeRectifyDeal.items && resp.safeRectifyDeal.items.length > 0) {
                        this.attachmentIds_1 = resp.safeRectifyDeal.items.map(item => {
                            return item.attachment.id
                        })
                    }

                    // 获取编辑整改复查时存的一堆图片
                    if (resp.safeRectifyDeal && resp.safeRectifyDeal.itemsChecked && resp.safeRectifyDeal.itemsChecked.length > 0) {
                        this.attachmentIds_2 = resp.safeRectifyDeal.itemsChecked.map(item => {
                            return item.attachment.id
                        })
                    }
                })
                .finally(() => {
                    Toast.clear()
                })
        },
        check(flag) {
            this.$refs.customForm.validate(valid => {
                if (valid) {
                    let submitModel = {};
                    submitModel.rectifyId = this.formModel.id;
                    submitModel.remarks = cloneDeep( this.formModel.remarks);
                    submitModel.comment = cloneDeep( this.formModel.remarks);
                    submitModel.pass = flag;
                    submitModel.id = this.formModel.safeRectifyDeal.id;

                    submitModel.items = this.attachmentIds_2.map(item => {
                        return {
                            attachment: {
                                id: item
                            },
                            rectifyId: this.formModel.id
                        }
                    });

                    //审核时：拼接工作流的的行数据
                    submitModel.procInsId = this.formModel.procInsId;
                    submitModel.taskDefKey = this.formModel.taskDefKey;
                    submitModel.taskId = this.formModel.taskId;
                    submitModel.variable = this.formModel.variable

                    Toast.loading({
                        mask: true,
                        duration: 0,
                        loadingType: 'spinner'
                    });

                    this.$axios.post(uri.check, submitModel)
                        .then(resp => {
                            Toast.clear();
                            Toast.success(this.$t('operationTips.saveSuccess'));
                            this.toBack()
                        })
                        .catch(() => {
                            Toast.clear()
                        })
                }
            })
        },

        scenePopup() {
            this.$refs.imageUpload.show = true;

        },
        imageUploadCallback(attachments) {
            this.attachmentIds_2 = attachments;
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
                    componentType: 'userList',
                    prop: 'rectifyMan',
                    label: this.$t('safeRectify.rectifyMan'), //整改责任人
                    componentProp: {
                        url: "/project/projectUserRole/list",
                        title: this.$t('safeRectify.rectifyMan'),
                    },
                    required: true,
                    events: {
                        'callback': (data) => {
                            //值修改后的回调函数，返回新的选中Object
                            this.formModel = Object.assign({}, this.formModel, {
                                rectifyMan: data.user
                            })
                            this.addEventBackButtonBack()
                        }
                    }
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
                    componentType: 'label',
                    prop: 'drawingPoint.code',
                    label: this.$t('safeRectify.pointCode'), //标记点编号
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
                    label: this.$t('safeRectify.createDate'),//检查时间
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
                    componentType: 'DatetimePicker',
                    prop: 'rectifyTime',
                    label: this.$t('safeRectify.rectifyTime'), //整改时间
                    required: true,
                    viewFormat: (data) => {
                        return data.rectifyTime ? data.rectifyTime.slice(0, 10) : null
                    },
                    componentProp: {
                        type: 'date'
                    },
                },
                {
                    componentType: 'input',
                    prop: 'rectifyResult',
                    label: this.$t("safeRectify.rectifyResult"), // 整改结果
                    componentProp: {
                        type: "textarea",
                        maxlength: 1000
                    },
                    required: true
                }
            ]
        },
        formConfig_3() {
            return [{
                componentType: 'input',
                prop: 'remarks',
                label: this.$t("safeRectify.remarks"), // 备注
                componentProp: {
                    type: "textarea",
                    maxlength: 1000
                },
                required: true
            }]
        }
    },
    components: {
        customForm,
        imageUpload,
        imagePreview
    },
    mounted() {
        this.addEventBackButtonBack();
        this.getData();
    }
};
</script>

<style lang="less">
.safeRectify_result {
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
