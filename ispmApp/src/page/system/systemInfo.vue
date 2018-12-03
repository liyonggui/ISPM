<template>
    <div class="userInfo">

        <nav-bar left-arrow left-text="返回" @click-left="toBack" title="系统信息" />

        <van-cell-group class="user-group">
            <van-cell title="版本号" :value="version" />
            <!-- <van-cell title="意见反馈" is-link />
            <van-cell title="规则说明" is-link />
            <van-cell title="用户协议" is-link />
            <van-cell title="隐私政策" is-link /> -->
        </van-cell-group>

    </div>
</template>

<script>
export default {
    data() {
        return {
            version: ""
        };
    },
    created() {
        this.addEventBackButtonBack();
        this.version = sessionStorage.version;
    },
    methods: {
        //返回上一页
        toBack() {
            this.$router.push("/index?index=1");
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
    }
};
</script>

<style lang="less" scoped>
.userInfo {
    height: 100%;
    background-repeat: no-repeat;
    background-size: cover;
    background-color: whitesmoke;
    .van-nav-bar {
        background: transparent;
    }
    .van-hairline--bottom {
        &::after {
            border-bottom-width: 0px;
        }
    }
    .user-group {
        margin-bottom: 0.1rem;
    }
}
</style>
