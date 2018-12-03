<!-- 首页 -->
<template>
    <tms-page class="index">
        <div slot="content">
            <!-- dashboard -->
            <dashboard v-if="active == 0"></dashboard>
            <!-- 工作台 -->
            <platform v-if="active===1"></platform>
            <!-- 个人信息 -->
            <myInfo v-if="active===2"></myInfo>
        </div>
        <!-- tab标签 -->
        <div slot="footer">
            <van-tabbar v-model="active">
                <van-tabbar-item icon="wap-home">{{ $t("index.home") }}</van-tabbar-item>
                <van-tabbar-item icon="idcard">{{ $t("index.platform") }}</van-tabbar-item>
                <van-tabbar-item icon="contact">{{ $t("index.myInfo") }}</van-tabbar-item>
            </van-tabbar>
        </div>
    </tms-page>
</template>

<script>
// import upgrade from "../config/plusUpgrade.js";
import dashboard from './dashboard'
import platform from "../page/project/platform";
import myInfo from "../page/system/user/myInfo";
export default {
    components: {
        dashboard,
        platform,
        myInfo
    },
    data() {
        return {
            name: "",
            active: 0,
            //填充沉浸式状态栏
            navbarStyle: "",
            stateBarHeight: "height:0px"
        };
    },
    methods: {
        //监听返回按钮_按返回键后关闭
        addEventBackButtonClose() {
            if (sessionStorage.plusready === "done") {
                //监听返回按钮
                plus.key.removeEventListener("backbutton", () => {
                    this.toBack();
                });
            }
        }
        //更新app
        // updateApp() {
        //   if (sessionStorage.plusready === "done") {
        //     if (sessionStorage.updateChecked != "done") {
        //       //自动升级
        //       console.log("升级程序调用");
        //       let version = sessionStorage.version;
        //       let appname = sessionStorage.appname;
        //       if (version != null && appname != null) {
        //         console.log("调用更新信息:" + version + "  " + appname);
        //         upgrade.checkUpdate(this, version, appname);
        //         console.log("更新结束");
        //         sessionStorage.setItem("updateChecked", "done");
        //       }
        //     }
        //   } else {
        //     setTimeout(() => {
        //       this.updateApp();
        //     }, 3000);
        //   }
        // }
    },
    mounted() {
        if (!sessionStorage.getItem("token")) {
            sessionStorage.setItem("token", localStorage.getItem("token"));
        }
        //监听手机关闭事件
        this.addEventBackButtonClose();
        //系统自动更新
        // this.updateApp();

        //填充沉浸式状态栏
        this.navbarStyle =
            "top:" + (localStorage.getItem("statusbarH") * 1 + 50) + "px";
        this.stateBarHeight =
            "height:" + localStorage.getItem("statusbarH") * 1 + "px";
    },
    created() {
        if (this.$route.query) {
            this.active = this.$route.query.active ?
                parseInt(this.$route.query.active) :
                0;
        }
        if (!localStorage.getItem("token")) {
            this.$router.push("/login");
        }

    }
};
</script>

<style lang="less" scoped>
.index {
  height: 100%; // overflow-y:scroll;-webkit-overflow-scrolling:touch;
}
</style>
<style lang="less">
.index {
  .van-tabbar--fixed {
    position: initial;
    border-top: 1px solid #e7e3e3;
  }
}
</style>

