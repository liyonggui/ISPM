<style lang="less" scoped>
.user-info,
.user-extra-info {
  display: block;
}

.user-extra-info {
  font-size: 12px;
  color: #999;
}
</style>
<template>
    <van-popup v-model="value" class="content-overlay" position="right">
        <nav-bar left-arrow :left-text="$t('public.back')" @click-left="cancel" :right-text="$t('public_button.save')" @click-right="submit" :title="$t('safeDisclosureContent.title')"></nav-bar>
        <div class="content c_flex_1" ref="content">
            <disclosure-filter ref="disclosureFilter" :default-filter="{type: worksType}" @callback="selectHandler"></disclosure-filter>
            <van-pull-refresh v-model="pullRefreshLoading" @refresh="onRefresh">
                <van-list v-model="loading" :finished="finished" :offset="50" @load="getData">
                    <van-radio-group v-model="selection">
                        <van-cell-group>
                            <van-cell v-for="(item, index) in listData" :key="index" center clickable @click="toggleSelection(item, index)">
                                <!-- <template slot="title">
                                    <span class="van-cell-text">{{ item.name }}</span>
                                </template> -->
                                <div class="c_flex c_j_between">
                                    <div>
                                        <span class="user-info van-cell-text">{{ item.name }}</span>
                                    </div>
                                    <van-radio :name="item"> </van-radio>
                                </div>
                            </van-cell>
                        </van-cell-group>
                    </van-radio-group>
                </van-list>
            </van-pull-refresh>
        </div>
    </van-popup>
</template>
<script>
import disclosureFilter from './disclosureFilter'
const uri = {
    list: "/safe/safeDisclosureContent/list"
}
export default {
    components: { disclosureFilter },
    data() {
        return {
            pullRefreshLoading: false,
            loading: false,
            finished: false,
            listData: [],
            totalCount: 0,
            pageInfo: { pageNo: 1, pageSize: 20 },

            /**选中的行项目 */
            selection: {},

            searchFormModel: {}
        }
    },
    props: {
        value: { type: Boolean, default: false, required: true },
        worksType: {}
    },

    watch: {
        value(val) {
            if (val) {
                this.addEventBackButtonBack()
                this.getData()
            } else {
                this.listData.splice(0)
                this.pageInfo = { pageNo: 1, pageSize: 20 }
            }
        }
    },

    methods: {
        cancel() {
            this.$emit('input', false)
        },
        submit() {
            this.$emit('select', this.selection)
            this.$emit('input', false)
        },
        selectHandler(result) {
            this.searchFormModel = { worksType: result.type }
            this.onRefresh()
        },
        onRefresh() {
            this.pageInfo = { pageNo: 1, pageSize: 20 };
            this.finished = true
            this.pullRefreshLoading = true;
            this.loadig = false
            this.getData(() => {
                this.listData.splice(0)
            })
        },
        getData(callback) {
            let filterInfo = Object.assign({ status: 'disclosure_content_3' }, this.pageInfo, Object.assign({ worksType: this.worksType }, this.searchFormModel));
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
                    console.log(err);
                    this.finished = true
                })
                .finally(res => {
                    this.loading = false
                    this.pullRefreshLoading = false
                })
        },

        toggleSelection(item, index) {
            this.selection = item
        },

        //监听返回按钮_按返回键后返回
        addEventBackButtonBack() {
            //监听返回按钮
            if (sessionStorage.plusready === "done") {
                plus.key.removeEventListener("backbutton", () => {
                    plus.runtime.quit();
                });
                plus.key.addEventListener("backbutton", () => {
                    this.cancel()
                });
            }
        }
    }
}
</script>

