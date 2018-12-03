<template>
 
    <tms-page>
        <nav-bar slot="header" left-arrow :left-text="$t('public.back')" @click-left="toBack" :title="$t('safe_drawing_point.pointDetail')">
            <div slot="right" v-if="formModel.auditStatus=='audit_status_4' || formModel.auditStatus=='audit_status_1'" class="van-nav-bar__text">
                <van-icon style="font-size: .2rem;margin-right: .05rem" name="edit" @click="isEdit=!isEdit" v-permission="formModel.type =='point_type_1'?$permission.safe_drawing_point.edit:$permission.danger_project_list.edit" />
            </div>
        </nav-bar>
        <div slot="content">
            <van-cell-group>
                <!--设计图名称-->
                <van-cell required :title="$t('safe_drawing_point.drawingName')" :value="formModel.drawing.name" :is-link="viewModel=='create'" @click="onShowDrawingPopup" />
                <!--设计图编号-->
                <van-cell :style="formModel.drawing.id?'color:blue':''" :is-link="!!formModel.drawing.id" :title="$t('safe_drawing_point.drawingCode')" :value="formModel.drawing.code"  @click="onLinktoDrawing(formModel)" />
                <!--区域-->
                <van-cell :title="$t('safe_drawing_point.region')" :value="$bizTranslate({key: 'region', value: formModel.drawing.region}).name" />
                <!--楼宇-->
                <van-cell :title="$t('safe_drawing_point.building')" :value="$bizTranslate({key: 'building', value: formModel.drawing.building}).name" />
                <!--分部分项-->
                <van-cell :title="$t('safe_drawing_point.subdivision')" :value="$translate({key: 'subdivision', value: formModel.drawing.subdivision})" />
                <!--楼层-->
                <van-cell :title="$t('safe_drawing_point.layer')" :value="$bizTranslate({key: 'layer', value: formModel.drawing.layer}).name" />

                <!--危险点名称-->
                <van-field :maxlength="100" required :disabled="!isEdit" input-align="right" @blur="formModel.name=formModel.name.trim()" :label="$t('safe_drawing_point.pointName')" :placeholder="isEdit?$t('safe_drawing_point.nameHit'):''" v-model="formModel.name" />
                <!--危险点编号-->
                <van-cell :title="$t('safe_drawing_point.pointCode')" :value="formModel.code" />
                <!--危险点二维码-->
                <van-field :maxlength="100" v-model="formModel.qrCode" @blur="formModel.qrCode=formModel.qrCode.trim()" input-align="right" :disabled="!isEdit" :label="$t('safe_drawing_point.showQRCode')" :placeholder="isEdit?$t('safe_drawing_point.barCodeHit'):''">
                    <van-icon v-if="isEdit" style="font-size: 20px;" slot="button" name="qr" @click="scanHandler" />
                </van-field>
                <!--危险点分类-->
                <van-cell required :title="$t('safe_drawing_point.drawingPointType')" :value="$translate({key: 'drawing_point_type', value: formModel.drawingPointType})" :is-link="isEdit" @click="onShowPointTypePopup" />
                <van-popup ref="pointTypePopup" v-model="showPointTypePopup" lock-scroll position="bottom">
                    <van-picker ref="pointTypePicker" value-key="label" :columns="pointTypeColumns" @change="onPointTypePickerConfirm" />
                </van-popup>
                <!--登记时间-->
                <van-cell required :title="$t('safe_drawing_point.registerDate')" :value="formModel.regiserDate" :is-link="isEdit" @click="onShowDatePicker" />
                <van-popup v-model="datePickerShowFlag" lock-scroll position="bottom">
                    <van-datetime-picker v-model="currentDate" type="datetime" @confirm="datePickerConfirm" @cancel="datePickerShowFlag = false" />
                </van-popup>
                <!--危险点性质-->
                <van-cell required :title="$t('safe_drawing_point.pointProperty')" :value="$translate({key: 'point_property', value: formModel.pointProperty})" :is-link="isEdit" @click="onShowPointPropertyPopup" />
                <van-popup v-model="showPointPropertyPopup" lock-scroll position="bottom">
                    <van-picker ref="pointPropertyPicker" value-key="label" :columns="pointPropertyColumns" @change="onPointPropertyPickerConfirm" />
                </van-popup>
                <!--危险点状态-->
                <van-cell required :title="$t('safe_drawing_point.status')" :value="$translate({key: 'danger_status', value: formModel.status})" :is-link="isEdit" @click="onShowPointStatusPopup" />
                <van-popup :disabled="viewModel=='submitAudit'" v-model="showPointStatusPopup" lock-scroll position="bottom">
                    <van-picker ref="pointStatusPicker" value-key="label" :columns="pointStatusColumns" @change="onPointStatusPickerConfirm" />
                </van-popup>
                <!--危险点描述-->
                <van-field :maxlength="1000" :disabled="!isEdit" @blur="formModel.remarks=formModel.remarks.trim()" type="textarea" autosize input-align="right" :label="$t('safe_drawing_point.remarks')" :placeholder="isEdit?$t('safe_drawing_point.remarksHit'):''" v-model="formModel.remarks" />
                <!--审核意见-->
                <van-field :maxlength="1000" type="textarea" v-if="viewModel=='submitAudit'"  @blur="formModel.comment=formModel.comment.trim()" autosize input-align="right" :label="$t('safe_drawing_point.auditRemarks')" :placeholder="$t('safe_drawing_point.auditRemarks')" v-model="formModel.comment" />
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
            <van-row v-if="formModel.auditStatus=='audit_status_4' &&isEdit==false">
                <!--审核撤回-->
                <van-col span="12">
                    <van-button size="large" :block="true" @click="approveAudit('N')">{{$t('operation.withdraw')}}</van-button>
                </van-col>
                <!--审核重新提交-->
                <van-col span="12">
                    <van-button size="large" :block="true" @click="approveAudit('Y')">{{$t('operation.resubmit')}}</van-button>
                </van-col>
            </van-row>
            <!--二维码-->
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
import popupPicker from '../../../components/popupPicker.vue'
import taskHistoicflow from '../../../components/taskHistoicflow.vue'
import drawingList from '../../../components/drawingList.vue'
const uri = {
    get: "/safe/safeDrawingPoint/getDangerousPoint",
    save: "/safe/safeDrawingPoint/saveDangerousPoint",
    update: "/safe/safeDrawingPoint/updateDangerousPoint",
    getCode: "/safe/safeDrawingPoint/getCode",
    getDrawing: "/project/drawing/get",
    sumitAudit: "/safe/safeDrawingPoint/submit/",
    completeAudit: "/safe/safeDrawingPoint/complete/",
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
            show: false,
            isEdit: true,
             formModel: {
                drawing: {
                    region: '',
                    building: '',
                    layer: '',
                    name: ''
                }
            },
            viewModel: ''
        }
    },
 

    methods: {
        toBack() {
           if (this.$route.query.rPath =='plist')   this.$router.push('/safe/safeDrawingPoint/list') 
           else this.$router.push('/task/todo/list')
        },
        //获取图纸信息
        getDrawing() {
            if (this.formModel.drawing.id) {
                let params = {
                    id: this.formModel.drawing.id
                }
                this.$axios.post(uri.getDrawing, params).then((response) => {
                        if (response) {
                            Object.assign(this.formModel, {
                                attachmentId: response.attachment.id
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
            if (!this.formModel.regiserDate) {
                this.$message.error(this.$t('safe_drawing_point.msgSelect') + this.$t('safe_drawing_point.registerDate'));
                valid = false
            }
            if (!this.formModel.drawingPointType) {
                this.$message.error(this.$t('safe_drawing_point.msgSelect') + (this.formModel.signType == 'sign_type_1' ? this.$t('safe_drawing_point.drawingPointType') : this.$t('danger_project.drawingPointType')));
                valid = false
            }
            if (!this.formModel.pointProperty) {
                this.$message.error(this.$t('safe_drawing_point.msgSelect') + (this.formModel.signType == 'sign_type_1' ? this.$t('safe_drawing_point.pointProperty') : this.$t('danger_project.pointProperty')));
                valid = false
            }
            if (!this.formModel.name) {
                this.$message.error(this.$t('safe_drawing_point.msgInput') + (this.formModel.signType == 'sign_type_1' ? this.$t('safe_drawing_point.name') : this.$t('danger_project.name')));
                valid = false
            }
            if (!this.formModel.status) {
                this.$message.error(this.$t('safe_drawing_point.msgSelect') + (this.formModel.signType == 'sign_type_1' ? this.$t('safe_drawing_point.status') : this.$t('danger_project.status')));
                valid = false
            }

            if (valid) {
                Toast.loading({
                    mask: true,
                    duration: 0,
                    message: this.$t('public.savingText')
                });
                let submitModel = cloneDeep(this.formModel)
                submitModel.type = this.formModel.type
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
                        Toast.clear()
                        this.toBack()

                    })
                    .finally(() => {
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
                      this.formModel=  Object.assign({},this.formModel, {
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
                        this.formModel = Object.assign({}, this.formModel, resp)
 
                        this.pointType = this.formModel.type
                        this.signType = this.formModel.signType
                        if (this.$route.query.id) {
                            if (this.$route.query.model == "view") this.viewModel = "view"
                            else if (this.$route.query.model == "edit") this.viewModel = "edit"
                            else if (this.$route.query.taskId) this.viewModel = "submitAudit"
                            this.getDrawing()
                        }
                    })
                    .finally(() => {
                        Toast.clear();
                    })
            }
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
        this.pointTypeColumns = [{
            values: this.$getDictByKey('drawing_point_type')
        }]
        this.pointPropertyColumns = [{
            values: this.$getDictByKey('point_property')
        }]
        this.pointStatusColumns = [{
            values: this.$getDictByKey('danger_status')
        }]

        this.formModel.signType = "sign_type_1"
        this.formModel.type = "point_type_1"
        if (!this.formModel.regiserDate) this.formModel.regiserDate = moment().format('YYYY-MM-DD HH:mm:ss')
        if (this.$route.query.id) {
            this.getData()
        } else {
            this.viewModel = 'create'
        }
        this.addEventBackButtonBack()
    }
}
</script>

 

<style lang="less" scoped>
.content-overlay {
    width: 100%;
    height: 100%;
    box-sizing: border-box;
    background: whitesmoke; //   padding: 10px;

    .content {
        overflow: auto;
        height: 100%;
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
