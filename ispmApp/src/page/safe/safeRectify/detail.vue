<!--detail-->
<!--@author LiFanLingJue-->
<!--@date 2018/8/31-->
<template>
<div class="safeRectify_detail c_flex c_direction_v" v-touch:right="rightSlip">
    <nav-bar left-arrow :left-text="$t('public.back')" @click-left="toBack" :right-text="$t('public_button.save')" @click-right="submit" :title="$store.state.offLine ? $t('safeRectify.offLineDetailTitle') : $t('safeRectify.detailTitle')">
    </nav-bar>
    <div class="content c_flex_1" ref="content">
        <custom-form :data="formModel" :config="formConfig" ref="form"></custom-form>
        <van-cell-group v-if="!$store.state.offLine">
            <van-cell value="查看" title="整改照片" is-link @click="scenePopup"></van-cell>
            <image-upload watermark-type="datetime" :data="attachmentIds" @callback="imageUploadCallback" :maxNumber=10 ref="imageUpload"></image-upload>
        </van-cell-group>
    </div>
</div>
</template>

<script>
import cloneDeep from 'lodash/cloneDeep'
import customForm from 'src/components/custom-form.vue'

import {
    Toast
} from 'vant'
import imageUpload from '../../../components/imageUpload.vue'

const uri = {
    get: "/safe/safeRectify/get",
    save: "/safe/safeRectify/save",
    update: "/safe/safeRectify/update",
    getCode: "/safe/safeRectify/getCode"
};
export default {
    props: {
        itemData: {
            type: Object
        },
        detailType: {
            type: String
        }
    },
    data() {
        return {
            formModel: {
                rectifyMan: {}
            },

            attachmentIds: []
        };
    },

    methods: {
        //返回上一页
        toBack(e) {
            this.$router.go(-1)
        },
        getData() {
            let itemDataId = this.$route.query.id;
            /** 查看和编辑操作 */
            if (itemDataId) {
                Toast.loading({
                    mask: true,
                    duration: 0,
                    loadingType: 'spinner'
                });
                this.$axios.post(uri.get, {
                        id: itemDataId
                    }, {
                        _cache: 'safeRectify'
                    })
                    .then(resp => {
                        this.formModel = resp;
                        if (resp.items && resp.items.length > 0) {
                            this.attachmentIds = resp.items.map(item => {
                                return item.attachment.id
                            })
                        }
                    })
                    .finally(() => {
                        Toast.clear();
                    })
            }
        },
        //获取整改单编号
        getCode() {
            let params = {}
            this.$axios.post(uri.getCode, params).then((response) => {
                    if (response) {
                        this.formModel = Object.assign({}, this.formModel, {
                            rectifyListCode: response
                        })
                    } else {
                        let msg = this.$t('safe_drawing_point.codeErrorMsg')
                        this.$Message.error(msg)
                    }

                })
                .catch(err => {
                    console.log('catch')
                    console.log(err)
                })
        },
        submit() {
            this.$refs.form.validate((valid) => {
                if (valid) {

                    let submitModel = cloneDeep(this.formModel);

                    submitModel.items = this.attachmentIds.map(item => {
                        return {
                            attachment: {
                                id: item
                            }
                        }
                    });
                    submitModel.status = 'rectify_status_0';
                    let userInfo = this.$store.state.accountInfo;

                    submitModel.checkMan = {
                        id: userInfo.id
                    };
                    submitModel.office = {
                        id: userInfo.company.id
                    };
                    submitModel.reviewMan = {
                        id: userInfo.id
                    };
                    let action = this.$route.query.id ? "更新" : "新建";
                    Toast.loading({
                        mask: true,
                        duration: 0,
                        loadingType: 'spinner'
                    });
                    this.$axios.post(this.$route.query.id ? uri.update : uri.save, submitModel, {
                            _queue: true,
                            _queueConfig: {
                                page: '整改详情',
                                action: action
                            }
                        })
                        .then(resp => {
                            Toast.clear();
                            Toast.success(this.$t('operationTips.saveSuccess'));
                            this.toBack()
                        })
                        .catch(() => {
                            Toast.clear();
                        })
                }
            });
        },

        scenePopup() {
            this.$refs.imageUpload.show = true;

        },
        imageUploadCallback(attachments) {
            this.attachmentIds = attachments
            this.addEventBackButtonBack()
            // alert(this.attachmentIds.length)
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
            return [{
                    componentType: 'bizDictPicker',
                    prop: 'region',
                    label: this.$t('drawing.region'), //区域
                    dictName: 'region',
                    selectCode: 'id',
                    displayCode: 'name',
                    required: true,
                    componentProp: {
                        disabled: this.formModel.drawingPoint
                    }
                },
                {
                    componentType: 'bizDictPicker',
                    prop: 'building',
                    label: this.$t('drawing.building'), //楼宇
                    dictName: 'building',
                    selectCode: 'id',
                    displayCode: 'name',
                    componentProp: {
                        disabled: this.formModel.drawingPoint
                    }
                },
                {
                    componentType: 'dictPicker',
                    prop: 'subdivision',
                    label: this.$t('drawing.subdivision'), //分部分项
                    dictName: 'subdivision',
                    componentProp: {
                        disabled: this.formModel.drawingPoint
                    }
                },
                {
                    componentType: 'bizDictPicker',
                    prop: 'layer',
                    label: this.$t('drawing.layer'), //楼层
                    dictName: 'layer',
                    selectCode: 'id',
                    displayCode: 'name',
                    componentProp: {
                        disabled: this.formModel.drawingPoint
                    }
                },
                {
                    componentType: "dictPicker",
                    prop: "type",
                    dictName: 'rectify_type',
                    label: this.$t("safeRectify.rectifyType"), // 整改单分类
                    required: true,
                    events: {
                        'change': (data) => {
                            //值修改后的回调函数，返回新的选中Object
                            if (this.formModel.drawingPoint) {
                                this.formModel = Object.assign({}, this.formModel, {
                                    drawingPoint: ""
                                })
                                this.formModel.region = null
                                this.formModel.building = null
                                this.formModel.subdivision = null
                                this.formModel.layer = null
                                this.formModel.issuePosition = null
                                this.formModel.drawingPointId = null
                            }

                        }
                    }
                },
                {
                    componentType: 'drawingPointList',
                    prop: 'drawingPoint',
                    label: this.$t('safeRectify.pointCode'), //标记点编号
                    componentProp: {
                        url: '/safe/safeDrawingPoint/rectifyDangerousPointList',
                        title: this.$t('safeRectify.rectifyListTitle')
                    },
                    events: {
                        'callback': (data) => {
                            //值修改后的回调函数，返回新的选中Object
                            this.formModel = Object.assign({}, this.formModel, {
                                drawingPoint: data
                            })
                            this.formModel.region = data ? data.drawing.region : ""
                            this.formModel.building = data ? data.drawing.building : ""
                            this.formModel.subdivision = data ? data.drawing.subdivision : ""
                            this.formModel.layer = data ? data.drawing.layer : ""
                            this.formModel.issuePosition = data ? data.name : ""
                            this.formModel.drawingPointId = data ? data.id : ""
                            this.addEventBackButtonBack()
                        }
                    }
                },
                {
                    componentType: "input",
                    prop: "issuePosition",
                    label: this.$t("safeRectify.issuePosition"), // 标记点名称
                    componentProp: {
                        maxlength: 64,
                        disabled: this.formModel.drawingPoint
                    },
                },
                {
                    componentType: "input",
                    prop: "issuePositionRemarks",
                    componentProp: {
                        type: "textarea",
                        maxlength: 1000
                    },
                    label: this.$t("safeRectify.issuePositionRemarks"), // 问题位置描述
                    required: true,
                },
                {
                    componentType: "input",
                    prop: "issueRemarks",
                    componentProp: {
                        type: "textarea",
                        maxlength: 1000
                    },
                    label: this.$t("safeRectify.issueRemarks"), // 存在问题
                    required: true,
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
                    required: true,
                    componentProp: {
                        maxlength: 64
                    },
                },
                {
                    componentType: "input",
                    prop: "rectifyListCode",
                    label: this.$t("safeRectify.rectifyListCode"), // 整改单编号
                    required: true,
                    componentProp: {
                        maxlength: 64,
                        disabled: true
                    },
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
        }
    },
    components: {
        customForm,
        imageUpload
    },
    mounted() {
        this.addEventBackButtonBack();
        if (this.$route.query.id) {
            this.getData();
        } else {
            this.getCode();
        }

    }
};
</script>

<style lang="less" scoped>
.safeRectify_detail {
    height: 100%;
    width: 100%;
    background-color: whitesmoke;

    .content {
        overflow: auto;
        -webkit-overflow-scrolling: touch;
    }
}
</style>
