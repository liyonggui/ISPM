<!-- 个人信息 -->
<template>
    <div class="userInfo">
        <nav-bar :title="$t('myInfo.myInfo')"/>
        <van-cell-group class="user-group">
            <van-cell :title="$t('myInfo.name')" :value="accountInfo.name" />
            <van-cell :title="$t('myInfo.phoneNo')" :value="accountInfo.loginName" />
            <van-cell :title="$t('myInfo.company')" :value="accountInfo.company.name" />
        </van-cell-group>
        <van-cell-group class="user-group">
            <van-cell :title="$t('myInfo.changePassword')" is-link @click="$router.push('/system/changePassword')" />
            <van-cell :title="$t('myInfo.logout')" is-link @click="logout" />
        </van-cell-group>
        <van-cell-group>
            <van-cell :title="$t('myInfo.about')" is-link @click="toAbout" />
        </van-cell-group>
    </div>
</template>

<script>
import { logout } from "../../../config/login";
export default {
    components: {},
    data() {
        return {
        };
    },
 
    computed: {
        accountInfo () {
            return this.$store.state.accountInfo;
        }
    },
    methods: {
   
        toAbout() {
            if (this.$route.query.index == 1) {
                this.$router.push("/system/systemInfo?index=1");
            } else {
                this.$router.push("/system/systemInfo");
            }
        },
        //登出系统
        logout() {
            logout(this,this.$router);  
        },
 
    }
};
</script>

<style lang="less" scoped>
.userInfo {
    height: 100%;
    background-repeat: no-repeat;
    background-size: cover;
    .user-group {
        margin-bottom: 0.1rem;
    }
}
</style>
