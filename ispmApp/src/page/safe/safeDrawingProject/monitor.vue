<!--detail-->
<!--@author LiFanLingJue-->
<!--@date 2018/8/14-->
<template>
<div class="safeInspection c_flex c_direction_v">
    <nav-bar left-arrow :left-text="$t('public.back')" @click-left="toBack" :title="$t('drawing.routerTitle')">
    </nav-bar>
    <div class="content c_flex_1" ref="content">
        <van-pull-refresh v-model="pullRefreshLoading" @refresh="onRefresh">
            <van-list v-model="loading" :finished="finished" @load="getData">
                <van-cell-group class="cellGroup">
                    <div class="cardContainer" v-for="(item, index) in listData" :item="item">
                        <van-cell class="cell" :key="index" @click="itemClickHandler(item)" clickable>
                            <div class="cellContainer">
                                <van-row type="flex" justify="space-between">
                                    <!--图纸名称-->
                                    <van-col class="cellHead">{{item.name}}</van-col>
                                    <!--编号-->
                                    <van-col class="cellHeadToolbar">
                                        <span>{{$t('drawing.code')}}:</span>
                                        <span>{{item.code}}</span>
                                    </van-col>
                                </van-row>
                                <van-row type="flex" justify="space-between">
                                    <van-col>
                                        <!--区域/楼宇/分部分项/楼层-->
                                        <span v-if="item.region">{{$bizTranslate({key: 'region', value: item.region}).name}}/</span>
                                        <span v-if="item.building">{{$bizTranslate({key: 'building', value: item.building}).name}}/</span>
                                        <span v-if="item.subdivision">{{$translate({key: 'subdivision', value: item.subdivision})}}/</span>
                                        <span v-if="item.layer">{{$bizTranslate({key: 'layer', value: item.layer}).name}}</span>
                                    </van-col>
                                </van-row>
                                <van-row type="flex" justify="space-between">
                                    <van-col>
                                        <span v-if="item.actualLength">{{$t('drawing.actualArea')}}:</span>
                                        <span v-if="item.actualLength">{{item.actualLength}} ×</span>
                                        <span v-if="item.actualWidth">{{item.actualWidth}}</span>
                                    </van-col>
                                </van-row>
                                <van-row type="flex" justify="space-between">
                                    <!--登记人、状态-->
                                    <van-col>
                                        <span>{{item.createBy ? item.createBy.loginName : ''}}</span>
                                    </van-col>
                                    <!--登记时间-->
                                    <van-col>
                                        {{item.createDate}}
                                    </van-col>
                                </van-row>
                            </div>

                        </van-cell>

                    </div>
                </van-cell-group>
            </van-list>
        </van-pull-refresh>
    </div>
    <no-data v-if="listData.length==0"></no-data>
</div>
</template>

<script>
const uri = {
    itemsList: '/project/drawing/list'
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
            pointType: ''
        };
    },
    computed: {},
    methods: {
        //返回上一页
        toBack(e) {
            this.$router.push('/index?active=1')
        },

        onRefresh() {
            setTimeout(() => {
                this.pageInfo = {
                    pageNo: 1,
                    pageSize: 10
                };
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

        itemClickHandler(item) {
            if(!this.$checkPermission(this.pointType =='point_type_1'?this.$permission.dangerPoint.edit:this.$permission.dangerProject.edit))
            {
                return
            }
            else
            {
                //无附件不显示设计图编辑页面
                if (item.attachment == null) {
                    this.$message.warning(this.$t('drawing.drawingTip'))
                    return
                }
                let region = item.region + '-' + item.building + '-' + item.subdivision + '-' + item.layer
                sessionStorage.setItem('pointRouteParams', JSON.stringify({
                    drawingId: item.id,
                    attachmentId: item.attachment.id,
                    viewType: 'edit',
                    pointType: this.pointType,
                    actualWidth: item.actualWidth,
                    region: region
                }))

                this.$router.push('/cad')
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
        this.pointType = 'point_type_2'   
    }
};
</script>

<style lang="less" scoped>
.safeInspection {
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
                    padding: .1rem;
                    color: #9b9b9b;
                    .cellHead {
                        color: #000000;
                        font-size: .16rem;
                    }
                    .cellHeadToolbar {
                        color: #000000;
                    }
                    .cellLabel {
                        display: inline-block;
                        text-align: right;
                        width: .8rem;
                    }
                }
                .cell {
                    padding: 0;
                    .cellContainer {
                        padding: .1rem;
                    }
                }
            }
            .right_delete {
                width: .65rem;
                height: 100%;
                font-size: 15px;
                color: #ffffff;
                background: #F44;
            }
        }
    }
}
</style>
