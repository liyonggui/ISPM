<!--detail-->
<!--@author LiFanLingJue-->
<!--@date 2018/8/14-->
<template>
<div class="safeDrawingPoint c_flex c_direction_v">
    <nav-bar left-arrow :left-text="$t('public.back')" @click-left="toBack" :title="$t('safeInspection.title')">
        <div slot="right" class="van-nav-bar__text">
            <van-icon style="font-size: .2rem; margin-right: .05rem" name="add-o" @click="addHandler" v-permission="$permission.safe_safeInspection.add" />
            <van-icon style="font-size: .2rem;" name="qr" @click="scanSearchHandler" v-permission="$permission.safe_safeInspection.add" />
        </div>
    </nav-bar>
    <van-search v-model="name" background="#f1f6f9" :placeholder="$t('safeInspection.listSearchTip')" show-action @search="onSearch" v-permission="$permission.safe_safeInspection.view">
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

                                    <van-row type="flex" class="region" justify="space-between">
                                        <van-col span="20">
                                            <!--区域/楼宇/分部分项/楼层-->
                                            <span v-if="item.safeDrawingPoint.drawing.region">{{$bizTranslate({key: 'region', value: item.safeDrawingPoint.drawing.region}).name}}/</span>
                                            <span v-if="item.safeDrawingPoint.drawing.building">{{$bizTranslate({key: 'building', value: item.safeDrawingPoint.drawing.building}).name}}/</span>
                                            <span v-if="item.safeDrawingPoint.drawing.subdivision">{{$translate({key: 'subdivision', value: item.safeDrawingPoint.drawing.subdivision})}}/</span>
                                            <span v-if="item.safeDrawingPoint.drawing.layer"> {{$bizTranslate({key: 'layer', value: item.safeDrawingPoint.drawing.layer}).name}}</span>
                                        </van-col>
                                    </van-row>

                                </div>
                                <van-cell class="dangerPoint van-hairline--bottom">
                                    <van-cell>
                                        <van-row>
                                            <!--巡检单号-->
                                            <van-col>
                                                <span class="cellLabel">{{ $t('safeInspection.inspectionNo')}} :</span>
                                                <span>{{item.inspectionNo}}</span>
                                            </van-col>
                                        </van-row>
                                        <van-row>
                                            <!--巡检单状态-->
                                            <van-col>
                                                <span class="cellLabel">{{ $t('safeInspection.inspectioStatus')}} :</span>
                                                <span>{{$translate({key: 'safeInspection_status', value: item.status})}}</span>
                                            </van-col>
                                        </van-row>
                                        <van-row v-if="item.inspectionMan &&item.inspectionDate">
                                            <!--巡查人-->
                                            <van-col>
                                                <span class="cellLabel">{{$t('safeInspection.inspectionMan')}} :</span>
                                                <span>{{item.inspectionMan ? item.inspectionMan.name : ''}}&nbsp</span>
                                            </van-col>
                                            <!--巡查时间-->
                                            <van-col>
                                                {{item.inspectionDate.substring(0, 10)}}
                                            </van-col>
                                        </van-row>
                                        <van-row>
                                            <!--危险点分类-->
                                            <van-col>
                                                <span class="cellLabel">{{$t('safeInspection.items.drawingPointType')}}:</span>
                                                <span>{{$translate({key: 'sign_type', value: item.safeDrawingPoint.signType})}}</span>
                                            </van-col>
                                        </van-row>
                                        <van-row>
                                            <!--危险点名称-->
                                            <van-col>
                                                <span class="cellLabel">{{ $t('safeInspection.items.drawingPointName')}} :</span>
                                                <span>{{item.safeDrawingPoint.name}}</span>
                                            </van-col>
                                        </van-row>
                                        <van-row>
                                            <!--危险点编号-->
                                            <span class="cellLabel"> {{$t('safeInspection.items.drawingPointCode')}} :</span>
                                            <span>{{item.safeDrawingPoint.code}}</span>
                                        </van-row>
                                        <van-row>
                                            <!--危险点状态-->
                                            <van-col>
                                                <span>{{$t('safeInspection.items.status')}} :</span>
                                                <span>
                                                <van-tag style="margin-left: 12px;" v-if="item.safeDrawingPoint.status" :type="calcStatusType(item.safeDrawingPoint.status)">
                                                {{$translate({key: item.safeDrawingPoint.signType=="sign_type_2"?'rail_status':'danger_status', value: item.safeDrawingPoint.status})}}
                                                </van-tag>
                                            </span>
                                            </van-col>

                                        </van-row>

                                    </van-cell>
                                </van-cell>
                            </div>
                            <van-cell>
                                <van-row style="text-align: right;    margin-bottom: .05rem;">
                                    <!--编辑-->
                                    <van-button size="small" :disabled="item.status=='safeInspection_status_2'" @click.stop="editHandler(item)" v-permission="$permission.safe_safeInspection.edit">
                                        {{$t('public_button.edit')}}
                                    </van-button>
                                    <!--整改派单-->
                                    <van-button size="small" :disabled="item.status=='safeInspection_status_1'||(item.status=='safeInspection_status_2'&&item.inspectionResult=='inspection_result_1')||!!item.safeRectify" @click.stop="rectifyHandler(item)" v-permission="$permission.safe_safeInspection.rectify">
                                        {{$t('safeInspection.rectify')}}
                                    </van-button>

                                </van-row>
                            </van-cell>

                        </van-cell>
                        <van-button :disabled="item.status=='safeInspection_status_2'" type="danger" class="right_delete c_flex c_a_center c_j_center" slot="right" v-text="$t('public_button.delete')" v-permission="$permission.safe_safeInspection.delete"></van-button>
                    </van-swipe-cell>
                </van-cell-group>
            </van-list>
        </van-pull-refresh>
        <no-data v-if="listData.length==0"></no-data>
    </div>

    <!--扫描二维码(查找)-->
    <barcode @callback="scanSearchSuccess" ref="barcodeSearch"></barcode>

</div>
</template>

<script>
import {
    Toast,
    Dialog
} from 'vant'

import cloneDeep from "lodash/cloneDeep"
import barcode from '../../../components/barcode.vue'
import drawingFilter from '../../../components/drawingFilter'
const uri = {
    itemsList: '/safe/safeInspection/list',
    deleteItem: '/safe/safeInspection/delete',
    drawingPointList:'/safe/safeDrawingPoint/dangerousPointList'
};
export default {
    components: {
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

            rowData: {},
            model: '',
            name:'',
            searchFormModel: {},
            currentDrawingID: '',
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
            let name = this.name
            this.searchFormModel = {}
            this.searchFormModel = {
                'inspectionNo': name
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
                this.listData = [];
                this.finished = false;
                this.pullRefreshLoading = false;
                //触发van-list调用load事件
                this.$refs.content.scrollTop = 1
            }, 500);
        },
        onSelectDrawing(value) {
            this.searchFormModel = Object.assign({}, this.searchFormModel, {
                safeDrawingPoint: {
                    drawing: value
                }
            })
            this.onRefresh()
        },
        getData() {
            let filterInfo = Object.assign({
                id: this.$route.query.id
            }, this.pageInfo);

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
            let model = "add"
            this.$router.push('/safe/safeInspection/detail' + "?model=" + model)
        },
        editHandler(item) {
            let model = "edit"
            this.$router.push('/safe/safeInspection/detail?id=' + item.id + "&model=" + model)
        },
        rectifyHandler(item) {
            this.$router.push('/safe/safeInspection/renovate?id=' + item.id)
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
        itemClickHandler(item) {
            let model = "view"
            this.$router.push('/safe/safeInspection/detail?id=' + item.id + "&model=" + model)
        },

        calcStatusType(status) {
            switch (status) {
                case 'danger_status_1':
                    return 'success'
                case 'danger_status_2':
                    return 'danger'
                case 'danger_status_3':
                    return 'warning'
                case 'danger_status_4':
                    return ''
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

        //扫描二维码
        scanSearchHandler() {
            this.$refs.barcodeSearch.show = true;
        },
        scanSearchSuccess(value) {
            if (value) {
            let model = "add"
            let filterInfo =  {qrCode:value}
              
            this.$axios
                .post( uri.drawingPointList, filterInfo)
                .then(resp => {
                    if(resp)
                    {
                         this.$router.push('/safe/safeInspection/detail?pointId=' + resp.list[0].id + "&model=" + model)
                    }
                    else
                    {
                        Toast.fail(this.$t('safeInspection.notInListData'));
                    }
                })
                .catch(err => {
                    console.log('catch');
                    console.log(err);
             
                })
            
        
            }
            this.addEventBackButtonBack();
        },

    },

    mounted() {
        this.addEventBackButtonBack();
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
                        width: .8rem;
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
