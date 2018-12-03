<!--detail-->
<!--@author LiFanLingJue-->
<!--@date 2018/8/14-->
<template>
<van-popup ref="popup" v-model="show" class="safeDrawingPoint c_flex c_direction_v" position="right">
    <nav-bar left-arrow :left-text="$t('public.back')" @click-left="toBack" :title="title">
    </nav-bar>
    <van-search v-model="searchValue" input-align="center" background="#f1f6f9" :placeholder="$t('public.searchTips') " show-action @search="onSearch">
        <div slot="left-icon" @click="onChangeSearchType">
            {{currentSearchType.label}} &nbsp<van-icon :name="searchIcon"></van-icon>
        </div>
        <div slot="action" @click="onSearch">{{$t('public_button.search')}}</div>
    </van-search>
    <div ref="tab" style="position: relative;"> </div>
    <van-popup v-model="showSearchType" :lazy-render="false" style="top: unset;" position="top" :overlay="false"  :get-container="getContainer">
        <van-row  style="background-color:#f1f6f9;"  v-for="(item,index) in searchTypeList" :key="index">
            <van-cell style="background-color:#f1f6f9; margin-left: 12px;" :value='item.label' @click="onSelectSearchType(item)" />
        </van-row>
    </van-popup>
    <div class="content c_flex_1" ref="content">
        <van-pull-refresh v-model="pullRefreshLoading" @refresh="onRefresh">
            <van-list v-model="loading" :finished="finished" @load="getData">
                <van-cell-group class="cellGroup">
                    <van-cell class="cardContainer" v-for="(item, index) in listData">
                        <div @click="itemClickHandler(item)">
                            <van-cell class="cell" :key="index">
                                <van-cell class="dangerPoint van-hairline--bottom">
                                    <van-row>
                                        <!--姓名-->
                                        <van-col span="12">
                                            <span >{{$t('projectUserRole.user.name')}} :</span>
                                            <span> {{item.user.name}}
                                            </span>
                                        </van-col>
                                        <!--岗位-->
                                        <van-col span="12">
                                            <span  >{{$t('projectUserRole.position')}} :</span>
                                            <span>  {{$translate({key: 'sys_role', value: item.position})}}</span>
                                        </van-col>
                                    </van-row>
                                    <van-row>
                                        <span >{{$t('projectUserRole.user.mobile')}} :</span>
                                        <span>{{item.user.loginName}}</span>
                                    </van-row>
                                    <van-row>
                                        <span >{{$t('projectUserRole.user.email')}} :</span>
                                        <span>{{item.user.email}}</span>
                                    </van-row>
                                    <van-row>
                                        <!--所属公司-->
                                        <span  >{{$t('projectUserRole.office.name')}} :</span>
                                        <span>{{item.office.name}}</span>
                                    </van-row>
                                </van-cell>
                            </van-cell>
                        </div>
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
            searchIconList: ["icon-jiantouxia", "icon-jiantoushang"],
            searchIcon: "icon-jiantouxia",
            showSearchType: false,
            searchFormModel: {},
            currentSearchType: {},
            show: false,
            searchValue: '',
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
        searchTypeList() {
            return [{
                    type: 'name',
                    label: this.$t('projectUserRole.user.name'), //姓名
                    prop: 'user.name'
                },
                {
                    type: 'mobile',
                    label: this.$t('projectUserRole.user.mobile'), //电话
                    prop: 'user.loginName'
                },
                {
                    type: 'office',
                    label: this.$t('projectUserRole.office.name'), //所属公司
                    prop: 'office.name'
                }
            ]
        }
    },
    watch: {
        show(value) {
            if (value) {
                this.addEventBackButtonBack()
                this.currentSearchType = this.searchTypeList[0]
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
            this.searchFormModel = {}
            this.searchFormModel = this.getObjByDot(this.searchValue, this.currentSearchType.prop)
            this.onRefresh()
        },
        getObjByDot(model, modelKey) {
            if (modelKey.indexOf('.') < 0) {
                return {
                    [modelKey]: model
                }
            }
            let key = modelKey.split('.')
            let current = model
            for (let i = key.length - 1; i >= 0; i--) {
                current = {
                    [key[i]]: current
                }
            }
            return current
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

        itemClickHandler(item) {
            if (this.showSearchType) {
                this.onChangeSearchType()
                return
            }
            this.$emit('callback', item)
            this.show = false
        },
        onSelectSearchType(item) {
            this.currentSearchType = item
            this.onChangeSearchType()
        },
        onChangeSearchType() {
            this.searchIcon = this.searchIcon == this.searchIconList[0] ? this.searchIconList[1] : this.searchIconList[0]
            this.showSearchType = !this.showSearchType
        },
        getContainer() {
            return this.$refs.tab
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

    }
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
