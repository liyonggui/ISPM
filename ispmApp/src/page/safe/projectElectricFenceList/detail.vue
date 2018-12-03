<template>
<tms-page>
    <nav-bar slot="header" left-arrow :left-text="$t('public.back')" @click-left="toBack" :title="$t('electric_fence_list.projectRouterTitle') ">
        <div slot="right" v-if="formModel.auditStatus=='audit_status_4' || formModel.auditStatus=='audit_status_1'" class="van-nav-bar__text">
            <van-icon style="font-size: .2rem;margin-right: .05rem" name="edit" @click="isEdit=!isEdit" v-permission="$permission.danger_rail_list.edit" />
        </div>
    </nav-bar>
    <div slot="content">
        <van-cell-group>
            <!--设计图名称-->
            <van-cell required :title="$t('safe_drawing_point.drawingName')" :value="formModel.drawing.name" :is-link="viewModel=='create'" @click="onShowDrawingPopup" />
            <!--设计图编号-->
            <van-cell  :style="formModel.drawing.id?'color:blue':''" :is-link="!!formModel.drawing.id" :title="$t('safe_drawing_point.drawingCode')" :value="formModel.drawing.code"   @click="onLinktoDrawing(formModel)" />
            <!--区域-->
            <van-cell :title="$t('safe_drawing_point.region')" :value="$bizTranslate({key: 'region', value: formModel.drawing.region}).name" />
            <!--楼宇-->
            <van-cell :title="$t('safe_drawing_point.building')" :value="$bizTranslate({key: 'building', value: formModel.drawing.building}).name" />
            <!--分部分项-->
            <van-cell :title="$t('safe_drawing_point.subdivision')" :value="$translate({key: 'subdivision', value: formModel.drawing.subdivision})" />
            <!--楼层-->
            <van-cell :title="$t('safe_drawing_point.layer')" :value="$bizTranslate({key: 'layer', value: formModel.drawing.layer}).name" />

            <!--危险点名称-->
            <van-field :maxlength="100"  @blur="formModel.name=formModel.name.trim()"  :disabled="!isEdit" required input-align="right" :label=" $t('electric_fence_list.railName')" :placeholder="isEdit?$t('electric_fence_list.railNameHit'):''" v-model="formModel.name" />
            <!--危险点编号-->
            <van-cell :title="$t('electric_fence_list.railCode')" :value="formModel.code" />
            <!--危险点二维码-->
            <van-field :maxlength="100" v-model="formModel.qrCode"  @blur="formModel.qrCode=formModel.qrCode.trim()" input-align="right" :disabled="!isEdit" :label="$t('safe_drawing_point.showQRCode')" :placeholder="isEdit?$t('electric_fence_list.barCodeHit'):''">
                <van-icon style="font-size: 20px;" slot="button" name="qr" v-if="isEdit" @click="scanHandler" />
            </van-field>
            <!--绑定设备-->
            <van-cell :title="$t('electric_fence_list.device')" :value="getSelectTranslate(formModel.projectEquRegister)" :is-link="isEdit" @click="onShowDevicePopup" />
            <van-popup ref="devicePopup" v-model="showDevicePopup" lock-scroll position="bottom">
                <van-picker ref="devicePicker" show-toolbar value-key="label" :columns="deviceColumns" @cancel="showDevicePopup=false" @confirm="onDevicePickerConfirm" />
            </van-popup>
            <!--危险点分类-->
            <van-cell required :title="$t('electric_fence_list.drawingPointType')" :value="$translate({key: 'rail_type', value: formModel.drawingPointType})" :is-link="isEdit" @click="onShowPointTypePopup" />
            <van-popup ref="pointTypePopup" v-model="showPointTypePopup" lock-scroll position="bottom">
                <van-picker ref="pointTypePicker" value-key="label" :columns="pointTypeColumns" @change="onPointTypePickerConfirm" />
            </van-popup>
            <!--登记时间-->
            <van-cell required :title="$t('safe_drawing_point.registerDate')" :value="formModel.regiserDate" :is-link="isEdit" @click="onShowDatePicker" />
            <van-popup v-model="datePickerShowFlag" lock-scroll position="bottom">
                <van-datetime-picker v-model="currentDate" type="datetime" @confirm="datePickerConfirm" @cancel="datePickerShowFlag = false" />
            </van-popup>
            <!--危险点性质-->
            <van-cell required :title="$t('electric_fence_list.pointProperty')" :value="$translate({key: 'point_property', value: formModel.pointProperty})" :is-link="isEdit" @click="onShowPointPropertyPopup" />
            <van-popup v-model="showPointPropertyPopup" lock-scroll position="bottom">
                <van-picker ref="pointPropertyPicker" value-key="label" :columns="pointPropertyColumns" @change="onPointPropertyPickerConfirm" />
            </van-popup>
            <!--危险点状态-->
            <van-cell required :title="$t('electric_fence_list.status')" :value="$translate({key: 'rail_status', value: formModel.status})" :is-link="isEdit" @click="onShowPointStatusPopup" />
            <van-popup v-model="showPointStatusPopup" lock-scroll position="bottom">
                <van-picker ref="pointStatusPicker" value-key="label" :columns="pointStatusColumns" @change="onPointStatusPickerConfirm" />
            </van-popup>
            <!--危险点描述-->
            <van-field :disabled="!isEdit"   @blur="formModel.remarks=formModel.remarks.trim()"  :maxlength="1000" type="textarea" autosize input-align="right" :label="$t('electric_fence_list.remarks')" :placeholder="isEdit?$t('electric_fence_list.remarksHit'):''" v-model="formModel.remarks" />
            <!--审核意见-->
            <van-field type="textarea"  @blur="formModel.comment=formModel.comment.trim()"   :maxlength="1000" v-if="viewModel=='submitAudit'&&formModel.auditStatus=='audit_status_2'" autosize input-align="right" :label="$t('safe_drawing_point.auditRemarks')" :placeholder="$t('safe_drawing_point.auditRemarks')" v-model="formModel.comment" />
        </van-cell-group>
        <!--审批历史-->
        <van-cell-group v-if="viewModel=='view' && formModel.auditStatus != 'audit_status_1'" style="margin-top: 0.1rem;">
            <task-histoicflow :procInsId="formModel.procInsId"> </task-histoicflow>
        </van-cell-group>

    </div>
    <div slot="footer">
        <van-button size="large" v-if="isEdit" @click="submit">{{$t('public_button.save')}}</van-button>
        <van-row v-if="viewModel=='submitAudit'&&formModel.auditStatus=='audit_status_2'">
            <!--审批驳回-->
            <van-col span="12">
                <van-button size="large" type="danger" :block="true" @click="approveAudit('N')">{{$t('operation.dismiss')}}</van-button>
            </van-col>
            <!--审批通过-->
            <van-col span="12">
                <van-button size="large" :block="true" @click="approveAudit('Y')">{{$t('operation.pass')}}</van-button>
            </van-col>
        </van-row>
        <van-row v-if="formModel.auditStatus=='audit_status_4'&&isEdit==false">
            <!--审核撤回-->
            <van-col span="12">
                <van-button size="large" :block="true" @click="approveAudit('N')">{{$t('operation.withdraw')}}</van-button>
            </van-col>
            <!--审核重新提交-->
            <van-col span="12">
                <van-button size="large" :block="true" @click="approveAudit('Y')">{{$t('operation.resubmit')}}</van-button>
            </van-col>
        </van-row>
        <barcode @callback="scanSuccess" ref="barcode"></barcode>
        <!--设计图列表-->
        <drawing-list ref="drawingList" @callback="onSelectDrawing"></drawing-list>
    </div>
</tms-page>
</template>

<script>
import {
    Toast
} from 'vant'
import moment from 'moment'
import config from 'src/config/devconfig'
import cloneDeep from "lodash/cloneDeep"
import barcode from '../../../components/barcode.vue'
import taskHistoicflow from '../../../components/taskHistoicflow.vue'
import drawingList from '../../../components/drawingList.vue'

const uri = {
    save: "/safe/safeDrawingPoint/saveElectricFencePoint",
    update: "/safe/safeDrawingPoint/updateElectricFencePoint",
    getCode: "/safe/safeDrawingPoint/getCode",
    get: "/safe/safeDrawingPoint/getElectricFencePoint",
    getDrawing: "/project/drawing/get",
    sumitAudit: "/safe/safeDrawingPoint/submit/",
    completeAudit: "/safe/safeDrawingPoint/complete/"
}
export default {
    components: {
        barcode,
        taskHistoicflow,
        drawingList
    },
    data() {
        return {
            //危险点分类
            showPointTypePopup: false,
            pointTypeColumns: [],
            //危险点性质
            showPointPropertyPopup: false,
            pointPropertyColumns: [],
            //危险点状态
            showPointStatusPopup: false,
            pointStatusColumns: [],
            //登记时间
            datePickerShowFlag: false,
            currentDate: new Date(),
            //设计图
            showDrawingPopup: false,
            drawingColumns: [],
            //设备
            showDevicePopup: false,
            deviceColumns: [],

            isEdit: true,
            formModel: {
                drawing: {
                    region: '',
                    building: '',
                    layer: '',
                    name: ''
                }
            },
            viewModel: '',
        }
    },

    methods: {
        toBack() {
            if (this.$route.query.rPath == 'plist') this.$router.push('/danger_rail_list')
            else this.$router.push('/task/todo/list')
        },
        //获取图纸信息
        getDrawing() {
            if (this.formModel.drawing.id) {
                let params = {
                    id: this.formModel.drawing.id
                }
                this.$axios.post(uri.getDrawing, params).then((response) => {
                        if (response.attachment.id) {
                            Object.assign(this.formModel, {
                                attachmentId: response.attachment.id
                            })
                        } else {
                            let msg = this.$t('safe_drawing_point.codeErrorMsg')
                            this.$message.error(msg)
                        }

                    })
                    .catch(err => {
                        console.log('catch')
                        console.log(err)
                    })
            }
        },
       //跳转到图纸页面
        onLinktoDrawing(item) {
            if(!item.drawing.id)
            {
                return
            }
            if (item.attachmentId) {
                sessionStorage.setItem('pointRouteParams', JSON.stringify({
                    drawingId: item.drawing.id,
                    attachmentId: item.attachmentId,
                    viewType: 'edit',
                    pointType: item.type
                }))

                this.$router.push('/cad')
            } else {
                Toast.fail({
                    mask: true,
                    duration: 2000,
                    message: this.$t('electric_fence_list.noDrawingAttchHit')
                })
            }
        },
        //弹出框 危险点类型
        onShowPointTypePopup() {
            this.showPointTypePopup = this.isEdit
            if (this.showPointTypePopup) {
                let flag = false;
                this.pointTypeColumns[0].values.forEach((item, index) => {
                    if (item.value === this.formModel.drawingPointType) {
                        flag = true;
                        this.pointTypeColumns[0].defaultIndex = index;
                        this.$refs.pointTypePicker.setIndexes([index])
                    }
                })
                if (!flag) {
                    this.formModel.drawingPointType = this.pointTypeColumns[0].values[0].value
                    this.$refs.pointTypePicker.setIndexes([0])
                }
            }
        },
        //确认选择危险点类型
        onPointTypePickerConfirm(picker, item, index) {
            this.formModel = Object.assign({}, this.formModel, {
                drawingPointType: item[0].value
            })
        },

        //弹出框 危险性质
        onShowPointPropertyPopup() {
            this.showPointPropertyPopup = this.isEdit
            if (this.showPointPropertyPopup) {
                let flag = false;
                this.pointPropertyColumns[0].values.forEach((item, index) => {
                    if (item.value === this.formModel.pointProperty) {
                        flag = true;
                        this.pointPropertyColumns[0].defaultIndex = index;
                        this.$refs.pointPropertyPicker.setIndexes([index])
                    }
                })
                if (!flag) {
                    this.formModel.pointProperty = this.pointPropertyColumns[0].values[0].value
                    this.$refs.pointPropertyPicker.setIndexes([0])
                }
            }
        },
        //确认选择危险性质 
        onPointPropertyPickerConfirm(picker, item, index) {
            this.formModel = Object.assign({}, this.formModel, {
                pointProperty: item[0].value
            })
        },

        //弹出框 危险状态
        onShowPointStatusPopup() {
            this.showPointStatusPopup = this.isEdit
            if (this.showPointStatusPopup) {
                let flag = false;
                this.pointStatusColumns[0].values.forEach((item, index) => {
                    if (item.value === this.formModel.status) {
                        flag = true;
                        this.pointStatusColumns[0].defaultIndex = index;
                        this.$refs.pointStatusPicker.setIndexes([index])
                    }
                })
                if (!flag) {
                    this.formModel.status = this.pointStatusColumns[0].values[0].value
                    this.$refs.pointStatusPicker.setIndexes([0])
                }
            }
        },
        //确认选择危险状态
        onPointStatusPickerConfirm(picker, item, index) {
            this.formModel = Object.assign({}, this.formModel, {
                status: item[0].value
            })
        },
        //翻译设备名称
        getSelectTranslate(projectEquRegister) {
            if (projectEquRegister) {
                let param = this.deviceColumns[0].values.filter(item => {
                    return item.value === projectEquRegister.id
                })
                if (0 === param.length) {
                    return ''
                } else {
                    return param[0].label
                }
            } else {
                return ""
            }

        },
        //弹出框 设备
        onShowDevicePopup() {
            this.showDevicePopup = this.isEdit
            if (this.showDevicePopup) {
                let flag = false;
                this.deviceColumns[0].values.forEach((item, index) => {
                    if (item.value === this.formModel.projectEquRegister.id) {
                        flag = true;
                        this.deviceColumns[0].defaultIndex = index;
                        this.$refs.devicePicker.setIndexes([index])
                    }
                })
                if (!flag) {
                    this.formModel.projectEquRegister = {
                        id: this.deviceColumns[0].values[0].value
                    }
                    this.$refs.devicePicker.setIndexes([0])
                }
            }
        },
        //确认选择设备
        onDevicePickerConfirm(e) {
            this.showDevicePopup = false
            this.formModel = Object.assign({}, this.formModel, {
                'projectEquRegister': {
                    id: e[0].value
                }
            })
        },

        //弹出框 登记时间
        onShowDatePicker() {
            this.datePickerShowFlag = this.isEdit
            if (this.datePickerShowFlag) {
                this.currentDate = this.formModel.regiserDate ? moment(this.formModel.regiserDate)._d : new Date()
            }
        },
        //确认选择登记时间
        datePickerConfirm(value) {
            this.formModel.regiserDate = moment(value).format('YYYY-MM-DD HH:mm:ss')
            this.datePickerShowFlag = false
        },
        //显示选择图纸弹窗
        onShowDrawingPopup() {
            if (this.viewModel == 'create') {
                this.$refs.drawingList.show = true
            }
        },
        //选择图纸
        onSelectDrawing(value) {
            this.formModel.drawing = value
            //获取编号
            this.getCode()
            this.getDrawing()
            this.addEventBackButtonBack()
        },
        //提交数据
        submit() {
            let valid = true
            if (!this.formModel.drawing.id) {
                this.$message.error(this.$t('safe_drawing_point.msgSelect') + this.$t('safe_drawing_point.drawing'));
                valid = false
            }
            if (!this.formModel.name) {
                this.$message.error(this.$t('safe_drawing_point.msgInput') + this.$t('electric_fence_list.railName'));
                valid = false
            }
            if (!this.formModel.regiserDate) {
                this.$message.error(this.$t('safe_drawing_point.msgSelect') + this.$t('safe_drawing_point.registerDate'));
                valid = false
            }
            if (!this.formModel.drawingPointType) {
                this.$message.error(this.$t('safe_drawing_point.msgSelect') + this.$t('electric_fence_list.drawingPointType'));
                valid = false
            }
            if (!this.formModel.pointProperty) {
                this.$message.error(this.$t('safe_drawing_point.msgSelect') + this.$t('electric_fence_list.pointProperty'));
                valid = false
            }
            if (!this.formModel.status) {
                this.$message.error(this.$t('safe_drawing_point.msgSelect') + this.$t('electric_fence_list.status'));
                valid = false
            }

            if (valid) {
                Toast.loading({
                    mask: true,
                    duration: 0,
                    message: this.$t('public.savingText')
                });
                let submitModel = cloneDeep(this.formModel)
                submitModel.dataSource = 'data_source_2'
                submitModel.drawing = {
                    id: submitModel.drawing.id
                }
                //    submitModel.registerMan = { id: this.$store.state.userInfo.id }
                if (!this.formModel.id) {
                    submitModel.auditStatus = "audit_status_1"
                }
                this.$axios.post(this.formModel.id ? uri.update : uri.save, submitModel)
                    .then(resp => {
                        this.$message.success(this.$t('operationTips.saveSuccess'))
                    })
                    .finally(() => {
                        this.toBack()
                        Toast.clear()
                    })
            }
        },

        //获取危险点编号
        getCode() {
            let params = {
                "drawing": {
                    "id": this.formModel.drawing.id
                },
                "signType": this.formModel.signType
            }
            this.$axios.post(uri.getCode, params).then((response) => {
                    if (response) {
                        this.formModel = Object.assign({}, this.formModel, {
                            code: response
                        })
                    } else {
                        let msg = this.$t('safe_drawing_point.codeErrorMsg')
                        this.$message.error(msg)
                    }

                })
                .catch(err => {
                    console.log('catch')
                    console.log(err)
                })
        },
        //扫描二维码
        scanHandler() {
            this.$refs.barcode.show = true;
        },
        //二维码扫描成功回调
        scanSuccess(code) {
            if (code) {
                this.formModel = Object.assign({}, this.formModel, {
                    qrCode: code
                })
            }
            this.addEventBackButtonBack()
        },

        //获取数据
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
                    })
                    .then((resp) => {
                        this.isEdit = false
                        if (resp) {
                            this.formModel = resp
                            if (this.$route.query.id) {
                                if (this.$route.query.model == "view") this.viewModel = "view"
                                else if (this.$route.query.model == "edit") this.viewModel = "edit"
                                else if (this.$route.query.taskId) this.viewModel = "submitAudit"
                                this.getDrawing()
                            }
                        }
                    })
                    .finally(() => {
                        Toast.clear();
                    })
            }
        },
        //获取设备列表
        getDeviceOptions() {
            const url = "/project/projectEquRegister/list"
            let params = {
                delFlag: "0",
                pageSize: -1,
                type: "equ_type_2"
            }
            let list = []
            this.$axios.post(url, params).then((response) => {
                    if (response.list) {
                        response.list.forEach(element => {
                            list.push({
                                "label": element.name + '[' + element.uniqueCode + ']',
                                "value": element.id
                            })
                        });
                        this.deviceColumns = [{
                            values: list
                        }]
                    }
                })
                .catch(err => {
                    console.log('catch')
                    console.log(err)

                })
        },

        //重新提交审核
        submitAudit() {

            Toast.loading({
                mask: true,
                duration: 0,
                message: this.$t('public.submitingText')
            });
            let actName
            if (this.formModel.type == "point_type_1") {
                actName = "ElectricFence"
            } else {
                actName = "DPElectricFence"
            }
            let submitModel = cloneDeep(this.formModel)
            this.$axios.post(uri.sumitAudit + actName, submitModel)
                .then(resp => {
                    this.$message.success(this.$t('operationTips.saveSuccess'))
                    this.toBack()
                })
                .finally(() => {
                    Toast.clear()
                })
        },
        //审批、驳回、撤回、重新提交审核
        approveAudit(pass) {
            let valid = true
            //撤回时填充默认审核意见  审批、驳回 需要填写审批理由
            if (this.formModel.auditStatus == "audit_status_4") {
                if (pass == "N") {
                    if (!this.formModel.comment) {
                        this.formModel.comment = this.$t('operation.withdraw')
                    }
                } else if (pass == "Y") {
                    if (!this.formModel.comment) {
                        this.formModel.comment = this.$t('operation.resubmit')
                    }
                }
            }
            // if (!this.formModel.comment) {
            //     this.$message.error(this.$t('safe_drawing_point.auditRemarksTip'))
            //     valid = false
            // }
            if (valid) {
                Toast.loading({
                    mask: true,
                    duration: 0,
                    loadingType: 'spinner',
                    message: this.$t('public.submitingText')
                });
                let submitModel = cloneDeep(this.formModel)

                submitModel.pass = pass
                this.$axios.post(uri.completeAudit, submitModel)
                    .then(resp => {
                        let msg = ""
                        if (submitModel.auditStatus == "audit_status_4" && pass == "N") {
                            msg = this.$t('operationTips.withdrawSuccess')
                        } else if (submitModel.auditStatus == "audit_status_4" && pass == "Y") {
                            msg = this.$t('operationTips.resubmitSuccess')
                        } else if (submitModel.auditStatus == "audit_status_2" && pass == "N") {
                            msg = this.$t('operationTips.dismissSuccess')
                        } else if (submitModel.auditStatus == "audit_status_2" && pass == "Y") {
                            msg = this.$t('operationTips.approveSuccess')
                        } else {
                            msg = this.$t('operationTips.saveSuccess')
                        }
                        this.$message.success(msg)

                        this.toBack()

                    })
                    .finally(() => {
                        Toast.clear()
                    })
            }
        },

        //监听返回按钮
        addEventBackButtonBack() {
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

    mounted() {
        this.addEventBackButtonBack()
        this.pointTypeColumns = [{
            values: this.$getDictByKey('rail_type')
        }]
        this.pointPropertyColumns = [{
            values: this.$getDictByKey('point_property')
        }]
        this.pointStatusColumns = [{
            values: this.$getDictByKey('rail_status')
        }]

        //获取设备列表
        this.getDeviceOptions()
        if (!this.formModel.regiserDate) this.formModel.regiserDate = moment().format('YYYY-MM-DD HH:mm:ss')
        this.formModel.signType = "sign_type_2"
        this.formModel.type = "point_type_2"
        if (this.$route.query.id) {
            this.getData()
        } else {
            this.viewModel = 'create'
        }
    
    }

}
</script>

<style lang="less">
.qrCode {
    width: 100%;
    height: 100%;
}
</style><style lang="less" scoped>
.content-overlay {
    width: 100%;
    height: 100%;
    box-sizing: border-box;
    background: whitesmoke; //   padding: 10px;

    .content {
        height: 100%;
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
            position: relative; //   padding: 5px;
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
