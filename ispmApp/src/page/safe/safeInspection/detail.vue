<!--detail-->
<!--@author LiFanLingJue-->
<!--@date 2018/8/31-->
<template>
<tms-page class="safeInspection_detail c_flex c_direction_v" v-touch:right="rightSlip">
    <nav-bar slot="header" left-arrow :left-text="$t('public.back')" @click-left="toBack" :title="$store.state.offLine ? $t('safeInspection.offLineDetailTitle') : $t('safeInspection.detailTitle')">
    </nav-bar>
    <div class="content c_flex_1" slot="content" ref="content">
        <custom-form :viewFlag="viewFlag" :data="formModel" :config="formConfig" ref="form"></custom-form>
        <van-cell-group v-if="!$store.state.offLine">
            <van-cell :value="$t('safeInspection.view')" :title="$t('safeInspection.photo')" is-link @click="scenePopup"></van-cell>
            <image-upload watermark-type="datetime" :data="attachmentIds" @callback="imageUploadCallback" :maxNumber=10 ref="imageUpload"></image-upload>
        </van-cell-group>
    </div>
    <div slot="footer" v-if="!viewFlag">
        <van-col span="12">
            <!--暂存-->
            <van-button size="large" @click="save('save')">{{$t('public_button.staging')}}</van-button>
        </van-col>
        <van-col span="12">
            <!--提交-->
            <van-button v-if="formModel.inspectionResult =='inspection_result_1'" size="large" @click="save('submit')">{{$t('public_button.submit')}}</van-button>
            <!--整改派单-->
            <van-button v-if="formModel.inspectionResult !='inspection_result_1'" size="large" @click="startRectify">{{$t('safeInspection.rectify')}}</van-button>
        </van-col>
    </div>
</tms-page>
</template>

<script>
import cloneDeep from 'lodash/cloneDeep'
import customForm from 'src/components/custom-form.vue'

import {
    Toast
} from 'vant'
import imageUpload from '../../../components/imageUpload.vue'
import moment from 'moment'
const uri = {
    get: "/safe/safeInspection/get",
    save: "/safe/safeInspection/save",
    getCode: "/safe/safeInspection/getCode",
    getDrawingPoint: '/safe/safeDrawingPoint/getDangerousPoint'
};
export default {

    data() {
        return {
            formModel: {},
            viewFlag: true,
            attachmentIds: []
        };
    },

    methods: {
        //返回上一页
        toBack(e) {
            Toast.clear()
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
        getDrawingPointData() {
            let itemDataId = this.$route.query.pointId;
            /** 查看和编辑操作 */
            if (itemDataId) {
                Toast.loading({
                    mask: true,
                    duration: 0,
                    loadingType: 'spinner'
                });
                this.$axios.post(uri.getDrawingPoint, {
                        id: itemDataId
                    })
                    .then(resp => {
                        this.formModel = Object.assign({}, this.formModel, {
                            safeDrawingPoint: resp
                        });
                        if(resp.auditStatus=='audit_status_3' &&(resp.status =='danger_status_3' || resp.status== 'rail_status_1'))
                        {
                            this.getCode()
                        }
                        else
                        {
                            this.viewFlag = true
                            this.$message(this.$t('safeInspection.getDrawingPointFailTip'));
                        }
                    })
                    .finally(() => {
                        Toast.clear();
                    })
            }
        },
        //获取编号
        getCode() {
            let params = {}
            this.$axios.post(uri.getCode, params).then((response) => {
                    if (response) {
                        this.formModel = Object.assign({}, this.formModel, {
                            inspectionNo: response
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
        startRectify() {
            this.submit('submit', (data) => {
                this.$router.push('/safe/safeInspection/renovate?id=' + data)
            })

        },
        save(submitType) {
            this.submit(submitType, (data) => {
                this.toBack()
            })
        },
        submit(submitType, callback) {
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
                    let userInfo = this.$store.state.accountInfo;
                    submitModel.status = submitType == 'save' ? 'safeInspection_status_1' : 'safeInspection_status_2'
                    submitModel.inspectionMan = {
                        id: userInfo.id,
                        office: {
                            id: userInfo.company.id
                        }
                    };
                    // submitModel.inspectionDate = moment().format('YYYY-MM-DD')+' 00:00:00'

                    let action = this.$route.query.id ? "更新" : "新建";
                    Toast.loading({
                        mask: true,
                        duration: 0,
                        loadingType: 'spinner'
                    });
                    this.$axios.post(uri.save, submitModel)
                        .then(resp => {
                            callback(resp)
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
                    componentType: 'drawingPointList',
                    prop: 'safeDrawingPoint',
                    label: this.$t('safeInspection.items.drawingPointCode'), //标记点编号
                    required: true,
                    componentProp: {
                        url: "/safe/safeDrawingPoint/dangerousPointList",
                        params: {
                            auditStatus: 'audit_status_3',
                            status:'danger_status_3,rail_status_1'
                        },
                        title: this.$t('safeInspection.drawingPointList')
                    },
                    events: {
                        'callback': (data) => {
                            //值修改后的回调函数，返回新的选中Object
                            this.formModel = Object.assign({}, this.formModel, {
                                safeDrawingPoint: data
                            })

                            this.formModel.drawingPointId = data ? data.id : ""
                            if (!this.formModel.inspectionNo) this.getCode()
                            this.addEventBackButtonBack()

                        }
                    }
                },
                {
                    componentType: "label",
                    prop: "safeDrawingPoint.name",
                    label: this.$t("safeInspection.items.drawingPointName"), // 标记点名称
                    componentProp: {
                        maxlength: 64,
                        disabled: true
                    },
                },
                {
                    componentType: "dictPicker",
                    prop: "safeDrawingPoint.signType",
                    dictName: 'sign_type',
                    label: this.$t("safeInspection.items.drawingPointType"), // 标记点分类
                    componentProp: {
                        maxlength: 64,
                        disabled: true
                    },
                },
                {
                    componentType: "dictPicker",
                    prop: "safeDrawingPoint.status",
                    dictName: this.formModel.signType=='sign_type_2'?'rail_status':'danger_status',
                    label: this.$t("safeInspection.items.status"), // 标记点状态
                    componentProp: {
                        maxlength: 64,
                        disabled: true
                    },
                },
                {
                    componentType: 'bizDictPicker',
                    prop: 'safeDrawingPoint.drawing.region',
                    label: this.$t('drawing.region'), //区域
                    dictName: 'region',
                    selectCode: 'id',
                    displayCode: 'name',
                    componentProp: {
                        disabled: true
                    }
                },
                {
                    componentType: 'bizDictPicker',
                    prop: 'safeDrawingPoint.drawing.building',
                    label: this.$t('drawing.building'), //楼宇
                    dictName: 'building',
                    selectCode: 'id',
                    displayCode: 'name',
                    componentProp: {
                        disabled: true
                    }
                },
                {
                    componentType: 'dictPicker',
                    prop: 'safeDrawingPoint.drawing.subdivision',
                    label: this.$t('drawing.subdivision'), //分部分项
                    dictName: 'subdivision',
                    componentProp: {
                        disabled: true
                    }
                },
                {
                    componentType: 'bizDictPicker',
                    prop: 'safeDrawingPoint.drawing.layer',
                    label: this.$t('drawing.layer'), //楼层
                    dictName: 'layer',
                    selectCode: 'id',
                    displayCode: 'name',
                    componentProp: {
                        disabled: true
                    }
                },
                {
                    componentType: "label",
                    prop: "inspectionNo",
                    label: this.$t("safeInspection.inspectionNo"), // 巡查单号
                },
                {
                    componentType: "dictPicker",
                    prop: "inspectionResult",
                    dictName: 'inspection_result',
                    label: this.$t("safeInspection.inspectionResult"), // 巡查结论
                    required: true
                },
                {
                    componentType: "input",
                    prop: "remarks",
                    label: this.$t("safeInspection.remarks"), // 备注
                    componentProp: {
                        type: "textarea",
                        maxlength: 1000
                    }
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
        this.$route.query.model == "view" ? this.viewFlag = true : this.viewFlag = false
        if (this.$route.query.id) this.getData();
        if (this.$route.query.pointId) this.getDrawingPointData();
        

    }
};
</script>

<style lang="less" scoped>
.safeInspection_detail {
    height: 100%;
    width: 100%;
    background-color: whitesmoke;

    .content {
        overflow: auto;
        -webkit-overflow-scrolling: touch;
    }
}
</style>
