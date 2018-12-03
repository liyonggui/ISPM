<!--safeRectify-->
<!--@author LiFanLingJue-->
<!--@date 2018/8/31-->
<template>
<div class="safeRectify c_flex c_direction_v" >
    <nav-bar left-arrow :left-text="$t('public.back')" @click-left="toBack" :title="$store.state.offLine ? $t('safeRectify.offLineTitle') : $t('safeRectify.title')">
        <div slot="right" class="van-nav-bar__text">
            <van-icon style="font-size: .2rem; margin-right: .1rem" name="add-o" @click="createHandler" v-permission="$permission.safe_rectify_list.add" />
            <!-- <van-icon style="font-size: .2rem; transform: rotateZ(180deg);" name="upgrade" @click="downloadOffline" v-if="!$store.state.offLine" /> -->
        </div>
    </nav-bar>
    <van-search v-model="searchValue" placeholder="请输入整改单名称查询" show-action @search="onRefresh">
        <div slot="action" @click="onRefresh">{{$t('public_button.search')}}</div>
    </van-search>
    <div class="content c_flex_1" ref="content">
        <van-pull-refresh v-model="pullRefreshLoading" @refresh="onRefresh">
            <van-list v-model="loading" :finished="finished" @load="getData">
                <van-cell-group class="cellGroup">
                    <van-swipe-cell class="cellSwipe" v-for="(item, index) in listData" :key="index" :right-width="65" :item="item" :on-close="deleteItemHandler">
                        <van-cell @click="itemClickHandler(item)" clickable>
                            <van-row>
                                <!--区域/楼宇/分部分项/楼层-->
                                <span style="color: #9b9b9b;">{{$t('safeRectify.region')}}:</span>
                                <span v-text="$bizTranslate({key: 'region', value: item.region}).name"></span>
                                <span v-if="item.building">/{{$bizTranslate({key: 'building', value: item.building}).name}}</span>
                                <span v-if="item.subdivision">/{{$translate({key: 'subdivision', value: item.subdivision})}}</span>
                                <span v-if="item.layer">/{{$bizTranslate({key: 'layer', value: item.layer}).name}}</span>
                            </van-row>
                            <van-row>
                                <!--整改单分类-->
                                <span style="color: #9b9b9b;">{{$t('safeRectify.rectifyType')}}:</span>
                                <span>{{$translate({key: 'rectify_type', value: item.type})}}</span>
                            </van-row>
                            <van-row>
                                <!--整改单名称-->
                                <span style="color: #9b9b9b;">{{$t('safeRectify.rectifyListName')}}:</span>
                                <span v-text="item.rectifyListName"></span>
                            </van-row>
                            <van-row v-if="item.drawingPoint">
                                <!--整改单编号-->
                                <span style="color: #9b9b9b;">{{$t('safeRectify.rectifyListCode')}}:</span>
                                <span v-text="item.rectifyListCode"></span>
                            </van-row>
                            <van-row>
                                <!--整改期限-->
                                <span style="color: #9b9b9b;">{{$t('safeRectify.rectifyDate')}}:</span>
                                <span>{{item.rectifyDate ? item.rectifyDate.slice(0,10) : ''}}</span>
                            </van-row>
                            <van-row>
                                <van-col span="12">
                                    <!--状态-->
                                    <span style="color: #9b9b9b;">{{$t('safeRectify.status')}}:</span>
                                    <span>{{$translate({key: 'rectify_status', value: item.status})}}</span>
                                </van-col>
                                <van-col span="12">
                                    <!--严重程度-->
                                    <span style="color: #9b9b9b;">{{$t('safeRectify.seriousLevel')}}:</span>
                                    <span>{{$translate({key: 'serious_level', value: item.seriousLevel})}}</span>
                                </van-col>
                            </van-row>

                            <van-row style="text-align: right">
                                <!--复查(整改完成后)-->
                                <van-button size="small" v-if="item.audit==true&&item.status=='rectify_status_1'" @click.stop="onReCheck(item)" type="primary">
                                    {{$t('operation.recheck')}}
                                </van-button>
                                <!--整改(发起工作流或者驳回后)))-->
                                <van-button size="small" v-if="item.audit==true&&(item.status=='rectify_status_4'||item.status=='rectify_status_3')" @click.stop="onRectify(item)" type="primary">
                                    {{$t('operation.rectify')}}
                                </van-button>
                                <!--发起工作流-->
                                <van-button size="small" @click.stop="initiatingWorkflow(item)" v-permission="$permission.safe_rectify_list.approve" type="primary" :loading="item._loading" :disabled="item.status!=='rectify_status_0'">
                                    {{$t('public.initiatingWorkflow')}}
                                </van-button>
                                <!--编辑-->
                                <van-button size="small" @click.stop="editHandler(item)" v-permission="$permission.safe_rectify_list.edit" type="primary" :disabled="item.status!=='rectify_status_0'">
                                    {{$t('public_button.edit')}}
                                </van-button>
                            </van-row>
                        </van-cell>
                        <span class="right_delete c_flex c_a_center c_j_center" slot="right" v-permission="$permission.safe_rectify_list.delete"
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
import {
    Toast
} from 'vant'

const uri = {
    list: '/safe/safeRectify/list',
    delete: '/safe/safeRectify/delete'
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

            itemData: {},
            reloadFlag: false,

            searchValue: '',
            cacheListDone: false
        };
    },
    methods: {
        //返回上一页
        toBack() {
            this.$router.push('/index?active=1')
        },

        onRefresh() {
            setTimeout(() => {
                this.pageInfo = {
                    pageNo: 1,
                    pageSize: 10
                };
                if (this.searchValue) {
                    let rectifyListName = this.searchValue;
                    this.pageInfo.rectifyListName = rectifyListName;
                }
                this.listData = [];
                this.finished = false;
                this.pullRefreshLoading = false;
                //触发van-list调用load事件
                this.$refs.content.scrollTop = 1
            }, 500);

        },
        getData() {
            let filterInfo = Object.assign({}, this.pageInfo);
            this.$axios
                .post(uri.list, filterInfo, {
                    _cache: 'safeRectify'
                })
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

        createHandler() {
            this.$router.push({
                name: 'safe_rectify_detail'
            });
        },
        editHandler(item) {
            this.$router.push({
                name: 'safe_rectify_detail',
                query: {
                    id: item.id
                }
            });
        },
        deleteItemHandler(position, instance) {
            if (position === 'right') {
                if (this.$store.state.offLine) {
                    instance.close();
                    return Toast.fail(this.$t('message.offLine'))
                }
                if (instance.$attrs.item.status !== 'rectify_status_0') {
                    return Toast.fail(this.$t('只允许删除初始状态的整改信息'))
                }
                this.$dialog.confirm({
                    message: this.$t('modalTips.deleteModalTips')
                }).then(() => {
                    this.$axios
                        .post(uri.delete, {
                            id: instance.$attrs.item.id,
                            delFlag: '1'
                        })
                        .then(resp => {
                            Toast.success(this.$t('operationTips.deleteSuccess'));
                            this.reloadFlag = true;
                        })
                        .catch(err => {})
                        .finally(resp => {
                            instance.close()
                        })
                }).catch(() => {})

            } else {
                instance.close()
            }
        },
        itemClickHandler(item) {
            if (this.$store.state.offLine) {
                return Toast.fail(this.$t('message.offLine'))
            }
            if (!this.$checkPermission(this.$permission.safe_rectify_list.view)) {
                return
            } else {
                this.$router.push({
                    name: 'safe_rectify_info',
                    query: {
                        id: item.id
                    }
                })
            }
        },
        //整改
        onRectify(item) {
            this.$router.push({
                name: '/safe/safeRectify/result/approve',
                query: {
                    id: item.id
                }
            })
        },
        //复查
        onReCheck(item) {
            this.$router.push({
                name: '/safe/safeRectify/resultReview/approve',
                query: {
                    id: item.id
                }
            })
        },
        initiatingWorkflow(item) {
            let submitModel = cloneDeep(item);
            this.$set(item, '_loading', true);
            this.$axios
                .post("/activiti/safeRectify/start", submitModel, {
                    _queue: true,
                    _queueConfig: {
                        page: '整改列表',
                        action: '发起工作流'
                    }
                })
                .then(res => {
                    this.reloadFlag = true;
                })
                .catch(err => {
                    console.log("catch");
                    console.log(err)
                })
                .finally(res => {
                    item._loading = false;
                })
        },

        downloadOffline() {
            this.$dialog.confirm({
                message: this.$t('modalTips.downOffline')
            }).then(() => {
                this.cacheListDone = false;
                Toast.loading({
                    mask: true,
                    duration: 0,
                    loadingType: 'spinner'
                });
                //缓存数据前先清空该模块之前的缓存内容
                let caches = localStorage.cache ? JSON.parse(localStorage.cache) : {};
                caches['safeRectify'] = {};
                localStorage.cache = JSON.stringify(caches);

                this.cacheListData({
                    pageNo: 1,
                    pageSize: 10
                })
            }).catch(() => {})
        },
        cacheListData(pageInfo) {
            let _pageInfo = cloneDeep(pageInfo);
            this.$axios.post('/safe/safeRectify/list', _pageInfo, {
                    _cache: 'safeRectify'
                })
                .then(resp => {
                    resp.list.forEach((item, index) => {
                        if (index === resp.list.length - 1) {
                            this.cacheItemData(item.id, true)
                        } else {
                            this.cacheItemData(item.id)
                        }
                    });

                    //检测是否已加载完全部数据（只缓存10页数据）
                    if (_pageInfo.pageSize * _pageInfo.pageNo < resp.count && _pageInfo.pageNo < 10) {
                        _pageInfo.pageNo++;
                        this.cacheListData(_pageInfo);
                    } else {
                        this.cacheListDone = true;
                    }
                })
                .catch((resp) => {
                    Toast.clear()
                })
        },
        cacheItemData(id, isLast) {
            this.$axios.post('/safe/safeRectify/get',
                    Object.assign({
                        id: id
                    }), {
                        _cache: 'safeRectify'
                    })
                .then(resp => {
                    //检测是否已加载完全部数据
                    if (isLast && this.cacheListDone) {
                        this.$axios.post('/project/projectUserRole/userList', {
                                delFlag: "0",
                                pageSize: -1
                            }, {
                                _cache: 'userList'
                            })
                            .finally(() => {
                                Toast.clear();
                                Toast.success(this.$t('operationTips.downloadSuccess'))
                            })
                    }
                })
                .catch((resp) => {
                    Toast.clear()
                })
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
        reloadFlag(value) {
            if (value) {
                this.onRefresh();
                this.reloadFlag = false;
            }
        }
    },
    mounted() {
        this.addEventBackButtonBack();
    }
};
</script>

<style lang="less" scoped>
.safeRectify {
    height: 100%;
    background-color: whitesmoke;

    .content {
        overflow: auto;
        -webkit-overflow-scrolling: touch;

        .cellGroup {
            background: none;

            &:after {
                border: none;
            }

            .cellSwipe {
                margin: .1rem;
                border-radius: .05rem;
                border: 1px solid #e5e5e5;

                &:first-child {
                    margin-top: 0;
                }

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
