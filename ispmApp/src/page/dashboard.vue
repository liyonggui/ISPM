<style lang="less" scoped>
.container {
  .content {
    // margin-top: 46px;
    overflow: auto;
    -webkit-overflow-scrolling: touch;
  }
  .iot-data {
    display: flex;
    flex-wrap: wrap;

    background-color: white;
    margin-bottom: 5px;

    .section-item {
      display: flex;
      flex-direction: column;
      color: #333;
      width: 50%;
      font-size: 12px;
      text-align: center;
      padding: 10px;
      img {
        width: 50%;
        margin-left: 25%;
        padding-bottom: 10px;
      }
    }
  }

  .col-data {
    display: flex;
    background: white;
    margin-bottom: 5px;

    .section-item {
      display: flex;
      flex-direction: column;
      color: #333;
      width: 33.33%;
      font-size: 12px;
      text-align: center;
      padding: 10px;
      img {
        width: 50%;
        margin-left: 25%;
        padding-bottom: 10px;
      }
    }
  }

  .chart-section {
    background: white;
    font-size: 12px;
    color: #333;
    padding: 5px 0;
    .title {
      padding-left: 10px;
    }
    #chart {
      width: 100%;
    }
  }
}
</style>
<style lang="less">
.select {
  top: 0.5rem;
  width: 80%;
  // height: 50%;
  // overflow-y: scroll;
  // -webkit-overflow-scrolling: touch;
  padding: 0.05rem;
}
</style>

<template>
    <div class="container">
        <!-- <nav-bar title="dashboard" /> -->
        <nav-bar :title="currentProject.name" selectStyle @click-title="show=!show" />
        <van-row>
            <van-loading style="align:center" color="black" v-if="loadingData" />
        </van-row>
        <!-- 弹出层 -->
        <van-popup v-model="show" position="top" class="select">
            <van-list v-model="loading" :finished="finished" @load="onLoad" style="padding-bottom:0.36rem;">
                <van-cell v-for="item in projectList" :key="item.id" @click="switchProject(item)" style="padding-left:.2rem;">
                    <van-icon name="description" style="color:#3388FF;" />
                    <span>&nbsp;&nbsp;{{item.name}}（{{item.code}}）</span>
                </van-cell>
            </van-list>
        </van-popup>

        <div class="content">
            <div class="iot-data">
                <div class="section-item">
                    <img src="../assets/dashboard/a.png" alt="">
                    <span>工地湿度：30% RH</span>
                </div>
                <div class="section-item">
                    <img src="../assets/dashboard/b.png" alt="">
                    <span>工地温度：23℃</span>
                </div>
                <div class="section-item">
                    <img src="../assets/dashboard/c.png" alt="">
                    <span>空气质量：优</span>
                </div>
                <div class="section-item">
                    <img src="../assets/dashboard/d.png" alt="">
                    <span>PM2.5：100μg/m³</span>
                </div>
            </div>
            <div class="col-data">
                <div class="section-item">
                    <img src="../assets/dashboard/1.png" alt="">
                    <span>塔吊</span>
                    <span>
                        <span style="color: red">{{tadiaoData.red}}</span> /
                        <span style="color: #888865">{{tadiaoData.yellow}}</span> / {{tadiaoData.total}}
                    </span>
                </div>
                <div class="section-item">
                    <img src="../assets/dashboard/2.png" alt="">
                    <span>项目人员</span>
                    <span>
                        {{userData.enabled}} / {{userData.total}}
                    </span>
                </div>
                <div class="section-item">
                    <img src="../assets/dashboard/3.png" alt="">
                    <span>深基坑</span>
                    <span>
                        <span style="color: red">{{kengjingData.red}}</span> /
                        <span style="color: #888865">{{kengjingData.yellow}}</span> / {{kengjingData.total}}
                    </span>
                </div>
            </div>
            <div class="chart-section">
                <span class="title">安全隐患统计</span>
                <canvas id="chart"></canvas>
            </div>
        </div>
    </div>
</template>
<script>
import clone from 'lodash/clone'
import values from 'lodash/values'
import F2 from '@antv/f2';

import { init } from "../config/ready.js";
const baseUrl = {
    safeDanger: '/dashboard/safeDanger',

    user: '/dashboard/user',
    tadiao: '/dashboard/tadiao',
    kengjing: '/dashboard/kengjing',
}
export default {
    name: 'dashboard',
    data() {
        return {
            userData: {},
            tadiaoData: {},
            kengjingData: {},

            chartData: {},

            chart: null,

            /**切换项目 */
            loading: false,
            finished: true,
            show: false,
            loadingData: false,
            userMenuShow: true
        }
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
    },
    methods: {
        safeDanger() {
            this.$axios.post(baseUrl.safeDanger, {})
                .then(resp => {
                    let result = []
                    resp.data.forEach(dataElement => {
                        resp.name.split(',').forEach((element, idx) => {
                            let temp = {
                                name: element,
                                type: dataElement.name,
                                val: parseInt(dataElement.data.split(',')[idx])
                            }

                            result.push(temp)
                        })
                    });
                    this.chart.changeData(result)
                })
        },

        user() {
            this.$axios.post(baseUrl.user, {})
                .then(resp => {
                    this.userData = resp
                })
        },

        tadiao() {
            this.$axios.post(baseUrl.tadiao, {})
                .then(resp => {
                    this.tadiaoData = resp
                })
        },

        kengjing() {
            this.$axios.post(baseUrl.kengjing, {})
                .then(resp => {
                    this.kengjingData = resp
                })
        },

        chartRender() {
            this.chart = new F2.Chart({
                id: 'chart',
                // height: 265,
                pixelRatio: window.devicePixelRatio
            });

            this.chart.interval().position('name*val').color('type').adjust({
                type: 'dodge',
                marginRatio: 0.05 // 设置分组间柱子的间距
            });
            this.chart.legend({ itemWidth: null, position: 'top', align: 'center' })
            this.chart.source(this.chartData)
            this.chart.render();
        },

        /**项目切换 */
        onLoad() { },
        switchProject(project) {
            this.show = false;
            this.loadingData = true;
            this.userMenuShow = false;
            if (project) {
                this.$axios
                    .post("/sys/project/set", project)
                    .then(resp => {
                        this.$store.commit("initializeCurrentProject", project);
                        this.loadingData = false;
                        this.userMenuShow = true;
                        init(this);


                        this.user()
                        this.tadiao()
                        this.kengjing()
                        this.safeDanger()
                    });
            }
        },
    },
    created() {
        this.user()
        this.tadiao()
        this.kengjing()
        this.safeDanger()
    },
    mounted() {
        // 设置 dashboard 高度
        this.$el.style.height = document.body.offsetHeight - 50 + 'px'

        let navbarHeight = document.querySelector('.van-nav-bar').offsetHeight
        this.$el.querySelector('.content').style.height = document.body.offsetHeight - 50 - navbarHeight + 'px'

        let iotHeight = this.$el.querySelector('.iot-data').offsetHeight
        let colHeight = this.$el.querySelector('.col-data').offsetHeight
        // this.$el.querySelector('#chart').style.height = document.body.offsetHeight - 50 - navbarHeight - iotHeight - colHeight + 'px'
        this.chartRender()
    }
}
</script>
