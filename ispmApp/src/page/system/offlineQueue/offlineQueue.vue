<!--offlineQueue-->
<!--@author LiFanLingJue-->
<!--@date 2018/8/27-->
<template>
    <div class="offlineQueue c_flex c_direction_v">
        <nav-bar class="test" left-arrow :left-text="$t('public.back')" @click-left="toBack"
                 :title="$t('offlineQueue.title')"></nav-bar>
        <div class="content c_flex_1" ref="content">
            <van-pull-refresh v-model="pullRefreshLoading" @refresh="onRefresh">
                <van-list v-model="loading" :finished="finished" @load="getData">
                    <van-cell-group class="cellGroup">
                        <van-swipe-cell class="cellSwipe" v-for="(item, index) in listData" :key="index"
                                        :right-width="65"
                                        :item="item"
                                        :index="index"
                                        :on-close="deleteItemHandler">
                            <van-cell>
                                <!--页面名-->
                                <van-row>
                                    <van-col style="text-align: right" span="6">{{$t('offlineQueue.page')}}：</van-col>
                                    <van-col span="18" v-text="item.page"></van-col>
                                </van-row>
                                <!--动作-->
                                <van-row>
                                    <van-col style="text-align: right" span="6">{{$t('offlineQueue.action')}}：</van-col>
                                    <van-col span="18" v-text="item.action"></van-col>
                                </van-row>
                                <!--URL-->
                                <van-row>
                                    <van-col style="text-align: right" span="6">URL：</van-col>
                                    <van-col style="overflow-wrap: break-word;" span="18" v-text="item.url"></van-col>
                                </van-row>
                                <!--操作时间-->
                                <van-row>
                                    <van-col style="text-align: right" span="6">{{$t('offlineQueue.updateDate')}}：
                                    </van-col>
                                    <van-col span="18" v-text="item.updateDate"></van-col>
                                </van-row>

                                <van-row style="text-align: right">
                                    <van-button size="small" @click.stop="submit(item, index)" :loading="item._loading">
                                        {{$t('public_button.submit')}}
                                    </van-button>
                                </van-row>
                            </van-cell>
                            <span class="right_delete c_flex c_a_center c_j_center" slot="right"
                                  v-text="$t('public_button.delete')"></span>
                        </van-swipe-cell>
                    </van-cell-group>
                </van-list>
            </van-pull-refresh>
        </div>
    </div>
</template>

<script>
    import cloneDeep from 'lodash/cloneDeep'
    import {Toast} from 'vant'

    export default {
        data() {
            return {
                pullRefreshLoading: false,
                loading: false,
                finished: false,
                listData: [],
                totalCount: 0,
                pageInfo: {pageNo: 1, pageSize: 10}
            };
        },
        methods: {
            //返回上一页
            toBack(e) {
                this.$router.push('/index?active=1')
            },

            onRefresh() {
                setTimeout(() => {
                    this.pageInfo = {pageNo: 1, pageSize: 10};
                    this.listData = [];
                    this.finished = false;
                    this.pullRefreshLoading = false;
                    //触发van-list调用load事件
                    this.$refs.content.scrollTop = 1
                }, 0);
            },
            getData() {
                this.loading = true;
                let queue = localStorage.queue ? JSON.parse(localStorage.queue) : [];
                this.totalCount = queue.length;
                let resp = queue.slice((this.pageInfo.pageNo - 1) * this.pageInfo.pageSize, this.pageInfo.pageNo * this.pageInfo.pageSize);
                resp.forEach(item => {
                    this.listData.push(item)
                });

                //检测是否已加载完全部数据
                if (this.pageInfo.pageSize * this.pageInfo.pageNo >= this.totalCount) {
                    this.finished = true
                } else {
                    this.pageInfo.pageNo++
                }
                this.loading = false;
            },

            deleteItemHandler(position, instance) {
                if (position === 'right') {
                    this.$dialog.confirm({
                        message: this.$t('modalTips.deleteModalTips')
                    }).then(() => {
                        this.deleteQueueItem(instance.$attrs.index);
                        Toast.success(this.$t('operationTips.deleteSuccess'));
                        this.onRefresh()
                    }).catch(() => {})
                } else {
                    instance.close()
                }
            },
            submit(item, index) {
                Toast.loading({mask: true, duration: 0, loadingType: 'spinner'});
                this.$axios.post(item.url, JSON.parse(item.data))
                    .then(resp => {
                        Toast.clear();
                        this.deleteQueueItem(index);
                        Toast.success(this.$t('operationTips.commitSuccess'));
                        this.onRefresh()
                    })
            },
            deleteQueueItem(index) {
                let queue = localStorage.queue ? JSON.parse(localStorage.queue) : [];
                queue.splice(index, 1);
                localStorage.queue = JSON.stringify(queue);
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

        mounted() {
            this.addEventBackButtonBack();
        }
    };
</script>

<style lang="less" scoped type="text/less">
    .offlineQueue {
        height: 100%;
        background-color: whitesmoke;
        .content {
            overflow: auto;
            .cellGroup {
                background: none;
                &:after {
                    border: none;
                }
                .cellSwipe {
                    margin: .1rem;
                    border-radius: .05rem;
                    border: 1px solid #e5e5e5;
                    .van-cell {
                        padding: .1rem .1rem;
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
