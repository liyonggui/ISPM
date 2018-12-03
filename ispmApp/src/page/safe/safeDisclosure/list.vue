<style lang="less" scoped type="text/less">
  .safeDisclosure {
    height: 100%;
    background-color: whitesmoke;
    .filter {
      display: flex;
      justify-content: space-between;
      padding: 5px 15px;
    }
    .content {
      // position: absolute;
      // top: 80px;
      // bottom: 0;
      // left: 0;
      // right: 0;
      // overflow: auto;
      -webkit-overflow-scrolling: touch;

      .van-pull-refresh {
        height: 100%;
        overflow: auto;
        .van-pull-refresh__track {
          height: 100%;

          .info {
            display: flex;
            justify-content: space-between;
          }
        }
      }

      .right_delete {
        width: 0.65rem;
        height: 100%;
        font-size: 15px;
        color: #ffffff;
        background: #f44;
      }
    }
  }
</style>
<template>
  <div class="safeDisclosure c_flex c_direction_v">
    <nav-bar left-arrow :left-text="$t('public.back')" @click-left="toBack" :title="$t('safeDisclosure.title')">
      <div slot="right" class="van-nav-bar__text">
        <van-icon style="font-size: .2rem; margin-right: .1rem" name="add-o" @click="createHandler" />
      </div>
    </nav-bar>
    <div class="filter">
      <div>我的交底</div>
      <van-switch v-model="checked" size="20px" @change="selfCheckedHandler" />
    </div>
    <div class="content c_flex_1" ref="content">
      <van-pull-refresh v-model="pullRefreshLoading" @refresh="onRefresh">
        <van-list v-model="loading" :finished="finished" :offset="10" @load="handleListLoadMore">
          <van-cell-group>
            <van-swipe-cell v-for="(item) in listData" :right-width="65" :item="item" :key="item.id" :on-close="deleteItemHandler">
              <van-cell @click="itemClickHandler(item)" clickable>
                <van-row>
                  <van-col span="18">
                    <van-row>
                      <span style="color: #9b9b9b;">{{$t('safeDisclosure.code')}}:</span>
                      <span v-text="item.code"></span>
                    </van-row>
                  </van-col>
                  <van-col span="6">
                    <van-row style="text-align: right;">
                      <van-tag :type="item.status | statusFilter">{{$translate({key: 'disclousure_status', value: item.status})}}</van-tag>
                    </van-row>
                  </van-col>
                </van-row>
                <van-row>
                  <span style="color: #9b9b9b;">{{$t('safeDisclosure.subProjectName')}}:</span>
                  <span v-text="item.subProjectName"></span>
                </van-row>
                <van-row>
                  <van-col span="12">
                    <span style="color: #9b9b9b;">{{$t('safeDisclosure.educationLevel')}}:</span>
                    <span v-text="$translate({key: 'education_level', value: item.educationLevel})"></span>
                  </van-col>
                </van-row>
                <div class="info">
                  <div>
                    <span style="color: #9b9b9b;">{{$t('safeDisclosure.createBy')}}:</span>
                    <span v-text="item.createBy.name"></span>
                  </div>
                  <div v-if="item.status === 'disclousure_status_3'">
                    <span style="color: #9b9b9b;">{{$t('safeDisclosure.endDate')}}:</span>
                    <span v-text="item.endDate"></span>
                  </div>
                </div>
              </van-cell>
              <span class="right_delete c_flex c_a_center c_j_center" slot="right" v-text="$t('public_button.delete')" v-permission="$permission.safe_disclosure_info.delete"></span>
            </van-swipe-cell>
          </van-cell-group>
        </van-list>
      </van-pull-refresh>
    </div>
    <detail-popup v-model="showDetailPopup" @reloadList="reloadList" :item="item"></detail-popup>
  </div>
</template>

<script>
import cloneDeep from "lodash/cloneDeep";
import { Toast } from "vant";
import detailPopup from "./detail";

const uri = {
  list: "/activiti/safeDisclosure/list",
  delete: "/activiti/safeDisclosure/delete"
};
export default {
  data() {
    return {
      /**安全交底详细 */
      showDetailPopup: false,
      item: {},

      /**由我审批 */
      checked: true,

      reloadFlag: false,

      pullRefreshLoading: false,
      loading: false,
      finished: false,
      listData: [],
      totalCount: 0,
      pageInfo: { pageNo: 1, pageSize: 10 }
    };
  },
  components: { detailPopup },
  filters: {
    statusFilter(value) {
      if (value === "disclousure_status_1") return "default";
      else if (value === "disclousure_status_2") return "primary";
      else if (value === "disclousure_status_3") return "success";
    }
  },
  methods: {
    //返回上一页
    toBack(e) {
      this.$router.push("/index?active=1");
    },

    onRefresh() {
      this.pageInfo = { pageNo: 1, pageSize: 10 };
      this.getData();
    },
    handleListLoadMore() {
      this.getData();
    },

    getData() {
      let filterInfo = Object.assign({}, this.pageInfo, {
        createBy: {},
        myself: this.checked
      });

      this.$axios
        .post(uri.list, filterInfo)
        .then(resp => {
          if (this.pullRefreshLoading) this.listData.splice(0);
          this.listData = this.listData.concat(resp.list);

          this.totalCount = resp.count;
          //检测是否已加载完全部数据
          if (
            this.pageInfo.pageSize * this.pageInfo.pageNo >=
            this.totalCount
          ) {
            this.finished = true;
          } else {
            this.finished = false;
            this.pageInfo.pageNo++;
          }
        })
        .catch(err => {
          this.finished = true;
        })
        .finally(res => {
          this.loading = false;
          this.pullRefreshLoading = false;
        });
    },

    createHandler() {
      this.$router.push({ name: "safe_disclosure_create" });
    },
    deleteItemHandler(position, instance) {
      if (position === "right") {
        this.$dialog
          .confirm({
            message: this.$t("modalTips.deleteModalTips")
          })
          .then(() => {
            this.$axios
              .post(uri.delete, { id: instance.$attrs.item.id })
              .then(resp => {
                this.$toast({
                  iconClass: "van-icon van-icon-success",
                  message: this.$t("operationTips.deleteSuccess")
                });
                this.onRefresh();
              })
              .catch(err => {})
              .finally(resp => {
                instance.close();
              });
          });
      } else {
        instance.close();
      }
    },
    itemClickHandler(item) {
      /**查看详情，无需路由跳转，使用 Popup 实现 */
      // this.$router.push({ name: 'safe_safeInspection_detail', query: { id: item.id, status: item.status } })

      // if (!this.$checkPermission(this.$permission.safe_disclosure.view)) {
      // return
      // }
      // else {
      this.item = item;
      this.showDetailPopup = true;
      // }
    },
    calcStatusType(status) {
      switch (status) {
        case "disclousure_status_5":
          return "danger";
        case "disclousure_status_4":
          return "success";
        default:
          return "primary";
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

    selfCheckedHandler(value) {
      this.pullRefreshLoading = true;
      this.onRefresh();
    },

    reloadList(){
      this.pullRefreshLoading = true;
      this.onRefresh();
    }
  },
  watch: {
    showDetailPopup(val) {
      if (!val) {
        // 重新绑定返回事件
        this.addEventBackButtonBack();
      }
    },
  },

  mounted() {
    this.addEventBackButtonBack();
    // this.getData();
  }
};
</script>