<!--detail-->
<!--@author LiFanLingJue-->
<!--@date 2018/8/14-->
<template>
<van-popup v-model="show" class="content-overlay c_flex c_direction_v" position="right">
    <nav-bar left-arrow :left-text="$t('public.back')" @click-left="toBack" :title="listData.signType=='sign_type_1'? $t('safe_drawing_point.modifyLog'):$t('danger_project.modifyLog')">
    </nav-bar>
     <div class="content c_flex_1" ref="content">
        <van-search v-model="searchValue"  background="#f1f6f9" :placeholder="$t('safe_drawing_point.modifyLogSearchTip')" show-action @search="onRefresh">
            <div slot="action" @click="onRefresh">{{$t('public_button.search')}}</div>
        </van-search>
        <van-pull-refresh v-model="pullRefreshLoading" @refresh="onRefresh" >
            <van-list v-model="loading" :finished="finished" @load="getData" >
             <van-cell-group class="cellGroup">
                  <div class="cardContainer" v-for="(item, index) in listData"    :item="item" >  
                    <van-cell style="background: none;">
                        <van-row>
                            <!--危险点名称-->
                            <van-col span="20">
                                <span class="cellLabel">{{$t('electric_fence_list.name')}}:</span>
                                <span>{{item.name}}</span>
                            </van-col>
                            <!--危险点状态-->
                            <van-col span="4">
                                <span>
                                    <van-tag plain v-if="item.status" :type="calcStatusType(item.status)">
                                    {{$translate({key: 'rail_status', value: item.status})}}
                                    </van-tag>
                                </span>
                            </van-col> 
                        </van-row>
                        <van-row>
                            <!--危险点分类-->
                            <span class="cellLabel">{{$t('electric_fence_list.drawingPointType')}} :</span>
                            <span>{{$translate({key: 'rail_type',value:item.drawingPointType})}}
                                        </span>
                        </van-row>
                        <van-row>
                            <!--危险点编号-->
                            <span class="cellLabel">{{$t('electric_fence_list.pointCode')}} :</span>
                            <span>{{item.code}}</span>
                        </van-row>
                        <van-row  v-if="item.registerMan &&item.regiserDate">
                            <!--登记人、状态-->
                            <van-col>
                                <span>{{$t('safe_drawing_point.registerMan')}} :</span>
                                <span>{{item.registerMan ? item.registerMan.name : ''}}</span>
                            </van-col>
                            <!--登记时间-->
                            <van-col>
                                {{item.regiserDate}}
                            </van-col>
                        </van-row>
                        <van-row  v-if="item.updateBy &&item.updateDate">
                            <!--修改人-->
                            <van-col >
                                <span>{{$t('safe_drawing_point.updateBy')}} :</span>
                                <span>{{item.updateBy ? item.updateBy.name : ''}}</span>
                            </van-col>
                            <!--修改时间-->
                            <van-col>
                                {{item.updateDate}}
                            </van-col>
                        </van-row>
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
 
const uri = {
    list: "/safe/safeDrawingPointLog/listForPoint"
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
            searchValue: '',
            show: false,
        };
    },
    props: {
        item: {
            type: Object,
            required: false
        }
    },

    computed: {},
    methods: {
        //返回上一页
        toBack(e) {
            this.show = false
            this.$emit('callback')
        },

        onRefresh() {
            setTimeout(() => {
                this.pageInfo = {
                    pageNo: 1,
                    pageSize: 10
                };
                if(this.searchValue)
                {
                    let updateBy={name: this.searchValue}
                    this.pageInfo.updateBy = updateBy
                }
                this.listData = [];
                this.finished = false;
                this.pullRefreshLoading = false;
            
            }, 500);
        },

        getData() {
            let filterInfo =
                Object.assign({}, this.pageInfo);
            filterInfo.drawingPoint = {
                id: this.item.id
            }
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
                })
        },

         calcStatusType(status) {
            switch (status) {
                case 'rail_status_1':
                    return 'success'
                case 'rail_status_2':
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
        }
    },
    watch: {
        item(value) {
            this.onRefresh()
        },
        show(value)
        {
            if(value)
            {
                this.addEventBackButtonBack()
            }
        }
    } 
};
</script>

<style lang="less" scoped>
.content-overlay {
    width: 100%;
    height: 100%;
    box-sizing: border-box;
    background: #f1f6f9; //   padding: 10px;
    .content {
        overflow: auto;
        .cellGroup {
            background: none;
            &:after {
                border: none;
            }
            .cardContainer {
                margin: .1rem;
                border-radius: .05rem;
                border: 2px solid #e5e5e5;
                background: white;
                .van-cell {
                    padding:.1rem .1rem 0 .1rem;
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
                        text-align: left;
                        width: .4rem;
                    }
                }
                .cell {
                    padding: 0;
                    .cellContainer {
                         padding:.1rem .1rem 0 .1rem;
                    }
                }
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
    .van-tag
    {
        padding: 2px 6px 2px 2px;
    }

}

 
 
</style>
