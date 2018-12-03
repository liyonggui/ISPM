<template lang="html">
  <div class="system-ready"
       v-loading="loading"
       element-loading-text="系统准备中">
    <p v-if="!isReady && !loading">
      系统准备失败
      <a href="javascript:;" @click="ready">重试</a>
    </p>
    <div style="height:100%;" >
    <transition name="slide-fade" mode="out-in">
      <router-view ref="pageview" v-if="isReady && !loading"></router-view>
    </transition>
    </div>
  </div>
</template>

<script>
  import Index from './index.vue'
  import {init} from 'src/config/ready.js'

  export default {

    created() {
      this.ready()
      // this.callback();
    },
    data() {
      return {
        loading: true,
        isReady: false,
        startX: 0,
        startY: 0,
        moveX:0,
        moveY:0,
        m_sX:0,
        m_sY:0,
        is_back:true,
        currentView: ''
      }
    },
    methods: {
      start (ev) {
          this.isMove = false;
          this.startX = ev.changedTouches[0].clientX;
          this.startY = ev.changedTouches[0].clientY;
          if(this.startX > 20){
            //console.log('不是在左侧开始');
            //开始位置在左侧10px内
            this.is_back = false;
          }
          //console.log('start   '+this.startX+'  '+this.startY)
      },
      move (ev) {
          ev.stopPropagation();
          this.moveX = ev.changedTouches[0].clientX;
          this.moveY = ev.changedTouches[0].clientY;
          this.m_sX = this.moveX - this.startX;
          this.m_sY = this.moveY - this.startY;
          if(Math.abs(this.getAngle(this.moveX,this.moveY,this.startX,this.startY)) > 25){
            this.is_back = false;
          }
          //console.log('move   '+this.moveX+'   '+this.moveY+'---'+this.m_sX+'    '+this.m_sY +'角度：' + Math.abs(this.getAngle(this.moveX,this.moveY,this.startX,this.startY)));
      },
      getAngle(x1, y1,  x2, y2){
	       	var x = Math.abs(x1 - x2);
	       	var y = Math.abs(y1 - y2);
	       	var z = Math.sqrt(x*x + y*y);
	       	return  Math.round((Math.asin(y / z) / Math.PI*180));
	    },
      end (ev) {
        //  console.log('              end   '+this.m_sX)
          if(this.m_sX > 100) {

            if(_.has(this.$refs.pageview.$options.methods,'toBack') && this.is_back){
            //  console.log('返回！');
              this.$refs.pageview.$options.methods.toBack.bind(this)()
            }
          } else {
             // console.log('不返回！');
          }
          this.m_sX = 0;
          this.m_sY = 0;
          this.is_back = true;
      },
      ready() {
        init(this, this.callback)
        window.addEventListener('online',  () => {
          this.$store.commit('setOffLineStatus', false)
        });
        window.addEventListener('offline', () => {
          this.$store.commit('setOffLineStatus', true)
        });
      },
      callback(result) {
        this.loading = false;
        if (result === 'error') {
          this.isReady = false;
        } else {
          this.isReady = true;
          this.$router.push(this.$route.fullPath)
        }
      }
    }
  }
</script>

<style lang="less" scoped>

  .router-fade-enter-active, .router-fade-leave-active {
	  	transition: opacity .1s;
	}
	.router-fade-enter, .router-fade-leave-active {
	  	opacity: 0;
  }

  .slide-fade-enter-active {
    transition: all .3s ease;
  }
  .slide-fade-leave-active {
    transition: all .2s cubic-bezier(1.0, 0.5, 0.8, 1.0);
  }
  .slide-fade-leave-to{
    transform: translateX(20px);
    opacity: 0;
  }
  .slide-fade-enter,
  /* .slide-fade-leave-active for below version 2.1.8 */ {
    transform: translateX(50px);
    opacity: 0;
  }

  .system-ready {
    height: 100%;
    background-color: #f1f6f9
  }

  p {
    color: #666;
    font-size: 14px;
    text-align: center;
    margin-top: 40%;

    a {
      margin-left: 10px;
    }

  }
</style>
