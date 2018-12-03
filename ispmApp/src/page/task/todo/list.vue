<style lang="less" type="text/less">
.todoTask {
  height: 100%;
  .content {
    overflow: auto;
    -webkit-overflow-scrolling: touch;

    .pull-refresh-con {
      overflow: auto;
      height: 100%;
      padding: 0 6px;
      .van-pull-refresh__track {
        height: 100%;
      }
      .cells-con {
        background: inherit;
        .cell-con {
          margin: 6px 0;

          .cell-unit {
            border-radius: 4px;
            border: 1px solid #e5e5e5;
          }

          .field-title {
            color: #bfbfbf;
          }
        }
      }
    }
  }
}
</style>
<template>
    <div class="todoTask c_flex c_direction_v">
        <nav-bar left-arrow :left-text="$t('public.back')" @click-left="toBack" :title="$t('todoTask.title')"></nav-bar>
        <div class="content c_flex_1" ref="content">
            <van-pull-refresh class="pull-refresh-con" v-model="pullRefreshLoading" @refresh="onRefresh">
                <van-list v-model="loading" :finished="finished" :immediate-check="false" :offset="10" @load="getData">
                    <van-cell-group class="cells-con">
                        <div class="cell-con" v-for="(item, index) in listData" :key="index">
                            <van-cell class="cell-unit" @click="itemClickHandler(item)">
                                <div>
                                    <span class="field-title">任务标题：</span>{{item.variable.title}}
                                </div>
                                <div>
                                    <span class="field-title">当前环节：</span>{{item.taskName}}
                                </div>
                                <div>
                                    <span class="field-title">流程名称：</span>{{item.procDefName}}({{item.version}})
                                </div>
                                <div>
                                    <span class="field-title">创建时间：</span>{{item.taskCreateDate}}
                                </div>
                            </van-cell>
                        </div>
                    </van-cell-group>
                </van-list>
            </van-pull-refresh>
        </div>
    </div>
</template>

<script>
import cloneDeep from 'lodash/cloneDeep'

const uri = {
    list: '/smart-act/act/task/todo',
};
export default {
    data() {
        return {
            pullRefreshLoading: false,
            loading: false,
            finished: true,
            listData: [],
            totalCount: 0,
            pageInfo: { pageSize: -1 }
        };
    },
    methods: {
        //返回上一页
        toBack(e) {
            this.$router.push('/index?active=1')
        },

        onRefresh() {
            this.pageInfo = { pageSize: -1 }
            this.pullRefreshLoading = true;

            this.getData(() => {
                this.listData.splice(0)
                this.pullRefreshLoading = false
            })
        },
        getData(callback) {
            let filterInfo = Object.assign({}, this.pageInfo);
            this.loading = true
            this.$axios
                .post(uri.list, filterInfo)
                .then(resp => {
                    this.totalCount = resp.count;
                    if (callback && 'function' === typeof (callback)) {
                        callback()
                    }

                    this.listData = this.listData.concat(resp.list)

                })
                .finally(res => {
                    this.loading = false
                })
        },

        itemClickHandler(item) {
            this.$router.push({
                name: item.formKey, query: {
                    id: item.businessId,
                    taskId: item.taskId,
                    taskDefKey: item.taskDefKey,
                    variable: JSON.stringify(item.variable),
                    procInsId: item.procInsId
                }
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
    watch: {},

    mounted() {
        this.addEventBackButtonBack();
        this.getData()
    }
};
</script>
