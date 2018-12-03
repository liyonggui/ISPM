<!--detail-->
<!--@author LiFanLingJue-->
<!--@date 2018/8/14-->
<template>
<div class="safeDrawingPoint c_flex c_direction_v">
    <nav-bar left-arrow :left-text="$t('public.back')" @click-left="toBack" :title="$t('safeCheck.routerTitle')">
        <div slot="right" class="van-nav-bar__text">
            <van-icon style="font-size: .2rem; margin-right: .05rem" name="add-o" @click="addHandler" v-permission="$permission.safe_check.add" />
        </div>
    </nav-bar>
    <van-search v-model="name" background="#f1f6f9" :placeholder="$t('safeCheck.listSearchTip') " show-action @search="onSearch" v-permission="$permission.safe_check.view">
        <div slot="action" @click="onSearch">{{$t('public_button.search')}}</div>
    </van-search>
    <div class="content c_flex_1" ref="content">
        <van-pull-refresh v-model="pullRefreshLoading" @refresh="onRefresh">
            <van-list v-model="loading" :finished="finished" @load="getData">
                <van-cell-group class="cellGroup">
                    <van-swipe-cell class="cardContainer" v-for="(item, index) in listData" :right-width="65" :item="item" :on-close="deleteItemHandler">
                        <van-cell class="cell" :key="index">
                            <div @click="itemClickHandler(item)">
                                <van-cell class="dangerPoint van-hairline--bottom">
                                    <van-cell>
                                        <van-row>
                                            <!--名称-->
                                            <van-col>
                                                <span class="cellLabel">{{$t('safeCheck.name')}} :</span>
                                                <span>{{item.name}}</span>
                                            </van-col>
                                        </van-row>
                                        <van-row>
                                            <!--编号-->
                                            <span class="cellLabel">{{$t('safeCheck.code')}} :</span>
                                            <span>{{item.code}}</span>
                                        </van-row>
                                        <van-row>
                                            <!--区域-->
                                            <span class="cellLabel">{{$t('safeCheck.region')}} :</span>
                                            <span>{{$bizTranslate({key: 'region', value: item.region}).name}}</span>
                                        </van-row>
                                        <van-row>
                                            <!--检查类型-->
                                            <span class="cellLabel">{{$t('safeCheck.type')}} :</span>
                                            <span>{{$translate({key: 'rectify_type', value: item.type})}}</span>
                                        </van-row>

                                        <van-row>
                                            <!--检查结论-->
                                            <van-col>
                                                <span>{{$t('safeCheck.checkResult')}} :</span>
                                                <span>
                                                <van-tag style="margin-left: 20px;" v-if="item.checkResult" :type="calcStatusType(item.checkResult)">
                                                {{$translate({key: 'check_result', value: item.checkResult})}}
                                                </van-tag>
                                            </span>
                                            </van-col>
                                        </van-row>
                                        <van-row>
                                            <!--检查时间-->
                                            <span class="cellLabel">{{$t('safeCheck.checkTime')}} :</span>
                                            <span>{{item.checkTime.slice(0, 10)}}</span>
                                        </van-row>
                                    </van-cell>
                                </van-cell>
                            </div>
                            <van-cell>
                                <van-row style="text-align: right;    margin-bottom: .05rem;">
                                    <!--编辑-->
                                    <van-button size="small" :disabled="!!item.safeRectify" @click.stop="editHandler(item)" v-permission="$permission.safe_check.edit">
                                        {{$t('public_button.edit')}}
                                    </van-button>
                                    <!--整改派单-->
                                    <van-button size="small" :disabled="item.checkResult !='check_result_1' || !!item.safeRectify" @click.stop="rectifyHandler(item)" v-permission="$permission.safe_check.rectify">
                                        {{$t('safeCheck.rectify')}}
                                    </van-button>
                                </van-row>
                            </van-cell>

                        </van-cell>
                        <van-button type="danger" :disabled="!!item.safeRectify" class="right_delete c_flex c_a_center c_j_center" slot="right" v-text="$t('public_button.delete')" v-permission="$permission.safe_check.delete"></van-button>
                    </van-swipe-cell>
                </van-cell-group>
            </van-list>
        </van-pull-refresh>
        <no-data v-if="listData.length==0"></no-data>
    </div>

</div>
</template>

<script>
import {
    Toast,
    Dialog
} from 'vant'

import cloneDeep from "lodash/cloneDeep"

const uri = {
    itemsList: '/safe/safeCheck/list',
    deleteItem: '/safe/safeCheck/delete'
};
export default {

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
            name:'',
            rowData: {},
            model: '',
            searchFormModel: {},

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
            this.$router.push('/safe/safeCheck/detail')
        },
        editHandler(item) {
            let model = "edit"
            this.$router.push('/safe/safeCheck/detail?id=' + item.id + "&model=" + model)
        },
        rectifyHandler(item) {
            this.$router.push('/safe/safeCheck/renovate?id=' + item.id)
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
            this.$router.push('/safe/safeCheck/detail?id=' + item.id + "&model=" + model)
        },

        calcStatusType(status) {
            switch (status) {
                case 'check_result_0':
                    return 'success'
                case 'check_result_1':
                    return 'danger'
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
                        width: .75rem;
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
