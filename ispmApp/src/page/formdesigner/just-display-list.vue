<template>
    <div class="fd_just_display_list c_flex c_direction_v">
        <nav-bar left-arrow :left-text="$t('public.back')" @click-left="toBack" :title="menu.title">
        </nav-bar>
        <div class="content c_flex_1" ref="content">
            <van-pull-refresh v-model="pullRefreshLoading" @refresh="onRefresh">
                <van-list v-model="loading" :finished="finished" :immediate-check="false" :offset="50" @load="getData">
                    <van-cell-group>
                        <van-cell v-for="(item, index) in listData" :item="item" :key="index" @click="itemClickHandler(item)" clickable>
                            <van-row>
                                <van-col span="18">
                                    <van-row>
                                        <span style="color: #9b9b9b;">创建人:</span>
                                        <span v-text="item.createBy.name"></span>
                                    </van-row>
                                    <van-row>
                                        <span style="color: #9b9b9b;">创建时间:</span>
                                        <span v-text="item.createDate ? item.createDate : ''"></span>
                                    </van-row>
                                </van-col>
                                <van-col span="6">
                                    <van-row v-if="template.workflowId">
                                        <span style="color: #9b9b9b;">状态:</span>
                                        <van-tag plain v-if="item.auditStatus" v-text="$translate({key: 'audit_status', value: item.auditStatus})" :type="calcStatusType(item.auditStatus)"></van-tag>
                                    </van-row>
                                </van-col>
                            </van-row>
                        </van-cell>
                    </van-cell-group>
                </van-list>
            </van-pull-refresh>
        </div>
        <detail-popup v-model="showDetailPopup" :template="template" :item="item" :title="menu.title"></detail-popup>
    </div>
</template>

<script>
import cloneDeep from 'lodash/cloneDeep';
import { Toast } from 'vant';
import detailPopup from './just-display-detail';

const uri = {
    list: '/formdesigner/table/list',
    template: '/formdesigner/table/template'
};

export default {
    data() {
        return {
            menu: {
                title: ''
            },
            template: {
                id: '',
                versionId: '',
                structure: [],
                properties: {}
            },
            showDetailPopup: false,
            item: {},
            pullRefreshLoading: false,
            loading: false,
            finished: false,
            listData: [],
            totalCount: 0,
            pageInfo: { pageNo: 1, pageSize: 10 }
        };
    },
    components: { detailPopup },
    methods: {
        //返回上一页
        toBack(e) {
            this.$router.push('/index?active=1')
        },
        // init
        init() {
            // 获取模板ID
            this.template.id = this.$route.query.id;
            // 获取菜单信息
            this.menu = JSON.parse(this.$route.query._menu);
            // 获取模板信息
            this.getTemplate(this.template.id);
        },
        // 查询模板
        getTemplate(id) {
            Toast.loading({ mask: true, duration: 0, loadingType: 'spinner' });
            this.$axios.post(uri.template, {id}).then(res => {
                this.template = res;
                this.$set(this.template, 'properties', JSON.parse(res.properties));
                this.$set(this.template, 'structure', JSON.parse(res.structure));
                this.getData();
            }).finally(res => {
                Toast.clear();
            });
        },
        onRefresh() {
            setTimeout(() => {
                this.pageInfo = { pageNo: 1, pageSize: 10 };
                this.finished = false;
                this.pullRefreshLoading = false;

                this.getData(() => {
                    this.listData.splice(0)
                })

                //触发van-list调用load事件
                // this.$refs.content.scrollTop = 1
            }, 0);
        },
        getData(callback) {
            let filterInfo = Object.assign({}, this.pageInfo, {
                name: this.template.name,
                tableName: this.template.tableName
            });
            this.loading = true
            this.$axios.post(uri.list, filterInfo).then(resp => {
                this.totalCount = resp.count;
                if (callback && 'function' === typeof (callback)) {
                    callback()
                }
                // this.listData.splice(0)
                this.listData = this.listData.concat(resp.list)
                //检测是否已加载完全部数据
                if (this.pageInfo.pageSize * this.pageInfo.pageNo >= this.totalCount) {
                    this.finished = true
                } else {
                    this.pageInfo.pageNo++
                }
            }).catch(err => {
                this.finished = true;
            }).finally(res => {
                this.loading = false;
            })
        },
        itemClickHandler(item) {
            this.item = item;
            this.showDetailPopup = true;
        },
        calcStatusType(status) {
            switch (status) {
                case 'audit_status_4':
                    return 'danger';
                case 'audit_status_3':
                    return 'success';
                default:
                    return 'primary';
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
        showDetailPopup(val) {
            if (!val) {
                // 重新绑定返回事件
                this.addEventBackButtonBack();
            }
        }
    },
    mounted() {
        this.addEventBackButtonBack();
        this.init();
    }
};
</script>

<style lang="less" scoped type="text/less">
.fd_just_display_list {
  height: 100%;
  background-color: whitesmoke;
  .content {
    overflow: auto;
    -webkit-overflow-scrolling: touch;
  }
}
</style>
