<template>
    <div class="safeDisclosure c_flex c_direction_v">
        <nav-bar left-arrow :left-text="$t('public.back')" @click-left="toBack" :title="$t('safeDisclosureConfirm.title')"></nav-bar>
        <div class="content c_flex_1" ref="content">
            <van-pull-refresh v-model="pullRefreshLoading" @refresh="onRefresh">
                <van-list v-model="loading" :finished="finished" :immediate-check="false" :offset="50" @load="getData">
                    <van-cell-group>
                        <van-cell v-for="(item, index) in listData" :key="index" @click="itemClickHandler(item)">
                            <van-row>
                                <van-col span="18">
                                    <van-row>
                                        <span style="color: #9b9b9b;">{{$t('safeDisclosure.code')}}:</span>
                                        <span v-text="item.safeDisclosure.code"></span>
                                    </van-row>
                                </van-col>
                                <van-col span="6">
                                    <van-row style="text-align: right;">
                                        <van-tag plain v-if="item.status" v-text="$translate({key: 'disclosure_user', value: item.status})" :type="calcStatusType(item.status)"></van-tag>
                                    </van-row>
                                </van-col>
                            </van-row>
                            <van-row>
                                <span style="color: #9b9b9b;">{{$t('safeDisclosure.subProjectName')}}:</span>
                                <span v-text="item.safeDisclosure.subProjectName"></span>
                            </van-row>
                            <van-row>
                                <van-col span="12">
                                    <span style="color: #9b9b9b;">{{$t('safeDisclosure.educationLevel')}}:</span>
                                    <span v-text="$translate({key: 'education_level', value: item.safeDisclosure.educationLevel})"></span>
                                </van-col>
                                <van-col span="12" style="text-align: right;">
                                    <span style="color: #9b9b9b;">{{$t('safeDisclosure.createBy')}}:</span>
                                    <span>{{item.safeDisclosure &&item.safeDisclosure.createBy? item.safeDisclosure.createBy.name: ''}}</span>
                                </van-col>
                            </van-row>
                        </van-cell>
                    </van-cell-group>
                </van-list>
            </van-pull-refresh>
        </div>
        <detail-popup v-model="showDetailPopup" @reload-list="onRefresh" :item="item"></detail-popup>
    </div>
</template>

<script>
import cloneDeep from "lodash/cloneDeep";
import detailPopup from "./detail";
import { Toast } from "vant";

const uri = {
  list: "/activiti/safeDisclosure/userSafeDisclosure"
};
export default {
  data() {
    return {
      /**安全交底详细 */
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
      this.$router.push("/index?active=1");
    },

    onRefresh() {
      this.pageInfo = { pageNo: 1, pageSize: 10 };
      this.finished = true;
      this.pullRefreshLoading = true;
      this.loadig = false;

      this.getData(() => {
        this.listData.splice(0);
      });
    },
    getData(callback) {
      Toast.loading({ mask: true, duration: 0, loadingType: "spinner" });

      let filterInfo = Object.assign({}, this.pageInfo, { createBy: {} });
      this.loading = true;
      this.$axios
        .post(uri.list, filterInfo)
        .then(resp => {
          this.totalCount = resp.count;

          if (callback && "function" === typeof callback) {
            callback();
          }

          this.listData = this.listData.concat(resp.list);

          //检测是否已加载完全部数据
          if (
            this.pageInfo.pageSize * this.pageInfo.pageNo >=
            this.totalCount
          ) {
            this.finished = true;
          } else {
            this.pageInfo.pageNo++;
            this.finished = false;
          }
        })
        .catch(err => {
          console.log(err);
          this.finished = true;
        })
        .finally(res => {
          this.$toast.clear();
          this.loading = false;
          this.pullRefreshLoading = false;
        });
    },

    itemClickHandler(item) {
      this.item = item;
      this.showDetailPopup = true;
    },

    calcDisclosureStatusType(status) {
      switch (status) {
        case "disclousure_status_2":
          return "primary";
        case "disclousure_status_1":
          return "success";
        default:
          return "default";
      }
    },

    calcStatusType(status) {
      switch (status) {
        case "disclosure_user_0":
          return "primary";
        case "disclosure_user_1":
          return "success";
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
    this.getData();
  }
};
</script>

<style lang="less" scoped type="text/less">
    .safeDisclosure {
      height: 100%;
      background-color: whitesmoke;
      .content {
        overflow: auto;
        -webkit-overflow-scrolling: touch;
      }
    }
</style>
