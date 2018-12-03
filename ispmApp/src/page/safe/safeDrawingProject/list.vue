<!--detail-->
<!--@author LiFanLingJue-->
<!--@date 2018/8/14-->
<template>
<div class="safeDrawingPoint c_flex c_direction_v">
    <nav-bar left-arrow :left-text="$t('public.back')" @click-left="toBack" :title="$t('danger_project.routerTitle') ">
        <div slot="right" class="van-nav-bar__text">
            <van-icon style="font-size: .2rem; margin-right: .05rem" name="add-o" @click="addHandler" v-permission="$permission.danger_project_list.add" />
            <van-icon style="font-size: .2rem;" name="more-o" @click="showMore=true" />
        </div>
    </nav-bar>
    <van-search v-model="searchFormModel.name" background="#f1f6f9" :placeholder="$t('danger_project.listSearchTip') " show-action @search="onSearch" v-permission="$permission.danger_project_list.view">
        <div slot="action" @click="onSearch">{{$t('public_button.search')}}</div>
    </van-search>
    <drawing-filter ref="drawingFilter" @callback="onSelectDrawing"></drawing-filter>
    <div class="content c_flex_1" ref="content">
        <van-pull-refresh v-model="pullRefreshLoading" @refresh="onRefresh">
            <van-list v-model="loading" :finished="finished" @load="getData">
                <van-cell-group class="cellGroup">
                    <van-swipe-cell :key="index" class="cardContainer" v-for="(item, index) in listData" :right-width="65" :item="item" :on-close="deleteItemHandler">
                        <van-cell class="cell" :key="index">
                            <div @click="itemClickHandler(item)">
                                <div class="cellContainer van-hairline--bottom">
                                    <van-row type="flex" justify="space-between">
                                        <!--图纸名称-->
                                        <van-col class="cellHeadToolbar">
                                            <span>{{item.drawing?item.drawing.name:''}}</span>
                                        </van-col>
                                        <!--编号-->
                                        <van-col class="cellHeadToolbar">
                                            <span>{{$t('safe_drawing_point.drawingCode')}} :</span>
                                            <span>{{item.drawing?item.drawing.code:''}}</span>
                                        </van-col>
                                    </van-row>
                                    <van-row type="flex" class="region" justify="space-between">
                                        <van-col span="20">
                                            <!--区域/楼宇/分部分项/楼层-->
                                            <span v-if="item.drawing.region">{{$bizTranslate({key: 'region', value: item.drawing.region}).name}}/</span>
                                            <span v-if="item.drawing.building">{{$bizTranslate({key: 'building', value: item.drawing.building}).name}}/</span>
                                            <span v-if="item.drawing.subdivision">{{$translate({key: 'subdivision', value: item.drawing.subdivision})}}/</span>
                                            <span v-if="item.drawing.layer"> {{$bizTranslate({key: 'layer', value: item.drawing.layer}).name}}</span>
                                        </van-col>
                                        <van-col span="4">
                                            <van-tag v-if="item.auditStatus" plain :type="calAuditStatusType(item.auditStatus)">
                                                {{$translate({key: 'audit_status', value: item.auditStatus})}}
                                            </van-tag>
                                        </van-col>
                                    </van-row>

                                </div>
                                <van-cell class="dangerPoint van-hairline--bottom">
                                    <van-cell>
                                        <van-row>
                                            <!--危险点名称-->
                                            <van-col>
                                                <span class="cellLabel">{{$t('danger_project.name')}} :</span>
                                                <span>{{item.name}}</span>
                                            </van-col>
                                        </van-row>
                                        <van-row>
                                            <!--危险点编号-->
                                            <span class="cellLabel">{{$t('danger_project.code')}} :</span>
                                            <span>{{item.code}}</span>
                                        </van-row>
                                        <van-row>
                                            <!--危险点状态-->
                                            <van-col>
                                                <span>{{$t('danger_project.status')}} :</span>
                                                <span>
                                                <van-tag style="margin-left: 8px;" v-if="item.status"   :color="calcStatusType(item.status)">
                                                {{$translate({key: 'danger_status', value: item.status})}}
                                                </van-tag>
                                            </span>
                                            </van-col>

                                        </van-row>
                                        <van-row>
                                            <!--危险点分类-->
                                            <van-col>
                                                <span class="cellLabel">{{$t('danger_project.drawingPointType')}} :</span>
                                                <span>{{$translate({key: 'drawing_point_type',value:item.drawingPointType})}}
                                            </span>
                                            </van-col>
                                        </van-row>
                                        <van-row>
                                            <!--危险点性质-->
                                            <van-col>
                                                <span class="cellLabel">{{$t('danger_project.pointProperty')}} :</span>
                                                <span>{{$translate({key: 'point_property',value:item.pointProperty})}}
                                            </span>
                                            </van-col>
                                        </van-row>
                                        <van-row>
                                            <!--巡查频次-->
                                            <van-col>
                                                <span class="cellLabel" v-if="item.frequency" style="width:.6rem;">{{$t('safe_drawing_point.frequency')}} :</span>
                                                <span>{{item.frequency}}</span>
                                            </van-col>
                                        </van-row>
                                        <van-row v-if="item.registerMan &&item.regiserDate">
                                            <!--登记人-->
                                            <van-col>
                                                <span>{{$t('safe_drawing_point.registerMan')}} :</span>
                                                <span>{{item.registerMan ? item.registerMan.name : ''}}</span>
                                            </van-col>
                                            <!--登记时间-->
                                            <van-col>
                                                {{item.regiserDate}}
                                            </van-col>
                                        </van-row>
                                    </van-cell>
                                </van-cell>
                            </div>
                            <van-cell>
                                <van-row style="text-align: right;    margin-bottom: .05rem;">
                                    <!--删除-->
                                    <van-button  size="small" :disabled="(item.dangerDelCol1+item.dangerDelCol2> 0)||(item.auditStatus=='audit_status_2'||item.auditStatus=='audit_status_3'||item.auditStatus=='audit_status_4')" type="danger"   v-text="$t('public_button.delete')" v-permission="$permission.danger_project_list.delete"  @click.stop="deleteClickHandler(item)"></van-button>
                                    <!--关闭-->
                                    <van-button size="small" :disabled="item.status!=='danger_status_3'" type="danger" v-text="$t('operation.close')" v-permission="$permission.danger_project_list.close" @click.stop="closeData(item)"></van-button>
                                    <!--审批-->
                                    <van-button size="small" v-if="item.audit&&item.auditStatus=='audit_status_2'" :disabled="item.auditStatus=='audit_status_3'" @click.stop="auditDetail(item)" v-permission="$permission.danger_project_list.consideration">
                                        {{$t('safe_drawing_point.audit')}}
                                    </van-button>
                                    <!--绑定二维码-->
                                    <van-button size="small"   @click.stop="scanHandler(item)" v-permission="$permission.danger_project_list.edit">
                                        {{$t('danger_project.showQRCode')}}
                                    </van-button>
                                    <!--提交审核-->
                                    <van-button size="small" v-if="item.auditStatus=='audit_status_1'" :disabled="(item.auditStatus=='audit_status_2'||item.auditStatus=='audit_status_3')" @click.stop="approveDetail(item)" v-permission="$permission.danger_project_list.approve">
                                        {{$t('safe_drawing_point.sumitAudit')}}
                                    </van-button>
                                    <!--发起整改-->
                                    <van-button size="small" v-if="(item.auditStatus=='audit_status_3')" @click.stop="renovate(item)" v-permission="$permission.danger_project_list.rectify">
                                        {{$t('danger_project.renovate')}}
                                    </van-button>
                                    <!--修改日志-->
                                    <van-button size="small" @click.stop="showLog(item)" v-permission="$permission.danger_project_list.view">
                                        {{$t('safe_drawing_point.modifyLog')}}
                                    </van-button>
                                </van-row>
                            </van-cell>

                        </van-cell>
                        <van-button :disabled="(item.dangerDelCol1+item.dangerDelCol2> 0)||(item.auditStatus=='audit_status_2'||item.auditStatus=='audit_status_3'||item.auditStatus=='audit_status_4')" type="danger" class="right_delete c_flex c_a_center c_j_center" slot="right" v-text="$t('public_button.delete')" v-permission="$permission.danger_project_list.delete"></van-button>
                    </van-swipe-cell>
                </van-cell-group>
            </van-list>
        </van-pull-refresh>
        <no-data v-if="listData.length==0"></no-data>
    </div>

    <!--查看修改日志-->
    <log ref="log" @callback="logCallback" :item="rowData"></log>

    <!--扫描二维码(查找)-->
    <barcode @callback="scanSearchSuccess" ref="barcodeSearch"></barcode>
    <!--绑定二维码-->
    <barcode @callback="scanSuccess" ref="barcode"></barcode>
    <!--批量审核提示-->
    <van-dialog v-model="showCompleteBatchAudit" show-cancel-button :before-close="completeBatchAudit">
        <van-cell :title="$t('safe_drawing_point.completeBatchLabel')">
            <van-switch slot="right-icon" v-model="completeBatchAuditChecked" />
        </van-cell>
        <van-field type="textarea" :maxlength="1000" rows="3" autosize input-align="right" :label="$t('safe_drawing_point.auditRemarks')" :placeholder="$t('safe_drawing_point.auditRemarksTip')" v-model="completeBatchAuditComment" />
    </van-dialog>
    <!--更多-->
    <van-popup v-model="showMore">
        <van-button size="large" @click="sumitBatchAudit" v-permission="$permission.danger_project_list.approve">{{$t('safe_drawing_point.batchSumitAudit')}}</van-button>
        <van-button size="large" @click="onShowCompleteBatchAudit" v-permission="$permission.danger_project_list.consideration">{{$t('safe_drawing_point.batchCompleteAudit')}}</van-button>
        <van-button size="large" @click="scanSearchHandler" v-permission="$permission.danger_project_list.view">{{$t('safe_drawing_point.scanBarCode')}}</van-button>
    </van-popup>
</div>
</template>

<script>
import {
    Toast,
    Dialog
} from 'vant'

import log from './log.vue'

import cloneDeep from "lodash/cloneDeep"
import barcode from '../../../components/barcode.vue'
import drawingFilter from '../../../components/drawingFilter'
const uri = {
    itemsList: '/safe/safeDrawingPoint/dangerousPointList',
    deleteItem: '/safe/safeDrawingPoint/deleteDangerousPoint',
    check: "/safe/safeRectify/checkRectifyForDangerousPoint",
    sumitAudit: "/safe/safeDrawingPoint/submit/",
    sumitBatchAudit: "/safe/safeDrawingPoint/submit/batch/",
    completeAudit: "/safe/safeDrawingPoint/complete/",
    completeBatchAudit: "/safe/safeDrawingPoint/complete/batch/",
    update: "/safe/safeDrawingPoint/updateDangerousPoint"
};
export default {
    components: {
        log,
        barcode,
        drawingFilter
    },
    data() {
        return {
            pullRefreshLoading: false,
            loading: false,
            finished: false,
            listData: [],
            totalCount: 0,
            pageInfo: {
                pageNo: 1,
                pageSize: 10
            },
            pointType: '',
            signType: '',
            rowData: {},
            model: '',
            searchFormModel: {},
            currentDrawingID: '',
            showCompleteBatchAudit: false,
            completeBatchAuditComment: '',
            completeBatchAuditChecked: true,
            showMore:false
        };
    },
    computed: {},
    methods: {
        //返回上一页
        toBack(e) {
            this.$router.push('/index?active=1')
        },

        onSearch() {
            //输入名称查询时忽略区域楼宇筛选
            let name = this.searchFormModel.name
            this.searchFormModel = {}
            this.searchFormModel = {
                'name': name
            }
            this.onRefresh()
        },
        onRefresh() {
            setTimeout(() => {
                this.pageInfo = {
                    pageNo: 1,
                    pageSize: 10
                };
                if (this.searchFormModel) {
                    this.pageInfo = Object.assign({}, this.pageInfo, this.searchFormModel)
                }
                this.showMore= false;
                this.listData = [];
                this.finished = false;
                this.pullRefreshLoading = false;
                //触发van-list调用load事件
                this.$refs.content.scrollTop = 1
            }, 500);
        },
        onSelectDrawing(value) {
            this.searchFormModel = Object.assign({}, this.searchFormModel, {
                drawing: value
            })
            this.onRefresh()
        },
        getData() {
            let filterInfo = Object.assign({
                id: this.$route.query.id
            }, this.pageInfo);
            filterInfo.signType = this.signType
            this.$axios
                .post(uri.itemsList, filterInfo)
                .then(resp => {
                    this.totalCount = resp.count;
                    resp.list.forEach(item => {
                        this.listData.push(item)
                    });

                    //检测是否已加载完全部数据
                    if (this.pageInfo.pageSize * this.pageInfo.pageNo >= this.totalCount) {
                        this.finished = true
                    } else {
                        this.pageInfo.pageNo++
                    }
                })
                .catch(err => {
                    console.log('catch');
                    console.log(err);
                    this.finished = true
                })
                .finally(res => {
                    this.loading = false
                })
        },

        addHandler() {
            let model = 'create'
            this.$router.push('/safe/safeDrawingProject/detail?model=' + model+'&rPath=plist')
        },

        deleteItemHandler(position, instance) {
            if (position === 'right') {
                this.$dialog.confirm({
                    message: this.$t('modalTips.deleteModalTips')
                }).then(() => {
                    this.$axios
                        .post(uri.deleteItem, {
                            id: instance.$attrs.item.id
                        })
                        .then(resp => {
                            this.$toast({
                                iconClass: 'van-icon van-icon-success',
                                message: this.$t('operationTips.deleteSuccess')
                            });
                            this.onRefresh()
                        })
                        .catch(err => {})
                        .finally(resp => {
                            instance.close()
                        })
                }, () => {})
            } else {
                instance.close()
            }
        },
        deleteClickHandler(item) {
            this.$dialog.confirm({
                message: this.$t('modalTips.deleteModalTips')
            }).then(() => {
                this.$axios
                    .post(uri.deleteItem, {
                        id: item.id
                    })
                    .then(resp => {
                        this.$toast({
                            iconClass: 'van-icon van-icon-success',
                            message: this.$t('operationTips.deleteSuccess')
                        });
                        this.onRefresh()
                    })
                    .catch(err => {})
            }, () => {})
        },
        closeData(rowData) {
            this.$dialog.confirm({
                message: this.$t('modalTips.closeModalTips')
            }).then(() => {
                let submitModel = cloneDeep(rowData)
                    submitModel.type = this.pointType
                    submitModel.dataSource = 'data_source_2'
                    submitModel.status = 'danger_status_4' // 关闭
                    this.$axios.post(uri.update, submitModel)
                        .then(resp => {
                            this.onRefresh()
                        })
                        .catch(err => {})
            }, () => {})
        },
        itemClickHandler(item) {
            if (this.$refs.drawingFilter.show) {
                this.$refs.drawingFilter.show = false
                return
            }
            let model
            if (item.auditStatus == 'audit_status_5' || item.auditStatus == 'audit_status_2' || item.auditStatus == 'audit_status_3') {
                if (this.$permission.danger_project_list.view) {
                    model = 'view'
                    this.$router.push('/safe/safeDrawingProject/detail?id=' + item.id + '&model=' + model+'&rPath=plist')
                }
            } else {
                if (this.$permission.danger_project_list.edit) {
                    model = 'edit'
                    this.$router.push('/safe/safeDrawingProject/detail?id=' + item.id + '&model=' + model+'&rPath=plist')
                }
            }
        },
        //批量提交审核
        sumitBatchAudit() {
            Dialog.confirm({
                title: this.$t('safe_drawing_point.submitBatchAuditHit')
            }).then(() => {
                //提交审核
                Toast.loading({
                    mask: true,
                    duration: 0,
                    message: this.$t('public.submitingText')
                });
                let filterInfo
                filterInfo = {
                    type: this.pointType
                }

                let actName
                if (this.pointType == "point_type_1") {
                    actName = "SafeDrawingPoint"
                } else {
                    actName = "DangerProject"
                }
                this.$axios.post(uri.sumitBatchAudit + actName, filterInfo)
                    .then(resp => {
                        this.$message.success(this.$t('operationTips.commitSuccess'))
                        this.onRefresh()
                    })
                    .finally(() => {
                        Toast.clear()
                    })
            }).catch(() => {
                // on cancel
            });

        },
        //批量审批
        completeBatchAudit(action, done) {
            if (action === 'confirm') {
                //提交审批
                Toast.loading({
                    mask: true,
                    duration: 0,
                    message: this.$t('public.submitingText')
                });
                let pass = ""
                if (this.completeBatchAuditChecked) {
                    pass = "Y"
                } else {
                    pass = "N"
                }
                let filterInfo
                filterInfo = {
                    type: this.pointType,
                    pass: pass,
                    comment: this.completeBatchAuditComment
                }

                let actName
                if (this.pointType == "point_type_1") {
                    actName = "SafeDrawingPoint"
                } else {
                    actName = "DangerProject"
                }
                this.$axios.post(uri.completeBatchAudit + actName, filterInfo)
                    .then(resp => {
                        this.$message.success(this.$t('operationTips.commitSuccess'))
                        this.onRefresh()
                        this.showCompleteBatchAudit = false
                        done()
                    })
                    .finally(() => {
                        Toast.clear()
                    })

            } else {
                done()
            }

        },
        //单个审批
        auditDetail(item) {
            
            if (item.type == "point_type_1") {
                this.$router.push('/safe/safeDrawingPoint/detail?id=' + item.id+'&taskId='+item.taskId+'&rPath=plist')
            } else {
                this.$router.push('/safe/safeDrawingProject/detail?id=' + item.id+'&taskId='+item.taskId+'&rPath=plist')
            }
        },
        //显示批量审批界面
        onShowCompleteBatchAudit() {
            this.showCompleteBatchAudit = true
            this.completeBatchAuditComment = ''
            this.completeBatchAuditChecked = true
        },
        showLog(item) {
            this.rowData = cloneDeep(item)
            this.$refs.log.show = true
        },
        approveDetail(row) {
            this.rowData = cloneDeep(row)
            this.rowData.pointType = this.pointType
            //提交审核
            Toast.loading({
                mask: true,
                duration: 0,
                message: this.$t('public.submitingText')
            });
            let actName
            if (this.rowData.pointType == "point_type_1") {
                actName = "SafeDrawingPoint"
            } else {
                actName = "DangerProject"
            }
            this.$axios.post(uri.sumitAudit + actName, this.rowData)
                .then(resp => {
                    this.$message.success(this.$t('operationTips.saveSuccess'))
                    this.onRefresh()
                })
                .finally(() => {
                    Toast.clear()
                })
        },
        //危险点销项
        renovate(row) {
            this.$router.push((row.signType == 'sign_type_1' ? '/safe/safeDrawingPoint/renovate?id=' : '/safe/safeDrawingProject/renovate?id=') + row.id)
        },
        calcStatusType(status) {
            switch (status) {
                case 'danger_status_1':
                    return '#44bb00'
                case 'danger_status_2':
                    return 'red'
                case 'danger_status_3':
                    return '#cece4d'
                case 'danger_status_4':
                    return 'darkgray'
            }
        },
        calAuditStatusType(status) {
            switch (status) {
                case 'audit_status_3':
                    return 'success'
                case 'audit_status_2':
                    return 'danger'
                case 'audit_status_4':
                    return 'warning'
                case 'audit_status_1':
                    return ''
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
        },
        //绑定二维码
        scanHandler(item) {
            this.rowData = cloneDeep(item)
            this.$refs.barcode.show = true;
        },
        scanSuccess(code) {
            console.log(code);
            if (code) {
                Toast.loading({
                    mask: true,
                    duration: 0,
                    message: this.$t('safe_drawing_point.showQRCode')
                });
                this.rowData.qrCode = code
                let submitModel = cloneDeep(this.rowData)
                this.$axios.post(uri.update, submitModel)
                    .then(resp => {
                        this.$message.success(this.$t('safe_drawing_point.qrCodeSuccess'))
                        this.onRefresh()
                    })
                    .finally(() => {
                        Toast.clear()
                    })
            }
            
            this.addEventBackButtonBack()
        },
        //扫描二维码
        scanSearchHandler() {
            this.$refs.barcodeSearch.show = true;
            this.showMore = false;
        },
        scanSearchSuccess(value) {
            if (value) {
                let flag = false;
                this.listData.forEach(item => {
                    if (item.qrCode === value) {
                        this.rowData = item;
                        flag = true
                    }
                });
                if (flag) {
                    let model = 'view'
                    this.$router.push('/safe/safeDrawingProject/detail?id=' + this.rowData.id + '&model=' + model + '&rPath=plist')
                } else {
                    Toast.fail(this.$t('safeInspection.notInListData'));
                }
            }
            this.addEventBackButtonBack()
        },
        detailSaveSuccess(value) {
            if (value) {
                this.onRefresh()
            }
            this.addEventBackButtonBack()
        },
        logCallback() {
            this.addEventBackButtonBack()
        },

    },

    mounted() {
        this.addEventBackButtonBack();
        this.pointType = 'point_type_2'
        this.signType = "sign_type_3"
    }
};
</script>

<style lang="less" scoped>
.safeDrawingPoint {
    height: 100%;

    .content {
        overflow: auto;

        .cellGroup {
            background: none;

            &:after {
                border: none;
            }

            .cardContainer {
                margin: .06rem;
                border-radius: .05rem;
                border: 2px solid #e5e5e5;

                .van-cell {
                    padding: .1rem .1rem 0 .1rem;
                    color: #9b9b9b;

                    .cellHead {
                        color: #000000;
                        font-size: .16rem;
                    }

                    .cellHeadToolbar {
                        color: #000000;
                        font-size: .14rem;
                    }

                    .dangerPoint {

                        background: none;

                        .van-cell {
                            font-size: .12rem;
                            color: #B1B1B1;
                            padding: 0px 10px;
                        }
                    }

                    .region {
                        font-size: .12rem;
                    }

                    .cellLabel {
                        display: inline-block;
                        text-align: left;
                        width: .4rem;
                    }
                }

                .cell {
                    padding: 0;

                    .cellContainer {
                        padding: .1rem .1rem 0 .1rem;
                    }
                }
            }

            .van-button--default {
                color: #2A8CFF;
                border: 1px solid #2A8CFF;
            }

            .van-button--disabled {
                color: #999;
                background-color: #e8e8e8;
                border: 1px solid #e5e5e5;
            }

            .right_delete {
                width: .65rem;
                height: 100%;
                font-size: 15px;
            }
        }
    }

    .van-tag--warning {
        background: #b3b324;
    }

    .van-tag {
        padding: 2px 6px 2px 2px;
    }

    .block_title {
        margin: 0;
        font-weight: 400;
        font-size: 14px;
        color: rgba(69, 90, 100, 0.6); // background-color: whitesmoke;
    }
}
</style>
