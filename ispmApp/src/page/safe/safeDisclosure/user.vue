<style lang="less" scoped>
    .popupWrapper {
      height: 100%;
      width: 100%;
      .userListWrapper {
        // position: absolute;
        // top: 90px;
        // bottom: 0;
        // left: 0;
        // right: 0;
        overflow: auto;
        -webkit-overflow-scrolling: touch;

        .van-pull-refresh {
          height: 100%;
          overflow: auto;
          .van-pull-refresh__track {
            height: 100%;
          }
        }
      }
    }
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
    <van-popup v-model="value" class="popupWrapper c_flex c_direction_v" position="right" :lazy-render="false">
        <nav-bar left-arrow :left-text="$t('public.back')" @click-left="cancel" :right-text="$t('public_button.save')" @click-right="submit" :title="$t('safeDisclosureUser.title')"></nav-bar>
        <van-search placeholder="请输入用户姓名" show-action v-model="userName" @search="handleUserSearch">
            <div slot="action" @click="handleUserSearch">搜索</div>
        </van-search>
        <div class="userListWrapper c_flex_1" ref="content">
            <van-pull-refresh v-model="pullRefreshLoading" @refresh="onRefresh">
                <van-list v-model="loading" :finished="finished" :offset="10" @load="getData">
                    <van-checkbox-group v-model="selection">
                        <van-cell-group>
                            <van-cell v-for="(item, index) in listData" :key="index" center clickable @click="toggleSelection(index, item)">
                                <div class="c_flex c_j_between">
                                    <div>
                                        <span class="user-info van-cell-text">{{ item.user.name }}</span>
                                        <span class="user-extra-info">{{item.user.loginName}}</span>
                                        <span class="user-extra-info">{{item.office.name}}</span>
                                    </div>
                                    <van-checkbox :name="item" ref="checkboxes"> </van-checkbox>
                                </div>
                            </van-cell>
                        </van-cell-group>
                    </van-checkbox-group>
                </van-list>
            </van-pull-refresh>
        </div>
    </van-popup>
</template>
<script>
import cloneDeep from "lodash/cloneDeep";
import uniqBy from "lodash/uniqBy";
import intersectionBy from "lodash/intersectionBy";
const uri = {
  list: "/project/projectUserRole/list"
};
export default {
  data() {
    return {
      pullRefreshLoading: false,
      loading: false,
      finished: false,
      listData: [],
      totalCount: 0,
      pageInfo: { pageNo: 1, pageSize: 10 },

      userName: "",

      /**选中的行项目 */
      selection: [],

      storeSelection: []
    };
  },
  props: {
    value: { type: Boolean, default: false, required: true }
  },

  watch: {
    value(val) {
      if (val) {
        this.addEventBackButtonBack();
        this.getData();
      } else {
        this.listData.splice(0);
        this.selection.splice(0);
        this.storeSelection.splice(0);
        this.userName = "";
        this.pageInfo = { pageNo: 1, pageSize: 20 };
      }
    }
  },

  methods: {
    cancel() {
      this.$emit("input", false);
    },
    submit() {
      this.storeSelection.forEach(item => {
        delete item.id;
      });
      this.$emit("select", this.storeSelection);
      this.$emit("input", false);
    },

    onRefresh() {
      this.pageInfo = { pageNo: 1, pageSize: 10 };
      this.getData();
    },
    getData() {
      let filterInfo = Object.assign(
        {},
        this.pageInfo,
        this.userName ? { user: { name: this.userName } } : {}
      );
      this.$axios
        .post(uri.list, filterInfo)
        .then(resp => {
          if (this.pullRefreshLoading) {
            this.selection.splice(0);
            this.listData.splice(0);
          }

          this.listData = this.listData.concat(resp.list);
          this.totalCount = resp.count;

          if (this.pullRefreshLoading) {
            this.listData.forEach((user, index) => {
              let findObj = this.storeSelection.find(item => {
                return item.id === user.id;
              });
              if (findObj) {
                setTimeout(() => {
                  this.$refs.checkboxes[index].toggle();
                }, 0);
              }
            });
          }

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
          this.finished = true;
        })
        .finally(res => {
          this.loading = false;
          this.pullRefreshLoading = false;
        });
    },

    toggleSelection(index, item) {
      this.$refs.checkboxes[index].toggle();
      let flag = false;
      this.storeSelection.forEach((element, elementIdx) => {
        if (element.id === item.id && this.$refs.checkboxes[index].checked) {
          this.storeSelection.splice(elementIdx, 1);
          flag = true;
        }
      });
      if (!flag) {
        this.storeSelection.push(item);
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
          this.cancel();
        });
      }
    },

    /**查询 */
    handleUserSearch() {
      this.pullRefreshLoading = true;
      this.onRefresh();
    }
  }
};
</script>

