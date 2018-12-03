<!-- 工作台 -->
<template>
<div class="platform">
    <!-- 导航条 -->
    <nav-bar :title="currentProject.name" selectStyle @click-title="show=!show" >
        <van-icon slot="right" name="info-o" style="font-size: 18px;" @click="$router.push('/project/detail?id='+currentProject.id)"></van-icon>
    </nav-bar>
    <van-row>
        <van-loading style="align:center" color="black" v-if="loadingData" />
    </van-row>
    <!-- 弹出层 项详情-->
    <van-popup v-model="show" position="top" class="select">
        <van-list v-model="loading" :finished="finished" @load="onLoad" style="padding-bottom:0.36rem;">
            <van-cell v-for="item in projectList" :key="item.id" @click="switchProject(item)" style="padding-left:.2rem;">
                <van-icon name="description" style="color:#3388FF;" />
                <span>&nbsp;&nbsp;{{item.name}}（{{item.code}}）</span>
            </van-cell>
        </van-list>
    </van-popup>
    <!-- 菜单按钮平铺 -->
    <div class="content" v-if="userMenuShow">
        <van-panel v-for="ele in userMenu.children" :key="ele.id" style="padding-top:.05rem;">
            <div slot="header" class="van-cell van-hairline van-panel__header">
                <span class="titleSpan"></span> {{ele.title}}
            </div>
            <div class="menu">
                <div v-for="e in ele.children" :key="e.id" class="child-menu" @click="menuClickHandler(e)">
                    <van-row style="display:flex;justify-content:center;align-items:center;">
                        <!-- <van-icon :name="e.icon" class="menu-icon"/> -->
                        <div class="menu-icon" :style="'background-image:url('+require('../../assets/index/'+e.icon+'.png') +');background-size: 100% 100%'">
                        </div>
                    </van-row>
                    <van-row>
                        <span class="menu-title">{{e.title}}</span>
                    </van-row>
                </div>
            </div>
        </van-panel>
    </div>
    <!-- 没有项目提示 -->
    <no-data v-if="projectList.length==0" :title="$t('project.noProject')"></no-data>
</div>
</template>

<script>
 
import {
    init
} from "../../config/ready.js";
 

const uri = {
    switchProject: "/sys/project/set",

};
export default {

    data() {
        return {
            loading: false,
            finished: true,
            show: false,
            loadingData: false,
            userMenuShow: true
        };  
    },
    methods: {
        onLoad() {},
        switchProject(project) {
            this.show = false;
            // this.test = !this.test;
            // todo: how to do when no project
            this.loadingData = true;
            this.userMenuShow = false;
            if (project) {
                this.$axios
                    .post(uri.switchProject, project)
                    .then(resp => {
                        this.$store.commit("initializeCurrentProject", project);
                        this.loadingData = false;
                        this.userMenuShow = true;
                        init(this);
                    });
            }
        },
        menuClickHandler(menu) {
            // 增加参数支持，可以在菜单name中配置参数: ?param1:xxx&param2:xxxx
            const name = menu.name;
            let arr = name.split('?');
            let params = {};
            if (arr.length > 1) {
                // 有参数，按&拆分
                let paramArr = arr[1].split('&');
                paramArr.forEach(element => {
                    // 按=拆分key-value
                    let param = element.split('=');
                    params[param[0]] = param[1];
                });
                // 菜单进行了特殊设置，params中增加key：_menu
                params._menu = JSON.stringify({
                    name: menu.name,
                    title: menu.title
                });
            } 
            this.$router.push({
                name: arr[0],
                query: params
            });
        },
     
       
    },
    computed: {
        projectList() {
            return this.$store.state.projects;
        },
        currentProject() {
            return this.$store.state.currentProject;
        },
        userMenu() {
            return this.$store.state.userMenu;
        } 
    }
};
</script>

<style lang="less">
.platform {
    height: 100%;

    .select {
        top: 0.5rem;
        width: 80%;
        // height: 50%;
        // overflow-y: scroll;
        // -webkit-overflow-scrolling: touch;
        padding: 0.05rem;
    }

    .content {
        height: 100%;
        width: 100%;

        .titleSpan {
            width: 4px;
            height: 18px;
            line-height: 18px;
            background: #2A8CFF;
            margin-right: .05rem;
            margin-top: .02rem;
            border-radius: .05rem;
        }

        .menu {
            width: 100%;
            height: 100%;
            display: flex;
            flex-wrap: wrap;
            text-align: center;
            background: white;

            .child-menu {
                height: 25%;
                width: 32%;
                padding: 0.08rem;
                flex-direction: row;

                .menu-icon {
                    color: #3388ff;
                    font-size: 0.46rem;
                    width: 0.64rem;
                    height: 0.64rem;
                }

                .menu-title {
                    font-size: 0.12rem;
                    color: #666666
                }
            }
        }
    }

    .van-loading {
        margin: 0 auto;
        height: 1.6rem;
    }

    .van-cell-group {
        background-color: #f1f6f9
    }

    .van-cell__title {
        color: #000;
    }

    .van-cell:not(:last-child):after {
        border-bottom-width: 0px;
    }
}
</style>
