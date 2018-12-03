<!--detail-->
<!--@author LiFanLingJue-->
<!--@date 2018/8/14-->
<template>
<van-popup v-model="show" class="drawingList c_flex c_direction_v" position="right">
    <nav-bar left-arrow :left-text="$t('public.back')" @click-left="toBack" :title="$t('safe_drawing_point.drawingList')">
    </nav-bar>
    <van-search v-model="searchFormModel.name" background="#f1f6f9" :placeholder="$t('safe_drawing_point.drawingListSearchTip')" show-action @search="onSearch">
        <div slot="action" @click="onSearch">{{$t('public_button.search')}}</div>
    </van-search>
    <drawing-filter ref="drawingFilter" @callback="onSelectDrawing"></drawing-filter>
    <div class="content c_flex_1" ref="content">
        <van-pull-refresh v-model="pullRefreshLoading" @refresh="onRefresh">
            <van-list v-model="loading" :finished="finished" @load="getData">
                <van-cell-group class="cellGroup">
                    <div class="cardContainer" v-for="(item, index) in listData" :item="item">
                        <van-cell style="background: white;">
                            <div @click="itemClickHandler(item)">
                                <div class="cellContainer van-hairline--bottom">
                                    <van-row type="flex" justify="space-between">
                                        <!--图纸名称-->
                                        <van-col class="cellHeadToolbar">
                                            <span>{{item.name}}</span>
                                        </van-col>
                                        <!--编号-->
                                        <van-col class="cellHeadToolbar">
                                            <span>{{$t('safe_drawing_point.drawingCode')}} :</span>
                                            <span>{{item.code}}</span>
                                        </van-col>
                                    </van-row>
                                    <van-row type="flex" class="region" justify="space-between">
                                        <van-col span="20">
                                            <!--区域/楼宇/分部分项/楼层-->
                                            <span v-if="item.region">{{$bizTranslate({key: 'region', value: item.region}).name}}/</span>
                                            <span v-if="item.building">{{$bizTranslate({key: 'building', value: item.building}).name}}/</span>
                                            <span v-if="item.subdivision">{{$translate({key: 'subdivision', value: item.subdivision})}}/</span>
                                            <span v-if="item.layer"> {{$bizTranslate({key: 'layer', value: item.layer}).name}}</span>
                                        </van-col>

                                    </van-row>

                                </div>
                            </div>
                        </van-cell>
                    </div>
                </van-cell-group>
            </van-list>
        </van-pull-refresh>

    </div>
    <no-data v-if="listData.length==0"></no-data>
</van-popup>
</template>

<script>
import drawingFilter from './drawingFilter'

const uri = {
    list: "/project/drawing/list"
};
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
            show: false,
        };
    },
   
    methods: {
        //返回上一页
        toBack() {
            this.show = false
            this.$emit('callback')
            this.$refs.drawingFilter.show = false
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
                this.getData()
            }, 500);
        },
        onSelectDrawing(value) {
            this.searchFormModel = Object.assign({}, this.searchFormModel, value)
            this.onRefresh()
        },
        getData() {
            this.$toast.loading({
                mask: true,
                duration: 0,
                message: this.$t('public.searchText')
            });
            let filterInfo =
                Object.assign({}, this.pageInfo);
            // filterInfo.drawingPoint = {
            //     id: this.item.id
            // }
            this.$axios
                .post(uri.list, filterInfo)
                .then(resp => {
                    this.totalCount = resp.count;
                    resp.list.forEach(item => {
                        this.listData.push(item)
                    });
                    console.log(this.listData)
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
                    this.$toast.clear()
                })
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
        }
    },
    watch: {
 
        show(value) {
            if (value) {
                this.addEventBackButtonBack()
                this.onRefresh()
            }
        }
    }
};
</script>

<style lang="less" scoped>
.drawingList {
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

                            background: white;

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

        }
    }

}
</style>
