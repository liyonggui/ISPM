<!--detail-->
<!--@author LiFanLingJue-->
<!--@date 2018/8/14-->
<template>
<van-popup ref="popup" v-model="show" class="safeDrawingPoint c_flex c_direction_v" position="right">
    <nav-bar left-arrow :left-text="$t('public.back')" @click-left="toBack" :title="title">
    </nav-bar>
    <van-search v-model="searchFormModel.name" background="#f1f6f9" :placeholder="$t('safeRectify.listSearchTip') " show-action @search="onSearch">
        <div slot="action" @click="onSearch">{{$t('public_button.search')}}</div>
    </van-search>
    <drawing-filter ref="drawingFilter" @callback="onSelectDrawing"></drawing-filter>
    <div class="content c_flex_1" ref="content">
        <van-pull-refresh v-model="pullRefreshLoading" @refresh="onRefresh">
            <van-list v-model="loading" :finished="finished" @load="getData">
                <van-cell-group class="cellGroup">
                    <van-cell class="cardContainer" v-for="(item, index) in listData">
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
                                    <van-row>
                                        <!--危险点分类-->
                                        <van-col>
                                            <span class="cellLabel">{{$t('safeRectify.signType')}} :</span>
                                            <span>{{$translate({key: 'sign_type',value:item.signType})}}
                                            </span>
                                        </van-col>
                                    </van-row>
                                    <van-row>
                                        <!--危险点名称-->
                                        <van-col>
                                            <span class="cellLabel">{{$t('safeRectify.name')}} :</span>
                                            <span>{{item.name}}</span>
                                        </van-col>
                                    </van-row>
                                    <van-row>
                                        <!--危险点编号-->
                                        <span class="cellLabel">{{$t('safeRectify.pointCode')}} :</span>
                                        <span>{{item.code}}</span>
                                    </van-row>

                                    <van-row>
                                        <!--危险点状态-->
                                        <van-col>
                                            <span  class="cellLabel">{{ $t('safeRectify.status')}} :</span>
                                            <span>
                                                <van-tag   v-if="item.status" :type="calcStatusType(item.status)">
                                                {{$translate({key: item.signType=='sign_type_2'?'rail_status':'danger_status', value: item.status})}}
                                                </van-tag>
                                            </span>
                                        </van-col>

                                    </van-row>
                                    <van-row>
                                        <!--危险点性质-->
                                        <van-col>
                                            <span class="cellLabel">{{$t('safeRectify.pointProperty')}} :</span>
                                            <span>{{$translate({key: 'point_property',value:item.pointProperty})}}
                                            </span>
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
                            </div>

                        </van-cell>

                    </van-cell>
                </van-cell-group>
            </van-list>
        </van-pull-refresh>
        <no-data v-if="listData.length==0"></no-data>
    </div>

</van-popup>
</template>

<script>
import {
    Toast,
    Dialog
} from 'vant'

import drawingFilter from './drawingFilter'

export default {
    components: {
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

            searchFormModel: {},
            show: false
        };
    },
    props: {
        url: {
            type: String,
            required: false,
            default: '/safe/safeDrawingPoint/dangerousPointList',
        },
        title: {
            type: String,
            required: false
        },
        params: {
            type: Object,
            required: false
        },
    },
    computed: {

    },
    watch: {
        show(value) {
            if (value) {
                this.addEventBackButtonBack()
            }  
        },

    },
    methods: {
        //返回上一页
        toBack() {
            this.show = false
            this.$emit('callback')

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
            filterInfo = Object.assign({}, filterInfo, this.params)
            this.$axios
                .post(this.url, filterInfo)
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
        itemClickHandler(item) {
            if (this.$refs.drawingFilter.show) {
                this.$refs.drawingFilter.show = false
                return
            }
            this.$emit('callback', item)
            this.show = false
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

    },

   
};
</script>

<style lang="less" scoped>
.safeDrawingPoint {
    width: 100%;
    height: 100%;
    box-sizing: border-box;
    background: #f1f6f9;

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
