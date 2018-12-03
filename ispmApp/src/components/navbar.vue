<template>
<div :style="navbarStyle">
  <div
    class="van-nav-bar"
    :class="{ 'van-nav-bar--fixed': fixed }"
    :style="style"
  >
      <div style="height:46px;width:100%">
          <div class="van-nav-bar__left" @click="$emit('click-left')">
          <slot name="left">
              <i v-if="leftArrow"  class="van-icon van-icon-arrow-left"/>
              <span v-if="leftText" v-text="leftText" class="van-nav-bar__text" />
          </slot>
          </div>
          <div class="van-nav-bar__title van-ellipsis" @click="$emit('click-title')">
          <slot name="title">{{ title }}</slot>
          <slot name="selectStyle" v-if="selectStyle"><span style="font-size:.12rem">&#9660;</span></slot>
          </div>
          <div class="van-nav-bar__right" @click="$emit('click-right')">
          <slot name="right">
              <span v-if="rightText" v-text="rightText" class="van-nav-bar__text" />
          </slot>
          </div>
      </div>
    </div>
  </div>
<!-- </div>  -->


</template>

<script>
export default {

  props: {
    title: String,
    leftText: String,
    rightText: String,
    leftArrow: Boolean,
    fixed: Boolean,
    zIndex: {
      type: Number,
      default: 1
    },
    selectStyle: Boolean
  },
    data() {
        return {
          navbarStyle: "padding-top:0px;background-color:#3388FF;"
        }
    },
    computed: {
    style() {
      return {
        zIndex: this.zIndex
      };
    }
  },
   mounted() {

    if (sessionStorage.plusready === "done")
    {
          this.navbarStyle =  'padding-top:'+localStorage.getItem('statusbarH') +'px';
    }
  }
}
</script>

<style scoped>
    .fillStatubar
    {
        width: 100%;
    }
</style>


 <style lang="less" type="text/less" scoped>
 .van-nav-bar {
    
    background: url('../assets/index/banner.png') no-repeat;
    background-size:100% 100%;  
     height: unset;
     * {
         color: #ffffff;
         &:active{
             background: none;
         }
     }
 }
 </style>
