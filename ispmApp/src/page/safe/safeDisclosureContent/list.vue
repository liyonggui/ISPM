<!-- 安全交底模板主列表 -->
<!-- @author Lisa -->
<!-- @date 2018/9/7 -->
<template>
    <div class="safeDisclosureContent c_flex c_direction_v">

        <nav-bar left-arrow :left-text="$t('public.back')" @click-left="toBack" :title="$store.state.offLine ? $t('safeDisclosureContent.offLineTitle') : $t('safeDisclosureContent.title')">
        </nav-bar>

        <div class="content c_flex_1" ref="content">
            <div class="filter">
                <div>我的交底模板</div>
                <van-switch v-model="checked" size="20px" @change="selfCheckedHandler" />
            </div>
            <van-pull-refresh v-model="pullRefreshLoading" @refresh="onRefresh">
                <van-list v-model="loading" :finished="finished" :immediate-check="false" :offset="80" @load="getData">
                    <van-cell-group>
                        <van-swipe-cell v-for="(item, index) in listData" :right-width="65" :item="item" :key="index">
                            <van-cell :key="index" @click="itemClickHandler(item)" clickable>
                                <van-row>
                                    <van-col span="24">
                                        <van-row>
                                            <van-col span="9" v-text="$t('safeDisclosureContent.code')"></van-col>
                                            <van-col span="15" v-text="item.code"></van-col>
                                        </van-row>
                                        <van-row>
                                            <van-col span="9" v-text="$t('safeDisclosureContent.name')"></van-col>
                                            <van-col span="15" v-text="item.name"></van-col>
                                        </van-row>
                                        <van-row>
                                            <van-col span="9" v-text="$t('safeDisclosureContent.educationLevel')"></van-col>
                                            <van-col span="15" v-text="$translate({key: 'education_level', value: item.educationLevel})"></van-col>
                                        </van-row>
                                        <van-row>
                                            <van-col span="9" v-text="$t('safeDisclosureContent.industry')"></van-col>
                                            <van-col span="15" v-text="$translate({key: 'industry', value: item.industry})"></van-col>
                                        </van-row>
                                        <van-row>
                                            <van-col span="9" v-text="$t('safeDisclosureContent.major')"></van-col>
                                            <van-col span="15" v-text="$translate({key: 'major', value: item.major})"></van-col>
                                        </van-row>
                                        <van-row>
                                            <van-col span="9" v-text="$t('safeDisclosureContent.worksType')"></van-col>
                                            <van-col span="15" v-text="$translate({key: 'works_type', value: item.worksType})"></van-col>
                                        </van-row>
                                        <van-row>
                                            <van-col span="9" v-text="$t('safeDisclosureContent.status')"></van-col>
                                            <van-col span="15">
                                                <van-tag plain v-if="item.status" v-text="$translate({key: 'disclosure_content', value: item.status})" :type="calcStatusType(item.status)">
                                                </van-tag>
                                            </van-col>
                                        </van-row>
                                    </van-col>
                                </van-row>
                                <van-row style="text-align: right">
                                    <van-button size="small" @click.stop="submitDetail(item)" type="primary" v-if="item.status === 'disclosure_content_1'">
                                        <!-- {{$t('operation.approve')}} -->
                                        提交审核
                                    </van-button>
                                    <!-- 审核 -->
                                    <van-button size="small" @click.stop="approveDetail(item)" type="primary" v-if="item.audit">
                                        {{$t('operation.approve')}}
                                    </van-button>
                                </van-row>
                            </van-cell>
                        </van-swipe-cell>
                    </van-cell-group>
                </van-list>
            </van-pull-refresh>
        </div>
    </div>
</template>

<script>
import cloneDeep from 'lodash/cloneDeep'
import { Dialog } from 'vant'
import detailPopup from './detail'
import { Toast } from 'vant'

const uri = {
    list: '/safe/safeDisclosureContent/list',
    delete: '/safe/safeDisclosureContent/delete',
    submit: '/safe/safeDisclosureContent/submit'
};
export default {
    data() {
        return {
            /**安全交底详细 */
            showDetailPopup: false,
            item: {},

            /**由我审批 */
            checked: true,

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

        onRefresh() {
            setTimeout(() => {
                this.pageInfo = { pageNo: 1, pageSize: 10 }
                this.finished = true
                this.pullRefreshLoading = true
                this.loadig = false

                this.getData(() => {
                    this.listData.splice(0)
                })
            }, 0)
        },

        getData(callback) {
            Toast.loading({ mask: true, duration: 0, loadingType: 'spinner' })

            let filterInfo = Object.assign({}, this.pageInfo, { createBy: {}, myself: this.checked });
            this.loading = true
            this.$axios
                .post(uri.list, filterInfo)
                .then(resp => {
                    this.totalCount = resp.count;

                    if (callback && 'function' === typeof (callback)) {
                        callback()
                    }

                    this.listData = this.listData.concat(resp.list)


                    //检测是否已加载完全部数据
                    if (this.pageInfo.pageSize * this.pageInfo.pageNo >= this.totalCount) {
                        this.finished = true
                    } else {
                        this.pageInfo.pageNo++
                        this.finished = false
                    }
                })
                .catch(err => {
                    this.finished = true
                })
                .finally(res => {
                    Toast.clear()
                    this.loading = false
                    this.pullRefreshLoading = false
                })
        },

        submitDetail(row) {
            Dialog.confirm({
                title: this.$t("modalTips.approveModalTitle"),
                message: this.$t("modalTips.approveModalTips"),
            }).then(() => {
                Toast.loading({ mask: true, duration: 0, loadingType: 'spinner' })
                this.$axios.post(uri.submit, { id: row.id })
                    .then(resp => {
                        this.onRefresh()
                    })
                    .catch(err => { })
                    .finally(resp => {
                        Toast.clear()
                    })
            }).catch(() => {
                Toast.clear()
            })
        },

        approveDetail(row) {
            this.$router.push({
                name: '/safe/safe-disclosure/content/approve',
                query: {
                    id: row.id,
                    taskId: row.taskId,
                    taskDefKey: row.taskDefKey,
                    variable: JSON.stringify(row.variable),
                    procInsId: row.procInsId
                }
            })
        },

        createHandler() {
            this.$router.push({ name: 'safe_disclosure_content_create' })
        },

        itemClickHandler(item) {
            // if(!this.$checkPermission(this.$permission.safe_disclosure_content.view)){
            //     return
            // } else {
            this.$router.push({ name: 'safe_disclosure_content_detail', query: { id: item.id } })
            // }
        },

        calcStatusType(status) {
            switch (status) {
                case 'disclosure_content_4':
                    return 'danger';
                case 'disclosure_content_3':
                    return 'success';
                case 'disclosure_content_2':
                    return 'primary';
            }
        },

        //监听返回按钮_按返回键后返回
        addEventBackButtonBack() {
            //监听返回按钮
            if (sessionStorage.plusready === "done") {
                plus.key.removeEventListener("backbutton", () => {
                    plus.runtime.quit()
                })
                plus.key.addEventListener("backbutton", () => {
                    this.toBack()
                })
            }
        },

        selfCheckedHandler(value) {
            this.onRefresh()
        }
    },

    watch: {},

    mounted() {
        this.addEventBackButtonBack()
        this.getData()
    }
};
</script>

<style lang="less" scoped type="text/less">
.safeDisclosureContent {
  height: 100%;
  background-color: whitesmoke;
  .content {
    overflow: auto;
    -webkit-overflow-scrolling: touch;

    .filter {
      display: flex;
      justify-content: space-between;
      padding: 5px 15px;
    }
  }
}
</style>
